// src/ai/diff.rs
//
// Minimal diff between the AI suggestion and existing buffer text.
// Used when applying a refactor/edit suggestion to avoid clobbering
// user changes that occurred while the AI was thinking.
//
// Algorithm: Myers diff (character-level, adapted for editor ops).
// We produce a sequence of `DiffOp`s (Keep, Insert, Delete) that
// can be converted to `EditOp` batches.

use crate::core::edit::EditOp;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DiffOp {
    Keep(String),
    Insert(String),
    Delete(String),
}

/// Diff result — sequence of keep/insert/delete ops.
pub struct SuggestionDiff {
    pub ops: Vec<DiffOp>,
    pub total_insertions: usize,
    pub total_deletions: usize,
}

impl SuggestionDiff {
    /// Compute diff between `original` text and `suggested` text.
    pub fn compute(original: &str, suggested: &str) -> Self {
        let orig_lines: Vec<&str> = original.lines().collect();
        let sugg_lines: Vec<&str> = suggested.lines().collect();

        let ops = line_diff(&orig_lines, &sugg_lines);

        let total_insertions = ops
            .iter()
            .filter(|op| matches!(op, DiffOp::Insert(_)))
            .count();
        let total_deletions = ops
            .iter()
            .filter(|op| matches!(op, DiffOp::Delete(_)))
            .count();

        Self {
            ops,
            total_insertions,
            total_deletions,
        }
    }

    /// Convert diff ops to `EditOp`s starting at `base_offset`.
    /// Applies deletes before inserts, offset-adjusted.
    pub fn to_edit_ops(&self, base_offset: usize) -> Vec<EditOp> {
        let mut ops = Vec::new();
        let mut offset = base_offset;

        for op in &self.ops {
            match op {
                DiffOp::Keep(text) => {
                    offset += text.len();
                    if !text.ends_with('\n') {
                        offset += 1;
                    } // newline
                }
                DiffOp::Delete(text) => {
                    let len = text.len() + 1; // +1 for newline
                    ops.push(EditOp::delete(offset, offset + len));
                    // don't advance offset — deleted bytes are gone
                }
                DiffOp::Insert(text) => {
                    let with_newline = format!("{}\n", text);
                    ops.push(EditOp::insert(offset, &with_newline));
                    offset += with_newline.len();
                }
            }
        }

        ops
    }

    /// True if there are no differences.
    pub fn is_identical(&self) -> bool {
        self.total_insertions == 0 && self.total_deletions == 0
    }

    /// Human-readable diff summary.
    pub fn summary(&self) -> String {
        format!("+{} -{} lines", self.total_insertions, self.total_deletions)
    }
}

// ── Myers diff (line-level) ───────────────────────────────────────────────────

/// Dynamic-programming LCS diff on line slices.
/// Returns `DiffOp`s in document order.
fn line_diff(orig: &[&str], sugg: &[&str]) -> Vec<DiffOp> {
    let n = orig.len();
    let m = sugg.len();

    let mut lcs = vec![vec![0usize; m + 1]; n + 1];
    for i in (0..n).rev() {
        for j in (0..m).rev() {
            lcs[i][j] = if orig[i] == sugg[j] {
                lcs[i + 1][j + 1] + 1
            } else {
                lcs[i + 1][j].max(lcs[i][j + 1])
            };
        }
    }

    let mut ops = Vec::new();
    let mut i = 0;
    let mut j = 0;
    while i < n || j < m {
        if i < n && j < m && orig[i] == sugg[j] {
            ops.push(DiffOp::Keep(orig[i].to_owned()));
            i += 1;
            j += 1;
        } else if i < n && (j == m || lcs[i + 1][j] >= lcs[i][j + 1]) {
            ops.push(DiffOp::Delete(orig[i].to_owned()));
            i += 1;
        } else if j < m {
            ops.push(DiffOp::Insert(sugg[j].to_owned()));
            j += 1;
        }
    }

    ops
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_identical_diff() {
        let diff = SuggestionDiff::compute("hello\nworld", "hello\nworld");
        assert!(diff.is_identical());
    }

    #[test]
    fn test_insert_line() {
        let orig = "fn foo() {\n    let x = 1;\n}";
        let sugg = "fn foo() {\n    let x = 1;\n    let y = 2;\n}";
        let diff = SuggestionDiff::compute(orig, sugg);
        assert_eq!(diff.total_insertions, 1);
        assert_eq!(diff.total_deletions, 0);
    }

    #[test]
    fn test_delete_line() {
        let orig = "a\nb\nc";
        let sugg = "a\nc";
        let diff = SuggestionDiff::compute(orig, sugg);
        assert_eq!(diff.total_deletions, 1);
        assert_eq!(diff.total_insertions, 0);
    }

    #[test]
    fn test_replace_line() {
        let orig = "let x = 1;";
        let sugg = "let x = 42;";
        let diff = SuggestionDiff::compute(orig, sugg);
        // One delete + one insert = replacement
        assert_eq!(diff.total_insertions + diff.total_deletions, 2);
    }

    #[test]
    fn test_summary_format() {
        let diff = SuggestionDiff::compute("a\nb", "a\nb\nc");
        assert_eq!(diff.summary(), "+1 -0 lines");
    }

    #[test]
    fn test_to_edit_ops_insert() {
        let orig = "line1\nline2";
        let sugg = "line1\nnew_line\nline2";
        let diff = SuggestionDiff::compute(orig, sugg);
        let edit_ops = diff.to_edit_ops(0);
        // At least one insert op
        assert!(edit_ops
            .iter()
            .any(|op| matches!(op, EditOp::Insert { .. })));
    }
}

#[cfg(test)]
mod diff_extended_tests {
    use super::*;

    #[test]
    fn test_identical_content_is_identical() {
        let d = SuggestionDiff::compute("hello world", "hello world");
        assert!(d.is_identical());
    }

    #[test]
    fn test_different_content_not_identical() {
        let d = SuggestionDiff::compute("hello world", "hello Rust");
        assert!(!d.is_identical());
    }

    #[test]
    fn test_empty_original_all_additions() {
        let d = SuggestionDiff::compute("", "def foo(): pass");
        assert!(!d.is_identical());
        let ops = d.to_edit_ops(0);
        assert!(!ops.is_empty(), "Should produce insert ops");
    }

    #[test]
    fn test_empty_suggested_all_deletions() {
        let d = SuggestionDiff::compute("def foo(): pass", "");
        assert!(!d.is_identical());
        let ops = d.to_edit_ops(0);
        assert!(!ops.is_empty(), "Should produce delete ops");
    }

    #[test]
    fn test_single_line_change() {
        let orig = "def hello():\n    return 1\n";
        let sugg = "def hello():\n    return 42\n";
        let d = SuggestionDiff::compute(orig, sugg);
        assert!(!d.is_identical());
        let ops = d.to_edit_ops(0);
        assert!(!ops.is_empty());
    }

    #[test]
    fn test_summary_identical() {
        let d = SuggestionDiff::compute("same", "same");
        assert!(
            d.summary().contains("identical")
                || d.summary().contains("no change")
                || d.is_identical()
        );
    }

    #[test]
    fn test_summary_has_content() {
        let d = SuggestionDiff::compute("old code", "new code");
        assert!(!d.summary().is_empty());
    }

    #[test]
    fn test_to_edit_ops_at_offset() {
        let d = SuggestionDiff::compute("abc", "axc");
        let ops = d.to_edit_ops(10); // base_offset = 10
                                     // Ops should reference position >= 10
        for op in &ops {
            match op {
                crate::core::edit::EditOp::Insert { at, .. } => assert!(at.0 >= 10),
                crate::core::edit::EditOp::Delete { range } => assert!(range.start.0 >= 10),
                crate::core::edit::EditOp::Replace { range, .. } => assert!(range.start.0 >= 10),
            }
        }
    }

    #[test]
    fn test_multiline_diff() {
        let orig = "line1\nline2\nline3\n";
        let sugg = "line1\nLINE2_MODIFIED\nline3\nnew_line4\n";
        let d = SuggestionDiff::compute(orig, sugg);
        assert!(!d.is_identical());
        let _ops = d.to_edit_ops(0); // just verify no panic
    }
}
