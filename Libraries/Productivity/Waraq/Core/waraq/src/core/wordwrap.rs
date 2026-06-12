// src/core/wordwrap.rs
//
// Word wrap engine — breaks logical lines into visual (wrapped) lines.
//
// When word wrap is enabled the viewport shows more "virtual" lines than
// the underlying buffer has logical lines.  All cursor positions, scroll
// offsets, and rendering are expressed in *logical* lines by the buffer,
// and in *visual* lines by the renderer.
//
// This module provides:
//   WrapMap     — cached mapping logical ↔ visual lines
//   WrapEngine  — computes wrap maps and translates coordinates
//
// Wrap strategies:
//   Off         — no wrapping, horizontal scroll
//   Chars(col)  — break at `col` characters (Unicode-aware)
//   Words(col)  — break on word boundaries before `col` chars
//   Viewport    — break at current viewport width

use crate::core::buffer::Buffer;
use crate::core::config::WordWrap;
use serde::{Deserialize, Serialize};

// ── Visual line ────────────────────────────────────────────────────────────────

/// A single visual (possibly wrapped) line.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WrappedLine {
    /// Logical line index (0-based) in the buffer.
    pub logical_line: usize,
    /// Which wrapped segment within the logical line (0 = first segment).
    pub wrap_index: usize,
    /// Byte offset of the first character of this visual line in the logical line.
    pub start_in_line: usize,
    /// Byte offset (exclusive) of the last character, or end of logical line.
    pub end_in_line: usize,
    /// Continuation marker (true if this is not the first wrap of the line).
    pub is_continuation: bool,
}

impl WrappedLine {
    pub fn text<'a>(&self, line_text: &'a str) -> &'a str {
        let start = self.start_in_line.min(line_text.len());
        let end = self.end_in_line.min(line_text.len());
        &line_text[start..end]
    }
}

// ── Wrap map ──────────────────────────────────────────────────────────────────

/// Cached mapping between logical and visual lines.
#[derive(Debug, Default)]
pub struct WrapMap {
    /// logical_line → first visual line index
    logical_to_visual: Vec<usize>,
    /// visual_line → (logical_line, wrap_index)
    visual_to_logical: Vec<(usize, usize)>,
    /// Total visual line count.
    pub visual_line_count: usize,
}

impl WrapMap {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn logical_to_visual(&self, logical: usize) -> usize {
        self.logical_to_visual
            .get(logical)
            .copied()
            .unwrap_or(logical)
    }

    pub fn visual_to_logical(&self, visual: usize) -> (usize, usize) {
        self.visual_to_logical
            .get(visual)
            .copied()
            .unwrap_or((visual, 0))
    }

    pub fn visual_count_for_logical(&self, logical: usize) -> usize {
        let start = self.logical_to_visual.get(logical).copied().unwrap_or(0);
        let next = self
            .logical_to_visual
            .get(logical + 1)
            .copied()
            .unwrap_or(self.visual_line_count);
        next.saturating_sub(start)
    }

    /// Is the map valid (non-empty)?
    pub fn is_built(&self) -> bool {
        !self.visual_to_logical.is_empty()
    }
}

// ── Wrap engine ───────────────────────────────────────────────────────────────

pub struct WrapEngine {
    pub mode: WordWrap,
    /// Viewport width in columns (only used when mode = Viewport).
    pub viewport_cols: usize,
    /// Cached wrap map (invalidated on edit or config change).
    map: WrapMap,
}

impl WrapEngine {
    pub fn new(mode: WordWrap) -> Self {
        Self {
            mode,
            viewport_cols: 80,
            map: WrapMap::new(),
        }
    }

    pub fn off() -> Self {
        Self::new(WordWrap::Off)
    }

    pub fn is_wrapping(&self) -> bool {
        !matches!(self.mode, WordWrap::Off)
    }

    pub fn set_viewport_cols(&mut self, cols: usize) {
        if cols != self.viewport_cols {
            self.viewport_cols = cols;
            self.map = WrapMap::new(); // invalidate
        }
    }

    pub fn set_mode(&mut self, mode: WordWrap) {
        self.mode = mode;
        self.map = WrapMap::new(); // invalidate
    }

    /// Invalidate the cache (call after any buffer edit).
    pub fn invalidate(&mut self) {
        self.map = WrapMap::new();
    }

    /// Get the wrap column for the current mode.
    fn wrap_col(&self) -> usize {
        match &self.mode {
            WordWrap::Off => usize::MAX,
            WordWrap::On => self.viewport_cols,
            WordWrap::Column(col) => *col as usize,
        }
    }

    // ── Map building ──────────────────────────────────────────────────────────

    /// Build (or return cached) wrap map for the given buffer.
    pub fn map(&mut self, buffer: &Buffer) -> &WrapMap {
        if !self.map.is_built() {
            self.build_map(buffer);
        }
        &self.map
    }

    fn build_map(&mut self, buffer: &Buffer) {
        let col = self.wrap_col();
        let mut logical_to_visual = Vec::with_capacity(buffer.len_lines());
        let mut visual_to_logical = Vec::new();
        let mut visual = 0usize;

        for logical in 0..buffer.len_lines() {
            logical_to_visual.push(visual);
            let line = buffer.line_str(logical);
            let line = line.trim_end_matches(['\n', '\r']);
            let segs = self.split_line(line, col);
            let count = segs.len().max(1);
            for i in 0..count {
                visual_to_logical.push((logical, i));
            }
            visual += count;
        }

        self.map = WrapMap {
            logical_to_visual,
            visual_to_logical,
            visual_line_count: visual,
        };
    }

    /// Split a line into visual segments at the wrap column.
    pub fn split_line<'a>(&self, line: &'a str, col: usize) -> Vec<&'a str> {
        if col == usize::MAX || line.len() <= col {
            return vec![line];
        }

        let mut segments = Vec::new();
        let mut remaining = line;

        while !remaining.is_empty() {
            let char_count = remaining.chars().count();
            if char_count <= col {
                segments.push(remaining);
                break;
            }

            // Find the byte index of the `col`-th character
            let mut byte_idx = 0;
            let mut chars_seen = 0;
            for ch in remaining.chars() {
                if chars_seen == col {
                    break;
                }
                byte_idx += ch.len_utf8();
                chars_seen += 1;
            }

            // For word-wrap mode, back up to the last space
            let break_at = if matches!(self.mode, WordWrap::On | WordWrap::Column(_)) {
                // Try to break at word boundary
                let segment = &remaining[..byte_idx];
                if let Some(last_space) = segment.rfind(' ') {
                    last_space + 1 // break after the space
                } else {
                    byte_idx // no space found, hard break at column
                }
            } else {
                byte_idx
            };

            segments.push(&remaining[..break_at]);
            remaining = &remaining[break_at..];
        }

        if segments.is_empty() {
            segments.push("");
        }
        segments
    }

    // ── Coordinate translation ────────────────────────────────────────────────

    /// Convert a logical line to its first visual line.
    pub fn logical_to_visual_line(&mut self, logical: usize, buffer: &Buffer) -> usize {
        if !self.is_wrapping() {
            return logical;
        }
        self.map(buffer).logical_to_visual(logical)
    }

    /// Convert a visual line to (logical_line, wrap_index).
    pub fn visual_to_logical_line(&mut self, visual: usize, buffer: &Buffer) -> (usize, usize) {
        if !self.is_wrapping() {
            return (visual, 0);
        }
        self.map(buffer).visual_to_logical(visual)
    }

    /// Total visual line count.
    pub fn total_visual_lines(&mut self, buffer: &Buffer) -> usize {
        if !self.is_wrapping() {
            return buffer.len_lines();
        }
        self.map(buffer).visual_line_count
    }

    // ── Visual line text ───────────────────────────────────────────────────────

    /// Get the wrapped lines for a range of visual lines [first..last].
    pub fn visual_lines<'a>(
        &mut self,
        buffer: &'a Buffer,
        first_visual: usize,
        last_visual: usize,
    ) -> Vec<WrappedLine> {
        let col = self.wrap_col();
        let mut out = Vec::new();

        if !self.is_wrapping() {
            for vl in first_visual..=last_visual {
                if vl >= buffer.len_lines() {
                    break;
                }
                let text = buffer.line_str(vl);
                let len = text.trim_end_matches(['\n', '\r']).len();
                out.push(WrappedLine {
                    logical_line: vl,
                    wrap_index: 0,
                    start_in_line: 0,
                    end_in_line: len,
                    is_continuation: false,
                });
            }
            return out;
        }

        // Build map first so visual_to_logical is populated
        if !self.map.is_built() {
            self.build_map(buffer);
        }

        for vl in first_visual..=last_visual {
            let (logical, wrap_idx) = self.map.visual_to_logical(vl);
            if logical >= buffer.len_lines() {
                break;
            }

            let full_line = buffer.line_str(logical);
            let line = full_line.trim_end_matches(['\n', '\r']);
            let segs = self.split_line(line, col);

            if let Some(seg) = segs.get(wrap_idx) {
                let start = seg.as_ptr() as usize - line.as_ptr() as usize;
                let end = start + seg.len();
                out.push(WrappedLine {
                    logical_line: logical,
                    wrap_index: wrap_idx,
                    start_in_line: start,
                    end_in_line: end,
                    is_continuation: wrap_idx > 0,
                });
            }
        }
        out
    }
}

impl Default for WrapEngine {
    fn default() -> Self {
        Self::off()
    }
}

// ── C API ─────────────────────────────────────────────────────────────────────
// (Exposed via json_bridge batch commands: WordWrapSet, WordWrapMode)

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::core::config::WordWrap;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    // ── Split line ─────────────────────────────────────────────────────────────

    #[test]
    fn test_split_line_no_wrap_short() {
        let engine = WrapEngine::new(WordWrap::Column(80));
        let segs = engine.split_line("hello world", 80);
        assert_eq!(segs, vec!["hello world"]);
    }

    #[test]
    fn test_split_line_hard_wrap() {
        let engine = WrapEngine::new(WordWrap::Column(10));
        let segs = engine.split_line("hello world foo bar", 10);
        assert!(segs.len() > 1);
        // Each segment should be ≤ 10 chars
        for seg in &segs {
            assert!(seg.chars().count() <= 10, "Segment too long: {:?}", seg);
        }
    }

    #[test]
    fn test_split_line_word_boundary() {
        let engine = WrapEngine::new(WordWrap::On);
        // Line is 25 chars, wrap at 20 — should break at the last space before col 20
        let segs = engine.split_line("hello world this is long text", 20);
        assert!(segs.len() >= 2);
        // First segment should not contain the full line
        assert!(segs[0].len() < 30);
    }

    #[test]
    fn test_split_line_no_spaces_hard_break() {
        let engine = WrapEngine::new(WordWrap::On);
        let long = "a".repeat(50);
        let segs = engine.split_line(&long, 20);
        assert!(segs.len() >= 2);
    }

    #[test]
    fn test_split_empty_line() {
        let engine = WrapEngine::new(WordWrap::Column(80));
        let segs = engine.split_line("", 80);
        assert_eq!(segs.len(), 1);
        assert_eq!(segs[0], "");
    }

    #[test]
    fn test_split_unicode() {
        let engine = WrapEngine::new(WordWrap::Column(5));
        let text = "こんにちは世界"; // 7 chars, each 3 bytes
        let segs = engine.split_line(text, 5);
        assert!(segs.len() >= 2);
    }

    // ── Map building ───────────────────────────────────────────────────────────

    #[test]
    fn test_map_no_wrap_identity() {
        let mut engine = WrapEngine::off();
        let b = buf("line1\nline2\nline3\n");
        assert_eq!(engine.logical_to_visual_line(0, &b), 0);
        assert_eq!(engine.logical_to_visual_line(2, &b), 2);
    }

    #[test]
    fn test_map_wrap_increases_visual_count() {
        let b = buf(
            "short\nthis is a very long line that will definitely wrap at forty chars\nshort\n",
        );
        let mut engine = WrapEngine::new(WordWrap::Column(40));
        let total = engine.total_visual_lines(&b);
        assert!(
            total > b.len_lines(),
            "Wrap should produce more visual than logical lines"
        );
    }

    #[test]
    fn test_map_logical_to_visual_monotone() {
        let b = buf("line1\nlong line that wraps at 20 chars here indeed\nline3\n");
        let mut engine = WrapEngine::new(WordWrap::Column(20));
        let v0 = engine.logical_to_visual_line(0, &b);
        let v1 = engine.logical_to_visual_line(1, &b);
        let v2 = engine.logical_to_visual_line(2, &b);
        assert!(v0 < v1);
        assert!(v1 < v2);
    }

    #[test]
    fn test_map_visual_to_logical_roundtrip() {
        let b = buf("line1\nlong line that wraps beyond twenty chars\nline3\n");
        let mut engine = WrapEngine::new(WordWrap::Column(20));
        engine.map(&b);
        let total = engine.map.visual_line_count;
        for visual in 0..total {
            let (logical, _) = engine.map.visual_to_logical(visual);
            assert!(
                logical < b.len_lines(),
                "logical {} >= line count {}",
                logical,
                b.len_lines()
            );
        }
    }

    // ── Visual lines ───────────────────────────────────────────────────────────

    #[test]
    fn test_visual_lines_no_wrap() {
        let b = buf("line0\nline1\nline2\n");
        let mut engine = WrapEngine::off();
        let vl = engine.visual_lines(&b, 0, 2);
        assert_eq!(vl.len(), 3);
        for (i, line) in vl.iter().enumerate() {
            assert_eq!(line.logical_line, i);
            assert!(!line.is_continuation);
        }
    }

    #[test]
    fn test_visual_lines_wrap_continuation() {
        let b = buf("this line is long enough to wrap at twenty chars for sure");
        let mut engine = WrapEngine::new(WordWrap::Column(20));
        let total = engine.total_visual_lines(&b);
        let vl = engine.visual_lines(&b, 0, total.saturating_sub(1));
        // All segments should be from logical_line 0
        for line in &vl {
            assert_eq!(line.logical_line, 0);
        }
        // All but the first should be continuations
        for line in vl.iter().skip(1) {
            assert!(line.is_continuation);
        }
    }

    #[test]
    fn test_visual_lines_text_reconstructs() {
        let src = "hello world foo bar baz";
        let b = buf(src);
        let mut engine = WrapEngine::new(WordWrap::Column(10));
        let total = engine.total_visual_lines(&b);
        let vl = engine.visual_lines(&b, 0, total.saturating_sub(1));
        let reconstructed: String = vl.iter().map(|l| l.text(src.trim_end())).collect();
        assert_eq!(
            reconstructed,
            src.trim_end(),
            "Reconstructed text should match original"
        );
    }

    // ── Invalidation ──────────────────────────────────────────────────────────

    #[test]
    fn test_invalidation_on_mode_change() {
        let b = buf("test\n");
        let mut engine = WrapEngine::new(WordWrap::Column(40));
        engine.map(&b); // build
        assert!(engine.map.is_built());
        engine.set_mode(WordWrap::Column(20)); // change mode
        assert!(!engine.map.is_built()); // should be invalidated
    }

    #[test]
    fn test_invalidation_on_viewport_change() {
        let b = buf("test\n");
        let mut engine = WrapEngine::new(WordWrap::On);
        engine.set_viewport_cols(80);
        engine.map(&b);
        assert!(engine.map.is_built());
        engine.set_viewport_cols(40); // change
        assert!(!engine.map.is_built());
    }
}
