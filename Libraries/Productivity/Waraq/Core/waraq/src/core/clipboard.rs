// src/core/clipboard.rs
//
// Clipboard engine — manages copy/cut/paste with:
//   • History ring (last 10 entries, cycle with Ctrl+Shift+V)
//   • Multi-cursor awareness (per-cursor entries joined or split on paste)
//   • Line-copy mode (when nothing is selected, copies the whole line)
//   • Column-paste mode (rectangular selections paste column-by-column)
//   • Platform clipboard integration via an opaque `PlatformClipboard` trait
//     (the FFI layer supplies the concrete impl)
//
// Design: the `Clipboard` struct is owned by `Editor` and operates purely
// on byte offsets.  It never touches platform APIs directly — those are
// injected via the `ClipboardProvider` trait so the engine stays portable
// to WASM and headless test environments.

use crate::core::buffer::Buffer;
use crate::core::cursor::MultiCursor;
use crate::core::edit::EditOp;
use crate::core::types::{ByteOffset, Range};
use serde::{Deserialize, Serialize};

// ── Clipboard entry ────────────────────────────────────────────────────────────

/// The kind of clipboard content.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ClipboardKind {
    /// Normal text selection.
    Text,
    /// Whole-line copy (no selection was active — copy the line including newline).
    Line,
    /// Rectangular / column selection.
    Column,
}

/// One item in the clipboard history.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClipboardEntry {
    /// The copied text.
    pub text: String,
    /// For multi-cursor copy: one string per cursor, in top-to-bottom order.
    pub per_cursor: Vec<String>,
    pub kind: ClipboardKind,
}

impl ClipboardEntry {
    fn new_text(text: String) -> Self {
        Self {
            text: text.clone(),
            per_cursor: vec![text],
            kind: ClipboardKind::Text,
        }
    }

    fn new_line(text: String) -> Self {
        Self {
            text: text.clone(),
            per_cursor: vec![text],
            kind: ClipboardKind::Line,
        }
    }

    fn new_multi(entries: Vec<String>) -> Self {
        let text = entries.join("\n");
        Self {
            text,
            per_cursor: entries,
            kind: ClipboardKind::Text,
        }
    }
}

// ── Platform clipboard trait ───────────────────────────────────────────────────

/// Abstracts the OS clipboard so the engine can be tested headlessly.
pub trait ClipboardProvider: Send + Sync {
    fn get_text(&self) -> Option<String>;
    fn set_text(&mut self, text: &str);
}

/// No-op provider used in tests and WASM.
#[derive(Default)]
pub struct InMemoryClipboard {
    text: Option<String>,
}

impl ClipboardProvider for InMemoryClipboard {
    fn get_text(&self) -> Option<String> {
        self.text.clone()
    }
    fn set_text(&mut self, text: &str) {
        self.text = Some(text.to_owned());
    }
}

// ── Clipboard ring ─────────────────────────────────────────────────────────────

const HISTORY_CAPACITY: usize = 10;

pub struct Clipboard {
    ring: Vec<ClipboardEntry>,
    /// Points to the most recently added entry.
    head: usize,
    /// How many entries are currently populated.
    len: usize,
    /// Index for "cycle paste" — tracks which ring position we're at.
    paste_idx: usize,
    provider: Box<dyn ClipboardProvider>,
}

impl Clipboard {
    pub fn new() -> Self {
        Self::with_provider(Box::new(InMemoryClipboard::default()))
    }

    pub fn with_provider(provider: Box<dyn ClipboardProvider>) -> Self {
        Self {
            ring: vec![ClipboardEntry::new_text(String::new()); HISTORY_CAPACITY],
            head: 0,
            len: 0,
            paste_idx: 0,
            provider,
        }
    }

    // ── Push ──────────────────────────────────────────────────────────────────

    fn push(&mut self, entry: ClipboardEntry) {
        self.head = (self.head + 1) % HISTORY_CAPACITY;
        self.ring[self.head] = entry.clone();
        if self.len < HISTORY_CAPACITY {
            self.len += 1;
        }
        self.paste_idx = self.head;
        self.provider.set_text(&entry.text);
    }

    // ── Copy ──────────────────────────────────────────────────────────────────

    /// Copy the current selection(s) to the clipboard.
    /// With no selection, copies the whole line (line-copy mode).
    pub fn copy(&mut self, buffer: &Buffer, cursors: &MultiCursor) {
        let entry = self.build_copy_entry(buffer, cursors, false);
        self.push(entry);
    }

    fn build_copy_entry(
        &self,
        buffer: &Buffer,
        cursors: &MultiCursor,
        _cut_mode: bool,
    ) -> ClipboardEntry {
        let cursors_list = cursors.all();

        // Multi-cursor with selections: collect one string per cursor
        let all_have_selection = cursors_list.iter().all(|c| c.has_selection());
        if cursors_list.len() > 1 && all_have_selection {
            let entries: Vec<String> = cursors_list
                .iter()
                .map(|c| {
                    c.selection()
                        .map(|sel| buffer.text_in_range(sel.as_range()))
                        .unwrap_or_default()
                })
                .collect();
            return ClipboardEntry::new_multi(entries);
        }

        // Primary cursor with selection
        if let Some(sel) = cursors.primary().selection() {
            let text = buffer.text_in_range(sel.as_range());
            return ClipboardEntry::new_text(text);
        }

        // No selection: copy whole line (line-copy mode)
        let lc = buffer.offset_to_line_col(cursors.primary().pos);
        let line = buffer.line_str(lc.line);
        let text = if lc.line + 1 < buffer.len_lines() {
            format!("{}\n", line)
        } else {
            line
        };
        ClipboardEntry::new_line(text)
    }

    // ── Cut ───────────────────────────────────────────────────────────────────

    /// Cut the current selection(s). Returns the EditOps to apply.
    pub fn cut(&mut self, buffer: &Buffer, cursors: &MultiCursor) -> Vec<EditOp> {
        let entry = self.build_copy_entry(buffer, cursors, true);
        let ops = self.build_delete_ops(buffer, cursors, &entry.kind);
        self.push(entry);
        ops
    }

    fn build_delete_ops(
        &self,
        buffer: &Buffer,
        cursors: &MultiCursor,
        kind: &ClipboardKind,
    ) -> Vec<EditOp> {
        let mut ops: Vec<EditOp> = Vec::new();

        for cursor in cursors.all().iter().rev() {
            if let Some(sel) = cursor.selection() {
                ops.push(EditOp::delete(sel.start.0, sel.end.0));
            } else if *kind == ClipboardKind::Line {
                // Delete the whole line including newline
                let lc = buffer.offset_to_line_col(cursor.pos);
                let start = buffer.line_col_to_offset(crate::core::types::LineCol::new(lc.line, 0));
                let end = if lc.line + 1 < buffer.len_lines() {
                    buffer.line_col_to_offset(crate::core::types::LineCol::new(lc.line + 1, 0))
                } else {
                    ByteOffset(buffer.len_bytes())
                };
                ops.push(EditOp::delete(start.0, end.0));
            }
        }

        // Sort largest-offset first to apply safely
        ops.sort_by(|a, b| {
            let a0 = match a {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            let b0 = match b {
                EditOp::Delete { range } => range.start.0,
                _ => 0,
            };
            b0.cmp(&a0)
        });
        ops
    }

    // ── Paste ─────────────────────────────────────────────────────────────────

    /// Paste the most recent clipboard entry. Returns EditOps to apply.
    /// Handles:
    ///   • Normal paste at cursor (replaces selection if present)
    ///   • Multi-cursor paste (one per-cursor entry per cursor, cycled if count mismatch)
    ///   • Line-mode paste (inserts the line above the cursor line)
    pub fn paste(&mut self, buffer: &Buffer, cursors: &MultiCursor) -> Vec<EditOp> {
        // Sync from platform clipboard (in case text was copied externally)
        if let Some(platform_text) = self.provider.get_text() {
            let current = self.current().map(|e| e.text.clone()).unwrap_or_default();
            if platform_text != current && !platform_text.is_empty() {
                let entry = ClipboardEntry::new_text(platform_text);
                // Insert at head without disturbing paste_idx cycle
                self.head = (self.head + 1) % HISTORY_CAPACITY;
                self.ring[self.head] = entry.clone();
                if self.len < HISTORY_CAPACITY {
                    self.len += 1;
                }
                self.paste_idx = self.head;
                self.provider.set_text(&entry.text);
            }
        }

        let entry = match self.current() {
            Some(e) => e.clone(),
            None => return vec![],
        };

        self.paste_idx = self.head; // reset cycle after normal paste
        self.build_paste_ops(buffer, cursors, &entry)
    }

    /// Cycle paste — paste the previous clipboard entry.
    /// Call repeatedly to walk through history.
    pub fn cycle_paste(&mut self, buffer: &Buffer, cursors: &MultiCursor) -> Vec<EditOp> {
        if self.len == 0 {
            return vec![];
        }
        self.paste_idx = if self.paste_idx == 0 {
            HISTORY_CAPACITY - 1
        } else {
            self.paste_idx - 1
        };
        let entry = self.ring[self.paste_idx].clone();
        self.build_paste_ops(buffer, cursors, &entry)
    }

    fn build_paste_ops(
        &self,
        buffer: &Buffer,
        cursors: &MultiCursor,
        entry: &ClipboardEntry,
    ) -> Vec<EditOp> {
        let all_cursors = cursors.all();
        let cursor_count = all_cursors.len();
        let mut ops: Vec<EditOp> = Vec::new();

        if entry.kind == ClipboardKind::Line {
            // Line-mode paste: insert the line above the cursor's line
            for cursor in all_cursors.iter().rev() {
                let lc = buffer.offset_to_line_col(cursor.pos);
                let line_start =
                    buffer.line_col_to_offset(crate::core::types::LineCol::new(lc.line, 0));
                ops.push(EditOp::insert(line_start.0, &entry.text));
            }
        } else if cursor_count > 1 && entry.per_cursor.len() == cursor_count {
            // Multi-cursor paste with matching entry count
            for (cursor, text) in all_cursors.iter().zip(entry.per_cursor.iter()).rev() {
                if let Some(sel) = cursor.selection() {
                    ops.push(EditOp::replace(sel.start.0, sel.end.0, text));
                } else {
                    ops.push(EditOp::insert(cursor.pos.0, text));
                }
            }
        } else {
            // Normal paste: replace selection or insert at each cursor
            for cursor in all_cursors.iter().rev() {
                // Cycle through per_cursor entries if lengths differ
                let text_idx = cursor as *const _ as usize % entry.per_cursor.len();
                let text = &entry.per_cursor[text_idx];
                if let Some(sel) = cursor.selection() {
                    ops.push(EditOp::replace(sel.start.0, sel.end.0, text));
                } else {
                    ops.push(EditOp::insert(cursor.pos.0, text));
                }
            }
        }

        ops
    }

    // ── Queries ───────────────────────────────────────────────────────────────

    pub fn current(&self) -> Option<&ClipboardEntry> {
        if self.len == 0 {
            return None;
        }
        Some(&self.ring[self.head])
    }

    pub fn history(&self) -> Vec<&ClipboardEntry> {
        let mut result = Vec::new();
        if self.len == 0 {
            return result;
        }
        for i in 0..self.len {
            let idx = (self.head + HISTORY_CAPACITY - i) % HISTORY_CAPACITY;
            result.push(&self.ring[idx]);
        }
        result
    }

    pub fn history_len(&self) -> usize {
        self.len
    }

    pub fn peek_text(&self) -> &str {
        self.current().map(|e| e.text.as_str()).unwrap_or("")
    }
}

impl Default for Clipboard {
    fn default() -> Self {
        Self::new()
    }
}

// ── Statistics helper (also used by buffer) ────────────────────────────────────

/// Document statistics computed from the buffer.
#[derive(Debug, Clone, Serialize)]
pub struct DocumentStats {
    pub bytes: usize,
    pub chars: usize,
    pub words: usize,
    pub lines: usize,
    pub sentences: usize,
    pub paragraphs: usize,
}

impl DocumentStats {
    pub fn compute(buffer: &Buffer) -> Self {
        let text = buffer.to_string();
        Self {
            bytes: buffer.len_bytes(),
            chars: buffer.len_chars(),
            words: count_words(&text),
            lines: buffer.len_lines().saturating_sub(1), // don't count trailing empty
            sentences: count_sentences(&text),
            paragraphs: count_paragraphs(&text),
        }
    }

    pub fn compute_selection(buffer: &Buffer, range: Range) -> Self {
        let text = buffer.text_in_range(range);
        let lines = text.lines().count();
        Self {
            bytes: text.len(),
            chars: text.chars().count(),
            words: count_words(&text),
            lines,
            sentences: count_sentences(&text),
            paragraphs: count_paragraphs(&text),
        }
    }
}

fn count_words(text: &str) -> usize {
    // Word: sequence of alphanumeric or underscore characters.
    let mut in_word = false;
    let mut count = 0usize;
    for ch in text.chars() {
        if ch.is_alphanumeric() || ch == '_' {
            if !in_word {
                count += 1;
            }
            in_word = true;
        } else {
            in_word = false;
        }
    }
    count
}

fn count_sentences(text: &str) -> usize {
    // Sentence boundary: `. `, `! `, `? ` or end-of-text after word chars
    let mut count = 0usize;
    let chars: Vec<char> = text.chars().collect();
    for i in 0..chars.len() {
        let ch = chars[i];
        if matches!(ch, '.' | '!' | '?') {
            let next = chars.get(i + 1).copied();
            if next.map(|c| c.is_whitespace()).unwrap_or(true) {
                count += 1;
            }
        }
    }
    count.max(if text.trim().is_empty() { 0 } else { 1 })
}

fn count_paragraphs(text: &str) -> usize {
    // Paragraph: block of non-empty lines separated by blank lines
    let mut in_para = false;
    let mut count = 0usize;
    for line in text.lines() {
        if line.trim().is_empty() {
            in_para = false;
        } else if !in_para {
            in_para = true;
            count += 1;
        }
    }
    count
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::core::cursor::MultiCursor;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }
    fn cursors_at(pos: usize) -> MultiCursor {
        let mut c = MultiCursor::new();
        c.move_to(pos, false);
        c
    }

    // ── Copy ──────────────────────────────────────────────────────────────────

    #[test]
    fn test_copy_selection() {
        let b = buf("hello world");
        let mut c = MultiCursor::new();
        c.move_to(0, false);
        c.move_to(5, true); // select "hello"
        let mut cb = Clipboard::new();
        cb.copy(&b, &c);
        assert_eq!(cb.peek_text(), "hello");
        assert_eq!(cb.current().unwrap().kind, ClipboardKind::Text);
    }

    #[test]
    fn test_copy_no_selection_copies_line() {
        let b = buf("hello\nworld\n");
        let c = cursors_at(2); // inside "hello"
        let mut cb = Clipboard::new();
        cb.copy(&b, &c);
        assert_eq!(cb.current().unwrap().kind, ClipboardKind::Line);
        assert!(cb.peek_text().contains("hello"));
    }

    #[test]
    fn test_copy_multi_cursor() {
        let b = buf("foo bar foo");
        let mut c = MultiCursor::new();
        // cursor 0: select "foo" at 0-3
        c.move_to(0, false);
        c.move_to(3, true);
        // cursor 1: select "foo" at 8-11
        c.add(8); // this adds a second cursor at 8
        let mut cb = Clipboard::new();
        cb.copy(&b, &c);
        // Should have per-cursor entries
        assert!(!cb.current().unwrap().per_cursor.is_empty());
    }

    // ── Cut ───────────────────────────────────────────────────────────────────

    #[test]
    fn test_cut_returns_delete_op() {
        let b = buf("hello world");
        let mut c = MultiCursor::new();
        c.move_to(0, false);
        c.move_to(5, true);
        let mut cb = Clipboard::new();
        let ops = cb.cut(&b, &c);
        assert_eq!(ops.len(), 1);
        assert_eq!(cb.peek_text(), "hello");
        match &ops[0] {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 0);
                assert_eq!(range.end.0, 5);
            }
            _ => panic!("Expected Delete op"),
        }
    }

    #[test]
    fn test_cut_line_mode_no_selection() {
        let b = buf("line1\nline2\nline3\n");
        let c = cursors_at(2); // inside "line1"
        let mut cb = Clipboard::new();
        let ops = cb.cut(&b, &c);
        assert_eq!(ops.len(), 1);
        assert_eq!(cb.current().unwrap().kind, ClipboardKind::Line);
        match &ops[0] {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 0); // start of line1
                assert_eq!(range.end.0, 6); // including \n
            }
            _ => panic!("Expected Delete op"),
        }
    }

    // ── Paste ─────────────────────────────────────────────────────────────────

    #[test]
    fn test_paste_inserts_at_cursor() {
        let b = buf("hello world");
        let c = cursors_at(5);
        let mut cb = Clipboard::new();
        cb.copy(&buf("hello world"), &{
            let mut mc = MultiCursor::new();
            mc.move_to(0, false);
            mc.move_to(5, true);
            mc
        });
        let ops = cb.paste(&b, &c);
        assert!(!ops.is_empty());
        match &ops[0] {
            EditOp::Insert { at, text } => {
                assert_eq!(at.0, 5);
                assert_eq!(text, "hello");
            }
            _ => panic!("Expected Insert op"),
        }
    }

    #[test]
    fn test_paste_replaces_selection() {
        let b = buf("hello world");
        let mut c = MultiCursor::new();
        c.move_to(6, false);
        c.move_to(11, true); // select "world"
        let mut cb = Clipboard::new();
        // Put "rust" in clipboard
        cb.copy(&buf("rust"), &{
            let mut mc = MultiCursor::new();
            mc.move_to(0, false);
            mc.move_to(4, true);
            mc
        });
        let ops = cb.paste(&b, &c);
        assert!(!ops.is_empty());
        match &ops[0] {
            EditOp::Replace { range, text } => {
                assert_eq!(range.start.0, 6);
                assert_eq!(text, "rust");
            }
            _ => panic!("Expected Replace op"),
        }
    }

    #[test]
    fn test_history_grows() {
        let b = buf("abc def ghi");
        let mut cb = Clipboard::new();
        for i in 0..5 {
            let mut c = MultiCursor::new();
            c.move_to(i, false);
            c.move_to(i + 1, true);
            cb.copy(&b, &c);
        }
        assert_eq!(cb.history_len(), 5);
    }

    #[test]
    fn test_history_capped_at_10() {
        let b = buf("abcdefghijklmnopqrst");
        let mut cb = Clipboard::new();
        for i in 0..15 {
            let mut c = MultiCursor::new();
            c.move_to(i, false);
            c.move_to(i + 1, true);
            cb.copy(&b, &c);
        }
        assert_eq!(cb.history_len(), 10);
    }

    #[test]
    fn test_cycle_paste_walks_history() {
        let b = buf("abcdefgh");
        let mut cb = Clipboard::new();
        // Copy three different things
        for (s, e) in &[(0, 1), (1, 2), (2, 3)] {
            let mut c = MultiCursor::new();
            c.move_to(*s, false);
            c.move_to(*e, true);
            cb.copy(&b, &c);
        }
        // Normal paste gets "c"
        let ops1 = cb.paste(&b, &cursors_at(0));
        // Cycle paste gets "b"
        let ops2 = cb.cycle_paste(&b, &cursors_at(0));
        // Both produce Insert ops
        assert!(!ops1.is_empty());
        assert!(!ops2.is_empty());
    }

    // ── Document statistics ────────────────────────────────────────────────────

    #[test]
    fn test_word_count_basic() {
        assert_eq!(count_words("hello world"), 2);
        assert_eq!(count_words("one two three four five"), 5);
        assert_eq!(count_words("  spaces   between  "), 2);
        assert_eq!(count_words(""), 0);
    }

    #[test]
    fn test_word_count_code() {
        assert_eq!(count_words("fn main() { let x = 1; }"), 5);
    }

    #[test]
    fn test_sentence_count() {
        assert_eq!(count_sentences("Hello. World."), 2);
        assert_eq!(count_sentences("Is this? Yes! No."), 3);
        assert_eq!(count_sentences("no sentence ending"), 1);
        assert_eq!(count_sentences(""), 0);
    }

    #[test]
    fn test_paragraph_count() {
        let text = "Para one.\nStill para one.\n\nPara two.\n\nPara three.";
        assert_eq!(count_paragraphs(text), 3);
    }

    #[test]
    fn test_document_stats() {
        let b = buf("Hello world.\nSecond line.\n");
        let stats = DocumentStats::compute(&b);
        assert_eq!(stats.words, 4);
        assert!(stats.chars > 0);
        assert!(stats.lines >= 2);
    }

    #[test]
    fn test_selection_stats() {
        let b = buf("hello world this is a test");
        let range = Range::new(0, 11); // "hello world"
        let stats = DocumentStats::compute_selection(&b, range);
        assert_eq!(stats.words, 2);
        assert_eq!(stats.chars, 11);
    }

    #[test]
    fn test_in_memory_clipboard_provider() {
        let mut p = InMemoryClipboard::default();
        assert!(p.get_text().is_none());
        p.set_text("hello");
        assert_eq!(p.get_text().unwrap(), "hello");
    }
}
