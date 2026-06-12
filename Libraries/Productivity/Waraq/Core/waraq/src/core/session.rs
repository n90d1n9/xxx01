// src/core/session.rs
//
// Session persistence — save and restore complete editor state to/from JSON.
//
// Saved state includes:
//   • Document content (UTF-8)
//   • Cursor positions
//   • Selection anchors
//   • Viewport (scroll offset, height)
//   • Fold states (collapsed/expanded)
//   • Search query (if active)
//   • Config (tab width, indent style, etc.)
//   • Language
//   • File URI
//   • Undo history depth (not the ops themselves — too large)
//
// Design: sessions are intentionally serialisable to a compact JSON object
// so they can be stored in SharedPreferences (Flutter), localStorage (WASM),
// or a database (Java backend).

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::core::config::Config;
use crate::core::types::ByteOffset;

// ── Snapshot types ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CursorSnapshot {
    pub pos: usize,
    pub anchor: Option<usize>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ViewportSnapshot {
    pub scroll_offset: usize,
    pub height: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldSnapshot {
    pub start_line: usize,
    pub end_line: usize,
    pub collapsed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SearchSnapshot {
    pub pattern: String,
    pub case_sensitive: bool,
    pub whole_word: bool,
    pub regex: bool,
}

/// Complete editor session — everything needed to restore a tab exactly.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    /// Schema version for forward-compatibility.
    pub version: u32,
    pub file_uri: String,
    pub language: String,
    /// The document text. For large files, callers may omit this and only
    /// restore cursor/viewport (file content comes from the filesystem).
    pub content: Option<String>,
    pub cursors: Vec<CursorSnapshot>,
    pub viewport: ViewportSnapshot,
    pub folds: Vec<FoldSnapshot>,
    pub search: Option<SearchSnapshot>,
    pub config: Config,
    /// Timestamp (Unix ms) when the session was last saved.
    pub saved_at: u64,
    /// Arbitrary caller-defined metadata (e.g. tab title, git branch).
    pub metadata: HashMap<String, serde_json::Value>,
}

impl Session {
    pub const CURRENT_VERSION: u32 = 1;

    pub fn new(file_uri: &str, language: &str) -> Self {
        Self {
            version: Self::CURRENT_VERSION,
            file_uri: file_uri.to_owned(),
            language: language.to_owned(),
            content: None,
            cursors: vec![CursorSnapshot {
                pos: 0,
                anchor: None,
            }],
            viewport: ViewportSnapshot {
                scroll_offset: 0,
                height: 50,
            },
            folds: Vec::new(),
            search: None,
            config: Config::default(),
            saved_at: 0,
            metadata: HashMap::new(),
        }
    }

    // ── Serialisation ─────────────────────────────────────────────────────────

    pub fn to_json(&self) -> String {
        serde_json::to_string(self).unwrap_or_default()
    }

    pub fn to_json_pretty(&self) -> String {
        serde_json::to_string_pretty(self).unwrap_or_default()
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        let mut s: Session = serde_json::from_str(json)?;
        // Migrate older versions
        if s.version < Self::CURRENT_VERSION {
            s = Self::migrate(s)?;
        }
        Ok(s)
    }

    fn migrate(s: Session) -> anyhow::Result<Session> {
        // v0 → v1: add missing fields with defaults
        Ok(Session {
            version: Self::CURRENT_VERSION,
            ..s
        })
    }

    // ── Convenience ───────────────────────────────────────────────────────────

    pub fn with_content(mut self, content: String) -> Self {
        self.content = Some(content);
        self
    }

    pub fn with_metadata(mut self, key: &str, value: serde_json::Value) -> Self {
        self.metadata.insert(key.to_owned(), value);
        self
    }

    pub fn is_untitled(&self) -> bool {
        self.file_uri.is_empty() || self.file_uri.starts_with("untitled://")
    }

    pub fn primary_cursor_pos(&self) -> usize {
        self.cursors.first().map(|c| c.pos).unwrap_or(0)
    }
}

// ── Session builder from live Editor ─────────────────────────────────────────

/// Capture the current state of an `Editor` into a `Session`.
pub fn capture(editor: &crate::Editor) -> Session {
    let now_ms = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0);

    let cursors = editor
        .cursors
        .all()
        .iter()
        .map(|c| CursorSnapshot {
            pos: c.pos.0,
            anchor: c.anchor.map(|a| a.0),
        })
        .collect();

    let folds = editor
        .folds
        .all()
        .iter()
        .filter(|f| f.is_valid())
        .map(|f| FoldSnapshot {
            start_line: f.start_line,
            end_line: f.end_line,
            collapsed: f.collapsed,
        })
        .collect();

    let search = editor.search.as_ref().map(|s| {
        let q = s.query();
        SearchSnapshot {
            pattern: q.pattern.clone(),
            case_sensitive: q.case_sensitive,
            whole_word: q.whole_word,
            regex: q.regex,
        }
    });

    Session {
        version: Session::CURRENT_VERSION,
        file_uri: editor.file_uri.clone(),
        language: editor.language.clone(),
        content: Some(editor.buffer.to_string()),
        cursors,
        viewport: ViewportSnapshot {
            scroll_offset: editor.viewport.scroll_offset(),
            height: editor.viewport.height(),
        },
        folds,
        search,
        config: editor.config.clone(),
        saved_at: now_ms,
        metadata: HashMap::new(),
    }
}

/// Restore a `Session` into an `Editor`.
/// Returns the restored `Editor`.
pub fn restore(session: &Session) -> crate::Editor {
    use crate::core::search::SearchQuery;
    use crate::Editor;

    let content = session.content.as_deref().unwrap_or("");
    let mut ed = Editor::from_str(content);

    ed.file_uri = session.file_uri.clone();
    ed.config = session.config.clone();
    ed.viewport.set_height(session.viewport.height);
    ed.viewport
        .scroll_to_line(session.viewport.scroll_offset, ed.buffer.len_lines());

    if !session.language.is_empty() {
        ed.set_language(&session.language);
    }

    // Restore cursors
    if !session.cursors.is_empty() {
        let buf_len = ed.buffer.len_bytes();
        let positions: Vec<usize> = session.cursors.iter().map(|c| c.pos.min(buf_len)).collect();
        if positions.len() == 1 {
            ed.cursors.move_to(positions[0], false);
        } else {
            ed.cursors.set_all(positions.clone());
        }
        // Restore selection anchors
        for (i, snap) in session.cursors.iter().enumerate() {
            if let Some(anchor) = snap.anchor {
                if let Some(cursor) = ed.cursors.all_mut().get_mut(i) {
                    cursor.anchor = Some(ByteOffset(anchor.min(buf_len)));
                }
            }
        }
    }

    // Restore fold states
    for fold_snap in &session.folds {
        if fold_snap.collapsed {
            ed.folds.toggle(fold_snap.start_line);
        }
    }

    // Restore search
    if let Some(search_snap) = &session.search {
        let query = SearchQuery {
            pattern: search_snap.pattern.clone(),
            case_sensitive: search_snap.case_sensitive,
            whole_word: search_snap.whole_word,
            regex: search_snap.regex,
            wrap_around: true,
        };
        ed.search_start(query);
    }

    ed
}

// ── Session store ─────────────────────────────────────────────────────────────

/// A simple in-memory store of multiple sessions (one per open tab).
#[derive(Debug, Default)]
pub struct SessionStore {
    sessions: Vec<Session>,
    active: usize,
}

impl SessionStore {
    pub fn new() -> Self {
        Self::default()
    }

    /// Add or update a session. Uses `file_uri` as the key.
    pub fn upsert(&mut self, session: Session) {
        if let Some(i) = self
            .sessions
            .iter()
            .position(|s| s.file_uri == session.file_uri)
        {
            self.sessions[i] = session;
        } else {
            self.sessions.push(session);
        }
    }

    pub fn get(&self, file_uri: &str) -> Option<&Session> {
        self.sessions.iter().find(|s| s.file_uri == file_uri)
    }

    pub fn remove(&mut self, file_uri: &str) {
        self.sessions.retain(|s| s.file_uri != file_uri);
        self.active = self.active.min(self.sessions.len().saturating_sub(1));
    }

    pub fn active(&self) -> Option<&Session> {
        self.sessions.get(self.active)
    }

    pub fn set_active(&mut self, file_uri: &str) {
        if let Some(i) = self.sessions.iter().position(|s| s.file_uri == file_uri) {
            self.active = i;
        }
    }

    pub fn all(&self) -> &[Session] {
        &self.sessions
    }
    pub fn len(&self) -> usize {
        self.sessions.len()
    }
    pub fn is_empty(&self) -> bool {
        self.sessions.is_empty()
    }

    /// Serialise all sessions to a JSON array.
    pub fn to_json(&self) -> String {
        serde_json::to_string(&self.sessions).unwrap_or_else(|_| "[]".into())
    }

    /// Restore sessions from a JSON array.
    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        let sessions: Vec<Session> = serde_json::from_str(json)?;
        Ok(Self {
            sessions,
            active: 0,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Editor;

    #[test]
    fn test_capture_and_restore_basic() {
        let mut ed = Editor::from_str("hello world\nline two\n");
        ed.set_language("rust");
        ed.file_uri = "file:///test.rs".into();
        ed.cursors.move_to(5, false);
        ed.viewport.set_height(30);

        let session = capture(&ed);
        assert_eq!(session.language, "rust");
        assert_eq!(session.file_uri, "file:///test.rs");
        assert_eq!(session.primary_cursor_pos(), 5);
        assert_eq!(session.viewport.height, 30);
        assert!(session.content.as_ref().unwrap().contains("hello world"));
    }

    #[test]
    fn test_restore_cursor_position() {
        let mut ed = Editor::from_str("abcdefghij");
        ed.cursors.move_to(7, false);
        let session = capture(&ed);

        let restored = restore(&session);
        assert_eq!(restored.cursors.primary().pos.0, 7);
    }

    #[test]
    fn test_restore_viewport_scroll() {
        let content: String = (0..100).map(|i| format!("line {}\n", i)).collect();
        let mut ed = Editor::from_str(&content);
        ed.viewport.set_height(20);
        ed.viewport.scroll_to_line(50, 100);
        let session = capture(&ed);

        let restored = restore(&session);
        assert_eq!(restored.viewport.scroll_offset(), 50);
    }

    #[test]
    fn test_json_roundtrip() {
        let mut ed = Editor::from_str("fn main() { let x = 1; }");
        ed.set_language("rust");
        let session = capture(&ed);
        let json = session.to_json();

        let restored_session = Session::from_json(&json).unwrap();
        assert_eq!(restored_session.language, "rust");
        assert_eq!(restored_session.content, session.content);
    }

    #[test]
    fn test_session_store_upsert_and_get() {
        let mut store = SessionStore::new();

        let s1 = Session::new("file:///a.rs", "rust");
        let s2 = Session::new("file:///b.py", "python");
        store.upsert(s1);
        store.upsert(s2);
        assert_eq!(store.len(), 2);

        // Update existing
        let s1_updated = Session::new("file:///a.rs", "rust");
        store.upsert(s1_updated);
        assert_eq!(store.len(), 2); // still 2

        assert!(store.get("file:///a.rs").is_some());
        assert!(store.get("file:///nonexistent").is_none());
    }

    #[test]
    fn test_session_store_remove() {
        let mut store = SessionStore::new();
        store.upsert(Session::new("file:///a.rs", "rust"));
        store.upsert(Session::new("file:///b.py", "python"));
        store.remove("file:///a.rs");
        assert_eq!(store.len(), 1);
        assert!(store.get("file:///a.rs").is_none());
    }

    #[test]
    fn test_session_store_json_roundtrip() {
        let mut store = SessionStore::new();
        store.upsert(Session::new("file:///a.rs", "rust").with_content("fn main(){}".into()));
        store.upsert(Session::new("file:///b.py", "python").with_content("print('hi')".into()));
        let json = store.to_json();

        let restored = SessionStore::from_json(&json).unwrap();
        assert_eq!(restored.len(), 2);
        assert_eq!(restored.get("file:///a.rs").unwrap().language, "rust");
    }

    #[test]
    fn test_restore_search_state() {
        let mut ed = Editor::from_str("foo bar foo baz");
        ed.search_start(crate::core::search::SearchQuery::literal("foo"));
        let session = capture(&ed);
        assert!(session.search.is_some());
        assert_eq!(session.search.as_ref().unwrap().pattern, "foo");

        let restored = restore(&session);
        assert!(restored.search.is_some());
        assert_eq!(restored.search.as_ref().unwrap().match_count(), 2);
    }

    #[test]
    fn test_session_is_untitled() {
        let s = Session::new("", "");
        assert!(s.is_untitled());
        let s2 = Session::new("file:///real.rs", "rust");
        assert!(!s2.is_untitled());
    }

    #[test]
    fn test_capture_with_selection() {
        let mut ed = Editor::from_str("hello world");
        ed.cursors.move_to(0, false);
        ed.cursors.move_to(5, true); // select "hello"
        let session = capture(&ed);
        assert!(session.cursors[0].anchor.is_some());
        assert_eq!(session.cursors[0].anchor.unwrap(), 0);
        assert_eq!(session.cursors[0].pos, 5);
    }
}
