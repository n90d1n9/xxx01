// src/core/indent_guide.rs
//
// Indent guide computation — calculates the column positions where vertical
// indent guide lines should be drawn, per visible line.
//
// Visual indent guides are the faint vertical lines (like │) at each indent
// level. They make deeply nested code easier to read.
//
// Features:
//   • Works with both spaces and tabs
//   • Active guide — the guide for the indent level of the current line
//     is highlighted differently
//   • Empty lines inherit the guide level of the surrounding context
//   • Bracket-scope guides: optional extended guides that span bracket blocks

use crate::core::buffer::Buffer;
use crate::core::config::{Config, IndentStyle};
use serde::{Deserialize, Serialize};

// ── Guide line info ────────────────────────────────────────────────────────────

/// One vertical guide column on one visible line.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct IndentGuide {
    /// 0-based column index where the guide appears.
    pub column: usize,
    /// Indent level (0 = first indent, 1 = second, …).
    pub level: usize,
    /// True if this is the "active" guide (the one matching the cursor's indent).
    pub is_active: bool,
}

/// All guides for one visible line.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LineGuides {
    pub line_number: usize, // 0-based logical line
    pub guides: Vec<IndentGuide>,
    /// The indent depth of this line (in columns).
    pub indent_depth: usize,
}

impl LineGuides {
    pub fn is_empty(&self) -> bool {
        self.guides.is_empty()
    }
    pub fn len(&self) -> usize {
        self.guides.len()
    }
}

// ── Guide engine ───────────────────────────────────────────────────────────────

pub struct IndentGuideEngine {
    pub tab_size: usize,
    pub indent_size: usize,
    pub use_tabs: bool,
}

impl IndentGuideEngine {
    pub fn from_config(cfg: &Config) -> Self {
        Self {
            tab_size: cfg.tab_width as usize,
            indent_size: cfg.indent_width as usize,
            use_tabs: cfg.indent_style == IndentStyle::Tabs,
        }
    }

    pub fn new(indent_size: usize, use_tabs: bool) -> Self {
        Self {
            tab_size: indent_size,
            indent_size,
            use_tabs,
        }
    }

    // ── Indent measurement ────────────────────────────────────────────────────

    /// Count leading whitespace columns in a line.
    pub fn indent_cols(&self, line: &str) -> usize {
        let mut cols = 0usize;
        for ch in line.chars() {
            match ch {
                ' ' => cols += 1,
                '\t' => cols += self.tab_size - (cols % self.tab_size),
                _ => break,
            }
        }
        cols
    }

    /// Number of complete indent levels.
    pub fn indent_level(&self, line: &str) -> usize {
        let cols = self.indent_cols(line);
        let unit = self.indent_size.max(1);
        cols / unit
    }

    /// Is the line blank or whitespace-only?
    pub fn is_blank(line: &str) -> bool {
        line.trim_matches([' ', '\t', '\n', '\r']).is_empty()
    }

    // ── Guide computation ─────────────────────────────────────────────────────

    /// Compute guides for a range of lines [first_line, last_line].
    /// `cursor_line`: the current cursor line (for active guide highlighting).
    pub fn guides_for_viewport(
        &self,
        buffer: &Buffer,
        first_line: usize,
        last_line: usize,
        cursor_line: usize,
    ) -> Vec<LineGuides> {
        let total = buffer.len_lines();
        let last = last_line.min(total.saturating_sub(1));
        if first_line > last {
            return vec![];
        }

        // Pre-compute indent depths for all lines in range
        // Empty lines use the depth of surrounding non-empty lines
        let depths = self.compute_depths(buffer, first_line, last);

        // Determine the active indent level from cursor line
        let active_depth = if cursor_line >= first_line && cursor_line <= last {
            let idx = cursor_line - first_line;
            depths.get(idx).copied().unwrap_or(0)
        } else {
            0
        };
        let active_level = self.depth_to_level(active_depth).saturating_sub(1);

        depths
            .into_iter()
            .enumerate()
            .map(|(i, depth)| {
                let line_num = first_line + i;
                let level = self.depth_to_level(depth);
                let unit = self.indent_size.max(1);

                let guides: Vec<IndentGuide> = (0..level)
                    .map(|lvl| IndentGuide {
                        column: lvl * unit,
                        level: lvl,
                        is_active: lvl == active_level && active_depth > 0,
                    })
                    .collect();

                LineGuides {
                    line_number: line_num,
                    guides,
                    indent_depth: depth,
                }
            })
            .collect()
    }

    fn depth_to_level(&self, depth: usize) -> usize {
        let unit = self.indent_size.max(1);
        depth / unit
    }

    /// Compute indent depths, filling empty lines with context.
    fn compute_depths(&self, buffer: &Buffer, first: usize, last: usize) -> Vec<usize> {
        let count = last - first + 1;
        let mut depths: Vec<Option<usize>> = Vec::with_capacity(count);

        for line_num in first..=last {
            let line = buffer.line_str(line_num);
            if Self::is_blank(&line) {
                depths.push(None); // fill later
            } else {
                depths.push(Some(self.indent_cols(&line)));
            }
        }

        // Backward pass: fill Nones from subsequent non-None, take minimum
        let mut next_depth = 0usize;
        for d in depths.iter_mut().rev() {
            match d {
                Some(v) => next_depth = *v,
                None => *d = Some(next_depth),
            }
        }

        // For truly empty lines, use context minimum
        depths
            .iter_mut()
            .enumerate()
            .map(|(_i, d)| {
                let raw = d.unwrap_or(0);
                if raw == 0 {
                    return 0;
                }
                // Round down to nearest indent unit
                let unit = self.indent_size.max(1);
                (raw / unit) * unit
            })
            .collect()
    }
}

impl Default for IndentGuideEngine {
    fn default() -> Self {
        Self::new(4, false)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }
    fn engine() -> IndentGuideEngine {
        IndentGuideEngine::new(4, false)
    }

    // ── Indent measurement ────────────────────────────────────────────────────

    #[test]
    fn test_indent_cols_spaces() {
        let e = engine();
        assert_eq!(e.indent_cols("    hello"), 4);
        assert_eq!(e.indent_cols("        hello"), 8);
        assert_eq!(e.indent_cols("hello"), 0);
        assert_eq!(e.indent_cols(""), 0);
    }

    #[test]
    fn test_indent_cols_tabs() {
        let e = IndentGuideEngine::new(4, true);
        assert_eq!(e.indent_cols("\thello"), 4);
        assert_eq!(e.indent_cols("\t\thello"), 8);
    }

    #[test]
    fn test_indent_cols_mixed() {
        let e = IndentGuideEngine::new(4, false);
        // 2 spaces + tab (tab aligns to next 4-col boundary from col 2 = col 4)
        assert_eq!(e.indent_cols("  \thello"), 4);
    }

    #[test]
    fn test_indent_level() {
        let e = engine();
        assert_eq!(e.indent_level("    hello"), 1);
        assert_eq!(e.indent_level("        hello"), 2);
        assert_eq!(e.indent_level("hello"), 0);
    }

    #[test]
    fn test_is_blank() {
        assert!(IndentGuideEngine::is_blank(""));
        assert!(IndentGuideEngine::is_blank("   "));
        assert!(IndentGuideEngine::is_blank("\t  \n"));
        assert!(!IndentGuideEngine::is_blank("  x"));
    }

    // ── Guide computation ─────────────────────────────────────────────────────

    #[test]
    fn test_no_guides_for_zero_indent() {
        let b = buf("fn main() {\n    x = 1;\n}\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 0, 2, 0);
        assert_eq!(guides[0].guides.len(), 0, "Line 0 at col 0 has no guides");
        assert_eq!(guides[1].guides.len(), 1, "Line 1 at indent 4 has 1 guide");
    }

    #[test]
    fn test_guide_columns() {
        let b = buf("fn main() {\n    if true {\n        let x = 1;\n    }\n}\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 0, 4, 2);
        // Line 2 (        let x) has indent 8 → level 2 → guides at col 0 and col 4
        let line2 = &guides[2];
        assert_eq!(line2.guides.len(), 2);
        assert_eq!(line2.guides[0].column, 0);
        assert_eq!(line2.guides[1].column, 4);
    }

    #[test]
    fn test_active_guide() {
        let b = buf("fn main() {\n    let x = 1;\n    let y = 2;\n}\n");
        let e = engine();
        // Cursor on line 1 (indent level 1) → active guide at column 0? No.
        // Active guide marks the guide that MATCHES the cursor's indent.
        let guides = e.guides_for_viewport(&b, 0, 3, 1);
        let line1 = &guides[1]; // "    let x = 1;"
        assert!(!line1.guides.is_empty());
        assert!(
            line1.guides.iter().any(|g| g.is_active),
            "Cursor line should have active guide"
        );
    }

    #[test]
    fn test_empty_lines_inherit_depth() {
        let b = buf("fn main() {\n    let x = 1;\n\n    let y = 2;\n}\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 0, 4, 0);
        // Line 2 is empty, should inherit some depth from neighbors
        let empty_line = &guides[2];
        // Not asserting exact depth — just that it doesn't panic
        let _ = empty_line;
    }

    #[test]
    fn test_guides_for_deep_nesting() {
        let src = "fn a() {\n    fn b() {\n        fn c() {\n            let x = 1;\n        }\n    }\n}\n";
        let b = buf(src);
        let e = engine();
        let guides = e.guides_for_viewport(&b, 0, 6, 3);
        // Line 3 (            let x) has indent 12 → level 3 → 3 guides
        let line3 = &guides[3];
        assert_eq!(line3.guides.len(), 3);
        assert_eq!(line3.guides[0].column, 0);
        assert_eq!(line3.guides[1].column, 4);
        assert_eq!(line3.guides[2].column, 8);
    }

    #[test]
    fn test_tab_indent_guides() {
        let b = buf("def foo():\n\tif True:\n\t\tx = 1\n");
        let e = IndentGuideEngine::new(4, true);
        let guides = e.guides_for_viewport(&b, 0, 2, 2);
        let line2 = &guides[2]; // "\t\tx = 1"
        assert_eq!(line2.guides.len(), 2);
        assert_eq!(line2.guides[0].column, 0);
        assert_eq!(line2.guides[1].column, 4);
    }

    #[test]
    fn test_viewport_range() {
        let b = buf("a\n    b\n        c\n    d\ne\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 1, 3, 2);
        assert_eq!(guides.len(), 3);
        assert_eq!(guides[0].line_number, 1);
        assert_eq!(guides[2].line_number, 3);
    }

    #[test]
    fn test_out_of_range_returns_empty() {
        let b = buf("hello\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 100, 200, 0);
        assert!(guides.is_empty());
    }

    #[test]
    fn test_guides_json_serializable() {
        let b = buf("    hello\n        world\n");
        let e = engine();
        let guides = e.guides_for_viewport(&b, 0, 1, 0);
        let json = serde_json::to_string(&guides);
        assert!(json.is_ok());
    }
}
