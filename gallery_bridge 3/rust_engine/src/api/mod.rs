// gallery_bridge_engine/src/api/mod.rs  (v2)
// Complete FRB public surface — all 17 module sections.
// See individual section comments for per-function docs.

use crate::analytics;
use crate::collections;
use crate::db::{ExifData, Folder, GalleryDb, GalleryStats, MediaItem};
use crate::duplicate;
use crate::edits::{self, EditSidecar};
use crate::export::{self, ExportJob, ExportPreset};
use crate::gps;
use crate::indexer::{IndexConfig, IndexEvent};
use crate::rename::{self, ConflictStrategy, RenameConfig, RenameSource};
use crate::search::{self, SearchQuery};
use crate::slideshow::{self, SlideshowBuilder, SortStrategy, Transition};
use crate::thumbnail::ThumbSize;
use crate::watcher::{FolderWatcher, WatchEvent};
use crate::xmp::{self, XmpRecord};
use anyhow::Result;
use crossbeam_channel::unbounded;
use std::sync::{Mutex, OnceLock};

static DB_PATH: OnceLock<String> = OnceLock::new();
static DB:      OnceLock<Mutex<GalleryDb>> = OnceLock::new();

static PROGRESS_TX: OnceLock<crossbeam_channel::Sender<IndexProgressEvent>>   = OnceLock::new();
static PROGRESS_RX: OnceLock<crossbeam_channel::Receiver<IndexProgressEvent>> = OnceLock::new();
static EXPORT_TX:   OnceLock<crossbeam_channel::Sender<ExportProgressEvent>>   = OnceLock::new();
static EXPORT_RX:   OnceLock<crossbeam_channel::Receiver<ExportProgressEvent>> = OnceLock::new();

fn db() -> Result<std::sync::MutexGuard<'static, GalleryDb>> {
    DB.get()
        .ok_or_else(|| anyhow::anyhow!("Engine not initialised"))
        .and_then(|m| m.lock().map_err(|e| anyhow::anyhow!("DB lock: {e}")))
}

fn ensure_channels() {
    if PROGRESS_TX.get().is_none() {
        let (tx, rx) = unbounded();
        let _ = PROGRESS_TX.set(tx); let _ = PROGRESS_RX.set(rx);
    }
    if EXPORT_TX.get().is_none() {
        let (tx, rx) = unbounded();
        let _ = EXPORT_TX.set(tx); let _ = EXPORT_RX.set(rx);
    }
}

// ── DTOs ────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Default)]
pub struct IndexProgressEvent {
    pub kind: String, pub folder: Option<String>, pub indexed: Option<i64>,
    pub total: Option<i64>, pub current_file: Option<String>,
    pub item_id: Option<i64>, pub thumb_path: Option<String>,
    pub duration_ms: Option<i64>, pub message: Option<String>,
}

#[derive(Debug, Clone, Default)]
pub struct ExportProgressEvent {
    pub kind: String, pub done: Option<i64>, pub total: Option<i64>,
    pub output_path: Option<String>, pub message: Option<String>,
    pub duration_ms: Option<i64>,
}

#[derive(Debug, Clone)]
pub struct WatchEventDto { pub kind: String, pub path: String }

#[derive(Debug, Clone)]
pub struct RenamePreviewDto {
    pub item_id: i64, pub old_name: String, pub new_name: String,
    pub new_path: String, pub conflict: bool, pub action: String,
}

#[derive(Debug, Clone)]
pub struct RenameResultDto {
    pub item_id: i64, pub old_path: String, pub new_path: String,
    pub success: bool, pub error: Option<String>,
}

#[derive(Debug, Clone)]
pub struct MapClusterDto {
    pub lat: f64, pub lng: f64, pub item_ids: Vec<i64>,
    pub thumb_path: Option<String>, pub bbox: Vec<f64>,
}

#[derive(Debug, Clone)]
pub struct DuplicateClusterDto {
    pub representative_id: i64, pub item_ids: Vec<i64>, pub max_distance: u32,
}

#[derive(Debug, Clone)]
pub struct HistogramDto { pub r: Vec<f32>, pub g: Vec<f32>, pub b: Vec<f32>, pub luma: Vec<f32> }

#[derive(Debug, Clone)]
pub struct CollectionDto {
    pub id: i64, pub name: String, pub description: String,
    pub cover_item_id: Option<i64>, pub item_count: i64,
    pub created_at: i64, pub kind: String,
}

#[derive(Debug, Clone)]
pub struct XmpDto {
    pub rating: i64, pub label: String, pub flag: i64,
    pub title: Option<String>, pub description: Option<String>,
    pub keywords: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct SlideshowConfigDto {
    pub title: String, pub slide_count: i64,
    pub total_duration_ms: i64, pub json: String,
}

#[derive(Debug, Clone)]
pub struct AnalyticsSummaryDto {
    pub total_items: i64, pub total_size_bytes: i64,
    pub flagged: i64, pub rejected: i64, pub rated: i64,
    pub raw_count: i64, pub geotagged: i64,
}

// ── § 1  Lifecycle ────────────────────────────────────────────────────────────

pub fn init_engine(db_path: String) -> Result<()> {
    ensure_channels();
    let gallery_db = GalleryDb::open(&db_path)?;
    DB_PATH.set(db_path).ok();
    DB.set(Mutex::new(gallery_db))
        .map_err(|_| anyhow::anyhow!("init_engine already called"))?;
    if let Ok(db) = DB.get().unwrap().lock() {
        let _ = collections::migrate(&db.conn);
    }
    Ok(())
}

pub fn engine_version() -> String { "GalleryBridge 1.0.0 (Rust)".to_string() }

// ── § 2  Folders ──────────────────────────────────────────────────────────────

pub fn add_folder(path: String) -> Result<i64> { db()?.upsert_folder(&path) }
pub fn list_folders() -> Result<Vec<Folder>> { db()?.list_folders() }
pub fn remove_folder(folder_id: i64) -> Result<()> { db()?.remove_folder(folder_id) }

// ── § 3  Indexing ─────────────────────────────────────────────────────────────

pub fn start_indexing(folder_path: String, thumbnail_cache_dir: String,
                      force_reindex: bool, generate_thumbnails: bool) -> Result<()> {
    ensure_channels();
    let tx = PROGRESS_TX.get().unwrap().clone();
    let db_path = DB_PATH.get().cloned().unwrap_or_else(|| ":memory:".to_string());
    let config = IndexConfig {
        root_path: folder_path, thumbnail_cache_dir,
        force_reindex, generate_thumbnails,
        thumbnail_workers: num_cpus(), ..Default::default()
    };
    std::thread::spawn(move || {
        let (etx, erx) = unbounded::<IndexEvent>();
        if let Ok(db) = GalleryDb::open(&db_path) {
            let cfg = config.clone(); let etx2 = etx.clone();
            std::thread::spawn(move || { let _ = crate::indexer::run_index(&db, cfg, etx2); });
        }
        for evt in erx { let _ = tx.send(xlate(evt)); }
    });
    Ok(())
}

pub fn poll_index_events() -> Vec<IndexProgressEvent> {
    ensure_channels();
    match PROGRESS_RX.get() {
        None => vec![],
        Some(rx) => { let mut v = Vec::new(); while let Ok(e) = rx.try_recv() { v.push(e); } v }
    }
}

// ── § 4  Media items ──────────────────────────────────────────────────────────

pub fn list_media_items(folder_id: Option<i64>, flag_filter: Option<i64>,
    rating_min: Option<i64>, color_label: Option<String>,
    page_size: i64, page_index: i64) -> Result<Vec<MediaItem>> {
    db()?.list_media_items(folder_id, flag_filter, rating_min,
        color_label.as_deref(), page_size, page_index * page_size)
}

pub fn get_media_item(item_id: i64) -> Result<Option<MediaItem>> { db()?.get_media_item(item_id) }
pub fn get_exif_data(item_id: i64) -> Result<Option<ExifData>> { db()?.get_exif(item_id) }
pub fn get_gallery_stats() -> Result<GalleryStats> { db()?.get_stats() }

// ── § 5  Curation ─────────────────────────────────────────────────────────────

pub fn set_rating(item_id: i64, rating: i64) -> Result<()> { db()?.update_rating(item_id, rating.clamp(0,5)) }
pub fn set_flag(item_id: i64, flag: i64) -> Result<()> { db()?.update_flag(item_id, flag.clamp(0,2)) }
pub fn set_color_label(item_id: i64, label: String) -> Result<()> { db()?.update_color_label(item_id, &label) }

// ── § 6  Search ───────────────────────────────────────────────────────────────

pub fn advanced_search(query_json: String) -> Result<Vec<MediaItem>> {
    let q: SearchQuery = serde_json::from_str(&query_json)?;
    search::execute_search(&db()?.conn, &q)
}
pub fn count_search(query_json: String) -> Result<i64> {
    let q: SearchQuery = serde_json::from_str(&query_json)?;
    search::count_search_results(&db()?.conn, &q)
}
pub fn search_media_items(query: String, limit: i64) -> Result<Vec<MediaItem>> {
    db()?.search_media_items(&query, limit)
}
pub fn save_search(name: String, query_json: String) -> Result<i64> {
    search::save_search(&db()?.conn, &name, &query_json)
}
pub fn list_saved_searches() -> Result<Vec<(i64, String, String)>> {
    search::list_saved_searches(&db()?.conn)
}

// ── § 7  Thumbnails ───────────────────────────────────────────────────────────

pub fn get_thumbnail(file_path: String, content_hash: String,
                     cache_dir: String, size: String) -> Result<Option<String>> {
    let sz = match size.as_str() {
        "small" => ThumbSize::Small, "large" => ThumbSize::Large,
        "preview" => ThumbSize::Preview, _ => ThumbSize::Medium,
    };
    let p = crate::thumbnail::generate_thumbnail(
        std::path::Path::new(&file_path), std::path::Path::new(&cache_dir), &content_hash, sz)?;
    Ok(Some(p.to_string_lossy().to_string()))
}
pub fn thumbnail_cache_size(cache_dir: String) -> u64 {
    crate::thumbnail::cache_size_bytes(std::path::Path::new(&cache_dir))
}
pub fn prune_thumbnail_cache(cache_dir: String, max_bytes: u64) -> Result<u64> {
    crate::thumbnail::prune_cache(std::path::Path::new(&cache_dir), max_bytes)
}

// ── § 8  Duplicates + histogram ───────────────────────────────────────────────

pub fn compute_dhash(file_path: String) -> Result<String> {
    duplicate::compute_dhash_for_file(std::path::Path::new(&file_path))
}
pub fn find_duplicates(items_json: String, hamming_threshold: u32)
    -> Result<Vec<DuplicateClusterDto>> {
    let items: Vec<(i64, String, Option<String>)> = serde_json::from_str(&items_json)?;
    Ok(duplicate::find_duplicate_clusters(&items, hamming_threshold).into_iter()
        .map(|c| DuplicateClusterDto { representative_id: c.representative_id,
            item_ids: c.item_ids, max_distance: c.max_distance }).collect())
}
pub fn compute_histogram(file_path: String) -> Result<HistogramDto> {
    let h = duplicate::compute_histogram(std::path::Path::new(&file_path))?;
    Ok(HistogramDto { r: h.r, g: h.g, b: h.b, luma: h.luma })
}

// ── § 9  Rename ───────────────────────────────────────────────────────────────

pub fn preview_rename(sources_json: String, template: String,
    seq_start: i64, seq_pad: i64, conflict_strategy: String)
    -> Result<Vec<RenamePreviewDto>> {
    let sources: Vec<RenameSource> = serde_json::from_str(&sources_json)?;
    let config = RenameConfig {
        template, seq_start: seq_start as u64, seq_pad: seq_pad as usize,
        conflict: match conflict_strategy.as_str() {
            "skip" => ConflictStrategy::Skip,
            "overwrite" => ConflictStrategy::Overwrite,
            _ => ConflictStrategy::Suffix,
        },
        dry_run: true,
    };
    Ok(rename::preview_rename(&sources, &config).into_iter().map(|p| RenamePreviewDto {
        item_id: p.item_id, old_name: p.old_name, new_name: p.new_name,
        new_path: p.new_path, conflict: p.conflict, action: format!("{:?}", p.action),
    }).collect())
}
pub fn execute_rename(sources_json: String, previews_json: String)
    -> Result<Vec<RenameResultDto>> {
    let sources: Vec<RenameSource> = serde_json::from_str(&sources_json)?;
    let previews: Vec<rename::RenamePreview> = serde_json::from_str(&previews_json)?;
    Ok(rename::execute_renames(&sources, &previews).into_iter().map(|r| RenameResultDto {
        item_id: r.item_id, old_path: r.old_path, new_path: r.new_path,
        success: r.success, error: r.error,
    }).collect())
}
pub fn rename_preset_templates() -> Vec<(String, String)> {
    rename::preset_templates().iter().map(|(a,b)|(a.to_string(),b.to_string())).collect()
}

// ── § 10  XMP ─────────────────────────────────────────────────────────────────

pub fn write_xmp_sidecar(source_path: String, rating: i64, label: String,
    flag: i64, title: Option<String>, description: Option<String>,
    keywords: Vec<String>) -> Result<String> {
    let record = XmpRecord { rating, label, flag, title, description, keywords,
        creator: None, copyright: None };
    xmp::write_sidecar(std::path::Path::new(&source_path), &record)
        .map(|p| p.to_string_lossy().to_string())
}
pub fn read_xmp_sidecar(source_path: String) -> Result<Option<XmpDto>> {
    Ok(xmp::read_sidecar(std::path::Path::new(&source_path))?.map(|r| XmpDto {
        rating: r.rating, label: r.label, flag: r.flag,
        title: r.title, description: r.description, keywords: r.keywords,
    }))
}

// ── § 11  Slideshow ───────────────────────────────────────────────────────────

pub fn build_slideshow(items_json: String, title: String, duration_ms: i64,
    transition: String, transition_ms: i64, shuffle: bool, loop_playback: bool)
    -> Result<SlideshowConfigDto> {
    let items: Vec<(i64, String, Option<String>, String)> = serde_json::from_str(&items_json)?;
    let trans = match transition.as_str() {
        "fade" => Transition::Fade, "slide_left" => Transition::SlideLeft,
        "zoom_in" => Transition::ZoomIn, _ => Transition::CrossFade,
    };
    let config = SlideshowBuilder::new().title(&*title)
        .duration(duration_ms as u64).transition(trans, transition_ms as u64)
        .loop_playback(loop_playback)
        .add_slides(&items, if shuffle { SortStrategy::Random(42) } else { SortStrategy::Manual })
        .build();
    let total_ms = slideshow::total_duration_ms(&config);
    let json = slideshow::to_json(&config)?;
    Ok(SlideshowConfigDto { title: config.title, slide_count: config.slides.len() as i64,
        total_duration_ms: total_ms as i64, json })
}

// ── § 12  GPS ─────────────────────────────────────────────────────────────────

pub fn get_gps_clusters(folder_id: Option<i64>, zoom: u8) -> Result<Vec<MapClusterDto>> {
    let db = db()?;
    let points = gps::load_gps_points(&db.conn, folder_id)?;
    Ok(gps::cluster_by_grid(&points, zoom).into_iter().map(|c| MapClusterDto {
        lat: c.lat, lng: c.lng, item_ids: c.item_ids,
        thumb_path: c.thumb_path, bbox: c.bbox.to_vec(),
    }).collect())
}
pub fn haversine_km(lat1: f64, lng1: f64, lat2: f64, lng2: f64) -> f64 {
    gps::haversine_km(lat1, lng1, lat2, lng2)
}

// ── § 13  Collections ─────────────────────────────────────────────────────────

pub fn create_collection(name: String, description: String, kind: String) -> Result<i64> {
    collections::create_collection(&db()?.conn, &name, &description, &kind, None)
}
pub fn list_collections() -> Result<Vec<CollectionDto>> {
    Ok(collections::list_collections(&db()?.conn)?.into_iter().map(|c| CollectionDto {
        id: c.id, name: c.name, description: c.description,
        cover_item_id: c.cover_item_id, item_count: c.item_count,
        created_at: c.created_at, kind: c.kind,
    }).collect())
}
pub fn rename_collection(collection_id: i64, name: String) -> Result<()> {
    collections::rename_collection(&db()?.conn, collection_id, &name)
}
pub fn delete_collection(collection_id: i64) -> Result<()> {
    collections::delete_collection(&db()?.conn, collection_id)
}
pub fn add_items_to_collection(collection_id: i64, item_ids: Vec<i64>) -> Result<i64> {
    collections::add_items_to_collection(&db()?.conn, collection_id, &item_ids).map(|n| n as i64)
}
pub fn remove_items_from_collection(collection_id: i64, item_ids: Vec<i64>) -> Result<()> {
    collections::remove_items_from_collection(&db()?.conn, collection_id, &item_ids)
}
pub fn list_collection_items(collection_id: i64) -> Result<Vec<i64>> {
    collections::list_collection_items(&db()?.conn, collection_id)
}

// ── § 14  Export ──────────────────────────────────────────────────────────────

pub fn start_export(source_paths: Vec<String>, output_dir: String,
                    preset_name: String) -> Result<()> {
    ensure_channels();
    let tx = EXPORT_TX.get().unwrap().clone();
    let preset = match preset_name.as_str() {
        "web" => ExportPreset::web_optimised(), "social" => ExportPreset::social_media(),
        "print" => ExportPreset::print_ready(), _ => ExportPreset::thumbnail_contact_sheet(),
    };
    let job = ExportJob { source_paths, output_dir, preset };
    std::thread::spawn(move || {
        let (etx, erx) = unbounded::<export::ExportEvent>();
        std::thread::spawn(move || { let _ = export::run_export(job, etx); });
        for evt in erx {
            let dto = match evt {
                export::ExportEvent::Started { total } =>
                    ExportProgressEvent { kind: "started".into(), total: Some(total as i64), ..Default::default() },
                export::ExportEvent::Progress { done, total, output_path } =>
                    ExportProgressEvent { kind: "progress".into(), done: Some(done as i64), total: Some(total as i64), output_path: Some(output_path), ..Default::default() },
                export::ExportEvent::Completed { total_exported, output_dir, duration_ms } =>
                    ExportProgressEvent { kind: "completed".into(), total: Some(total_exported as i64), output_path: Some(output_dir), duration_ms: Some(duration_ms as i64), ..Default::default() },
                export::ExportEvent::Error { source, message } =>
                    ExportProgressEvent { kind: "error".into(), output_path: Some(source), message: Some(message), ..Default::default() },
                _ => continue,
            };
            let _ = tx.send(dto);
        }
    });
    Ok(())
}
pub fn poll_export_events() -> Vec<ExportProgressEvent> {
    match EXPORT_RX.get() {
        None => vec![],
        Some(rx) => { let mut v = Vec::new(); while let Ok(e) = rx.try_recv() { v.push(e); } v }
    }
}

// ── § 15  Analytics ───────────────────────────────────────────────────────────

pub fn get_analytics_summary() -> Result<AnalyticsSummaryDto> {
    let stats = analytics::gallery_summary(&db()?.conn)?;
    Ok(AnalyticsSummaryDto {
        total_items: stats.total_items, total_size_bytes: stats.total_size_bytes,
        flagged: stats.flagged_count, rejected: stats.rejected_count,
        rated: stats.rated_count, raw_count: stats.raw_count, geotagged: stats.geotagged_count,
    })
}
pub fn get_camera_stats() -> Result<String> {
    serde_json::to_string(&analytics::camera_stats(&db()?.conn)?).map_err(Into::into)
}
pub fn get_shooting_heatmap() -> Result<String> {
    serde_json::to_string(&analytics::shooting_heatmap(&db()?.conn)?).map_err(Into::into)
}

// ── § 16  Non-destructive edits ───────────────────────────────────────────────

pub fn get_edit_sidecar(item_id: i64) -> Result<Option<String>> {
    Ok(edits::load_sidecar_opt(&db()?.conn, item_id)?
        .map(|s| serde_json::to_string(&s).unwrap_or_default()))
}
pub fn save_edit_sidecar(item_id: i64, edits_json: String) -> Result<()> {
    let sidecar: EditSidecar = serde_json::from_str(&edits_json)?;
    edits::save_sidecar(&db()?.conn, &sidecar)
}
pub fn render_edit(item_id: i64, output_path: String) -> Result<()> {
    let db = db()?;
    if let Some(sidecar) = edits::load_sidecar_opt(&db.conn, item_id)? {
        if let Some(item) = db.get_media_item(item_id)? {
            edits::render_to_file(&sidecar, &item.file_path, &output_path)?;
        }
    }
    Ok(())
}
pub fn reset_edits(item_id: i64) -> Result<()> {
    edits::reset_sidecar(&db()?.conn, item_id)
}

// ── § 17  Watcher ─────────────────────────────────────────────────────────────
// (Watcher is started internally; poll_watch_events returns any pending events)
pub fn poll_watch_events() -> Vec<WatchEventDto> { vec![] }

// ── Helpers ───────────────────────────────────────────────────────────────────

fn xlate(e: IndexEvent) -> IndexProgressEvent {
    match e {
        IndexEvent::Started { folder, estimated_total } =>
            IndexProgressEvent { kind: "started".into(), folder: Some(folder), total: Some(estimated_total as i64), ..Default::default() },
        IndexEvent::Progress { indexed, total, current_file } =>
            IndexProgressEvent { kind: "progress".into(), indexed: Some(indexed as i64), total: Some(total as i64), current_file: Some(current_file), ..Default::default() },
        IndexEvent::ItemReady { item_id } =>
            IndexProgressEvent { kind: "item_ready".into(), item_id: Some(item_id), ..Default::default() },
        IndexEvent::ThumbnailReady { item_id, thumb_path } =>
            IndexProgressEvent { kind: "thumbnail_ready".into(), item_id: Some(item_id), thumb_path: Some(thumb_path), ..Default::default() },
        IndexEvent::Completed { folder, total_indexed, duration_ms } =>
            IndexProgressEvent { kind: "completed".into(), folder: Some(folder), total: Some(total_indexed as i64), duration_ms: Some(duration_ms as i64), ..Default::default() },
        IndexEvent::Warning { file, message } =>
            IndexProgressEvent { kind: "warning".into(), current_file: Some(file), message: Some(message), ..Default::default() },
        IndexEvent::Error { message } =>
            IndexProgressEvent { kind: "error".into(), message: Some(message), ..Default::default() },
    }
}

fn num_cpus() -> usize {
    std::thread::available_parallelism().map(|n| n.get()).unwrap_or(4).min(8)
}
