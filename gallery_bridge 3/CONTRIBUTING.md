# Contributing to GalleryBridge

## Project layout

```
gallery_bridge/
├── rust_engine/          # Rust backend (flutter_rust_bridge plugin)
│   ├── src/
│   │   ├── api/          # FRB public surface — all Dart-callable functions
│   │   ├── analytics/    # Shot statistics, camera usage, heatmaps
│   │   ├── collections/  # Virtual albums (CRUD + ordering)
│   │   ├── contact_sheet/ # Multi-image contact sheet compositor
│   │   ├── db/           # SQLite schema, migrations, CRUD
│   │   ├── duplicate/    # dHash perceptual dedup + histogram
│   │   ├── edits/        # Non-destructive edit sidecars
│   │   ├── export/       # Batch resize/convert/watermark
│   │   ├── gps/          # GPS cluster engine (grid + DBSCAN)
│   │   ├── indexer/      # File-system walker + incremental rescan
│   │   ├── metadata/     # EXIF/IPTC extraction (kamadak-exif)
│   │   ├── print_layout/ # Print layout compositor (n-up, contact sheets)
│   │   ├── rename/       # Smart rename engine with token templates
│   │   ├── search/       # Multi-criteria advanced search builder
│   │   ├── slideshow/    # Slideshow sequencer + playlist
│   │   ├── thumbnail/    # 4-size JPEG cache with hash-based naming
│   │   ├── watcher/      # Live folder monitoring (notify crate)
│   │   └── xmp/          # XMP sidecar reader/writer
│   ├── benches/          # Criterion benchmarks
│   └── Cargo.toml
│
└── flutter_frontend/     # Flutter frontend (macOS / Windows / Linux / mobile)
    └── lib/
        ├── core/
        │   ├── bridge/   # GalleryBridge — stub wrapping FRB generated code
        │   ├── models/   # Dart-side DTOs mirroring all Rust structs
        │   ├── navigation/ # go_router configuration
        │   ├── providers/  # Riverpod state (folders, items, filters, indexing)
        │   └── undo/       # Command-pattern undo/redo system
        ├── features/
        │   ├── analytics/  # Charts dashboard
        │   ├── compare/    # A/B split-screen compare
        │   ├── detail/     # Lightbox + histogram panel
        │   ├── develop/    # Non-destructive edit panel
        │   ├── gallery/    # Main screen + all gallery widgets
        │   └── settings/   # Settings (General/Cache/Export/Shortcuts)
        └── shared/
            └── theme/      # AppTheme design tokens
```

## Setting up the dev environment

### Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Rust | ≥ 1.78 | `rustup update stable` |
| Flutter | ≥ 3.22 | `flutter upgrade` |
| flutter_rust_bridge_codegen | 2.x | `cargo install flutter_rust_bridge_codegen` |
| Xcode (macOS) | ≥ 15 | App Store |

### First-time setup

```bash
# 1. Clone
git clone https://github.com/your-org/gallery_bridge
cd gallery_bridge

# 2. Generate Dart bindings from Rust source
flutter_rust_bridge_codegen generate \
  --rust-input  rust_engine/src/api/mod.rs \
  --dart-output flutter_frontend/lib/generated/

# 3. Build Rust dylib (debug)
cd rust_engine
cargo build

# 4. Run Flutter app
cd ../flutter_frontend
flutter pub get
flutter run -d macos
```

### Running tests

```bash
# Rust unit tests
cd rust_engine && cargo test

# Flutter unit tests
cd flutter_frontend && flutter test

# Rust benchmarks
cd rust_engine && cargo bench
```

## Adding a new Rust module

1. Create `src/my_module/mod.rs`
2. Register it in `src/lib.rs`: `pub mod my_module;`
3. Add public functions to `src/api/mod.rs`
4. Re-run `flutter_rust_bridge_codegen generate`
5. Add a Dart wrapper method to `lib/core/bridge/gallery_bridge.dart`
6. Add the Dart DTO to `lib/core/models/gallery_models.dart`

## Code style

**Rust**: `cargo clippy --all-targets -- -D warnings` must pass clean.

**Dart/Flutter**: `flutter analyze` must pass with zero issues.

Both are enforced in CI.

## Performance budget

| Operation | Target |
|-----------|--------|
| Cold start (10K indexed items) | < 400 ms to first frame |
| Scroll 10K grid @ 60 fps | ✓ virtual list |
| EXIF extraction | < 1 ms/file |
| Thumbnail lookup (disk cache hit) | < 2 ms |
| Advanced search (10K items) | < 5 ms |
| dHash computation | < 15 ms/file |
