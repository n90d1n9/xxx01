// src/ext/event.rs
//
// Extension event bus — lets extensions subscribe to editor lifecycle events.
//
// Mirrors the Monaco event model:
//   editor.onDidChangeModelContent  → TextChangeEvent
//   editor.onDidChangeCursorPosition → CursorChangeEvent
//   editor.onDidChangeCursorSelection → SelectionChangeEvent
//   editor.onDidScrollChange → ScrollChangeEvent
//   editor.onDidFocusEditorText / onDidBlurEditorText
//   workspace.onDidOpenTextDocument / onDidCloseTextDocument
//   workspace.onDidSaveTextDocument
//   languages.onDidChangeDiagnostics
//
// Design:
//   • Listeners are trait objects stored behind Arc<Mutex<>>
//   • `subscribe()` returns a `SubscriptionHandle` (drop to unsubscribe)
//   • Events are dispatched synchronously in document-change order
//   • Thread-safe: can be called from background threads (LSP, AI)

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use crate::core::types::Range;

// ── Event types ───────────────────────────────────────────────────────────────

/// A single text change: what was replaced and what replaced it.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentChange {
    /// Byte range that was replaced (start..end).
    pub range: Range,
    /// New text inserted at range.start.
    pub text: String,
    /// The version counter after this change.
    pub version: u64,
    /// Was this change caused by undo/redo?
    pub is_undo_redo: bool,
}

/// Emitted when the document's text content changes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextChangeEvent {
    pub file_uri: String,
    pub changes: Vec<ContentChange>,
    pub version: u64,
}

/// Emitted when the cursor position changes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CursorChangeEvent {
    pub file_uri: String,
    pub line: usize,
    pub column: usize,
    pub byte_offset: usize,
    /// True if triggered by a selection (not just cursor movement).
    pub selection_active: bool,
}

/// Emitted when the selection changes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SelectionChangeEvent {
    pub file_uri: String,
    pub selections: Vec<SelectionRange>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SelectionRange {
    pub start_line: usize,
    pub start_col: usize,
    pub end_line: usize,
    pub end_col: usize,
    pub start_byte: usize,
    pub end_byte: usize,
    pub is_reversed: bool,
}

/// Emitted when the viewport scrolls.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScrollChangeEvent {
    pub file_uri: String,
    pub scroll_top: usize,  // first visible line
    pub scroll_left: usize, // horizontal scroll (col offset)
    pub visible_lines: usize,
}

/// Emitted when a document is opened.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentOpenEvent {
    pub file_uri: String,
    pub language: String,
    pub line_count: usize,
}

/// Emitted when a document is closed.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentCloseEvent {
    pub file_uri: String,
}

/// Emitted when a document is saved.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentSaveEvent {
    pub file_uri: String,
    pub version: u64,
}

/// Emitted when diagnostics change for a file.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiagnosticsChangedEvent {
    pub file_uri: String,
    pub error_count: usize,
    pub warning_count: usize,
    pub info_count: usize,
}

/// Emitted when the active language changes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LanguageChangeEvent {
    pub file_uri: String,
    pub language: String,
}

/// Emitted when the active theme changes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ThemeChangeEvent {
    pub theme_id: String,
    pub theme_name: String,
}

/// All events that extensions can subscribe to.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "camelCase")]
pub enum ExtensionEvent {
    TextChanged(TextChangeEvent),
    CursorChanged(CursorChangeEvent),
    SelectionChanged(SelectionChangeEvent),
    ScrollChanged(ScrollChangeEvent),
    DocumentOpened(DocumentOpenEvent),
    DocumentClosed(DocumentCloseEvent),
    DocumentSaved(DocumentSaveEvent),
    DiagnosticsChanged(DiagnosticsChangedEvent),
    LanguageChanged(LanguageChangeEvent),
    ThemeChanged(ThemeChangeEvent),
    EditorFocused { file_uri: String },
    EditorBlurred { file_uri: String },
}

impl ExtensionEvent {
    pub fn kind(&self) -> &'static str {
        match self {
            Self::TextChanged(_) => "textChanged",
            Self::CursorChanged(_) => "cursorChanged",
            Self::SelectionChanged(_) => "selectionChanged",
            Self::ScrollChanged(_) => "scrollChanged",
            Self::DocumentOpened(_) => "documentOpened",
            Self::DocumentClosed(_) => "documentClosed",
            Self::DocumentSaved(_) => "documentSaved",
            Self::DiagnosticsChanged(_) => "diagnosticsChanged",
            Self::LanguageChanged(_) => "languageChanged",
            Self::ThemeChanged(_) => "themeChanged",
            Self::EditorFocused { .. } => "editorFocused",
            Self::EditorBlurred { .. } => "editorBlurred",
        }
    }

    pub fn file_uri(&self) -> Option<&str> {
        match self {
            Self::TextChanged(e) => Some(&e.file_uri),
            Self::CursorChanged(e) => Some(&e.file_uri),
            Self::SelectionChanged(e) => Some(&e.file_uri),
            Self::ScrollChanged(e) => Some(&e.file_uri),
            Self::DocumentOpened(e) => Some(&e.file_uri),
            Self::DocumentClosed(e) => Some(&e.file_uri),
            Self::DocumentSaved(e) => Some(&e.file_uri),
            Self::DiagnosticsChanged(e) => Some(&e.file_uri),
            Self::LanguageChanged(e) => Some(&e.file_uri),
            Self::EditorFocused { file_uri } => Some(file_uri),
            Self::EditorBlurred { file_uri } => Some(file_uri),
            _ => None,
        }
    }
}

// ── Listener trait ────────────────────────────────────────────────────────────

pub trait EventListener: Send + Sync {
    fn on_event(&self, event: &ExtensionEvent);
}

/// Convenience wrapper for closures.
pub struct FnListener<F: Fn(&ExtensionEvent) + Send + Sync>(pub F);

impl<F: Fn(&ExtensionEvent) + Send + Sync> EventListener for FnListener<F> {
    fn on_event(&self, event: &ExtensionEvent) {
        (self.0)(event);
    }
}

// ── Subscription handle ───────────────────────────────────────────────────────

/// Dropping this handle unsubscribes the listener.
pub struct SubscriptionHandle {
    id: u64,
    bus: Arc<Mutex<EventBusInner>>,
}

impl Drop for SubscriptionHandle {
    fn drop(&mut self) {
        if let Ok(mut inner) = self.bus.lock() {
            inner.listeners.remove(&self.id);
        }
    }
}

// ── Event bus ─────────────────────────────────────────────────────────────────

struct EventBusInner {
    listeners: HashMap<u64, Box<dyn EventListener>>,
    next_id: u64,
    /// Buffer of recent events for extensions that poll instead of subscribe.
    event_log: std::collections::VecDeque<ExtensionEvent>,
    log_capacity: usize,
}

impl EventBusInner {
    fn new() -> Self {
        Self {
            listeners: HashMap::new(),
            next_id: 1,
            event_log: std::collections::VecDeque::new(),
            log_capacity: 256,
        }
    }
}

/// The shared editor event bus.
#[derive(Clone)]
pub struct EditorEventBus {
    inner: Arc<Mutex<EventBusInner>>,
}

impl EditorEventBus {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(Mutex::new(EventBusInner::new())),
        }
    }

    // ── Subscription ──────────────────────────────────────────────────────────

    /// Subscribe with a trait object. Returns a handle — drop to unsubscribe.
    pub fn subscribe(&self, listener: Box<dyn EventListener>) -> SubscriptionHandle {
        let mut inner = self.inner.lock().unwrap();
        let id = inner.next_id;
        inner.next_id += 1;
        inner.listeners.insert(id, listener);
        SubscriptionHandle {
            id,
            bus: Arc::clone(&self.inner),
        }
    }

    /// Subscribe with a closure.
    pub fn on<F: Fn(&ExtensionEvent) + Send + Sync + 'static>(&self, f: F) -> SubscriptionHandle {
        self.subscribe(Box::new(FnListener(f)))
    }

    /// Subscribe only to a specific event kind.
    pub fn on_kind<F: Fn(&ExtensionEvent) + Send + Sync + 'static>(
        &self,
        kind: &'static str,
        f: F,
    ) -> SubscriptionHandle {
        self.on(move |e| {
            if e.kind() == kind {
                f(e);
            }
        })
    }

    // ── Dispatch ──────────────────────────────────────────────────────────────

    /// Emit an event to all subscribers.
    pub fn emit(&self, event: ExtensionEvent) {
        let mut inner = self.inner.lock().unwrap();
        // Log the event
        if inner.event_log.len() >= inner.log_capacity {
            inner.event_log.pop_front();
        }
        inner.event_log.push_back(event.clone());
        // Dispatch to listeners
        for listener in inner.listeners.values() {
            listener.on_event(&event);
        }
    }

    // ── Convenience emitters ──────────────────────────────────────────────────

    pub fn emit_text_changed(&self, file_uri: &str, changes: Vec<ContentChange>, version: u64) {
        self.emit(ExtensionEvent::TextChanged(TextChangeEvent {
            file_uri: file_uri.to_owned(),
            changes,
            version,
        }));
    }

    pub fn emit_cursor_changed(
        &self,
        file_uri: &str,
        line: usize,
        column: usize,
        byte_offset: usize,
        selection_active: bool,
    ) {
        self.emit(ExtensionEvent::CursorChanged(CursorChangeEvent {
            file_uri: file_uri.to_owned(),
            line,
            column,
            byte_offset,
            selection_active,
        }));
    }

    pub fn emit_document_opened(&self, file_uri: &str, language: &str, line_count: usize) {
        self.emit(ExtensionEvent::DocumentOpened(DocumentOpenEvent {
            file_uri: file_uri.to_owned(),
            language: language.to_owned(),
            line_count,
        }));
    }

    pub fn emit_document_closed(&self, file_uri: &str) {
        self.emit(ExtensionEvent::DocumentClosed(DocumentCloseEvent {
            file_uri: file_uri.to_owned(),
        }));
    }

    pub fn emit_document_saved(&self, file_uri: &str, version: u64) {
        self.emit(ExtensionEvent::DocumentSaved(DocumentSaveEvent {
            file_uri: file_uri.to_owned(),
            version,
        }));
    }

    pub fn emit_diagnostics_changed(
        &self,
        file_uri: &str,
        error_count: usize,
        warning_count: usize,
        info_count: usize,
    ) {
        self.emit(ExtensionEvent::DiagnosticsChanged(
            DiagnosticsChangedEvent {
                file_uri: file_uri.to_owned(),
                error_count,
                warning_count,
                info_count,
            },
        ));
    }

    pub fn emit_language_changed(&self, file_uri: &str, language: &str) {
        self.emit(ExtensionEvent::LanguageChanged(LanguageChangeEvent {
            file_uri: file_uri.to_owned(),
            language: language.to_owned(),
        }));
    }

    pub fn emit_theme_changed(&self, theme_id: &str, theme_name: &str) {
        self.emit(ExtensionEvent::ThemeChanged(ThemeChangeEvent {
            theme_id: theme_id.to_owned(),
            theme_name: theme_name.to_owned(),
        }));
    }

    pub fn emit_scroll_changed(
        &self,
        file_uri: &str,
        scroll_top: usize,
        scroll_left: usize,
        visible_lines: usize,
    ) {
        self.emit(ExtensionEvent::ScrollChanged(ScrollChangeEvent {
            file_uri: file_uri.to_owned(),
            scroll_top,
            scroll_left,
            visible_lines,
        }));
    }

    // ── Polling API (for WASM / non-closure consumers) ─────────────────────────

    /// Drain all buffered events (non-destructive view of the log).
    pub fn poll_events(&self) -> Vec<ExtensionEvent> {
        self.inner
            .lock()
            .unwrap()
            .event_log
            .iter()
            .cloned()
            .collect()
    }

    /// Drain all buffered events, clearing the log.
    pub fn drain_events(&self) -> Vec<ExtensionEvent> {
        self.inner.lock().unwrap().event_log.drain(..).collect()
    }

    /// Drain events of a specific kind.
    pub fn drain_kind(&self, kind: &str) -> Vec<ExtensionEvent> {
        let mut inner = self.inner.lock().unwrap();
        let matching: Vec<_> = inner
            .event_log
            .iter()
            .filter(|e| e.kind() == kind)
            .cloned()
            .collect();
        inner.event_log.retain(|e| e.kind() != kind);
        matching
    }

    pub fn pending_count(&self) -> usize {
        self.inner.lock().unwrap().event_log.len()
    }

    pub fn subscriber_count(&self) -> usize {
        self.inner.lock().unwrap().listeners.len()
    }
}

impl Default for EditorEventBus {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::{Arc, Mutex};

    #[test]
    fn test_emit_and_receive() {
        let bus = EditorEventBus::new();
        let received: Arc<Mutex<Vec<String>>> = Arc::new(Mutex::new(vec![]));
        let r = Arc::clone(&received);

        let _handle = bus.on(move |e| {
            r.lock().unwrap().push(e.kind().to_owned());
        });

        bus.emit_text_changed("file:///a.rs", vec![], 1);
        bus.emit_cursor_changed("file:///a.rs", 0, 0, 0, false);
        bus.emit_document_opened("file:///a.rs", "rust", 10);

        let got = received.lock().unwrap().clone();
        assert_eq!(got, vec!["textChanged", "cursorChanged", "documentOpened"]);
    }

    #[test]
    fn test_subscription_handle_drop_unsubscribes() {
        let bus = EditorEventBus::new();
        let count: Arc<Mutex<usize>> = Arc::new(Mutex::new(0));
        let c = Arc::clone(&count);

        let handle = bus.on(move |_| {
            *c.lock().unwrap() += 1;
        });
        bus.emit_text_changed("file:///a.rs", vec![], 1);
        assert_eq!(*count.lock().unwrap(), 1);

        drop(handle); // unsubscribe
        bus.emit_text_changed("file:///a.rs", vec![], 2);
        assert_eq!(
            *count.lock().unwrap(),
            1,
            "Should not receive after unsubscribe"
        );
    }

    #[test]
    fn test_on_kind_filter() {
        let bus = EditorEventBus::new();
        let text_events: Arc<Mutex<usize>> = Arc::new(Mutex::new(0));
        let c = Arc::clone(&text_events);

        let _h = bus.on_kind("textChanged", move |_| {
            *c.lock().unwrap() += 1;
        });

        bus.emit_text_changed("file:///a.rs", vec![], 1);
        bus.emit_cursor_changed("file:///a.rs", 0, 0, 0, false);
        bus.emit_document_opened("file:///a.rs", "rust", 5);

        assert_eq!(
            *text_events.lock().unwrap(),
            1,
            "Only textChanged should be counted"
        );
    }

    #[test]
    fn test_poll_events() {
        let bus = EditorEventBus::new();
        bus.emit_language_changed("file:///a.rs", "rust");
        bus.emit_theme_changed("waraq.dracula", "Dracula");

        let events = bus.poll_events();
        assert_eq!(events.len(), 2);
        // poll_events is non-destructive
        assert_eq!(bus.pending_count(), 2);
    }

    #[test]
    fn test_drain_events() {
        let bus = EditorEventBus::new();
        bus.emit_document_opened("file:///a.rs", "rust", 1);
        bus.emit_document_closed("file:///a.rs");

        let drained = bus.drain_events();
        assert_eq!(drained.len(), 2);
        assert_eq!(bus.pending_count(), 0);
    }

    #[test]
    fn test_drain_kind() {
        let bus = EditorEventBus::new();
        bus.emit_text_changed("file:///a.rs", vec![], 1);
        bus.emit_cursor_changed("file:///a.rs", 5, 3, 30, false);
        bus.emit_text_changed("file:///a.rs", vec![], 2);

        let text_events = bus.drain_kind("textChanged");
        assert_eq!(text_events.len(), 2);
        assert_eq!(bus.pending_count(), 1); // cursor event remains
    }

    #[test]
    fn test_event_log_capacity() {
        let bus = EditorEventBus::new();
        // Fill past capacity
        for i in 0..300 {
            bus.emit_text_changed("file:///a.rs", vec![], i as u64);
        }
        // Should be capped at 256
        assert!(bus.pending_count() <= 256);
    }

    #[test]
    fn test_multiple_subscribers() {
        let bus = EditorEventBus::new();
        let c1: Arc<Mutex<usize>> = Arc::new(Mutex::new(0));
        let c2: Arc<Mutex<usize>> = Arc::new(Mutex::new(0));
        let cc1 = Arc::clone(&c1);
        let cc2 = Arc::clone(&c2);

        let _h1 = bus.on(move |_| {
            *cc1.lock().unwrap() += 1;
        });
        let _h2 = bus.on(move |_| {
            *cc2.lock().unwrap() += 1;
        });

        bus.emit_document_saved("file:///x.rs", 1);

        assert_eq!(*c1.lock().unwrap(), 1);
        assert_eq!(*c2.lock().unwrap(), 1);
    }

    #[test]
    fn test_event_file_uri() {
        let e = ExtensionEvent::TextChanged(TextChangeEvent {
            file_uri: "file:///foo.rs".into(),
            changes: vec![],
            version: 1,
        });
        assert_eq!(e.file_uri(), Some("file:///foo.rs"));

        let e2 = ExtensionEvent::ThemeChanged(ThemeChangeEvent {
            theme_id: "d".into(),
            theme_name: "Dracula".into(),
        });
        assert!(e2.file_uri().is_none());
    }

    #[test]
    fn test_all_event_kinds_have_names() {
        let events: Vec<ExtensionEvent> = vec![
            ExtensionEvent::TextChanged(TextChangeEvent {
                file_uri: "f".into(),
                changes: vec![],
                version: 0,
            }),
            ExtensionEvent::CursorChanged(CursorChangeEvent {
                file_uri: "f".into(),
                line: 0,
                column: 0,
                byte_offset: 0,
                selection_active: false,
            }),
            ExtensionEvent::DocumentOpened(DocumentOpenEvent {
                file_uri: "f".into(),
                language: "rust".into(),
                line_count: 1,
            }),
            ExtensionEvent::DocumentClosed(DocumentCloseEvent {
                file_uri: "f".into(),
            }),
            ExtensionEvent::DocumentSaved(DocumentSaveEvent {
                file_uri: "f".into(),
                version: 1,
            }),
            ExtensionEvent::DiagnosticsChanged(DiagnosticsChangedEvent {
                file_uri: "f".into(),
                error_count: 0,
                warning_count: 0,
                info_count: 0,
            }),
            ExtensionEvent::LanguageChanged(LanguageChangeEvent {
                file_uri: "f".into(),
                language: "rust".into(),
            }),
            ExtensionEvent::ThemeChanged(ThemeChangeEvent {
                theme_id: "t".into(),
                theme_name: "T".into(),
            }),
        ];
        for e in &events {
            assert!(!e.kind().is_empty(), "Kind should not be empty for {:?}", e);
        }
    }
}
