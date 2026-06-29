// gallery_bridge_engine/src/db/mod.rs
//
// SQLite-backed local index database.
// Schema:
//   - folders      : tracked root folders
//   - media_items  : every indexed media file
//   - thumbnails   : thumbnail cache manifest
//   - tags         : user-defined labels
//   - item_tags    : many-to-many join

use anyhow::{Context, Result};
use rusqlite::{params, Connection, OptionalExtension};
use serde::{Deserialize, Serialize};
use std::path::Path;

// ────────────────────────────────────────────────────────────────────────────
// Domain models (also the types flutter_rust_bridge will generate Dart code for)
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Folder {
    pub id: i64,
    pub path: String,
    pub display_name: String,
    pub last_indexed_at: Option<i64>, // Unix timestamp millis
    pub item_count: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaItem {
    pub id: i64,
    pub folder_id: i64,
    pub file_path: String,
    pub file_name: String,
    pub file_size: i64,    // bytes
    pub width: Option<i64>,
    pub height: Option<i64>,
    pub mime_type: String,
    pub created_at: Option<i64>,   // Unix timestamp millis from EXIF / FS
    pub modified_at: i64,          // Unix timestamp millis from FS mtime
    pub content_hash: Option<String>, // SHA-256 hex of first 64KB
    pub rating: i64,               // 0-5 stars
    pub flag: i64,                 // 0=none,1=flagged,2=rejected
    pub color_label: String,       // "red"|"yellow"|"green"|"blue"|"purple"|""
    pub is_raw: bool,
    pub thumbnail_path: Option<String>,
    pub indexed_at: i64,           // Unix timestamp millis
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExifData {
    pub item_id: i64,
    pub camera_make: Option<String>,
    pub camera_model: Option<String>,
    pub lens: Option<String>,
    pub iso: Option<i64>,
    pub shutter_speed: Option<String>,
    pub aperture: Option<f64>,
    pub focal_length: Option<f64>,
    pub flash: Option<bool>,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub color_space: Option<String>,
    pub exposure_mode: Option<String>,
    pub white_balance: Option<String>,
    pub raw_json: String, // full EXIF dump as JSON blob
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Tag {
    pub id: i64,
    pub name: String,
    pub color: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GalleryStats {
    pub total_items: i64,
    pub total_folders: i64,
    pub total_size_bytes: i64,
    pub raw_count: i64,
    pub flagged_count: i64,
    pub rejected_count: i64,
}

// ────────────────────────────────────────────────────────────────────────────
// Database connection & schema bootstrap
// ────────────────────────────────────────────────────────────────────────────

pub struct GalleryDb {
    pub conn: Connection,
}

impl GalleryDb {
    /// Open (or create) the SQLite database at `db_path`.
    pub fn open(db_path: &str) -> Result<Self> {
        let conn = Connection::open(db_path)
            .with_context(|| format!("Failed to open database at {db_path}"))?;

        // Performance pragmas
        conn.execute_batch(
            "PRAGMA journal_mode = WAL;
             PRAGMA synchronous  = NORMAL;
             PRAGMA foreign_keys = ON;
             PRAGMA cache_size   = -32000;  -- 32 MB page cache
             PRAGMA temp_store   = MEMORY;",
        )?;

        let db = Self { conn };
        db.migrate()?;
        Ok(db)
    }

    /// Apply all schema migrations idempotently.
    fn migrate(&self) -> Result<()> {
        self.conn.execute_batch(
            "
            CREATE TABLE IF NOT EXISTS schema_version (
                version INTEGER NOT NULL
            );

            CREATE TABLE IF NOT EXISTS folders (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                path            TEXT    NOT NULL UNIQUE,
                display_name    TEXT    NOT NULL,
                last_indexed_at INTEGER,
                item_count      INTEGER NOT NULL DEFAULT 0
            );

            CREATE TABLE IF NOT EXISTS media_items (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                folder_id       INTEGER NOT NULL REFERENCES folders(id) ON DELETE CASCADE,
                file_path       TEXT    NOT NULL UNIQUE,
                file_name       TEXT    NOT NULL,
                file_size       INTEGER NOT NULL DEFAULT 0,
                width           INTEGER,
                height          INTEGER,
                mime_type       TEXT    NOT NULL DEFAULT '',
                created_at      INTEGER,
                modified_at     INTEGER NOT NULL DEFAULT 0,
                content_hash    TEXT,
                rating          INTEGER NOT NULL DEFAULT 0,
                flag            INTEGER NOT NULL DEFAULT 0,
                color_label     TEXT    NOT NULL DEFAULT '',
                is_raw          INTEGER NOT NULL DEFAULT 0,
                thumbnail_path  TEXT,
                indexed_at      INTEGER NOT NULL DEFAULT 0
            );

            CREATE INDEX IF NOT EXISTS idx_media_folder   ON media_items(folder_id);
            CREATE INDEX IF NOT EXISTS idx_media_hash     ON media_items(content_hash);
            CREATE INDEX IF NOT EXISTS idx_media_created  ON media_items(created_at);
            CREATE INDEX IF NOT EXISTS idx_media_flag     ON media_items(flag);
            CREATE INDEX IF NOT EXISTS idx_media_rating   ON media_items(rating);

            CREATE TABLE IF NOT EXISTS exif_data (
                item_id         INTEGER PRIMARY KEY REFERENCES media_items(id) ON DELETE CASCADE,
                camera_make     TEXT,
                camera_model    TEXT,
                lens            TEXT,
                iso             INTEGER,
                shutter_speed   TEXT,
                aperture        REAL,
                focal_length    REAL,
                flash           INTEGER,
                latitude        REAL,
                longitude       REAL,
                color_space     TEXT,
                exposure_mode   TEXT,
                white_balance   TEXT,
                raw_json        TEXT NOT NULL DEFAULT '{}'
            );

            CREATE TABLE IF NOT EXISTS tags (
                id    INTEGER PRIMARY KEY AUTOINCREMENT,
                name  TEXT NOT NULL UNIQUE,
                color TEXT NOT NULL DEFAULT '#888888'
            );

            CREATE TABLE IF NOT EXISTS item_tags (
                item_id INTEGER NOT NULL REFERENCES media_items(id) ON DELETE CASCADE,
                tag_id  INTEGER NOT NULL REFERENCES tags(id)        ON DELETE CASCADE,
                PRIMARY KEY (item_id, tag_id)
            );

            CREATE TABLE IF NOT EXISTS thumbnails (
                item_id    INTEGER PRIMARY KEY REFERENCES media_items(id) ON DELETE CASCADE,
                thumb_path TEXT NOT NULL,
                width      INTEGER NOT NULL,
                height     INTEGER NOT NULL,
                generated_at INTEGER NOT NULL
            );
            ",
        )?;
        Ok(())
    }

    // ────────────────────────────── Folder ops ───────────────────────────────

    pub fn upsert_folder(&self, path: &str) -> Result<i64> {
        let display = Path::new(path)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(path)
            .to_string();

        self.conn.execute(
            "INSERT INTO folders (path, display_name) VALUES (?1, ?2)
             ON CONFLICT(path) DO UPDATE SET display_name = excluded.display_name",
            params![path, display],
        )?;

        let id: i64 = self.conn.query_row(
            "SELECT id FROM folders WHERE path = ?1",
            params![path],
            |r| r.get(0),
        )?;
        Ok(id)
    }

    pub fn list_folders(&self) -> Result<Vec<Folder>> {
        let mut stmt = self.conn.prepare(
            "SELECT id, path, display_name, last_indexed_at,
                    (SELECT COUNT(*) FROM media_items WHERE folder_id = folders.id) AS item_count
             FROM folders ORDER BY path",
        )?;
        let rows = stmt.query_map([], |r| {
            Ok(Folder {
                id: r.get(0)?,
                path: r.get(1)?,
                display_name: r.get(2)?,
                last_indexed_at: r.get(3)?,
                item_count: r.get(4)?,
            })
        })?;
        rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
    }

    pub fn remove_folder(&self, folder_id: i64) -> Result<()> {
        self.conn
            .execute("DELETE FROM folders WHERE id = ?1", params![folder_id])?;
        Ok(())
    }

    pub fn mark_folder_indexed(&self, folder_id: i64, now_ms: i64, count: i64) -> Result<()> {
        self.conn.execute(
            "UPDATE folders SET last_indexed_at = ?1, item_count = ?2 WHERE id = ?3",
            params![now_ms, count, folder_id],
        )?;
        Ok(())
    }

    // ────────────────────────────── Media ops ────────────────────────────────

    pub fn upsert_media_item(&self, item: &MediaItem) -> Result<i64> {
        self.conn.execute(
            "INSERT INTO media_items
               (folder_id, file_path, file_name, file_size, width, height, mime_type,
                created_at, modified_at, content_hash, rating, flag, color_label,
                is_raw, thumbnail_path, indexed_at)
             VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15,?16)
             ON CONFLICT(file_path) DO UPDATE SET
               file_size      = excluded.file_size,
               width          = excluded.width,
               height         = excluded.height,
               mime_type      = excluded.mime_type,
               modified_at    = excluded.modified_at,
               content_hash   = excluded.content_hash,
               thumbnail_path = excluded.thumbnail_path,
               indexed_at     = excluded.indexed_at",
            params![
                item.folder_id,
                item.file_path,
                item.file_name,
                item.file_size,
                item.width,
                item.height,
                item.mime_type,
                item.created_at,
                item.modified_at,
                item.content_hash,
                item.rating,
                item.flag,
                item.color_label,
                item.is_raw as i64,
                item.thumbnail_path,
                item.indexed_at,
            ],
        )?;

        let id: i64 = self.conn.query_row(
            "SELECT id FROM media_items WHERE file_path = ?1",
            params![item.file_path],
            |r| r.get(0),
        )?;
        Ok(id)
    }

    pub fn get_media_item(&self, id: i64) -> Result<Option<MediaItem>> {
        self.conn
            .query_row(
                "SELECT id,folder_id,file_path,file_name,file_size,width,height,
                         mime_type,created_at,modified_at,content_hash,rating,flag,
                         color_label,is_raw,thumbnail_path,indexed_at
                  FROM media_items WHERE id = ?1",
                params![id],
                Self::row_to_media_item,
            )
            .optional()
            .map_err(Into::into)
    }

    /// Paginated listing with optional filters.
    pub fn list_media_items(
        &self,
        folder_id: Option<i64>,
        flag_filter: Option<i64>,
        rating_min: Option<i64>,
        color_label: Option<&str>,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<MediaItem>> {
        let mut conditions = vec!["1=1".to_string()];
        if let Some(fid) = folder_id {
            conditions.push(format!("folder_id = {fid}"));
        }
        if let Some(f) = flag_filter {
            conditions.push(format!("flag = {f}"));
        }
        if let Some(r) = rating_min {
            conditions.push(format!("rating >= {r}"));
        }
        if let Some(cl) = color_label {
            conditions.push(format!("color_label = '{cl}'"));
        }
        let where_clause = conditions.join(" AND ");
        let sql = format!(
            "SELECT id,folder_id,file_path,file_name,file_size,width,height,
                    mime_type,created_at,modified_at,content_hash,rating,flag,
                    color_label,is_raw,thumbnail_path,indexed_at
             FROM media_items
             WHERE {where_clause}
             ORDER BY created_at DESC, modified_at DESC
             LIMIT {limit} OFFSET {offset}"
        );

        let mut stmt = self.conn.prepare(&sql)?;
        let rows = stmt.query_map([], Self::row_to_media_item)?;
        rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
    }

    pub fn search_media_items(&self, query: &str, limit: i64) -> Result<Vec<MediaItem>> {
        let pattern = format!("%{}%", query.to_lowercase());
        let mut stmt = self.conn.prepare(
            "SELECT id,folder_id,file_path,file_name,file_size,width,height,
                    mime_type,created_at,modified_at,content_hash,rating,flag,
                    color_label,is_raw,thumbnail_path,indexed_at
             FROM media_items
             WHERE LOWER(file_name) LIKE ?1
             ORDER BY modified_at DESC
             LIMIT ?2",
        )?;
        let rows = stmt.query_map(params![pattern, limit], Self::row_to_media_item)?;
        rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
    }

    pub fn update_rating(&self, item_id: i64, rating: i64) -> Result<()> {
        self.conn.execute(
            "UPDATE media_items SET rating = ?1 WHERE id = ?2",
            params![rating, item_id],
        )?;
        Ok(())
    }

    pub fn update_flag(&self, item_id: i64, flag: i64) -> Result<()> {
        self.conn.execute(
            "UPDATE media_items SET flag = ?1 WHERE id = ?2",
            params![flag, item_id],
        )?;
        Ok(())
    }

    pub fn update_color_label(&self, item_id: i64, label: &str) -> Result<()> {
        self.conn.execute(
            "UPDATE media_items SET color_label = ?1 WHERE id = ?2",
            params![label, item_id],
        )?;
        Ok(())
    }

    pub fn set_thumbnail_path(&self, item_id: i64, thumb_path: &str) -> Result<()> {
        self.conn.execute(
            "UPDATE media_items SET thumbnail_path = ?1 WHERE id = ?2",
            params![thumb_path, item_id],
        )?;
        Ok(())
    }

    pub fn remove_stale_items(&self, folder_id: i64, known_paths: &[String]) -> Result<usize> {
        if known_paths.is_empty() {
            let count = self.conn.execute(
                "DELETE FROM media_items WHERE folder_id = ?1",
                params![folder_id],
            )?;
            return Ok(count);
        }
        // Build a temp table approach for large sets
        let placeholders = known_paths
            .iter()
            .enumerate()
            .map(|(i, _)| format!("?{}", i + 2))
            .collect::<Vec<_>>()
            .join(",");
        let sql = format!(
            "DELETE FROM media_items WHERE folder_id = ?1 AND file_path NOT IN ({placeholders})"
        );
        let mut stmt = self.conn.prepare(&sql)?;
        let mut params_vec: Vec<Box<dyn rusqlite::ToSql>> = vec![Box::new(folder_id)];
        for p in known_paths {
            params_vec.push(Box::new(p.clone()));
        }
        let param_refs: Vec<&dyn rusqlite::ToSql> = params_vec.iter().map(|b| b.as_ref()).collect();
        let count = stmt.execute(param_refs.as_slice())?;
        Ok(count)
    }

    // ────────────────────────────── EXIF ops ─────────────────────────────────

    pub fn upsert_exif(&self, exif: &ExifData) -> Result<()> {
        self.conn.execute(
            "INSERT INTO exif_data
               (item_id,camera_make,camera_model,lens,iso,shutter_speed,aperture,
                focal_length,flash,latitude,longitude,color_space,exposure_mode,
                white_balance,raw_json)
             VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15)
             ON CONFLICT(item_id) DO UPDATE SET
               camera_make   = excluded.camera_make,
               camera_model  = excluded.camera_model,
               lens          = excluded.lens,
               iso           = excluded.iso,
               shutter_speed = excluded.shutter_speed,
               aperture      = excluded.aperture,
               focal_length  = excluded.focal_length,
               flash         = excluded.flash,
               latitude      = excluded.latitude,
               longitude     = excluded.longitude,
               color_space   = excluded.color_space,
               exposure_mode = excluded.exposure_mode,
               white_balance = excluded.white_balance,
               raw_json      = excluded.raw_json",
            params![
                exif.item_id,
                exif.camera_make,
                exif.camera_model,
                exif.lens,
                exif.iso,
                exif.shutter_speed,
                exif.aperture,
                exif.focal_length,
                exif.flash.map(|b| b as i64),
                exif.latitude,
                exif.longitude,
                exif.color_space,
                exif.exposure_mode,
                exif.white_balance,
                exif.raw_json,
            ],
        )?;
        Ok(())
    }

    pub fn get_exif(&self, item_id: i64) -> Result<Option<ExifData>> {
        self.conn
            .query_row(
                "SELECT item_id,camera_make,camera_model,lens,iso,shutter_speed,aperture,
                         focal_length,flash,latitude,longitude,color_space,exposure_mode,
                         white_balance,raw_json
                  FROM exif_data WHERE item_id = ?1",
                params![item_id],
                |r| {
                    Ok(ExifData {
                        item_id: r.get(0)?,
                        camera_make: r.get(1)?,
                        camera_model: r.get(2)?,
                        lens: r.get(3)?,
                        iso: r.get(4)?,
                        shutter_speed: r.get(5)?,
                        aperture: r.get(6)?,
                        focal_length: r.get(7)?,
                        flash: r.get::<_, Option<i64>>(8)?.map(|v| v != 0),
                        latitude: r.get(9)?,
                        longitude: r.get(10)?,
                        color_space: r.get(11)?,
                        exposure_mode: r.get(12)?,
                        white_balance: r.get(13)?,
                        raw_json: r.get(14)?,
                    })
                },
            )
            .optional()
            .map_err(Into::into)
    }

    // ────────────────────────────── Stats ────────────────────────────────────

    pub fn get_stats(&self) -> Result<GalleryStats> {
        let total_items: i64 = self
            .conn
            .query_row("SELECT COUNT(*) FROM media_items", [], |r| r.get(0))?;
        let total_folders: i64 = self
            .conn
            .query_row("SELECT COUNT(*) FROM folders", [], |r| r.get(0))?;
        let total_size_bytes: i64 = self
            .conn
            .query_row(
                "SELECT COALESCE(SUM(file_size),0) FROM media_items",
                [],
                |r| r.get(0),
            )?;
        let raw_count: i64 = self.conn.query_row(
            "SELECT COUNT(*) FROM media_items WHERE is_raw = 1",
            [],
            |r| r.get(0),
        )?;
        let flagged_count: i64 = self.conn.query_row(
            "SELECT COUNT(*) FROM media_items WHERE flag = 1",
            [],
            |r| r.get(0),
        )?;
        let rejected_count: i64 = self.conn.query_row(
            "SELECT COUNT(*) FROM media_items WHERE flag = 2",
            [],
            |r| r.get(0),
        )?;
        Ok(GalleryStats {
            total_items,
            total_folders,
            total_size_bytes,
            raw_count,
            flagged_count,
            rejected_count,
        })
    }

    // ────────────────────────────── Helpers ──────────────────────────────────

    fn row_to_media_item(r: &rusqlite::Row) -> rusqlite::Result<MediaItem> {
        Ok(MediaItem {
            id: r.get(0)?,
            folder_id: r.get(1)?,
            file_path: r.get(2)?,
            file_name: r.get(3)?,
            file_size: r.get(4)?,
            width: r.get(5)?,
            height: r.get(6)?,
            mime_type: r.get(7)?,
            created_at: r.get(8)?,
            modified_at: r.get(9)?,
            content_hash: r.get(10)?,
            rating: r.get(11)?,
            flag: r.get(12)?,
            color_label: r.get(13)?,
            is_raw: r.get::<_, i64>(14)? != 0,
            thumbnail_path: r.get(15)?,
            indexed_at: r.get(16)?,
        })
    }
}
