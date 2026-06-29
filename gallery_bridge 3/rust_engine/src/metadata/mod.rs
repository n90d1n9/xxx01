// gallery_bridge_engine/src/metadata/mod.rs
//
// Extracts EXIF / IPTC / XMP metadata from image files.
// Uses kamadak-exif for structured EXIF parsing.

use crate::db::ExifData;
use anyhow::Result;
use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::path::Path;

/// Attempt to read EXIF data from an image file.
/// Returns `None` if the file has no EXIF data or the format is unsupported.
pub fn extract_exif(path: &Path) -> Result<Option<ExifData>> {
    let file = File::open(path)?;
    let mut reader = BufReader::new(file);

    let exif_result = exif::Reader::new().read_from_container(&mut reader);

    match exif_result {
        Err(_) => Ok(None),
        Ok(exif) => {
            let mut raw_map: HashMap<String, String> = HashMap::new();

            let mut camera_make: Option<String> = None;
            let mut camera_model: Option<String> = None;
            let mut lens: Option<String> = None;
            let mut iso: Option<i64> = None;
            let mut shutter_speed: Option<String> = None;
            let mut aperture: Option<f64> = None;
            let mut focal_length: Option<f64> = None;
            let mut flash: Option<bool> = None;
            let mut latitude: Option<f64> = None;
            let mut longitude: Option<f64> = None;
            let mut color_space: Option<String> = None;
            let mut exposure_mode: Option<String> = None;
            let mut white_balance: Option<String> = None;

            for field in exif.fields() {
                let tag_name = format!("{}", field.tag);
                let value_str = field.display_value().to_string();
                raw_map.insert(tag_name.clone(), value_str.clone());

                match field.tag {
                    exif::Tag::Make => camera_make = Some(clean_string(&value_str)),
                    exif::Tag::Model => camera_model = Some(clean_string(&value_str)),
                    exif::Tag::LensModel => lens = Some(clean_string(&value_str)),

                    exif::Tag::PhotographicSensitivity => {
                        iso = value_str.trim().parse::<i64>().ok();
                    }
                    exif::Tag::ISOSpeedRatings => {
                        if iso.is_none() {
                            iso = value_str.trim().parse::<i64>().ok();
                        }
                    }

                    exif::Tag::ExposureTime => {
                        shutter_speed = Some(value_str.trim().to_string());
                    }

                    exif::Tag::FNumber => {
                        aperture = parse_rational(&value_str);
                    }

                    exif::Tag::FocalLength => {
                        focal_length = parse_rational(&value_str);
                    }

                    exif::Tag::Flash => {
                        // Flash value is a bitmask; bit 0 = flash fired
                        flash = value_str
                            .trim()
                            .parse::<u64>()
                            .ok()
                            .map(|v| (v & 1) != 0);
                    }

                    exif::Tag::ColorSpace => {
                        color_space = Some(value_str.trim().to_string());
                    }

                    exif::Tag::ExposureMode => {
                        exposure_mode = Some(value_str.trim().to_string());
                    }

                    exif::Tag::WhiteBalance => {
                        white_balance = Some(value_str.trim().to_string());
                    }

                    exif::Tag::GPSLatitude => {
                        if let exif::Value::Rational(ref rationals) = field.value {
                            latitude = dms_to_decimal(rationals);
                        }
                    }

                    exif::Tag::GPSLongitude => {
                        if let exif::Value::Rational(ref rationals) = field.value {
                            longitude = dms_to_decimal(rationals);
                        }
                    }

                    exif::Tag::GPSLatitudeRef => {
                        if value_str.contains('S') || value_str.contains('s') {
                            latitude = latitude.map(|v| -v.abs());
                        }
                    }

                    exif::Tag::GPSLongitudeRef => {
                        if value_str.contains('W') || value_str.contains('w') {
                            longitude = longitude.map(|v| -v.abs());
                        }
                    }

                    _ => {}
                }
            }

            let raw_json = serde_json::to_string(&raw_map).unwrap_or_else(|_| "{}".to_string());

            Ok(Some(ExifData {
                item_id: 0, // caller must set this
                camera_make,
                camera_model,
                lens,
                iso,
                shutter_speed,
                aperture,
                focal_length,
                flash,
                latitude,
                longitude,
                color_space,
                exposure_mode,
                white_balance,
                raw_json,
            }))
        }
    }
}

/// Returns the EXIF DateTimeOriginal as Unix millis, if present.
pub fn extract_datetime_millis(path: &Path) -> Option<i64> {
    let file = File::open(path).ok()?;
    let mut reader = BufReader::new(file);
    let exif = exif::Reader::new().read_from_container(&mut reader).ok()?;

    let field = exif
        .get_field(exif::Tag::DateTimeOriginal, exif::In::PRIMARY)
        .or_else(|| exif.get_field(exif::Tag::DateTime, exif::In::PRIMARY))?;

    if let exif::Value::Ascii(ref vecs) = field.value {
        if let Some(bytes) = vecs.first() {
            let s = String::from_utf8_lossy(bytes);
            // Format: "YYYY:MM:DD HH:MM:SS"
            return parse_exif_datetime(&s);
        }
    }
    None
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

fn clean_string(s: &str) -> String {
    s.trim().trim_matches('"').trim_matches('\0').to_string()
}

fn parse_rational(s: &str) -> Option<f64> {
    // Rational displayed as "n/d" or already as decimal
    let s = s.trim();
    if let Some((n, d)) = s.split_once('/') {
        let n = n.trim().parse::<f64>().ok()?;
        let d = d.trim().parse::<f64>().ok()?;
        if d == 0.0 {
            return None;
        }
        Some(n / d)
    } else {
        s.parse::<f64>().ok()
    }
}

fn dms_to_decimal(rationals: &[exif::Rational]) -> Option<f64> {
    if rationals.len() < 3 {
        return None;
    }
    let deg = rationals[0].num as f64 / rationals[0].denom as f64;
    let min = rationals[1].num as f64 / rationals[1].denom as f64;
    let sec = rationals[2].num as f64 / rationals[2].denom as f64;
    Some(deg + min / 60.0 + sec / 3600.0)
}

fn parse_exif_datetime(s: &str) -> Option<i64> {
    // "YYYY:MM:DD HH:MM:SS"
    let parts: Vec<&str> = s.splitn(2, ' ').collect();
    if parts.len() != 2 {
        return None;
    }
    let date_parts: Vec<&str> = parts[0].split(':').collect();
    let time_parts: Vec<&str> = parts[1].split(':').collect();

    if date_parts.len() < 3 || time_parts.len() < 3 {
        return None;
    }

    let year: i32 = date_parts[0].parse().ok()?;
    let month: u32 = date_parts[1].parse().ok()?;
    let day: u32 = date_parts[2].parse().ok()?;
    let hour: u32 = time_parts[0].parse().ok()?;
    let min: u32 = time_parts[1].parse().ok()?;
    let sec: u32 = time_parts[2].trim_end_matches('\0').parse().ok()?;

    use chrono::{TimeZone, Utc};
    let dt = Utc.with_ymd_and_hms(year, month, day, hour, min, sec).single()?;
    Some(dt.timestamp_millis())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dms_to_decimal() {
        let rationals = vec![
            exif::Rational { num: 37, denom: 1 },
            exif::Rational { num: 30, denom: 1 },
            exif::Rational { num: 0,  denom: 1 },
        ];
        let result = dms_to_decimal(&rationals).unwrap();
        assert!((result - 37.5).abs() < 0.001);
    }

    #[test]
    fn test_parse_rational() {
        assert!((parse_rational("2/8").unwrap() - 0.25).abs() < 0.001);
        assert!((parse_rational("2.8").unwrap() - 2.8).abs() < 0.001);
    }
}
