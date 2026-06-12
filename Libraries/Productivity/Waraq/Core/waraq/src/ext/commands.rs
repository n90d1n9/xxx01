// src/ext/commands.rs
//
// Command registry — the central dispatch table for all editor actions.
//
// Every editor action that can be invoked by the user (keyboard shortcut,
// menu click, command palette) is a registered command with a unique ID.
//
// Architecture:
//   CommandRegistry holds:
//     • A map of id → CommandHandler (trait object or fn pointer)
//     • Metadata for command palette display
//     • When-clause context for conditional enablement
//
// Commands are first-class: extensions register them at activation time,
// and the host calls `registry.execute(id, args)` to run them.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ── Command arguments ─────────────────────────────────────────────────────────

/// Arguments passed to a command. JSON-serialisable for cross-extension IPC.
pub type CommandArgs = serde_json::Value;

/// Result returned by a command.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CommandResult {
    Ok(serde_json::Value),
    Err(String),
    NoResult,
}

impl CommandResult {
    pub fn ok(v: serde_json::Value) -> Self {
        Self::Ok(v)
    }
    pub fn err(msg: &str) -> Self {
        Self::Err(msg.to_owned())
    }
    pub fn void() -> Self {
        Self::NoResult
    }
    pub fn is_ok(&self) -> bool {
        !matches!(self, Self::Err(_))
    }
}

// ── Handler trait ─────────────────────────────────────────────────────────────

/// A command handler. Implementations may hold references to extension state.
pub trait CommandHandler: Send + Sync {
    fn execute(&self, args: CommandArgs) -> CommandResult;
    fn is_enabled(&self) -> bool {
        true
    }
}

/// Convenience wrapper for plain functions.
struct FnHandler(Box<dyn Fn(CommandArgs) -> CommandResult + Send + Sync>);

impl CommandHandler for FnHandler {
    fn execute(&self, args: CommandArgs) -> CommandResult {
        (self.0)(args)
    }
}

// ── Command entry ─────────────────────────────────────────────────────────────

pub struct CommandEntry {
    pub id: String,
    pub title: String,
    pub category: Option<String>,
    pub extension_id: String,
    handler: Box<dyn CommandHandler>,
}

impl CommandEntry {
    /// Full display title: "Category: Title" or just "Title".
    pub fn display_title(&self) -> String {
        match &self.category {
            Some(cat) => format!("{}: {}", cat, self.title),
            None => self.title.clone(),
        }
    }

    pub fn is_enabled(&self) -> bool {
        self.handler.is_enabled()
    }

    pub fn execute(&self, args: CommandArgs) -> CommandResult {
        if !self.is_enabled() {
            return CommandResult::Err(format!("Command '{}' is disabled", self.id));
        }
        self.handler.execute(args)
    }
}

// ── Command registry ──────────────────────────────────────────────────────────

pub struct CommandRegistry {
    commands: HashMap<String, CommandEntry>,
    /// Most-recently-used list for command palette ordering.
    mru: Vec<String>,
    max_mru: usize,
}

impl CommandRegistry {
    pub fn new() -> Self {
        Self {
            commands: HashMap::new(),
            mru: Vec::new(),
            max_mru: 50,
        }
    }

    // ── Registration ──────────────────────────────────────────────────────────

    /// Register a command with a handler trait object.
    pub fn register(
        &mut self,
        id: &str,
        title: &str,
        extension_id: &str,
        handler: Box<dyn CommandHandler>,
    ) {
        self.commands.insert(
            id.to_owned(),
            CommandEntry {
                id: id.to_owned(),
                title: title.to_owned(),
                category: None,
                extension_id: extension_id.to_owned(),
                handler,
            },
        );
    }

    /// Register with a plain closure (convenience).
    pub fn register_fn<F>(&mut self, id: &str, title: &str, extension_id: &str, f: F)
    where
        F: Fn(CommandArgs) -> CommandResult + Send + Sync + 'static,
    {
        self.register(id, title, extension_id, Box::new(FnHandler(Box::new(f))));
    }

    /// Set the category for an already-registered command.
    pub fn set_category(&mut self, id: &str, category: &str) {
        if let Some(entry) = self.commands.get_mut(id) {
            entry.category = Some(category.to_owned());
        }
    }

    /// Unregister all commands from an extension (called on deactivation).
    pub fn unregister_extension(&mut self, extension_id: &str) {
        self.commands.retain(|_, v| v.extension_id != extension_id);
        self.mru.retain(|id| self.commands.contains_key(id));
    }

    // ── Execution ─────────────────────────────────────────────────────────────

    /// Execute a command by ID.
    pub fn execute(&mut self, id: &str, args: CommandArgs) -> CommandResult {
        match self.commands.get(id) {
            Some(entry) => {
                let result = entry.execute(args);
                if result.is_ok() {
                    self.record_mru(id);
                }
                result
            }
            None => CommandResult::Err(format!("Command '{}' not found", id)),
        }
    }

    // ── Query ─────────────────────────────────────────────────────────────────

    pub fn get(&self, id: &str) -> Option<&CommandEntry> {
        self.commands.get(id)
    }

    pub fn contains(&self, id: &str) -> bool {
        self.commands.contains_key(id)
    }
    pub fn len(&self) -> usize {
        self.commands.len()
    }
    pub fn is_empty(&self) -> bool {
        self.commands.is_empty()
    }

    /// All commands sorted for palette display (MRU first, then alphabetical).
    pub fn palette_items(&self) -> Vec<PaletteItem> {
        let mut items: Vec<PaletteItem> = self
            .commands
            .values()
            .map(|e| {
                let mru_pos = self.mru.iter().rposition(|id| id == &e.id);
                PaletteItem {
                    id: e.id.clone(),
                    title: e.display_title(),
                    enabled: e.is_enabled(),
                    mru_pos,
                }
            })
            .collect();

        items.sort_by(|a, b| {
            match (a.mru_pos, b.mru_pos) {
                (Some(pa), Some(pb)) => pb.cmp(&pa), // higher mru_pos = more recent
                (Some(_), None) => std::cmp::Ordering::Less,
                (None, Some(_)) => std::cmp::Ordering::Greater,
                (None, None) => a.title.cmp(&b.title),
            }
        });
        items
    }

    /// Filter palette items by a fuzzy query.
    pub fn search_palette(&self, query: &str) -> Vec<PaletteItem> {
        let q = query.to_lowercase();
        self.palette_items()
            .into_iter()
            .filter(|item| fuzzy_match(&item.title.to_lowercase(), &q))
            .collect()
    }

    // ── MRU tracking ──────────────────────────────────────────────────────────

    fn record_mru(&mut self, id: &str) {
        self.mru.retain(|i| i != id);
        self.mru.push(id.to_owned());
        if self.mru.len() > self.max_mru {
            self.mru.remove(0);
        }
    }
}

impl Default for CommandRegistry {
    fn default() -> Self {
        Self::new()
    }
}

// ── Palette item ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize)]
pub struct PaletteItem {
    pub id: String,
    pub title: String,
    pub enabled: bool,
    #[serde(skip)]
    pub mru_pos: Option<usize>,
}

// ── Fuzzy match ───────────────────────────────────────────────────────────────

/// Simple subsequence-based fuzzy match.
fn fuzzy_match(haystack: &str, needle: &str) -> bool {
    if needle.is_empty() {
        return true;
    }
    let mut hi = haystack.chars().flat_map(char::to_lowercase).peekable();
    for nc in needle.chars() {
        let nc = nc.to_lowercase().next().unwrap_or(nc);
        loop {
            match hi.next() {
                Some(hc) if hc == nc => break,
                Some(_) => {}
                None => return false,
            }
        }
    }
    true
}

// ── Built-in editor commands ──────────────────────────────────────────────────

/// Register all built-in editor commands into a registry.
/// These are the commands available before any extension is loaded.
pub fn register_builtin_commands(registry: &mut CommandRegistry) {
    const EXT: &str = "waraq.builtin";

    // File
    registry.register_fn("workbench.action.files.save", "Save File", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn(
        "workbench.action.files.saveAs",
        "Save File As...",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn("workbench.action.files.newFile", "New File", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn(
        "workbench.action.files.openFile",
        "Open File...",
        EXT,
        |_| CommandResult::void(),
    );
    registry.set_category("workbench.action.files.save", "File");
    registry.set_category("workbench.action.files.saveAs", "File");
    registry.set_category("workbench.action.files.newFile", "File");
    registry.set_category("workbench.action.files.openFile", "File");

    // Edit
    registry.register_fn("editor.action.selectAll", "Select All", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn("undo", "Undo", EXT, |_| CommandResult::void());
    registry.register_fn("redo", "Redo", EXT, |_| CommandResult::void());
    registry.register_fn("editor.action.clipboardCopyAction", "Copy", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn("editor.action.clipboardCutAction", "Cut", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn("editor.action.clipboardPasteAction", "Paste", EXT, |_| {
        CommandResult::void()
    });
    registry.set_category("editor.action.selectAll", "Edit");
    registry.set_category("undo", "Edit");
    registry.set_category("redo", "Edit");

    // Search
    registry.register_fn("actions.find", "Find", EXT, |_| CommandResult::void());
    registry.register_fn(
        "editor.action.startFindReplaceAction",
        "Replace",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn(
        "actions.findWithSelection",
        "Find with Selection",
        EXT,
        |_| CommandResult::void(),
    );
    registry.set_category("actions.find", "Search");
    registry.set_category("editor.action.startFindReplaceAction", "Search");

    // View
    registry.register_fn(
        "editor.action.toggleWordWrap",
        "Toggle Word Wrap",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn("editor.action.showHover", "Show Hover", EXT, |_| {
        CommandResult::void()
    });
    registry.register_fn("editor.foldAll", "Fold All", EXT, |_| CommandResult::void());
    registry.register_fn("editor.unfoldAll", "Unfold All", EXT, |_| {
        CommandResult::void()
    });
    registry.set_category("editor.action.toggleWordWrap", "View");
    registry.set_category("editor.foldAll", "View");
    registry.set_category("editor.unfoldAll", "View");

    // Format
    registry.register_fn(
        "editor.action.formatDocument",
        "Format Document",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn(
        "editor.action.formatSelection",
        "Format Selection",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn(
        "editor.action.organizeImports",
        "Organize Imports",
        EXT,
        |_| CommandResult::void(),
    );
    registry.set_category("editor.action.formatDocument", "Format");
    registry.set_category("editor.action.formatSelection", "Format");
    registry.set_category("editor.action.organizeImports", "Format");

    // Go to
    registry.register_fn(
        "editor.action.goToDeclaration",
        "Go to Definition",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn(
        "editor.action.findReferences",
        "Find All References",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn("editor.action.rename", "Rename Symbol", EXT, |_| {
        CommandResult::void()
    });
    registry.set_category("editor.action.goToDeclaration", "Go");
    registry.set_category("editor.action.findReferences", "Go");
    registry.set_category("editor.action.rename", "Refactor");

    // Macro
    registry.register_fn(
        "editor.action.startMacroRecording",
        "Start Macro Recording",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn(
        "editor.action.stopMacroRecording",
        "Stop Macro Recording",
        EXT,
        |_| CommandResult::void(),
    );
    registry.register_fn("editor.action.replayMacro", "Replay Macro", EXT, |_| {
        CommandResult::void()
    });
    registry.set_category("editor.action.startMacroRecording", "Macro");
}

#[cfg(test)]
mod tests {
    use super::*;

    fn reg_with_builtins() -> CommandRegistry {
        let mut r = CommandRegistry::new();
        register_builtin_commands(&mut r);
        r
    }

    #[test]
    fn test_register_and_execute() {
        let mut r = CommandRegistry::new();
        r.register_fn("test.greet", "Test: Greet", "test", |args| {
            let name = args["name"].as_str().unwrap_or("world").to_owned();
            CommandResult::ok(serde_json::json!({ "message": format!("Hello, {}!", name) }))
        });
        let result = r.execute("test.greet", serde_json::json!({"name": "Alice"}));
        match result {
            CommandResult::Ok(v) => assert_eq!(v["message"], "Hello, Alice!"),
            _ => panic!("Expected Ok"),
        }
    }

    #[test]
    fn test_execute_unknown_command() {
        let mut r = CommandRegistry::new();
        let result = r.execute("nonexistent", serde_json::Value::Null);
        assert!(!result.is_ok());
        matches!(result, CommandResult::Err(msg) if msg.contains("not found"));
    }

    #[test]
    fn test_unregister_extension() {
        let mut r = CommandRegistry::new();
        r.register_fn("ext1.cmd", "Cmd 1", "ext1", |_| CommandResult::void());
        r.register_fn("ext2.cmd", "Cmd 2", "ext2", |_| CommandResult::void());
        assert_eq!(r.len(), 2);
        r.unregister_extension("ext1");
        assert_eq!(r.len(), 1);
        assert!(!r.contains("ext1.cmd"));
        assert!(r.contains("ext2.cmd"));
    }

    #[test]
    fn test_palette_items_sorted_alphabetically() {
        let mut r = CommandRegistry::new();
        r.register_fn("c.zzz", "ZZZ", "ext", |_| CommandResult::void());
        r.register_fn("a.aaa", "AAA", "ext", |_| CommandResult::void());
        r.register_fn("b.mmm", "MMM", "ext", |_| CommandResult::void());
        let items = r.palette_items();
        let titles: Vec<&str> = items.iter().map(|i| i.title.as_str()).collect();
        assert_eq!(titles, vec!["AAA", "MMM", "ZZZ"]);
    }

    #[test]
    fn test_mru_ordering() {
        let mut r = CommandRegistry::new();
        r.register_fn("cmd.a", "A", "ext", |_| CommandResult::void());
        r.register_fn("cmd.b", "B", "ext", |_| CommandResult::void());
        r.register_fn("cmd.c", "C", "ext", |_| CommandResult::void());
        r.execute("cmd.b", serde_json::Value::Null);
        r.execute("cmd.a", serde_json::Value::Null);
        let items = r.palette_items();
        // cmd.a was used most recently, should be first
        assert_eq!(items[0].id, "cmd.a");
        assert_eq!(items[1].id, "cmd.b");
    }

    #[test]
    fn test_search_palette_fuzzy() {
        let mut r = CommandRegistry::new();
        r.register_fn("format.doc", "Format Document", "ext", |_| {
            CommandResult::void()
        });
        r.register_fn("format.sel", "Format Selection", "ext", |_| {
            CommandResult::void()
        });
        r.register_fn("find.replace", "Find Replace", "ext", |_| {
            CommandResult::void()
        });
        let results = r.search_palette("fmat");
        let ids: Vec<&str> = results.iter().map(|i| i.id.as_str()).collect();
        // "fmat" matches "Format" (f-m-a-t subsequence)
        assert!(
            ids.contains(&"format.doc") || ids.contains(&"format.sel"),
            "Should find format commands: {:?}",
            ids
        );
    }

    #[test]
    fn test_fuzzy_match() {
        assert!(fuzzy_match("Format Document", "fmd"));
        assert!(fuzzy_match("hello world", "hlo"));
        assert!(!fuzzy_match("abc", "xyz"));
        assert!(fuzzy_match("anything", ""));
    }

    #[test]
    fn test_builtin_commands_registered() {
        let r = reg_with_builtins();
        assert!(r.contains("undo"));
        assert!(r.contains("redo"));
        assert!(r.contains("editor.action.formatDocument"));
        assert!(r.contains("editor.action.selectAll"));
        assert!(r.len() >= 20);
    }

    #[test]
    fn test_builtin_categories() {
        let r = reg_with_builtins();
        let undo = r.get("undo").unwrap();
        assert_eq!(undo.category, Some("Edit".into()));
        let fmt = r.get("editor.action.formatDocument").unwrap();
        assert_eq!(fmt.category, Some("Format".into()));
    }

    #[test]
    fn test_command_result_helpers() {
        assert!(CommandResult::void().is_ok());
        assert!(CommandResult::ok(serde_json::json!(42)).is_ok());
        assert!(!CommandResult::err("oops").is_ok());
    }
}
