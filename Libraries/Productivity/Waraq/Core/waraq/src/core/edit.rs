// src/core/edit.rs
//
// Structured edit operations — the atoms of editor mutations.
//
// Every mutation is expressed as an `EditOp`. The undo stack stores
// the inverse of each op, enabling perfect undo/redo without storing
// full snapshots.

use serde::{Deserialize, Serialize};

use super::buffer::TextChange;
use super::types::{ByteOffset, Position, Range};

/// An atomic edit operation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EditOp {
    Insert { at: ByteOffset, text: String },
    Delete { range: Range },
    Replace { range: Range, text: String },
}

impl EditOp {
    // ── Constructors ──────────────────────────────────────────────────────────

    pub fn insert(at: usize, text: impl Into<String>) -> Self {
        Self::Insert {
            at: ByteOffset(at),
            text: text.into(),
        }
    }

    pub fn delete(start: usize, end: usize) -> Self {
        Self::Delete {
            range: Range::new(start, end),
        }
    }

    pub fn replace(start: usize, end: usize, text: impl Into<String>) -> Self {
        Self::Replace {
            range: Range::new(start, end),
            text: text.into(),
        }
    }

    // ── Common editor actions → EditOp ────────────────────────────────────────

    /// Type a character at `pos` (handles newline correctly).
    pub fn type_char(pos: usize, ch: char) -> Self {
        let mut s = String::with_capacity(ch.len_utf8());
        s.push(ch);
        Self::insert(pos, s)
    }

    /// Backspace at `pos`: deletes the char to the left.
    pub fn backspace(pos: usize, char_len: usize) -> Self {
        Self::delete(pos.saturating_sub(char_len), pos)
    }

    /// Delete-forward at `pos`: deletes the char to the right.
    pub fn delete_forward(pos: usize, char_len: usize) -> Self {
        Self::delete(pos, pos + char_len)
    }

    /// Indent a range of lines by `width` spaces.
    pub fn indent_lines(line_starts: Vec<usize>, width: usize) -> Vec<Self> {
        let indent = " ".repeat(width);
        line_starts
            .into_iter()
            .map(|start| Self::insert(start, &indent))
            .collect()
    }

    /// Dedent: remove up to `width` leading spaces.
    pub fn dedent_line(line_start: usize, current_indent: usize, width: usize) -> Self {
        let remove = current_indent.min(width);
        Self::delete(line_start, line_start + remove)
    }
}

/// The result returned to the renderer after applying an op.
#[derive(Debug, Clone, Serialize)]
pub struct EditResult {
    pub change: TextChange,
    pub cursor_positions: Vec<Position>,
    pub dirty: bool,
}

/// A batch of edit ops applied atomically (for multi-cursor edits).
/// Applied in REVERSE order by index to keep offsets valid across cursors.
#[derive(Debug, Clone)]
pub struct EditBatch {
    ops: Vec<EditOp>,
}

impl EditBatch {
    pub fn new() -> Self {
        Self { ops: vec![] }
    }

    pub fn push(&mut self, op: EditOp) {
        self.ops.push(op);
    }

    /// Returns ops sorted in reverse offset order (safe to apply sequentially).
    pub fn into_sorted(mut self) -> Vec<EditOp> {
        self.ops.sort_by(|a, b| {
            let a_offset = op_start_offset(a);
            let b_offset = op_start_offset(b);
            b_offset.cmp(&a_offset)
        });
        self.ops
    }
}

fn op_start_offset(op: &EditOp) -> usize {
    match op {
        EditOp::Insert { at, .. } => at.0,
        EditOp::Delete { range } => range.start.0,
        EditOp::Replace { range, .. } => range.start.0,
    }
}

impl Default for EditBatch {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_edit_op_constructors() {
        match EditOp::insert(5, "hello") {
            EditOp::Insert { at, text } => {
                assert_eq!(at.0, 5);
                assert_eq!(text, "hello");
            }
            _ => panic!(),
        }
        match EditOp::delete(3, 8) {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 3);
                assert_eq!(range.end.0, 8);
            }
            _ => panic!(),
        }
        match EditOp::replace(2, 6, "world") {
            EditOp::Replace { range, text } => {
                assert_eq!(range.start.0, 2);
                assert_eq!(text, "world");
            }
            _ => panic!(),
        }
    }

    #[test]
    fn test_type_char() {
        match EditOp::type_char(10, 'a') {
            EditOp::Insert { at, text } => {
                assert_eq!(at.0, 10);
                assert_eq!(text, "a");
            }
            _ => panic!(),
        }
    }

    #[test]
    fn test_type_char_multibyte() {
        match EditOp::type_char(0, '€') {
            EditOp::Insert { text, .. } => assert_eq!(text.len(), 3), // € is 3 bytes
            _ => panic!(),
        }
    }

    #[test]
    fn test_backspace() {
        match EditOp::backspace(5, 1) {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 4);
                assert_eq!(range.end.0, 5);
            }
            _ => panic!(),
        }
    }

    #[test]
    fn test_delete_forward() {
        match EditOp::delete_forward(5, 1) {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 5);
                assert_eq!(range.end.0, 6);
            }
            _ => panic!(),
        }
    }

    #[test]
    fn test_indent_lines() {
        let ops = EditOp::indent_lines(vec![0, 10, 20], 4);
        assert_eq!(ops.len(), 3);
        for op in &ops {
            match op {
                EditOp::Insert { text, .. } => assert_eq!(text, "    "),
                _ => panic!("Expected Insert"),
            }
        }
    }

    #[test]
    fn test_dedent_line() {
        match EditOp::dedent_line(0, 8, 4) {
            EditOp::Delete { range } => {
                assert_eq!(range.start.0, 0);
                assert_eq!(range.end.0, 4); // removes min(8, 4) = 4 chars
            }
            _ => panic!("Expected Delete"),
        }
    }

    #[test]
    fn test_edit_batch_sorted_reverse() {
        let mut batch = EditBatch::new();
        batch.push(EditOp::insert(10, "c"));
        batch.push(EditOp::insert(2, "a"));
        batch.push(EditOp::insert(5, "b"));
        let sorted = batch.into_sorted();
        let offsets: Vec<usize> = sorted
            .iter()
            .map(|op| match op {
                EditOp::Insert { at, .. } => at.0,
                _ => 0,
            })
            .collect();
        assert_eq!(offsets, vec![10, 5, 2], "Should be sorted largest-first");
    }
}
