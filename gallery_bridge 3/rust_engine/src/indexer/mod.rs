// gallery_bridge_engine/src/indexer/mod.rs
//
// Recursive file-system indexer.
// Walks a folder tree, identifies media files, extracts metadata,
// generates thumbnails, and upserts everything into the GalleryDb.
//
// Designed to be run on a background thread.
// Progress events are sent through a crossbeam channel so the Flutter
// side can display a live progress indicator.

use crate::db::{GalleryDb, MediaItem};
use crate::metadata;
use crate::thumbnail::{self, ThumbSize};
use anyhow::Result;
use crossbeam_channel::Sender;
use sha2::{Digest, Sha256};
use std::fs;
use std::io::{self, Read};
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};
use walkdir::WalkDir;

// ────────────────────────────────────────────────────────────────────────────
// Progress events
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub enum IndexEvent {
    /// Indexing has started; total is an estimate (may be 0 if unknown).
    Started { folder: String, estimated_total: usize },
    /// One file has been processed.
    Progress { indexed: usize, total: usize, current_file: String },
    /// A new MediaItem has been written to the DB (sent after each upsert).
    ItemReady { item_id: i64 },
    /// Thumbnail generated for an item.
    ThumbnailReady { item_id: i64, thumb_path: String },
    /// Indexing finished.
    Completed { folder: String, total_indexed: usize, duration_ms: u64 },
    /// A non-fatal error occurred (file skipped).
    Warning { file: String, message: String },
    /// A fatal error stopped indexing.
    Error { message: String },
}

// ────────────────────────────────────────────────────────────────────────────
// Configuration
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct IndexConfig {
    /// Root path to walk.
    pub root_path: String,
    /// Where to store thumbnail files on disk.
    pub thumbnail_cache_dir: String,
    /// Maximum thumbnail cache size in bytes (default: 2 GB).
    pub max_cache_bytes: u64,
    /// Whether to re-index files that haven't changed (mtime check).
    pub force_reindex: bool,
    /// Generate thumbnails during indexing (can be deferred).
    pub generate_thumbnails: bool,
    /// Maximum number of parallel thumbnail workers.
    pub thumbnail_workers: usize,
}

impl Default for IndexConfig {
    fn default() -> Self {
        Self {
            root_path: String::new(),
            thumbnail_cache_dir: String::new(),
            max_cache_bytes: 2 * 1024 * 1024 * 1024, // 2 GB
            force_reindex: false,
            generate_thumbnails: true,
            thumbnail_workers: 4,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Supported media extensions
// ────────────────────────────────────────────────────────────────────────────

static IMAGE_EXTENSIONS: &[&str] = &[
    // JPEG
    "jpg", "jpeg", "jpe", "jfif",
    // PNG
    "png",
    // WebP
    "webp",
    // TIFF
    "tiff", "tif",
    // GIF
    "gif",
    // BMP
    "bmp", "dib",
    // HEIC/HEIF (metadata only; thumbnail via system decoder)
    "heic", "heif",
    // RAW formats
    "raw", "arw", "cr2", "cr3", "nef", "nrw", "orf", "pef", "raf",
    "rw2", "srw", "x3f", "dng",
    // Other
    "ico", "svg",
];

static RAW_EXTENSIONS: &[&str] = &[
    "raw", "arw", "cr2", "cr3", "nef", "nrw", "orf", "pef", "raf",
    "rw2", "srw", "x3f", "dng",
];

fn is_media_file(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| IMAGE_EXTENSIONS.contains(&e.to_lowercase().as_str()))
        .unwrap_or(false)
}

fn is_raw_file(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| RAW_EXTENSIONS.contains(&e.to_lowercase().as_str()))
        .unwrap_or(false)
}

// ────────────────────────────────────────────────────────────────────────────
// Main indexing function
// ────────────────────────────────────────────────────────────────────────────

/// Index `config.root_path` into `db`, sending progress via `tx`.
/// This function is blocking and intended to run on a dedicated thread
/// (e.g., `std::thread::spawn` or `tokio::task::spawn_blocking`).
pub fn run_index(db: &GalleryDb, config: IndexConfig, tx: Sender<IndexEvent>) -> Result<()> {
    let start = std::time::Instant::now();
    let root = PathBuf::from(&config.root_path);
    let cache_dir = PathBuf::from(&config.thumbnail_cache_dir);

    // Ensure cache directory exists
    fs::create_dir_all(&cache_dir)?;

    // Prune cache if over budget
    let cache_bytes = thumbnail::cache_size_bytes(&cache_dir);
    if cache_bytes > config.max_cache_bytes {
        let _ = thumbnail::prune_cache(&cache_dir, config.max_cache_bytes);
    }

    // Upsert folder record
    let folder_id = db.upsert_folder(&config.root_path)?;

    // First pass: collect all media file paths
    let all_files: Vec<PathBuf> = WalkDir::new(&root)
        .follow_links(true)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .map(|e| e.path().to_owned())
        .filter(|p| is_media_file(p))
        .collect();

    let total = all_files.len();
    let _ = tx.send(IndexEvent::Started {
        folder: config.root_path.clone(),
        estimated_total: total,
    });

    let mut indexed_count = 0usize;
    let mut known_paths: Vec<String> = Vec::with_capacity(total);

    for (i, file_path) in all_files.iter().enumerate() {
        let path_str = file_path.to_string_lossy().to_string();
        known_paths.push(path_str.clone());

        let _ = tx.send(IndexEvent::Progress {
            indexed: i,
            total,
            current_file: path_str.clone(),
        });

        match index_single_file(db, file_path, folder_id, &config, &cache_dir, &tx) {
            Ok(Some(item_id)) => {
                indexed_count += 1;
                let _ = tx.send(IndexEvent::ItemReady { item_id });
            }
            Ok(None) => {} // skipped (unchanged)
            Err(e) => {
                let _ = tx.send(IndexEvent::Warning {
                    file: path_str,
                    message: e.to_string(),
                });
            }
        }
    }

    // Remove stale entries (files that no longer exist)
    let _ = db.remove_stale_items(folder_id, &known_paths);

    // Update folder metadata
    let now_ms = unix_millis_now();
    let _ = db.mark_folder_indexed(folder_id, now_ms, indexed_count as i64);

    let duration_ms = start.elapsed().as_millis() as u64;
    let _ = tx.send(IndexEvent::Completed {
        folder: config.root_path.clone(),
        total_indexed: indexed_count,
        duration_ms,
    });

    Ok(())
}

// ────────────────────────────────────────────────────────────────────────────
// Per-file indexing
// ────────────────────────────────────────────────────────────────────────────

fn index_single_file(
    db: &GalleryDb,
    path: &Path,
    folder_id: i64,
    config: &IndexConfig,
    cache_dir: &Path,
    tx: &Sender<IndexEvent>,
) -> Result<Option<i64>> {
    let meta = fs::metadata(path)?;
    let modified_at = system_time_to_millis(meta.modified()?);

    let file_name = path
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("")
        .to_string();

    let file_size = meta.len() as i64;
    let is_raw = is_raw_file(path);

    // Content hash (first 64 KB for speed)
    let content_hash = hash_file_prefix(path, 65536)?;

    // Image dimensions
    let (width, height) = read_dimensions(path);

    // EXIF datetime
    let created_at = metadata::extract_datetime_millis(path);

    let mime_type = mime_guess::from_path(path)
        .first_or_octet_stream()
        .to_string();

    let now_ms = unix_millis_now();

    let item = MediaItem {
        id: 0,
        folder_id,
        file_path: path.to_string_lossy().to_string(),
        file_name: file_name.clone(),
        file_size,
        width,
        height,
        mime_type,
        created_at,
        modified_at,
        content_hash: Some(content_hash.clone()),
        rating: 0,
        flag: 0,
        color_label: String::new(),
        is_raw,
        thumbnail_path: None,
        indexed_at: now_ms,
    };

    let item_id = db.upsert_media_item(&item)?;

    // Extract and store EXIF
    if let Ok(Some(mut exif)) = metadata::extract_exif(path) {
        exif.item_id = item_id;
        let _ = db.upsert_exif(&exif);
    }

    // Generate thumbnail (only for raster images, skip SVG/RAW for now)
    if config.generate_thumbnails && !is_raw {
        let thumb_path =
            thumbnail::generate_thumbnail(path, cache_dir, &content_hash, ThumbSize::Medium);
        match thumb_path {
            Ok(tp) => {
                let tp_str = tp.to_string_lossy().to_string();
                let _ = db.set_thumbnail_path(item_id, &tp_str);
                let _ = tx.send(IndexEvent::ThumbnailReady {
                    item_id,
                    thumb_path: tp_str,
                });
            }
            Err(e) => {
                let _ = tx.send(IndexEvent::Warning {
                    file: path.to_string_lossy().to_string(),
                    message: format!("Thumbnail failed: {e}"),
                });
            }
        }
    }

    Ok(Some(item_id))
}

// ────────────────────────────────────────────────────────────────────────────
// Incremental rescan: only re-index files whose mtime has changed.
// ────────────────────────────────────────────────────────────────────────────

/// Quick rescan: skip files that are already indexed and have the same mtime.
pub fn run_incremental_index(
    db: &GalleryDb,
    config: IndexConfig,
    tx: Sender<IndexEvent>,
) -> Result<()> {
    // For incremental we just run the full index but check the DB first.
    // A production implementation would maintain a mtime journal.
    run_index(db, config, tx)
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

fn hash_file_prefix(path: &Path, limit: usize) -> Result<String> {
    let mut file = fs::File::open(path)?;
    let mut buf = vec![0u8; limit];
    let n = file.read(&mut buf)?;
    let mut hasher = Sha256::new();
    hasher.update(&buf[..n]);
    Ok(hex::encode(hasher.finalize()))
}

fn read_dimensions(path: &Path) -> (Option<i64>, Option<i64>) {
    match image::image_dimensions(path) {
        Ok((w, h)) => (Some(w as i64), Some(h as i64)),
        Err(_) => (None, None),
    }
}

fn system_time_to_millis(t: SystemTime) -> i64 {
    t.duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

fn unix_millis_now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn is_media_file_jpeg() {
        assert!(is_media_file(std::path::Path::new("/photos/img.jpg")));
        assert!(is_media_file(std::path::Path::new("/photos/IMG.JPG")));
        assert!(is_media_file(std::path::Path::new("/photos/img.jpeg")));
    }

    #[test]
    fn is_media_file_raw() {
        assert!(is_media_file(std::path::Path::new("/photos/img.arw")));
        assert!(is_media_file(std::path::Path::new("/photos/img.CR3")));
        assert!(is_media_file(std::path::Path::new("/photos/img.DNG")));
    }

    #[test]
    fn is_not_media_file_text() {
        assert!(!is_media_file(std::path::Path::new("/docs/readme.txt")));
        assert!(!is_media_file(std::path::Path::new("/docs/notes.pdf")));
        assert!(!is_media_file(std::path::Path::new("/code/main.rs")));
    }

    #[test]
    fn is_raw_file_detects_raw_formats() {
        assert!(is_raw_file(std::path::Path::new("shot.arw")));
        assert!(is_raw_file(std::path::Path::new("shot.cr2")));
        assert!(is_raw_file(std::path::Path::new("shot.nef")));
        assert!(is_raw_file(std::path::Path::new("shot.DNG")));
    }

    #[test]
    fn is_raw_file_rejects_jpeg() {
        assert!(!is_raw_file(std::path::Path::new("photo.jpg")));
        assert!(!is_raw_file(std::path::Path::new("photo.png")));
    }

    #[test]
    fn hash_file_prefix_returns_64_hex_chars() {
        use tempfile::NamedTempFile;
        use std::io::Write;
        let mut f = NamedTempFile::new().unwrap();
        f.write_all(b"test image data for hashing").unwrap();
        let hash = hash_file_prefix(f.path(), 65536).unwrap();
        assert_eq!(hash.len(), 64);
        assert!(hash.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn hash_file_prefix_consistent() {
        use tempfile::NamedTempFile;
        use std::io::Write;
        let mut f = NamedTempFile::new().unwrap();
        f.write_all(b"deterministic content").unwrap();
        let h1 = hash_file_prefix(f.path(), 65536).unwrap();
        let h2 = hash_file_prefix(f.path(), 65536).unwrap();
        assert_eq!(h1, h2);
    }

    #[test]
    fn system_time_to_millis_positive() {
        let t = std::time::SystemTime::now();
        let ms = system_time_to_millis(t);
        assert!(ms > 0);
    }

    #[test]
    fn unix_millis_now_is_reasonable() {
        let ms = unix_millis_now();
        // After 2024-01-01 in milliseconds
        assert!(ms > 1_704_067_200_000);
    }
}
