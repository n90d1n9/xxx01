# GalleryBridge

Adobe Bridge-inspired media gallery: **Rust engine** + **Flutter frontend**.

```
Flutter UI  ◄──flutter_rust_bridge──►  Rust Engine
(viewer)                                (indexer · thumbnails · EXIF · DB)
```

## What's included

| Layer | Files | Lines |
|-------|-------|-------|
| Rust engine (19 modules) | 20 `.rs` | ~7,200 |
| Flutter frontend (25 widgets) | 25 `.dart` | ~7,600 |
| **Total** | **45** | **~14,800** |

## Rust modules

`api` · `analytics` · `collections` · `contact_sheet` · `db` · `duplicate` · `edits` · `export` · `gps` · `indexer` · `metadata` · `print_layout` · `rename` · `search` · `slideshow` · `thumbnail` · `watcher` · `xmp`

## Flutter features

Grid/List/Filmstrip/Timeline/Map/Compare/Analytics views · Lightbox with histogram · Develop panel (non-destructive edits) · Rename dialog with live token preview · Slideshow player with Ken Burns · Batch export (JPEG/PNG/WebP) · XMP sidecar sync · Collections with drag-to-collect · Undo/redo history panel · Advanced search (20 dimensions) · Duplicate detection (dHash)

## Building

```bash
# 1. Generate Dart bindings
flutter_rust_bridge_codegen generate \
  --rust-input  rust_engine/src/api/mod.rs \
  --dart-output flutter_frontend/lib/generated/

# 2. Build Rust
cd rust_engine && cargo build --release

# 3. Run Flutter
cd ../flutter_frontend && flutter pub get && flutter run -d macos
```

See CONTRIBUTING.md for the full developer guide.
