//! Module for handling chart parts in a .docx archive.

use quick_xml::events::Event;
use quick_xml::Reader;
use serde::{Deserialize, Serialize};
use std::io::BufRead;

/// Representation of a chart embedded in a Word document.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Chart {
    /// Relationship ID from `word/_rels/document.xml.rels`.
    pub rel_id: String,
    /// Target path inside the zip, e.g. `word/charts/chart1.xml`.
    pub target: String,
    /// Title or name of the chart, if available.
    pub title: Option<String>,
    /// Raw XML content of the chart (may be parsed further by callers).
    pub xml: String,
}

/// Parse a chart XML document into a `Chart` struct.
///
/// This is a thin wrapper that reads the whole XML into a string and extracts the optional title.
/// For full chart semantics you would parse the DrawingML schema – left for future extensions.
pub fn parse_chart<R: BufRead>(
    rel_id: &str,
    target: &str,
    reader: &mut Reader<R>,
) -> Result<Chart, Box<dyn std::error::Error>> {
    let mut scratch = Vec::new();
    let mut xml = String::new();
    while let Ok(event) = reader.read_event_into(&mut scratch) {
        match event {
            Event::Eof => break,
            Event::Text(e) => xml.push_str(&e.unescape()?.into_owned()),
            _ => {}
        }
        scratch.clear();
    }
    // Very simple title extraction: look for <c:title> element.
    let title = xml
        .split("<c:title>")
        .nth(1)
        .and_then(|s| s.split("</c:title>").next())
        .map(|s| s.trim().to_string());
    Ok(Chart {
        rel_id: rel_id.to_string(),
        target: target.to_string(),
        title,
        xml,
    })
}

// Exported for external crates.
pub mod prelude {
    pub use super::{parse_chart, Chart};
}
