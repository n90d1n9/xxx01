// gallery_bridge_engine/src/collections/mod.rs
//
// Collections (albums) system.
// A collection is a user-curated, ordered set of media items.
// Unlike folders (which are tied to the filesystem), collections
// are purely virtual — they reference items by ID.
//
// Schema additions (applied via migrate() in db/mod.rs):
//   collections        : id, name, description, cover_item_id, created_at, kind
//   collection_items   : collection_id, item_id, position, added_at

use anyhow::Result;
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};

// ────────────────────────────────────────────────────────────────────────────
// Models
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Collection {
    pub id: i64,
    pub name: String,
    pub description: String,
    pub cover_item_id: Option<i64>,
    pub item_count: i64,
    pub created_at: i64,
    /// "album" | "smart" | "output"
    pub kind: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CollectionItem {
    pub collection_id: i64,
    pub item_id: i64,
    pub position: i64,
    pub added_at: i64,
}

/// Smart collection criteria (stored as JSON in collections.smart_criteria)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SmartCriteria {
    pub flag_filter: Option<i64>,
    pub rating_min: Option<i64>,
    pub color_label: Option<String>,
    pub camera_model: Option<String>,
    pub date_from: Option<i64>,
    pub date_to: Option<i64>,
    pub is_raw: Option<bool>,
}

// ────────────────────────────────────────────────────────────────────────────
// Schema migration (called from GalleryDb::migrate)
// ────────────────────────────────────────────────────────────────────────────

pub fn migrate(conn: &Connection) -> Result<()> {
    conn.execute_batch(
        "
        CREATE TABLE IF NOT EXISTS collections (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            name            TEXT    NOT NULL,
            description     TEXT    NOT NULL DEFAULT '',
            cover_item_id   INTEGER REFERENCES media_items(id) ON DELETE SET NULL,
            created_at      INTEGER NOT NULL DEFAULT 0,
            kind            TEXT    NOT NULL DEFAULT 'album',
            smart_criteria  TEXT
        );

        CREATE TABLE IF NOT EXISTS collection_items (
            collection_id   INTEGER NOT NULL REFERENCES collections(id)  ON DELETE CASCADE,
            item_id         INTEGER NOT NULL REFERENCES media_items(id)  ON DELETE CASCADE,
            position        INTEGER NOT NULL DEFAULT 0,
            added_at        INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (collection_id, item_id)
        );

        CREATE INDEX IF NOT EXISTS idx_coll_items_cid ON collection_items(collection_id);
        CREATE INDEX IF NOT EXISTS idx_coll_items_pos ON collection_items(collection_id, position);
        ",
    )?;
    Ok(())
}

// ────────────────────────────────────────────────────────────────────────────
// Collection CRUD
// ────────────────────────────────────────────────────────────────────────────

pub fn create_collection(
    conn: &Connection,
    name: &str,
    description: &str,
    kind: &str,
    smart_criteria: Option<&SmartCriteria>,
) -> Result<i64> {
    let now = unix_ms_now();
    let criteria_json = smart_criteria
        .map(|c| serde_json::to_string(c).unwrap_or_default());

    conn.execute(
        "INSERT INTO collections (name, description, created_at, kind, smart_criteria)
         VALUES (?1, ?2, ?3, ?4, ?5)",
        params![name, description, now, kind, criteria_json],
    )?;
    Ok(conn.last_insert_rowid())
}

pub fn list_collections(conn: &Connection) -> Result<Vec<Collection>> {
    let mut stmt = conn.prepare(
        "SELECT c.id, c.name, c.description, c.cover_item_id, c.created_at, c.kind,
                (SELECT COUNT(*) FROM collection_items WHERE collection_id = c.id) AS cnt
         FROM collections c
         ORDER BY c.created_at DESC",
    )?;
    let rows = stmt.query_map([], |r| {
        Ok(Collection {
            id:            r.get(0)?,
            name:          r.get(1)?,
            description:   r.get(2)?,
            cover_item_id: r.get(3)?,
            created_at:    r.get(4)?,
            kind:          r.get(5)?,
            item_count:    r.get(6)?,
        })
    })?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

pub fn rename_collection(conn: &Connection, id: i64, name: &str) -> Result<()> {
    conn.execute("UPDATE collections SET name = ?1 WHERE id = ?2", params![name, id])?;
    Ok(())
}

pub fn delete_collection(conn: &Connection, id: i64) -> Result<()> {
    conn.execute("DELETE FROM collections WHERE id = ?1", params![id])?;
    Ok(())
}

pub fn set_collection_cover(conn: &Connection, id: i64, item_id: Option<i64>) -> Result<()> {
    conn.execute(
        "UPDATE collections SET cover_item_id = ?1 WHERE id = ?2",
        params![item_id, id],
    )?;
    Ok(())
}

// ────────────────────────────────────────────────────────────────────────────
// Collection item management
// ────────────────────────────────────────────────────────────────────────────

pub fn add_items_to_collection(
    conn: &Connection,
    collection_id: i64,
    item_ids: &[i64],
) -> Result<usize> {
    let now = unix_ms_now();
    // Find current max position
    let max_pos: i64 = conn
        .query_row(
            "SELECT COALESCE(MAX(position), -1) FROM collection_items WHERE collection_id = ?1",
            params![collection_id],
            |r| r.get(0),
        )
        .unwrap_or(-1);

    let mut added = 0;
    for (i, item_id) in item_ids.iter().enumerate() {
        let result = conn.execute(
            "INSERT OR IGNORE INTO collection_items (collection_id, item_id, position, added_at)
             VALUES (?1, ?2, ?3, ?4)",
            params![collection_id, item_id, max_pos + 1 + i as i64, now],
        )?;
        added += result;
    }
    Ok(added)
}

pub fn remove_items_from_collection(
    conn: &Connection,
    collection_id: i64,
    item_ids: &[i64],
) -> Result<()> {
    for item_id in item_ids {
        conn.execute(
            "DELETE FROM collection_items WHERE collection_id = ?1 AND item_id = ?2",
            params![collection_id, item_id],
        )?;
    }
    Ok(())
}

pub fn reorder_collection_item(
    conn: &Connection,
    collection_id: i64,
    item_id: i64,
    new_position: i64,
) -> Result<()> {
    conn.execute(
        "UPDATE collection_items SET position = ?1
         WHERE collection_id = ?2 AND item_id = ?3",
        params![new_position, collection_id, item_id],
    )?;
    Ok(())
}

pub fn list_collection_items(conn: &Connection, collection_id: i64) -> Result<Vec<i64>> {
    let mut stmt = conn.prepare(
        "SELECT item_id FROM collection_items
         WHERE collection_id = ?1
         ORDER BY position ASC",
    )?;
    let rows = stmt.query_map(params![collection_id], |r| r.get::<_, i64>(0))?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

/// Returns all collection IDs that contain the given item.
pub fn collections_for_item(conn: &Connection, item_id: i64) -> Result<Vec<i64>> {
    let mut stmt = conn.prepare(
        "SELECT collection_id FROM collection_items WHERE item_id = ?1",
    )?;
    let rows = stmt.query_map(params![item_id], |r| r.get::<_, i64>(0))?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

fn unix_ms_now() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_db() -> rusqlite::Connection {
        let conn = rusqlite::Connection::open_in_memory().unwrap();
        // Minimal schema for collections
        conn.execute_batch(
            "CREATE TABLE IF NOT EXISTS collections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL DEFAULT '',
                cover_item_id INTEGER,
                created_at INTEGER NOT NULL DEFAULT 0,
                kind TEXT NOT NULL DEFAULT 'album',
                smart_criteria TEXT
            );
            CREATE TABLE IF NOT EXISTS collection_items (
                collection_id INTEGER NOT NULL,
                item_id INTEGER NOT NULL,
                position INTEGER NOT NULL DEFAULT 0,
                added_at INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (collection_id, item_id)
            );
            -- Minimal media_items stub for FK satisfaction
            CREATE TABLE IF NOT EXISTS media_items (id INTEGER PRIMARY KEY);"
        ).unwrap();
        conn
    }

    #[test]
    fn create_and_list_collection() {
        let conn = make_db();
        let id = create_collection(&conn, "Test Album", "desc", "album", None).unwrap();
        assert!(id > 0);
        let cols = list_collections(&conn).unwrap();
        assert_eq!(cols.len(), 1);
        assert_eq!(cols[0].name, "Test Album");
        assert_eq!(cols[0].kind, "album");
    }

    #[test]
    fn rename_collection_updates_name() {
        let conn = make_db();
        let id = create_collection(&conn, "Old Name", "", "album", None).unwrap();
        rename_collection(&conn, id, "New Name").unwrap();
        let cols = list_collections(&conn).unwrap();
        assert_eq!(cols[0].name, "New Name");
    }

    #[test]
    fn delete_collection_removes_it() {
        let conn = make_db();
        let id = create_collection(&conn, "To Delete", "", "album", None).unwrap();
        delete_collection(&conn, id).unwrap();
        let cols = list_collections(&conn).unwrap();
        assert!(cols.is_empty());
    }

    #[test]
    fn add_and_list_items() {
        let conn = make_db();
        // Insert stub media items
        conn.execute("INSERT INTO media_items (id) VALUES (10), (20), (30)", []).unwrap();
        let cid = create_collection(&conn, "Album", "", "album", None).unwrap();
        let added = add_items_to_collection(&conn, cid, &[10, 20, 30]).unwrap();
        assert_eq!(added, 3);
        let items = list_collection_items(&conn, cid).unwrap();
        assert_eq!(items.len(), 3);
        assert!(items.contains(&10));
    }

    #[test]
    fn remove_items_from_collection_works() {
        let conn = make_db();
        conn.execute("INSERT INTO media_items (id) VALUES (1),(2),(3)", []).unwrap();
        let cid = create_collection(&conn, "Album", "", "album", None).unwrap();
        add_items_to_collection(&conn, cid, &[1, 2, 3]).unwrap();
        remove_items_from_collection(&conn, cid, &[2]).unwrap();
        let items = list_collection_items(&conn, cid).unwrap();
        assert_eq!(items.len(), 2);
        assert!(!items.contains(&2));
    }

    #[test]
    fn smart_criteria_serializes() {
        let criteria = SmartCriteria {
            flag_filter: Some(1),
            rating_min: Some(4),
            color_label: None,
            camera_model: None,
            date_from: None,
            date_to: None,
            is_raw: Some(false),
        };
        let json = serde_json::to_string(&criteria).unwrap();
        assert!(json.contains("flag_filter"));
    }
}
