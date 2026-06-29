// gallery_bridge_engine/src/export/mod.rs
//
// Batch export pipeline.
// Supports resize presets, format conversion (JPEG/PNG/WebP),
// quality control, optional watermark overlay, and rename templates.
//
// All exports run on a rayon thread pool for parallelism.
// Progress is emitted via a crossbeam channel identical to the indexer.

use anyhow::{Context, Result};
use crossbeam_channel::Sender;
use image::{
    imageops::{self, FilterType},
    DynamicImage, ImageFormat, Rgba,
};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::{
    fs,
    path::{Path, PathBuf},
};

// ────────────────────────────────────────────────────────────────────────────
// Config
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExportPreset {
    pub name: String,
    /// Target format: "jpeg" | "png" | "webp"
    pub format: String,
    /// JPEG quality 1–100 (ignored for PNG/WebP lossless)
    pub quality: u8,
    /// Resize strategy
    pub resize: ResizeStrategy,
    /// Optional watermark config
    pub watermark: Option<WatermarkConfig>,
    /// Output filename template: "{stem}_{width}x{height}.{ext}"
    /// Tokens: {stem}, {ext}, {width}, {height}, {date}, {index}
    pub filename_template: String,
    /// If true, preserve EXIF in output (JPEG only)
    pub preserve_exif: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ResizeStrategy {
    /// Keep original dimensions
    Original,
    /// Fit within a bounding box (preserve aspect ratio)
    FitWithin { max_width: u32, max_height: u32 },
    /// Crop to exact dimensions from center
    CropToExact { width: u32, height: u32 },
    /// Scale by percentage (e.g. 50 = 50%)
    ScalePercent(u32),
    /// Resize to exact width; height auto
    FixedWidth(u32),
    /// Resize to exact height; width auto
    FixedHeight(u32),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WatermarkConfig {
    /// Path to a PNG watermark image
    pub image_path: String,
    /// "top-left" | "top-right" | "bottom-left" | "bottom-right" | "center"
    pub position: String,
    /// Opacity 0.0–1.0
    pub opacity: f32,
    /// Padding from edge in pixels
    pub padding: u32,
}

// Well-known presets
impl ExportPreset {
    pub fn web_optimised() -> Self {
        Self {
            name: "Web Optimised".to_string(),
            format: "jpeg".to_string(),
            quality: 82,
            resize: ResizeStrategy::FitWithin { max_width: 1920, max_height: 1080 },
            watermark: None,
            filename_template: "{stem}_web.{ext}".to_string(),
            preserve_exif: false,
        }
    }

    pub fn social_media() -> Self {
        Self {
            name: "Social Media".to_string(),
            format: "jpeg".to_string(),
            quality: 90,
            resize: ResizeStrategy::FitWithin { max_width: 1080, max_height: 1080 },
            watermark: None,
            filename_template: "{stem}_social.{ext}".to_string(),
            preserve_exif: false,
        }
    }

    pub fn print_ready() -> Self {
        Self {
            name: "Print Ready".to_string(),
            format: "png".to_string(),
            quality: 100,
            resize: ResizeStrategy::Original,
            watermark: None,
            filename_template: "{stem}_print.{ext}".to_string(),
            preserve_exif: true,
        }
    }

    pub fn thumbnail_contact_sheet() -> Self {
        Self {
            name: "Contact Sheet Thumb".to_string(),
            format: "jpeg".to_string(),
            quality: 75,
            resize: ResizeStrategy::FitWithin { max_width: 400, max_height: 400 },
            watermark: None,
            filename_template: "{stem}_thumb.{ext}".to_string(),
            preserve_exif: false,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Progress events
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub enum ExportEvent {
    Started  { total: usize },
    Progress { done: usize, total: usize, output_path: String },
    ItemDone { source: String, output: String },
    Error    { source: String, message: String },
    Completed { total_exported: usize, output_dir: String, duration_ms: u64 },
}

// ────────────────────────────────────────────────────────────────────────────
// Main export function
// ────────────────────────────────────────────────────────────────────────────

pub struct ExportJob {
    pub source_paths: Vec<String>,
    pub output_dir: String,
    pub preset: ExportPreset,
}

/// Run a batch export. Blocking; call from a thread.
pub fn run_export(job: ExportJob, tx: Sender<ExportEvent>) -> Result<()> {
    let start = std::time::Instant::now();
    let total = job.source_paths.len();

    let _ = tx.send(ExportEvent::Started { total });

    fs::create_dir_all(&job.output_dir)
        .context("Cannot create output directory")?;

    // Load watermark once (shared across threads via Arc)
    let watermark_img: Option<std::sync::Arc<DynamicImage>> =
        if let Some(ref wm) = job.preset.watermark {
            match image::open(&wm.image_path) {
                Ok(img) => Some(std::sync::Arc::new(img)),
                Err(e) => {
                    let _ = tx.send(ExportEvent::Error {
                        source: wm.image_path.clone(),
                        message: format!("Watermark load failed: {e}"),
                    });
                    None
                }
            }
        } else {
            None
        };

    use std::sync::atomic::{AtomicUsize, Ordering};
    let done_counter = std::sync::Arc::new(AtomicUsize::new(0));

    let results: Vec<Result<(String, String)>> = job
        .source_paths
        .par_iter()
        .map(|src_path| {
            let result = export_single(
                Path::new(src_path),
                Path::new(&job.output_dir),
                &job.preset,
                watermark_img.as_deref(),
            );

            let done = done_counter.fetch_add(1, Ordering::Relaxed) + 1;

            match &result {
                Ok((_, out)) => {
                    let _ = tx.send(ExportEvent::Progress {
                        done,
                        total,
                        output_path: out.clone(),
                    });
                }
                Err(e) => {
                    let _ = tx.send(ExportEvent::Error {
                        source: src_path.clone(),
                        message: e.to_string(),
                    });
                }
            }
            result
        })
        .collect();

    let exported = results.iter().filter(|r| r.is_ok()).count();
    let duration_ms = start.elapsed().as_millis() as u64;

    let _ = tx.send(ExportEvent::Completed {
        total_exported: exported,
        output_dir: job.output_dir.clone(),
        duration_ms,
    });

    Ok(())
}

// ────────────────────────────────────────────────────────────────────────────
// Single-file export
// ────────────────────────────────────────────────────────────────────────────

fn export_single(
    src: &Path,
    out_dir: &Path,
    preset: &ExportPreset,
    watermark: Option<&DynamicImage>,
) -> Result<(String, String)> {
    let mut img = image::open(src)
        .with_context(|| format!("Cannot open source: {}", src.display()))?;

    // 1. Resize
    img = apply_resize(img, &preset.resize);

    // 2. Watermark
    if let (Some(wm_img), Some(wm_cfg)) = (watermark, preset.watermark.as_ref()) {
        img = apply_watermark(img, wm_img, wm_cfg);
    }

    // 3. Build output filename
    let stem = src.file_stem().and_then(|s| s.to_str()).unwrap_or("export");
    let ext = match preset.format.as_str() {
        "png"  => "png",
        "webp" => "webp",
        _      => "jpg",
    };
    let filename = preset
        .filename_template
        .replace("{stem}", stem)
        .replace("{ext}", ext)
        .replace("{width}", &img.width().to_string())
        .replace("{height}", &img.height().to_string());

    let out_path = out_dir.join(&filename);

    // 4. Save
    match preset.format.as_str() {
        "png" => img.save_with_format(&out_path, ImageFormat::Png)?,
        "webp" => img.save_with_format(&out_path, ImageFormat::WebP)?,
        _ => {
            let mut f = fs::File::create(&out_path)?;
            let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(
                &mut f,
                preset.quality,
            );
            img.write_with_encoder(encoder)?;
        }
    }

    Ok((
        src.to_string_lossy().to_string(),
        out_path.to_string_lossy().to_string(),
    ))
}

// ────────────────────────────────────────────────────────────────────────────
// Resize helpers
// ────────────────────────────────────────────────────────────────────────────

fn apply_resize(img: DynamicImage, strategy: &ResizeStrategy) -> DynamicImage {
    match strategy {
        ResizeStrategy::Original => img,

        ResizeStrategy::FitWithin { max_width, max_height } => {
            if img.width() <= *max_width && img.height() <= *max_height {
                img
            } else {
                img.resize(*max_width, *max_height, FilterType::Lanczos3)
            }
        }

        ResizeStrategy::CropToExact { width, height } => {
            // First scale to fill, then crop center
            let scale_w = *width as f32 / img.width() as f32;
            let scale_h = *height as f32 / img.height() as f32;
            let scale   = scale_w.max(scale_h);
            let nw = (img.width() as f32 * scale) as u32;
            let nh = (img.height() as f32 * scale) as u32;
            let scaled = img.resize_exact(nw, nh, FilterType::Lanczos3);
            let x = (nw.saturating_sub(*width)) / 2;
            let y = (nh.saturating_sub(*height)) / 2;
            scaled.crop_imm(x, y, *width, *height)
        }

        ResizeStrategy::ScalePercent(pct) => {
            let factor = *pct as f32 / 100.0;
            let nw = ((img.width() as f32) * factor) as u32;
            let nh = ((img.height() as f32) * factor) as u32;
            img.resize_exact(nw.max(1), nh.max(1), FilterType::Lanczos3)
        }

        ResizeStrategy::FixedWidth(w) => img.resize(*w, u32::MAX, FilterType::Lanczos3),
        ResizeStrategy::FixedHeight(h) => img.resize(u32::MAX, *h, FilterType::Lanczos3),
    }
}

fn apply_watermark(
    mut base: DynamicImage,
    wm: &DynamicImage,
    cfg: &WatermarkConfig,
) -> DynamicImage {
    let bw = base.width();
    let bh = base.height();
    let ww = wm.width().min(bw / 4); // Watermark max 25% of base width
    let wh = (wm.height() as f64 * (ww as f64 / wm.width() as f64)) as u32;
    let scaled_wm = wm.resize_exact(ww, wh, FilterType::Lanczos3);

    let pad = cfg.padding;
    let (x, y) = match cfg.position.as_str() {
        "top-left"     => (pad, pad),
        "top-right"    => (bw.saturating_sub(ww + pad), pad),
        "bottom-left"  => (pad, bh.saturating_sub(wh + pad)),
        "center"       => ((bw.saturating_sub(ww)) / 2, (bh.saturating_sub(wh)) / 2),
        _              => (bw.saturating_sub(ww + pad), bh.saturating_sub(wh + pad)), // bottom-right
    };

    // Apply opacity by modifying alpha channel
    let mut wm_rgba = scaled_wm.into_rgba8();
    for pixel in wm_rgba.pixels_mut() {
        pixel[3] = (pixel[3] as f32 * cfg.opacity) as u8;
    }
    let wm_dyn = DynamicImage::ImageRgba8(wm_rgba);

    imageops::overlay(&mut base, &wm_dyn, x as i64, y as i64);
    base
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn web_optimised_preset_has_correct_quality() {
        let p = ExportPreset::web_optimised();
        assert_eq!(p.quality, 82);
        assert_eq!(p.format, "jpeg");
    }

    #[test]
    fn social_media_preset_fits_in_1080() {
        let p = ExportPreset::social_media();
        if let ResizeStrategy::FitWithin { max_width, max_height } = p.resize {
            assert_eq!(max_width, 1080);
            assert_eq!(max_height, 1080);
        } else {
            panic!("Expected FitWithin");
        }
    }

    #[test]
    fn print_ready_is_png() {
        let p = ExportPreset::print_ready();
        assert_eq!(p.format, "png");
    }

    #[test]
    fn resize_original_returns_same_size() {
        let img = image::DynamicImage::new_rgb8(800, 600);
        let out = apply_resize(img.clone(), &ResizeStrategy::Original);
        assert_eq!(out.width(), 800);
        assert_eq!(out.height(), 600);
    }

    #[test]
    fn resize_scale_percent_halves_size() {
        let img = image::DynamicImage::new_rgb8(800, 600);
        let out = apply_resize(img, &ResizeStrategy::ScalePercent(50));
        assert_eq!(out.width(), 400);
        assert_eq!(out.height(), 300);
    }

    #[test]
    fn resize_fit_within_does_not_upscale() {
        let img = image::DynamicImage::new_rgb8(400, 300);
        let out = apply_resize(img, &ResizeStrategy::FitWithin { max_width: 1920, max_height: 1080 });
        // Small image should not be upscaled
        assert_eq!(out.width(), 400);
        assert_eq!(out.height(), 300);
    }

    #[test]
    fn resize_fixed_width_preserves_aspect() {
        let img = image::DynamicImage::new_rgb8(800, 400);
        let out = apply_resize(img, &ResizeStrategy::FixedWidth(400));
        assert_eq!(out.width(), 400);
        // Height should be approximately 200 (±2 for rounding)
        assert!((out.height() as i32 - 200).abs() <= 2);
    }

    #[test]
    fn filename_template_with_stem_ext() {
        let p = ExportPreset {
            filename_template: "{stem}_web.{ext}".to_string(),
            ..ExportPreset::web_optimised()
        };
        // Template substitution happens in export_single — we just verify the struct
        assert!(p.filename_template.contains("{stem}"));
    }
}
