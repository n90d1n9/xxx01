// gallery_bridge_engine/benches/indexer_bench.rs
//
// Criterion benchmarks for the indexer and thumbnail pipeline.
// Run with: cargo bench --bench indexer_bench

use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion};
use gallery_bridge_engine::duplicate::{compute_dhash, hamming_distance};
use gallery_bridge_engine::rename::{preview_rename, RenameConfig, RenameSource};
use std::path::Path;

// ─────────────────────────────────────────────────────────────────────────────
// dHash benchmarks
// ─────────────────────────────────────────────────────────────────────────────

fn bench_hamming(c: &mut Criterion) {
    let a = "a1b2c3d4e5f60718";
    let b = "b1c2d3e4f5067182";
    c.bench_function("hamming_distance", |bencher| {
        bencher.iter(|| hamming_distance(black_box(a), black_box(b)))
    });
}

// ─────────────────────────────────────────────────────────────────────────────
// Rename preview benchmarks
// ─────────────────────────────────────────────────────────────────────────────

fn bench_rename_preview(c: &mut Criterion) {
    let mut sources: Vec<RenameSource> = (0..100)
        .map(|i| RenameSource {
            item_id: i,
            current_path: format!("/photos/DSC_{:04}.jpg", i),
            exif_date: Some("2024:11:15 10:30:00".to_string()),
            camera_model: Some("Sony A7R IV".to_string()),
            iso: Some(400),
            focal_length: Some(35.0),
            rating: 4,
        })
        .collect();

    let config = RenameConfig {
        template: "{date}_{camera}_{seq:4}.{ext}".to_string(),
        seq_start: 1,
        seq_pad: 4,
        conflict: gallery_bridge_engine::rename::ConflictStrategy::Suffix,
        dry_run: true,
    };

    let mut group = c.benchmark_group("rename_preview");
    for size in [10, 50, 100].iter() {
        group.bench_with_input(
            BenchmarkId::new("items", size),
            size,
            |b, &s| {
                b.iter(|| preview_rename(black_box(&sources[..s]), black_box(&config)))
            },
        );
    }
    group.finish();
}

criterion_group!(benches, bench_hamming, bench_rename_preview);
criterion_main!(benches);
