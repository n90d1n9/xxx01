// src/core/cursor.rs
//
// Multi-cursor state engine.
//
// Design goals:
//   • Any number of cursors (VS Code model)
//   • Each cursor optionally has a Selection anchor
//   • All cursors are kept sorted and non-overlapping
//   • Cursors adjust automatically after buffer edits

use serde::{Deserialize, Serialize};

use super::buffer::TextChange;
use super::types::{ByteOffset, LineCol, Position, Range};
use crate::core::buffer::Buffer;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CursorKind {
    /// Standard insert-mode cursor
    Bar,
    /// Block cursor (terminal / vim normal mode)
    Block,
    /// Underline cursor
    Underline,
}

/// A single cursor with an optional selection.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cursor {
    /// Current cursor position (byte offset).
    pub pos: ByteOffset,
    /// Selection anchor. When Some, text between anchor and pos is selected.
    pub anchor: Option<ByteOffset>,
    /// Visual style.
    pub kind: CursorKind,
    /// Preferred column — preserved during line moves across short lines.
    preferred_col: Option<usize>,
    /// Column-line position cache (lazily filled, cleared on mutation).
    cached_lc: Option<LineCol>,
}

impl Cursor {
    pub fn at(offset: usize) -> Self {
        Self {
            pos: ByteOffset(offset),
            anchor: None,
            kind: CursorKind::Bar,
            preferred_col: None,
            cached_lc: None,
        }
    }

    pub fn selection(&self) -> Option<Selection> {
        self.anchor.map(|anchor| {
            let (start, end) = if anchor <= self.pos {
                (anchor, self.pos)
            } else {
                (self.pos, anchor)
            };
            Selection { start, end }
        })
    }

    pub fn has_selection(&self) -> bool {
        self.anchor.is_some()
    }

    pub fn collapse(&mut self) {
        self.anchor = None;
    }

    pub fn start_selection(&mut self) {
        if self.anchor.is_none() {
            self.anchor = Some(self.pos);
        }
    }

    /// Adjust after a text change.
    pub fn adjust(&mut self, change: &TextChange) {
        self.pos = adjust_offset(self.pos, change);
        if let Some(anchor) = self.anchor {
            self.anchor = Some(adjust_offset(anchor, change));
        }
        self.cached_lc = None;
    }
}

/// A resolved selection range (always start <= end).
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Selection {
    pub start: ByteOffset,
    pub end: ByteOffset,
}

impl Selection {
    pub fn is_empty(&self) -> bool {
        self.start == self.end
    }
    pub fn len(&self) -> usize {
        self.end.0 - self.start.0
    }
    pub fn as_range(&self) -> Range {
        Range::new(self.start.0, self.end.0)
    }
}

/// The multi-cursor collection.
///
/// Invariants maintained at all times:
///   1. Sorted by `pos` ascending.
///   2. No two cursors have overlapping selections.
///   3. At least one cursor (the "primary") always exists.
pub struct MultiCursor {
    cursors: Vec<Cursor>,
    primary: usize,
}

impl MultiCursor {
    pub fn new() -> Self {
        Self {
            cursors: vec![Cursor::at(0)],
            primary: 0,
        }
    }

    pub fn primary(&self) -> &Cursor {
        &self.cursors[self.primary]
    }
    pub fn primary_mut(&mut self) -> &mut Cursor {
        &mut self.cursors[self.primary]
    }

    pub fn all(&self) -> &[Cursor] {
        &self.cursors
    }
    pub fn all_mut(&mut self) -> &mut [Cursor] {
        &mut self.cursors
    }
    pub fn count(&self) -> usize {
        self.cursors.len()
    }

    /// All cursor positions as `Position` (for the renderer).
    pub fn all_positions(&self) -> Vec<Position> {
        self.cursors
            .iter()
            .map(|c| Position {
                line: 0,
                col: c.pos.0,
            })
            .collect()
    }

    /// Add a cursor at `offset`. Merges if it would overlap an existing cursor.
    pub fn add(&mut self, offset: usize) {
        let new_cursor = Cursor::at(offset);
        self.cursors.push(new_cursor);
        self.sort_and_merge();
    }

    /// Remove all cursors except primary.
    pub fn collapse_to_primary(&mut self) {
        let primary = self.cursors[self.primary].clone();
        self.cursors = vec![primary];
        self.primary = 0;
    }

    /// Move primary cursor. `extend` = extend selection.
    pub fn move_to(&mut self, offset: usize, extend: bool) {
        let cursor = &mut self.cursors[self.primary];
        if extend {
            cursor.start_selection();
        } else {
            cursor.collapse();
        }
        cursor.pos = ByteOffset(offset);
        cursor.cached_lc = None;
    }

    /// Move all cursors to new positions (for find-all, column select, etc.).
    pub fn set_all(&mut self, positions: Vec<usize>) {
        self.cursors = positions.into_iter().map(Cursor::at).collect();
        if self.cursors.is_empty() {
            self.cursors.push(Cursor::at(0));
        }
        self.primary = 0;
        self.sort_and_merge();
    }

    /// Adjust all cursors after a buffer edit.
    pub fn adjust_for_change(&mut self, change: &TextChange) {
        for cursor in &mut self.cursors {
            cursor.adjust(change);
        }
        self.sort_and_merge();
    }

    // ── Motion helpers (called by keyboard handler) ───────────────────────────

    pub fn move_by_chars(&mut self, delta: i64, extend: bool, buffer: &Buffer) {
        for cursor in &mut self.cursors {
            if extend {
                cursor.start_selection();
            } else {
                cursor.collapse();
            }
            let new_pos = (cursor.pos.0 as i64 + delta)
                .max(0)
                .min(buffer.len_bytes() as i64) as usize;
            cursor.pos = ByteOffset(new_pos);
            cursor.cached_lc = None;
        }
        self.sort_and_merge();
    }

    pub fn move_by_lines(&mut self, delta: i64, extend: bool, buffer: &Buffer) {
        for cursor in &mut self.cursors {
            if extend {
                cursor.start_selection();
            } else {
                cursor.collapse();
            }
            let lc = buffer.offset_to_line_col(cursor.pos);
            let preferred = cursor.preferred_col.get_or_insert(lc.col);
            let new_line = (lc.line as i64 + delta)
                .max(0)
                .min(buffer.len_lines().saturating_sub(1) as i64)
                as usize;
            let max_col = buffer.line_len_chars(new_line).saturating_sub(1);
            let new_col = (*preferred).min(max_col);
            cursor.pos = buffer.line_col_to_offset(LineCol::new(new_line, new_col));
            cursor.cached_lc = None;
        }
        self.sort_and_merge();
    }

    pub fn select_all(&mut self, buffer: &Buffer) {
        self.cursors = vec![{
            let mut c = Cursor::at(buffer.len_bytes());
            c.anchor = Some(ByteOffset(0));
            c
        }];
        self.primary = 0;
    }

    // ── Private helpers ────────────────────────────────────────────────────────

    fn sort_and_merge(&mut self) {
        self.cursors.sort_by_key(|c| c.pos);

        // Merge overlapping cursors
        let mut merged: Vec<Cursor> = Vec::new();
        for cursor in self.cursors.drain(..) {
            if let Some(last) = merged.last_mut() {
                let last_end = last.selection().map(|s| s.end).unwrap_or(last.pos);
                let cur_start = cursor.selection().map(|s| s.start).unwrap_or(cursor.pos);
                if cur_start <= last_end {
                    // Merge: keep the further-reaching end
                    if cursor.pos > last.pos {
                        last.pos = cursor.pos;
                    }
                    continue;
                }
            }
            merged.push(cursor);
        }
        self.cursors = merged;
        if self.primary >= self.cursors.len() {
            self.primary = self.cursors.len().saturating_sub(1);
        }
    }
}

impl Default for MultiCursor {
    fn default() -> Self {
        Self::new()
    }
}

/// Adjust an offset after a text change.
fn adjust_offset(offset: ByteOffset, change: &TextChange) -> ByteOffset {
    let edit_start = change.replaced.start.0;
    let deleted_end = change.replaced.end.0;

    if change.replaced.is_empty() {
        if offset.0 < edit_start {
            offset
        } else {
            ByteOffset(offset.0 + change.inserted.len())
        }
    } else if offset.0 <= edit_start {
        // Before edit — unchanged
        offset
    } else if offset.0 < deleted_end {
        // Inside deleted region — clamp to edit start
        ByteOffset(edit_start)
    } else {
        // After edit — shift by net delta
        let new_pos = (offset.0 as i64 + change.byte_delta).max(0) as usize;
        ByteOffset(new_pos)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_multi_cursor_merge() {
        let mut mc = MultiCursor::new();
        mc.add(5);
        mc.add(5); // duplicate
        assert_eq!(mc.count(), 2); // positions differ: 0 and 5
    }

    #[test]
    fn test_cursor_adjust_after_insert() {
        let change = TextChange {
            replaced: Range::new(3, 3),
            inserted: "abc".to_owned(),
            deleted: String::new(),
            byte_delta: 3,
            first_line: 0,
            last_line: 0,
        };
        let offset = ByteOffset(10);
        let adjusted = adjust_offset(offset, &change);
        assert_eq!(adjusted.0, 13);
    }

    #[test]
    fn test_cursor_adjust_inside_delete() {
        let change = TextChange {
            replaced: Range::new(5, 15),
            inserted: String::new(),
            deleted: "0123456789".to_owned(),
            byte_delta: -10,
            first_line: 0,
            last_line: 0,
        };
        // Cursor was inside the deleted region
        let offset = ByteOffset(10);
        let adjusted = adjust_offset(offset, &change);
        assert_eq!(adjusted.0, 5); // clamped to edit start
    }
}

#[cfg(test)]
mod cursor_extended_tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::core::types::{ByteOffset, Range};

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_cursor_at_construction() {
        let c = Cursor::at(10);
        assert_eq!(c.pos, ByteOffset(10));
        assert!(c.anchor.is_none());
    }

    #[test]
    fn test_cursor_selection_anchor() {
        let mut c = Cursor::at(5);
        c.start_selection();
        assert!(c.anchor.is_some());
        c.pos = ByteOffset(15);
        let sel = c.selection().unwrap();
        assert_eq!(sel.start, ByteOffset(5));
        assert_eq!(sel.end, ByteOffset(15));
    }

    #[test]
    fn test_cursor_selection_reversed() {
        let mut c = Cursor::at(15);
        c.anchor = Some(ByteOffset(5)); // anchor > pos is reversed
        c.pos = ByteOffset(5);
        // selection should still work
        let sel = c.selection().unwrap();
        assert!(sel.start.0 <= sel.end.0);
    }

    #[test]
    fn test_cursor_collapse() {
        let mut c = Cursor::at(5);
        c.start_selection();
        c.pos = ByteOffset(10);
        assert!(c.has_selection());
        c.collapse();
        assert!(!c.has_selection());
    }

    #[test]
    fn test_multicursor_add_deduplicates() {
        let mut mc = MultiCursor::new();
        mc.add(5);
        mc.add(10);
        mc.add(5); // duplicate position
                   // After merge, positions are unique
        let positions: Vec<usize> = mc.all().iter().map(|c| c.pos.0).collect();
        let unique: std::collections::HashSet<usize> = positions.iter().copied().collect();
        assert_eq!(
            positions.len(),
            unique.len(),
            "No duplicate cursor positions"
        );
    }

    #[test]
    fn test_multicursor_collapse_to_primary() {
        let mut mc = MultiCursor::new();
        mc.add(5);
        mc.add(10);
        mc.add(20);
        assert!(mc.count() > 1);
        mc.collapse_to_primary();
        assert_eq!(mc.count(), 1);
    }

    #[test]
    fn test_multicursor_move_to() {
        let mut mc = MultiCursor::new();
        mc.move_to(42, false);
        assert_eq!(mc.primary().pos.0, 42);
        assert!(!mc.primary().has_selection());
    }

    #[test]
    fn test_multicursor_move_to_extend() {
        let mut mc = MultiCursor::new();
        mc.move_to(5, false);
        mc.move_to(15, true);
        assert!(mc.primary().has_selection());
        let sel = mc.primary().selection().unwrap();
        assert_eq!(sel.start.0, 5);
        assert_eq!(sel.end.0, 15);
    }

    #[test]
    fn test_multicursor_all_positions() {
        let mut mc = MultiCursor::new();
        mc.add(5);
        mc.add(10);
        let positions = mc.all_positions();
        assert!(positions.iter().any(|p| p.col == 5));
        assert!(positions.iter().any(|p| p.col == 10));
    }

    #[test]
    fn test_multicursor_set_all() {
        let mut mc = MultiCursor::new();
        mc.set_all(vec![3, 7, 15]);
        assert_eq!(mc.count(), 3);
    }

    #[test]
    fn test_cursor_adjust_after_insert_before() {
        let _b = buf("hello world");
        let change = crate::core::buffer::TextChange {
            replaced: Range::new(0, 0),
            inserted: "XY".to_owned(),
            deleted: String::new(),
            byte_delta: 2,
            first_line: 0,
            last_line: 0,
        };
        let mut mc = MultiCursor::new();
        mc.move_to(5, false);
        mc.adjust_for_change(&change);
        // Cursor should shift forward by 2
        assert_eq!(mc.primary().pos.0, 7);
    }

    #[test]
    fn test_cursor_adjust_after_delete_before() {
        let _b = buf("hello world");
        let change = crate::core::buffer::TextChange {
            replaced: Range::new(0, 3),
            inserted: String::new(),
            deleted: "hel".to_owned(),
            byte_delta: -3,
            first_line: 0,
            last_line: 0,
        };
        let mut mc = MultiCursor::new();
        mc.move_to(5, false);
        mc.adjust_for_change(&change);
        // Cursor shifts back by 3
        assert_eq!(mc.primary().pos.0, 2);
    }

    #[test]
    fn test_cursor_select_all() {
        let b = buf("hello world");
        let mut mc = MultiCursor::new();
        mc.select_all(&b);
        let sel = mc.primary().selection().unwrap();
        assert_eq!(sel.start.0, 0);
        assert_eq!(sel.end.0, b.len_bytes());
    }

    #[test]
    fn test_cursor_move_by_chars() {
        let b = buf("hello world");
        let mut mc = MultiCursor::new();
        mc.move_to(0, false);
        mc.move_by_chars(3, false, &b);
        assert_eq!(mc.primary().pos.0, 3);
    }

    #[test]
    fn test_cursor_move_by_lines() {
        let b = buf("line0\nline1\nline2\n");
        let mut mc = MultiCursor::new();
        mc.move_to(0, false);
        mc.move_by_lines(1, false, &b);
        assert!(mc.primary().pos.0 >= 6, "Should be on line 1");
    }

    #[test]
    fn test_selection_len() {
        let sel = Selection {
            start: ByteOffset(5),
            end: ByteOffset(15),
        };
        assert_eq!(sel.len(), 10);
        assert!(!sel.is_empty());
    }

    #[test]
    fn test_selection_empty() {
        let sel = Selection {
            start: ByteOffset(5),
            end: ByteOffset(5),
        };
        assert!(sel.is_empty());
    }
}
