// gallery_bridge_engine/src/xmp/mod.rs
//
// XMP sidecar writer.
//
// Writes rating, color label, flag, keywords, and title back to
// standard XMP sidecar files (.xmp) so that Lightroom, Capture One,
// Bridge, and any other XMP-aware application sees the same metadata.
//
// XMP sidecars live alongside the source file:
//   /photos/DSC_0001.jpg  →  /photos/DSC_0001.xmp
//
// Namespaces used:
//   xmp:    — http://ns.adobe.com/xap/1.0/
//   xmpMM:  — http://ns.adobe.com/xap/1.0/mm/
//   dc:     — http://purl.org/dc/elements/1.1/
//   lr:     — http://ns.adobe.com/lightroom/1.0/
//   exif:   — http://ns.adobe.com/exif/1.0/
//
// Format: minimal valid XMP packet (not full RDF graph).

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::{Path, PathBuf};

// ────────────────────────────────────────────────────────────────────────────
// XMP record
// ────────────────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct XmpRecord {
    pub rating: i64,          // 0–5  → xmp:Rating
    pub label: String,        // "Red"|"Yellow"|"Green"|"Blue"|"Purple"|""  → xmp:Label
    pub flag: i64,            // 0=none, 1=picked, 2=rejected → xmp:Marked / lr:rejected
    pub title: Option<String>,
    pub description: Option<String>,
    pub keywords: Vec<String>,
    pub creator: Option<String>,
    pub copyright: Option<String>,
}

impl Default for XmpRecord {
    fn default() -> Self {
        Self {
            rating: 0,
            label: String::new(),
            flag: 0,
            title: None,
            description: None,
            keywords: vec![],
            creator: None,
            copyright: None,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Sidecar path
// ────────────────────────────────────────────────────────────────────────────

/// Returns the XMP sidecar path for a given source file.
/// `/photos/DSC_0001.jpg` → `/photos/DSC_0001.xmp`
pub fn sidecar_path(source: &Path) -> PathBuf {
    source.with_extension("xmp")
}

// ────────────────────────────────────────────────────────────────────────────
// Write
// ────────────────────────────────────────────────────────────────────────────

/// Write (or overwrite) an XMP sidecar for `source_path`.
/// If the sidecar already exists its non-managed fields are preserved
/// by reading the existing file first, then merging.
pub fn write_sidecar(source_path: &Path, record: &XmpRecord) -> Result<PathBuf> {
    let xmp_path = sidecar_path(source_path);

    // If a sidecar already exists, read its existing raw XML so we can
    // preserve any fields we don't manage (e.g. GPS, lens info).
    // In production this would use a real XMP parser; here we use a
    // minimal approach that replaces only the managed properties.
    let existing = if xmp_path.exists() {
        fs::read_to_string(&xmp_path).ok()
    } else {
        None
    };

    let xml = if let Some(existing_xml) = existing {
        update_xmp_fields(&existing_xml, record)
    } else {
        create_xmp_packet(record, source_path)
    };

    fs::write(&xmp_path, xml.as_bytes())
        .with_context(|| format!("Cannot write XMP to {}", xmp_path.display()))?;

    Ok(xmp_path)
}

/// Read an existing XMP sidecar and return a partial XmpRecord.
pub fn read_sidecar(source_path: &Path) -> Result<Option<XmpRecord>> {
    let xmp_path = sidecar_path(source_path);
    if !xmp_path.exists() {
        return Ok(None);
    }
    let xml = fs::read_to_string(&xmp_path)?;
    Ok(Some(parse_xmp_record(&xml)))
}

/// Remove the XMP sidecar for a source file (e.g. on delete).
pub fn remove_sidecar(source_path: &Path) -> Result<bool> {
    let xmp_path = sidecar_path(source_path);
    if xmp_path.exists() {
        fs::remove_file(&xmp_path)?;
        Ok(true)
    } else {
        Ok(false)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// Batch operations
// ────────────────────────────────────────────────────────────────────────────

pub struct SidecarWriteResult {
    pub source_path: String,
    pub xmp_path: String,
    pub success: bool,
    pub error: Option<String>,
}

/// Write XMP sidecars for multiple files in one call.
pub fn write_sidecars_batch(
    items: &[(String, XmpRecord)], // (source_path, record)
) -> Vec<SidecarWriteResult> {
    items
        .iter()
        .map(|(path, record)| {
            let result = write_sidecar(Path::new(path), record);
            match result {
                Ok(xmp) => SidecarWriteResult {
                    source_path: path.clone(),
                    xmp_path: xmp.to_string_lossy().to_string(),
                    success: true,
                    error: None,
                },
                Err(e) => SidecarWriteResult {
                    source_path: path.clone(),
                    xmp_path: String::new(),
                    success: false,
                    error: Some(e.to_string()),
                },
            }
        })
        .collect()
}

// ────────────────────────────────────────────────────────────────────────────
// XMP generation
// ────────────────────────────────────────────────────────────────────────────

fn create_xmp_packet(record: &XmpRecord, source: &Path) -> String {
    let source_name = source
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("");

    let keywords_xml = keywords_to_xml(&record.keywords);
    let label_xml    = if record.label.is_empty() { String::new() }
                       else { format!("   <xmp:Label>{}</xmp:Label>\n", xml_escape(&record.label)) };
    let title_xml    = record.title.as_deref()
        .map(|t| format!("   <dc:title><rdf:Alt><rdf:li xml:lang=\"x-default\">{}</rdf:li></rdf:Alt></dc:title>\n", xml_escape(t)))
        .unwrap_or_default();
    let desc_xml     = record.description.as_deref()
        .map(|d| format!("   <dc:description><rdf:Alt><rdf:li xml:lang=\"x-default\">{}</rdf:li></rdf:Alt></dc:description>\n", xml_escape(d)))
        .unwrap_or_default();
    let creator_xml  = record.creator.as_deref()
        .map(|c| format!("   <dc:creator><rdf:Seq><rdf:li>{}</rdf:li></rdf:Seq></dc:creator>\n", xml_escape(c)))
        .unwrap_or_default();
    let rights_xml   = record.copyright.as_deref()
        .map(|r| format!("   <dc:rights><rdf:Alt><rdf:li xml:lang=\"x-default\">{}</rdf:li></rdf:Alt></dc:rights>\n", xml_escape(r)))
        .unwrap_or_default();
    let marked_xml   = if record.flag == 1 { "   <xmp:Marked>True</xmp:Marked>\n".to_string() }
                       else { String::new() };
    let rejected_xml = if record.flag == 2 { "   <lr:rejected>1</lr:rejected>\n".to_string() }
                       else { String::new() };

    format!(
        r#"<?xpacket begin="﻿" id="W5M0MpCehiHzreSzNTczkc9d"?>
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="GalleryBridge 1.0">
 <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="{source_name}"
   xmlns:xmp="http://ns.adobe.com/xap/1.0/"
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:lr="http://ns.adobe.com/lightroom/1.0/">
   <xmp:Rating>{rating}</xmp:Rating>
{label_xml}{marked_xml}{rejected_xml}{title_xml}{desc_xml}{creator_xml}{rights_xml}{keywords_xml}  </rdf:Description>
 </rdf:RDF>
</x:xmpmeta>
<?xpacket end="w"?>
"#,
        source_name = source_name,
        rating = record.rating,
        label_xml = label_xml,
        marked_xml = marked_xml,
        rejected_xml = rejected_xml,
        title_xml = title_xml,
        desc_xml = desc_xml,
        creator_xml = creator_xml,
        rights_xml = rights_xml,
        keywords_xml = keywords_xml,
    )
}

fn update_xmp_fields(existing: &str, record: &XmpRecord) -> String {
    // Simple field replacement for managed properties.
    // In production use a real XML DOM parser.
    let mut xml = existing.to_string();

    // Replace or insert xmp:Rating
    xml = replace_or_insert_field(
        &xml,
        "xmp:Rating",
        &record.rating.to_string(),
        "rdf:Description",
    );

    // Replace or insert xmp:Label
    if !record.label.is_empty() {
        xml = replace_or_insert_field(&xml, "xmp:Label", &record.label, "rdf:Description");
    }

    xml
}

fn replace_or_insert_field(xml: &str, tag: &str, value: &str, parent_tag: &str) -> String {
    let open  = format!("<{}>", tag);
    let close = format!("</{}>", tag);
    let replacement = format!("<{}>{}</{}>", tag, xml_escape(value), tag);

    if xml.contains(&open) {
        // Replace existing value between tags
        if let (Some(start), Some(end)) = (xml.find(&open), xml.find(&close)) {
            let prefix = &xml[..start];
            let suffix = &xml[end + close.len()..];
            return format!("{}{}{}", prefix, replacement, suffix);
        }
    }

    // Insert before the closing parent tag
    let close_parent = format!("</{}>", parent_tag);
    xml.replacen(
        &close_parent,
        &format!("   {}\n  {}", replacement, close_parent),
        1,
    )
}

fn keywords_to_xml(keywords: &[String]) -> String {
    if keywords.is_empty() {
        return String::new();
    }
    let items = keywords
        .iter()
        .map(|k| format!("       <rdf:li>{}</rdf:li>", xml_escape(k)))
        .collect::<Vec<_>>()
        .join("\n");
    format!(
        "   <dc:subject>\n    <rdf:Bag>\n{}\n    </rdf:Bag>\n   </dc:subject>\n",
        items
    )
}

fn parse_xmp_record(xml: &str) -> XmpRecord {
    let mut record = XmpRecord::default();

    // Minimal tag-extraction parser
    if let Some(r) = extract_between(xml, "<xmp:Rating>", "</xmp:Rating>") {
        record.rating = r.trim().parse().unwrap_or(0);
    }
    if let Some(l) = extract_between(xml, "<xmp:Label>", "</xmp:Label>") {
        record.label = l.trim().to_string();
    }
    if xml.contains("<xmp:Marked>True</xmp:Marked>") {
        record.flag = 1;
    }
    if xml.contains("<lr:rejected>1</lr:rejected>") {
        record.flag = 2;
    }

    record
}

fn extract_between<'a>(s: &'a str, open: &str, close: &str) -> Option<&'a str> {
    let start = s.find(open)? + open.len();
    let end   = s[start..].find(close)? + start;
    Some(&s[start..end])
}

fn xml_escape(s: &str) -> String {
    s.replace('&', "&amp;")
     .replace('<', "&lt;")
     .replace('>', "&gt;")
     .replace('"', "&quot;")
     .replace('\'', "&apos;")
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn write_and_read_roundtrip() {
        let dir = tempdir().unwrap();
        let src = dir.path().join("DSC_0001.jpg");
        std::fs::write(&src, b"fake jpeg").unwrap();

        let record = XmpRecord {
            rating: 4,
            label: "Red".to_string(),
            flag: 1,
            keywords: vec!["travel".to_string(), "landscape".to_string()],
            ..Default::default()
        };

        write_sidecar(&src, &record).unwrap();

        let read_back = read_sidecar(&src).unwrap().unwrap();
        assert_eq!(read_back.rating, 4);
        assert_eq!(read_back.label, "Red");
        assert_eq!(read_back.flag, 1);
    }

    #[test]
    fn sidecar_path_replaces_extension() {
        let p = Path::new("/photos/DSC_0001.jpg");
        assert_eq!(sidecar_path(p), PathBuf::from("/photos/DSC_0001.xmp"));
    }

    #[test]
    fn sidecar_path_raw() {
        let p = Path::new("/photos/DSC_0001.ARW");
        assert_eq!(sidecar_path(p), PathBuf::from("/photos/DSC_0001.xmp"));
    }
}
