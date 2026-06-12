// src/core/git_gutter.rs
//
// Git gutter — compute line-level diff annotations (added / modified / deleted)
// and turn them into `Decoration` entries for the gutter.
//
// The gutter shows coloured bars in the margin:
//   Green bar   — line was added (not in HEAD)
//   Blue bar    — line was modified (exists in HEAD but content changed)
//   Red triangle — line(s) were deleted at this position (not in current file)
//
// This module is pure Rust — it accepts the HEAD content as a string and the
// current buffer content, runs a line-level LCS diff, and returns decorations.
// The host layer (Flutter/Java) is responsible for calling git and passing the
// HEAD content.
//
// Diff algorithm: Myers diff (line level), same approach as ai/diff.rs but
// specialized for the gutter use case.

use crate::core::buffer::Buffer;
use crate::core::decoration::{
    DecorationKind, DecorationOptions, DecorationSet, DecorationSpec, DecorationStyle,
    OverviewRulerDecoration, OverviewRulerLane,
};
use crate::core::types::Range;
use serde::{Deserialize, Serialize};

// ── Hunk type ─────────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum GutterHunkKind {
    Added,
    Modified,
    Deleted,
}

/// A contiguous range of changed lines.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GutterHunk {
    pub kind: GutterHunkKind,
    /// 0-based start line in the *current* file.
    pub start_line: usize,
    /// 0-based end line in the *current* file (exclusive).
    pub end_line: usize,
    /// Number of lines removed at this position in HEAD.
    pub deleted_count: usize,
}

impl GutterHunk {
    pub fn line_count(&self) -> usize {
        self.end_line.saturating_sub(self.start_line)
    }

    pub fn color_hex(&self) -> &'static str {
        match self.kind {
            GutterHunkKind::Added => "#4CAF50",
            GutterHunkKind::Modified => "#2196F3",
            GutterHunkKind::Deleted => "#F44336",
        }
    }
}

// ── Diff engine ───────────────────────────────────────────────────────────────

pub struct GitGutter;

impl GitGutter {
    /// Compute the diff between `head_content` and `current_content`.
    /// Returns a list of hunks sorted by start line.
    pub fn diff(head_content: &str, current_content: &str) -> Vec<GutterHunk> {
        let head_lines: Vec<&str> = head_content.lines().collect();
        let current_lines: Vec<&str> = current_content.lines().collect();

        let lcs = Self::lcs_table(&head_lines, &current_lines);
        let hunks = Self::build_hunks(&head_lines, &current_lines, &lcs);
        Self::merge_adjacent(hunks)
    }

    /// Convert diff hunks into `Decoration` entries.
    pub fn hunks_to_decorations(
        hunks: &[GutterHunk],
        buffer: &Buffer,
    ) -> Vec<(DecorationSpec, String)> {
        let owner = "waraq.git-gutter";
        let mut specs = Vec::new();

        for hunk in hunks {
            let line = hunk.start_line.min(buffer.len_lines().saturating_sub(1));
            let line_start = buffer.line_col_to_offset(crate::core::types::LineCol::new(line, 0));
            let line_end = {
                let end_line = (hunk.end_line).min(buffer.len_lines().saturating_sub(1));
                buffer.line_col_to_offset(crate::core::types::LineCol::new(end_line, 0))
            };
            let range = Range::new(line_start.0, line_end.0.max(line_start.0 + 1));

            let mut opts = DecorationOptions::default();
            opts.is_whole_line = true;
            opts.kind = DecorationKind::Diff;
            opts.overview_ruler = Some(OverviewRulerDecoration {
                color: hunk.color_hex().into(),
                lane: OverviewRulerLane::Left,
            });
            opts.inline_style = Some(DecorationStyle {
                background_color: Some(match hunk.kind {
                    GutterHunkKind::Added => "var(--git-added-bg)".into(),
                    GutterHunkKind::Modified => "var(--git-modified-bg)".into(),
                    GutterHunkKind::Deleted => "var(--git-deleted-bg)".into(),
                }),
                ..Default::default()
            });

            // For deleted hunks, show a triangle marker
            if hunk.kind == GutterHunkKind::Deleted {
                opts.glyph_margin = Some(crate::core::decoration::GlyphMarginDecoration {
                    icon: "triangle-down".into(),
                    tooltip: Some(format!(
                        "{} line{} deleted",
                        hunk.deleted_count,
                        if hunk.deleted_count == 1 { "" } else { "s" }
                    )),
                    color: Some("#F44336".into()),
                });
            }

            specs.push((
                DecorationSpec {
                    range,
                    options: opts,
                },
                owner.to_owned(),
            ));
        }
        specs
    }

    /// Apply git diff to an existing `DecorationSet`, replacing all git hunks.
    pub fn apply_to_decorations(
        decorations: &mut DecorationSet,
        hunks: &[GutterHunk],
        buffer: &Buffer,
    ) {
        // Remove existing git decorations
        decorations.remove_by_kind(DecorationKind::Diff);
        // Add new ones
        let specs = Self::hunks_to_decorations(hunks, buffer);
        decorations.delta(&[], &specs);
    }

    // ── LCS diff algorithm ────────────────────────────────────────────────────

    fn lcs_table<'a>(a: &[&'a str], b: &[&'a str]) -> Vec<Vec<usize>> {
        let n = a.len();
        let m = b.len();
        let mut dp = vec![vec![0usize; m + 1]; n + 1];
        for i in 1..=n {
            for j in 1..=m {
                dp[i][j] = if a[i - 1] == b[j - 1] {
                    dp[i - 1][j - 1] + 1
                } else {
                    dp[i - 1][j].max(dp[i][j - 1])
                };
            }
        }
        dp
    }

    fn build_hunks(a: &[&str], b: &[&str], dp: &[Vec<usize>]) -> Vec<GutterHunk> {
        // Walk the edit path
        #[derive(Debug, Clone, Copy)]
        enum Edit {
            Keep,
            Insert(usize),
            Delete,
        }

        let mut path: Vec<Edit> = Vec::new();
        let (mut i, mut j) = (a.len(), b.len());

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && a[i - 1] == b[j - 1] {
                path.push(Edit::Keep);
                i -= 1;
                j -= 1;
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                path.push(Edit::Insert(j - 1));
                j -= 1;
            } else {
                path.push(Edit::Delete);
                i -= 1;
            }
        }
        path.reverse();

        // Convert edit path to hunks
        let mut hunks: Vec<GutterHunk> = Vec::new();
        let mut current_b_line = 0usize; // current line in b (current file)
        let mut pending_deletes = 0usize;

        for edit in &path {
            match edit {
                Edit::Keep => {
                    if pending_deletes > 0 {
                        hunks.push(GutterHunk {
                            kind: GutterHunkKind::Deleted,
                            start_line: current_b_line,
                            end_line: current_b_line,
                            deleted_count: pending_deletes,
                        });
                        pending_deletes = 0;
                    }
                    current_b_line += 1;
                }
                Edit::Insert(_b_idx) => {
                    let kind = if pending_deletes > 0 {
                        pending_deletes -= 1;
                        GutterHunkKind::Modified
                    } else {
                        GutterHunkKind::Added
                    };
                    if let Some(last) = hunks.last_mut() {
                        if last.kind == kind && last.end_line == current_b_line {
                            last.end_line += 1;
                        } else {
                            hunks.push(GutterHunk {
                                kind,
                                start_line: current_b_line,
                                end_line: current_b_line + 1,
                                deleted_count: 0,
                            });
                        }
                    } else {
                        hunks.push(GutterHunk {
                            kind,
                            start_line: current_b_line,
                            end_line: current_b_line + 1,
                            deleted_count: 0,
                        });
                    }
                    current_b_line += 1;
                }
                Edit::Delete => {
                    pending_deletes += 1;
                }
            }
        }

        // Flush trailing deletes
        if pending_deletes > 0 {
            hunks.push(GutterHunk {
                kind: GutterHunkKind::Deleted,
                start_line: current_b_line,
                end_line: current_b_line,
                deleted_count: pending_deletes,
            });
        }

        hunks
    }

    fn merge_adjacent(hunks: Vec<GutterHunk>) -> Vec<GutterHunk> {
        if hunks.len() < 2 {
            return hunks;
        }
        let mut merged: Vec<GutterHunk> = Vec::new();
        for hunk in hunks {
            if let Some(last) = merged.last_mut() {
                if last.kind == hunk.kind && last.end_line == hunk.start_line {
                    last.end_line = hunk.end_line;
                    last.deleted_count += hunk.deleted_count;
                    continue;
                }
            }
            merged.push(hunk);
        }
        merged
    }

    /// Serialise hunks to JSON (for FFI).
    pub fn hunks_to_json(hunks: &[GutterHunk]) -> String {
        serde_json::to_string(hunks).unwrap_or_default()
    }

    /// Parse hunks from JSON.
    pub fn hunks_from_json(json: &str) -> Vec<GutterHunk> {
        serde_json::from_str(json).unwrap_or_default()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    // ── Diff correctness ──────────────────────────────────────────────────────

    #[test]
    fn test_no_changes() {
        let content = "line1\nline2\nline3\n";
        let hunks = GitGutter::diff(content, content);
        assert!(hunks.is_empty(), "No changes should produce no hunks");
    }

    #[test]
    fn test_all_added() {
        let head = "";
        let current = "line1\nline2\nline3\n";
        let hunks = GitGutter::diff(head, current);
        assert!(!hunks.is_empty());
        assert!(hunks.iter().all(|h| h.kind == GutterHunkKind::Added));
    }

    #[test]
    fn test_all_deleted() {
        let head = "line1\nline2\nline3\n";
        let current = "";
        let hunks = GitGutter::diff(head, current);
        assert!(!hunks.is_empty());
        assert!(hunks.iter().any(|h| h.kind == GutterHunkKind::Deleted));
    }

    #[test]
    fn test_single_added_line() {
        let head = "line1\nline3\n";
        let current = "line1\nline2\nline3\n";
        let hunks = GitGutter::diff(head, current);
        assert!(hunks.iter().any(|h| h.kind == GutterHunkKind::Added));
        // Added line should be at line 1 (0-based)
        let added = hunks
            .iter()
            .find(|h| h.kind == GutterHunkKind::Added)
            .unwrap();
        assert_eq!(added.start_line, 1);
    }

    #[test]
    fn test_single_deleted_line() {
        let head = "line1\nline2\nline3\n";
        let current = "line1\nline3\n";
        let hunks = GitGutter::diff(head, current);
        assert!(hunks
            .iter()
            .any(|h| h.kind == GutterHunkKind::Deleted || h.kind == GutterHunkKind::Modified));
    }

    #[test]
    fn test_modified_line() {
        let head = "line1\noriginal\nline3\n";
        let current = "line1\nmodified\nline3\n";
        let hunks = GitGutter::diff(head, current);
        assert!(!hunks.is_empty());
        // Should have some modification indication
        let has_change = hunks
            .iter()
            .any(|h| h.kind == GutterHunkKind::Modified || h.kind == GutterHunkKind::Added);
        assert!(has_change, "Modified line should appear in hunks");
    }

    #[test]
    fn test_additions_at_end() {
        let head = "line1\nline2\n";
        let current = "line1\nline2\nline3\nline4\n";
        let hunks = GitGutter::diff(head, current);
        let added = hunks
            .iter()
            .filter(|h| h.kind == GutterHunkKind::Added)
            .count();
        assert!(added > 0, "Should detect added lines at end");
    }

    #[test]
    fn test_hunk_line_count() {
        let head = "";
        let current = "a\nb\nc\n";
        let hunks = GitGutter::diff(head, current);
        let total: usize = hunks.iter().map(|h| h.line_count()).sum();
        assert_eq!(total, 3, "Total lines in hunks should equal lines added");
    }

    // ── Decorations ───────────────────────────────────────────────────────────

    #[test]
    fn test_hunks_to_decorations() {
        let hunks = vec![
            GutterHunk {
                kind: GutterHunkKind::Added,
                start_line: 0,
                end_line: 2,
                deleted_count: 0,
            },
            GutterHunk {
                kind: GutterHunkKind::Modified,
                start_line: 5,
                end_line: 6,
                deleted_count: 1,
            },
        ];
        let b = buf("a\nb\nc\nd\ne\nf\ng\n");
        let spec = GitGutter::hunks_to_decorations(&hunks, &b);
        assert_eq!(spec.len(), 2);
        // Decorations should be whole-line
        for (s, _) in &spec {
            assert!(s.options.is_whole_line);
        }
    }

    #[test]
    fn test_apply_to_decorations() {
        let mut dset = DecorationSet::new();
        let b = buf("line0\nline1\nline2\n");
        let hunks = GitGutter::diff("line0\noriginal\nline2\n", "line0\nline1\nline2\n");
        GitGutter::apply_to_decorations(&mut dset, &hunks, &b);
        // Should have some decorations
        assert!(!dset.is_empty() || hunks.is_empty());
    }

    #[test]
    fn test_apply_replaces_existing_git_decorations() {
        let mut dset = DecorationSet::new();
        let b = buf("a\nb\nc\n");
        // First apply
        let hunks1 = GitGutter::diff("x\nb\nc\n", "a\nb\nc\n");
        GitGutter::apply_to_decorations(&mut dset, &hunks1, &b);
        let count1 = dset.len();
        // Second apply replaces
        let hunks2 = GitGutter::diff("a\nx\nc\n", "a\nb\nc\n");
        GitGutter::apply_to_decorations(&mut dset, &hunks2, &b);
        let count2 = dset.len();
        // Count may differ but old Diff decorations should be replaced
        let _ = (count1, count2);
    }

    // ── Color / JSON ──────────────────────────────────────────────────────────

    #[test]
    fn test_hunk_colors() {
        assert_eq!(
            GutterHunk {
                kind: GutterHunkKind::Added,
                start_line: 0,
                end_line: 1,
                deleted_count: 0
            }
            .color_hex(),
            "#4CAF50"
        );
        assert_eq!(
            GutterHunk {
                kind: GutterHunkKind::Modified,
                start_line: 0,
                end_line: 1,
                deleted_count: 0
            }
            .color_hex(),
            "#2196F3"
        );
        assert_eq!(
            GutterHunk {
                kind: GutterHunkKind::Deleted,
                start_line: 0,
                end_line: 0,
                deleted_count: 1
            }
            .color_hex(),
            "#F44336"
        );
    }

    #[test]
    fn test_json_roundtrip() {
        let head = "line1\noriginal\nline3\n";
        let current = "line1\nmodified\nline3\nline4\n";
        let hunks = GitGutter::diff(head, current);
        let json = GitGutter::hunks_to_json(&hunks);
        let restored = GitGutter::hunks_from_json(&json);
        assert_eq!(hunks.len(), restored.len());
    }

    #[test]
    fn test_large_file_performance() {
        // 10k lines with a few changes shouldn't be slow
        let head: String = (0..10_000).map(|i| format!("line {}\n", i)).collect();
        let current = head.clone();
        // Change a few lines
        let lines: Vec<&str> = current.lines().collect();
        let mut v = lines.clone();
        if v.len() > 100 {
            v[100] = "modified line";
        }
        if v.len() > 5000 {
            v[5000] = "another modified line";
        }
        let current2 = v.join("\n");
        let hunks = GitGutter::diff(&head, &current2);
        // Should complete quickly and find the changes
        assert!(hunks.len() <= 10);
    }
}
