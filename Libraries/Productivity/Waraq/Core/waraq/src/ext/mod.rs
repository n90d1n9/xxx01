// src/ext/mod.rs — Extension system public API

pub mod api;
pub mod commands;
pub mod contribution;
pub mod event;
pub mod keybinding;
pub mod manifest;
pub mod providers;
pub mod registry;

pub use api::{
    CodeAction, CodeActionProvider, CodeActionRequest, CompletionItem, CompletionItemKind,
    CompletionProvider, CompletionRequest, DiagSeverity, DiagnosticItem, DiagnosticProvider,
    DiagnosticRequest, DocumentPosition, ExtensionBus, ExtensionContext, FormatRequest,
    FormatterProvider, HoverProvider, HoverRequest, HoverResponse, Notification, NotificationKind,
    StatusBarItem, TextEdit as ExtTextEdit,
};
pub use commands::{
    register_builtin_commands, CommandArgs, CommandRegistry, CommandResult, PaletteItem,
};
pub use contribution::{
    ExpandedSnippet, LanguageRegistry, Snippet, SnippetEngine, TabStop, Theme, ThemeColor,
    ThemeEngine,
};
pub use event::{
    EditorEventBus, EventListener, ExtensionEvent, SubscriptionHandle, TextChangeEvent,
};
pub use keybinding::{
    default_keybindings, KeyChord, KeyContext, KeyResolution, KeySequence, KeybindingEngine,
    KeybindingEntry,
};
pub use manifest::{
    ActivationEvent, CommandContribution, Contributions, ExtensionKind, ExtensionManifest,
    KeybindingContribution, LanguageContribution, StatusBarAlignment, StatusBarContribution,
    ThemeContribution, ThemeKind, ThemeKind as ManifestThemeKind,
};
pub use providers::{
    Color, ColorInformation, ColorPresentation, ColorProvider, DefinitionProvider,
    DocumentHighlight, DocumentHighlightKind, DocumentHighlightProvider, DocumentSymbol,
    DocumentSymbolKind, DocumentSymbolProvider, FoldingRange as ExtFoldingRange, FoldingRangeKind,
    FoldingRangeProvider, InlayHint, InlayHintKind, InlayHintProvider, LanguageConfiguration,
    LanguageFeatureRegistry, LinkedEditingRangeProvider, LinkedEditingRanges,
    Location as ExtLocation, MonarchLanguage, MonarchRule, ParameterInformation, ReferenceContext,
    ReferenceProvider, RenameProvider, SignatureHelp, SignatureHelpProvider, SignatureInformation,
    WorkspaceEdit,
};
pub use registry::{
    register_builtin_extensions, ExtensionEntry, ExtensionInfo, ExtensionRegistry, ExtensionState,
};

#[cfg(test)]
mod mod_tests {
    use super::*;

    #[test]
    fn test_extension_registry_built_ins_registered() {
        let mut reg = ExtensionRegistry::with_new_bus();
        register_builtin_extensions(&mut reg);
        assert!(
            reg.count() >= 4,
            "Should have at least 4 built-in extensions"
        );
    }

    #[test]
    fn test_extension_registry_activate_startup() {
        let mut reg = ExtensionRegistry::with_new_bus();
        register_builtin_extensions(&mut reg);
        reg.activate_startup();
        assert!(reg.active_count() > 0, "Startup extensions should activate");
    }

    #[test]
    fn test_extension_registry_activate_for_language() {
        let mut reg = ExtensionRegistry::with_new_bus();
        register_builtin_extensions(&mut reg);
        reg.activate_for_language("rust");
        // After activating for rust, rust-snippets extension should be active
        assert!(reg.active_count() > 0);
    }

    #[test]
    fn test_command_registry_builtin_commands() {
        let mut cr = CommandRegistry::new();
        register_builtin_commands(&mut cr);
        assert!(
            !cr.palette_items().is_empty(),
            "Should have built-in commands"
        );
    }

    #[test]
    fn test_keybinding_engine_default_bindings() {
        use crate::ext::keybinding::{KeyChord, KeyContext, KeyResolution, KeybindingEngine};
        let mut engine = KeybindingEngine::new();
        for binding in default_keybindings() {
            engine.register(binding);
        }
        let chord = KeyChord::parse("ctrl+s").unwrap();
        let mut ctx = KeyContext::new();
        ctx.set("editorFocus");
        let r = engine.resolve(chord, &ctx);
        assert!(
            matches!(r, KeyResolution::Command(_)),
            "ctrl+s should be bound"
        );
    }

    #[test]
    fn test_theme_engine_has_builtin_themes() {
        let te = ThemeEngine::new();
        let list = te.list();
        assert!(
            list.iter().any(|(id, _, _)| id.contains("dracula")),
            "Should have Dracula theme"
        );
        assert!(
            list.iter().any(|(id, _, _)| id.contains("github")),
            "Should have GitHub Light theme"
        );
    }

    #[test]
    fn test_snippet_engine_has_rust_snippets() {
        let _se = SnippetEngine::new();
        // Register via extension bus
        let mut reg = ExtensionRegistry::with_new_bus();
        register_builtin_extensions(&mut reg);
        reg.activate_for_language("rust");
        let bus = reg.bus().lock().unwrap();
        let snips = bus.snippets.all_for_language("rust");
        assert!(
            !snips.is_empty(),
            "Should have Rust snippets after activation"
        );
    }

    #[test]
    fn test_language_registry_detects_rust() {
        let lr = LanguageRegistry::new();
        assert_eq!(lr.detect("main.rs", None), Some("rust"));
    }

    #[test]
    fn test_language_registry_detects_python_shebang() {
        let lr = LanguageRegistry::new();
        assert_eq!(
            lr.detect("script", Some("#!/usr/bin/env python3")),
            Some("python")
        );
    }

    #[test]
    fn test_editor_event_bus_reexport() {
        let bus = EditorEventBus::new();
        let n = bus.subscriber_count();
        assert_eq!(n, 0);
    }
}
