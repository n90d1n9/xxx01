// src/notebook/output.rs
//
// Notebook cell output types — mirrors the Jupyter nbformat v4 output spec.
//
// Output kinds:
//   stream         → stdout/stderr text (print statements)
//   display_data   → rich display (HTML, SVG, images, LaTeX, JSON, ...)
//   execute_result → the last expression value in a cell
//   error          → exception traceback
//
// MIME types commonly used in outputs:
//   text/plain          → fallback text representation
//   text/html           → HTML rendering (pandas DataFrames, plotly, etc.)
//   text/markdown       → Markdown text
//   text/latex          → LaTeX math
//   image/png           → base64-encoded PNG
//   image/jpeg          → base64-encoded JPEG
//   image/svg+xml       → inline SVG
//   application/json    → JSON data (Vega-lite, Plotly JSON, etc.)
//   application/javascript → executable JavaScript
//   text/x-python       → syntax-highlighted Python
//   application/vnd.jupyter.widget-view+json → ipywidgets

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── MIME bundle ────────────────────────────────────────────────────────────────

/// A bundle of MIME-typed data for the same content.
/// Renderers choose the richest type they can display.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct MimeBundle {
    /// MIME type → data. Data is either plain text or base64 for binary.
    pub data: HashMap<String, MimeData>,
    /// MIME type → metadata (e.g. image dimensions).
    pub metadata: HashMap<String, serde_json::Value>,
}

impl MimeBundle {
    pub fn new() -> Self {
        Self::default()
    }

    /// Add a MIME entry. Text types store as-is; binary types must be base64.
    pub fn add(mut self, mime: &str, data: MimeData) -> Self {
        self.data.insert(mime.to_owned(), data);
        self
    }

    pub fn text(mut self, text: &str) -> Self {
        self.data
            .insert("text/plain".into(), MimeData::Text(text.to_owned()));
        self
    }

    pub fn html(mut self, html: &str) -> Self {
        self.data
            .insert("text/html".into(), MimeData::Text(html.to_owned()));
        self
    }

    pub fn svg(mut self, svg: &str) -> Self {
        self.data
            .insert("image/svg+xml".into(), MimeData::Text(svg.to_owned()));
        self
    }

    pub fn markdown(mut self, md: &str) -> Self {
        self.data
            .insert("text/markdown".into(), MimeData::Text(md.to_owned()));
        self
    }

    pub fn latex(mut self, latex: &str) -> Self {
        self.data
            .insert("text/latex".into(), MimeData::Text(latex.to_owned()));
        self
    }

    pub fn json(mut self, v: serde_json::Value) -> Self {
        self.data
            .insert("application/json".into(), MimeData::Json(v));
        self
    }

    pub fn png_base64(mut self, b64: &str) -> Self {
        self.data
            .insert("image/png".into(), MimeData::Text(b64.to_owned()));
        self
    }

    pub fn jpeg_base64(mut self, b64: &str) -> Self {
        self.data
            .insert("image/jpeg".into(), MimeData::Text(b64.to_owned()));
        self
    }

    /// Get the best available text representation.
    pub fn best_text(&self) -> Option<&str> {
        for mime in &["text/html", "text/markdown", "text/plain", "text/latex"] {
            if let Some(MimeData::Text(t)) = self.data.get(*mime) {
                return Some(t);
            }
        }
        None
    }

    /// Returns true if this bundle has an image.
    pub fn has_image(&self) -> bool {
        self.data.keys().any(|k| k.starts_with("image/"))
    }

    /// Returns true if this bundle has HTML output.
    pub fn has_html(&self) -> bool {
        self.data.contains_key("text/html")
    }

    /// MIME types available in this bundle, richest first.
    pub fn available_types(&self) -> Vec<&str> {
        let priority = [
            "application/vnd.jupyter.widget-view+json",
            "application/json",
            "application/javascript",
            "image/svg+xml",
            "image/png",
            "image/jpeg",
            "text/html",
            "text/markdown",
            "text/latex",
            "text/plain",
        ];
        let mut result: Vec<&str> = priority
            .iter()
            .filter(|&&m| self.data.contains_key(m))
            .map(|&m| m)
            .collect();
        // Add any remaining types not in priority list
        for k in self.data.keys() {
            if !result.contains(&k.as_str()) {
                result.push(k.as_str());
            }
        }
        result
    }
}

/// MIME data payload.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum MimeData {
    /// Plain text or base64-encoded binary.
    Text(String),
    /// Lines joined array (nbformat multiline text).
    Lines(Vec<String>),
    /// JSON object (for application/json MIME types).
    Json(serde_json::Value),
}

impl MimeData {
    pub fn as_str(&self) -> &str {
        match self {
            MimeData::Text(s) => s,
            _ => "",
        }
    }

    pub fn as_joined(&self) -> String {
        match self {
            MimeData::Text(s) => s.clone(),
            MimeData::Lines(v) => v.join(""),
            MimeData::Json(v) => serde_json::to_string(v).unwrap_or_default(),
        }
    }
}

// ── Stream output ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum StreamName {
    #[serde(rename = "stdout")]
    Stdout,
    #[serde(rename = "stderr")]
    Stderr,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StreamOutput {
    pub name: StreamName,
    pub text: String,
}

// ── Error output ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorOutput {
    /// Exception type name: "TypeError", "ValueError", "NameError", etc.
    pub ename: String,
    /// Exception message.
    pub evalue: String,
    /// Traceback lines (may contain ANSI color codes).
    pub traceback: Vec<String>,
}

impl ErrorOutput {
    pub fn new(ename: &str, evalue: &str, traceback: Vec<String>) -> Self {
        Self {
            ename: ename.to_owned(),
            evalue: evalue.to_owned(),
            traceback,
        }
    }

    /// Format the traceback as plain text (stripped of ANSI codes).
    pub fn plain_traceback(&self) -> String {
        self.traceback
            .iter()
            .map(|line| strip_ansi(line))
            .collect::<Vec<_>>()
            .join("\n")
    }

    /// One-line summary.
    pub fn summary(&self) -> String {
        format!("{}: {}", self.ename, self.evalue)
    }
}

fn strip_ansi(s: &str) -> String {
    let mut result = String::new();
    let mut chars = s.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch == '\x1b' {
            // Skip ESC sequence
            if chars.next() == Some('[') {
                while let Some(c) = chars.next() {
                    if c.is_alphabetic() {
                        break;
                    }
                }
            }
        } else {
            result.push(ch);
        }
    }
    result
}

// ── Cell output union ─────────────────────────────────────────────────────────

/// One output item produced by a cell execution.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "output_type", rename_all = "snake_case")]
pub enum CellOutput {
    /// Standard output/error stream.
    Stream(StreamOutput),
    /// Rich display — not the return value of the cell.
    DisplayData {
        data: MimeBundle,
        metadata: HashMap<String, serde_json::Value>,
        /// For updateable displays (comm protocol).
        transient: Option<serde_json::Value>,
    },
    /// The result of the last expression in the cell (like a REPL).
    ExecuteResult {
        execution_count: u32,
        data: MimeBundle,
        metadata: HashMap<String, serde_json::Value>,
    },
    /// An unhandled exception.
    Error(ErrorOutput),
}

impl CellOutput {
    // ── Constructors ──────────────────────────────────────────────────────────

    pub fn stdout(text: &str) -> Self {
        Self::Stream(StreamOutput {
            name: StreamName::Stdout,
            text: text.to_owned(),
        })
    }

    pub fn stderr(text: &str) -> Self {
        Self::Stream(StreamOutput {
            name: StreamName::Stderr,
            text: text.to_owned(),
        })
    }

    pub fn display(bundle: MimeBundle) -> Self {
        Self::DisplayData {
            data: bundle,
            metadata: HashMap::new(),
            transient: None,
        }
    }

    pub fn result(n: u32, bundle: MimeBundle) -> Self {
        Self::ExecuteResult {
            execution_count: n,
            data: bundle,
            metadata: HashMap::new(),
        }
    }

    pub fn error(ename: &str, evalue: &str, traceback: Vec<String>) -> Self {
        Self::Error(ErrorOutput::new(ename, evalue, traceback))
    }

    // ── Queries ───────────────────────────────────────────────────────────────

    pub fn is_error(&self) -> bool {
        matches!(self, Self::Error(_))
    }
    pub fn is_stream(&self) -> bool {
        matches!(self, Self::Stream(_))
    }

    pub fn as_stream_text(&self) -> Option<&str> {
        if let Self::Stream(s) = self {
            Some(&s.text)
        } else {
            None
        }
    }

    pub fn mime_bundle(&self) -> Option<&MimeBundle> {
        match self {
            Self::DisplayData { data, .. } => Some(data),
            Self::ExecuteResult { data, .. } => Some(data),
            _ => None,
        }
    }

    pub fn plain_text(&self) -> String {
        match self {
            Self::Stream(s) => s.text.clone(),
            Self::DisplayData { data, .. } => data.best_text().unwrap_or("").to_owned(),
            Self::ExecuteResult { data, .. } => data.best_text().unwrap_or("").to_owned(),
            Self::Error(e) => e.summary(),
        }
    }
}

// ── Output buffer ─────────────────────────────────────────────────────────────

/// Accumulates outputs from a single cell execution.
/// Merges consecutive stream outputs of the same type (as Jupyter does).
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct OutputBuffer {
    pub outputs: Vec<CellOutput>,
}

impl OutputBuffer {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn push(&mut self, output: CellOutput) {
        // Merge consecutive stream outputs of the same type
        if let CellOutput::Stream(new_stream) = &output {
            if let Some(CellOutput::Stream(last)) = self.outputs.last_mut() {
                if last.name == new_stream.name {
                    last.text.push_str(&new_stream.text);
                    return;
                }
            }
        }
        self.outputs.push(output);
    }

    pub fn clear(&mut self) {
        self.outputs.clear();
    }
    pub fn is_empty(&self) -> bool {
        self.outputs.is_empty()
    }
    pub fn len(&self) -> usize {
        self.outputs.len()
    }

    pub fn has_error(&self) -> bool {
        self.outputs.iter().any(|o| o.is_error())
    }

    pub fn errors(&self) -> Vec<&ErrorOutput> {
        self.outputs
            .iter()
            .filter_map(|o| {
                if let CellOutput::Error(e) = o {
                    Some(e)
                } else {
                    None
                }
            })
            .collect()
    }

    /// Concatenate all stdout text.
    pub fn stdout_text(&self) -> String {
        self.outputs
            .iter()
            .filter_map(|o| {
                if let CellOutput::Stream(s) = o {
                    if s.name == StreamName::Stdout {
                        return Some(s.text.as_str());
                    }
                }
                None
            })
            .collect::<Vec<_>>()
            .join("")
    }

    /// Concatenate all stderr text.
    pub fn stderr_text(&self) -> String {
        self.outputs
            .iter()
            .filter_map(|o| {
                if let CellOutput::Stream(s) = o {
                    if s.name == StreamName::Stderr {
                        return Some(s.text.as_str());
                    }
                }
                None
            })
            .collect::<Vec<_>>()
            .join("")
    }

    /// All plain-text representation of all outputs.
    pub fn all_text(&self) -> String {
        self.outputs
            .iter()
            .map(|o| o.plain_text())
            .collect::<Vec<_>>()
            .join("\n")
    }

    /// Serialise to nbformat JSON array.
    pub fn to_json(&self) -> serde_json::Value {
        serde_json::to_value(&self.outputs).unwrap_or(serde_json::Value::Array(vec![]))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── MimeBundle ────────────────────────────────────────────────────────────

    #[test]
    fn test_mime_bundle_add() {
        let b = MimeBundle::new().text("hello").html("<b>hello</b>");
        assert!(b.data.contains_key("text/plain"));
        assert!(b.data.contains_key("text/html"));
    }

    #[test]
    fn test_mime_bundle_best_text_prefers_html() {
        let b = MimeBundle::new().html("<b>rich</b>").text("plain");
        assert_eq!(b.best_text().unwrap(), "<b>rich</b>");
    }

    #[test]
    fn test_mime_bundle_available_types_order() {
        let b = MimeBundle::new().html("<p>hi</p>").text("hi");
        let types = b.available_types();
        let html_idx = types.iter().position(|&t| t == "text/html").unwrap();
        let text_idx = types.iter().position(|&t| t == "text/plain").unwrap();
        assert!(html_idx < text_idx, "HTML should come before text/plain");
    }

    #[test]
    fn test_mime_bundle_has_image() {
        let b = MimeBundle::new().png_base64("abc123");
        assert!(b.has_image());
        let b2 = MimeBundle::new().text("no image");
        assert!(!b2.has_image());
    }

    #[test]
    fn test_mime_data_as_joined_text() {
        let d = MimeData::Text("hello world".into());
        assert_eq!(d.as_joined(), "hello world");
    }

    #[test]
    fn test_mime_data_as_joined_lines() {
        let d = MimeData::Lines(vec!["line1\n".into(), "line2\n".into()]);
        assert_eq!(d.as_joined(), "line1\nline2\n");
    }

    // ── CellOutput ────────────────────────────────────────────────────────────

    #[test]
    fn test_stdout_output() {
        let out = CellOutput::stdout("hello\n");
        assert!(out.is_stream());
        assert_eq!(out.as_stream_text().unwrap(), "hello\n");
    }

    #[test]
    fn test_error_output() {
        let out = CellOutput::error(
            "NameError",
            "name 'x' is not defined",
            vec![
                "  File <ipython-input>".into(),
                "NameError: name 'x'...".into(),
            ],
        );
        assert!(out.is_error());
        assert_eq!(out.plain_text(), "NameError: name 'x' is not defined");
    }

    #[test]
    fn test_display_data_plain_text() {
        let b = MimeBundle::new().text("42").html("<b>42</b>");
        let out = CellOutput::display(b);
        // plain_text prefers html
        assert_eq!(out.plain_text(), "<b>42</b>");
    }

    #[test]
    fn test_execute_result() {
        let b = MimeBundle::new().text("42");
        let out = CellOutput::result(3, b);
        assert!(!out.is_error());
        assert!(!out.is_stream());
    }

    // ── OutputBuffer ─────────────────────────────────────────────────────────

    #[test]
    fn test_output_buffer_merges_stream() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("line 1\n"));
        buf.push(CellOutput::stdout("line 2\n"));
        assert_eq!(buf.len(), 1, "Consecutive stdout should be merged");
        assert_eq!(buf.stdout_text(), "line 1\nline 2\n");
    }

    #[test]
    fn test_output_buffer_no_merge_different_stream() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("out\n"));
        buf.push(CellOutput::stderr("err\n"));
        assert_eq!(buf.len(), 2, "stdout and stderr should NOT be merged");
    }

    #[test]
    fn test_output_buffer_has_error() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("hello\n"));
        assert!(!buf.has_error());
        buf.push(CellOutput::error("ValueError", "bad value", vec![]));
        assert!(buf.has_error());
    }

    #[test]
    fn test_output_buffer_clear() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("hello\n"));
        buf.clear();
        assert!(buf.is_empty());
    }

    #[test]
    fn test_output_buffer_all_text() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("line1\n"));
        buf.push(CellOutput::result(1, MimeBundle::new().text("42")));
        let text = buf.all_text();
        assert!(text.contains("line1"));
        assert!(text.contains("42"));
    }

    #[test]
    fn test_error_strip_ansi() {
        let err = ErrorOutput::new(
            "TypeError",
            "bad type",
            vec!["\x1b[31mTraceback\x1b[0m (most recent call last)".into()],
        );
        let plain = err.plain_traceback();
        assert!(!plain.contains('\x1b'), "ANSI codes should be stripped");
        assert!(plain.contains("Traceback"));
    }

    #[test]
    fn test_output_buffer_to_json() {
        let mut buf = OutputBuffer::new();
        buf.push(CellOutput::stdout("hello\n"));
        let json = buf.to_json();
        assert!(json.is_array());
        assert_eq!(json.as_array().unwrap().len(), 1);
    }
}
