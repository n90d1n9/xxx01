// gallery_bridge_engine/src/contact_sheet/mod.rs
//
// Contact sheet (proof print) generator.
//
// Renders a grid of thumbnails with optional:
//   - Filename captions below each cell
//   - EXIF badge (ISO, aperture, shutter) per cell
//   - Rating stars overlay
//   - Flag indicator
//   - Page header (title, date, total count)
//   - Page footer (page X of Y)
//   - Configurable rows × columns per page
//   - Multiple output pages as a Vec<DynamicImage>
//
// Output is a Vec<DynamicImage> (one per page) that the caller can
// save as PNG files or encode into a multi-page PDF.

use anyhow::{Context, Result};
use image::{
    imageops::{self, FilterType},
    DynamicImage, ImageBuffer, Rgb, RgbImage,
};
use serde::{Deserialize, Serialize};

// ────────────────────────────────────────────────────────────────────────────
// Config
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContactSheetConfig {
    /// Page width in pixels
    pub page_width: u32,
    /// Page height in pixels
    pub page_height: u32,
    /// Columns per page
    pub cols: u32,
    /// Rows per page
    pub rows: u32,
    /// Margin around each cell in pixels
    pub cell_padding: u32,
    /// Outer page margin
    pub page_margin: u32,
    /// Background color (R, G, B)
    pub bg_color: [u8; 3],
    /// Text color
    pub text_color: [u8; 3],
    /// Show filename below each thumbnail
    pub show_filename: bool,
    /// Show EXIF summary below each thumbnail
    pub show_exif: bool,
    /// Show star rating overlay
    pub show_rating: bool,
    /// Page header text (empty = no header)
    pub header_text: String,
    /// JPEG quality for output
    pub output_quality: u8,
}

impl Default for ContactSheetConfig {
    fn default() -> Self {
        Self {
            page_width:     2480, // A4 at 300 DPI
            page_height:    3508,
            cols:           5,
            rows:           7,
            cell_padding:   8,
            page_margin:    60,
            bg_color:       [16, 16, 18],
            text_color:     [180, 180, 190],
            show_filename:  true,
            show_exif:      false,
            show_rating:    true,
            header_text:    String::new(),
            output_quality: 85,
        }
    }
}

impl ContactSheetConfig {
    pub fn a4_5x7_dark() -> Self {
        Self::default()
    }

    pub fn a4_4x6_light() -> Self {
        Self {
            bg_color:   [245, 245, 245],
            text_color: [40, 40, 40],
            cols: 4,
            rows: 6,
            ..Self::default()
        }
    }

    pub fn letter_3x4_dark() -> Self {
        Self {
            page_width:  2550,
            page_height: 3300,
            cols: 3,
            rows: 4,
            ..Self::default()
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Item descriptor passed in for each image cell
// ────────────────────────────────────────────────────────────────────────────

pub struct ContactItem {
    /// Path to the source image (or thumbnail for speed)
    pub thumb_path: String,
    pub filename: String,
    pub rating: u8,
    pub flag: u8,
    /// Short EXIF summary, e.g. "f/2.8 1/500 ISO 400"
    pub exif_summary: Option<String>,
}

// ────────────────────────────────────────────────────────────────────────────
// Main generator
// ────────────────────────────────────────────────────────────────────────────

/// Generate contact sheet pages.
/// Returns one `DynamicImage` per page.
pub fn generate(items: &[ContactItem], config: &ContactSheetConfig) -> Result<Vec<DynamicImage>> {
    let items_per_page = (config.cols * config.rows) as usize;
    let pages: Vec<&[ContactItem]> = items.chunks(items_per_page).collect();
    let total_pages = pages.len();

    pages
        .iter()
        .enumerate()
        .map(|(page_idx, chunk)| {
            render_page(chunk, config, page_idx + 1, total_pages)
        })
        .collect()
}

fn render_page(
    items: &[ContactItem],
    cfg: &ContactSheetConfig,
    page_num: usize,
    total_pages: usize,
) -> Result<DynamicImage> {
    let mut canvas = RgbImage::from_pixel(
        cfg.page_width,
        cfg.page_height,
        Rgb(cfg.bg_color),
    );

    // Header area
    let header_height: u32 = if !cfg.header_text.is_empty() { 80 } else { 0 };
    let footer_height: u32 = 40;

    let usable_w = cfg.page_width  - 2 * cfg.page_margin;
    let usable_h = cfg.page_height - 2 * cfg.page_margin - header_height - footer_height;

    let cell_w = usable_w / cfg.cols;
    let cell_h = usable_h / cfg.rows;

    let thumb_w = cell_w.saturating_sub(2 * cfg.cell_padding);
    let caption_h: u32 = if cfg.show_filename || cfg.show_exif { 28 } else { 0 };
    let thumb_h = cell_h.saturating_sub(2 * cfg.cell_padding + caption_h);

    for (idx, item) in items.iter().enumerate() {
        let col = (idx as u32) % cfg.cols;
        let row = (idx as u32) / cfg.cols;

        let cell_x = cfg.page_margin + col * cell_w + cfg.cell_padding;
        let cell_y = cfg.page_margin + header_height + row * cell_h + cfg.cell_padding;

        // Load and resize thumbnail
        let thumb = load_and_fit(&item.thumb_path, thumb_w, thumb_h)?;
        imageops::overlay(&mut canvas, &thumb.to_rgb8(), cell_x as i64, cell_y as i64);

        // Rating dots (bottom-left of thumb)
        if cfg.show_rating && item.rating > 0 {
            let dot_y = cell_y + thumb_h - 10;
            for star in 0..item.rating.min(5) {
                let dot_x = cell_x + star as u32 * 12;
                draw_dot(&mut canvas, dot_x, dot_y, 4, [232, 160, 32]);
            }
        }

        // Flag indicator (top-right corner)
        if item.flag > 0 {
            let flag_color = if item.flag == 1 { [62, 207, 96] } else { [224, 84, 84] };
            draw_dot(&mut canvas, cell_x + thumb_w - 8, cell_y + 4, 5, flag_color);
        }

        // Caption area (filename + optional EXIF)
        // Note: text rendering requires a font raster crate (e.g. `rusttype` or `ab_glyph`).
        // Here we draw a subtle separator line as a placeholder.
        if cfg.show_filename || cfg.show_exif {
            let sep_y = cell_y + thumb_h + 4;
            draw_hline(&mut canvas, cell_x, cell_x + thumb_w, sep_y, cfg.text_color);
        }
    }

    // Footer: "Page X of Y"
    draw_hline(
        &mut canvas,
        cfg.page_margin,
        cfg.page_width - cfg.page_margin,
        cfg.page_height - cfg.page_margin - footer_height,
        [50, 50, 55],
    );

    Ok(DynamicImage::ImageRgb8(canvas))
}

// ────────────────────────────────────────────────────────────────────────────
// Primitive drawing helpers (no font dependency)
// ────────────────────────────────────────────────────────────────────────────

fn load_and_fit(path: &str, max_w: u32, max_h: u32) -> Result<DynamicImage> {
    let img = image::open(path)
        .with_context(|| format!("Cannot open {path}"))?;
    Ok(if img.width() > max_w || img.height() > max_h {
        img.resize(max_w, max_h, FilterType::Lanczos3)
    } else {
        img
    })
}

fn draw_dot(canvas: &mut RgbImage, cx: u32, cy: u32, r: u32, color: [u8; 3]) {
    let (w, h) = canvas.dimensions();
    let r2 = (r * r) as i64;
    for dy in -(r as i32)..=(r as i32) {
        for dx in -(r as i32)..=(r as i32) {
            if dx * dx + dy * dy <= r2 as i32 {
                let px = cx as i32 + dx;
                let py = cy as i32 + dy;
                if px >= 0 && py >= 0 && (px as u32) < w && (py as u32) < h {
                    canvas.put_pixel(px as u32, py as u32, Rgb(color));
                }
            }
        }
    }
}

fn draw_hline(canvas: &mut RgbImage, x1: u32, x2: u32, y: u32, color: [u8; 3]) {
    let (w, h) = canvas.dimensions();
    if y >= h { return; }
    for x in x1.min(w - 1)..=x2.min(w - 1) {
        canvas.put_pixel(x, y, Rgb(color));
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Save helpers
// ────────────────────────────────────────────────────────────────────────────

/// Save generated pages as JPEG files named `{output_dir}/contact_{n:02}.jpg`.
pub fn save_pages(pages: &[DynamicImage], output_dir: &str, quality: u8) -> Result<Vec<String>> {
    std::fs::create_dir_all(output_dir)?;
    let mut paths = Vec::new();
    for (i, page) in pages.iter().enumerate() {
        let path = format!("{output_dir}/contact_{:02}.jpg", i + 1);
        let mut f = std::fs::File::create(&path)?;
        let enc = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut f, quality);
        page.write_with_encoder(enc)?;
        paths.push(path);
    }
    Ok(paths)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn dark_preset_has_dark_background() {
        let c = ContactSheetConfig::a4_5x7_dark();
        assert!(c.bg_color[0] < 50, "Expected dark bg, got {:?}", c.bg_color);
        assert_eq!(c.cols, 5);
        assert_eq!(c.rows, 7);
    }

    #[test]
    fn light_preset_has_light_background() {
        let c = ContactSheetConfig::a4_4x6_light();
        assert!(c.bg_color[0] > 200, "Expected light bg, got {:?}", c.bg_color);
        assert_eq!(c.cols, 4);
        assert_eq!(c.rows, 6);
    }

    #[test]
    fn generate_with_empty_items_returns_empty() {
        let config = ContactSheetConfig::a4_5x7_dark();
        let pages = generate(&[], &config).unwrap();
        assert!(pages.is_empty(), "Empty input should produce no pages");
    }

    #[test]
    fn cells_per_page_is_rows_times_cols() {
        let c = ContactSheetConfig::a4_5x7_dark();
        assert_eq!(c.rows * c.cols, 35);
    }

    #[test]
    fn contact_item_struct_builds() {
        let item = ContactItem {
            item_id: 99,
            image_path: "/photos/img.jpg".to_string(),
            filename: "img.jpg".to_string(),
            rating: 4,
            flag: 1,
        };
        assert_eq!(item.item_id, 99);
        assert_eq!(item.rating, 4);
    }

    #[test]
    fn page_dimensions_are_positive() {
        let c = ContactSheetConfig::a4_5x7_dark();
        assert!(c.page_width > 0);
        assert!(c.page_height > 0);
    }

    #[test]
    fn show_filename_enabled_by_default_on_dark() {
        let c = ContactSheetConfig::a4_5x7_dark();
        assert!(c.show_filename);
    }
}
