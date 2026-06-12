use roxmltree::Node;
use crate::models::color::{Color, ColorSpec, ThemeColor};

/// Parse a DrawingML color node (srgbClr, sysClr, schemeClr, prstClr, hslClr, scrgbClr).
pub fn parse_color_node(node: Node) -> Option<ColorSpec> {
    for child in node.children() {
        let tag = child.tag_name().name();
        match tag {
            "srgbClr" => {
                let val = child.attribute("val")?;
                let mut color = Color::from_hex(val)?;
                apply_color_transforms(&mut color, child);
                return Some(ColorSpec::Solid(color));
            }
            "sysClr" => {
                // System color with a last-color fallback
                let last_clr = child.attribute("lastClr").unwrap_or("000000");
                let mut color = Color::from_hex(last_clr).unwrap_or(Color::black());
                apply_color_transforms(&mut color, child);
                return Some(ColorSpec::Solid(color));
            }
            "schemeClr" => {
                let val = child.attribute("val").unwrap_or("").to_string();
                let mut tint = None;
                let mut shade = None;
                let mut lum_mod = None;
                let mut lum_off = None;
                for t in child.children() {
                    match t.tag_name().name() {
                        "tint" => tint = t.attribute("val").and_then(|v| v.parse::<f32>().ok()).map(|v| v / 100000.0),
                        "shade" => shade = t.attribute("val").and_then(|v| v.parse::<f32>().ok()).map(|v| v / 100000.0),
                        "lumMod" => lum_mod = t.attribute("val").and_then(|v| v.parse::<f32>().ok()).map(|v| v / 100000.0),
                        "lumOff" => lum_off = t.attribute("val").and_then(|v| v.parse::<f32>().ok()).map(|v| v / 100000.0),
                        _ => {}
                    }
                }
                return Some(ColorSpec::Theme(ThemeColor { theme: val, tint, shade, lum_mod, lum_off }));
            }
            "prstClr" => {
                let val = child.attribute("val").unwrap_or("black").to_string();
                return Some(ColorSpec::Preset(val));
            }
            "hslClr" => {
                // Convert HSL to RGB
                if let (Some(h), Some(s), Some(l)) = (
                    child.attribute("hue").and_then(|v| v.parse::<f64>().ok()),
                    child.attribute("sat").and_then(|v| v.parse::<f64>().ok()),
                    child.attribute("lum").and_then(|v| v.parse::<f64>().ok()),
                ) {
                    let color = hsl_to_rgb(h / 60000.0, s / 100000.0, l / 100000.0);
                    return Some(ColorSpec::Solid(color));
                }
            }
            "scrgbClr" => {
                // Percentage-based RGB (0-100000)
                if let (Some(r), Some(g), Some(b)) = (
                    child.attribute("r").and_then(|v| v.parse::<u32>().ok()),
                    child.attribute("g").and_then(|v| v.parse::<u32>().ok()),
                    child.attribute("b").and_then(|v| v.parse::<u32>().ok()),
                ) {
                    let color = Color::from_rgb(
                        (r * 255 / 100000) as u8,
                        (g * 255 / 100000) as u8,
                        (b * 255 / 100000) as u8,
                    );
                    return Some(ColorSpec::Solid(color));
                }
            }
            _ => {}
        }
    }
    None
}

/// Apply color transforms (tint, shade, lumMod, lumOff, alpha, etc.) in place.
fn apply_color_transforms(color: &mut Color, node: Node) {
    for child in node.children() {
        match child.tag_name().name() {
            "alpha" => {
                if let Some(val) = child.attribute("val").and_then(|v| v.parse::<u32>().ok()) {
                    color.a = (val * 255 / 100000) as u8;
                }
            }
            "tint" => {
                if let Some(val) = child.attribute("val").and_then(|v| v.parse::<f64>().ok()) {
                    let t = val / 100000.0;
                    color.r = ((color.r as f64 * t) + (255.0 * (1.0 - t))) as u8;
                    color.g = ((color.g as f64 * t) + (255.0 * (1.0 - t))) as u8;
                    color.b = ((color.b as f64 * t) + (255.0 * (1.0 - t))) as u8;
                }
            }
            "shade" => {
                if let Some(val) = child.attribute("val").and_then(|v| v.parse::<f64>().ok()) {
                    let s = val / 100000.0;
                    color.r = (color.r as f64 * s) as u8;
                    color.g = (color.g as f64 * s) as u8;
                    color.b = (color.b as f64 * s) as u8;
                }
            }
            _ => {}
        }
    }
}

/// Convert HSL (0-360, 0-1, 0-1) to RGB Color.
fn hsl_to_rgb(h: f64, s: f64, l: f64) -> Color {
    if s == 0.0 {
        let v = (l * 255.0) as u8;
        return Color::from_rgb(v, v, v);
    }
    let q = if l < 0.5 { l * (1.0 + s) } else { l + s - l * s };
    let p = 2.0 * l - q;
    Color::from_rgb(
        (hue_to_rgb(p, q, h + 1.0 / 3.0) * 255.0) as u8,
        (hue_to_rgb(p, q, h) * 255.0) as u8,
        (hue_to_rgb(p, q, h - 1.0 / 3.0) * 255.0) as u8,
    )
}

fn hue_to_rgb(p: f64, q: f64, mut t: f64) -> f64 {
    if t < 0.0 { t += 1.0; }
    if t > 1.0 { t -= 1.0; }
    if t < 1.0 / 6.0 { return p + (q - p) * 6.0 * t; }
    if t < 1.0 / 2.0 { return q; }
    if t < 2.0 / 3.0 { return p + (q - p) * (2.0 / 3.0 - t) * 6.0; }
    p
}
