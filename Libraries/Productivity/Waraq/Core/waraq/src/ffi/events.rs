// src/ffi/events.rs
//
// Event bus — pushes asynchronous notifications from the Rust engine
// back to the host (Flutter / Java / WASM) without blocking the editor.
//
// Why this matters:
//   The engine processes LSP responses, AI completions, and syntax updates
//   on background threads. The host UI thread must be notified via a
//   callback/polling mechanism — not by blocking the FFI call that triggered
//   the work.
//
// Architecture:
//   • `EventQueue` is an MPSC channel between the engine and the FFI layer.
//   • Events are serialised to JSON and polled by the host every frame.
//   • The host registers a callback (function pointer) which is invoked
//     when events are available — for platforms that support callbacks.
//
// On platforms that do not support function pointer callbacks (WASM),
// the host should poll `editor_poll_events` each animation frame.

use std::collections::VecDeque;
use std::sync::{Arc, Mutex};

use serde::{Deserialize, Serialize};

// ── Event types ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum EditorEvent {
    /// LSP diagnostics updated.
    DiagnosticsUpdated {
        file_uri: String,
        count: usize,
        error_count: usize,
        warning_count: usize,
    },

    /// AI completion suggestion is ready.
    CompletionReady {
        request_id: u64,
        suggestion: String,
        insert_at: usize,
        is_multiline: bool,
    },

    /// AI completion request was cancelled or failed.
    CompletionCancelled { request_id: u64, reason: String },

    /// Syntax highlighting updated for a range of lines.
    SyntaxUpdated { first_line: usize, last_line: usize },

    /// Document was modified by an external process (e.g. file watcher).
    DocumentChanged { file_uri: String },

    /// An LSP code action is available at the cursor position.
    CodeActionAvailable {
        line: usize,
        col: usize,
        count: usize,
    },

    /// A find-in-files search completed.
    SearchCompleted {
        query: String,
        total_matches: usize,
        files_with_matches: usize,
    },

    /// Background formatting completed.
    FormatCompleted {
        file_uri: String,
        edits_applied: usize,
    },

    /// An error occurred in a background operation.
    BackgroundError { operation: String, message: String },

    /// Progress update for long-running operations.
    Progress {
        operation: String,
        /// 0.0–1.0, or -1.0 for indeterminate.
        fraction: f32,
        message: Option<String>,
    },
}

// ── Event queue ───────────────────────────────────────────────────────────────

/// Thread-safe event queue.
#[derive(Clone)]
pub struct EventQueue {
    inner: Arc<Mutex<VecDeque<EditorEvent>>>,
    max_capacity: usize,
}

impl EventQueue {
    pub fn new(max_capacity: usize) -> Self {
        Self {
            inner: Arc::new(Mutex::new(VecDeque::with_capacity(32))),
            max_capacity,
        }
    }

    /// Push an event. If the queue is full, the oldest event is dropped.
    pub fn push(&self, event: EditorEvent) {
        let mut q = self.inner.lock().unwrap();
        if q.len() >= self.max_capacity {
            q.pop_front(); // drop oldest
        }
        q.push_back(event);
    }

    /// Drain all pending events (call from the host's render loop).
    pub fn drain(&self) -> Vec<EditorEvent> {
        let mut q = self.inner.lock().unwrap();
        q.drain(..).collect()
    }

    /// Drain all events as a JSON array string.
    pub fn drain_json(&self) -> String {
        let events = self.drain();
        serde_json::to_string(&events).unwrap_or_else(|_| "[]".into())
    }

    /// Peek — returns number of pending events without consuming them.
    pub fn len(&self) -> usize {
        self.inner.lock().unwrap().len()
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Clear all pending events.
    pub fn clear(&self) {
        self.inner.lock().unwrap().clear();
    }
}

impl Default for EventQueue {
    fn default() -> Self {
        Self::new(256)
    }
}

// ── Global event queue ─────────────────────────────────────────────────────────

use std::sync::OnceLock;

static GLOBAL_QUEUE: OnceLock<EventQueue> = OnceLock::new();

fn global_queue() -> &'static EventQueue {
    GLOBAL_QUEUE.get_or_init(EventQueue::default)
}

// ── C API ─────────────────────────────────────────────────────────────────────

use std::ffi::CString;
use std::os::raw::c_char;

/// Poll all pending events as a JSON array.
/// Returns a null-terminated UTF-8 JSON array string.
/// CALLER MUST call `editor_free_str` on the returned pointer.
///
/// JSON format:
/// [
///   {"type": "diagnostics_updated", "file_uri": "...", "count": 3, ...},
///   {"type": "completion_ready", "request_id": 42, "suggestion": "...", ...}
/// ]
#[no_mangle]
pub extern "C" fn editor_poll_events() -> *mut c_char {
    let json = global_queue().drain_json();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Returns the number of pending events (without consuming them).
#[no_mangle]
pub extern "C" fn editor_event_count() -> u32 {
    global_queue().len() as u32
}

/// Clear all pending events.
#[no_mangle]
pub extern "C" fn editor_clear_events() {
    global_queue().clear();
}

// ── Internal helpers for other modules ───────────────────────────────────────

/// Emit an event to the global queue. Called by LSP, AI, and syntax modules.
pub fn emit(event: EditorEvent) {
    global_queue().push(event);
}

pub fn emit_diagnostics_updated(file_uri: &str, error_count: usize, warning_count: usize) {
    emit(EditorEvent::DiagnosticsUpdated {
        file_uri: file_uri.to_owned(),
        count: error_count + warning_count,
        error_count,
        warning_count,
    });
}

pub fn emit_completion_ready(
    request_id: u64,
    suggestion: &str,
    insert_at: usize,
    is_multiline: bool,
) {
    emit(EditorEvent::CompletionReady {
        request_id,
        suggestion: suggestion.to_owned(),
        insert_at,
        is_multiline,
    });
}

pub fn emit_completion_cancelled(request_id: u64, reason: &str) {
    emit(EditorEvent::CompletionCancelled {
        request_id,
        reason: reason.to_owned(),
    });
}

pub fn emit_syntax_updated(first_line: usize, last_line: usize) {
    emit(EditorEvent::SyntaxUpdated {
        first_line,
        last_line,
    });
}

pub fn emit_progress(operation: &str, fraction: f32, message: Option<&str>) {
    emit(EditorEvent::Progress {
        operation: operation.to_owned(),
        fraction,
        message: message.map(|m| m.to_owned()),
    });
}

pub fn emit_background_error(operation: &str, message: &str) {
    emit(EditorEvent::BackgroundError {
        operation: operation.to_owned(),
        message: message.to_owned(),
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_push_and_drain() {
        let q = EventQueue::new(10);
        q.push(EditorEvent::SyntaxUpdated {
            first_line: 0,
            last_line: 5,
        });
        q.push(EditorEvent::DiagnosticsUpdated {
            file_uri: "file:///test.rs".into(),
            count: 2,
            error_count: 1,
            warning_count: 1,
        });
        assert_eq!(q.len(), 2);
        let drained = q.drain();
        assert_eq!(drained.len(), 2);
        assert_eq!(q.len(), 0);
    }

    #[test]
    fn test_capacity_drops_oldest() {
        let q = EventQueue::new(3);
        for i in 0..5 {
            q.push(EditorEvent::SyntaxUpdated {
                first_line: i,
                last_line: i,
            });
        }
        assert_eq!(q.len(), 3);
        let events = q.drain();
        // Should have the last 3 events (oldest dropped)
        let first_lines: Vec<usize> = events
            .iter()
            .filter_map(|e| {
                if let EditorEvent::SyntaxUpdated { first_line, .. } = e {
                    Some(*first_line)
                } else {
                    None
                }
            })
            .collect();
        assert_eq!(first_lines, vec![2, 3, 4]);
    }

    #[test]
    fn test_drain_json_valid() {
        let q = EventQueue::new(10);
        q.push(EditorEvent::CompletionReady {
            request_id: 42,
            suggestion: "let x = 1;".into(),
            insert_at: 100,
            is_multiline: false,
        });
        let json = q.drain_json();
        let parsed: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(parsed.is_array());
        assert_eq!(parsed[0]["type"], "completion_ready");
        assert_eq!(parsed[0]["request_id"], 42);
    }

    #[test]
    fn test_drain_json_empty() {
        let q = EventQueue::new(10);
        assert_eq!(q.drain_json(), "[]");
    }

    #[test]
    fn test_clear() {
        let q = EventQueue::new(10);
        q.push(EditorEvent::SyntaxUpdated {
            first_line: 0,
            last_line: 1,
        });
        assert_eq!(q.len(), 1);
        q.clear();
        assert_eq!(q.len(), 0);
    }

    #[test]
    fn test_event_serialisation_types() {
        let events = vec![
            EditorEvent::DiagnosticsUpdated {
                file_uri: "f".into(),
                count: 1,
                error_count: 1,
                warning_count: 0,
            },
            EditorEvent::Progress {
                operation: "indexing".into(),
                fraction: 0.5,
                message: Some("halfway".into()),
            },
            EditorEvent::BackgroundError {
                operation: "lsp".into(),
                message: "server crashed".into(),
            },
        ];
        let json = serde_json::to_string(&events).unwrap();
        let parsed: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(parsed[0]["type"], "diagnostics_updated");
        assert_eq!(parsed[1]["type"], "progress");
        assert_eq!(parsed[2]["type"], "background_error");
    }

    #[test]
    fn test_c_api_poll_events() {
        // Push through global queue
        global_queue().clear();
        global_queue().push(EditorEvent::SyntaxUpdated {
            first_line: 0,
            last_line: 10,
        });
        assert_eq!(editor_event_count(), 1);

        let ptr = editor_poll_events();
        assert!(!ptr.is_null());
        let json = unsafe { std::ffi::CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        super::super::c_api::editor_free_str(ptr);

        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v[0]["type"], "syntax_updated");
        assert_eq!(editor_event_count(), 0);
    }
}
