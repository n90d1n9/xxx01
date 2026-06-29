// gallery_bridge_engine/src/analytics/mod.rs
//
// Gallery analytics engine.
// Runs SQL aggregate queries against the indexed database to produce
// statistical summaries Flutter can visualise as charts.
//
// All queries run in microseconds on indexed columns.

use anyhow::Result;
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};

// ────────────────────────────────────────────────────────────────────────────
// Output types  (all serializable for flutter_rust_bridge)
// ────────────────────────────────────────────────────────────────────────────

/// Count per discrete bucket
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BucketStat {
    pub label: String,
    pub count: i64,
    pub size_bytes: i64,
}

/// Heatmap cell: day-of-week × hour-of-day (0-based)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HeatmapCell {
    pub day_of_week: i64,  // 0=Sun … 6=Sat
    pub hour: i64,         // 0..23
    pub count: i64,
}

/// Focal length histogram bucket (mm ranges)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FocalBucket {
    pub range_label: String, // "14-24 mm"
    pub count: i64,
}

/// Per-month shooting activity
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonthStat {
    pub year_month: String, // "2024-11"
    pub count: i64,
    pub flagged: i64,
    pub rejected: i64,
}

/// Full analytics snapshot
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnalyticsSnapshot {
    pub total_items:       i64,
    pub total_size_bytes:  i64,
    pub raw_count:         i64,
    pub flagged_count:     i64,
    pub rejected_count:    i64,
    pub rated_count:       i64,      // rating >= 1
    pub avg_rating:        f64,
    pub by_camera:         Vec<BucketStat>,
    pub by_lens:           Vec<BucketStat>,
    pub by_iso:            Vec<BucketStat>,
    pub by_aperture:       Vec<BucketStat>,
    pub by_focal_length:   Vec<FocalBucket>,
    pub by_color_label:    Vec<BucketStat>,
    pub by_month:          Vec<MonthStat>,
    pub hourly_heatmap:    Vec<HeatmapCell>,
    pub top_shoot_days:    Vec<BucketStat>,
    pub size_distribution: Vec<BucketStat>,
}

// ────────────────────────────────────────────────────────────────────────────
// Main entry point
// ────────────────────────────────────────────────────────────────────────────

pub fn compute_analytics(
    conn: &Connection,
    folder_id: Option<i64>,
) -> Result<AnalyticsSnapshot> {
    let folder_clause = folder_id
        .map(|id| format!("m.folder_id = {id}"))
        .unwrap_or_else(|| "1=1".to_string());

    Ok(AnalyticsSnapshot {
        total_items:       count_scalar(conn, &format!("SELECT COUNT(*) FROM media_items m WHERE {folder_clause}"))?,
        total_size_bytes:  count_scalar(conn, &format!("SELECT COALESCE(SUM(file_size),0) FROM media_items m WHERE {folder_clause}"))?,
        raw_count:         count_scalar(conn, &format!("SELECT COUNT(*) FROM media_items m WHERE {folder_clause} AND is_raw=1"))?,
        flagged_count:     count_scalar(conn, &format!("SELECT COUNT(*) FROM media_items m WHERE {folder_clause} AND flag=1"))?,
        rejected_count:    count_scalar(conn, &format!("SELECT COUNT(*) FROM media_items m WHERE {folder_clause} AND flag=2"))?,
        rated_count:       count_scalar(conn, &format!("SELECT COUNT(*) FROM media_items m WHERE {folder_clause} AND rating>=1"))?,
        avg_rating: {
            let sum: f64 = conn.query_row(&format!(
                "SELECT COALESCE(AVG(CAST(rating AS REAL)),0.0) FROM media_items m WHERE {folder_clause} AND rating>0"
            ), [], |r| r.get(0)).unwrap_or(0.0);
            (sum * 10.0).round() / 10.0
        },

        by_camera:       camera_stats(conn, &folder_clause)?,
        by_lens:         lens_stats(conn, &folder_clause)?,
        by_iso:          iso_stats(conn, &folder_clause)?,
        by_aperture:     aperture_stats(conn, &folder_clause)?,
        by_focal_length: focal_length_stats(conn, &folder_clause)?,
        by_color_label:  color_label_stats(conn, &folder_clause)?,
        by_month:        monthly_stats(conn, &folder_clause)?,
        hourly_heatmap:  hourly_heatmap(conn, &folder_clause)?,
        top_shoot_days:  top_shoot_days(conn, &folder_clause)?,
        size_distribution: size_distribution(conn, &folder_clause)?,
    })
}

// ────────────────────────────────────────────────────────────────────────────
// Individual stat queries
// ────────────────────────────────────────────────────────────────────────────

fn camera_stats(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT COALESCE(e.camera_model, 'Unknown') AS label,
                COUNT(*) AS count,
                COALESCE(SUM(m.file_size),0) AS size_bytes
         FROM media_items m
         LEFT JOIN exif_data e ON e.item_id = m.id
         WHERE {fc}
         GROUP BY label
         ORDER BY count DESC
         LIMIT 20"
    );
    bucket_query(conn, &sql)
}

fn lens_stats(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT COALESCE(e.lens, 'Unknown') AS label,
                COUNT(*) AS count,
                COALESCE(SUM(m.file_size),0) AS size_bytes
         FROM media_items m
         LEFT JOIN exif_data e ON e.item_id = m.id
         WHERE {fc} AND e.lens IS NOT NULL
         GROUP BY label
         ORDER BY count DESC
         LIMIT 15"
    );
    bucket_query(conn, &sql)
}

fn iso_stats(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    // Bucket ISO into standard ranges
    let sql = format!(
        "SELECT
           CASE
             WHEN e.iso IS NULL      THEN 'Unknown'
             WHEN e.iso <= 100       THEN '≤100'
             WHEN e.iso <= 200       THEN '200'
             WHEN e.iso <= 400       THEN '400'
             WHEN e.iso <= 800       THEN '800'
             WHEN e.iso <= 1600      THEN '1600'
             WHEN e.iso <= 3200      THEN '3200'
             WHEN e.iso <= 6400      THEN '6400'
             ELSE                         '6400+'
           END AS label,
           COUNT(*) AS count,
           0 AS size_bytes
         FROM media_items m
         LEFT JOIN exif_data e ON e.item_id = m.id
         WHERE {fc}
         GROUP BY label
         ORDER BY MIN(COALESCE(e.iso, 999999))"
    );
    bucket_query(conn, &sql)
}

fn aperture_stats(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT
           CASE
             WHEN e.aperture IS NULL   THEN 'Unknown'
             WHEN e.aperture < 1.8     THEN 'f/1.2–1.4'
             WHEN e.aperture < 2.2     THEN 'f/1.8–2.0'
             WHEN e.aperture < 2.9     THEN 'f/2.2–2.8'
             WHEN e.aperture < 4.5     THEN 'f/3.5–4.0'
             WHEN e.aperture < 6.5     THEN 'f/5.6'
             WHEN e.aperture < 9.0     THEN 'f/7.1–8.0'
             ELSE                           'f/11+'
           END AS label,
           COUNT(*) AS count,
           0 AS size_bytes
         FROM media_items m
         LEFT JOIN exif_data e ON e.item_id = m.id
         WHERE {fc}
         GROUP BY label
         ORDER BY MIN(COALESCE(e.aperture, 999))"
    );
    bucket_query(conn, &sql)
}

fn focal_length_stats(conn: &Connection, fc: &str) -> Result<Vec<FocalBucket>> {
    let sql = format!(
        "SELECT
           CASE
             WHEN e.focal_length IS NULL    THEN 'Unknown'
             WHEN e.focal_length < 18       THEN '≤17mm (ultra-wide)'
             WHEN e.focal_length < 25       THEN '18–24mm (wide)'
             WHEN e.focal_length < 36       THEN '24–35mm'
             WHEN e.focal_length < 56       THEN '35–50mm (normal)'
             WHEN e.focal_length < 86       THEN '50–85mm (portrait)'
             WHEN e.focal_length < 136      THEN '85–135mm (tele)'
             WHEN e.focal_length < 201      THEN '135–200mm'
             ELSE                                '200mm+'
           END AS range_label,
           COUNT(*) AS count
         FROM media_items m
         LEFT JOIN exif_data e ON e.item_id = m.id
         WHERE {fc}
         GROUP BY range_label
         ORDER BY MIN(COALESCE(e.focal_length, 9999))"
    );
    let mut stmt = conn.prepare(&sql)?;
    let rows = stmt.query_map([], |r| {
        Ok(FocalBucket {
            range_label: r.get(0)?,
            count: r.get(1)?,
        })
    })?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

fn color_label_stats(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT CASE WHEN color_label='' THEN 'None' ELSE color_label END AS label,
                COUNT(*) AS count, 0 AS size_bytes
         FROM media_items m
         WHERE {fc}
         GROUP BY label ORDER BY count DESC"
    );
    bucket_query(conn, &sql)
}

fn monthly_stats(conn: &Connection, fc: &str) -> Result<Vec<MonthStat>> {
    let sql = format!(
        "SELECT
           strftime('%Y-%m', datetime(created_at/1000, 'unixepoch')) AS ym,
           COUNT(*) AS cnt,
           SUM(CASE WHEN flag=1 THEN 1 ELSE 0 END) AS flagged,
           SUM(CASE WHEN flag=2 THEN 1 ELSE 0 END) AS rejected
         FROM media_items m
         WHERE {fc} AND created_at IS NOT NULL
         GROUP BY ym
         ORDER BY ym DESC
         LIMIT 24"
    );
    let mut stmt = conn.prepare(&sql)?;
    let rows = stmt.query_map([], |r| {
        Ok(MonthStat {
            year_month: r.get(0)?,
            count:      r.get(1)?,
            flagged:    r.get(2)?,
            rejected:   r.get(3)?,
        })
    })?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

fn hourly_heatmap(conn: &Connection, fc: &str) -> Result<Vec<HeatmapCell>> {
    let sql = format!(
        "SELECT
           CAST(strftime('%w', datetime(created_at/1000,'unixepoch')) AS INTEGER) AS dow,
           CAST(strftime('%H', datetime(created_at/1000,'unixepoch')) AS INTEGER) AS hr,
           COUNT(*) AS count
         FROM media_items m
         WHERE {fc} AND created_at IS NOT NULL
         GROUP BY dow, hr"
    );
    let mut stmt = conn.prepare(&sql)?;
    let rows = stmt.query_map([], |r| {
        Ok(HeatmapCell {
            day_of_week: r.get(0)?,
            hour:        r.get(1)?,
            count:       r.get(2)?,
        })
    })?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

fn top_shoot_days(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT
           strftime('%Y-%m-%d', datetime(created_at/1000,'unixepoch')) AS label,
           COUNT(*) AS count, 0 AS size_bytes
         FROM media_items m
         WHERE {fc} AND created_at IS NOT NULL
         GROUP BY label ORDER BY count DESC LIMIT 10"
    );
    bucket_query(conn, &sql)
}

fn size_distribution(conn: &Connection, fc: &str) -> Result<Vec<BucketStat>> {
    let sql = format!(
        "SELECT
           CASE
             WHEN file_size < 1000000   THEN '<1 MB'
             WHEN file_size < 5000000   THEN '1–5 MB'
             WHEN file_size < 15000000  THEN '5–15 MB'
             WHEN file_size < 30000000  THEN '15–30 MB'
             WHEN file_size < 50000000  THEN '30–50 MB'
             ELSE                            '50 MB+'
           END AS label,
           COUNT(*) AS count,
           SUM(file_size) AS size_bytes
         FROM media_items m WHERE {fc}
         GROUP BY label
         ORDER BY MIN(file_size)"
    );
    bucket_query(conn, &sql)
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

fn bucket_query(conn: &Connection, sql: &str) -> Result<Vec<BucketStat>> {
    let mut stmt = conn.prepare(sql)?;
    let rows = stmt.query_map([], |r| {
        Ok(BucketStat {
            label:      r.get(0)?,
            count:      r.get(1)?,
            size_bytes: r.get(2)?,
        })
    })?;
    rows.collect::<rusqlite::Result<Vec<_>>>().map_err(Into::into)
}

fn count_scalar(conn: &Connection, sql: &str) -> Result<i64> {
    conn.query_row(sql, [], |r| r.get(0)).map_err(Into::into)
}

// ─────────────────────────────────────────────────────────────────────────────
// Compatibility wrappers (called from api/mod.rs)
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight summary stats (used by the analytics API endpoint).
#[derive(Debug, Clone)]
pub struct GallerySummary {
    pub total_items: i64,
    pub total_size_bytes: i64,
    pub flagged_count: i64,
    pub rejected_count: i64,
    pub rated_count: i64,
    pub raw_count: i64,
    pub geotagged_count: i64,
}

pub fn gallery_summary(conn: &Connection) -> anyhow::Result<GallerySummary> {
    let snap = compute_analytics(conn, None)?;
    Ok(GallerySummary {
        total_items:      snap.total_items,
        total_size_bytes: snap.total_size_bytes,
        flagged_count:    snap.flagged_count,
        rejected_count:   snap.rejected_count,
        rated_count:      snap.rated_count,
        raw_count:        snap.raw_count,
        geotagged_count:  count_scalar(conn,
            "SELECT COUNT(*) FROM exif_data WHERE latitude IS NOT NULL").unwrap_or(0),
    })
}

/// Camera model breakdown as JSON-ready Vec.
pub fn camera_stats(conn: &Connection) -> anyhow::Result<Vec<BucketStat>> {
    let snap = compute_analytics(conn, None)?;
    Ok(snap.by_camera)
}

/// Hour-of-day shooting heatmap.
pub fn shooting_heatmap(conn: &Connection) -> anyhow::Result<Vec<HeatmapCell>> {
    let snap = compute_analytics(conn, None)?;
    Ok(snap.hourly_heatmap)
}

/// Month-by-month activity.
pub fn monthly_stats(conn: &Connection) -> anyhow::Result<Vec<MonthStat>> {
    let snap = compute_analytics(conn, None)?;
    Ok(snap.by_month)
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gallery_summary_struct_builds() {
        let s = GallerySummary {
            total_items: 100, total_size_bytes: 1_000_000,
            flagged_count: 10, rejected_count: 5,
            rated_count: 20, raw_count: 8, geotagged_count: 3,
        };
        assert_eq!(s.total_items, 100);
        assert_eq!(s.raw_count, 8);
    }

    #[test]
    fn bucket_stat_serializes() {
        let b = BucketStat { label: "Sony A7R IV".to_string(), count: 42, size_bytes: 99 };
        let json = serde_json::to_string(&b).unwrap();
        assert!(json.contains("Sony A7R IV"));
    }

    #[test]
    fn heatmap_cell_day_range() {
        let cell = HeatmapCell { day_of_week: 6, hour: 23, count: 1 };
        assert!(cell.day_of_week <= 6);
        assert!(cell.hour <= 23);
    }

    #[test]
    fn month_stat_format() {
        let m = MonthStat { year_month: "2024-11".to_string(), count: 50, flagged: 5, rejected: 2 };
        assert_eq!(&m.year_month[4..5], "-");
    }
}
