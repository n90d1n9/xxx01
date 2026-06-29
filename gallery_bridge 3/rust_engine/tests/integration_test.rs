// gallery_bridge_engine/tests/integration_test.rs
//
// Integration tests that spin up a real in-memory SQLite DB and
// exercise the full stack: index → search → curation → rename → export.

use gallery_bridge_engine::{
    collections,
    db::{GalleryDb, MediaItem},
    duplicate::{compute_dhash, hamming_distance},
    rename::{preview_rename, ConflictStrategy, RenameConfig, RenameSource},
    search::{execute_search, SearchQuery},
    slideshow::{build_slideshow_config, format_duration, total_duration_ms, SlideshowBuilder, SortStrategy, Transition},
    xmp::{read_sidecar, sidecar_path, write_sidecar, XmpRecord},
};
use std::path::Path;
use tempfile::tempdir;

// ─────────────────────────────────────────────────────────────────────────────
// Database integration
// ─────────────────────────────────────────────────────────────────────────────

fn test_db() -> GalleryDb {
    GalleryDb::open(":memory:").expect("in-memory DB failed")
}

fn insert_item(db: &GalleryDb, id: i64, folder_id: i64, filename: &str, rating: i64, flag: i64) {
    db.conn.execute(
        "INSERT OR IGNORE INTO media_items
         (id, folder_id, file_path, file_name, file_size, mime_type,
          modified_at, rating, flag, color_label, is_raw, indexed_at)
         VALUES (?1,?2,?3,?4,1000,'image/jpeg',0,?5,?6,'',0,0)",
        rusqlite::params![id, folder_id, format!("/photos/{}", filename), filename, rating, flag],
    ).unwrap();
}

#[test]
fn db_open_and_migrate_succeeds() {
    let db = test_db();
    let stats = db.get_stats().unwrap();
    assert_eq!(stats.total_items, 0);
    assert_eq!(stats.total_folders, 0);
}

#[test]
fn upsert_folder_and_retrieve() {
    let db = test_db();
    let id = db.upsert_folder("/photos/vacation").unwrap();
    assert!(id > 0);
    let folders = db.list_folders().unwrap();
    assert_eq!(folders.len(), 1);
    assert_eq!(folders[0].path, "/photos/vacation");
}

#[test]
fn upsert_same_folder_is_idempotent() {
    let db = test_db();
    let id1 = db.upsert_folder("/photos/test").unwrap();
    let id2 = db.upsert_folder("/photos/test").unwrap();
    assert_eq!(id1, id2);
    assert_eq!(db.list_folders().unwrap().len(), 1);
}

#[test]
fn upsert_and_list_media_items() {
    let db = test_db();
    let fid = db.upsert_folder("/photos/test").unwrap();
    let item = MediaItem {
        id: 0, folder_id: fid,
        file_path: "/photos/test/img.jpg".to_string(),
        file_name: "img.jpg".to_string(),
        file_size: 3_000_000,
        width: Some(4000), height: Some(3000),
        mime_type: "image/jpeg".to_string(),
        created_at: Some(1_700_000_000_000),
        modified_at: 1_700_000_000_000,
        content_hash: Some("abc123".to_string()),
        rating: 0, flag: 0,
        color_label: String::new(),
        is_raw: false, thumbnail_path: None,
        indexed_at: 1_700_000_000_000,
    };
    let stored_id = db.upsert_media_item(&item).unwrap();
    assert!(stored_id > 0);
    let retrieved = db.get_media_item(stored_id).unwrap().unwrap();
    assert_eq!(retrieved.file_name, "img.jpg");
    assert_eq!(retrieved.width, Some(4000));
}

#[test]
fn update_rating_persists() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    insert_item(&db, 1, fid, "a.jpg", 0, 0);
    db.update_rating(1, 5).unwrap();
    let item = db.get_media_item(1).unwrap().unwrap();
    assert_eq!(item.rating, 5);
}

#[test]
fn update_flag_persists() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    insert_item(&db, 1, fid, "a.jpg", 0, 0);
    db.update_flag(1, 1).unwrap();
    let item = db.get_media_item(1).unwrap().unwrap();
    assert_eq!(item.flag, 1);
}

#[test]
fn update_color_label_persists() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    insert_item(&db, 1, fid, "a.jpg", 0, 0);
    db.update_color_label(1, "red").unwrap();
    let item = db.get_media_item(1).unwrap().unwrap();
    assert_eq!(item.color_label, "red");
}

#[test]
fn search_by_flag() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    for i in 1..=10 {
        insert_item(&db, i, fid, &format!("img{i}.jpg"), 0, if i <= 3 { 1 } else { 0 });
    }
    let q = SearchQuery { flag: Some(1), ..Default::default() };
    let results = execute_search(&db.conn, &q).unwrap();
    assert_eq!(results.len(), 3);
    assert!(results.iter().all(|r| r.flag == 1));
}

#[test]
fn search_by_rating_min() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    for i in 1..=5 {
        insert_item(&db, i, fid, &format!("img{i}.jpg"), i, 0);
    }
    let q = SearchQuery { rating_min: Some(4), ..Default::default() };
    let results = execute_search(&db.conn, &q).unwrap();
    assert_eq!(results.len(), 2); // items with rating 4 and 5
}

#[test]
fn search_by_filename() {
    let db = test_db();
    let fid = db.upsert_folder("/p").unwrap();
    insert_item(&db, 1, fid, "vacation_paris.jpg", 0, 0);
    insert_item(&db, 2, fid, "office_meeting.jpg", 0, 0);
    insert_item(&db, 3, fid, "vacation_tokyo.jpg", 0, 0);
    let q = SearchQuery { filename_contains: Some("vacation".to_string()), ..Default::default() };
    let results = execute_search(&db.conn, &q).unwrap();
    assert_eq!(results.len(), 2);
}

// ─────────────────────────────────────────────────────────────────────────────
// Collections integration
// ─────────────────────────────────────────────────────────────────────────────

#[test]
fn collections_full_lifecycle() {
    let db = test_db();
    collections::migrate(&db.conn).unwrap();
    let fid = db.upsert_folder("/p").unwrap();
    for i in 1..=5 {
        insert_item(&db, i, fid, &format!("img{i}.jpg"), 0, 0);
    }

    let cid = collections::create_collection(&db.conn, "Portfolio", "My best shots", "album", None).unwrap();
    collections::add_items_to_collection(&db.conn, cid, &[1, 2, 3]).unwrap();

    let items = collections::list_collection_items(&db.conn, cid).unwrap();
    assert_eq!(items.len(), 3);

    collections::remove_items_from_collection(&db.conn, cid, &[2]).unwrap();
    let items2 = collections::list_collection_items(&db.conn, cid).unwrap();
    assert_eq!(items2.len(), 2);
    assert!(!items2.contains(&2));

    collections::rename_collection(&db.conn, cid, "Best Work").unwrap();
    let cols = collections::list_collections(&db.conn).unwrap();
    assert_eq!(cols[0].name, "Best Work");

    collections::delete_collection(&db.conn, cid).unwrap();
    assert!(collections::list_collections(&db.conn).unwrap().is_empty());
}

// ─────────────────────────────────────────────────────────────────────────────
// Rename integration
// ─────────────────────────────────────────────────────────────────────────────

#[test]
fn rename_preview_batch_no_conflicts() {
    let sources: Vec<RenameSource> = (0..5).map(|i| RenameSource {
        item_id: i + 1,
        current_path: format!("/photos/DSC_{:04}.jpg", i),
        exif_date: Some("2024:11:15 10:30:00".to_string()),
        camera_model: Some("Sony A7R IV".to_string()),
        iso: Some(200), focal_length: Some(35.0), rating: 0,
    }).collect();

    let config = RenameConfig {
        template: "{date}_{seq:4}.{ext}".to_string(),
        seq_start: 1, seq_pad: 4,
        conflict: ConflictStrategy::Suffix,
        dry_run: true,
    };

    let previews = preview_rename(&sources, &config);
    assert_eq!(previews.len(), 5);
    assert_eq!(previews[0].new_name, "2024-11-15_0001.jpg");
    assert_eq!(previews[4].new_name, "2024-11-15_0005.jpg");
    assert!(previews.iter().all(|p| !p.conflict));
}

#[test]
fn rename_template_camera_token() {
    let sources = vec![RenameSource {
        item_id: 1,
        current_path: "/photos/img.jpg".to_string(),
        exif_date: Some("2024:06:01 12:00:00".to_string()),
        camera_model: Some("Canon EOS R5".to_string()),
        iso: Some(400), focal_length: Some(50.0), rating: 4,
    }];

    let config = RenameConfig {
        template: "{camera}_{date}_{seq:3}.{ext}".to_string(),
        seq_start: 1, seq_pad: 3,
        conflict: ConflictStrategy::Suffix,
        dry_run: true,
    };

    let previews = preview_rename(&sources, &config);
    assert_eq!(previews[0].new_name, "Canon_EOS_R5_2024-06-01_001.jpg");
}

// ─────────────────────────────────────────────────────────────────────────────
// XMP sidecar integration
// ─────────────────────────────────────────────────────────────────────────────

#[test]
fn xmp_write_read_roundtrip() {
    let dir = tempdir().unwrap();
    let src = dir.path().join("DSC_001.jpg");
    std::fs::write(&src, b"fake jpeg data").unwrap();

    let record = XmpRecord {
        rating: 5,
        label: "Green".to_string(),
        flag: 1,
        title: Some("Sunset at Santorini".to_string()),
        description: Some("Golden hour shot".to_string()),
        keywords: vec!["travel".to_string(), "greece".to_string(), "sunset".to_string()],
        creator: Some("Jane Doe".to_string()),
        copyright: Some("© 2024 Jane Doe".to_string()),
    };

    let xmp_path = write_sidecar(&src, &record).unwrap();
    assert!(xmp_path.exists());

    let read_back = read_sidecar(&src).unwrap().unwrap();
    assert_eq!(read_back.rating, 5);
    assert_eq!(read_back.label, "Green");
    assert_eq!(read_back.flag, 1);
}

#[test]
fn xmp_sidecar_path_convention() {
    let p = Path::new("/photos/IMG_001.ARW");
    let xp = sidecar_path(p);
    assert_eq!(xp.extension().unwrap(), "xmp");
    assert_eq!(xp.file_stem().unwrap(), "IMG_001");
}

#[test]
fn xmp_overwrite_updates_rating() {
    let dir = tempdir().unwrap();
    let src = dir.path().join("test.jpg");
    std::fs::write(&src, b"fake").unwrap();

    write_sidecar(&src, &XmpRecord { rating: 2, ..Default::default() }).unwrap();
    let r1 = read_sidecar(&src).unwrap().unwrap();
    assert_eq!(r1.rating, 2);

    write_sidecar(&src, &XmpRecord { rating: 5, ..Default::default() }).unwrap();
    let r2 = read_sidecar(&src).unwrap().unwrap();
    assert_eq!(r2.rating, 5);
}

// ─────────────────────────────────────────────────────────────────────────────
// Slideshow integration
// ─────────────────────────────────────────────────────────────────────────────

#[test]
fn slideshow_builder_correct_slide_count() {
    let items: Vec<(i64, String, Option<String>, String)> = (1..=10)
        .map(|i| (i, format!("/p/{i}.jpg"), None, format!("{i}.jpg")))
        .collect();

    let config = SlideshowBuilder::new()
        .title("Test Show")
        .duration(4000)
        .transition(Transition::CrossFade, 800)
        .add_slides(&items, SortStrategy::Manual)
        .build();

    assert_eq!(config.slides.len(), 10);
    assert_eq!(config.title, "Test Show");
    assert_eq!(config.slides[0].duration_ms, 4000);
}

#[test]
fn slideshow_total_duration() {
    let items: Vec<(i64, String, Option<String>, String)> = (1..=5)
        .map(|i| (i, format!("/p/{i}.jpg"), None, format!("{i}.jpg")))
        .collect();

    let config = SlideshowBuilder::new()
        .duration(3000)
        .transition(Transition::Fade, 1000)
        .add_slides(&items, SortStrategy::Manual)
        .build();

    let total = total_duration_ms(&config);
    assert_eq!(total, 5 * (3000 + 1000));
}

#[test]
fn slideshow_duration_format() {
    assert_eq!(format_duration(0), "0:00");
    assert_eq!(format_duration(60_000), "1:00");
    assert_eq!(format_duration(125_000), "2:05");
    assert_eq!(format_duration(3_600_000), "60:00");
}

#[test]
fn slideshow_shuffle_changes_order() {
    let items: Vec<(i64, String, Option<String>, String)> = (1..=20)
        .map(|i| (i, format!("/p/{i}.jpg"), None, format!("{i}.jpg")))
        .collect();

    let sequential = SlideshowBuilder::new()
        .add_slides(&items, SortStrategy::Manual)
        .build();

    let shuffled = SlideshowBuilder::new()
        .add_slides(&items, SortStrategy::Random(42))
        .build();

    // Both have same count
    assert_eq!(sequential.slides.len(), shuffled.slides.len());

    // But different order (with overwhelming probability)
    let seq_ids: Vec<i64> = sequential.slides.iter().map(|s| s.item_id).collect();
    let shuf_ids: Vec<i64> = shuffled.slides.iter().map(|s| s.item_id).collect();
    assert_ne!(seq_ids, shuf_ids, "Shuffled order should differ from sequential");
}

// ─────────────────────────────────────────────────────────────────────────────
// dHash integration
// ─────────────────────────────────────────────────────────────────────────────

#[test]
fn dhash_identical_images_have_zero_distance() {
    use gallery_bridge_engine::duplicate::compute_dhash;
    let img = image::DynamicImage::new_rgb8(100, 100);
    let h1 = compute_dhash(&img);
    let h2 = compute_dhash(&img);
    assert_eq!(hamming_distance(&h1, &h2), 0);
}

#[test]
fn dhash_is_16_hex_chars() {
    let img = image::DynamicImage::new_rgb8(50, 50);
    let h = compute_dhash(&img);
    assert_eq!(h.len(), 16);
    assert!(h.chars().all(|c| c.is_ascii_hexdigit()));
}

#[test]
fn hamming_distance_max_is_64() {
    let max = hamming_distance("0000000000000000", "ffffffffffffffff");
    assert_eq!(max, 64);
}
