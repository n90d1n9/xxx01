// src/core/settings.rs
//
// Settings persistence — stores user preferences and workspace-level settings.
//
// Three layers (VS Code model):
//   Default  — built-in defaults (from Config::default())
//   User     — ~/.config/waraq/settings.json  (persists across workspaces)
//   Workspace — <workspace>/.waraq/settings.json  (project-specific overrides)
//
// The resolved config is: Default ← overridden by User ← overridden by Workspace.
//
// Settings keys match EditorConfig / VS Code naming conventions:
//   "editor.tabSize"             → config.indent_width
//   "editor.insertSpaces"        → config.indent_style
//   "editor.wordWrap"            → config.word_wrap ("off" / "on" / "bounded")
//   "editor.wordWrapColumn"      → config.word_wrap Column(n)
//   "editor.trimAutoWhitespace"  → config.trim_trailing_whitespace
//   "editor.renderWhitespace"    → config.show_whitespace
//   "editor.cursorStyle"         → config.cursor_style
//   "editor.fontSize"            → config.font_size
//   "editor.fontFamily"          → config.font_family
//   "editor.lineNumbers"         → config.show_line_numbers
//   "editor.highlightActiveLine" → config.highlight_current_line
//   "files.insertFinalNewline"   → config.insert_final_newline
//   "files.trimTrailingWhitespace" → config.trim_trailing_whitespace
//   "[rust]" / "[python]"        → per-language overrides

use crate::core::config::{Config, CursorStyle, IndentStyle, WordWrap};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Setting value ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum SettingValue {
    Bool(bool),
    Int(i64),
    Float(f64),
    String(String),
    Array(Vec<SettingValue>),
    Object(HashMap<String, SettingValue>),
    Null,
}

impl SettingValue {
    pub fn as_bool(&self) -> Option<bool> {
        if let Self::Bool(b) = self {
            Some(*b)
        } else {
            None
        }
    }
    pub fn as_int(&self) -> Option<i64> {
        match self {
            Self::Int(i) => Some(*i),
            Self::Float(f) => Some(*f as i64),
            _ => None,
        }
    }
    pub fn as_str(&self) -> Option<&str> {
        if let Self::String(s) = self {
            Some(s)
        } else {
            None
        }
    }
    pub fn as_float(&self) -> Option<f64> {
        match self {
            Self::Float(f) => Some(*f),
            Self::Int(i) => Some(*i as f64),
            _ => None,
        }
    }
}

impl From<bool> for SettingValue {
    fn from(v: bool) -> Self {
        Self::Bool(v)
    }
}
impl From<i64> for SettingValue {
    fn from(v: i64) -> Self {
        Self::Int(v)
    }
}
impl From<u32> for SettingValue {
    fn from(v: u32) -> Self {
        Self::Int(v as i64)
    }
}
impl From<f64> for SettingValue {
    fn from(v: f64) -> Self {
        Self::Float(v)
    }
}
impl From<String> for SettingValue {
    fn from(v: String) -> Self {
        Self::String(v)
    }
}
impl From<&str> for SettingValue {
    fn from(v: &str) -> Self {
        Self::String(v.to_owned())
    }
}

// ── Settings store ────────────────────────────────────────────────────────────

/// A flat key→value settings store (one layer).
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SettingsStore {
    #[serde(flatten)]
    values: HashMap<String, serde_json::Value>,
}

impl SettingsStore {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        Ok(serde_json::from_str(json)?)
    }

    pub fn to_json_pretty(&self) -> String {
        serde_json::to_string_pretty(&self.values).unwrap_or_default()
    }

    pub fn set(&mut self, key: &str, value: serde_json::Value) {
        self.values.insert(key.to_owned(), value);
    }

    pub fn get(&self, key: &str) -> Option<&serde_json::Value> {
        self.values.get(key)
    }

    pub fn remove(&mut self, key: &str) -> bool {
        self.values.remove(key).is_some()
    }

    pub fn contains(&self, key: &str) -> bool {
        self.values.contains_key(key)
    }

    pub fn keys(&self) -> Vec<&str> {
        self.values.keys().map(|k| k.as_str()).collect()
    }

    pub fn is_empty(&self) -> bool {
        self.values.is_empty()
    }
    pub fn len(&self) -> usize {
        self.values.len()
    }

    /// Merge another store into this one (other wins on conflicts).
    pub fn merge(&mut self, other: &Self) {
        for (k, v) in &other.values {
            self.values.insert(k.clone(), v.clone());
        }
    }
}

// ── Layered settings ──────────────────────────────────────────────────────────

/// Manages default + user + workspace settings with proper precedence.
pub struct LayeredSettings {
    pub user: SettingsStore,
    pub workspace: SettingsStore,
    /// Per-language overrides e.g. "[rust]" → store
    pub language_overrides: HashMap<String, SettingsStore>,
}

impl LayeredSettings {
    pub fn new() -> Self {
        Self {
            user: SettingsStore::new(),
            workspace: SettingsStore::new(),
            language_overrides: HashMap::new(),
        }
    }

    /// Load from a JSON string representing the full settings object.
    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        let mut ls = Self::new();
        let parsed: serde_json::Value = serde_json::from_str(json)?;
        if let Some(obj) = parsed.as_object() {
            for (key, val) in obj {
                if key.starts_with('[') && key.ends_with(']') {
                    // Language-specific override
                    let lang = key[1..key.len() - 1].to_owned();
                    let mut store = SettingsStore::new();
                    if let Some(inner) = val.as_object() {
                        for (k, v) in inner {
                            store.set(k, v.clone());
                        }
                    }
                    ls.language_overrides.insert(lang, store);
                } else {
                    ls.user.set(key, val.clone());
                }
            }
        }
        Ok(ls)
    }

    /// Get a setting value, checking workspace → user → default order.
    pub fn get(&self, key: &str) -> Option<&serde_json::Value> {
        self.workspace.get(key).or_else(|| self.user.get(key))
    }

    /// Get a setting with a language override applied.
    pub fn get_for_language<'a>(
        &'a self,
        key: &str,
        language: &str,
    ) -> Option<&'a serde_json::Value> {
        // Language override wins over workspace wins over user
        let lang_key = format!("[{}]", language);
        if let Some(lang_store) = self
            .language_overrides
            .get(language)
            .or_else(|| self.language_overrides.get(&lang_key))
        {
            if let Some(v) = lang_store.get(key) {
                return Some(v);
            }
        }
        self.get(key)
    }

    /// Serialise all layers to JSON.
    pub fn to_json(&self) -> String {
        let mut merged = serde_json::Map::new();
        for (k, v) in &self.user.values {
            merged.insert(k.clone(), v.clone());
        }
        for (k, v) in &self.workspace.values {
            merged.insert(k.clone(), v.clone());
        }
        for (lang, store) in &self.language_overrides {
            let lang_key = format!("[{}]", lang);
            let inner: serde_json::Map<String, serde_json::Value> =
                store.values.clone().into_iter().collect();
            merged.insert(lang_key, serde_json::Value::Object(inner));
        }
        serde_json::to_string_pretty(&merged).unwrap_or_default()
    }

    // ── Apply to Config ───────────────────────────────────────────────────────

    /// Apply settings to a Config, optionally for a specific language.
    pub fn apply_to_config(&self, config: &mut Config, language: Option<&str>) {
        let get = |key: &str| -> Option<&serde_json::Value> {
            if let Some(lang) = language {
                self.get_for_language(key, lang)
            } else {
                self.get(key)
            }
        };

        if let Some(v) = get("editor.tabSize").and_then(|v| v.as_u64()) {
            config.tab_width = v as u32;
            config.indent_width = v as u32;
        }
        if let Some(v) = get("editor.insertSpaces").and_then(|v| v.as_bool()) {
            config.indent_style = if v {
                IndentStyle::Spaces
            } else {
                IndentStyle::Tabs
            };
        }
        if let Some(v) = get("editor.wordWrap").and_then(|v| v.as_str()) {
            config.word_wrap = match v {
                "on" => WordWrap::On,
                "bounded" => {
                    let col = get("editor.wordWrapColumn")
                        .and_then(|v| v.as_u64())
                        .unwrap_or(80) as u32;
                    WordWrap::Column(col)
                }
                _ => WordWrap::Off,
            };
        }
        if let Some(v) = get("editor.trimAutoWhitespace").and_then(|v| v.as_bool()) {
            config.trim_trailing_whitespace = v;
        }
        if let Some(v) = get("files.insertFinalNewline").and_then(|v| v.as_bool()) {
            config.insert_final_newline = v;
        }
        if let Some(v) = get("editor.renderWhitespace").and_then(|v| v.as_str()) {
            config.show_whitespace = v != "none";
        }
        if let Some(v) = get("editor.cursorStyle").and_then(|v| v.as_str()) {
            config.cursor_style = match v {
                "block" => CursorStyle::Block,
                "underline" => CursorStyle::Underline,
                _ => CursorStyle::Bar,
            };
        }
        if let Some(v) = get("editor.fontSize").and_then(|v| v.as_f64()) {
            config.font_size = v as f32;
        }
        if let Some(v) = get("editor.fontFamily").and_then(|v| v.as_str()) {
            config.font_family = v.to_owned();
        }
        if let Some(v) = get("editor.lineNumbers").and_then(|v| v.as_str()) {
            config.show_line_numbers = v != "off";
        }
    }

    /// Build a resolved `Config` from default + settings.
    pub fn resolve_config(&self, language: Option<&str>) -> Config {
        let mut cfg = Config::default();
        self.apply_to_config(&mut cfg, language);
        cfg
    }
}

impl Default for LayeredSettings {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── SettingValue ──────────────────────────────────────────────────────────

    #[test]
    fn test_setting_value_conversions() {
        let b: SettingValue = true.into();
        assert_eq!(b.as_bool(), Some(true));

        let i: SettingValue = 42i64.into();
        assert_eq!(i.as_int(), Some(42));

        let s: SettingValue = "hello".into();
        assert_eq!(s.as_str(), Some("hello"));

        let f: SettingValue = 3.14f64.into();
        assert!((f.as_float().unwrap() - 3.14).abs() < 0.001);
    }

    // ── SettingsStore ─────────────────────────────────────────────────────────

    #[test]
    fn test_settings_store_set_get() {
        let mut s = SettingsStore::new();
        s.set("editor.tabSize", serde_json::json!(4));
        assert_eq!(s.get("editor.tabSize").unwrap(), &serde_json::json!(4));
    }

    #[test]
    fn test_settings_store_remove() {
        let mut s = SettingsStore::new();
        s.set("key", serde_json::json!(1));
        assert!(s.remove("key"));
        assert!(!s.contains("key"));
    }

    #[test]
    fn test_settings_store_merge() {
        let mut base = SettingsStore::new();
        base.set("a", serde_json::json!(1));
        base.set("b", serde_json::json!(2));

        let mut override_store = SettingsStore::new();
        override_store.set("b", serde_json::json!(99));
        override_store.set("c", serde_json::json!(3));

        base.merge(&override_store);
        assert_eq!(base.get("a").unwrap(), &serde_json::json!(1));
        assert_eq!(base.get("b").unwrap(), &serde_json::json!(99)); // overridden
        assert_eq!(base.get("c").unwrap(), &serde_json::json!(3)); // new key
    }

    #[test]
    fn test_settings_store_json_roundtrip() {
        let mut s = SettingsStore::new();
        s.set("editor.tabSize", serde_json::json!(2));
        s.set("editor.insertSpaces", serde_json::json!(true));
        s.set("editor.fontFamily", serde_json::json!("JetBrains Mono"));

        let json = s.to_json_pretty();
        let restored = SettingsStore::from_json(&json).unwrap();
        assert_eq!(
            restored.get("editor.tabSize").unwrap(),
            &serde_json::json!(2)
        );
        assert_eq!(
            restored.get("editor.insertSpaces").unwrap(),
            &serde_json::json!(true)
        );
    }

    // ── LayeredSettings ───────────────────────────────────────────────────────

    #[test]
    fn test_workspace_overrides_user() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.tabSize", serde_json::json!(4));
        ls.workspace.set("editor.tabSize", serde_json::json!(2)); // workspace wins
        assert_eq!(ls.get("editor.tabSize").unwrap(), &serde_json::json!(2));
    }

    #[test]
    fn test_user_fallback_when_no_workspace() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.fontSize", serde_json::json!(14));
        assert_eq!(ls.get("editor.fontSize").unwrap(), &serde_json::json!(14));
    }

    #[test]
    fn test_missing_key_returns_none() {
        let ls = LayeredSettings::new();
        assert!(ls.get("editor.nonexistent").is_none());
    }

    #[test]
    fn test_language_override() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.tabSize", serde_json::json!(4));
        // Python uses 4 spaces, but Go uses tabs
        let mut go_override = SettingsStore::new();
        go_override.set("editor.tabSize", serde_json::json!(8));
        go_override.set("editor.insertSpaces", serde_json::json!(false));
        ls.language_overrides.insert("go".to_owned(), go_override);

        // Default → 4
        assert_eq!(
            ls.get_for_language("editor.tabSize", "rust").unwrap(),
            &serde_json::json!(4)
        );
        // Go → 8
        assert_eq!(
            ls.get_for_language("editor.tabSize", "go").unwrap(),
            &serde_json::json!(8)
        );
    }

    #[test]
    fn test_apply_to_config_tab_size() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.tabSize", serde_json::json!(2));
        ls.user.set("editor.insertSpaces", serde_json::json!(true));

        let mut cfg = Config::default();
        ls.apply_to_config(&mut cfg, None);
        assert_eq!(cfg.indent_width, 2);
        assert_eq!(cfg.indent_style, IndentStyle::Spaces);
    }

    #[test]
    fn test_apply_to_config_word_wrap() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.wordWrap", serde_json::json!("bounded"));
        ls.user.set("editor.wordWrapColumn", serde_json::json!(100));

        let cfg = ls.resolve_config(None);
        assert!(matches!(cfg.word_wrap, WordWrap::Column(100)));
    }

    #[test]
    fn test_apply_to_config_word_wrap_on() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.wordWrap", serde_json::json!("on"));
        let cfg = ls.resolve_config(None);
        assert!(matches!(cfg.word_wrap, WordWrap::On));
    }

    #[test]
    fn test_apply_to_config_word_wrap_off() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.wordWrap", serde_json::json!("off"));
        let cfg = ls.resolve_config(None);
        assert!(matches!(cfg.word_wrap, WordWrap::Off));
    }

    #[test]
    fn test_apply_to_config_cursor_style() {
        let mut ls = LayeredSettings::new();
        ls.user
            .set("editor.cursorStyle", serde_json::json!("underline"));
        let cfg = ls.resolve_config(None);
        assert_eq!(cfg.cursor_style, CursorStyle::Underline);
    }

    #[test]
    fn test_from_json_with_language_override() {
        let json = r#"{
            "editor.tabSize": 4,
            "editor.insertSpaces": true,
            "[rust]": { "editor.tabSize": 4, "editor.insertSpaces": true },
            "[go]":   { "editor.tabSize": 8, "editor.insertSpaces": false }
        }"#;
        let ls = LayeredSettings::from_json(json).unwrap();
        assert_eq!(ls.get("editor.tabSize").unwrap(), &serde_json::json!(4));
        assert_eq!(
            ls.get_for_language("editor.tabSize", "go").unwrap(),
            &serde_json::json!(8)
        );
    }

    #[test]
    fn test_to_json_roundtrip() {
        let mut ls = LayeredSettings::new();
        ls.user.set("editor.tabSize", serde_json::json!(2));
        ls.user
            .set("editor.fontFamily", serde_json::json!("Fira Code"));
        let json = ls.to_json();
        let ls2 = LayeredSettings::from_json(&json).unwrap();
        assert_eq!(ls2.get("editor.tabSize").unwrap(), &serde_json::json!(2));
    }

    #[test]
    fn test_resolve_config_default_values() {
        let ls = LayeredSettings::new(); // no settings
        let cfg = ls.resolve_config(None);
        // Should have sensible defaults
        assert!(cfg.indent_width > 0);
    }
}
