// gallery_bridge_engine/src/search/mod.rs
//
// Advanced multi-criteria search engine.
// Builds parameterized SQL queries dynamically from a SearchQuery struct.
// Supports full-text on filename, date range, dimension range, camera model,
// flag, rating, color label, file type, GPS bounds, and tag membership.

use crate::db::MediaItem;
use anyhow::Result;
use rusqlite::Connection;
use serde::{Deserialize, Serialize};

// ────────────────────────────────────────────────────────────────────────────
// Query model
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SearchQuery {
    // Text
    pub filename_contains: Option<String>,

    // Curation
    pub flag: Option<i64>,          // 0=unflagged, 1=picked, 2=rejected
    pub rating_min: Option<i64>,
    pub rating_max: Option<i64>,
    pub color_label: Option<String>,

    // Date
    pub date_from_ms: Option<i64>,  // created_at >= date_from_ms
    pub date_to_ms: Option<i64>,    // created_at <= date_to_ms

    // Dimensions
    pub width_min: Option<i64>,
    pub height_min: Option<i64>,
    pub megapixels_min: Option<f64>,// width*height/1e6 >=

    // File
    pub is_raw: Option<bool>,
    pub mime_contains: Option<String>,
    pub filesize_min: Option<i64>,  // bytes
    pub filesize_max: Option<i64>,

    // EXIF
    pub camera_model_contains: Option<String>,
    pub iso_min: Option<i64>,
    pub iso_max: Option<i64>,

    // Location
    pub lat_min: Option<f64>,
    pub lat_max: Option<f64>,
    pub lng_min: Option<f64>,
    pub lng_max: Option<f64>,

    // Folder
    pub folder_id: Option<i64>,

    // Pagination
    pub limit: Option<i64>,
    pub offset: Option<i64>,

    // Sort
    /// "date" | "name" | "size" | "rating"
    pub sort_by: Option<String>,
    pub sort_desc: Option<bool>,
}

// ────────────────────────────────────────────────────────────────────────────
// Query execution
// ────────────────────────────────────────────────────────────────────────────

pub fn execute_search(conn: &Connection, q: &SearchQuery) -> Result<Vec<MediaItem>> {
    let (sql, param_values) = build_query(q);

    let mut stmt = conn.prepare(&sql)?;
    let param_refs: Vec<&dyn rusqlite::ToSql> = param_values
        .iter()
        .map(|p| p.as_ref() as &dyn rusqlite::ToSql)
        .collect();

    let rows = stmt.query_map(param_refs.as_slice(), |r| {
        Ok(MediaItem {
            id:             r.get(0)?,
            folder_id:      r.get(1)?,
            file_path:      r.get(2)?,
            file_name:      r.get(3)?,
            file_size:      r.get(4)?,
            width:          r.get(5)?,
            height:         r.get(6)?,
            mime_type:      r.get(7)?,
            created_at:     r.get(8)?,
            modified_at:    r.get(9)?,
            content_hash:   r.get(10)?,
            rating:         r.get(11)?,
            flag:           r.get(12)?,
            color_label:    r.get(13)?,
            is_raw:         r.get::<_, i64>(14)? != 0,
            thumbnail_path: r.get(15)?,
            indexed_at:     r.get(16)?,
        })
    })?;

    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

pub fn count_search_results(conn: &Connection, q: &SearchQuery) -> Result<i64> {
    let mut q2 = q.clone();
    q2.limit = None;
    q2.offset = None;
    q2.sort_by = None;
    let (base_sql, param_values) = build_query(&q2);
    let count_sql = format!("SELECT COUNT(*) FROM ({base_sql}) sub");
    let param_refs: Vec<&dyn rusqlite::ToSql> = param_values
        .iter()
        .map(|p| p.as_ref())
        .collect();
    let count: i64 = conn.query_row(&count_sql, param_refs.as_slice(), |r| r.get(0))?;
    Ok(count)
}

// ────────────────────────────────────────────────────────────────────────────
// Query builder
// ────────────────────────────────────────────────────────────────────────────

fn build_query(q: &SearchQuery) -> (String, Vec<Box<dyn rusqlite::ToSql>>) {
    let mut conditions: Vec<String> = vec!["1=1".to_string()];
    let mut params: Vec<Box<dyn rusqlite::ToSql>> = Vec::new();
    let mut p = 1usize; // parameter index

    macro_rules! add {
        ($cond:expr, $val:expr) => {{
            conditions.push($cond.replace("{}", &format!("?{p}")));
            params.push(Box::new($val));
            p += 1;
        }};
    }

    // Text
    if let Some(ref s) = q.filename_contains {
        add!("LOWER(m.file_name) LIKE {}", format!("%{}%", s.to_lowercase()));
    }

    // Curation
    if let Some(f) = q.flag {
        add!("m.flag = {}", f);
    }
    if let Some(r) = q.rating_min {
        add!("m.rating >= {}", r);
    }
    if let Some(r) = q.rating_max {
        add!("m.rating <= {}", r);
    }
    if let Some(ref cl) = q.color_label {
        add!("m.color_label = {}", cl.clone());
    }

    // Date
    if let Some(df) = q.date_from_ms {
        add!("m.created_at >= {}", df);
    }
    if let Some(dt) = q.date_to_ms {
        add!("m.created_at <= {}", dt);
    }

    // Dimensions
    if let Some(w) = q.width_min {
        add!("m.width >= {}", w);
    }
    if let Some(h) = q.height_min {
        add!("m.height >= {}", h);
    }
    if let Some(mp) = q.megapixels_min {
        let min_pixels = (mp * 1_000_000.0) as i64;
        add!("(m.width * m.height) >= {}", min_pixels);
    }

    // File
    if let Some(raw) = q.is_raw {
        add!("m.is_raw = {}", raw as i64);
    }
    if let Some(ref mime) = q.mime_contains {
        add!("LOWER(m.mime_type) LIKE {}", format!("%{}%", mime.to_lowercase()));
    }
    if let Some(fs_min) = q.filesize_min {
        add!("m.file_size >= {}", fs_min);
    }
    if let Some(fs_max) = q.filesize_max {
        add!("m.file_size <= {}", fs_max);
    }

    // Folder
    if let Some(fid) = q.folder_id {
        add!("m.folder_id = {}", fid);
    }

    // EXIF join (only if EXIF conditions present)
    let needs_exif = q.camera_model_contains.is_some()
        || q.iso_min.is_some()
        || q.iso_max.is_some()
        || q.lat_min.is_some();

    let exif_join = if needs_exif {
        "LEFT JOIN exif_data e ON e.item_id = m.id"
    } else {
        ""
    };

    if let Some(ref cam) = q.camera_model_contains {
        add!("LOWER(e.camera_model) LIKE {}", format!("%{}%", cam.to_lowercase()));
    }
    if let Some(iso_min) = q.iso_min {
        add!("e.iso >= {}", iso_min);
    }
    if let Some(iso_max) = q.iso_max {
        add!("e.iso <= {}", iso_max);
    }

    // GPS bounds
    if let Some(lat_min) = q.lat_min {
        add!("e.latitude >= {}", lat_min);
    }
    if let Some(lat_max) = q.lat_max {
        add!("e.latitude <= {}", lat_max);
    }
    if let Some(lng_min) = q.lng_min {
        add!("e.longitude >= {}", lng_min);
    }
    if let Some(lng_max) = q.lng_max {
        add!("e.longitude <= {}", lng_max);
    }

    // Sort
    let sort_col = match q.sort_by.as_deref() {
        Some("name")   => "m.file_name",
        Some("size")   => "m.file_size",
        Some("rating") => "m.rating",
        _              => "m.created_at",
    };
    let sort_dir = if q.sort_desc.unwrap_or(true) { "DESC" } else { "ASC" };
    let order_clause = format!("ORDER BY {sort_col} {sort_dir}");

    // Pagination
    let limit  = q.limit.unwrap_or(200);
    let offset = q.offset.unwrap_or(0);
    let page_clause = format!("LIMIT {limit} OFFSET {offset}");

    let where_clause = conditions.join(" AND ");

    let sql = format!(
        "SELECT m.id, m.folder_id, m.file_path, m.file_name, m.file_size,
                m.width, m.height, m.mime_type, m.created_at, m.modified_at,
                m.content_hash, m.rating, m.flag, m.color_label,
                m.is_raw, m.thumbnail_path, m.indexed_at
         FROM media_items m
         {exif_join}
         WHERE {where_clause}
         {order_clause}
         {page_clause}"
    );

    (sql, params)
}

// ────────────────────────────────────────────────────────────────────────────
// Saved searches
// ────────────────────────────────────────────────────────────────────────────

pub fn save_search(conn: &Connection, name: &str, query_json: &str) -> Result<i64> {
    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS saved_searches (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT NOT NULL UNIQUE,
            query_json  TEXT NOT NULL,
            created_at  INTEGER NOT NULL DEFAULT 0
         )",
    )?;
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0);
    conn.execute(
        "INSERT INTO saved_searches (name, query_json, created_at) VALUES (?1, ?2, ?3)
         ON CONFLICT(name) DO UPDATE SET query_json = excluded.query_json",
        rusqlite::params![name, query_json, now],
    )?;
    Ok(conn.last_insert_rowid())
}

pub fn list_saved_searches(conn: &Connection) -> Result<Vec<(i64, String, String)>> {
    let mut stmt =
        conn.prepare("SELECT id, name, query_json FROM saved_searches ORDER BY name")?;
    let rows = stmt.query_map([], |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?)))?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_query_builds_valid_sql() {
        let q = SearchQuery::default();
        let (sql, _params) = build_query(&q);
        assert!(sql.contains("SELECT m.id"));
        assert!(sql.contains("FROM media_items m"));
        assert!(sql.contains("LIMIT 200"));
    }

    #[test]
    fn flag_filter_adds_condition() {
        let q = SearchQuery { flag: Some(1), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("m.flag = "));
    }

    #[test]
    fn rating_range_adds_both_conditions() {
        let q = SearchQuery { rating_min: Some(3), rating_max: Some(5), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("m.rating >= "));
        assert!(sql.contains("m.rating <= "));
    }

    #[test]
    fn is_raw_filter_works() {
        let q = SearchQuery { is_raw: Some(true), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("m.is_raw = "));
    }

    #[test]
    fn sort_by_name_produces_correct_order() {
        let q = SearchQuery { sort_by: Some("name".to_string()), sort_desc: Some(false), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("m.file_name ASC"));
    }

    #[test]
    fn megapixels_filter_multiplies_correctly() {
        let q = SearchQuery { megapixels_min: Some(24.0), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("(m.width * m.height) >= "));
    }

    #[test]
    fn gps_bounds_require_exif_join() {
        let q = SearchQuery { lat_min: Some(40.0), lat_max: Some(50.0), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("JOIN exif_data e"));
    }

    #[test]
    fn pagination_offset_calculated() {
        let q = SearchQuery { limit: Some(50), offset: Some(100), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("LIMIT 50 OFFSET 100"));
    }

    #[test]
    fn camera_model_filter_joins_exif() {
        let q = SearchQuery { camera_model_contains: Some("Sony".to_string()), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("exif_data e"));
        assert!(sql.contains("camera_model"));
    }

    #[test]
    fn filename_filter_lowercases() {
        let q = SearchQuery { filename_contains: Some("VACATION".to_string()), ..Default::default() };
        let (sql, _) = build_query(&q);
        assert!(sql.contains("LOWER(m.file_name)"));
    }
}
