// src/ext/manifest.rs
//
// Extension manifest — the declarative description of what an extension
// provides. Equivalent to VS Code's package.json `contributes` block.
//
// A manifest is either:
//   • Written in JSON and loaded from disk (third-party / WASM extensions)
//   • Constructed in Rust code (built-in / trusted extensions)
//
// Contribution points defined here:
//   commands       — Command palette entries
//   keybindings    — Key chord → command mappings
//   languages      — Language ID → file extensions/patterns
//   grammars       — Syntax tokenizer rules per language
//   themes         — Color theme definitions
//   snippets       — Code snippet templates
//   menus          — Context menu / editor toolbar entries
//   statusBarItems — Status bar contributions

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Extension metadata ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtensionManifest {
    /// Unique reverse-domain identifier: "com.waraq.rust-analyzer"
    pub id: String,
    pub name: String,
    pub version: String,
    pub description: String,
    pub author: String,
    /// Minimum editor version required.
    pub engine_version: String,

    /// Conditions that cause this extension to activate.
    pub activation_events: Vec<ActivationEvent>,

    /// What this extension adds to the editor.
    pub contributes: Contributions,

    /// Extension kind: built-in trusted or sandboxed WASM.
    pub kind: ExtensionKind,
}

impl ExtensionManifest {
    pub fn new(id: &str, name: &str, version: &str) -> Self {
        Self {
            id: id.to_owned(),
            name: name.to_owned(),
            version: version.to_owned(),
            description: String::new(),
            author: String::new(),
            engine_version: "0.1.0".to_owned(),
            activation_events: Vec::new(),
            contributes: Contributions::default(),
            kind: ExtensionKind::Builtin,
        }
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        Ok(serde_json::from_str(json)?)
    }

    pub fn to_json(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }

    /// True if this extension should activate for the given language.
    pub fn activates_for_language(&self, language: &str) -> bool {
        self.activation_events
            .iter()
            .any(|e| matches!(e, ActivationEvent::OnLanguage(l) if l == language))
    }

    /// True if this extension should activate when `command_id` is invoked.
    pub fn activates_for_command(&self, command_id: &str) -> bool {
        self.activation_events
            .iter()
            .any(|e| matches!(e, ActivationEvent::OnCommand(c) if c == command_id))
    }
}

// ── Activation events ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ActivationEvent {
    /// Activate when a file of this language is opened.
    OnLanguage(String),
    /// Activate when this command is about to be run.
    OnCommand(String),
    /// Activate immediately on editor startup.
    OnStartup,
    /// Activate when the workspace contains a file matching the glob.
    WorkspaceContains(String),
    /// Activate when a file matching the glob is opened.
    OnFileSystem(String),
}

// ── Extension kind ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ExtensionKind {
    /// Built-in: compiled directly into the engine, no sandbox.
    Builtin,
    /// Trusted: native code loaded as a dylib, minimal sandbox.
    Native,
    /// Sandboxed: WASM module with restricted API surface.
    Wasm { module_path: String },
}

// ── Contributions ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Contributions {
    pub commands: Vec<CommandContribution>,
    pub keybindings: Vec<KeybindingContribution>,
    pub languages: Vec<LanguageContribution>,
    pub grammars: Vec<GrammarContribution>,
    pub themes: Vec<ThemeContribution>,
    pub snippets: Vec<SnippetFileContribution>,
    pub menus: HashMap<String, Vec<MenuItemContribution>>,
    pub status_bar: Vec<StatusBarContribution>,
    pub hover_providers: Vec<String>,       // language IDs
    pub completion_providers: Vec<String>,  // language IDs
    pub diagnostic_providers: Vec<String>,  // language IDs
    pub code_action_providers: Vec<String>, // language IDs
    pub formatter_providers: Vec<String>,   // language IDs
}

// ── Command contribution ───────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommandContribution {
    /// Unique command id: "waraq.rust.check"
    pub command: String,
    /// User-visible title: "Rust: Check Project"
    pub title: String,
    /// Optional category prefix: "Rust"
    pub category: Option<String>,
    /// Icon identifier for toolbars.
    pub icon: Option<String>,
    /// Whether to show in the command palette.
    pub palette: bool,
}

impl CommandContribution {
    pub fn new(command: &str, title: &str) -> Self {
        Self {
            command: command.to_owned(),
            title: title.to_owned(),
            category: None,
            icon: None,
            palette: true,
        }
    }

    pub fn with_category(mut self, cat: &str) -> Self {
        self.category = Some(cat.to_owned());
        self
    }
    pub fn with_icon(mut self, icon: &str) -> Self {
        self.icon = Some(icon.to_owned());
        self
    }
    pub fn hidden(mut self) -> Self {
        self.palette = false;
        self
    }
}

// ── Keybinding contribution ───────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeybindingContribution {
    /// The command to run.
    pub command: String,
    /// Key chord: "ctrl+shift+p", "cmd+k cmd+s"
    pub key: String,
    /// Platform-specific override for macOS: "cmd+shift+p"
    pub mac: Option<String>,
    /// When-clause: "editorTextFocus", "!editorReadonly"
    pub when: Option<String>,
}

impl KeybindingContribution {
    pub fn new(key: &str, command: &str) -> Self {
        Self {
            command: command.to_owned(),
            key: key.to_owned(),
            mac: None,
            when: None,
        }
    }
    pub fn with_mac(mut self, mac: &str) -> Self {
        self.mac = Some(mac.to_owned());
        self
    }
    pub fn when(mut self, when: &str) -> Self {
        self.when = Some(when.to_owned());
        self
    }
}

// ── Language contribution ─────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguageContribution {
    /// Language ID: "rust", "my-dsl"
    pub id: String,
    pub aliases: Vec<String>,
    pub extensions: Vec<String>, // ".myext"
    pub filenames: Vec<String>,  // "Makefile"
    pub mime_types: Vec<String>,
    /// Inline comment token: "//"
    pub line_comment: Option<String>,
    /// Block comment: ("/*", "*/")
    pub block_comment: Option<(String, String)>,
    /// Bracket pairs for auto-close and matching.
    pub brackets: Vec<(String, String)>,
    /// Characters that end a word boundary.
    pub word_pattern: Option<String>,
    /// Indent-increasing patterns (regex strings).
    pub indent_rules_increase: Vec<String>,
    /// Indent-decreasing patterns.
    pub indent_rules_decrease: Vec<String>,
}

impl LanguageContribution {
    pub fn new(id: &str) -> Self {
        Self {
            id: id.to_owned(),
            aliases: Vec::new(),
            extensions: Vec::new(),
            filenames: Vec::new(),
            mime_types: Vec::new(),
            line_comment: None,
            block_comment: None,
            brackets: vec![
                ("(".to_owned(), ")".to_owned()),
                ("[".to_owned(), "]".to_owned()),
                ("{".to_owned(), "}".to_owned()),
            ],
            word_pattern: None,
            indent_rules_increase: Vec::new(),
            indent_rules_decrease: Vec::new(),
        }
    }

    pub fn with_extensions(mut self, exts: &[&str]) -> Self {
        self.extensions = exts.iter().map(|s| s.to_string()).collect();
        self
    }
    pub fn with_line_comment(mut self, tok: &str) -> Self {
        self.line_comment = Some(tok.to_owned());
        self
    }
}

// ── Grammar contribution ──────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrammarContribution {
    pub language: String,
    /// Path to the grammar file (TextMate .tmLanguage.json or .json).
    pub path: String,
    /// Scope name: "source.rust"
    pub scope_name: String,
}

// ── Theme contribution ────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ThemeContribution {
    pub id: String,
    pub label: String,
    pub kind: ThemeKind,
    pub path: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ThemeKind {
    Dark,
    Light,
    HighContrast,
}

// ── Snippet file contribution ─────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SnippetFileContribution {
    pub language: String,
    pub path: String,
}

// ── Menu item contribution ────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MenuItemContribution {
    pub command: String,
    pub group: Option<String>,
    pub when: Option<String>,
}

// ── Status bar contribution ───────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusBarContribution {
    pub id: String,
    pub text: String,
    pub tooltip: Option<String>,
    pub command: Option<String>,
    pub alignment: StatusBarAlignment,
    pub priority: i32,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum StatusBarAlignment {
    Left,
    Right,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_manifest_construction() {
        let mut m = ExtensionManifest::new("com.test.ext", "Test Extension", "1.0.0");
        m.activation_events
            .push(ActivationEvent::OnLanguage("rust".into()));
        m.activation_events
            .push(ActivationEvent::OnCommand("test.run".into()));
        m.contributes
            .commands
            .push(CommandContribution::new("test.run", "Test: Run"));

        assert!(m.activates_for_language("rust"));
        assert!(!m.activates_for_language("python"));
        assert!(m.activates_for_command("test.run"));
        assert!(!m.activates_for_command("other.command"));
    }

    #[test]
    fn test_manifest_json_roundtrip() {
        let mut m = ExtensionManifest::new("com.test.ext", "Test", "0.1.0");
        m.contributes.commands.push(
            CommandContribution::new("test.hello", "Test: Hello World").with_category("Test"),
        );
        m.contributes.keybindings.push(
            KeybindingContribution::new("ctrl+shift+h", "test.hello").with_mac("cmd+shift+h"),
        );
        m.contributes.languages.push(
            LanguageContribution::new("my-dsl")
                .with_extensions(&[".mydsl", ".mds"])
                .with_line_comment("//"),
        );

        let json = m.to_json();
        let restored = ExtensionManifest::from_json(&json).unwrap();
        assert_eq!(restored.id, "com.test.ext");
        assert_eq!(restored.contributes.commands.len(), 1);
        assert_eq!(restored.contributes.keybindings.len(), 1);
        assert_eq!(restored.contributes.languages.len(), 1);
        assert_eq!(
            restored.contributes.languages[0].extensions,
            vec![".mydsl", ".mds"]
        );
    }

    #[test]
    fn test_activation_events() {
        let events = vec![
            ActivationEvent::OnStartup,
            ActivationEvent::OnLanguage("typescript".into()),
            ActivationEvent::WorkspaceContains("tsconfig.json".into()),
        ];
        let json = serde_json::to_string(&events).unwrap();
        let restored: Vec<ActivationEvent> = serde_json::from_str(&json).unwrap();
        assert_eq!(restored.len(), 3);
        assert_eq!(restored[0], ActivationEvent::OnStartup);
    }

    #[test]
    fn test_command_contribution_builder() {
        let cmd = CommandContribution::new("ext.doThing", "Extension: Do Thing")
            .with_category("Extension")
            .with_icon("$(play)")
            .hidden();
        assert_eq!(cmd.category, Some("Extension".into()));
        assert!(!cmd.palette);
    }

    #[test]
    fn test_keybinding_contribution() {
        let kb = KeybindingContribution::new("ctrl+shift+p", "workbench.action.showCommands")
            .with_mac("cmd+shift+p")
            .when("editorFocus");
        assert_eq!(kb.mac, Some("cmd+shift+p".into()));
        assert_eq!(kb.when, Some("editorFocus".into()));
    }

    #[test]
    fn test_language_contribution_brackets() {
        let lang = LanguageContribution::new("rust");
        // Default brackets should be set
        assert!(!lang.brackets.is_empty());
        assert!(lang.brackets.iter().any(|(o, c)| o == "(" && c == ")"));
    }
}
