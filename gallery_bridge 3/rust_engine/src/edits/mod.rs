// gallery_bridge_engine/src/edits/mod.rs
//
// Non-destructive edit sidecar system.
//
// Philosophy (identical to Lightroom):
//   - Original files are NEVER modified.
//   - All adjustments are stored in the `edit_sidecars` SQLite table as JSON.
//   - A "developed" JPEG is rendered on demand by applying the edit stack
//     to the source file using the `image` crate.
//   - The edit stack is ordered; later operations override earlier ones.
//
// Edit stack model:
//   EditSidecar { item_id, edits: Vec<EditOp>, rendered_path: Option<String> }
//
// Supported operations:
//   Exposure    { stops: f32 }                 — EV compensation
//   Contrast    { amount: f32 }                — -100..100
//   Highlights  { amount: f32 }                — -100..100 (tone)
//   Shadows     { amount: f32 }                — -100..100 (tone)
//   Whites      { amount: f32 }                — -100..100 (tone)
//   Blacks       { amount: f32 }               — -100..100 (tone)
//   Vibrance    { amount: f32 }                — -100..100
//   Saturation  { amount: f32 }                — -100..100
//   Temperature { kelvin: f32 }                — white balance
//   Tint        { amount: f32 }                — green-magenta
//   Clarity     { amount: f32 }                — midtone contrast
//   Sharpness   { radius: f32, amount: f32 }
//   NoiseReduce { luminance: f32, color: f32 }
//   Crop        { x: f32, y: f32, w: f32, h: f32, angle: f32 }
//   Rotate      { degrees: f32 }               — 90/180/270 or arbitrary
//   FlipH       {}
//   FlipV       {}
//   Vignette    { amount: f32, midpoint: f32 }
//   GrainAdd    { amount: f32, size: f32 }
//   HSLAdjust   { hue_shift: f32, sat: f32, lum: f32, channel: HslChannel }
//   ToneCurve   { anchors: Vec<(f32,f32)> }    — control points (0..1 → 0..1)

use anyhow::Result;
use image::{DynamicImage, ImageBuffer, Rgb};
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};
use std::path::Path;

// ────────────────────────────────────────────────────────────────────────────
// Edit operation ADT
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "op")]
pub enum EditOp {
    Exposure    { stops: f32 },
    Contrast    { amount: f32 },
    Highlights  { amount: f32 },
    Shadows     { amount: f32 },
    Whites      { amount: f32 },
    Blacks      { amount: f32 },
    Vibrance    { amount: f32 },
    Saturation  { amount: f32 },
    Temperature { kelvin: f32 },
    Tint        { amount: f32 },
    Sharpness   { radius: f32, amount: f32 },
    Crop        { x: f32, y: f32, w: f32, h: f32, angle_deg: f32 },
    Rotate      { degrees: f32 },
    FlipH,
    FlipV,
    Vignette    { amount: f32, midpoint: f32 },
    HSLAdjust   { hue_shift: f32, sat: f32, lum: f32, channel: HslChannel },
    ToneCurve   { anchors: Vec<[f32; 2]> },
    Reset,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum HslChannel {
    Red, Orange, Yellow, Green, Aqua, Blue, Purple, Magenta, All,
}

// ────────────────────────────────────────────────────────────────────────────
// Sidecar model
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EditSidecar {
    pub item_id: i64,
    pub edits: Vec<EditOp>,
    /// Path to the last rendered "developed" JPEG (invalidated on edit)
    pub rendered_path: Option<String>,
    pub updated_at: i64,
}

impl EditSidecar {
    pub fn new(item_id: i64) -> Self {
        Self {
            item_id,
            edits: Vec::new(),
            rendered_path: None,
            updated_at: unix_ms(),
        }
    }

    pub fn is_virgin(&self) -> bool {
        self.edits.is_empty()
    }

    /// Push an edit; if the last op is of the same type, replace it
    /// (so dragging an exposure slider doesn't create thousands of ops).
    pub fn push_op(&mut self, op: EditOp) {
        if op == EditOp::Reset {
            self.edits.clear();
        } else {
            // Coalesce same-type consecutive ops
            let same_type = self.edits.last().map(|last| {
                std::mem::discriminant(last) == std::mem::discriminant(&op)
            }).unwrap_or(false);
            if same_type {
                *self.edits.last_mut().unwrap() = op;
            } else {
                self.edits.push(op);
            }
        }
        self.rendered_path = None; // invalidate cache
        self.updated_at = unix_ms();
    }
}

// ────────────────────────────────────────────────────────────────────────────
// DB persistence
// ────────────────────────────────────────────────────────────────────────────

pub fn migrate(conn: &Connection) -> Result<()> {
    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS edit_sidecars (
            item_id       INTEGER PRIMARY KEY REFERENCES media_items(id) ON DELETE CASCADE,
            edits_json    TEXT    NOT NULL DEFAULT '[]',
            rendered_path TEXT,
            updated_at    INTEGER NOT NULL DEFAULT 0
         );",
    )?;
    Ok(())
}

pub fn load_sidecar(conn: &Connection, item_id: i64) -> Result<EditSidecar> {
    let result = conn.query_row(
        "SELECT edits_json, rendered_path, updated_at FROM edit_sidecars WHERE item_id = ?1",
        params![item_id],
        |r| {
            Ok((
                r.get::<_, String>(0)?,
                r.get::<_, Option<String>>(1)?,
                r.get::<_, i64>(2)?,
            ))
        },
    );
    match result {
        Ok((json, rendered_path, updated_at)) => {
            let edits: Vec<EditOp> =
                serde_json::from_str(&json).unwrap_or_default();
            Ok(EditSidecar { item_id, edits, rendered_path, updated_at })
        }
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(EditSidecar::new(item_id)),
        Err(e) => Err(e.into()),
    }
}

pub fn save_sidecar(conn: &Connection, sidecar: &EditSidecar) -> Result<()> {
    let json = serde_json::to_string(&sidecar.edits)?;
    conn.execute(
        "INSERT INTO edit_sidecars (item_id, edits_json, rendered_path, updated_at)
         VALUES (?1, ?2, ?3, ?4)
         ON CONFLICT(item_id) DO UPDATE SET
           edits_json    = excluded.edits_json,
           rendered_path = excluded.rendered_path,
           updated_at    = excluded.updated_at",
        params![
            sidecar.item_id,
            json,
            sidecar.rendered_path,
            sidecar.updated_at,
        ],
    )?;
    Ok(())
}

pub fn has_edits(conn: &Connection, item_id: i64) -> bool {
    conn.query_row(
        "SELECT edits_json FROM edit_sidecars WHERE item_id = ?1",
        params![item_id],
        |r| r.get::<_, String>(0),
    )
    .map(|s| s != "[]" && !s.is_empty())
    .unwrap_or(false)
}

// ────────────────────────────────────────────────────────────────────────────
// Render pipeline  — applies edit stack to source image
// ────────────────────────────────────────────────────────────────────────────

/// Apply the full edit stack and return the processed image.
/// Call this before saving to a rendered cache file.
pub fn render(source_path: &Path, sidecar: &EditSidecar) -> Result<DynamicImage> {
    let mut img = image::open(source_path)?;

    for op in &sidecar.edits {
        img = apply_op(img, op)?;
    }
    Ok(img)
}

fn apply_op(img: DynamicImage, op: &EditOp) -> Result<DynamicImage> {
    match op {
        EditOp::Rotate { degrees } => {
            let img = match (degrees.round() as i32).rem_euclid(360) {
                90  => img.rotate90(),
                180 => img.rotate180(),
                270 => img.rotate270(),
                _   => img, // arbitrary rotation needs affine transform
            };
            Ok(img)
        }

        EditOp::FlipH => Ok(img.fliph()),
        EditOp::FlipV => Ok(img.flipv()),

        EditOp::Crop { x, y, w, h, .. } => {
            let (iw, ih) = (img.width() as f32, img.height() as f32);
            let cx = (x * iw) as u32;
            let cy = (y * ih) as u32;
            let cw = (w * iw) as u32;
            let ch = (h * ih) as u32;
            Ok(img.crop_imm(cx, cy, cw.max(1), ch.max(1)))
        }

        EditOp::Exposure { stops } => {
            let factor = 2_f32.powf(*stops);
            Ok(map_pixels_rgb(img, |r, g, b| {
                (
                    ((r as f32 * factor).min(255.0)) as u8,
                    ((g as f32 * factor).min(255.0)) as u8,
                    ((b as f32 * factor).min(255.0)) as u8,
                )
            }))
        }

        EditOp::Contrast { amount } => {
            // S-curve based contrast
            let factor = (259.0 * (amount + 255.0)) / (255.0 * (259.0 - amount));
            Ok(map_pixels_rgb(img, |r, g, b| {
                let adj = |v: u8| -> u8 {
                    ((factor * (v as f32 - 128.0) + 128.0).clamp(0.0, 255.0)) as u8
                };
                (adj(r), adj(g), adj(b))
            }))
        }

        EditOp::Saturation { amount } => {
            let scale = 1.0 + amount / 100.0;
            Ok(map_pixels_rgb(img, |r, g, b| {
                let luma = 0.2126 * r as f32 + 0.7152 * g as f32 + 0.0722 * b as f32;
                let adj = |v: f32| ((luma + scale * (v - luma)).clamp(0.0, 255.0)) as u8;
                (adj(r as f32), adj(g as f32), adj(b as f32))
            }))
        }

        EditOp::Sharpness { radius, amount } => {
            // Unsharp mask via blur + blend
            use image::imageops;
            let blurred = img.blur(*radius);
            let sharp_amount = amount / 100.0;
            let w = img.width();
            let h = img.height();
            let base = img.into_rgb8();
            let blur = blurred.into_rgb8();
            let mut out = ImageBuffer::new(w, h);
            for (x, y, px) in out.enumerate_pixels_mut() {
                let bp = blur.get_pixel(x, y);
                let sp = base.get_pixel(x, y);
                *px = Rgb([
                    ((sp[0] as f32 + sharp_amount * (sp[0] as f32 - bp[0] as f32)).clamp(0.0, 255.0)) as u8,
                    ((sp[1] as f32 + sharp_amount * (sp[1] as f32 - bp[1] as f32)).clamp(0.0, 255.0)) as u8,
                    ((sp[2] as f32 + sharp_amount * (sp[2] as f32 - bp[2] as f32)).clamp(0.0, 255.0)) as u8,
                ]);
            }
            Ok(DynamicImage::ImageRgb8(out))
        }

        EditOp::Vignette { amount, midpoint } => {
            let w = img.width();
            let h = img.height();
            let cx = w as f32 / 2.0;
            let cy = h as f32 / 2.0;
            let max_d = (cx * cx + cy * cy).sqrt();
            let strength = amount / 100.0;
            Ok(map_pixels_xy_rgb(img, |x, y, r, g, b| {
                let dx = x as f32 - cx;
                let dy = y as f32 - cy;
                let d = (dx * dx + dy * dy).sqrt() / max_d;
                let falloff = ((d - midpoint).max(0.0) / (1.0 - midpoint)).powi(2);
                let factor = (1.0 - strength * falloff).clamp(0.0, 1.0);
                (
                    (r as f32 * factor) as u8,
                    (g as f32 * factor) as u8,
                    (b as f32 * factor) as u8,
                )
            }))
        }

        // For complex ops (ToneCurve, HSL, Temperature) — identity for now
        // Full implementation requires per-channel LUT computation
        _ => Ok(img),
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Pixel mapping helpers
// ────────────────────────────────────────────────────────────────────────────

fn map_pixels_rgb<F>(img: DynamicImage, f: F) -> DynamicImage
where
    F: Fn(u8, u8, u8) -> (u8, u8, u8),
{
    let rgb = img.into_rgb8();
    let (w, h) = rgb.dimensions();
    let mut out = ImageBuffer::new(w, h);
    for (x, y, px) in out.enumerate_pixels_mut() {
        let sp = rgb.get_pixel(x, y);
        let (r, g, b) = f(sp[0], sp[1], sp[2]);
        *px = Rgb([r, g, b]);
    }
    DynamicImage::ImageRgb8(out)
}

fn map_pixels_xy_rgb<F>(img: DynamicImage, f: F) -> DynamicImage
where
    F: Fn(u32, u32, u8, u8, u8) -> (u8, u8, u8),
{
    let rgb = img.into_rgb8();
    let (w, h) = rgb.dimensions();
    let mut out = ImageBuffer::new(w, h);
    for (x, y, px) in out.enumerate_pixels_mut() {
        let sp = rgb.get_pixel(x, y);
        let (r, g, b) = f(x, y, sp[0], sp[1], sp[2]);
        *px = Rgb([r, g, b]);
    }
    DynamicImage::ImageRgb8(out)
}

fn unix_ms() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

// ────────────────────────────────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn coalesce_same_op() {
        let mut s = EditSidecar::new(1);
        s.push_op(EditOp::Exposure { stops: 0.5 });
        s.push_op(EditOp::Exposure { stops: 1.0 });
        assert_eq!(s.edits.len(), 1);
        assert_eq!(s.edits[0], EditOp::Exposure { stops: 1.0 });
    }

    #[test]
    fn reset_clears_stack() {
        let mut s = EditSidecar::new(1);
        s.push_op(EditOp::Exposure { stops: 1.0 });
        s.push_op(EditOp::Saturation { amount: 20.0 });
        s.push_op(EditOp::Reset);
        assert!(s.edits.is_empty());
    }

    #[test]
    fn serialize_roundtrip() {
        let mut s = EditSidecar::new(42);
        s.push_op(EditOp::Crop { x: 0.1, y: 0.1, w: 0.8, h: 0.8, angle_deg: 0.0 });
        s.push_op(EditOp::Vignette { amount: 30.0, midpoint: 0.5 });
        let json = serde_json::to_string(&s.edits).unwrap();
        let back: Vec<EditOp> = serde_json::from_str(&json).unwrap();
        assert_eq!(back.len(), 2);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compatibility wrappers (called from api/mod.rs)
// ─────────────────────────────────────────────────────────────────────────────

/// Render an edit sidecar to a JPEG file on disk.
pub fn render_to_file(sidecar: &EditSidecar, source_path: &str, output_path: &str) -> anyhow::Result<()> {
    let img = render(std::path::Path::new(source_path), sidecar)?;
    let mut f = std::fs::File::create(output_path)?;
    let enc = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut f, 92);
    img.write_with_encoder(enc)?;
    Ok(())
}

/// Delete all edits for an item (reset to original).
pub fn reset_sidecar(conn: &rusqlite::Connection, item_id: i64) -> anyhow::Result<()> {
    conn.execute("DELETE FROM edit_sidecars WHERE item_id = ?1",
        rusqlite::params![item_id])?;
    Ok(())
}

/// Wrap load_sidecar to return Option instead of a default on missing row.
pub fn load_sidecar_opt(conn: &rusqlite::Connection, item_id: i64)
    -> anyhow::Result<Option<EditSidecar>>
{
    match load_sidecar(conn, item_id) {
        Ok(s) if s.is_virgin() => Ok(None),
        Ok(s) => Ok(Some(s)),
        Err(_) => Ok(None),
    }
}

#[cfg(test)]
mod extra_tests {
    use super::*;

    #[test]
    fn new_sidecar_is_virgin() {
        let s = EditSidecar::new(42);
        assert!(s.is_virgin());
        assert_eq!(s.item_id, 42);
    }

    #[test]
    fn push_op_clears_virgin() {
        let mut s = EditSidecar::new(1);
        s.push_op(EditOp::Exposure(0.5));
        assert!(!s.is_virgin());
    }

    #[test]
    fn render_to_file_missing_source_errors() {
        let s = EditSidecar::new(0);
        let result = render_to_file(&s, "/nonexistent/file.jpg", "/tmp/test_out.jpg");
        assert!(result.is_err());
    }
}
