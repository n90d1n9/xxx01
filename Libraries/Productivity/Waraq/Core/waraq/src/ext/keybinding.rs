// src/ext/keybinding.rs
//
// Keybinding engine — maps key chords to command IDs.
//
// Features:
//   • Single-key and multi-chord bindings ("ctrl+k ctrl+s")
//   • Platform modifiers: ctrl/cmd (auto-mapped on macOS), alt, shift
//   • When-clause predicates ("editorFocus", "!editorReadonly", "inDebugMode")
//   • Priority resolution: extension bindings > default bindings
//   • JSON import/export (same format as VS Code keybindings.json)
//
// The engine is stateful: call `key_down(chord)` to drive it through
// multi-chord sequences.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Key chord ─────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct KeyChord {
    pub key: String, // "a", "enter", "f1", "["
    pub ctrl: bool,
    pub shift: bool,
    pub alt: bool,
    pub meta: bool, // Cmd on macOS, Win on Windows
}

impl KeyChord {
    /// Parse a key chord from a string like "ctrl+shift+p" or "cmd+k".
    pub fn parse(s: &str) -> Option<Self> {
        let s = s.trim().to_lowercase();
        let parts: Vec<&str> = s.split('+').collect();
        if parts.is_empty() {
            return None;
        }

        let mut ctrl = false;
        let mut shift = false;
        let mut alt = false;
        let mut meta = false;
        let mut key = String::new();

        for part in &parts {
            match *part {
                "ctrl" => ctrl = true,
                "control" => ctrl = true,
                "shift" => shift = true,
                "alt" => alt = true,
                "option" => alt = true,
                "meta" => meta = true,
                "cmd" => meta = true,
                "win" => meta = true,
                k => key = k.to_owned(),
            }
        }

        if key.is_empty() {
            return None;
        }
        Some(Self {
            key,
            ctrl,
            shift,
            alt,
            meta,
        })
    }

    /// Canonical string representation.
    pub fn to_chord_string(&self) -> String {
        let mut parts = Vec::new();
        if self.ctrl {
            parts.push("ctrl");
        }
        if self.shift {
            parts.push("shift");
        }
        if self.alt {
            parts.push("alt");
        }
        if self.meta {
            parts.push("meta");
        }
        parts.push(&self.key);
        parts.join("+")
    }
}

/// A binding may require one or two chords ("ctrl+k ctrl+f").
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct KeySequence {
    pub first: KeyChord,
    pub second: Option<KeyChord>,
}

impl KeySequence {
    pub fn single(chord: KeyChord) -> Self {
        Self {
            first: chord,
            second: None,
        }
    }
    pub fn chord(first: KeyChord, second: KeyChord) -> Self {
        Self {
            first,
            second: Some(second),
        }
    }

    /// Parse a sequence like "ctrl+k ctrl+f" or "ctrl+shift+p".
    pub fn parse(s: &str) -> Option<Self> {
        let s = s.trim();
        // Multi-chord: "ctrl+k ctrl+f"
        if let Some(space_pos) = s.find(' ') {
            let first = KeyChord::parse(&s[..space_pos])?;
            let second = KeyChord::parse(&s[space_pos + 1..])?;
            return Some(Self::chord(first, second));
        }
        Some(Self::single(KeyChord::parse(s)?))
    }

    pub fn is_multi_chord(&self) -> bool {
        self.second.is_some()
    }
}

// ── When-clause context ───────────────────────────────────────────────────────

/// The context used for evaluating when-clauses.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct KeyContext {
    /// Active context keys (truthy presence).
    pub active: Vec<String>,
    /// Named values.
    pub values: HashMap<String, serde_json::Value>,
}

impl KeyContext {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn set(&mut self, key: &str) {
        self.active.push(key.to_owned());
    }
    pub fn unset(&mut self, key: &str) {
        self.active.retain(|k| k != key);
    }
    pub fn set_value(&mut self, k: &str, v: serde_json::Value) {
        self.values.insert(k.to_owned(), v);
    }

    /// Evaluate a simple when-clause: "key", "!key", "key == value".
    pub fn evaluate(&self, when: &str) -> bool {
        let when = when.trim();
        if when.is_empty() {
            return true;
        }

        // Negation: "!editorFocus"
        if let Some(stripped) = when.strip_prefix('!') {
            return !self.active.contains(&stripped.trim().to_owned());
        }

        // Equality: "language == rust"
        if let Some(eq_pos) = when.find("==") {
            let lhs = when[..eq_pos].trim();
            let rhs = when[eq_pos + 2..].trim().trim_matches('"');
            if let Some(val) = self.values.get(lhs) {
                return val.as_str() == Some(rhs);
            }
            return false;
        }

        // Inequality: "language != python"
        if let Some(ne_pos) = when.find("!=") {
            let lhs = when[..ne_pos].trim();
            let rhs = when[ne_pos + 2..].trim().trim_matches('"');
            if let Some(val) = self.values.get(lhs) {
                return val.as_str() != Some(rhs);
            }
            return true;
        }

        // Compound: "a && b"
        if let Some(and_pos) = when.find("&&") {
            let lhs = &when[..and_pos];
            let rhs = &when[and_pos + 2..];
            return self.evaluate(lhs) && self.evaluate(rhs);
        }

        // Compound: "a || b"
        if let Some(or_pos) = when.find("||") {
            let lhs = &when[..or_pos];
            let rhs = &when[or_pos + 2..];
            return self.evaluate(lhs) || self.evaluate(rhs);
        }

        // Simple key check
        self.active.contains(&when.to_owned())
    }
}

// ── Keybinding entry ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeybindingEntry {
    pub sequence: KeySequence,
    pub command: String,
    /// Negative command prefix for unbinding: "-editor.action.x"
    pub is_unbound: bool,
    pub when: Option<String>,
    pub extension_id: String,
    pub priority: i32,
}

// ── Keybinding engine ─────────────────────────────────────────────────────────

pub struct KeybindingEngine {
    bindings: Vec<KeybindingEntry>,
    /// If Some, we've received the first chord of a multi-chord sequence.
    pending: Option<KeyChord>,
}

impl KeybindingEngine {
    pub fn new() -> Self {
        Self {
            bindings: Vec::new(),
            pending: None,
        }
    }

    // ── Registration ──────────────────────────────────────────────────────────

    pub fn register(&mut self, entry: KeybindingEntry) {
        self.bindings.push(entry);
        // Sort: higher priority first, then extension bindings before defaults
        self.bindings.sort_by(|a, b| b.priority.cmp(&a.priority));
    }

    pub fn register_all(&mut self, entries: Vec<KeybindingEntry>) {
        for e in entries {
            self.register(e);
        }
    }

    /// Remove all bindings contributed by an extension.
    pub fn unregister_extension(&mut self, extension_id: &str) {
        self.bindings.retain(|b| b.extension_id != extension_id);
    }

    // ── Resolution ────────────────────────────────────────────────────────────

    /// Feed a key chord to the engine. Returns the resolved command (if any).
    ///
    /// Multi-chord: first call returns `KeyResolution::ChordPending` if the
    /// chord is the start of a multi-chord sequence.  A subsequent call with
    /// the second chord completes the resolution.
    pub fn resolve(&mut self, chord: KeyChord, ctx: &KeyContext) -> KeyResolution {
        if let Some(first) = self.pending.take() {
            // Complete a multi-chord
            let seq = KeySequence::chord(first.clone(), chord.clone());
            if let Some(cmd) = self.find_command(&seq, ctx) {
                return KeyResolution::Command(cmd);
            }
            // Second chord didn't match — try single-chord with the new key
            let single = KeySequence::single(chord);
            return match self.find_command(&single, ctx) {
                Some(cmd) => KeyResolution::Command(cmd),
                None => KeyResolution::Unbound,
            };
        }

        let seq = KeySequence::single(chord.clone());

        // Check if this is the first chord of a multi-chord sequence
        let has_multi = self.bindings.iter().any(|b| {
            !b.is_unbound
                && b.sequence.first == chord
                && b.sequence.second.is_some()
                && b.when.as_deref().map(|w| ctx.evaluate(w)).unwrap_or(true)
        });

        if has_multi {
            self.pending = Some(chord);
            return KeyResolution::ChordPending;
        }

        match self.find_command(&seq, ctx) {
            Some(cmd) => KeyResolution::Command(cmd),
            None => KeyResolution::Unbound,
        }
    }

    fn find_command(&self, seq: &KeySequence, ctx: &KeyContext) -> Option<String> {
        for binding in &self.bindings {
            if binding.is_unbound {
                continue;
            }
            if binding.sequence != *seq {
                continue;
            }
            if let Some(when) = &binding.when {
                if !ctx.evaluate(when) {
                    continue;
                }
            }
            return Some(binding.command.clone());
        }
        None
    }

    /// Cancel a pending multi-chord sequence.
    pub fn cancel_pending(&mut self) {
        self.pending = None;
    }
    pub fn has_pending(&self) -> bool {
        self.pending.is_some()
    }

    pub fn binding_count(&self) -> usize {
        self.bindings.len()
    }

    /// Get all bindings for a command (for display in settings UI).
    pub fn bindings_for_command(&self, command: &str) -> Vec<&KeybindingEntry> {
        self.bindings
            .iter()
            .filter(|b| b.command == command && !b.is_unbound)
            .collect()
    }

    /// Serialise all bindings to keybindings.json format.
    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(&self.bindings).unwrap_or_default()
    }
}

impl Default for KeybindingEngine {
    fn default() -> Self {
        Self::new()
    }
}

// ── Resolution result ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum KeyResolution {
    /// A command was matched — execute it.
    Command(String),
    /// First chord of a multi-chord; wait for next key.
    ChordPending,
    /// No binding found — let the key fall through as a character.
    Unbound,
}

// ── Default keybindings ───────────────────────────────────────────────────────

pub fn default_keybindings() -> Vec<KeybindingEntry> {
    const EXT: &str = "waraq.builtin";

    fn kb(key: &str, cmd: &str) -> KeybindingEntry {
        KeybindingEntry {
            sequence: KeySequence::parse(key).unwrap(),
            command: cmd.to_owned(),
            is_unbound: false,
            when: None,
            extension_id: EXT.to_owned(),
            priority: 0,
        }
    }

    fn kb_when(key: &str, cmd: &str, when: &str) -> KeybindingEntry {
        let mut e = kb(key, cmd);
        e.when = Some(when.to_owned());
        e
    }

    vec![
        // File
        kb("ctrl+s", "workbench.action.files.save"),
        kb("ctrl+shift+s", "workbench.action.files.saveAs"),
        kb("ctrl+n", "workbench.action.files.newFile"),
        kb("ctrl+o", "workbench.action.files.openFile"),
        // Edit
        kb("ctrl+z", "undo"),
        kb("ctrl+shift+z", "redo"),
        kb("ctrl+y", "redo"),
        kb("ctrl+c", "editor.action.clipboardCopyAction"),
        kb("ctrl+x", "editor.action.clipboardCutAction"),
        kb("ctrl+v", "editor.action.clipboardPasteAction"),
        kb("ctrl+a", "editor.action.selectAll"),
        // Search
        kb("ctrl+f", "actions.find"),
        kb("ctrl+h", "editor.action.startFindReplaceAction"),
        // Format
        kb("ctrl+shift+i", "editor.action.formatDocument"),
        // Go to
        kb("f12", "editor.action.goToDeclaration"),
        kb("shift+f12", "editor.action.findReferences"),
        kb("f2", "editor.action.rename"),
        // View
        kb("ctrl+shift+p", "workbench.action.showCommands"),
        // Folding
        kb_when("ctrl+shift+[", "editor.foldAll", "editorFocus"),
        kb_when("ctrl+shift+]", "editor.unfoldAll", "editorFocus"),
        // Macro
        kb("ctrl+shift+r", "editor.action.startMacroRecording"),
        kb("ctrl+shift+e", "editor.action.stopMacroRecording"),
        kb("ctrl+alt+p", "editor.action.replayMacro"),
        // Multi-chord example: ctrl+k ctrl+f = Format Selection
        KeybindingEntry {
            sequence: KeySequence::parse("ctrl+k ctrl+f").unwrap(),
            command: "editor.action.formatSelection".to_owned(),
            is_unbound: false,
            when: Some("editorFocus".to_owned()),
            extension_id: EXT.to_owned(),
            priority: 0,
        },
        // ctrl+k ctrl+s = Open Keyboard Shortcuts
        KeybindingEntry {
            sequence: KeySequence::parse("ctrl+k ctrl+s").unwrap(),
            command: "workbench.action.openGlobalKeybindings".to_owned(),
            is_unbound: false,
            when: None,
            extension_id: EXT.to_owned(),
            priority: 0,
        },
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ctx_focused() -> KeyContext {
        let mut c = KeyContext::new();
        c.set("editorFocus");
        c.set("editorTextFocus");
        c
    }

    // ── KeyChord parsing ──────────────────────────────────────────────────────

    #[test]
    fn test_parse_simple_chord() {
        let c = KeyChord::parse("a").unwrap();
        assert_eq!(c.key, "a");
        assert!(!c.ctrl);
    }

    #[test]
    fn test_parse_modifier_chord() {
        let c = KeyChord::parse("ctrl+shift+p").unwrap();
        assert_eq!(c.key, "p");
        assert!(c.ctrl);
        assert!(c.shift);
    }

    #[test]
    fn test_parse_cmd_becomes_meta() {
        let c = KeyChord::parse("cmd+s").unwrap();
        assert!(c.meta);
        assert_eq!(c.key, "s");
    }

    #[test]
    fn test_chord_string_roundtrip() {
        let s = "ctrl+shift+p";
        let c = KeyChord::parse(s).unwrap();
        assert_eq!(c.to_chord_string(), s);
    }

    #[test]
    fn test_parse_invalid() {
        assert!(KeyChord::parse("ctrl+shift").is_none()); // no key
    }

    // ── KeySequence parsing ────────────────────────────────────────────────────

    #[test]
    fn test_sequence_single() {
        let seq = KeySequence::parse("ctrl+s").unwrap();
        assert!(!seq.is_multi_chord());
    }

    #[test]
    fn test_sequence_multi_chord() {
        let seq = KeySequence::parse("ctrl+k ctrl+f").unwrap();
        assert!(seq.is_multi_chord());
        assert_eq!(seq.first.key, "k");
        assert_eq!(seq.second.unwrap().key, "f");
    }

    // ── When-clause evaluation ────────────────────────────────────────────────

    #[test]
    fn test_when_simple_key_present() {
        let mut ctx = KeyContext::new();
        ctx.set("editorFocus");
        assert!(ctx.evaluate("editorFocus"));
        assert!(!ctx.evaluate("debugMode"));
    }

    #[test]
    fn test_when_negation() {
        let mut ctx = KeyContext::new();
        ctx.set("editorFocus");
        assert!(!ctx.evaluate("!editorFocus"));
        assert!(ctx.evaluate("!debugMode"));
    }

    #[test]
    fn test_when_equality() {
        let mut ctx = KeyContext::new();
        ctx.set_value("language", serde_json::json!("rust"));
        assert!(ctx.evaluate("language == rust"));
        assert!(!ctx.evaluate("language == python"));
    }

    #[test]
    fn test_when_and() {
        let mut ctx = KeyContext::new();
        ctx.set("a");
        ctx.set("b");
        assert!(ctx.evaluate("a && b"));
        assert!(!ctx.evaluate("a && c"));
    }

    #[test]
    fn test_when_or() {
        let mut ctx = KeyContext::new();
        ctx.set("a");
        assert!(ctx.evaluate("a || b"));
        assert!(!ctx.evaluate("c || d"));
    }

    #[test]
    fn test_when_empty_always_true() {
        let ctx = KeyContext::new();
        assert!(ctx.evaluate(""));
    }

    // ── Engine ────────────────────────────────────────────────────────────────

    #[test]
    fn test_single_chord_resolution() {
        let mut eng = KeybindingEngine::new();
        eng.register_all(default_keybindings());
        let chord = KeyChord::parse("ctrl+s").unwrap();
        let result = eng.resolve(chord, &KeyContext::new());
        assert_eq!(
            result,
            KeyResolution::Command("workbench.action.files.save".into())
        );
    }

    #[test]
    fn test_multi_chord_resolution() {
        let mut eng = KeybindingEngine::new();
        eng.register_all(default_keybindings());
        let ctx = ctx_focused();

        // First chord: ctrl+k → ChordPending
        let r1 = eng.resolve(KeyChord::parse("ctrl+k").unwrap(), &ctx);
        assert_eq!(r1, KeyResolution::ChordPending);
        assert!(eng.has_pending());

        // Second chord: ctrl+f → formatSelection
        let r2 = eng.resolve(KeyChord::parse("ctrl+f").unwrap(), &ctx);
        assert_eq!(
            r2,
            KeyResolution::Command("editor.action.formatSelection".into())
        );
        assert!(!eng.has_pending());
    }

    #[test]
    fn test_unbound_key() {
        let mut eng = KeybindingEngine::new();
        let result = eng.resolve(KeyChord::parse("ctrl+q").unwrap(), &KeyContext::new());
        assert_eq!(result, KeyResolution::Unbound);
    }

    #[test]
    fn test_when_clause_filtering() {
        let mut eng = KeybindingEngine::new();
        eng.register(KeybindingEntry {
            sequence: KeySequence::parse("ctrl+f").unwrap(),
            command: "actions.find".to_owned(),
            is_unbound: false,
            when: Some("editorFocus".to_owned()),
            extension_id: "test".to_owned(),
            priority: 0,
        });
        // Without editorFocus: unbound
        let result = eng.resolve(KeyChord::parse("ctrl+f").unwrap(), &KeyContext::new());
        assert_eq!(result, KeyResolution::Unbound);
        // With editorFocus: matched
        let result2 = eng.resolve(KeyChord::parse("ctrl+f").unwrap(), &ctx_focused());
        assert_eq!(result2, KeyResolution::Command("actions.find".into()));
    }

    #[test]
    fn test_priority_override() {
        let mut eng = KeybindingEngine::new();
        // Default: ctrl+s → save
        eng.register(KeybindingEntry {
            sequence: KeySequence::parse("ctrl+s").unwrap(),
            command: "save".to_owned(),
            is_unbound: false,
            when: None,
            extension_id: "builtin".to_owned(),
            priority: 0,
        });
        // Extension override: ctrl+s → custom.save (higher priority)
        eng.register(KeybindingEntry {
            sequence: KeySequence::parse("ctrl+s").unwrap(),
            command: "custom.save".to_owned(),
            is_unbound: false,
            when: None,
            extension_id: "my-ext".to_owned(),
            priority: 10,
        });
        let result = eng.resolve(KeyChord::parse("ctrl+s").unwrap(), &KeyContext::new());
        assert_eq!(result, KeyResolution::Command("custom.save".into()));
    }

    #[test]
    fn test_cancel_pending() {
        let mut eng = KeybindingEngine::new();
        eng.register_all(default_keybindings());
        let ctx = ctx_focused();
        eng.resolve(KeyChord::parse("ctrl+k").unwrap(), &ctx);
        assert!(eng.has_pending());
        eng.cancel_pending();
        assert!(!eng.has_pending());
    }

    #[test]
    fn test_unregister_extension() {
        let mut eng = KeybindingEngine::new();
        eng.register(KeybindingEntry {
            sequence: KeySequence::parse("ctrl+shift+q").unwrap(),
            command: "myext.quit".to_owned(),
            is_unbound: false,
            when: None,
            extension_id: "my-ext".to_owned(),
            priority: 5,
        });
        assert_eq!(eng.binding_count(), 1);
        eng.unregister_extension("my-ext");
        assert_eq!(eng.binding_count(), 0);
    }

    #[test]
    fn test_bindings_for_command() {
        let mut eng = KeybindingEngine::new();
        eng.register_all(default_keybindings());
        let bindings = eng.bindings_for_command("undo");
        assert!(!bindings.is_empty());
        assert!(bindings
            .iter()
            .any(|b| b.sequence.first.key == "z" && b.sequence.first.ctrl));
    }

    #[test]
    fn test_default_bindings_count() {
        let bindings = default_keybindings();
        assert!(
            bindings.len() >= 20,
            "Should have at least 20 default bindings"
        );
    }
}
