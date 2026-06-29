// gallery_bridge_engine/src/thumbnail/mod.rs
//
// Thumbnail generation pipeline.
// Produces JPEG thumbnails at multiple sizes and writes them to a disk cache.
// Filenames are derived from the content hash so they can be safely invalidated.

use anyhow::{Context, Result};
use image::{imageops::FilterType, DynamicImage, ImageFormat};
use std::fs;
use std::path::{Path, PathBuf};

/// Standard thumbnail sizes exposed to the Flutter UI.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ThumbSize {
    /// Small grid cell (120 × 120 px)
    Small,
    /// Medium grid cell (240 × 240 px)
    Medium,
    /// Large preview panel (480 × 480 px)
    Large,
    /// Full-resolution preview up to 1920 on the longest edge
    Preview,
}

impl ThumbSize {
    pub fn max_dimension(&self) -> u32 {
        match self {
            Self::Small   => 120,
            Self::Medium  => 240,
            Self::Large   => 480,
            Self::Preview => 1920,
        }
    }

    pub fn suffix(&self) -> &'static str {
        match self {
            Self::Small   => "sm",
            Self::Medium  => "md",
            Self::Large   => "lg",
            Self::Preview => "prev",
        }
    }

    pub fn jpeg_quality(&self) -> u8 {
        match self {
            Self::Small   => 70,
            Self::Medium  => 75,
            Self::Large   => 82,
            Self::Preview => 90,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Public API
// ────────────────────────────────────────────────────────────────────────────

/// Generate a thumbnail for `source_path` and return the output path.
/// Skips generation if the cached file already exists (mtime not checked — use
/// content-hash based names for cache invalidation instead).
///
/// `cache_dir`: root directory for thumbnail storage (e.g. `<app_support>/thumbnails`)
/// `content_hash`: SHA-256 hex of the source file (first 64 KB is fine)
pub fn generate_thumbnail(
    source_path: &Path,
    cache_dir: &Path,
    content_hash: &str,
    size: ThumbSize,
) -> Result<PathBuf> {
    let out_path = thumb_path(cache_dir, content_hash, size);

    if out_path.exists() {
        return Ok(out_path);
    }

    // Ensure the cache sub-directory exists (sharded by first 2 hex chars)
    if let Some(parent) = out_path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("Cannot create thumb dir: {}", parent.display()))?;
    }

    let img = load_image(source_path)
        .with_context(|| format!("Cannot open image: {}", source_path.display()))?;

    let thumb = resize_image(&img, size.max_dimension());
    save_jpeg(&thumb, &out_path, size.jpeg_quality())
        .with_context(|| format!("Cannot save thumbnail: {}", out_path.display()))?;

    Ok(out_path)
}

/// Generate thumbnails for all standard sizes in one pass (more efficient as
/// the image is decoded only once).
pub fn generate_all_thumbnails(
    source_path: &Path,
    cache_dir: &Path,
    content_hash: &str,
) -> Result<ThumbnailSet> {
    let img = load_image(source_path)
        .with_context(|| format!("Cannot open image: {}", source_path.display()))?;

    let sizes = [
        ThumbSize::Small,
        ThumbSize::Medium,
        ThumbSize::Large,
        ThumbSize::Preview,
    ];

    let mut set = ThumbnailSet::default();
    for size in &sizes {
        let out_path = thumb_path(cache_dir, content_hash, *size);

        if !out_path.exists() {
            if let Some(parent) = out_path.parent() {
                fs::create_dir_all(parent)?;
            }
            let thumb = resize_image(&img, size.max_dimension());
            save_jpeg(&thumb, &out_path, size.jpeg_quality())?;
        }

        let path_str = out_path.to_string_lossy().to_string();
        match size {
            ThumbSize::Small   => set.small   = Some(path_str),
            ThumbSize::Medium  => set.medium  = Some(path_str),
            ThumbSize::Large   => set.large   = Some(path_str),
            ThumbSize::Preview => set.preview = Some(path_str),
        }
    }

    Ok(set)
}

/// Remove all cached thumbnails for a given content hash.
pub fn evict_thumbnails(cache_dir: &Path, content_hash: &str) -> Result<()> {
    for size in &[
        ThumbSize::Small,
        ThumbSize::Medium,
        ThumbSize::Large,
        ThumbSize::Preview,
    ] {
        let p = thumb_path(cache_dir, content_hash, *size);
        if p.exists() {
            fs::remove_file(&p)?;
        }
    }
    Ok(())
}

/// Returns disk usage of the entire thumbnail cache in bytes.
pub fn cache_size_bytes(cache_dir: &Path) -> u64 {
    walkdir::WalkDir::new(cache_dir)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .filter_map(|e| e.metadata().ok())
        .map(|m| m.len())
        .sum()
}

/// Prune the cache to stay under `max_bytes`, removing oldest files first.
pub fn prune_cache(cache_dir: &Path, max_bytes: u64) -> Result<u64> {
    let mut files: Vec<(std::time::SystemTime, PathBuf, u64)> = walkdir::WalkDir::new(cache_dir)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .filter_map(|e| {
            let meta = e.metadata().ok()?;
            let mtime = meta.modified().ok()?;
            Some((mtime, e.path().to_owned(), meta.len()))
        })
        .collect();

    files.sort_by_key(|(t, _, _)| *t);

    let total: u64 = files.iter().map(|(_, _, s)| s).sum();
    let mut freed = 0u64;
    let mut to_free = total.saturating_sub(max_bytes);

    for (_, path, size) in &files {
        if to_free == 0 {
            break;
        }
        if fs::remove_file(path).is_ok() {
            freed += size;
            to_free = to_free.saturating_sub(*size);
        }
    }
    Ok(freed)
}

// ────────────────────────────────────────────────────────────────────────────
// Data types
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Default, Clone)]
pub struct ThumbnailSet {
    pub small: Option<String>,
    pub medium: Option<String>,
    pub large: Option<String>,
    pub preview: Option<String>,
}

// ────────────────────────────────────────────────────────────────────────────
// Private helpers
// ────────────────────────────────────────────────────────────────────────────

/// Compute the thumbnail cache path using a 2-level sharding scheme:
/// `<cache_dir>/<first-2-hex>/<hash>_<suffix>.jpg`
fn thumb_path(cache_dir: &Path, content_hash: &str, size: ThumbSize) -> PathBuf {
    let shard = &content_hash[..2.min(content_hash.len())];
    cache_dir
        .join(shard)
        .join(format!("{}_{}.jpg", content_hash, size.suffix()))
}

fn load_image(path: &Path) -> Result<DynamicImage> {
    let img = image::open(path)?;
    Ok(img)
}

fn resize_image(img: &DynamicImage, max_dim: u32) -> DynamicImage {
    let (w, h) = (img.width(), img.height());
    if w <= max_dim && h <= max_dim {
        return img.clone();
    }
    // Lanczos3 for Small/Medium; for Large/Preview the quality difference is minimal.
    img.resize(max_dim, max_dim, FilterType::Lanczos3)
}

fn save_jpeg(img: &DynamicImage, path: &Path, quality: u8) -> Result<()> {
    let mut out = fs::File::create(path)?;
    let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut out, quality);
    img.write_with_encoder(encoder)?;
    Ok(())
}

// ────────────────────────────────────────────────────────────────────────────
// Unit tests
// ────────────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn thumb_path_sharding() {
        let dir = Path::new("/cache");
        let hash = "abcdef1234567890";
        let p = thumb_path(dir, hash, ThumbSize::Small);
        assert_eq!(p, PathBuf::from("/cache/ab/abcdef1234567890_sm.jpg"));
    }

    #[test]
    fn cache_prune_does_not_panic_on_empty_dir() {
        let dir = tempdir().unwrap();
        let freed = prune_cache(dir.path(), 1024 * 1024).unwrap();
        assert_eq!(freed, 0);
    }
}
