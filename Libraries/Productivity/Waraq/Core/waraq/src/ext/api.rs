// src/ext/api.rs
//
// Extension API — the interface extensions use to interact with the editor.
// This is the Waraq equivalent of VS Code's `vscode` namespace.
//
// An `ExtensionContext` is handed to each extension at activation time.
// Through it, extensions can:
//   • Register commands, providers, and handlers
//   • Read and edit documents
//   • Show notifications and UI
//   • Subscribe to editor events
//   • Store extension-specific state
//
// The API uses message-passing over a shared `ExtensionBus` so extensions
// can be sandboxed (WASM modules) or native (trait objects).

use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};

use crate::ext::commands::{CommandArgs, CommandRegistry, CommandResult};
use crate::ext::contribution::{Snippet, SnippetEngine, ThemeEngine};
use crate::ext::keybinding::{KeybindingEngine, KeybindingEntry};

// ── Provider traits ───────────────────────────────────────────────────────────

/// Provides hover documentation for a position in a document.
pub trait HoverProvider: Send + Sync {
    fn provide_hover(&self, request: HoverRequest) -> Option<HoverResponse>;
}

/// Provides completion items for a position.
pub trait CompletionProvider: Send + Sync {
    fn provide_completions(&self, request: CompletionRequest) -> Vec<CompletionItem>;
}

/// Provides diagnostics for a document.
pub trait DiagnosticProvider: Send + Sync {
    fn provide_diagnostics(&self, request: DiagnosticRequest) -> Vec<DiagnosticItem>;
}

/// Provides code actions for a range.
pub trait CodeActionProvider: Send + Sync {
    fn provide_code_actions(&self, request: CodeActionRequest) -> Vec<CodeAction>;
}

/// Formats a document or selection.
pub trait FormatterProvider: Send + Sync {
    fn format(&self, request: FormatRequest) -> Vec<TextEdit>;
}

// ── Request / response types ──────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentPosition {
    pub file_uri: String,
    pub line: usize,
    pub col: usize,
    pub byte_offset: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HoverRequest {
    pub position: DocumentPosition,
    pub word: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HoverResponse {
    pub markdown: String,
    pub range: Option<(usize, usize)>, // (start_byte, end_byte)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompletionRequest {
    pub position: DocumentPosition,
    pub trigger_char: Option<char>,
    pub prefix: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompletionItem {
    pub label: String,
    pub kind: CompletionItemKind,
    pub detail: Option<String>,
    pub documentation: Option<String>,
    pub insert_text: String,
    pub sort_text: Option<String>,
    pub filter_text: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CompletionItemKind {
    Text,
    Method,
    Function,
    Constructor,
    Field,
    Variable,
    Class,
    Interface,
    Module,
    Property,
    Unit,
    Value,
    Enum,
    Keyword,
    Snippet,
    Color,
    File,
    Reference,
    Folder,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiagnosticRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiagnosticItem {
    pub range: (usize, usize, usize, usize), // start_line, start_col, end_line, end_col
    pub severity: DiagSeverity,
    pub message: String,
    pub source: Option<String>,
    pub code: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DiagSeverity {
    Error,
    Warning,
    Information,
    Hint,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodeActionRequest {
    pub position: DocumentPosition,
    pub diagnostics: Vec<DiagnosticItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodeAction {
    pub title: String,
    pub kind: String, // "quickfix", "refactor", "source.organizeImports"
    pub command: Option<String>,
    pub edits: Vec<TextEdit>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextEdit {
    pub start_line: usize,
    pub start_col: usize,
    pub end_line: usize,
    pub end_col: usize,
    pub new_text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FormatRequest {
    pub file_uri: String,
    pub content: String,
    pub language: String,
    pub tab_size: u32,
    pub use_spaces: bool,
}

// ── Status bar item ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StatusBarItem {
    pub id: String,
    pub text: String,
    pub tooltip: Option<String>,
    pub command: Option<String>,
    pub priority: i32,
    pub visible: bool,
}

// ── Notification ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NotificationKind {
    Info,
    Warning,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Notification {
    pub kind: NotificationKind,
    pub message: String,
    pub actions: Vec<String>,
}

// ── Extension bus ─────────────────────────────────────────────────────────────

/// Shared mutable state accessible to all extensions through their context.
pub struct ExtensionBus {
    pub commands: CommandRegistry,
    pub keybindings: KeybindingEngine,
    pub snippets: SnippetEngine,
    pub themes: ThemeEngine,
    pub status_bar: Vec<StatusBarItem>,
    pub notifications: Vec<Notification>,
    hover_providers: Vec<(String, Box<dyn HoverProvider>)>, // (extension_id, provider)
    completion_providers: Vec<(String, Box<dyn CompletionProvider>)>,
    diagnostic_providers: Vec<(String, Box<dyn DiagnosticProvider>)>,
    code_action_providers: Vec<(String, Box<dyn CodeActionProvider>)>,
    formatter_providers: Vec<(String, Box<dyn FormatterProvider>)>,
}

impl ExtensionBus {
    pub fn new() -> Self {
        let mut commands = CommandRegistry::new();
        crate::ext::commands::register_builtin_commands(&mut commands);
        let mut keybindings = KeybindingEngine::new();
        keybindings.register_all(crate::ext::keybinding::default_keybindings());

        Self {
            commands,
            keybindings,
            snippets: SnippetEngine::new(),
            themes: ThemeEngine::new(),
            status_bar: Vec::new(),
            notifications: Vec::new(),
            hover_providers: Vec::new(),
            completion_providers: Vec::new(),
            diagnostic_providers: Vec::new(),
            code_action_providers: Vec::new(),
            formatter_providers: Vec::new(),
        }
    }

    // ── Provider dispatch ──────────────────────────────────────────────────────

    pub fn hover(&self, req: HoverRequest) -> Option<HoverResponse> {
        for (_, p) in &self.hover_providers {
            if let Some(r) = p.provide_hover(req.clone()) {
                return Some(r);
            }
        }
        None
    }

    pub fn completions(&self, req: CompletionRequest) -> Vec<CompletionItem> {
        let mut all = Vec::new();
        for (_, p) in &self.completion_providers {
            all.extend(p.provide_completions(req.clone()));
        }
        all
    }

    pub fn diagnostics(&self, req: DiagnosticRequest) -> Vec<DiagnosticItem> {
        let mut all = Vec::new();
        for (_, p) in &self.diagnostic_providers {
            all.extend(p.provide_diagnostics(req.clone()));
        }
        all
    }

    pub fn code_actions(&self, req: CodeActionRequest) -> Vec<CodeAction> {
        let mut all = Vec::new();
        for (_, p) in &self.code_action_providers {
            all.extend(p.provide_code_actions(req.clone()));
        }
        all
    }

    pub fn format(&self, req: FormatRequest) -> Vec<TextEdit> {
        self.formatter_providers
            .first()
            .map(|(_, p)| p.format(req))
            .unwrap_or_default()
    }

    // ── Provider registration ─────────────────────────────────────────────────

    pub fn register_hover_provider(&mut self, ext_id: &str, p: Box<dyn HoverProvider>) {
        self.hover_providers.push((ext_id.to_owned(), p));
    }
    pub fn register_completion_provider(&mut self, ext_id: &str, p: Box<dyn CompletionProvider>) {
        self.completion_providers.push((ext_id.to_owned(), p));
    }
    pub fn register_diagnostic_provider(&mut self, ext_id: &str, p: Box<dyn DiagnosticProvider>) {
        self.diagnostic_providers.push((ext_id.to_owned(), p));
    }
    pub fn register_code_action_provider(&mut self, ext_id: &str, p: Box<dyn CodeActionProvider>) {
        self.code_action_providers.push((ext_id.to_owned(), p));
    }
    pub fn register_formatter_provider(&mut self, ext_id: &str, p: Box<dyn FormatterProvider>) {
        self.formatter_providers.push((ext_id.to_owned(), p));
    }

    pub fn unregister_extension(&mut self, ext_id: &str) {
        self.commands.unregister_extension(ext_id);
        self.keybindings.unregister_extension(ext_id);
        self.hover_providers.retain(|(id, _)| id != ext_id);
        self.completion_providers.retain(|(id, _)| id != ext_id);
        self.diagnostic_providers.retain(|(id, _)| id != ext_id);
        self.code_action_providers.retain(|(id, _)| id != ext_id);
        self.formatter_providers.retain(|(id, _)| id != ext_id);
        self.status_bar
            .retain(|item| !item.id.starts_with(&format!("{}.", ext_id)));
    }
}

impl Default for ExtensionBus {
    fn default() -> Self {
        Self::new()
    }
}

// ── Extension context ─────────────────────────────────────────────────────────

/// Handed to each extension at activation. Extensions hold onto this for
/// their lifetime to register/unregister capabilities.
pub struct ExtensionContext {
    pub extension_id: String,
    bus: Arc<Mutex<ExtensionBus>>,
}

impl ExtensionContext {
    pub fn new(extension_id: &str, bus: Arc<Mutex<ExtensionBus>>) -> Self {
        Self {
            extension_id: extension_id.to_owned(),
            bus,
        }
    }

    // ── Commands ──────────────────────────────────────────────────────────────

    pub fn register_command<F>(&self, command_id: &str, title: &str, f: F)
    where
        F: Fn(CommandArgs) -> CommandResult + Send + Sync + 'static,
    {
        let ext = self.extension_id.clone();
        self.bus
            .lock()
            .unwrap()
            .commands
            .register_fn(command_id, title, &ext, f);
    }

    pub fn execute_command(&self, command_id: &str, args: CommandArgs) -> CommandResult {
        self.bus.lock().unwrap().commands.execute(command_id, args)
    }

    // ── Keybindings ───────────────────────────────────────────────────────────

    pub fn register_keybinding(&self, entry: KeybindingEntry) {
        let mut entry = entry;
        entry.extension_id = self.extension_id.clone();
        self.bus.lock().unwrap().keybindings.register(entry);
    }

    // ── Snippets ──────────────────────────────────────────────────────────────

    pub fn register_snippet(&self, snippet: Snippet) {
        self.bus.lock().unwrap().snippets.register(snippet);
    }

    pub fn register_snippets(&self, snippets: Vec<Snippet>) {
        let mut bus = self.bus.lock().unwrap();
        for s in snippets {
            bus.snippets.register(s);
        }
    }

    // ── Providers ─────────────────────────────────────────────────────────────

    pub fn register_hover_provider(&self, provider: Box<dyn HoverProvider>) {
        let ext = self.extension_id.clone();
        self.bus
            .lock()
            .unwrap()
            .register_hover_provider(&ext, provider);
    }

    pub fn register_completion_provider(&self, provider: Box<dyn CompletionProvider>) {
        let ext = self.extension_id.clone();
        self.bus
            .lock()
            .unwrap()
            .register_completion_provider(&ext, provider);
    }

    pub fn register_diagnostic_provider(&self, provider: Box<dyn DiagnosticProvider>) {
        let ext = self.extension_id.clone();
        self.bus
            .lock()
            .unwrap()
            .register_diagnostic_provider(&ext, provider);
    }

    pub fn register_formatter_provider(&self, provider: Box<dyn FormatterProvider>) {
        let ext = self.extension_id.clone();
        self.bus
            .lock()
            .unwrap()
            .register_formatter_provider(&ext, provider);
    }

    // ── Status bar ────────────────────────────────────────────────────────────

    pub fn set_status_bar_item(&self, item: StatusBarItem) {
        let mut bus = self.bus.lock().unwrap();
        bus.status_bar.retain(|i| i.id != item.id);
        bus.status_bar.push(item);
        bus.status_bar.sort_by(|a, b| b.priority.cmp(&a.priority));
    }

    pub fn remove_status_bar_item(&self, id: &str) {
        self.bus.lock().unwrap().status_bar.retain(|i| i.id != id);
    }

    // ── Notifications ─────────────────────────────────────────────────────────

    pub fn show_info_message(&self, msg: &str) {
        self.bus.lock().unwrap().notifications.push(Notification {
            kind: NotificationKind::Info,
            message: msg.to_owned(),
            actions: Vec::new(),
        });
    }

    pub fn show_warning_message(&self, msg: &str) {
        self.bus.lock().unwrap().notifications.push(Notification {
            kind: NotificationKind::Warning,
            message: msg.to_owned(),
            actions: Vec::new(),
        });
    }

    pub fn show_error_message(&self, msg: &str) {
        self.bus.lock().unwrap().notifications.push(Notification {
            kind: NotificationKind::Error,
            message: msg.to_owned(),
            actions: Vec::new(),
        });
    }

    // ── Themes ────────────────────────────────────────────────────────────────

    pub fn register_theme(&self, theme: crate::ext::contribution::Theme) {
        self.bus.lock().unwrap().themes.register(theme);
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    /// Called when the extension is deactivated — cleans up all registrations.
    pub fn dispose(&self) {
        self.bus
            .lock()
            .unwrap()
            .unregister_extension(&self.extension_id);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn make_bus() -> Arc<Mutex<ExtensionBus>> {
        Arc::new(Mutex::new(ExtensionBus::new()))
    }

    fn make_ctx(bus: &Arc<Mutex<ExtensionBus>>) -> ExtensionContext {
        ExtensionContext::new("test.extension", Arc::clone(bus))
    }

    #[test]
    fn test_register_and_execute_command() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_command("test.hello", "Test: Hello", |_| {
            CommandResult::ok(serde_json::json!({ "msg": "hello" }))
        });
        let result = ctx.execute_command("test.hello", serde_json::Value::Null);
        assert!(result.is_ok());
        if let CommandResult::Ok(v) = result {
            assert_eq!(v["msg"], "hello");
        }
    }

    #[test]
    fn test_show_notifications() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.show_info_message("All tests passed!");
        ctx.show_warning_message("Deprecated API");
        ctx.show_error_message("Build failed");
        let locked = bus.lock().unwrap();
        assert_eq!(locked.notifications.len(), 3);
        assert!(matches!(
            locked.notifications[0].kind,
            NotificationKind::Info
        ));
        assert!(matches!(
            locked.notifications[2].kind,
            NotificationKind::Error
        ));
    }

    #[test]
    fn test_status_bar_item() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.set_status_bar_item(StatusBarItem {
            id: "test.extension.status".into(),
            text: "✓ Ready".into(),
            tooltip: Some("Extension is active".into()),
            command: None,
            priority: 100,
            visible: true,
        });
        let locked = bus.lock().unwrap();
        assert!(!locked.status_bar.is_empty());
        assert_eq!(locked.status_bar[0].text, "✓ Ready");
    }

    #[test]
    fn test_register_snippet() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_snippet(Snippet::new(
            "fn",
            &["fn $1($2) {", "    $0", "}"],
            "Rust function",
            "rust",
        ));
        let locked = bus.lock().unwrap();
        let snips = locked.snippets.all_for_language("rust");
        assert!(!snips.is_empty());
        assert_eq!(snips[0].prefix, "fn");
    }

    #[test]
    fn test_dispose_cleans_up() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_command("test.cmd", "Test Cmd", |_| CommandResult::void());
        ctx.set_status_bar_item(StatusBarItem {
            id: "test.extension.sb".into(),
            text: "hi".into(),
            tooltip: None,
            command: None,
            priority: 0,
            visible: true,
        });
        {
            let locked = bus.lock().unwrap();
            assert!(locked.commands.contains("test.cmd"));
        }
        ctx.dispose();
        {
            let locked = bus.lock().unwrap();
            assert!(
                !locked.commands.contains("test.cmd"),
                "Command should be unregistered after dispose"
            );
            assert!(
                locked.status_bar.is_empty(),
                "Status bar should be cleared after dispose"
            );
        }
    }

    #[test]
    fn test_hover_provider() {
        struct MyHover;
        impl HoverProvider for MyHover {
            fn provide_hover(&self, req: HoverRequest) -> Option<HoverResponse> {
                Some(HoverResponse {
                    markdown: format!("Documentation for `{}`", req.word),
                    range: None,
                })
            }
        }

        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_hover_provider(Box::new(MyHover));

        let locked = bus.lock().unwrap();
        let result = locked.hover(HoverRequest {
            position: DocumentPosition {
                file_uri: "file:///test.rs".into(),
                line: 0,
                col: 0,
                byte_offset: 0,
            },
            word: "println".into(),
        });
        assert!(result.is_some());
        assert!(result.unwrap().markdown.contains("println"));
    }

    #[test]
    fn test_completion_provider() {
        struct MyCompleter;
        impl CompletionProvider for MyCompleter {
            fn provide_completions(&self, _req: CompletionRequest) -> Vec<CompletionItem> {
                vec![CompletionItem {
                    label: "println!".into(),
                    kind: CompletionItemKind::Function,
                    detail: Some("macro_rules! println".into()),
                    documentation: None,
                    insert_text: "println!(\"$1\")".into(),
                    sort_text: None,
                    filter_text: None,
                }]
            }
        }

        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_completion_provider(Box::new(MyCompleter));

        let locked = bus.lock().unwrap();
        let items = locked.completions(CompletionRequest {
            position: DocumentPosition {
                file_uri: "file:///test.rs".into(),
                line: 0,
                col: 4,
                byte_offset: 4,
            },
            trigger_char: Some('.'),
            prefix: "prin".into(),
        });
        assert_eq!(items.len(), 1);
        assert_eq!(items[0].label, "println!");
    }

    #[test]
    fn test_keybinding_registration() {
        let bus = make_bus();
        let ctx = make_ctx(&bus);
        ctx.register_keybinding(crate::ext::keybinding::KeybindingEntry {
            sequence: crate::ext::keybinding::KeySequence::parse("ctrl+shift+t").unwrap(),
            command: "test.runTests".to_owned(),
            is_unbound: false,
            when: None,
            extension_id: "test.extension".to_owned(),
            priority: 10,
        });
        let locked = bus.lock().unwrap();
        let bindings = locked.keybindings.bindings_for_command("test.runTests");
        assert_eq!(bindings.len(), 1);
    }

    #[test]
    fn test_bus_default_has_builtins() {
        let bus = ExtensionBus::new();
        assert!(bus.commands.contains("undo"));
        assert!(bus.commands.contains("editor.action.formatDocument"));
        assert!(bus.keybindings.binding_count() > 0);
    }
}
