// src/core/buffer.rs
//
// The core text buffer — backed by a Rope (via `ropey`).
//
// Design rationale vs alternatives:
//
//   Gap buffer  — O(n) for edits far from gap; simple but breaks on multi-cursor
//   Piece table — great undo model; fragmentation with heavy editing; VS Code uses this
//   Rope        — O(log n) insert/delete/split/concat; excellent for large files & multi-cursor
//                 Xi Editor and Zed both chose rope-based designs.
//
// We use `ropey` which provides:
//   • UTF-8 aware chunk storage
//   • O(log n) char/byte/line indexing
//   • Slice views without allocation
//   • ~10M chars/sec insert throughput

use ropey::Rope;
use serde::{Deserialize, Serialize};
use unicode_segmentation::UnicodeSegmentation;

use super::types::{ByteOffset, LineCol, Range};
use crate::core::edit::EditOp;

/// A text change that was applied — used to update cursors/syntax incrementally.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextChange {
    /// Range replaced (may be zero-length for a pure insert).
    pub replaced: Range,
    /// New text that was inserted at `replaced.start`.
    pub inserted: String,
    /// Text that was deleted (empty for pure inserts).
    pub deleted: String,
    /// Number of net new bytes.
    pub byte_delta: i64,
    /// First line affected.
    pub first_line: usize,
    /// Last line affected (after the edit).
    pub last_line: usize,
}

impl TextChange {
    pub fn is_insert_only(&self) -> bool {
        self.replaced.is_empty()
    }
    pub fn is_delete_only(&self) -> bool {
        self.inserted.is_empty()
    }
}

/// The primary text storage.
pub struct Buffer {
    rope: Rope,
    /// Cached line count — updated on every mutation.
    line_count: usize,
    /// Total byte length.
    byte_len: usize,
}

impl Buffer {
    pub fn new() -> Self {
        Self {
            rope: Rope::new(),
            line_count: 1,
            byte_len: 0,
        }
    }

    pub fn from_str(s: &str) -> Self {
        let rope = Rope::from_str(s);
        let line_count = rope.len_lines();
        let byte_len = rope.len_bytes();
        Self {
            rope,
            line_count,
            byte_len,
        }
    }

    // ── Metrics ─────────────────────────────────────────────────────────────

    #[inline]
    pub fn len_bytes(&self) -> usize {
        self.byte_len
    }
    #[inline]
    pub fn len_chars(&self) -> usize {
        self.rope.len_chars()
    }
    #[inline]
    pub fn len_lines(&self) -> usize {
        self.line_count
    }
    #[inline]
    pub fn is_empty(&self) -> bool {
        self.byte_len == 0
    }

    // ── Coordinate conversion ────────────────────────────────────────────────

    /// Byte offset → (line, char-column).
    pub fn offset_to_line_col(&self, offset: ByteOffset) -> LineCol {
        let char_idx = self.rope.byte_to_char(offset.0);
        let line = self.rope.char_to_line(char_idx);
        let line_start = self.rope.line_to_char(line);
        LineCol::new(line, char_idx - line_start)
    }

    /// (line, char-column) → byte offset.
    pub fn line_col_to_offset(&self, lc: LineCol) -> ByteOffset {
        let line_start = self
            .rope
            .line_to_char(lc.line.min(self.line_count.saturating_sub(1)));
        let char_idx = (line_start + lc.col).min(self.rope.len_chars());
        ByteOffset(self.rope.char_to_byte(char_idx))
    }

    /// Length of line `n` in characters (including the newline, if any).
    pub fn line_len_chars(&self, line: usize) -> usize {
        if line >= self.line_count {
            return 0;
        }
        self.rope.line(line).len_chars()
    }

    /// Length of line in grapheme clusters (visual width).
    pub fn line_len_graphemes(&self, line: usize) -> usize {
        let line_str = self.line_str(line);
        line_str.graphemes(true).count()
    }

    // ── Text access ──────────────────────────────────────────────────────────

    /// Get an entire line as a `String` (without the trailing newline).
    pub fn line_str(&self, line: usize) -> String {
        if line >= self.line_count {
            return String::new();
        }
        let s = self.rope.line(line).to_string();
        // Strip trailing \n or \r\n
        s.trim_end_matches(['\n', '\r']).to_owned()
    }

    /// Slice of visible lines [start, end) as individual strings.
    pub fn lines_slice(&self, start: usize, end: usize) -> Vec<String> {
        let end = end.min(self.line_count);
        (start..end).map(|l| self.line_str(l)).collect()
    }

    /// Get text in a byte range.
    pub fn text_in_range(&self, range: Range) -> String {
        let start_char = self.rope.byte_to_char(range.start.0);
        let end_char = self.rope.byte_to_char(range.end.0);
        self.rope.slice(start_char..end_char).to_string()
    }

    /// Full document text (use sparingly — allocates).
    pub fn to_string(&self) -> String {
        self.rope.to_string()
    }

    // ── Mutations ────────────────────────────────────────────────────────────

    /// Apply a structured edit operation; returns a `TextChange` for downstream updates.
    pub fn apply_op(&mut self, op: &EditOp) -> TextChange {
        match op {
            EditOp::Insert { at, text } => self.insert(*at, text),
            EditOp::Delete { range } => self.delete(*range),
            EditOp::Replace { range, text } => self.replace(*range, text),
        }
    }

    fn insert(&mut self, at: ByteOffset, text: &str) -> TextChange {
        let char_idx = self.rope.byte_to_char(at.0);
        let first_line = self.rope.char_to_line(char_idx);

        self.rope.insert(char_idx, text);
        self.byte_len = self.rope.len_bytes();
        self.line_count = self.rope.len_lines();

        let last_line = self.rope.char_to_line(char_idx + text.chars().count());

        TextChange {
            replaced: Range::new(at.0, at.0),
            inserted: text.to_owned(),
            deleted: String::new(),
            byte_delta: text.len() as i64,
            first_line,
            last_line,
        }
    }

    fn delete(&mut self, range: Range) -> TextChange {
        let start_char = self.rope.byte_to_char(range.start.0);
        let end_char = self.rope.byte_to_char(range.end.0);
        let first_line = self.rope.char_to_line(start_char);
        let deleted_text = self.rope.slice(start_char..end_char).to_string();

        let deleted_text_len = deleted_text.len();
        self.rope.remove(start_char..end_char);
        self.byte_len = self.rope.len_bytes();
        self.line_count = self.rope.len_lines();

        TextChange {
            replaced: range,
            inserted: String::new(),
            deleted: deleted_text,
            byte_delta: -(deleted_text_len as i64),
            first_line,
            last_line: first_line,
        }
    }

    fn replace(&mut self, range: Range, text: &str) -> TextChange {
        let start_char = self.rope.byte_to_char(range.start.0);
        let end_char = self.rope.byte_to_char(range.end.0);
        let first_line = self.rope.char_to_line(start_char);
        let old_len = range.len();
        let deleted_text_replace = self.rope.slice(start_char..end_char).to_string();

        self.rope.remove(start_char..end_char);
        self.rope.insert(start_char, text);
        self.byte_len = self.rope.len_bytes();
        self.line_count = self.rope.len_lines();

        let last_line = self.rope.char_to_line(start_char + text.chars().count());

        TextChange {
            replaced: range,
            inserted: text.to_owned(),
            deleted: deleted_text_replace,
            byte_delta: text.len() as i64 - old_len as i64,
            first_line,
            last_line,
        }
    }

    // ── Search ───────────────────────────────────────────────────────────────

    /// Simple forward search — returns byte offsets of all matches.
    /// For regex / fuzzy: wire in a separate search module.
    pub fn find_all(&self, pattern: &str) -> Vec<ByteOffset> {
        if pattern.is_empty() {
            return vec![];
        }
        let text = self.rope.to_string();
        text.match_indices(pattern)
            .map(|(i, _)| ByteOffset(i))
            .collect()
    }

    /// Word boundary at offset — walks back/forward to find word edges.
    pub fn word_range_at(&self, offset: ByteOffset) -> Range {
        let text = self.rope.to_string();
        let bytes = text.as_bytes();
        let mut start = offset.0;
        let mut end = offset.0;

        // Walk backwards
        while start > 0 {
            let c = text[..start].chars().last().unwrap_or(' ');
            if !c.is_alphanumeric() && c != '_' {
                break;
            }
            start -= c.len_utf8();
        }

        // Walk forwards
        while end < bytes.len() {
            let c = text[end..].chars().next().unwrap_or(' ');
            if !c.is_alphanumeric() && c != '_' {
                break;
            }
            end += c.len_utf8();
        }

        Range::new(start, end)
    }
}

impl Default for Buffer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_insert_and_len() {
        let mut buf = Buffer::new();
        buf.insert(ByteOffset(0), "hello\nworld\n");
        assert_eq!(buf.len_lines(), 3); // "hello", "world", ""
        assert_eq!(buf.line_str(0), "hello");
        assert_eq!(buf.line_str(1), "world");
    }

    #[test]
    fn test_large_file() {
        // Simulate a 100k-line file insert
        let content: String = (0..100_000)
            .map(|i| format!("line {:06} content here\n", i))
            .collect();
        let buf = Buffer::from_str(&content);
        assert_eq!(buf.len_lines(), 100_001);
    }

    #[test]
    fn test_line_col_roundtrip() {
        let buf = Buffer::from_str("abc\ndef\nghi\n");
        let lc = LineCol::new(1, 2);
        let offset = buf.line_col_to_offset(lc);
        let back = buf.offset_to_line_col(offset);
        assert_eq!(lc, back);
    }

    #[test]
    fn test_word_range() {
        let buf = Buffer::from_str("foo bar_baz qux");
        let range = buf.word_range_at(ByteOffset(4));
        assert_eq!(buf.text_in_range(range), "bar_baz");
    }

    #[test]
    fn test_replace() {
        let mut buf = Buffer::from_str("hello world");
        let range = Range::new(6, 11);
        buf.replace(range, "Rust");
        assert_eq!(buf.to_string(), "hello Rust");
    }
}
