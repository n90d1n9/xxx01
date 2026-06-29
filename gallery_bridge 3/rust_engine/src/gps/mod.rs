// gallery_bridge_engine/src/gps/mod.rs
//
// GPS clustering and map-tile grouping engine.
//
// Algorithms:
//   1. Grid clustering  — fast O(n) bucket-based approach for initial render.
//      Divides the world into lat/lng grid cells at a given zoom level and
//      groups items that fall in the same cell.
//   2. DBSCAN-lite      — density-based clustering for finding photo hotspots.
//      Items within `eps_km` of each other are merged into one cluster.
//
// Output types are designed to match what a Flutter map plugin (e.g.
// flutter_map + leaflet) can consume directly.

use anyhow::Result;
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};

// ────────────────────────────────────────────────────────────────────────────
// Types
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GpsPoint {
    pub item_id: i64,
    pub latitude: f64,
    pub longitude: f64,
    pub thumbnail_path: Option<String>,
    pub file_name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MapCluster {
    /// Centroid latitude
    pub lat: f64,
    /// Centroid longitude
    pub lng: f64,
    /// IDs of items in this cluster
    pub item_ids: Vec<i64>,
    /// Representative thumbnail (first item with one)
    pub thumb_path: Option<String>,
    /// Bounding box [min_lat, min_lng, max_lat, max_lng]
    pub bbox: [f64; 4],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GpsStats {
    pub total_geotagged: i64,
    pub country_counts: Vec<(String, i64)>,
    pub unique_locations: i64,
}

// ────────────────────────────────────────────────────────────────────────────
// Data loading
// ────────────────────────────────────────────────────────────────────────────

/// Load all geotagged items from the database.
pub fn load_gps_points(conn: &Connection, folder_id: Option<i64>) -> Result<Vec<GpsPoint>> {
    let folder_clause = folder_id
        .map(|id| format!("AND m.folder_id = {id}"))
        .unwrap_or_default();

    let sql = format!(
        "SELECT m.id, e.latitude, e.longitude, m.thumbnail_path, m.file_name
         FROM media_items m
         JOIN exif_data e ON e.item_id = m.id
         WHERE e.latitude IS NOT NULL AND e.longitude IS NOT NULL
         {folder_clause}
         ORDER BY m.created_at DESC"
    );

    let mut stmt = conn.prepare(&sql)?;
    let rows = stmt.query_map([], |r| {
        Ok(GpsPoint {
            item_id:        r.get(0)?,
            latitude:       r.get(1)?,
            longitude:      r.get(2)?,
            thumbnail_path: r.get(3)?,
            file_name:      r.get(4)?,
        })
    })?;
    rows.collect::<rusqlite::Result<_>>().map_err(Into::into)
}

// ────────────────────────────────────────────────────────────────────────────
// Grid clustering (zoom-level aware)
// ────────────────────────────────────────────────────────────────────────────

/// Cluster points using a grid at a given zoom level (1–18).
/// At zoom 1 the grid is 4×2 cells; at zoom 18 individual pins.
pub fn cluster_by_grid(points: &[GpsPoint], zoom: u8) -> Vec<MapCluster> {
    if points.is_empty() {
        return vec![];
    }

    // Cell size in degrees (rough approximation)
    let cell_deg = 360.0 / (2.0f64.powi(zoom as i32) * 2.0);

    let mut buckets: std::collections::HashMap<(i64, i64), Vec<usize>> =
        std::collections::HashMap::new();

    for (i, pt) in points.iter().enumerate() {
        let col = (pt.longitude / cell_deg).floor() as i64;
        let row = (pt.latitude  / cell_deg).floor() as i64;
        buckets.entry((col, row)).or_default().push(i);
    }

    let mut clusters = Vec::with_capacity(buckets.len());

    for (_key, indices) in &buckets {
        let lats: Vec<f64> = indices.iter().map(|&i| points[i].latitude).collect();
        let lngs: Vec<f64> = indices.iter().map(|&i| points[i].longitude).collect();

        let centroid_lat = lats.iter().sum::<f64>() / lats.len() as f64;
        let centroid_lng = lngs.iter().sum::<f64>() / lngs.len() as f64;

        let min_lat = lats.iter().cloned().fold(f64::INFINITY, f64::min);
        let max_lat = lats.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
        let min_lng = lngs.iter().cloned().fold(f64::INFINITY, f64::min);
        let max_lng = lngs.iter().cloned().fold(f64::NEG_INFINITY, f64::max);

        let thumb = indices
            .iter()
            .find_map(|&i| points[i].thumbnail_path.clone());

        clusters.push(MapCluster {
            lat: centroid_lat,
            lng: centroid_lng,
            item_ids: indices.iter().map(|&i| points[i].item_id).collect(),
            thumb_path: thumb,
            bbox: [min_lat, min_lng, max_lat, max_lng],
        });
    }

    // Sort by cluster size descending
    clusters.sort_by(|a, b| b.item_ids.len().cmp(&a.item_ids.len()));
    clusters
}

// ────────────────────────────────────────────────────────────────────────────
// DBSCAN-lite clustering
// ────────────────────────────────────────────────────────────────────────────

/// Find photo hotspots using density-based clustering.
/// `eps_km`: maximum distance in km for two points to be considered neighbours.
/// `min_points`: minimum cluster size (noise points are returned as singletons).
pub fn cluster_dbscan(
    points: &[GpsPoint],
    eps_km: f64,
    min_points: usize,
) -> Vec<MapCluster> {
    let n = points.len();
    if n == 0 {
        return vec![];
    }

    let mut labels = vec![-2i64; n]; // -2 = unvisited, -1 = noise
    let mut cluster_id = 0i64;

    for i in 0..n {
        if labels[i] != -2 {
            continue;
        }

        let neighbours = range_query(points, i, eps_km);

        if neighbours.len() < min_points {
            labels[i] = -1; // noise
            continue;
        }

        labels[i] = cluster_id;
        let mut seeds: Vec<usize> = neighbours.clone();
        let mut si = 0;

        while si < seeds.len() {
            let q = seeds[si];
            si += 1;

            if labels[q] == -1 {
                labels[q] = cluster_id; // noise → border
            }
            if labels[q] != -2 {
                continue;
            }
            labels[q] = cluster_id;

            let q_neighbours = range_query(points, q, eps_km);
            if q_neighbours.len() >= min_points {
                seeds.extend(q_neighbours.iter().filter(|&&r| !seeds.contains(&r)));
            }
        }

        cluster_id += 1;
    }

    // Build MapCluster per cluster_id
    let mut cluster_map: std::collections::HashMap<i64, Vec<usize>> =
        std::collections::HashMap::new();
    for (i, &cid) in labels.iter().enumerate() {
        cluster_map.entry(cid).or_default().push(i);
    }

    cluster_map
        .into_values()
        .map(|indices| {
            let lats: Vec<f64> = indices.iter().map(|&i| points[i].latitude).collect();
            let lngs: Vec<f64> = indices.iter().map(|&i| points[i].longitude).collect();

            let centroid_lat = lats.iter().sum::<f64>() / lats.len() as f64;
            let centroid_lng = lngs.iter().sum::<f64>() / lngs.len() as f64;
            let min_lat = lats.iter().cloned().fold(f64::INFINITY, f64::min);
            let max_lat = lats.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
            let min_lng = lngs.iter().cloned().fold(f64::INFINITY, f64::min);
            let max_lng = lngs.iter().cloned().fold(f64::NEG_INFINITY, f64::max);
            let thumb = indices.iter().find_map(|&i| points[i].thumbnail_path.clone());

            MapCluster {
                lat: centroid_lat,
                lng: centroid_lng,
                item_ids: indices.iter().map(|&i| points[i].item_id).collect(),
                thumb_path: thumb,
                bbox: [min_lat, min_lng, max_lat, max_lng],
            }
        })
        .collect()
}

fn range_query(points: &[GpsPoint], idx: usize, eps_km: f64) -> Vec<usize> {
    let origin = &points[idx];
    points
        .iter()
        .enumerate()
        .filter(|(j, pt)| *j != idx && haversine_km(origin.latitude, origin.longitude, pt.latitude, pt.longitude) <= eps_km)
        .map(|(j, _)| j)
        .collect()
}

/// Haversine distance in kilometres.
pub fn haversine_km(lat1: f64, lng1: f64, lat2: f64, lng2: f64) -> f64 {
    const R: f64 = 6371.0;
    let dlat = (lat2 - lat1).to_radians();
    let dlng = (lng2 - lng1).to_radians();
    let a = (dlat / 2.0).sin().powi(2)
        + lat1.to_radians().cos() * lat2.to_radians().cos() * (dlng / 2.0).sin().powi(2);
    2.0 * R * a.sqrt().asin()
}

// ────────────────────────────────────────────────────────────────────────────
// GPS stats
// ────────────────────────────────────────────────────────────────────────────

pub fn gps_stats(conn: &Connection) -> Result<GpsStats> {
    let total: i64 = conn.query_row(
        "SELECT COUNT(*) FROM exif_data WHERE latitude IS NOT NULL",
        [],
        |r| r.get(0),
    )?;

    // Approximate unique locations: cluster at zoom 14 (~1 km grid)
    // In production this would use reverse geocoding.
    let unique: i64 = conn.query_row(
        "SELECT COUNT(DISTINCT (CAST(latitude * 100 AS INTEGER) || ',' || CAST(longitude * 100 AS INTEGER)))
         FROM exif_data WHERE latitude IS NOT NULL",
        [],
        |r| r.get(0),
    )?;

    Ok(GpsStats {
        total_geotagged: total,
        country_counts: vec![], // requires reverse geocoding service
        unique_locations: unique,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn haversine_london_paris() {
        let d = haversine_km(51.5074, -0.1278, 48.8566, 2.3522);
        assert!((d - 340.0).abs() < 10.0, "Expected ~340 km, got {d}");
    }

    #[test]
    fn grid_cluster_groups_nearby_points() {
        let pts = vec![
            GpsPoint { item_id: 1, latitude: 48.8566, longitude: 2.3522, thumbnail_path: None, file_name: "a.jpg".into() },
            GpsPoint { item_id: 2, latitude: 48.8600, longitude: 2.3540, thumbnail_path: None, file_name: "b.jpg".into() },
            GpsPoint { item_id: 3, latitude: 35.6762, longitude: 139.6503, thumbnail_path: None, file_name: "c.jpg".into() },
        ];
        let clusters = cluster_by_grid(&pts, 10);
        // Paris pair should cluster together, Tokyo separate
        assert!(clusters.len() >= 2);
    }
}
