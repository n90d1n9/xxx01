// gallery_bridge_engine/src/print_layout/mod.rs
//
// Print layout engine.
// Composes multiple images into print-ready layouts:
//   - Contact sheets  (4×5, 5×6, etc.)
//   - N-up layouts    (2-up, 4-up, 6-up, 9-up, 12-up)
//   - Album spreads   (full-bleed 2-page spreads)
//   - Proof sheets    (with EXIF data, rating, flags)
//
// Output: Vec<DynamicImage> (one per page), which the caller encodes
// to PNG/JPEG or hands to the pdf module.
//
// All coordinates are in pixels at the target DPI (default 300 DPI for print).

use anyhow::{Context, Result};
use image::{
    imageops::{self, FilterType},
    DynamicImage, Rgb, RgbImage,
};
use serde::{Deserialize, Serialize};

// ─────────────────────────────────────────────────────────────────────────────
// Layout types
// ─────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum LayoutTemplate {
    /// Even grid: rows × cols per page.
    Grid { rows: u32, cols: u32 },
    /// One large + several small thumbnails.
    HeroGrid { hero_fraction: f32, side_count: u32 },
    /// Full-bleed single image per page.
    FullBleed,
    /// Two-image spread across the page width.
    TwoUp,
    /// Custom cell definitions [(x_pct, y_pct, w_pct, h_pct)].
    Custom(Vec<(f32, f32, f32, f32)>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PaperSize {
    A4,          // 2480 × 3508 px at 300 DPI
    A3,          // 3508 × 4961 px
    Letter,      // 2550 × 3300 px
    FourBySix,   // 1200 × 1800 px
    EightByTen,  // 2400 × 3000 px
    Custom { width_px: u32, height_px: u32 },
}

impl PaperSize {
    pub fn dimensions_px(&self) -> (u32, u32) {
        match self {
            Self::A4          => (2480, 3508),
            Self::A3          => (3508, 4961),
            Self::Letter      => (2550, 3300),
            Self::FourBySix   => (1200, 1800),
            Self::EightByTen  => (2400, 3000),
            Self::Custom { width_px, height_px } => (*width_px, *height_px),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrintLayoutConfig {
    pub paper: PaperSize,
    pub layout: LayoutTemplate,
    /// Margin as fraction of page width (0.0–0.1).
    pub margin: f32,
    /// Gap between cells as fraction of cell width.
    pub gap: f32,
    /// Background colour (RGB).
    pub background: [u8; 3],
    /// Show filename below each cell.
    pub show_filename: bool,
    /// Show rating stars below each cell.
    pub show_rating: bool,
    /// Caption font size in pixels.
    pub caption_size_px: u32,
    /// Page header text (e.g. photographer name).
    pub header_text: String,
    /// Page footer text.
    pub footer_text: String,
}

impl Default for PrintLayoutConfig {
    fn default() -> Self {
        Self {
            paper: PaperSize::A4,
            layout: LayoutTemplate::Grid { rows: 4, cols: 5 },
            margin: 0.03,
            gap: 0.015,
            background: [245, 245, 245],
            show_filename: true,
            show_rating: true,
            caption_size_px: 24,
            header_text: String::new(),
            footer_text: String::new(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct PrintCell {
    pub item_id: i64,
    pub image_path: String,
    pub filename: String,
    pub rating: i64,
    pub flag: i64,
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout engine
// ─────────────────────────────────────────────────────────────────────────────

/// Lay out cells across pages. Returns one page image per page.
pub fn render_pages(
    cells: &[PrintCell],
    config: &PrintLayoutConfig,
) -> Result<Vec<DynamicImage>> {
    let (pw, ph) = config.paper.dimensions_px();
    let margin_px_x = (pw as f32 * config.margin) as u32;
    let margin_px_y = (ph as f32 * config.margin) as u32;

    let content_w = pw - 2 * margin_px_x;
    let content_h = ph - 2 * margin_px_y;

    // Reserve space for header + footer
    let header_h = if config.header_text.is_empty() { 0 } else { config.caption_size_px * 3 };
    let footer_h = if config.footer_text.is_empty() { 0 } else { config.caption_size_px * 2 };
    let caption_h = if config.show_filename || config.show_rating { config.caption_size_px + 8 } else { 0 };

    let grid_h = content_h.saturating_sub(header_h + footer_h);

    let cell_positions = compute_cell_positions(
        &config.layout, content_w, grid_h, config.gap, caption_h);

    let cells_per_page = cell_positions.len().max(1);
    let page_count = cells.len().div_ceil(cells_per_page);

    let mut pages = Vec::with_capacity(page_count);

    for page_idx in 0..page_count {
        let mut canvas = RgbImage::from_pixel(
            pw, ph,
            Rgb(config.background),
        );

        let page_cells = &cells[page_idx * cells_per_page ..
            ((page_idx + 1) * cells_per_page).min(cells.len())];

        for (cell_data, (cx, cy, cw, ch)) in page_cells.iter().zip(cell_positions.iter()) {
            let abs_x = margin_px_x + cx;
            let abs_y = margin_px_y + header_h + cy;

            // Load and resize thumbnail
            if let Ok(img) = image::open(&cell_data.image_path) {
                let resized = img.resize(*cw, *ch, FilterType::Lanczos3)
                    .into_rgb8();

                // Centre in cell
                let off_x = (cw.saturating_sub(resized.width())) / 2;
                let off_y = (ch.saturating_sub(resized.height())) / 2;

                imageops::replace(
                    &mut canvas,
                    &resized,
                    (abs_x + off_x) as i64,
                    (abs_y + off_y) as i64,
                );
            } else {
                // Placeholder grey box
                let placeholder = RgbImage::from_pixel(*cw, *ch, Rgb([200, 200, 200]));
                imageops::replace(&mut canvas, &placeholder, abs_x as i64, abs_y as i64);
            }

            // Caption (filename) — rendered as a light grey bar
            // In production use `imageproc` for text rendering.
            if config.show_filename && caption_h > 0 {
                let caption_bar = RgbImage::from_pixel(*cw, caption_h, Rgb([220, 220, 220]));
                imageops::replace(
                    &mut canvas,
                    &caption_bar,
                    abs_x as i64,
                    (abs_y + ch) as i64,
                );
            }
        }

        // Page number footer
        if !config.footer_text.is_empty() && footer_h > 0 {
            let footer_bar = RgbImage::from_pixel(
                content_w, footer_h, Rgb(config.background));
            imageops::replace(
                &mut canvas, &footer_bar,
                margin_px_x as i64,
                (ph - margin_px_y - footer_h) as i64,
            );
        }

        pages.push(DynamicImage::ImageRgb8(canvas));
    }

    Ok(pages)
}

/// Save rendered pages as individual JPEG files.
pub fn save_pages_as_jpeg(
    pages: &[DynamicImage],
    output_dir: &std::path::Path,
    base_name: &str,
    quality: u8,
) -> Result<Vec<String>> {
    std::fs::create_dir_all(output_dir)?;
    let mut paths = Vec::with_capacity(pages.len());

    for (i, page) in pages.iter().enumerate() {
        let filename = format!("{}_page{:03}.jpg", base_name, i + 1);
        let path = output_dir.join(&filename);
        let mut f = std::fs::File::create(&path)
            .with_context(|| format!("Cannot create {}", path.display()))?;
        let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut f, quality);
        page.write_with_encoder(encoder)?;
        paths.push(path.to_string_lossy().to_string());
    }

    Ok(paths)
}

// ─────────────────────────────────────────────────────────────────────────────
// Cell position computation
// ─────────────────────────────────────────────────────────────────────────────

/// Returns Vec of (x, y, w, h) pixel positions for each cell in a page.
fn compute_cell_positions(
    layout: &LayoutTemplate,
    content_w: u32,
    content_h: u32,
    gap_frac: f32,
    caption_h: u32,
) -> Vec<(u32, u32, u32, u32)> {
    match layout {
        LayoutTemplate::Grid { rows, cols } => {
            let gap_x = (content_w as f32 * gap_frac) as u32;
            let gap_y = (content_h as f32 * gap_frac) as u32;
            let total_gap_x = gap_x * (cols - 1);
            let total_gap_y = gap_y * (rows - 1);
            let cell_w = (content_w.saturating_sub(total_gap_x)) / cols;
            let cell_h_with_caption = (content_h.saturating_sub(total_gap_y)) / rows;
            let cell_h = cell_h_with_caption.saturating_sub(caption_h);

            let mut positions = Vec::with_capacity((*rows * *cols) as usize);
            for row in 0..*rows {
                for col in 0..*cols {
                    let x = col * (cell_w + gap_x);
                    let y = row * (cell_h + caption_h + gap_y);
                    positions.push((x, y, cell_w, cell_h));
                }
            }
            positions
        }

        LayoutTemplate::TwoUp => {
            let half_w = (content_w.saturating_sub(10)) / 2;
            vec![
                (0, 0, half_w, content_h),
                (half_w + 10, 0, half_w, content_h),
            ]
        }

        LayoutTemplate::FullBleed => {
            vec![(0, 0, content_w, content_h)]
        }

        LayoutTemplate::HeroGrid { hero_fraction, side_count } => {
            let hero_w = (content_w as f32 * hero_fraction) as u32;
            let side_w = content_w.saturating_sub(hero_w + 10);
            let side_h = if *side_count > 0 { content_h / *side_count } else { content_h };

            let mut positions = vec![(0u32, 0u32, hero_w, content_h)];
            for i in 0..*side_count {
                positions.push((hero_w + 10, i * side_h, side_w, side_h));
            }
            positions
        }

        LayoutTemplate::Custom(cells) => {
            cells.iter().map(|(xp, yp, wp, hp)| {
                let x = (xp * content_w as f32) as u32;
                let y = (yp * content_h as f32) as u32;
                let w = (wp * content_w as f32) as u32;
                let h = (hp * content_h as f32) as u32;
                (x, y, w, h)
            }).collect()
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Named layout presets
// ─────────────────────────────────────────────────────────────────────────────

pub fn preset_4x5_contact() -> PrintLayoutConfig {
    PrintLayoutConfig {
        paper: PaperSize::A4,
        layout: LayoutTemplate::Grid { rows: 4, cols: 5 },
        show_filename: true, show_rating: true,
        header_text: "Contact Sheet".to_string(),
        ..Default::default()
    }
}

pub fn preset_2up_print() -> PrintLayoutConfig {
    PrintLayoutConfig {
        paper: PaperSize::A4,
        layout: LayoutTemplate::TwoUp,
        show_filename: false, show_rating: false,
        ..Default::default()
    }
}

pub fn preset_hero_portfolio() -> PrintLayoutConfig {
    PrintLayoutConfig {
        paper: PaperSize::A4,
        layout: LayoutTemplate::HeroGrid { hero_fraction: 0.65, side_count: 3 },
        show_filename: false, show_rating: true,
        ..Default::default()
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn grid_positions_correct_count() {
        let positions = compute_cell_positions(
            &LayoutTemplate::Grid { rows: 4, cols: 5 },
            2480, 3308, 0.015, 30,
        );
        assert_eq!(positions.len(), 20);
    }

    #[test]
    fn two_up_gives_two_cells() {
        let positions = compute_cell_positions(
            &LayoutTemplate::TwoUp, 2480, 3308, 0.015, 0,
        );
        assert_eq!(positions.len(), 2);
    }

    #[test]
    fn a4_dimensions() {
        let (w, h) = PaperSize::A4.dimensions_px();
        assert_eq!(w, 2480);
        assert_eq!(h, 3508);
    }

    #[test]
    fn render_empty_pages_does_not_panic() {
        let config = PrintLayoutConfig::default();
        let pages = render_pages(&[], &config).unwrap();
        assert!(pages.is_empty());
    }
}
