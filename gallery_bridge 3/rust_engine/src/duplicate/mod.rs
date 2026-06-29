// gallery_bridge_engine/src/duplicate/mod.rs
//
// Perceptual duplicate detection.
//
// Algorithm: dHash (difference hash) — fast, rotation-insensitive enough for
// practical gallery use, produces a 64-bit fingerprint per image.
//
// Workflow:
//   1. compute_dhash()  — called per image during indexing
//   2. find_duplicates() — called on-demand, returns clusters of similar images
//   3. find_near_duplicates() — same but with a configurable Hamming distance threshold
//
// The hash is stored in the `media_items` table as `phash TEXT`.

use anyhow::Result;
use image::{imageops::FilterType, DynamicImage, GrayImage};
use std::path::Path;

// ────────────────────────────────────────────────────────────────────────────
// dHash implementation
// ────────────────────────────────────────────────────────────────────────────

/// Compute a 64-bit dHash fingerprint for an image file.
/// Returns the hash as a hex string (16 chars) or an error.
pub fn compute_dhash_for_file(path: &Path) -> Result<String> {
    let img = image::open(path)?;
    Ok(compute_dhash(&img))
}

/// Compute dHash from a decoded image.
/// Uses a 9×8 grid: resize to 9×8, compute left-right differences → 64 bits.
pub fn compute_dhash(img: &DynamicImage) -> String {
    // Resize to 9×8 (grayscale) — keep exact pixel comparisons cheap
    let small = img
        .resize_exact(9, 8, FilterType::Lanczos3)
        .into_luma8();

    let mut hash: u64 = 0;
    let mut bit: u64 = 1;

    for y in 0..8u32 {
        for x in 0..8u32 {
            let left  = small.get_pixel(x, y)[0] as i32;
            let right = small.get_pixel(x + 1, y)[0] as i32;
            if left > right {
                hash |= bit;
            }
            bit <<= 1;
        }
    }

    format!("{:016x}", hash)
}

/// Compute the Hamming distance between two hex-encoded dHash strings.
/// Lower = more similar. 0 = identical. Typical threshold for "near duplicate": ≤ 10.
pub fn hamming_distance(a: &str, b: &str) -> u32 {
    let av = u64::from_str_radix(a, 16).unwrap_or(0);
    let bv = u64::from_str_radix(b, 16).unwrap_or(0);
    (av ^ bv).count_ones()
}

// ────────────────────────────────────────────────────────────────────────────
// Cluster finding
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct DuplicateCluster {
    pub representative_id: i64,
    pub item_ids: Vec<i64>,
    pub max_distance: u32,
}

/// Find exact duplicates (same content hash) and near-duplicates (dHash distance ≤ threshold).
/// Returns clusters sorted by cluster size descending.
pub fn find_duplicate_clusters(
    items: &[(i64, String, Option<String>)], // (id, content_hash, phash)
    hamming_threshold: u32,
) -> Vec<DuplicateCluster> {
    let mut clusters: Vec<DuplicateCluster> = Vec::new();
    let mut visited = vec![false; items.len()];

    for i in 0..items.len() {
        if visited[i] {
            continue;
        }

        let (id_i, hash_i, phash_i) = &items[i];
        let mut cluster_ids = vec![*id_i];
        let mut max_dist = 0u32;

        for j in (i + 1)..items.len() {
            if visited[j] {
                continue;
            }

            let (id_j, hash_j, phash_j) = &items[j];

            // Exact content match
            let exact = hash_i == hash_j && !hash_i.is_empty();

            // Perceptual match
            let perceptual = match (phash_i.as_deref(), phash_j.as_deref()) {
                (Some(a), Some(b)) => {
                    let d = hamming_distance(a, b);
                    if d <= hamming_threshold {
                        max_dist = max_dist.max(d);
                        true
                    } else {
                        false
                    }
                }
                _ => false,
            };

            if exact || perceptual {
                cluster_ids.push(*id_j);
                visited[j] = true;
            }
        }

        if cluster_ids.len() > 1 {
            visited[i] = true;
            clusters.push(DuplicateCluster {
                representative_id: *id_i,
                item_ids: cluster_ids,
                max_distance: max_dist,
            });
        }
    }

    clusters.sort_by(|a, b| b.item_ids.len().cmp(&a.item_ids.len()));
    clusters
}

// ────────────────────────────────────────────────────────────────────────────
// Histogram (RGB + luminosity)  — used by the Flutter histogram widget
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct ChannelHistogram {
    /// 256 buckets, each bucket is a count (normalised 0.0–1.0)
    pub r: Vec<f32>,
    pub g: Vec<f32>,
    pub b: Vec<f32>,
    pub luma: Vec<f32>,
}

/// Compute an RGB + luminosity histogram for an image file.
/// The `thumb_path` is preferred over the full source to keep this fast.
pub fn compute_histogram(path: &Path) -> Result<ChannelHistogram> {
    let img = image::open(path)?.into_rgb8();
    let (w, h) = img.dimensions();
    let total = (w * h) as f32;

    let mut r = vec![0u32; 256];
    let mut g = vec![0u32; 256];
    let mut b = vec![0u32; 256];
    let mut luma = vec![0u32; 256];

    for pixel in img.pixels() {
        let rv = pixel[0] as usize;
        let gv = pixel[1] as usize;
        let bv = pixel[2] as usize;
        // BT.709 luminance
        let lv = (0.2126 * rv as f32 + 0.7152 * gv as f32 + 0.0722 * bv as f32) as usize;
        r[rv]    += 1;
        g[gv]    += 1;
        b[bv]    += 1;
        luma[lv] += 1;
    }

    let norm = |v: Vec<u32>| -> Vec<f32> {
        let max = *v.iter().max().unwrap_or(&1) as f32;
        v.iter().map(|&c| c as f32 / max).collect()
    };

    Ok(ChannelHistogram {
        r:    norm(r),
        g:    norm(g),
        b:    norm(b),
        luma: norm(luma),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hamming_same_hash_is_zero() {
        let h = "a1b2c3d4e5f60718";
        assert_eq!(hamming_distance(h, h), 0);
    }

    #[test]
    fn hamming_all_bits_differ() {
        assert_eq!(hamming_distance("0000000000000000", "ffffffffffffffff"), 64);
    }

    #[test]
    fn cluster_exact_duplicates() {
        let items = vec![
            (1, "aabbcc".to_string(), None),
            (2, "aabbcc".to_string(), None),
            (3, "112233".to_string(), None),
        ];
        let clusters = find_duplicate_clusters(&items, 5);
        assert_eq!(clusters.len(), 1);
        assert_eq!(clusters[0].item_ids.len(), 2);
    }
}
