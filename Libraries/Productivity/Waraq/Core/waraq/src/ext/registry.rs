// src/ext/registry.rs
//
// Extension registry — loads, activates, and deactivates extensions.
//
// Extension lifecycle:
//   Registered → Activated → Running → Deactivating → Disposed
//
// For built-in (trait object) extensions the lifecycle is:
//   1. Host creates an `ExtensionEntry` with the manifest + factory function
//   2. On an activation event, `registry.activate(id)` calls the factory
//   3. Factory receives an `ExtensionContext` and registers its contributions
//   4. On deactivation, `registry.deactivate(id)` calls `context.dispose()`
//
// For WASM extensions (future):
//   1. Registry loads the .wasm module
//   2. Calls `waraq_activate(ctx_ptr)` inside the WASM sandbox
//   3. WASM communicates via a C ABI using the ext_api.rs functions

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use crate::ext::api::{ExtensionBus, ExtensionContext};
use crate::ext::manifest::{ActivationEvent, ExtensionKind, ExtensionManifest};

// ── Extension state ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ExtensionState {
    Registered,
    Activating,
    Active,
    Deactivating,
    Disposed,
    Failed,
}

pub struct ExtensionEntry {
    pub manifest: ExtensionManifest,
    pub state: ExtensionState,
    pub error: Option<String>,
    context: Option<ExtensionContext>,
    /// Factory that activates the extension. None for WASM extensions.
    activator: Option<Box<dyn Fn(&ExtensionContext) + Send + Sync>>,
}

impl std::fmt::Debug for ExtensionEntry {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ExtensionEntry")
            .field("id", &self.manifest.id)
            .field("state", &self.state)
            .finish()
    }
}

// ── Registry ──────────────────────────────────────────────────────────────────

pub struct ExtensionRegistry {
    extensions: HashMap<String, ExtensionEntry>,
    bus: Arc<Mutex<ExtensionBus>>,
    /// Activation events that have already fired (to avoid re-activating).
    fired_events: Vec<String>,
}

impl ExtensionRegistry {
    pub fn new(bus: Arc<Mutex<ExtensionBus>>) -> Self {
        Self {
            extensions: HashMap::new(),
            bus,
            fired_events: Vec::new(),
        }
    }

    pub fn with_new_bus() -> Self {
        let bus = Arc::new(Mutex::new(ExtensionBus::new()));
        Self::new(bus)
    }

    pub fn bus(&self) -> &Arc<Mutex<ExtensionBus>> {
        &self.bus
    }

    pub fn bus_handle(&self) -> Arc<Mutex<ExtensionBus>> {
        Arc::clone(&self.bus)
    }

    // ── Registration ──────────────────────────────────────────────────────────

    /// Register a built-in (trait object) extension.
    pub fn register<F>(&mut self, manifest: ExtensionManifest, activator: F)
    where
        F: Fn(&ExtensionContext) + Send + Sync + 'static,
    {
        let id = manifest.id.clone();
        self.extensions.insert(
            id,
            ExtensionEntry {
                manifest,
                state: ExtensionState::Registered,
                error: None,
                context: None,
                activator: Some(Box::new(activator)),
            },
        );
    }

    /// Register an extension from a JSON manifest (WASM / external).
    pub fn register_from_json(&mut self, manifest_json: &str) -> anyhow::Result<String> {
        let manifest = ExtensionManifest::from_json(manifest_json)?;
        let id = manifest.id.clone();
        self.extensions.insert(
            id.clone(),
            ExtensionEntry {
                manifest,
                state: ExtensionState::Registered,
                error: None,
                context: None,
                activator: None,
            },
        );
        Ok(id)
    }

    // ── Activation ────────────────────────────────────────────────────────────

    /// Activate a specific extension by ID.
    pub fn activate(&mut self, id: &str) -> Result<(), String> {
        let entry = self
            .extensions
            .get_mut(id)
            .ok_or_else(|| format!("Extension '{}' not found", id))?;

        if entry.state == ExtensionState::Active {
            return Ok(());
        }
        if entry.state == ExtensionState::Failed {
            return Err(entry.error.clone().unwrap_or_default());
        }

        entry.state = ExtensionState::Activating;
        let ext_id = entry.manifest.id.clone();

        let ctx = ExtensionContext::new(&ext_id, Arc::clone(&self.bus));

        // Call the activator if we have one (built-in extensions)
        if let Some(activator) = &entry.activator {
            (activator)(&ctx);
        }

        entry.context = Some(ctx);
        entry.state = ExtensionState::Active;
        Ok(())
    }

    /// Activate all extensions that respond to `OnStartup`.
    pub fn activate_startup(&mut self) {
        if self.fired_events.contains(&"OnStartup".to_owned()) {
            return;
        }
        self.fired_events.push("OnStartup".to_owned());

        let ids: Vec<String> = self
            .extensions
            .iter()
            .filter(|(_, e)| {
                e.manifest
                    .activation_events
                    .iter()
                    .any(|ev| matches!(ev, ActivationEvent::OnStartup))
                    && e.state == ExtensionState::Registered
            })
            .map(|(id, _)| id.clone())
            .collect();

        for id in ids {
            let _ = self.activate(&id);
        }
    }

    /// Activate all extensions that respond to `OnLanguage(language)`.
    pub fn activate_for_language(&mut self, language: &str) {
        let event_key = format!("OnLanguage:{}", language);
        if self.fired_events.contains(&event_key) {
            return;
        }
        self.fired_events.push(event_key);

        let ids: Vec<String> = self
            .extensions
            .iter()
            .filter(|(_, e)| {
                e.manifest.activates_for_language(language) && e.state == ExtensionState::Registered
            })
            .map(|(id, _)| id.clone())
            .collect();

        for id in ids {
            let _ = self.activate(&id);
        }
    }

    /// Activate all extensions that respond to `OnCommand(command_id)`.
    pub fn activate_for_command(&mut self, command_id: &str) {
        let ids: Vec<String> = self
            .extensions
            .iter()
            .filter(|(_, e)| {
                e.manifest.activates_for_command(command_id)
                    && e.state == ExtensionState::Registered
            })
            .map(|(id, _)| id.clone())
            .collect();

        for id in ids {
            let _ = self.activate(&id);
        }
    }

    // ── Deactivation ──────────────────────────────────────────────────────────

    /// Deactivate a specific extension.
    pub fn deactivate(&mut self, id: &str) -> Result<(), String> {
        let entry = self
            .extensions
            .get_mut(id)
            .ok_or_else(|| format!("Extension '{}' not found", id))?;

        if entry.state != ExtensionState::Active {
            return Ok(());
        }
        entry.state = ExtensionState::Deactivating;

        if let Some(ctx) = &entry.context {
            ctx.dispose();
        }
        entry.context = None;
        entry.state = ExtensionState::Disposed;
        Ok(())
    }

    /// Deactivate all active extensions.
    pub fn deactivate_all(&mut self) {
        let ids: Vec<String> = self.extensions.keys().cloned().collect();
        for id in ids {
            let _ = self.deactivate(&id);
        }
    }

    // ── Query ─────────────────────────────────────────────────────────────────

    pub fn get(&self, id: &str) -> Option<&ExtensionEntry> {
        self.extensions.get(id)
    }
    pub fn count(&self) -> usize {
        self.extensions.len()
    }
    pub fn active_count(&self) -> usize {
        self.extensions
            .values()
            .filter(|e| e.state == ExtensionState::Active)
            .count()
    }

    pub fn list(&self) -> Vec<ExtensionInfo> {
        let mut list: Vec<ExtensionInfo> = self
            .extensions
            .values()
            .map(|e| ExtensionInfo {
                id: e.manifest.id.clone(),
                name: e.manifest.name.clone(),
                version: e.manifest.version.clone(),
                state: e.state,
                kind: e.manifest.kind.clone(),
            })
            .collect();
        list.sort_by_key(|e| e.id.clone());
        list
    }
}

impl Default for ExtensionRegistry {
    fn default() -> Self {
        Self::with_new_bus()
    }
}

/// Lightweight summary of a registered extension.
#[derive(Debug, Clone, Serialize)]
pub struct ExtensionInfo {
    pub id: String,
    pub name: String,
    pub version: String,
    pub state: ExtensionState,
    pub kind: ExtensionKind,
}

// ── Example built-in extensions ───────────────────────────────────────────────

/// Register the set of built-in extensions that come with the editor.
pub fn register_builtin_extensions(registry: &mut ExtensionRegistry) {
    // Word count extension
    registry.register(
        {
            let mut m = ExtensionManifest::new("waraq.wordcount", "Word Count", "1.0.0");
            m.activation_events.push(ActivationEvent::OnStartup);
            m.contributes.commands.push(
                crate::ext::manifest::CommandContribution::new(
                    "waraq.wordcount.show",
                    "Word Count: Show Statistics",
                )
                .with_category("View"),
            );
            m
        },
        |ctx| {
            ctx.register_command(
                "waraq.wordcount.show",
                "Word Count: Show Statistics",
                |_| CommandResult::ok(serde_json::json!({ "action": "showWordCount" })),
            );
            ctx.set_status_bar_item(crate::ext::api::StatusBarItem {
                id: "waraq.wordcount.status".into(),
                text: "0 words".into(),
                tooltip: Some("Word count".into()),
                command: Some("waraq.wordcount.show".into()),
                priority: 50,
                visible: true,
            });
        },
    );

    // Bracket coloriser extension
    registry.register(
        {
            let mut m =
                ExtensionManifest::new("waraq.bracket-coloriser", "Bracket Coloriser", "1.0.0");
            m.activation_events.push(ActivationEvent::OnStartup);
            m
        },
        |ctx| {
            // The bracket coloriser contributes no commands but activates bracket
            // rainbow data generation (handled in syntax/bracket.rs)
            ctx.show_info_message("Bracket Coloriser activated");
        },
    );

    // Rust snippets extension
    registry.register(
        {
            let mut m = ExtensionManifest::new("waraq.rust-snippets", "Rust Snippets", "1.0.0");
            m.activation_events
                .push(ActivationEvent::OnLanguage("rust".into()));
            m
        },
        |ctx| {
            ctx.register_snippets(vec![
                Snippet::new(
                    "fn",
                    &[
                        "fn ${1:name}(${2:args}) -> ${3:ReturnType} {",
                        "    ${0}",
                        "}",
                    ],
                    "Function definition",
                    "rust",
                ),
                Snippet::new(
                    "impl",
                    &["impl ${1:Type} {", "    ${0}", "}"],
                    "Impl block",
                    "rust",
                ),
                Snippet::new(
                    "struct",
                    &["struct ${1:Name} {", "    ${0}", "}"],
                    "Struct definition",
                    "rust",
                ),
                Snippet::new(
                    "enum",
                    &["enum ${1:Name} {", "    ${0}", "}"],
                    "Enum definition",
                    "rust",
                ),
                Snippet::new(
                    "match",
                    &[
                        "match ${1:expr} {",
                        "    ${2:pattern} => ${3:result},",
                        "    _ => ${0},",
                        "}",
                    ],
                    "Match expression",
                    "rust",
                ),
                Snippet::new(
                    "if let",
                    &[
                        "if let ${1:Pattern}(${2:var}) = ${3:expr} {",
                        "    ${0}",
                        "}",
                    ],
                    "If let",
                    "rust",
                ),
                Snippet::new(
                    "for",
                    &["for ${1:item} in ${2:iter} {", "    ${0}", "}"],
                    "For loop",
                    "rust",
                ),
                Snippet::new(
                    "while",
                    &["while ${1:condition} {", "    ${0}", "}"],
                    "While loop",
                    "rust",
                ),
                Snippet::new(
                    "test",
                    &["#[test]", "fn ${1:test_name}() {", "    ${0}", "}"],
                    "Test function",
                    "rust",
                ),
                Snippet::new(
                    "derive",
                    &["#[derive(${1:Debug, Clone})]"],
                    "Derive macro",
                    "rust",
                ),
                Snippet::new("todo", &["todo!(\"${1:implement}\")"], "Todo macro", "rust"),
                Snippet::new("dbg", &["dbg!(&${1:value})"], "Debug macro", "rust"),
            ]);
        },
    );

    // Python snippets extension
    registry.register(
        {
            let mut m = ExtensionManifest::new("waraq.python-snippets", "Python Snippets", "1.0.0");
            m.activation_events
                .push(ActivationEvent::OnLanguage("python".into()));
            m
        },
        |ctx| {
            ctx.register_snippets(vec![
                Snippet::new(
                    "def",
                    &["def ${1:name}(${2:args}):", "    ${0}"],
                    "Function definition",
                    "python",
                ),
                Snippet::new(
                    "class",
                    &[
                        "class ${1:Name}:",
                        "    def __init__(self${2:, args}):",
                        "        ${0}",
                    ],
                    "Class definition",
                    "python",
                ),
                Snippet::new(
                    "if",
                    &["if ${1:condition}:", "    ${0}"],
                    "If statement",
                    "python",
                ),
                Snippet::new(
                    "for",
                    &["for ${1:item} in ${2:iterable}:", "    ${0}"],
                    "For loop",
                    "python",
                ),
                Snippet::new(
                    "with",
                    &["with ${1:expr} as ${2:var}:", "    ${0}"],
                    "With statement",
                    "python",
                ),
                Snippet::new(
                    "try",
                    &[
                        "try:",
                        "    ${1}",
                        "except ${2:Exception} as e:",
                        "    ${0}",
                    ],
                    "Try/except",
                    "python",
                ),
                Snippet::new(
                    "test",
                    &["def test_${1:name}():", "    ${0}"],
                    "Test function",
                    "python",
                ),
            ]);
        },
    );
}

use crate::ext::commands::CommandResult;
use crate::ext::contribution::Snippet;

#[cfg(test)]
mod tests {
    use super::*;

    fn registry() -> ExtensionRegistry {
        let mut r = ExtensionRegistry::with_new_bus();
        register_builtin_extensions(&mut r);
        r
    }

    #[test]
    fn test_register_and_activate() {
        let mut r = ExtensionRegistry::with_new_bus();
        r.register(
            {
                let mut m = ExtensionManifest::new("test.ext", "Test", "1.0.0");
                m.activation_events.push(ActivationEvent::OnStartup);
                m
            },
            |ctx| {
                ctx.register_command("test.hello", "Test: Hello", |_| CommandResult::void());
            },
        );

        assert_eq!(r.count(), 1);
        assert_eq!(r.active_count(), 0);

        r.activate_startup();
        assert_eq!(r.active_count(), 1);

        let entry = r.get("test.ext").unwrap();
        assert_eq!(entry.state, ExtensionState::Active);

        // Command should now be registered in the bus
        let bus = r.bus().lock().unwrap();
        assert!(bus.commands.contains("test.hello"));
    }

    #[test]
    fn test_activate_twice_is_idempotent() {
        let mut r = ExtensionRegistry::with_new_bus();
        r.register(
            ExtensionManifest::new("test.ext", "Test", "1.0.0"),
            |_ctx| {},
        );
        r.activate("test.ext").unwrap();
        r.activate("test.ext").unwrap(); // should not error
        assert_eq!(r.active_count(), 1);
    }

    #[test]
    fn test_activate_for_language() {
        let mut r = registry();
        assert_eq!(
            r.get("waraq.rust-snippets").unwrap().state,
            ExtensionState::Registered
        );
        r.activate_for_language("rust");
        assert_eq!(
            r.get("waraq.rust-snippets").unwrap().state,
            ExtensionState::Active
        );
        // Snippets should be registered
        let bus = r.bus().lock().unwrap();
        let snips = bus.snippets.all_for_language("rust");
        assert!(!snips.is_empty(), "Rust snippets should be registered");
        assert!(snips.iter().any(|s| s.prefix == "fn"));
    }

    #[test]
    fn test_activate_for_command() {
        let mut r = ExtensionRegistry::with_new_bus();
        r.register(
            {
                let mut m = ExtensionManifest::new("lazy.ext", "Lazy", "1.0.0");
                m.activation_events
                    .push(ActivationEvent::OnCommand("lazy.run".into()));
                m
            },
            |ctx| {
                ctx.register_command("lazy.run", "Lazy: Run", |_| {
                    CommandResult::ok(serde_json::json!({ "ran": true }))
                });
            },
        );

        assert_eq!(r.get("lazy.ext").unwrap().state, ExtensionState::Registered);
        r.activate_for_command("lazy.run");
        assert_eq!(r.get("lazy.ext").unwrap().state, ExtensionState::Active);
    }

    #[test]
    fn test_deactivate() {
        let mut r = ExtensionRegistry::with_new_bus();
        r.register(
            {
                let mut m = ExtensionManifest::new("test.ext", "Test", "1.0.0");
                m.activation_events.push(ActivationEvent::OnStartup);
                m
            },
            |ctx| {
                ctx.register_command("test.cmd", "Test Cmd", |_| CommandResult::void());
            },
        );
        r.activate_startup();
        assert_eq!(r.active_count(), 1);
        {
            let bus = r.bus().lock().unwrap();
            assert!(bus.commands.contains("test.cmd"));
        }

        r.deactivate("test.ext").unwrap();
        assert_eq!(r.get("test.ext").unwrap().state, ExtensionState::Disposed);
        {
            let bus = r.bus().lock().unwrap();
            assert!(
                !bus.commands.contains("test.cmd"),
                "Command should be removed after deactivation"
            );
        }
    }

    #[test]
    fn test_deactivate_all() {
        let mut r = registry();
        r.activate_startup();
        let initial_active = r.active_count();
        assert!(initial_active > 0);
        r.deactivate_all();
        assert_eq!(r.active_count(), 0);
    }

    #[test]
    fn test_builtin_extensions_registered() {
        let r = registry();
        assert!(r.get("waraq.wordcount").is_some());
        assert!(r.get("waraq.rust-snippets").is_some());
        assert!(r.get("waraq.python-snippets").is_some());
        assert!(r.get("waraq.bracket-coloriser").is_some());
    }

    #[test]
    fn test_list_extensions() {
        let r = registry();
        let list = r.list();
        assert!(!list.is_empty());
        let ids: Vec<&str> = list.iter().map(|e| e.id.as_str()).collect();
        assert!(ids.contains(&"waraq.wordcount"));
    }

    #[test]
    fn test_register_from_json() {
        let mut r = ExtensionRegistry::with_new_bus();
        let json = serde_json::to_string(&ExtensionManifest::new("json.ext", "JSON Ext", "1.0.0"))
            .unwrap();
        let id = r.register_from_json(&json).unwrap();
        assert_eq!(id, "json.ext");
        assert_eq!(r.get("json.ext").unwrap().state, ExtensionState::Registered);
    }

    #[test]
    fn test_wordcount_status_bar_after_startup() {
        let mut r = registry();
        r.activate_startup();
        let bus = r.bus().lock().unwrap();
        assert!(
            !bus.status_bar.is_empty(),
            "Word count status bar item should be registered"
        );
        assert!(bus.status_bar.iter().any(|i| i.id.contains("wordcount")));
    }

    #[test]
    fn test_python_snippets_activate_on_language() {
        let mut r = registry();
        r.activate_for_language("python");
        let bus = r.bus().lock().unwrap();
        let snips = bus.snippets.all_for_language("python");
        assert!(!snips.is_empty());
        assert!(snips.iter().any(|s| s.prefix == "def"));
        assert!(snips.iter().any(|s| s.prefix == "class"));
    }
}
