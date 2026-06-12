// src/core/viewport.rs
//
// Viewport — tracks which lines are visible and produces the render payload.
//
// The renderer only receives lines in [scroll_offset, scroll_offset + height).
// This is critical for large files: a 1M-line file never dumps 1M lines to Flutter.

use serde::{Deserialize, Serialize};

use super::buffer::Buffer;

/// A single line ready to be rendered.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VisibleLine {
    /// Logical line number (0-based).
    pub line_number: usize,
    /// Raw text content (no trailing newline).
    pub text: String,
    /// Byte offset of line start in the document.
    pub byte_offset: usize,
}

/// Viewport state.
pub struct Viewport {
    /// First visible line (scroll position).
    scroll_offset: usize,
    /// Number of visible lines (editor height in lines).
    height: usize,
    /// Horizontal scroll offset in characters.
    h_scroll: usize,
}

impl Viewport {
    pub fn new(scroll_offset: usize, height: usize) -> Self {
        Self {
            scroll_offset,
            height,
            h_scroll: 0,
        }
    }

    // ── Accessors ──────────────────────────────────────────────────────────────

    pub fn scroll_offset(&self) -> usize {
        self.scroll_offset
    }
    pub fn height(&self) -> usize {
        self.height
    }
    pub fn h_scroll(&self) -> usize {
        self.h_scroll
    }

    pub fn first_line(&self) -> usize {
        self.scroll_offset
    }
    pub fn last_line(&self, total_lines: usize) -> usize {
        (self.scroll_offset + self.height).min(total_lines)
    }

    // ── Scroll control ────────────────────────────────────────────────────────

    pub fn set_height(&mut self, height: usize) {
        self.height = height.max(1);
    }

    pub fn scroll_to_line(&mut self, line: usize, total_lines: usize) {
        let max_scroll = total_lines.saturating_sub(self.height);
        self.scroll_offset = line.min(max_scroll);
    }

    pub fn scroll_by(&mut self, delta: i64, total_lines: usize) {
        let new_offset = (self.scroll_offset as i64 + delta)
            .max(0)
            .min(total_lines.saturating_sub(self.height) as i64) as usize;
        self.scroll_offset = new_offset;
    }

    /// Ensure `cursor_line` is visible; scroll if needed.
    pub fn ensure_cursor_visible(&mut self, cursor_line: usize, total_lines: usize) {
        // Scroll up if cursor is above viewport
        if cursor_line < self.scroll_offset {
            self.scroll_offset = cursor_line;
        }
        // Scroll down if cursor is below viewport
        let bottom = self.scroll_offset + self.height;
        if cursor_line >= bottom {
            self.scroll_offset = cursor_line.saturating_sub(self.height) + 1;
        }
        // Clamp
        let max = total_lines.saturating_sub(self.height);
        self.scroll_offset = self.scroll_offset.min(max);
    }

    // ── Rendering ─────────────────────────────────────────────────────────────

    /// Produce the list of visible lines from the buffer.
    pub fn visible_lines(&self, buffer: &Buffer) -> Vec<VisibleLine> {
        let total = buffer.len_lines();
        let end = (self.scroll_offset + self.height).min(total);

        (self.scroll_offset..end)
            .map(|line_number| VisibleLine {
                line_number,
                text: buffer.line_str(line_number),
                byte_offset: buffer
                    .line_col_to_offset(super::types::LineCol::new(line_number, 0))
                    .0,
            })
            .collect()
    }

    /// Check whether a given line is inside the current viewport.
    pub fn contains_line(&self, line: usize) -> bool {
        line >= self.scroll_offset && line < self.scroll_offset + self.height
    }
}

impl Default for Viewport {
    fn default() -> Self {
        Self::new(0, 50)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn make_buf(lines: usize) -> Buffer {
        let s: String = (0..lines)
            .map(|i| format!("line {}", i))
            .collect::<Vec<_>>()
            .join("\n");
        Buffer::from_str(&s)
    }

    #[test]
    fn test_visible_lines_basic() {
        let buf = make_buf(100);
        let vp = Viewport::new(10, 20);
        let lines = vp.visible_lines(&buf);
        assert_eq!(lines.len(), 20);
        assert_eq!(lines[0].line_number, 10);
        assert_eq!(lines[19].line_number, 29);
    }

    #[test]
    fn test_ensure_cursor_visible_scroll_down() {
        let mut vp = Viewport::new(0, 20);
        vp.ensure_cursor_visible(25, 100);
        assert!(vp.scroll_offset > 0);
        assert!(vp.scroll_offset + vp.height > 25);
    }

    #[test]
    fn test_clamp_at_end_of_document() {
        let buf = make_buf(10);
        let vp = Viewport::new(0, 50);
        let lines = vp.visible_lines(&buf);
        // Should only return 10 lines even though height is 50
        assert_eq!(lines.len(), 10);
    }
}
