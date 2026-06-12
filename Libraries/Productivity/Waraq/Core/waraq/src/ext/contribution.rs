// src/ext/contribution.rs
//
// Contribution point implementations:
//   • ThemeEngine   — manages active theme, applies token coloring
//   • SnippetEngine — template expansion with tab stops ($1, $2, ${1:placeholder})
//   • LanguageRegistry — maps file extensions/names to language IDs
//   • GrammarRegistry  — maps language IDs to tokenizer rules

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::ext::manifest::{LanguageContribution, ThemeKind};

// ═══════════════════════════════════════════════════════════════════════════════
// Theme engine
// ═══════════════════════════════════════════════════════════════════════════════

/// RGBA color: r, g, b, a (0–255).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct ThemeColor {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl ThemeColor {
    pub const fn rgba(r: u8, g: u8, b: u8, a: u8) -> Self {
        Self { r, g, b, a }
    }
    pub const fn rgb(r: u8, g: u8, b: u8) -> Self {
        Self::rgba(r, g, b, 255)
    }

    pub fn from_hex(s: &str) -> Option<Self> {
        let s = s.trim_start_matches('#');
        match s.len() {
            6 => {
                let r = u8::from_str_radix(&s[0..2], 16).ok()?;
                let g = u8::from_str_radix(&s[2..4], 16).ok()?;
                let b = u8::from_str_radix(&s[4..6], 16).ok()?;
                Some(Self::rgb(r, g, b))
            }
            8 => {
                let r = u8::from_str_radix(&s[0..2], 16).ok()?;
                let g = u8::from_str_radix(&s[2..4], 16).ok()?;
                let b = u8::from_str_radix(&s[4..6], 16).ok()?;
                let a = u8::from_str_radix(&s[6..8], 16).ok()?;
                Some(Self::rgba(r, g, b, a))
            }
            _ => None,
        }
    }

    pub fn to_hex(&self) -> String {
        if self.a == 255 {
            format!("#{:02X}{:02X}{:02X}", self.r, self.g, self.b)
        } else {
            format!("#{:02X}{:02X}{:02X}{:02X}", self.r, self.g, self.b, self.a)
        }
    }

    pub fn with_alpha(mut self, a: u8) -> Self {
        self.a = a;
        self
    }
}

/// A complete editor color theme.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Theme {
    pub id: String,
    pub name: String,
    pub kind: ThemeKind,
    /// Token colors: token_kind_id (0–255) → color.
    pub tokens: HashMap<u8, ThemeColor>,
    /// Editor UI colors.
    pub background: ThemeColor,
    pub foreground: ThemeColor,
    pub selection: ThemeColor,
    pub cursor: ThemeColor,
    pub current_line: ThemeColor,
    pub line_number: ThemeColor,
    pub gutter_bg: ThemeColor,
    pub search_match: ThemeColor,
    pub search_match_active: ThemeColor,
    pub error_fg: ThemeColor,
    pub warning_fg: ThemeColor,
    pub info_fg: ThemeColor,
}

impl Theme {
    pub fn token_color(&self, kind: u8) -> ThemeColor {
        self.tokens.get(&kind).copied().unwrap_or(self.foreground)
    }

    /// Built-in Dracula dark theme.
    pub fn dracula() -> Self {
        let mut tokens = HashMap::new();
        tokens.insert(0, ThemeColor::rgb(248, 248, 242)); // Default
        tokens.insert(1, ThemeColor::rgb(255, 121, 198)); // Keyword
        tokens.insert(2, ThemeColor::rgb(241, 250, 140)); // String
        tokens.insert(3, ThemeColor::rgb(189, 147, 249)); // Number
        tokens.insert(4, ThemeColor::rgb(98, 114, 164)); // Comment
        tokens.insert(5, ThemeColor::rgb(255, 121, 198)); // Operator
        tokens.insert(6, ThemeColor::rgb(80, 250, 123)); // Function
        tokens.insert(7, ThemeColor::rgb(139, 233, 253)); // Type
        tokens.insert(8, ThemeColor::rgb(248, 248, 242)); // Variable
        tokens.insert(9, ThemeColor::rgb(189, 147, 249)); // Constant
        tokens.insert(10, ThemeColor::rgb(248, 248, 242)); // Punctuation
        tokens.insert(11, ThemeColor::rgb(80, 250, 123)); // Attribute
        tokens.insert(255, ThemeColor::rgb(255, 85, 85)); // Error

        Self {
            id: "waraq.dracula".into(),
            name: "Dracula".into(),
            kind: ThemeKind::Dark,
            tokens,
            background: ThemeColor::rgb(40, 42, 54),
            foreground: ThemeColor::rgb(248, 248, 242),
            selection: ThemeColor::rgba(68, 71, 90, 180),
            cursor: ThemeColor::rgb(248, 248, 242),
            current_line: ThemeColor::rgb(68, 71, 90),
            line_number: ThemeColor::rgb(98, 114, 164),
            gutter_bg: ThemeColor::rgb(33, 34, 44),
            search_match: ThemeColor::rgba(81, 232, 240, 80),
            search_match_active: ThemeColor::rgba(241, 250, 140, 130),
            error_fg: ThemeColor::rgb(255, 85, 85),
            warning_fg: ThemeColor::rgb(255, 184, 108),
            info_fg: ThemeColor::rgb(139, 233, 253),
        }
    }

    /// Built-in GitHub Light theme.
    pub fn github_light() -> Self {
        let mut tokens = HashMap::new();
        tokens.insert(0, ThemeColor::rgb(36, 41, 46)); // Default
        tokens.insert(1, ThemeColor::rgb(215, 58, 73)); // Keyword
        tokens.insert(2, ThemeColor::rgb(3, 47, 98)); // String
        tokens.insert(3, ThemeColor::rgb(0, 92, 197)); // Number
        tokens.insert(4, ThemeColor::rgb(106, 115, 125)); // Comment
        tokens.insert(5, ThemeColor::rgb(215, 58, 73)); // Operator
        tokens.insert(6, ThemeColor::rgb(111, 66, 193)); // Function
        tokens.insert(7, ThemeColor::rgb(0, 92, 197)); // Type
        tokens.insert(8, ThemeColor::rgb(36, 41, 46)); // Variable
        tokens.insert(9, ThemeColor::rgb(0, 92, 197)); // Constant
        tokens.insert(10, ThemeColor::rgb(36, 41, 46)); // Punctuation
        tokens.insert(255, ThemeColor::rgb(203, 36, 29)); // Error

        Self {
            id: "waraq.github-light".into(),
            name: "GitHub Light".into(),
            kind: ThemeKind::Light,
            tokens,
            background: ThemeColor::rgb(255, 255, 255),
            foreground: ThemeColor::rgb(36, 41, 46),
            selection: ThemeColor::rgba(186, 212, 247, 150),
            cursor: ThemeColor::rgb(36, 41, 46),
            current_line: ThemeColor::rgb(250, 250, 250),
            line_number: ThemeColor::rgb(187, 187, 187),
            gutter_bg: ThemeColor::rgb(246, 248, 250),
            search_match: ThemeColor::rgba(255, 229, 109, 80),
            search_match_active: ThemeColor::rgba(255, 159, 0, 130),
            error_fg: ThemeColor::rgb(203, 36, 29),
            warning_fg: ThemeColor::rgb(227, 98, 9),
            info_fg: ThemeColor::rgb(0, 92, 197),
        }
    }
}

/// Manages the active theme and theme registry.
pub struct ThemeEngine {
    themes: HashMap<String, Theme>,
    active: String,
}

impl ThemeEngine {
    pub fn new() -> Self {
        let mut engine = Self {
            themes: HashMap::new(),
            active: "waraq.dracula".into(),
        };
        engine.register(Theme::dracula());
        engine.register(Theme::github_light());
        engine
    }

    pub fn register(&mut self, theme: Theme) {
        let id = theme.id.clone();
        self.themes.insert(id, theme);
    }

    pub fn activate(&mut self, id: &str) -> bool {
        if self.themes.contains_key(id) {
            self.active = id.to_owned();
            true
        } else {
            false
        }
    }

    pub fn active(&self) -> Option<&Theme> {
        self.themes.get(&self.active)
    }
    pub fn active_id(&self) -> &str {
        &self.active
    }

    pub fn list(&self) -> Vec<(&str, &str, &ThemeKind)> {
        let mut list: Vec<_> = self
            .themes
            .values()
            .map(|t| (t.id.as_str(), t.name.as_str(), &t.kind))
            .collect();
        list.sort_by_key(|(id, _, _)| *id);
        list
    }

    pub fn token_color(&self, kind: u8) -> ThemeColor {
        self.active()
            .map(|t| t.token_color(kind))
            .unwrap_or(ThemeColor::rgb(200, 200, 200))
    }
}

impl Default for ThemeEngine {
    fn default() -> Self {
        Self::new()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Snippet engine
// ═══════════════════════════════════════════════════════════════════════════════

/// A snippet template with tab stops.
///
/// Syntax (VS Code compatible):
///   $1, $2       — tab stop positions (cursor moves through them on Tab)
///   ${1:text}    — tab stop with placeholder text
///   ${1|a,b,c|}  — tab stop with choice list
///   $0           — final cursor position
///   $TM_FILENAME — variable substitution
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Snippet {
    pub prefix: String,
    pub body: Vec<String>, // lines of the template
    pub description: String,
    pub language: String,
}

impl Snippet {
    pub fn new(prefix: &str, body: &[&str], description: &str, language: &str) -> Self {
        Self {
            prefix: prefix.to_owned(),
            body: body.iter().map(|s| s.to_string()).collect(),
            description: description.to_owned(),
            language: language.to_owned(),
        }
    }

    /// The raw body joined into a single string.
    pub fn raw_body(&self) -> String {
        self.body.join("\n")
    }

    /// Expand the snippet, substituting variables and returning:
    ///   • The expanded text
    ///   • Tab stop positions [(byte_offset, length, placeholder_text)]
    pub fn expand(&self, vars: &HashMap<String, String>) -> ExpandedSnippet {
        let raw = self.raw_body();
        let mut text = String::new();
        let mut tab_stops: Vec<TabStop> = Vec::new();
        let mut i = 0;
        let chars: Vec<char> = raw.chars().collect();

        while i < chars.len() {
            if chars[i] == '$' && i + 1 < chars.len() {
                i += 1;
                if chars[i] == '{' {
                    // ${N:placeholder} or ${N|choice1,choice2|}
                    i += 1;
                    let mut num_str = String::new();
                    while i < chars.len() && chars[i].is_ascii_digit() {
                        num_str.push(chars[i]);
                        i += 1;
                    }
                    let idx: u32 = num_str.parse().unwrap_or(0);

                    let placeholder = if i < chars.len() && chars[i] == ':' {
                        i += 1;
                        let mut p = String::new();
                        while i < chars.len() && chars[i] != '}' {
                            p.push(chars[i]);
                            i += 1;
                        }
                        if i < chars.len() {
                            i += 1;
                        } // skip }
                        p
                    } else if i < chars.len() && chars[i] == '|' {
                        i += 1;
                        let mut choices = String::new();
                        while i < chars.len() && chars[i] != '|' {
                            choices.push(chars[i]);
                            i += 1;
                        }
                        while i < chars.len() && chars[i] != '}' {
                            i += 1;
                        }
                        if i < chars.len() {
                            i += 1;
                        }
                        // Use first choice as default
                        choices.split(',').next().unwrap_or("").to_owned()
                    } else {
                        while i < chars.len() && chars[i] != '}' {
                            i += 1;
                        }
                        if i < chars.len() {
                            i += 1;
                        }
                        String::new()
                    };

                    let start = text.len();
                    text.push_str(&placeholder);
                    tab_stops.push(TabStop {
                        index: idx,
                        start,
                        len: placeholder.len(),
                        placeholder,
                    });
                } else if chars[i].is_ascii_digit() {
                    let mut num_str = String::new();
                    while i < chars.len() && chars[i].is_ascii_digit() {
                        num_str.push(chars[i]);
                        i += 1;
                    }
                    let idx: u32 = num_str.parse().unwrap_or(0);
                    let start = text.len();
                    tab_stops.push(TabStop {
                        index: idx,
                        start,
                        len: 0,
                        placeholder: String::new(),
                    });
                } else {
                    // Variable: $TM_FILENAME etc.
                    let mut var_name = String::new();
                    while i < chars.len() && (chars[i].is_alphanumeric() || chars[i] == '_') {
                        var_name.push(chars[i]);
                        i += 1;
                    }
                    if let Some(val) = vars.get(&var_name) {
                        text.push_str(val);
                    }
                }
            } else {
                text.push(chars[i]);
                i += 1;
            }
        }

        // Sort tab stops by index (0 is final position)
        tab_stops.sort_by(|a, b| {
            if a.index == 0 {
                std::cmp::Ordering::Greater
            } else if b.index == 0 {
                std::cmp::Ordering::Less
            } else {
                a.index.cmp(&b.index)
            }
        });
        tab_stops.dedup_by_key(|ts| ts.index);

        ExpandedSnippet { text, tab_stops }
    }
}

#[derive(Debug, Clone)]
pub struct TabStop {
    /// 1-based index ($1, $2 ...). 0 = final cursor.
    pub index: u32,
    /// Byte offset in the expanded text.
    pub start: usize,
    pub len: usize,
    pub placeholder: String,
}

#[derive(Debug, Clone)]
pub struct ExpandedSnippet {
    pub text: String,
    pub tab_stops: Vec<TabStop>,
}

impl ExpandedSnippet {
    pub fn final_cursor(&self) -> usize {
        self.tab_stops
            .iter()
            .find(|ts| ts.index == 0)
            .map(|ts| ts.start)
            .unwrap_or(self.text.len())
    }

    pub fn first_tab_stop(&self) -> Option<&TabStop> {
        self.tab_stops.first()
    }
}

/// Registry of all loaded snippets.
#[derive(Default)]
pub struct SnippetEngine {
    /// language → list of snippets
    snippets: HashMap<String, Vec<Snippet>>,
}

impl SnippetEngine {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn register(&mut self, snippet: Snippet) {
        self.snippets
            .entry(snippet.language.clone())
            .or_default()
            .push(snippet);
    }

    pub fn register_all(&mut self, snippets: Vec<Snippet>) {
        for s in snippets {
            self.register(s);
        }
    }

    /// Find the snippet whose prefix matches the word before `cursor_text`.
    pub fn find_for_prefix(&self, language: &str, prefix: &str) -> Option<&Snippet> {
        self.snippets
            .get(language)?
            .iter()
            .find(|s| s.prefix == prefix)
    }

    pub fn all_for_language(&self, language: &str) -> &[Snippet] {
        self.snippets
            .get(language)
            .map(|v| v.as_slice())
            .unwrap_or(&[])
    }

    pub fn completions_for_language(&self, language: &str, prefix: &str) -> Vec<&Snippet> {
        self.snippets
            .get(language)
            .map(|snippets| {
                snippets
                    .iter()
                    .filter(|s| s.prefix.starts_with(prefix))
                    .collect()
            })
            .unwrap_or_default()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Language registry
// ═══════════════════════════════════════════════════════════════════════════════

/// Resolves file extensions and filenames to language IDs.
pub struct LanguageRegistry {
    contributions: Vec<LanguageContribution>,
}

impl LanguageRegistry {
    pub fn new() -> Self {
        let mut reg = Self {
            contributions: Vec::new(),
        };
        reg.register_builtins();
        reg
    }

    pub fn register(&mut self, contrib: LanguageContribution) {
        // Remove any existing contribution for the same ID (extension override)
        self.contributions.retain(|c| c.id != contrib.id);
        self.contributions.push(contrib);
    }

    pub fn detect(&self, filename: &str, first_line: Option<&str>) -> Option<&str> {
        // Extension match
        if let Some(dot) = filename.rfind('.') {
            let ext = &filename[dot..]; // e.g. ".rs"
            for c in &self.contributions {
                if c.extensions.iter().any(|e| e == ext) {
                    return Some(&c.id);
                }
            }
        }
        // Exact filename match
        for c in &self.contributions {
            if c.filenames.iter().any(|f| f == filename) {
                return Some(&c.id);
            }
        }
        // Shebang
        if let Some(line) = first_line {
            if line.starts_with("#!") {
                for c in &self.contributions {
                    if c.id == "python" && line.contains("python") {
                        return Some(&c.id);
                    }
                    if c.id == "javascript" && (line.contains("node") || line.contains("deno")) {
                        return Some(&c.id);
                    }
                    if c.id == "bash" && (line.contains("bash") || line.contains("/sh")) {
                        return Some(&c.id);
                    }
                }
            }
        }
        None
    }

    pub fn get(&self, id: &str) -> Option<&LanguageContribution> {
        self.contributions.iter().find(|c| c.id == id)
    }

    pub fn all_ids(&self) -> Vec<&str> {
        self.contributions.iter().map(|c| c.id.as_str()).collect()
    }

    fn register_builtins(&mut self) {
        use crate::ext::manifest::LanguageContribution as LC;
        let langs: &[(&str, &[&str])] = &[
            ("rust", &[".rs"]),
            ("javascript", &[".js", ".mjs", ".cjs"]),
            ("typescript", &[".ts"]),
            ("jsx", &[".jsx"]),
            ("tsx", &[".tsx"]),
            ("python", &[".py", ".pyw"]),
            ("java", &[".java"]),
            ("kotlin", &[".kt", ".kts"]),
            ("go", &[".go"]),
            ("c", &[".c", ".h"]),
            ("cpp", &[".cpp", ".cc", ".cxx", ".hpp"]),
            ("csharp", &[".cs"]),
            ("ruby", &[".rb"]),
            ("swift", &[".swift"]),
            ("dart", &[".dart"]),
            ("html", &[".html", ".htm"]),
            ("css", &[".css"]),
            ("scss", &[".scss", ".sass"]),
            ("json", &[".json"]),
            ("toml", &[".toml"]),
            ("yaml", &[".yaml", ".yml"]),
            ("markdown", &[".md", ".mdx"]),
            ("bash", &[".sh", ".bash", ".zsh"]),
            ("sql", &[".sql"]),
        ];
        for (id, exts) in langs {
            self.contributions.push(LC::new(id).with_extensions(exts));
        }
        // Special filenames
        let mut makefile = LC::new("makefile");
        makefile.filenames = vec!["Makefile".into(), "makefile".into(), "GNUmakefile".into()];
        self.contributions.push(makefile);

        let mut dockerfile = LC::new("dockerfile");
        dockerfile.filenames = vec!["Dockerfile".into()];
        self.contributions.push(dockerfile);
    }
}

impl Default for LanguageRegistry {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── ThemeColor ────────────────────────────────────────────────────────────

    #[test]
    fn test_color_from_hex() {
        let c = ThemeColor::from_hex("#FF79C6").unwrap();
        assert_eq!(c.r, 255);
        assert_eq!(c.g, 121);
        assert_eq!(c.b, 198);
        assert_eq!(c.a, 255);
    }

    #[test]
    fn test_color_from_hex_with_alpha() {
        let c = ThemeColor::from_hex("#FF79C680").unwrap();
        assert_eq!(c.a, 128);
    }

    #[test]
    fn test_color_to_hex_roundtrip() {
        let c = ThemeColor::rgb(80, 250, 123);
        let h = c.to_hex();
        let restored = ThemeColor::from_hex(&h).unwrap();
        assert_eq!(c, restored);
    }

    #[test]
    fn test_color_invalid_hex() {
        assert!(ThemeColor::from_hex("not-a-color").is_none());
        assert!(ThemeColor::from_hex("#FFFFF").is_none()); // wrong length
    }

    // ── ThemeEngine ───────────────────────────────────────────────────────────

    #[test]
    fn test_theme_engine_default_themes() {
        let engine = ThemeEngine::new();
        let list = engine.list();
        assert!(list.iter().any(|(id, _, _)| *id == "waraq.dracula"));
        assert!(list.iter().any(|(id, _, _)| *id == "waraq.github-light"));
    }

    #[test]
    fn test_theme_engine_activate() {
        let mut engine = ThemeEngine::new();
        assert!(engine.activate("waraq.github-light"));
        assert_eq!(engine.active_id(), "waraq.github-light");
        assert!(!engine.activate("nonexistent.theme"));
    }

    #[test]
    fn test_theme_token_color() {
        let engine = ThemeEngine::new();
        let kw_color = engine.token_color(1); // Keyword
        assert_eq!(kw_color, ThemeColor::rgb(255, 121, 198)); // Dracula pink
    }

    #[test]
    fn test_register_custom_theme() {
        let mut engine = ThemeEngine::new();
        let custom = Theme {
            id: "custom.theme".into(),
            name: "My Custom Theme".into(),
            kind: ThemeKind::Dark,
            tokens: HashMap::new(),
            background: ThemeColor::rgb(10, 10, 10),
            foreground: ThemeColor::rgb(240, 240, 240),
            selection: ThemeColor::rgba(100, 100, 200, 100),
            cursor: ThemeColor::rgb(255, 255, 255),
            current_line: ThemeColor::rgb(20, 20, 20),
            line_number: ThemeColor::rgb(100, 100, 100),
            gutter_bg: ThemeColor::rgb(5, 5, 5),
            search_match: ThemeColor::rgba(200, 200, 0, 80),
            search_match_active: ThemeColor::rgba(255, 200, 0, 130),
            error_fg: ThemeColor::rgb(255, 0, 0),
            warning_fg: ThemeColor::rgb(255, 165, 0),
            info_fg: ThemeColor::rgb(0, 150, 255),
        };
        engine.register(custom);
        assert!(engine.activate("custom.theme"));
        assert_eq!(
            engine.active().unwrap().background,
            ThemeColor::rgb(10, 10, 10)
        );
    }

    // ── SnippetEngine ─────────────────────────────────────────────────────────

    #[test]
    fn test_snippet_basic_expansion() {
        let s = Snippet::new("fn", &["fn $1($2) {", "    $0", "}"], "Function", "rust");
        let expanded = s.expand(&HashMap::new());
        assert!(expanded.text.contains("fn"));
        assert!(!expanded.tab_stops.is_empty());
    }

    #[test]
    fn test_snippet_with_placeholder() {
        let s = Snippet::new("if", &["if ${1:condition} {", "    $0", "}"], "If", "rust");
        let expanded = s.expand(&HashMap::new());
        assert!(
            expanded.text.contains("condition"),
            "Placeholder should be in expanded text"
        );
        assert!(expanded
            .tab_stops
            .iter()
            .any(|ts| ts.placeholder == "condition"));
    }

    #[test]
    fn test_snippet_final_cursor() {
        let s = Snippet::new("fn", &["fn $1() { $0 }"], "Fn", "rust");
        let expanded = s.expand(&HashMap::new());
        let final_pos = expanded.final_cursor();
        // $0 is at position after "fn () { " = 9 chars
        assert!(final_pos > 0, "Final cursor should be > 0");
    }

    #[test]
    fn test_snippet_variable_substitution() {
        let s = Snippet::new("file", &["// $TM_FILENAME"], "Filename header", "rust");
        let mut vars = HashMap::new();
        vars.insert("TM_FILENAME".into(), "main.rs".into());
        let expanded = s.expand(&vars);
        assert!(
            expanded.text.contains("main.rs"),
            "Variable should be substituted"
        );
    }

    #[test]
    fn test_snippet_engine_find_by_prefix() {
        let mut engine = SnippetEngine::new();
        engine.register(Snippet::new("fn", &["fn $1() {}"], "Function", "rust"));
        engine.register(Snippet::new(
            "for",
            &["for $1 in $2 {}"],
            "For loop",
            "rust",
        ));
        assert!(engine.find_for_prefix("rust", "fn").is_some());
        assert!(engine.find_for_prefix("rust", "for").is_some());
        assert!(engine.find_for_prefix("rust", "while").is_none());
        assert!(engine.find_for_prefix("python", "fn").is_none()); // wrong language
    }

    #[test]
    fn test_snippet_completions_for_prefix() {
        let mut engine = SnippetEngine::new();
        engine.register(Snippet::new("fn", &["fn $1() {}"], "Function", "rust"));
        engine.register(Snippet::new("for", &["for $1 {}"], "For", "rust"));
        engine.register(Snippet::new("fmt", &["fmt::"], "Fmt", "rust"));
        let completions = engine.completions_for_language("rust", "f");
        assert_eq!(completions.len(), 3);
    }

    // ── LanguageRegistry ──────────────────────────────────────────────────────

    #[test]
    fn test_language_registry_detect_by_extension() {
        let reg = LanguageRegistry::new();
        assert_eq!(reg.detect("main.rs", None), Some("rust"));
        assert_eq!(reg.detect("app.js", None), Some("javascript"));
        assert_eq!(reg.detect("script.py", None), Some("python"));
        assert_eq!(reg.detect("style.css", None), Some("css"));
    }

    #[test]
    fn test_language_registry_detect_makefile() {
        let reg = LanguageRegistry::new();
        assert_eq!(reg.detect("Makefile", None), Some("makefile"));
        assert_eq!(reg.detect("makefile", None), Some("makefile"));
    }

    #[test]
    fn test_language_registry_detect_dockerfile() {
        let reg = LanguageRegistry::new();
        assert_eq!(reg.detect("Dockerfile", None), Some("dockerfile"));
    }

    #[test]
    fn test_language_registry_unknown() {
        let reg = LanguageRegistry::new();
        assert!(reg.detect("unknown.xyz", None).is_none());
    }

    #[test]
    fn test_language_registry_shebang() {
        let reg = LanguageRegistry::new();
        assert_eq!(
            reg.detect("script", Some("#!/usr/bin/env python3")),
            Some("python")
        );
        assert_eq!(
            reg.detect("server", Some("#!/usr/bin/env node")),
            Some("javascript")
        );
    }

    #[test]
    fn test_language_registry_override() {
        let mut reg = LanguageRegistry::new();
        // Register a new language with .myext
        let lang = LanguageContribution::new("my-dsl").with_extensions(&[".myext"]);
        reg.register(lang);
        assert_eq!(reg.detect("file.myext", None), Some("my-dsl"));
    }

    #[test]
    fn test_language_registry_all_ids() {
        let reg = LanguageRegistry::new();
        let ids = reg.all_ids();
        assert!(ids.contains(&"rust"));
        assert!(ids.contains(&"python"));
        assert!(ids.len() >= 20);
    }
}
