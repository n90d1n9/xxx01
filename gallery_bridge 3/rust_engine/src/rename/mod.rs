// gallery_bridge_engine/src/rename/mod.rs
//
// Smart rename engine.
//
// Template tokens:
//   {name}        — original filename stem
//   {ext}         — original extension (lowercase)
//   {date}        — EXIF DateTimeOriginal as YYYY-MM-DD
//   {year}        — 4-digit year from EXIF
//   {month}       — 2-digit month from EXIF
//   {day}         — 2-digit day from EXIF
//   {time}        — HH-MM-SS from EXIF
//   {camera}      — camera model (spaces → underscores)
//   {iso}         — ISO value
//   {focal}       — focal length in mm (no decimals)
//   {seq}         — 1-based sequence number, zero-padded to width
//   {seq:4}       — sequence padded to 4 digits
//   {rating}      — star rating 0-5
//   {folder}      — parent folder name
//
// Example template: "{date}_{camera}_{seq:4}.{ext}"
// → "2024-11-15_Sony_A7R_IV_0001.jpg"
//
// Conflict strategies:
//   Skip      — leave conflicting file unchanged
//   Overwrite — replace existing file
//   Suffix    — append _2, _3 … until unique

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::path::{Path, PathBuf};

// ────────────────────────────────────────────────────────────────────────────
// Config
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenameConfig {
    /// Filename template string.
    pub template: String,
    /// Starting sequence number (default 1).
    pub seq_start: u64,
    /// Sequence padding width (default 4).
    pub seq_pad: usize,
    /// What to do when the output path already exists.
    pub conflict: ConflictStrategy,
    /// If true, compute new names but don't touch the filesystem.
    pub dry_run: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ConflictStrategy {
    Skip,
    Overwrite,
    Suffix,
}

impl Default for RenameConfig {
    fn default() -> Self {
        Self {
            template: "{date}_{name}.{ext}".to_string(),
            seq_start: 1,
            seq_pad: 4,
            conflict: ConflictStrategy::Suffix,
            dry_run: true,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Input / Output
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenameSource {
    pub item_id: i64,
    pub current_path: String,
    // EXIF fields (loaded by caller)
    pub exif_date: Option<String>,       // "2024:11:15 10:30:00"
    pub camera_model: Option<String>,
    pub iso: Option<i64>,
    pub focal_length: Option<f64>,
    pub rating: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenamePreview {
    pub item_id: i64,
    pub old_name: String,
    pub new_name: String,
    pub new_path: String,
    pub conflict: bool,
    pub action: RenameAction,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RenameAction {
    Rename,
    Skip,
    Overwrite,
    AddSuffix(String),
}

// ────────────────────────────────────────────────────────────────────────────
// Preview (dry-run)
// ────────────────────────────────────────────────────────────────────────────

/// Compute the rename preview for a batch of sources.
/// Does NOT touch the filesystem regardless of `config.dry_run`.
pub fn preview_rename(
    sources: &[RenameSource],
    config: &RenameConfig,
) -> Vec<RenamePreview> {
    let mut previews = Vec::with_capacity(sources.len());
    let mut seen_names: HashSet<String> = HashSet::new();

    for (idx, src) in sources.iter().enumerate() {
        let seq = config.seq_start + idx as u64;
        let raw_name = apply_template(&config.template, src, seq, config.seq_pad);
        let dir = Path::new(&src.current_path)
            .parent()
            .unwrap_or(Path::new(""))
            .to_string_lossy()
            .to_string();

        let old_name = Path::new(&src.current_path)
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .to_string();

        let (final_name, action) = resolve_conflict(
            &raw_name,
            &dir,
            &config.conflict,
            &mut seen_names,
        );

        let new_path = format!("{}/{}", dir, final_name);
        let conflict = std::path::Path::new(&new_path).exists();

        previews.push(RenamePreview {
            item_id: src.item_id,
            old_name,
            new_name: final_name,
            new_path,
            conflict,
            action,
        });
    }

    previews
}

// ────────────────────────────────────────────────────────────────────────────
// Execute renames
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RenameResult {
    pub item_id: i64,
    pub old_path: String,
    pub new_path: String,
    pub success: bool,
    pub error: Option<String>,
}

/// Execute the renames described by the preview list.
/// Returns one result per item.
pub fn execute_renames(
    sources: &[RenameSource],
    previews: &[RenamePreview],
) -> Vec<RenameResult> {
    assert_eq!(sources.len(), previews.len());

    let mut results = Vec::with_capacity(sources.len());

    for (src, preview) in sources.iter().zip(previews.iter()) {
        if preview.action == RenameAction::Skip {
            results.push(RenameResult {
                item_id: src.item_id,
                old_path: src.current_path.clone(),
                new_path: preview.new_path.clone(),
                success: false,
                error: Some("Skipped (conflict)".to_string()),
            });
            continue;
        }

        let result = std::fs::rename(&src.current_path, &preview.new_path);
        results.push(RenameResult {
            item_id: src.item_id,
            old_path: src.current_path.clone(),
            new_path: preview.new_path.clone(),
            success: result.is_ok(),
            error: result.err().map(|e| e.to_string()),
        });
    }

    results
}

// ────────────────────────────────────────────────────────────────────────────
// Template engine
// ────────────────────────────────────────────────────────────────────────────

fn apply_template(
    template: &str,
    src: &RenameSource,
    seq: u64,
    default_pad: usize,
) -> String {
    let path = Path::new(&src.current_path);
    let stem = path.file_stem().and_then(|s| s.to_str()).unwrap_or("file");
    let ext  = path.extension().and_then(|e| e.to_str()).unwrap_or("jpg").to_lowercase();

    // Parse EXIF date "YYYY:MM:DD HH:MM:SS"
    let (date, year, month, day, time) = parse_exif_date(src.exif_date.as_deref());

    let camera = src
        .camera_model
        .as_deref()
        .unwrap_or("Unknown")
        .replace(' ', "_")
        .replace('/', "_");

    let iso = src.iso.map(|v| v.to_string()).unwrap_or_else(|| "0".to_string());
    let focal = src.focal_length
        .map(|f| format!("{:.0}mm", f))
        .unwrap_or_else(|| "0mm".to_string());

    // Handle {seq} and {seq:N} tokens
    let template = regex_replace_seq(template, seq, default_pad);

    template
        .replace("{name}", stem)
        .replace("{ext}", &ext)
        .replace("{date}", &date)
        .replace("{year}", &year)
        .replace("{month}", &month)
        .replace("{day}", &day)
        .replace("{time}", &time)
        .replace("{camera}", &camera)
        .replace("{iso}", &iso)
        .replace("{focal}", &focal)
        .replace("{rating}", &src.rating.to_string())
        .replace("{folder}", path.parent()
            .and_then(|p| p.file_name())
            .and_then(|n| n.to_str())
            .unwrap_or(""))
}

fn regex_replace_seq(template: &str, seq: u64, default_pad: usize) -> String {
    // Replace {seq:N} with zero-padded sequence number
    // Replace {seq} with default-padded sequence number
    let mut result = template.to_string();

    // Handle {seq:N} variants
    while let Some(start) = result.find("{seq:") {
        let end = result[start..].find('}').map(|e| start + e);
        if let Some(end) = end {
            let token = &result[start..=end];
            let n: usize = result[start + 5..end]
                .parse()
                .unwrap_or(default_pad);
            let padded = format!("{:0>width$}", seq, width = n);
            result = result.replacen(token, &padded, 1);
        } else {
            break;
        }
    }

    // Handle plain {seq}
    let padded = format!("{:0>width$}", seq, width = default_pad);
    result.replace("{seq}", &padded)
}

fn parse_exif_date(s: Option<&str>) -> (String, String, String, String, String) {
    let fallback = ("Unknown".to_string(), "0000".to_string(),
                    "00".to_string(), "00".to_string(), "00-00-00".to_string());

    let s = match s {
        Some(s) if !s.is_empty() => s,
        _ => return fallback,
    };

    // "YYYY:MM:DD HH:MM:SS"
    let parts: Vec<&str> = s.splitn(2, ' ').collect();
    let date_parts: Vec<&str> = parts[0].split(':').collect();
    let time_parts: Vec<&str> = parts.get(1).unwrap_or(&"00:00:00").split(':').collect();

    if date_parts.len() < 3 {
        return fallback;
    }

    let year  = date_parts[0].to_string();
    let month = date_parts[1].to_string();
    let day   = date_parts[2].to_string();
    let date  = format!("{}-{}-{}", year, month, day);
    let time  = format!("{}-{}-{}",
        time_parts.get(0).unwrap_or(&"00"),
        time_parts.get(1).unwrap_or(&"00"),
        time_parts.get(2).unwrap_or(&"00").trim_end_matches('\0'));

    (date, year, month, day, time)
}

fn resolve_conflict(
    name: &str,
    dir: &str,
    strategy: &ConflictStrategy,
    seen: &mut HashSet<String>,
) -> (String, RenameAction) {
    let full_path = format!("{}/{}", dir, name);
    let exists_on_disk = Path::new(&full_path).exists();
    let seen_in_batch  = seen.contains(name);

    if !exists_on_disk && !seen_in_batch {
        seen.insert(name.to_string());
        return (name.to_string(), RenameAction::Rename);
    }

    match strategy {
        ConflictStrategy::Skip => (name.to_string(), RenameAction::Skip),
        ConflictStrategy::Overwrite => {
            seen.insert(name.to_string());
            (name.to_string(), RenameAction::Overwrite)
        }
        ConflictStrategy::Suffix => {
            let stem = Path::new(name)
                .file_stem()
                .and_then(|s| s.to_str())
                .unwrap_or(name);
            let ext = Path::new(name)
                .extension()
                .and_then(|e| e.to_str())
                .map(|e| format!(".{}", e))
                .unwrap_or_default();

            for n in 2u32.. {
                let candidate = format!("{}_{}{}", stem, n, ext);
                let candidate_path = format!("{}/{}", dir, candidate);
                if !Path::new(&candidate_path).exists() && !seen.contains(&candidate) {
                    seen.insert(candidate.clone());
                    return (candidate.clone(), RenameAction::AddSuffix(format!("_{}", n)));
                }
            }
            (name.to_string(), RenameAction::Skip) // unreachable in practice
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Preset templates
// ────────────────────────────────────────────────────────────────────────────

pub fn preset_templates() -> Vec<(&'static str, &'static str)> {
    vec![
        ("Date + Original",   "{date}_{name}.{ext}"),
        ("Date + Sequence",   "{date}_{seq:4}.{ext}"),
        ("Camera + Date",     "{camera}_{date}_{seq:4}.{ext}"),
        ("Year/Month/Seq",    "{year}-{month}_{seq:4}.{ext}"),
        ("Date + Time",       "{date}_{time}.{ext}"),
        ("Full EXIF",         "{date}_{camera}_ISO{iso}_{focal}_{seq:4}.{ext}"),
        ("Sequence only",     "{seq:6}.{ext}"),
        ("Original (reset)",  "{name}.{ext}"),
    ]
}

// ────────────────────────────────────────────────────────────────────────────
// Tests
// ────────────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn make_src(id: i64, name: &str) -> RenameSource {
        RenameSource {
            item_id: id,
            current_path: format!("/photos/{}", name),
            exif_date: Some("2024:11:15 10:30:00".to_string()),
            camera_model: Some("Sony A7R IV".to_string()),
            iso: Some(400),
            focal_length: Some(35.0),
            rating: 4,
        }
    }

    #[test]
    fn template_date_seq() {
        let src = make_src(1, "DSC_0001.jpg");
        let result = apply_template("{date}_{seq:4}.{ext}", &src, 1, 4);
        assert_eq!(result, "2024-11-15_0001.jpg");
    }

    #[test]
    fn template_camera() {
        let src = make_src(1, "DSC_0001.jpg");
        let result = apply_template("{camera}_{seq:3}.{ext}", &src, 5, 4);
        assert_eq!(result, "Sony_A7R_IV_005.jpg");
    }

    #[test]
    fn preview_no_conflicts() {
        let sources = vec![make_src(1, "a.jpg"), make_src(2, "b.jpg")];
        let config = RenameConfig {
            template: "{date}_{seq:4}.{ext}".to_string(),
            seq_start: 1,
            seq_pad: 4,
            conflict: ConflictStrategy::Suffix,
            dry_run: true,
        };
        let previews = preview_rename(&sources, &config);
        assert_eq!(previews[0].new_name, "2024-11-15_0001.jpg");
        assert_eq!(previews[1].new_name, "2024-11-15_0002.jpg");
    }

    #[test]
    fn seq_custom_width() {
        let src = make_src(1, "img.jpg");
        let result = apply_template("{seq:6}.{ext}", &src, 42, 4);
        assert_eq!(result, "000042.jpg");
    }
}
