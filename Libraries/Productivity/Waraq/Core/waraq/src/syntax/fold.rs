// src/syntax/fold.rs
//
// Code folding — computes foldable ranges from the syntax structure.
//
// Sources of fold ranges (in priority order):
//   1. Explicit fold markers   — `// #region` / `// #endregion`
//   2. Bracket-based folds     — { ... } [ ... ] ( ... )
//   3. Indentation-based folds — Python/YAML/Markdown style
//   4. Comment blocks          — consecutive `//` or `/* ... */` lines
//
// FoldRange is serialised for the renderer — the renderer draws the ▶ widget.

use crate::core::buffer::Buffer;
use serde::{Deserialize, Serialize};

// ── Fold range ────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum FoldKind {
    Region,   // #region / #endregion
    Brackets, // { } [ ] ( )
    Indent,   // indent-based (Python, YAML)
    Comment,  // block of line comments
    Import,   // group of import statements
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FoldRange {
    /// First line of the foldable range (0-based, inclusive).
    /// The fold widget appears on this line.
    pub start_line: usize,
    /// Last line of the foldable range (0-based, inclusive).
    pub end_line: usize,
    pub kind: FoldKind,
    /// Whether this range is currently collapsed.
    pub collapsed: bool,
}

impl FoldRange {
    pub fn line_count(&self) -> usize {
        self.end_line.saturating_sub(self.start_line) + 1
    }

    pub fn is_valid(&self) -> bool {
        self.end_line > self.start_line
    }
}

// ── Fold state ────────────────────────────────────────────────────────────────

pub struct FoldState {
    ranges: Vec<FoldRange>,
}

impl FoldState {
    pub fn new() -> Self {
        Self { ranges: Vec::new() }
    }

    pub fn compute(buf: &Buffer, language: &str) -> Self {
        let ranges = compute_fold_ranges(buf, language);
        Self { ranges }
    }

    pub fn all(&self) -> &[FoldRange] {
        &self.ranges
    }

    /// Ranges that affect the visible viewport.
    pub fn for_viewport(&self, first_line: usize, last_line: usize) -> Vec<&FoldRange> {
        self.ranges
            .iter()
            .filter(|r| r.start_line >= first_line && r.start_line <= last_line)
            .collect()
    }

    pub fn toggle(&mut self, start_line: usize) {
        if let Some(r) = self.ranges.iter_mut().find(|r| r.start_line == start_line) {
            r.collapsed = !r.collapsed;
        }
    }

    pub fn expand_all(&mut self) {
        for r in &mut self.ranges {
            r.collapsed = false;
        }
    }

    pub fn collapse_all(&mut self) {
        for r in &mut self.ranges {
            r.collapsed = true;
        }
    }

    /// Collapse all import blocks.
    pub fn collapse_imports(&mut self) {
        for r in &mut self.ranges {
            if r.kind == FoldKind::Import {
                r.collapsed = true;
            }
        }
    }

    /// Which lines are hidden due to a collapsed fold?
    /// Returns a sorted list of hidden line numbers.
    pub fn hidden_lines(&self) -> Vec<usize> {
        let mut hidden = Vec::new();
        for range in &self.ranges {
            if range.collapsed {
                for line in (range.start_line + 1)..=range.end_line {
                    hidden.push(line);
                }
            }
        }
        hidden.sort_unstable();
        hidden.dedup();
        hidden
    }

    /// True if `line` is hidden by a collapsed fold.
    pub fn is_line_hidden(&self, line: usize) -> bool {
        self.ranges
            .iter()
            .any(|r| r.collapsed && line > r.start_line && line <= r.end_line)
    }

    /// After a buffer edit, remove ranges that are now invalid.
    pub fn invalidate_range(&mut self, first_line: usize, last_line: usize) {
        self.ranges
            .retain(|r| r.start_line < first_line || r.start_line > last_line);
    }
}

impl Default for FoldState {
    fn default() -> Self {
        Self::new()
    }
}

// ── Range computation ─────────────────────────────────────────────────────────

fn compute_fold_ranges(buf: &Buffer, language: &str) -> Vec<FoldRange> {
    let mut ranges = Vec::new();

    ranges.extend(find_region_markers(buf));
    ranges.extend(find_bracket_folds(buf, language));
    ranges.extend(find_import_blocks(buf, language));
    ranges.extend(find_comment_blocks(buf, language));

    if is_indent_based(language) {
        ranges.extend(find_indent_folds(buf));
    }

    // Sort by start line, deduplicate overlapping ranges
    ranges.sort_by_key(|r| (r.start_line, r.end_line));
    dedup_ranges(ranges)
}

fn is_indent_based(language: &str) -> bool {
    matches!(language, "python" | "yaml" | "markdown" | "toml")
}

/// Find `// #region` ... `// #endregion` style markers.
fn find_region_markers(buf: &Buffer) -> Vec<FoldRange> {
    let mut ranges = Vec::new();
    let mut stack: Vec<usize> = Vec::new();
    let region_open = ["#region", "region", "REGION"];
    let region_close = ["#endregion", "endregion", "ENDREGION"];

    for line_num in 0..buf.len_lines() {
        let line = buf.line_str(line_num);
        let trimmed = line.trim();

        // Strip comment prefix
        let content = trimmed
            .trim_start_matches("//")
            .trim_start_matches('#')
            .trim_start_matches("<!--")
            .trim();

        if region_open.iter().any(|&m| content.starts_with(m)) {
            stack.push(line_num);
        } else if region_close.iter().any(|&m| content.starts_with(m)) {
            if let Some(start) = stack.pop() {
                if line_num > start {
                    ranges.push(FoldRange {
                        start_line: start,
                        end_line: line_num,
                        kind: FoldKind::Region,
                        collapsed: false,
                    });
                }
            }
        }
    }
    ranges
}

/// Find { } bracket-based folds (for brace-based languages).
fn find_bracket_folds(buf: &Buffer, language: &str) -> Vec<FoldRange> {
    if is_indent_based(language) {
        return Vec::new();
    }

    let mut ranges = Vec::new();
    let mut stack: Vec<(usize, char)> = Vec::new(); // (line_num, open_char)

    for line_num in 0..buf.len_lines() {
        let line = buf.line_str(line_num);
        // Skip string contents (simplified — just look at line ends)
        let trimmed = line.trim_end();
        if let Some(last_ch) = trimmed.chars().last() {
            if last_ch == '{' || last_ch == '[' {
                stack.push((line_num, last_ch));
            }
        }
        let closer = trimmed.trim_start().chars().next();
        if closer == Some('}') || closer == Some(']') {
            if let Some((start_line, _)) = stack.pop() {
                if line_num > start_line + 1 {
                    // only fold if >1 line
                    ranges.push(FoldRange {
                        start_line,
                        end_line: line_num,
                        kind: FoldKind::Brackets,
                        collapsed: false,
                    });
                }
            }
        }
    }
    ranges
}

/// Find groups of import/use statements.
fn find_import_blocks(buf: &Buffer, language: &str) -> Vec<FoldRange> {
    let import_prefix: &[&str] = match language {
        "rust" => &["use "],
        "javascript" | "typescript" => &["import "],
        "python" => &["import ", "from "],
        "java" | "kotlin" => &["import "],
        "go" => &["import "],
        _ => return Vec::new(),
    };

    let mut ranges = Vec::new();
    let mut start: Option<usize> = None;
    let mut last_import = 0usize;

    for line_num in 0..buf.len_lines() {
        let line = buf.line_str(line_num);
        let trimmed = line.trim();
        let is_import = import_prefix.iter().any(|p| trimmed.starts_with(p));
        let is_blank = trimmed.is_empty();

        if is_import {
            if start.is_none() {
                start = Some(line_num);
            }
            last_import = line_num;
        } else if !is_blank && start.is_some() {
            // Block ended
            let block_start = start.take().unwrap();
            if last_import > block_start {
                ranges.push(FoldRange {
                    start_line: block_start,
                    end_line: last_import,
                    kind: FoldKind::Import,
                    collapsed: false,
                });
            }
        }
    }
    if let Some(block_start) = start {
        if last_import > block_start {
            ranges.push(FoldRange {
                start_line: block_start,
                end_line: last_import,
                kind: FoldKind::Import,
                collapsed: false,
            });
        }
    }
    ranges
}

/// Find blocks of consecutive line comments.
fn find_comment_blocks(buf: &Buffer, language: &str) -> Vec<FoldRange> {
    let comment_prefix = match language {
        "rust" | "javascript" | "typescript" | "java" | "kotlin" | "go" | "c" | "cpp" | "swift" => {
            "//"
        }
        "python" | "ruby" | "bash" => "#",
        _ => return Vec::new(),
    };

    let mut ranges = Vec::new();
    let mut start: Option<usize> = None;
    let mut last_comment = 0usize;

    for line_num in 0..buf.len_lines() {
        let line = buf.line_str(line_num);
        let trimmed = line.trim();
        let is_comment = trimmed.starts_with(comment_prefix);

        if is_comment {
            if start.is_none() {
                start = Some(line_num);
            }
            last_comment = line_num;
        } else if !trimmed.is_empty() && start.is_some() {
            let block_start = start.take().unwrap();
            if last_comment >= block_start + 2 {
                // Only fold if 3+ comment lines
                ranges.push(FoldRange {
                    start_line: block_start,
                    end_line: last_comment,
                    kind: FoldKind::Comment,
                    collapsed: false,
                });
            }
        }
    }
    ranges
}

/// Indentation-based folds for Python/YAML/etc.
fn find_indent_folds(buf: &Buffer) -> Vec<FoldRange> {
    let mut ranges = Vec::new();
    let total = buf.len_lines();
    let mut i = 0;

    while i < total {
        let line = buf.line_str(i);
        if line.trim().is_empty() {
            i += 1;
            continue;
        }

        let indent = line.chars().take_while(|c| *c == ' ' || *c == '\t').count();

        // Find the end of this indented block
        let mut end = i;
        let mut j = i + 1;
        while j < total {
            let jline = buf.line_str(j);
            if jline.trim().is_empty() {
                j += 1;
                continue;
            }
            let jind = jline
                .chars()
                .take_while(|c| *c == ' ' || *c == '\t')
                .count();
            if jind <= indent {
                break;
            }
            end = j;
            j += 1;
        }

        if end > i + 1 {
            ranges.push(FoldRange {
                start_line: i,
                end_line: end,
                kind: FoldKind::Indent,
                collapsed: false,
            });
        }
        i += 1;
    }
    ranges
}

fn dedup_ranges(mut ranges: Vec<FoldRange>) -> Vec<FoldRange> {
    ranges.dedup_by(|a, b| a.start_line == b.start_line && a.end_line == b.end_line);
    ranges
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_bracket_folds_rust() {
        let src = "fn main() {\n    let x = 1;\n    let y = 2;\n}\n";
        let b = buf(src);
        let state = FoldState::compute(&b, "rust");
        let bracket_folds: Vec<_> = state
            .all()
            .iter()
            .filter(|r| r.kind == FoldKind::Brackets)
            .collect();
        assert!(!bracket_folds.is_empty());
        assert_eq!(bracket_folds[0].start_line, 0);
        assert_eq!(bracket_folds[0].end_line, 3);
    }

    #[test]
    fn test_import_fold_rust() {
        let src =
            "use std::collections::HashMap;\nuse anyhow::Result;\nuse std::io;\n\nfn main() {}\n";
        let b = buf(src);
        let state = FoldState::compute(&b, "rust");
        let import_folds: Vec<_> = state
            .all()
            .iter()
            .filter(|r| r.kind == FoldKind::Import)
            .collect();
        assert!(!import_folds.is_empty());
        assert_eq!(import_folds[0].start_line, 0);
        assert_eq!(import_folds[0].end_line, 2);
    }

    #[test]
    fn test_comment_fold() {
        let src = "// This is a very long\n// multi-line comment block\n// that should be foldable\nfn foo() {}\n";
        let b = buf(src);
        let state = FoldState::compute(&b, "rust");
        let comment_folds: Vec<_> = state
            .all()
            .iter()
            .filter(|r| r.kind == FoldKind::Comment)
            .collect();
        assert!(!comment_folds.is_empty());
    }

    #[test]
    fn test_region_markers() {
        let src = "fn main() {\n    // #region setup\n    let x = 1;\n    let y = 2;\n    // #endregion\n}\n";
        let b = buf(src);
        let state = FoldState::compute(&b, "rust");
        let regions: Vec<_> = state
            .all()
            .iter()
            .filter(|r| r.kind == FoldKind::Region)
            .collect();
        assert!(!regions.is_empty());
        assert_eq!(regions[0].start_line, 1);
        assert_eq!(regions[0].end_line, 4);
    }

    #[test]
    fn test_toggle_and_hidden_lines() {
        let src = "fn main() {\n    let x = 1;\n    let y = 2;\n}\n";
        let b = buf(src);
        let mut state = FoldState::compute(&b, "rust");

        let start_line = state
            .all()
            .iter()
            .find(|r| r.kind == FoldKind::Brackets)
            .map(|r| r.start_line)
            .unwrap();

        state.toggle(start_line);
        assert!(!state.hidden_lines().is_empty());

        state.toggle(start_line);
        assert!(state.hidden_lines().is_empty());
    }

    #[test]
    fn test_expand_all_collapse_all() {
        let src = "fn foo() {\n    let a = 1;\n}\nfn bar() {\n    let b = 2;\n}\n";
        let b = buf(src);
        let mut state = FoldState::compute(&b, "rust");

        state.collapse_all();
        for r in state.all() {
            assert!(r.collapsed);
        }

        state.expand_all();
        for r in state.all() {
            assert!(!r.collapsed);
        }
    }

    #[test]
    fn test_indent_folds_python() {
        let src = "def foo():\n    x = 1\n    y = 2\n\ndef bar():\n    z = 3\n";
        let b = buf(src);
        let state = FoldState::compute(&b, "python");
        let indent_folds: Vec<_> = state
            .all()
            .iter()
            .filter(|r| r.kind == FoldKind::Indent)
            .collect();
        assert!(!indent_folds.is_empty());
    }

    #[test]
    fn test_is_line_hidden() {
        let src = "fn main() {\n    let x = 1;\n    let y = 2;\n}\n";
        let b = buf(src);
        let mut state = FoldState::compute(&b, "rust");

        let start = state
            .all()
            .iter()
            .find(|r| r.kind == FoldKind::Brackets)
            .map(|r| r.start_line)
            .unwrap();

        assert!(!state.is_line_hidden(start + 1));
        state.toggle(start);
        assert!(state.is_line_hidden(start + 1));
    }
}
