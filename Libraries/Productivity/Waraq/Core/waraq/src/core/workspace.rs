// src/core/workspace.rs
//
// Workspace — manages multiple open editors (tabs).
//
// Responsibilities:
//   • Open / close / switch between files
//   • Persist and restore the full workspace (all sessions + active tab)
//   • Broadcast language-server lifecycle (one server per language, shared)
//   • Provide a project-wide find-in-files interface
//   • Track modified (dirty) files
//
// Each file is represented by an `EditorHandle` — a thin wrapper that owns
// an `Editor` plus metadata.  The workspace owns all handles.

use serde::Serialize;

use crate::core::search::SearchQuery;
use crate::core::session::{capture, restore, SessionStore};
use crate::Editor;

// ── EditorHandle ──────────────────────────────────────────────────────────────

/// An open file in the workspace.
pub struct EditorHandle {
    pub editor: Editor,
    pub file_uri: String,
    pub language: String,
    /// True if the buffer differs from what's on disk.
    pub dirty: bool,
    /// True if this file is new and has never been saved.
    pub is_new: bool,
    /// Unique tab ID (monotonically increasing).
    pub tab_id: usize,
}

impl EditorHandle {
    fn new(tab_id: usize, file_uri: &str, language: &str, content: &str) -> Self {
        let mut editor = Editor::from_str(content);
        editor.set_language(language);
        editor.file_uri = file_uri.to_owned();
        Self {
            editor,
            file_uri: file_uri.to_owned(),
            language: language.to_owned(),
            dirty: false,
            is_new: file_uri.is_empty(),
            tab_id,
        }
    }
}

// ── Find-in-files result ──────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize)]
pub struct FileMatch {
    pub file_uri: String,
    pub line: usize,
    pub col_start: usize,
    pub col_end: usize,
    pub line_text: String,
    pub byte_start: usize,
    pub byte_end: usize,
}

#[derive(Debug, Clone, Serialize)]
pub struct FindInFilesResult {
    pub query: String,
    pub total_matches: usize,
    pub files_matched: usize,
    pub matches: Vec<FileMatch>,
}

// ── Workspace ─────────────────────────────────────────────────────────────────

pub struct Workspace {
    handles: Vec<EditorHandle>,
    active: usize,
    next_tab_id: usize,
    /// Project root URI (e.g. "file:///home/user/my-project").
    pub root_uri: String,
}

impl Workspace {
    pub fn new(root_uri: &str) -> Self {
        Self {
            handles: Vec::new(),
            active: 0,
            next_tab_id: 0,
            root_uri: root_uri.to_owned(),
        }
    }

    // ── Tab management ────────────────────────────────────────────────────────

    /// Open a new file or create an untitled tab.
    /// Returns the tab_id of the newly opened file.
    pub fn open(&mut self, file_uri: &str, language: &str, content: &str) -> usize {
        // Check if already open
        if let Some(i) = self
            .handles
            .iter()
            .position(|h| h.file_uri == file_uri && !file_uri.is_empty())
        {
            self.active = i;
            return self.handles[i].tab_id;
        }
        let tab_id = self.next_tab_id;
        self.next_tab_id += 1;
        self.handles
            .push(EditorHandle::new(tab_id, file_uri, language, content));
        self.active = self.handles.len() - 1;
        tab_id
    }

    /// Open a new untitled buffer.
    pub fn open_untitled(&mut self, language: &str) -> usize {
        let uri = format!("untitled://{}", self.next_tab_id);
        self.open(&uri, language, "")
    }

    /// Close the tab with the given tab_id.
    /// Returns (true, dirty) — dirty=true means unsaved changes were discarded.
    pub fn close(&mut self, tab_id: usize) -> (bool, bool) {
        if let Some(i) = self.handles.iter().position(|h| h.tab_id == tab_id) {
            let dirty = self.handles[i].dirty;
            self.handles.remove(i);
            if self.active >= self.handles.len() && !self.handles.is_empty() {
                self.active = self.handles.len() - 1;
            }
            (true, dirty)
        } else {
            (false, false)
        }
    }

    /// Switch the active tab to the given tab_id.
    pub fn switch_to(&mut self, tab_id: usize) -> bool {
        if let Some(i) = self.handles.iter().position(|h| h.tab_id == tab_id) {
            self.active = i;
            true
        } else {
            false
        }
    }

    /// Switch to the next tab (wraps around).
    pub fn next_tab(&mut self) {
        if self.handles.is_empty() {
            return;
        }
        self.active = (self.active + 1) % self.handles.len();
    }

    /// Switch to the previous tab (wraps around).
    pub fn prev_tab(&mut self) {
        if self.handles.is_empty() {
            return;
        }
        self.active = if self.active == 0 {
            self.handles.len() - 1
        } else {
            self.active - 1
        };
    }

    // ── Active editor access ──────────────────────────────────────────────────

    pub fn active_editor(&self) -> Option<&Editor> {
        self.handles.get(self.active).map(|h| &h.editor)
    }

    pub fn active_editor_mut(&mut self) -> Option<&mut Editor> {
        self.handles.get_mut(self.active).map(|h| &mut h.editor)
    }

    pub fn active_tab_id(&self) -> Option<usize> {
        self.handles.get(self.active).map(|h| h.tab_id)
    }

    pub fn active_file_uri(&self) -> Option<&str> {
        self.handles.get(self.active).map(|h| h.file_uri.as_str())
    }

    /// Get an editor by tab_id.
    pub fn editor_for(&self, tab_id: usize) -> Option<&Editor> {
        self.handles
            .iter()
            .find(|h| h.tab_id == tab_id)
            .map(|h| &h.editor)
    }

    pub fn editor_for_mut(&mut self, tab_id: usize) -> Option<&mut Editor> {
        self.handles
            .iter_mut()
            .find(|h| h.tab_id == tab_id)
            .map(|h| &mut h.editor)
    }

    // ── Metadata ──────────────────────────────────────────────────────────────

    pub fn tab_count(&self) -> usize {
        self.handles.len()
    }
    pub fn is_empty(&self) -> bool {
        self.handles.is_empty()
    }

    pub fn dirty_count(&self) -> usize {
        self.handles.iter().filter(|h| h.dirty).count()
    }

    pub fn dirty_files(&self) -> Vec<&str> {
        self.handles
            .iter()
            .filter(|h| h.dirty)
            .map(|h| h.file_uri.as_str())
            .collect()
    }

    /// Mark the active file as dirty (modified since last save).
    pub fn mark_dirty(&mut self) {
        if let Some(h) = self.handles.get_mut(self.active) {
            h.dirty = true;
        }
    }

    /// Mark a file as clean (just saved to disk).
    pub fn mark_clean(&mut self, tab_id: usize) {
        if let Some(h) = self.handles.iter_mut().find(|h| h.tab_id == tab_id) {
            h.dirty = false;
        }
    }

    pub fn tab_list(&self) -> Vec<TabInfo> {
        self.handles
            .iter()
            .map(|h| TabInfo {
                tab_id: h.tab_id,
                file_uri: h.file_uri.clone(),
                language: h.language.clone(),
                dirty: h.dirty,
                is_new: h.is_new,
                is_active: self
                    .handles
                    .get(self.active)
                    .map(|a| a.tab_id == h.tab_id)
                    .unwrap_or(false),
            })
            .collect()
    }

    // ── Find in files ─────────────────────────────────────────────────────────

    /// Search all open files for `pattern`.
    pub fn find_in_files(&self, query: &SearchQuery) -> FindInFilesResult {
        let mut all_matches: Vec<FileMatch> = Vec::new();
        let mut files_matched = 0usize;

        for handle in &self.handles {
            let buf = &handle.editor.buffer;
            let file_matches: Vec<FileMatch> = buf
                .find_all(&query.pattern)
                .iter()
                .map(|&start| {
                    let lc = buf.offset_to_line_col(start);
                    let end_offset = crate::ByteOffset(start.0 + query.pattern.len());
                    let end_lc = buf.offset_to_line_col(end_offset);
                    FileMatch {
                        file_uri: handle.file_uri.clone(),
                        line: lc.line,
                        col_start: lc.col,
                        col_end: end_lc.col,
                        line_text: buf.line_str(lc.line),
                        byte_start: start.0,
                        byte_end: start.0 + query.pattern.len(),
                    }
                })
                .collect();

            if !file_matches.is_empty() {
                files_matched += 1;
                all_matches.extend(file_matches);
            }
        }

        let total = all_matches.len();
        FindInFilesResult {
            query: query.pattern.clone(),
            total_matches: total,
            files_matched,
            matches: all_matches,
        }
    }

    /// Replace all matches of `query` with `replacement` across all open files.
    /// Returns total replacements made.
    pub fn replace_in_files(&mut self, query: &SearchQuery, replacement: &str) -> usize {
        let mut total = 0usize;
        for handle in &mut self.handles {
            let ops = crate::search_replace_all(&handle.editor.buffer, query, replacement);
            let n = ops.len();
            if n > 0 {
                handle.editor.apply_batch(ops);
                handle.dirty = true;
                total += n;
            }
        }
        total
    }

    // ── Session persistence ───────────────────────────────────────────────────

    /// Capture all open editors into a `SessionStore`.
    pub fn save_sessions(&self) -> SessionStore {
        let mut store = SessionStore::new();
        for handle in &self.handles {
            let session = capture(&handle.editor);
            store.upsert(session);
        }
        if let Some(uri) = self.active_file_uri() {
            store.set_active(uri);
        }
        store
    }

    /// Restore workspace from a `SessionStore`.
    pub fn load_sessions(&mut self, store: &SessionStore) {
        for session in store.all() {
            if let Some(content) = &session.content {
                let tab_id = self.open(&session.file_uri, &session.language, content);
                if let Some(h) = self.handles.iter_mut().find(|h| h.tab_id == tab_id) {
                    h.editor = restore(session);
                }
            }
        }
        // Restore active tab
        if let Some(active) = store.active() {
            self.switch_to_uri(&active.file_uri);
        }
    }

    fn switch_to_uri(&mut self, file_uri: &str) {
        if let Some(i) = self.handles.iter().position(|h| h.file_uri == file_uri) {
            self.active = i;
        }
    }
}

/// Lightweight tab descriptor for rendering the tab bar.
#[derive(Debug, Clone, Serialize)]
pub struct TabInfo {
    pub tab_id: usize,
    pub file_uri: String,
    pub language: String,
    pub dirty: bool,
    pub is_new: bool,
    pub is_active: bool,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::search::SearchQuery;

    fn ws() -> Workspace {
        Workspace::new("file:///project")
    }

    #[test]
    fn test_open_and_switch() {
        let mut w = ws();
        let id1 = w.open("file:///a.rs", "rust", "fn main() {}");
        let id2 = w.open("file:///b.rs", "rust", "fn foo() {}");
        assert_eq!(w.tab_count(), 2);
        assert_eq!(w.active_tab_id(), Some(id2));
        w.switch_to(id1);
        assert_eq!(w.active_tab_id(), Some(id1));
        assert_eq!(w.active_file_uri(), Some("file:///a.rs"));
    }

    #[test]
    fn test_open_same_file_twice() {
        let mut w = ws();
        let id1 = w.open("file:///a.rs", "rust", "hello");
        let id2 = w.open("file:///a.rs", "rust", "hello");
        assert_eq!(id1, id2);
        assert_eq!(w.tab_count(), 1);
    }

    #[test]
    fn test_close_tab() {
        let mut w = ws();
        let id = w.open("file:///a.rs", "rust", "fn main() {}");
        let (ok, dirty) = w.close(id);
        assert!(ok);
        assert!(!dirty);
        assert_eq!(w.tab_count(), 0);
    }

    #[test]
    fn test_close_nonexistent() {
        let mut w = ws();
        let (ok, _) = w.close(999);
        assert!(!ok);
    }

    #[test]
    fn test_next_prev_tab() {
        let mut w = ws();
        w.open("file:///a.rs", "rust", "");
        w.open("file:///b.rs", "rust", "");
        w.open("file:///c.rs", "rust", "");
        w.switch_to(0); // go to first
        w.next_tab();
        w.next_tab();
        assert_eq!(w.active_file_uri(), Some("file:///c.rs"));
        w.next_tab(); // wraps to first
        assert_eq!(w.active_file_uri(), Some("file:///a.rs"));
    }

    #[test]
    fn test_dirty_tracking() {
        let mut w = ws();
        let id = w.open("file:///a.rs", "rust", "fn main() {}");
        assert_eq!(w.dirty_count(), 0);
        w.mark_dirty();
        assert_eq!(w.dirty_count(), 1);
        w.mark_clean(id);
        assert_eq!(w.dirty_count(), 0);
    }

    #[test]
    fn test_find_in_files() {
        let mut w = ws();
        w.open("file:///a.rs", "rust", "foo bar foo");
        w.open("file:///b.rs", "rust", "baz qux foo");
        let q = SearchQuery::literal("foo");
        let result = w.find_in_files(&q);
        assert_eq!(result.total_matches, 3);
        assert_eq!(result.files_matched, 2);
    }

    #[test]
    fn test_find_in_files_no_match() {
        let mut w = ws();
        w.open("file:///a.rs", "rust", "hello world");
        let q = SearchQuery::literal("xyz");
        let result = w.find_in_files(&q);
        assert_eq!(result.total_matches, 0);
        assert_eq!(result.files_matched, 0);
    }

    #[test]
    fn test_replace_in_files() {
        let mut w = ws();
        w.open("file:///a.rs", "rust", "foo bar foo");
        w.open("file:///b.rs", "rust", "foo baz");
        let q = SearchQuery::literal("foo");
        let n = w.replace_in_files(&q, "qux");
        assert_eq!(n, 3);
    }

    #[test]
    fn test_tab_list() {
        let mut w = ws();
        let id1 = w.open("file:///a.rs", "rust", "");
        w.open("file:///b.py", "python", "");
        w.switch_to(id1);
        let tabs = w.tab_list();
        assert_eq!(tabs.len(), 2);
        assert!(tabs
            .iter()
            .any(|t| t.is_active && t.file_uri == "file:///a.rs"));
    }

    #[test]
    fn test_session_roundtrip() {
        let mut w = ws();
        w.open("file:///a.rs", "rust", "fn main() { let x = 1; }");
        w.open("file:///b.py", "python", "print('hello')");
        if let Some(ed) = w.active_editor_mut() {
            ed.cursors.move_to(5, false);
        }

        let store = w.save_sessions();
        let json = store.to_json();

        let mut w2 = ws();
        let store2 = crate::core::session::SessionStore::from_json(&json).unwrap();
        w2.load_sessions(&store2);

        assert_eq!(w2.tab_count(), 2);
    }

    #[test]
    fn test_open_untitled() {
        let mut w = ws();
        let _id = w.open_untitled("rust");
        assert_eq!(w.tab_count(), 1);
        let info = &w.tab_list()[0];
        assert!(info.file_uri.starts_with("untitled://"));
    }

    #[test]
    fn test_editor_for() {
        let mut w = ws();
        let id = w.open("file:///a.rs", "rust", "hello");
        let ed = w.editor_for(id).unwrap();
        assert_eq!(ed.buffer.to_string(), "hello");
    }
}
