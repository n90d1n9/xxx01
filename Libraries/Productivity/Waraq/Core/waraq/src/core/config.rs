// src/core/config.rs
//
// Editor configuration — centralises all user-facing settings.
//
// Design:
//   • One `Config` per editor session (can differ per file type).
//   • Layered resolution: global → workspace → file-type → per-file.
//   • Serialisable to/from JSON so the host can persist and restore.
//   • Zero-cost defaults — `Config::default()` is a single memset-equivalent.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Tab / indent ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum IndentStyle {
    /// Insert `tab_width` space characters.
    Spaces,
    /// Insert a real `\t` character.
    Tabs,
}

impl Default for IndentStyle {
    fn default() -> Self {
        IndentStyle::Spaces
    }
}

// ── Line ending ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LineEnding {
    Lf,   // \n  (Unix, default)
    CrLf, // \r\n (Windows)
    Cr,   // \r  (legacy Mac)
}

impl LineEnding {
    pub fn as_str(self) -> &'static str {
        match self {
            LineEnding::Lf => "\n",
            LineEnding::CrLf => "\r\n",
            LineEnding::Cr => "\r",
        }
    }

    /// Detect dominant line ending in a text sample.
    pub fn detect(text: &str) -> Self {
        let crlf = text.matches("\r\n").count();
        let lf = text.matches('\n').count().saturating_sub(crlf);
        let cr = text.matches('\r').count().saturating_sub(crlf);
        if crlf >= lf && crlf >= cr {
            return LineEnding::CrLf;
        }
        if cr > lf {
            return LineEnding::Cr;
        }
        LineEnding::Lf
    }
}

impl Default for LineEnding {
    fn default() -> Self {
        LineEnding::Lf
    }
}

// ── Cursor style ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CursorStyle {
    Bar,
    Block,
    Underline,
    BlinkingBar,
    BlinkingBlock,
}

impl Default for CursorStyle {
    fn default() -> Self {
        CursorStyle::BlinkingBar
    }
}

// ── Word wrap ─────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum WordWrap {
    /// No wrapping — horizontal scroll.
    Off,
    /// Wrap at viewport width.
    On,
    /// Wrap at a fixed column.
    Column(u32),
}

impl Default for WordWrap {
    fn default() -> Self {
        WordWrap::Off
    }
}

// ── Main config struct ────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    // Indent
    pub indent_style: IndentStyle,
    pub tab_width: u32,
    pub indent_width: u32,
    /// Auto-detect indent style from file content.
    pub detect_indent: bool,

    // Line handling
    pub line_ending: LineEnding,
    pub trim_trailing_whitespace: bool,
    pub insert_final_newline: bool,
    pub max_line_length: Option<u32>, // None = unlimited

    // Display
    pub word_wrap: WordWrap,
    pub show_line_numbers: bool,
    pub show_whitespace: bool,
    pub highlight_current_line: bool,
    pub cursor_style: CursorStyle,
    pub ruler_columns: Vec<u32>,
    pub font_size: f32,
    pub font_family: String,

    // Editing behaviour
    pub auto_close_brackets: bool,
    pub auto_close_quotes: bool,
    pub auto_indent: bool,
    pub format_on_save: bool,
    pub tab_completes: bool,

    // AI
    pub ai_inline_completion: bool,
    pub ai_debounce_ms: u64,
    pub ai_max_tokens: u32,
    pub ai_temperature: f32,

    // Language-specific overrides: language → partial config values.
    /// Keys are language IDs (e.g. "rust", "python").
    /// Values are flat key→value maps that override the matching field.
    pub language_overrides: HashMap<String, HashMap<String, serde_json::Value>>,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            indent_style: IndentStyle::Spaces,
            tab_width: 4,
            indent_width: 4,
            detect_indent: true,
            line_ending: LineEnding::Lf,
            trim_trailing_whitespace: true,
            insert_final_newline: true,
            max_line_length: None,
            word_wrap: WordWrap::Off,
            show_line_numbers: true,
            show_whitespace: false,
            highlight_current_line: true,
            cursor_style: CursorStyle::BlinkingBar,
            ruler_columns: Vec::new(),
            font_size: 14.0,
            font_family: "JetBrains Mono".into(),
            auto_close_brackets: true,
            auto_close_quotes: true,
            auto_indent: true,
            format_on_save: false,
            tab_completes: true,
            ai_inline_completion: true,
            ai_debounce_ms: 300,
            ai_max_tokens: 128,
            ai_temperature: 0.15,
            language_overrides: HashMap::new(),
        }
    }
}

impl Config {
    /// Resolve config for a specific language (applies overrides).
    pub fn for_language(&self, language: &str) -> ResolvedConfig {
        let mut resolved = ResolvedConfig::from(self.clone());
        if let Some(overrides) = self.language_overrides.get(language) {
            for (key, val) in overrides {
                resolved.apply_override(key, val);
            }
        }
        resolved
    }

    /// Auto-detect indent style from file content and update self.
    pub fn detect_and_apply_indent(&mut self, text: &str) {
        if !self.detect_indent {
            return;
        }
        let (style, width) = detect_indent_style(text);
        self.indent_style = style;
        self.indent_width = width;
    }

    /// Detect and apply line ending from file content.
    pub fn detect_and_apply_line_ending(&mut self, text: &str) {
        self.line_ending = LineEnding::detect(text);
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        Ok(serde_json::from_str(json)?)
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }

    /// Produce the indent string for one level.
    pub fn indent_str(&self) -> String {
        match self.indent_style {
            IndentStyle::Tabs => "\t".to_owned(),
            IndentStyle::Spaces => " ".repeat(self.indent_width as usize),
        }
    }
}

// ── ResolvedConfig ────────────────────────────────────────────────────────────

/// A config with language overrides already merged in.
/// This is what the indent engine and formatter actually see.
#[derive(Debug, Clone)]
pub struct ResolvedConfig {
    pub indent_style: IndentStyle,
    pub tab_width: u32,
    pub indent_width: u32,
    pub line_ending: LineEnding,
    pub auto_indent: bool,
    pub auto_close_brackets: bool,
    pub auto_close_quotes: bool,
    pub max_line_length: Option<u32>,
    pub trim_trailing_whitespace: bool,
    pub insert_final_newline: bool,
}

impl From<Config> for ResolvedConfig {
    fn from(c: Config) -> Self {
        Self {
            indent_style: c.indent_style,
            tab_width: c.tab_width,
            indent_width: c.indent_width,
            line_ending: c.line_ending,
            auto_indent: c.auto_indent,
            auto_close_brackets: c.auto_close_brackets,
            auto_close_quotes: c.auto_close_quotes,
            max_line_length: c.max_line_length,
            trim_trailing_whitespace: c.trim_trailing_whitespace,
            insert_final_newline: c.insert_final_newline,
        }
    }
}

impl ResolvedConfig {
    pub fn indent_str(&self) -> String {
        match self.indent_style {
            IndentStyle::Tabs => "\t".to_owned(),
            IndentStyle::Spaces => " ".repeat(self.indent_width as usize),
        }
    }

    fn apply_override(&mut self, key: &str, val: &serde_json::Value) {
        match key {
            "tab_width" => {
                if let Some(n) = val.as_u64() {
                    self.tab_width = n as u32;
                }
            }
            "indent_width" => {
                if let Some(n) = val.as_u64() {
                    self.indent_width = n as u32;
                }
            }
            "indent_style" => match val.as_str() {
                Some("tabs") => self.indent_style = IndentStyle::Tabs,
                Some("spaces") => self.indent_style = IndentStyle::Spaces,
                _ => {}
            },
            "line_ending" => match val.as_str() {
                Some("lf") => self.line_ending = LineEnding::Lf,
                Some("crlf") => self.line_ending = LineEnding::CrLf,
                Some("cr") => self.line_ending = LineEnding::Cr,
                _ => {}
            },
            _ => {}
        }
    }
}

// ── Indent detection ──────────────────────────────────────────────────────────

/// Detect indent style from a text sample.
/// Returns (IndentStyle, width).
pub fn detect_indent_style(text: &str) -> (IndentStyle, u32) {
    let mut tab_lines = 0u32;
    let mut space_counts: HashMap<u32, u32> = HashMap::new();

    for line in text.lines().take(500) {
        if line.starts_with('\t') {
            tab_lines += 1;
        } else if line.starts_with(' ') {
            let count = line.chars().take_while(|c| *c == ' ').count() as u32;
            if count > 0 && count <= 8 {
                *space_counts.entry(count).or_insert(0) += 1;
            }
        }
    }

    let space_lines: u32 = space_counts.values().sum();

    if tab_lines > space_lines {
        return (IndentStyle::Tabs, 4);
    }

    // Find most common indent width (look for divisors: 2, 4, 8)
    let dominant_width = [2u32, 4, 8]
        .iter()
        .map(|&w| {
            let score: u32 = space_counts
                .iter()
                .filter(|(&count, _)| count % w == 0)
                .map(|(_, &freq)| freq)
                .sum();
            (score, w)
        })
        .max_by_key(|(score, _)| *score)
        .map(|(_, w)| w)
        .unwrap_or(4);

    (IndentStyle::Spaces, dominant_width)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let cfg = Config::default();
        assert_eq!(cfg.tab_width, 4);
        assert_eq!(cfg.indent_style, IndentStyle::Spaces);
        assert!(cfg.auto_close_brackets);
        assert!(cfg.ai_inline_completion);
    }

    #[test]
    fn test_indent_str_spaces() {
        let cfg = Config::default();
        assert_eq!(cfg.indent_str(), "    ");
    }

    #[test]
    fn test_indent_str_tabs() {
        let mut cfg = Config::default();
        cfg.indent_style = IndentStyle::Tabs;
        assert_eq!(cfg.indent_str(), "\t");
    }

    #[test]
    fn test_line_ending_detect_crlf() {
        let text = "hello\r\nworld\r\n";
        assert_eq!(LineEnding::detect(text), LineEnding::CrLf);
    }

    #[test]
    fn test_line_ending_detect_lf() {
        let text = "hello\nworld\n";
        assert_eq!(LineEnding::detect(text), LineEnding::Lf);
    }

    #[test]
    fn test_detect_indent_spaces_4() {
        let code = "fn main() {\n    let x = 1;\n    let y = 2;\n}\n";
        let (style, width) = detect_indent_style(code);
        assert_eq!(style, IndentStyle::Spaces);
        assert_eq!(width, 4);
    }

    #[test]
    fn test_detect_indent_spaces_2() {
        let code = "function f() {\n  return 1;\n  return 2;\n}\n";
        let (style, width) = detect_indent_style(code);
        assert_eq!(style, IndentStyle::Spaces);
        assert_eq!(width, 2);
    }

    #[test]
    fn test_detect_indent_tabs() {
        let code = "fn main() {\n\tlet x = 1;\n\tlet y = 2;\n}\n";
        let (style, _width) = detect_indent_style(code);
        assert_eq!(style, IndentStyle::Tabs);
    }

    #[test]
    fn test_language_override() {
        let mut cfg = Config::default();
        let mut go_override = HashMap::new();
        go_override.insert("indent_style".to_owned(), serde_json::json!("tabs"));
        go_override.insert("tab_width".to_owned(), serde_json::json!(8));
        cfg.language_overrides.insert("go".to_owned(), go_override);

        let resolved = cfg.for_language("go");
        assert_eq!(resolved.indent_style, IndentStyle::Tabs);
        assert_eq!(resolved.tab_width, 8);

        // Rust should still use the default
        let rust = cfg.for_language("rust");
        assert_eq!(rust.indent_style, IndentStyle::Spaces);
    }

    #[test]
    fn test_json_roundtrip() {
        let cfg = Config::default();
        let json = cfg.to_json();
        let restored = Config::from_json(&json).unwrap();
        assert_eq!(restored.tab_width, cfg.tab_width);
        assert_eq!(restored.font_family, cfg.font_family);
    }
}
