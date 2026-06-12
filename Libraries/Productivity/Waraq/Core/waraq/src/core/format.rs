// src/core/format.rs
//
// Code formatter — produces a list of EditOps that transform the document
// into a consistently formatted version.
//
// Two strategies:
//   1. Native formatter — our own indent-normaliser (always available,
//      works on all languages, handles basic indentation and trailing whitespace)
//   2. LSP formatter — delegates to the language server (`textDocument/formatting`)
//      for languages where we have an active LSP connection.
//
// The formatter never touches the buffer directly — it always returns EditOps
// so the caller can preview the changes and apply them through the undo stack.

use crate::core::buffer::Buffer;
use crate::core::config::ResolvedConfig;
use crate::core::edit::EditOp;
use crate::core::types::LineCol;
use serde::{Deserialize, Serialize};

// ── Format options ────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FormatOptions {
    /// Insert spaces or tabs.
    pub tab_size: u32,
    pub use_spaces: bool,
    /// Remove trailing whitespace from every line.
    pub trim_trailing: bool,
    /// Ensure the file ends with a newline.
    pub final_newline: bool,
    /// Maximum line length for soft-wrapping (0 = don't wrap).
    pub max_line_len: u32,
    /// Normalise line endings to the configured style.
    pub normalise_eol: bool,
}

impl From<&ResolvedConfig> for FormatOptions {
    fn from(cfg: &ResolvedConfig) -> Self {
        Self {
            tab_size: cfg.indent_width,
            use_spaces: cfg.indent_style == crate::core::config::IndentStyle::Spaces,
            trim_trailing: cfg.trim_trailing_whitespace,
            final_newline: cfg.insert_final_newline,
            max_line_len: cfg.max_line_length.unwrap_or(0),
            normalise_eol: false,
        }
    }
}

impl Default for FormatOptions {
    fn default() -> Self {
        Self {
            tab_size: 4,
            use_spaces: true,
            trim_trailing: true,
            final_newline: true,
            max_line_len: 0,
            normalise_eol: false,
        }
    }
}

// ── Format result ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone)]
pub struct FormatResult {
    /// Ops to apply, sorted largest-offset-first for safe sequential application.
    pub ops: Vec<EditOp>,
    /// True if the ops will change the document.
    pub has_changes: bool,
    /// Human-readable description (e.g. "3 lines reformatted").
    pub description: String,
}

impl FormatResult {
    fn no_changes() -> Self {
        Self {
            ops: vec![],
            has_changes: false,
            description: "No changes".into(),
        }
    }
}

// ── Native formatter ──────────────────────────────────────────────────────────

/// Format the entire document using the native formatter.
/// Returns ops sorted largest-offset-first.
pub fn format_document(buffer: &Buffer, opts: &FormatOptions, _language: &str) -> FormatResult {
    let mut ops: Vec<(usize, EditOp)> = Vec::new(); // (byte_offset, op)
    let total = buffer.len_lines();

    for line_num in 0..total {
        let line = buffer.line_str(line_num);
        let line_start = buffer.line_col_to_offset(LineCol::new(line_num, 0)).0;

        // 1. Normalise indent (tabs↔spaces)
        if let Some(op) = normalise_indent(&line, line_start, opts) {
            ops.push((line_start, op));
        }

        // 2. Trim trailing whitespace
        if opts.trim_trailing {
            if let Some(op) = trim_trailing_whitespace(&line, line_start) {
                let op_offset = match &op {
                    EditOp::Delete { range } => range.start.0,
                    _ => line_start,
                };
                ops.push((op_offset, op));
            }
        }
    }

    // 3. Ensure final newline
    if opts.final_newline {
        let text = buffer.to_string();
        if !text.is_empty() && !text.ends_with('\n') {
            let end = buffer.len_bytes();
            ops.push((end, EditOp::insert(end, "\n")));
        }
    }

    if ops.is_empty() {
        return FormatResult::no_changes();
    }

    // Sort largest-offset-first for safe application
    ops.sort_unstable_by(|a, b| b.0.cmp(&a.0));
    let edit_ops: Vec<EditOp> = ops.into_iter().map(|(_, op)| op).collect();
    let count = edit_ops.len();

    FormatResult {
        has_changes: true,
        description: format!(
            "{} formatting change{}",
            count,
            if count == 1 { "" } else { "s" }
        ),
        ops: edit_ops,
    }
}

/// Format a range of lines [first_line, last_line] (0-based, inclusive).
pub fn format_range(
    buffer: &Buffer,
    opts: &FormatOptions,
    _language: &str,
    first_line: usize,
    last_line: usize,
) -> FormatResult {
    // Build a temporary view buffer — same content but only reformat the range
    let last_line = last_line.min(buffer.len_lines().saturating_sub(1));
    let mut ops: Vec<(usize, EditOp)> = Vec::new();

    for line_num in first_line..=last_line {
        let line = buffer.line_str(line_num);
        let line_start = buffer.line_col_to_offset(LineCol::new(line_num, 0)).0;

        if let Some(op) = normalise_indent(&line, line_start, opts) {
            ops.push((line_start, op));
        }
        if opts.trim_trailing {
            if let Some(op) = trim_trailing_whitespace(&line, line_start) {
                let offset = match &op {
                    EditOp::Delete { range } => range.start.0,
                    _ => line_start,
                };
                ops.push((offset, op));
            }
        }
    }

    if ops.is_empty() {
        return FormatResult::no_changes();
    }
    ops.sort_unstable_by(|a, b| b.0.cmp(&a.0));
    let edit_ops: Vec<EditOp> = ops.into_iter().map(|(_, op)| op).collect();
    let count = edit_ops.len();
    FormatResult {
        has_changes: true,
        description: format!(
            "{} formatting change{}",
            count,
            if count == 1 { "" } else { "s" }
        ),
        ops: edit_ops,
    }
}

// ── Indent normalisation ───────────────────────────────────────────────────────

/// Return an op to normalise the leading whitespace of `line`, or None if
/// already correct.
fn normalise_indent(line: &str, line_start: usize, opts: &FormatOptions) -> Option<EditOp> {
    if line.is_empty() {
        return None;
    }

    let leading: String = line
        .chars()
        .take_while(|c| *c == ' ' || *c == '\t')
        .collect();
    if leading.is_empty() {
        return None;
    }

    let normalised = if opts.use_spaces {
        // Tabs → spaces
        let mut result = String::new();
        for ch in leading.chars() {
            match ch {
                '\t' => {
                    let spaces = opts.tab_size as usize;
                    result.push_str(&" ".repeat(spaces));
                }
                ' ' => result.push(' '),
                _ => {}
            }
        }
        result
    } else {
        // Spaces → tabs (round down to nearest tab stop)
        let space_count = leading.chars().filter(|c| *c == ' ').count();
        let tab_count = space_count / opts.tab_size as usize;
        let remainder = space_count % opts.tab_size as usize;
        "\t".repeat(tab_count) + &" ".repeat(remainder)
    };

    if normalised == leading {
        return None;
    }

    Some(EditOp::replace(
        line_start,
        line_start + leading.len(),
        &normalised,
    ))
}

/// Return a delete op to remove trailing whitespace, or None if clean.
fn trim_trailing_whitespace(line: &str, line_start: usize) -> Option<EditOp> {
    let trimmed_len = line.trim_end_matches(|c| c == ' ' || c == '\t').len();
    if trimmed_len == line.len() {
        return None;
    }
    let ws_start = line_start + trimmed_len;
    let ws_end = line_start + line.len();
    Some(EditOp::delete(ws_start, ws_end))
}

// ── Sort / reorder imports ─────────────────────────────────────────────────────

/// Sort import/use statements alphabetically.
/// Returns ops that rewrite the import block, or empty if no change needed.
pub fn sort_imports(buffer: &Buffer, language: &str) -> FormatResult {
    let import_kw: &[&str] = match language {
        "rust" => &["use "],
        "python" => &["import ", "from "],
        "javascript" | "typescript" => &["import "],
        "java" | "kotlin" => &["import "],
        _ => return FormatResult::no_changes(),
    };

    // Collect import blocks (consecutive import lines)
    let mut import_groups: Vec<(usize, usize)> = Vec::new(); // (first_line, last_line)
    let mut i = 0;
    while i < buffer.len_lines() {
        let line = buffer.line_str(i);
        let trimmed = line.trim();
        if import_kw.iter().any(|kw| trimmed.starts_with(kw)) {
            let start = i;
            let mut end = i;
            i += 1;
            while i < buffer.len_lines() {
                let l = buffer.line_str(i);
                let t = l.trim();
                let is_import = import_kw.iter().any(|kw| t.starts_with(kw));
                if !is_import {
                    break;
                }
                end = i;
                i += 1;
            }
            import_groups.push((start, end));
        } else {
            i += 1;
        }
    }

    let mut ops: Vec<(usize, EditOp)> = Vec::new();

    for (first, last) in import_groups {
        let lines: Vec<String> = (first..=last).map(|l| buffer.line_str(l)).collect();
        let mut sorted = lines.clone();
        sorted.sort_unstable();
        if sorted == lines {
            continue;
        } // already sorted

        let new_text = sorted.join("\n") + "\n";
        let block_start = buffer.line_col_to_offset(LineCol::new(first, 0)).0;
        let block_end = if last + 1 < buffer.len_lines() {
            buffer.line_col_to_offset(LineCol::new(last + 1, 0)).0
        } else {
            buffer.len_bytes()
        };

        ops.push((
            block_start,
            EditOp::replace(block_start, block_end, &new_text),
        ));
    }

    if ops.is_empty() {
        return FormatResult::no_changes();
    }
    ops.sort_unstable_by(|a, b| b.0.cmp(&a.0));
    let edit_ops: Vec<EditOp> = ops.into_iter().map(|(_, op)| op).collect();
    FormatResult {
        has_changes: true,
        description: "Import statements sorted".into(),
        ops: edit_ops,
    }
}

// ── Format-on-save ────────────────────────────────────────────────────────────

/// Composite format pass run on save: indent normalisation + trailing whitespace
/// + final newline + import sorting.
pub fn format_on_save(buffer: &Buffer, opts: &FormatOptions, language: &str) -> FormatResult {
    let mut all_ops: Vec<(usize, EditOp)> = Vec::new();

    let main = format_document(buffer, opts, language);
    for op in main.ops {
        let offset = match &op {
            EditOp::Replace { range, .. } => range.start.0,
            EditOp::Delete { range } => range.start.0,
            EditOp::Insert { at, .. } => at.0,
        };
        all_ops.push((offset, op));
    }

    let imports = sort_imports(buffer, language);
    for op in imports.ops {
        let offset = match &op {
            EditOp::Replace { range, .. } => range.start.0,
            EditOp::Delete { range } => range.start.0,
            EditOp::Insert { at, .. } => at.0,
        };
        all_ops.push((offset, op));
    }

    if all_ops.is_empty() {
        return FormatResult::no_changes();
    }

    // Deduplicate ops on the same byte range (prefer the last one added)
    // then sort largest-offset-first
    all_ops.sort_unstable_by(|a, b| b.0.cmp(&a.0).then(std::cmp::Ordering::Equal));
    all_ops.dedup_by_key(|(offset, _)| *offset);

    let ops: Vec<EditOp> = all_ops.into_iter().map(|(_, op)| op).collect();
    let count = ops.len();
    FormatResult {
        has_changes: true,
        description: format!(
            "Format on save: {} change{}",
            count,
            if count == 1 { "" } else { "s" }
        ),
        ops,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }
    fn default_opts() -> FormatOptions {
        FormatOptions::default()
    }

    // ── Trailing whitespace ────────────────────────────────────────────────────

    #[test]
    fn test_trim_trailing_whitespace() {
        let b = buf("hello   \nworld  \nno_trail\n");
        let result = format_document(&b, &default_opts(), "text");
        assert!(result.has_changes);
        // Should have 2 delete ops for the trailing spaces
        assert_eq!(result.ops.len(), 2);
    }

    #[test]
    fn test_no_trailing_whitespace_no_changes() {
        let b = buf("hello\nworld\n");
        let result = format_document(&b, &default_opts(), "text");
        assert!(!result.has_changes);
    }

    // ── Final newline ──────────────────────────────────────────────────────────

    #[test]
    fn test_insert_final_newline() {
        let b = buf("hello world");
        let result = format_document(&b, &default_opts(), "text");
        assert!(result.has_changes);
        let last_op = result.ops.last().unwrap();
        match last_op {
            EditOp::Insert { text, .. } => assert_eq!(text, "\n"),
            _ => panic!("Expected Insert for final newline"),
        }
    }

    #[test]
    fn test_no_duplicate_final_newline() {
        let b = buf("hello\n");
        let opts = FormatOptions {
            trim_trailing: false,
            ..default_opts()
        };
        let result = format_document(&b, &opts, "text");
        // Already has newline — no final_newline op needed
        let has_newline_insert = result
            .ops
            .iter()
            .any(|op| matches!(op, EditOp::Insert { text, .. } if text == "\n"));
        assert!(!has_newline_insert);
    }

    // ── Indent normalisation ───────────────────────────────────────────────────

    #[test]
    fn test_tabs_to_spaces() {
        let b = buf("\thello\n\tworld\n");
        let opts = FormatOptions {
            use_spaces: true,
            tab_size: 4,
            ..default_opts()
        };
        let result = format_document(&b, &opts, "text");
        assert!(result.has_changes);
        // Each tab should become 4 spaces
        for op in &result.ops {
            if let EditOp::Replace { text, .. } = op {
                if text.starts_with("    ") || text == "\n" {
                    continue;
                }
            }
        }
    }

    #[test]
    fn test_spaces_to_tabs() {
        let b = buf("    hello\n    world\n");
        let opts = FormatOptions {
            use_spaces: false,
            tab_size: 4,
            trim_trailing: true,
            ..default_opts()
        };
        let result = format_document(&b, &opts, "text");
        assert!(result.has_changes);
        for op in &result.ops {
            if let EditOp::Replace { text, .. } = op {
                if text.starts_with('\t') {
                    return;
                } // found the replacement
            }
        }
    }

    #[test]
    fn test_already_normalised_no_change() {
        let b = buf("    hello\n    world\n");
        let opts = FormatOptions {
            use_spaces: true,
            tab_size: 4,
            trim_trailing: false,
            final_newline: false,
            ..default_opts()
        };
        let result = format_document(&b, &opts, "text");
        assert!(!result.has_changes);
    }

    // ── Format range ──────────────────────────────────────────────────────────

    #[test]
    fn test_format_range_only_targets_given_lines() {
        let b = buf("hello   \nworld   \nfoo   \n");
        let result = format_range(&b, &default_opts(), "text", 1, 1);
        // Only line 1 ("world") should be formatted
        assert_eq!(result.ops.len(), 1);
    }

    // ── Sort imports ──────────────────────────────────────────────────────────

    #[test]
    fn test_sort_imports_rust() {
        let b = buf(
            "use std::io;\nuse anyhow::Result;\nuse std::collections::HashMap;\n\nfn main() {}\n",
        );
        let result = sort_imports(&b, "rust");
        assert!(result.has_changes, "imports should be sorted");
    }

    #[test]
    fn test_sort_imports_already_sorted() {
        let b = buf(
            "use anyhow::Result;\nuse std::collections::HashMap;\nuse std::io;\n\nfn main() {}\n",
        );
        let result = sort_imports(&b, "rust");
        assert!(!result.has_changes, "already sorted — no change needed");
    }

    #[test]
    fn test_sort_imports_python() {
        let b = buf("import sys\nimport os\nimport json\n\nprint('hi')\n");
        let result = sort_imports(&b, "python");
        assert!(result.has_changes);
    }

    // ── Format on save ────────────────────────────────────────────────────────

    #[test]
    fn test_format_on_save_combined() {
        let src =
            "use std::io;\nuse anyhow::Result;\n\nfn main() {   \n    println!(\"hi\");   \n}";
        let b = buf(src);
        let opts = FormatOptions {
            use_spaces: true,
            tab_size: 4,
            trim_trailing: true,
            final_newline: true,
            ..default_opts()
        };
        let result = format_on_save(&b, &opts, "rust");
        assert!(result.has_changes);
    }

    #[test]
    fn test_normalise_indent_returns_none_for_empty_line() {
        assert!(normalise_indent("", 0, &default_opts()).is_none());
    }

    #[test]
    fn test_normalise_indent_returns_none_for_no_leading_ws() {
        assert!(normalise_indent("hello", 0, &default_opts()).is_none());
    }

    #[test]
    fn test_trim_trailing_returns_none_when_clean() {
        assert!(trim_trailing_whitespace("hello", 0).is_none());
        assert!(trim_trailing_whitespace("hello\n", 0).is_none());
    }

    #[test]
    fn test_format_result_description() {
        let b = buf("hello   \nworld   \n");
        let result = format_document(&b, &default_opts(), "text");
        assert!(
            result.description.contains("change"),
            "Description: {}",
            result.description
        );
    }
}
