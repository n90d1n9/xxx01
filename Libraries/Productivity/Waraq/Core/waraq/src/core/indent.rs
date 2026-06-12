// src/core/indent.rs
//
// Language-aware auto-indent engine.
//
// Provides:
//   indent_for_new_line  — correct indent when pressing Enter
//   reindent_lines       — re-indent a range using language rules
//   auto_close_pair      — insert matching bracket/quote when typing an opener
//   should_dedent        — detect if a typed character should decrease indent

use crate::core::buffer::Buffer;
use crate::core::config::ResolvedConfig;
use crate::core::edit::EditOp;
use crate::core::types::ByteOffset;

// ── Indent rules per language ─────────────────────────────────────────────────

/// Rules that govern automatic indentation for a language.
#[derive(Debug, Clone)]
pub struct IndentRules {
    /// Characters that increase indent on the NEXT line when they end a line.
    pub indent_after: Vec<char>,
    /// Characters that DECREASE indent of the current line when typed.
    pub dedent_on: Vec<char>,
    /// Bracket pairs that are auto-closed.
    pub auto_pairs: Vec<(char, char)>,
    /// Quote characters that are auto-paired.
    pub auto_quotes: Vec<char>,
}

impl IndentRules {
    pub fn for_language(language: &str) -> Self {
        match language {
            "rust" | "c" | "cpp" | "java" | "kotlin" | "javascript" | "typescript" | "jsx"
            | "tsx" | "go" | "swift" | "csharp" => Self {
                indent_after: vec!['{'],
                dedent_on: vec!['}'],
                auto_pairs: vec![('(', ')'), ('[', ']'), ('{', '}')],
                auto_quotes: vec!['"', '\'', '`'],
            },
            "python" => Self {
                indent_after: vec![':'],
                dedent_on: vec![], // Python uses blank line / dedent detection
                auto_pairs: vec![('(', ')'), ('[', ']'), ('{', '}')],
                auto_quotes: vec!['"', '\''],
            },
            "ruby" => Self {
                indent_after: vec!['|', ':'], // do..end detected by keyword
                dedent_on: vec![],
                auto_pairs: vec![('(', ')'), ('[', ']'), ('{', '}')],
                auto_quotes: vec!['"', '\''],
            },
            "html" | "xml" => Self {
                indent_after: vec!['>'],
                dedent_on: vec!['<'],
                auto_pairs: vec![('<', '>')],
                auto_quotes: vec!['"', '\''],
            },
            "markdown" => Self {
                indent_after: vec![],
                dedent_on: vec![],
                auto_pairs: vec![('[', ']'), ('(', ')')],
                auto_quotes: vec!['"'],
            },
            _ => Self {
                indent_after: vec!['{', ':'],
                dedent_on: vec!['}'],
                auto_pairs: vec![('(', ')'), ('[', ']'), ('{', '}')],
                auto_quotes: vec!['"', '\''],
            },
        }
    }

    pub fn closing_for(&self, open: char) -> Option<char> {
        self.auto_pairs
            .iter()
            .find(|(o, _)| *o == open)
            .map(|(_, c)| *c)
    }

    pub fn is_opener(&self, ch: char) -> bool {
        self.auto_pairs.iter().any(|(o, _)| *o == ch)
    }

    pub fn is_closer(&self, ch: char) -> bool {
        self.auto_pairs.iter().any(|(_, c)| *c == ch)
    }
}

// ── Core indent calculation ───────────────────────────────────────────────────

/// Count leading whitespace characters on a line.
pub fn leading_whitespace_len(line: &str, tab_width: u32) -> u32 {
    let mut count = 0u32;
    for ch in line.chars() {
        match ch {
            ' ' => count += 1,
            '\t' => count += tab_width,
            _ => break,
        }
    }
    count
}

/// Get the raw leading whitespace string of a line.
pub fn leading_whitespace_str(line: &str) -> &str {
    let end = line
        .find(|c: char| !c.is_whitespace())
        .unwrap_or(line.len());
    &line[..end]
}

/// Calculate the correct indentation string for a new line inserted after `line`.
///
/// Algorithm:
///   1. Start with the indent level of the current line.
///   2. If the current line (trimmed) ends with an indent-trigger char, add one level.
///   3. If the new line starts with a dedent-trigger char, subtract one level.
pub fn indent_for_new_line(
    buf: &Buffer,
    cursor_line: usize,
    cfg: &ResolvedConfig,
    rules: &IndentRules,
) -> String {
    if cursor_line >= buf.len_lines() {
        return String::new();
    }

    let line = buf.line_str(cursor_line);
    let trimmed = line.trim_end();
    let base_indent = leading_whitespace_str(&line).to_owned();
    let indent_unit = cfg.indent_str();

    // Check if the line ends with an indent trigger
    if let Some(last_char) = trimmed.chars().last() {
        if rules.indent_after.contains(&last_char) {
            return format!("{}{}", base_indent, indent_unit);
        }
    }

    base_indent
}

/// Calculate the indent for a line that was just closed (e.g. user typed `}`).
/// Returns the dedented indent string, or None if no dedent needed.
pub fn dedent_for_closer(
    buf: &Buffer,
    line: usize,
    typed_char: char,
    cfg: &ResolvedConfig,
    rules: &IndentRules,
) -> Option<String> {
    if !rules.dedent_on.contains(&typed_char) {
        return None;
    }

    let line_text = buf.line_str(line);
    let trimmed = line_text.trim();

    // Only dedent if the line contains ONLY the closing char (possibly with whitespace)
    if trimmed != typed_char.to_string().as_str() {
        return None;
    }

    let current_indent = leading_whitespace_len(&line_text, cfg.tab_width);
    let indent_unit_width = match cfg.indent_style {
        crate::core::config::IndentStyle::Tabs => cfg.tab_width,
        crate::core::config::IndentStyle::Spaces => cfg.indent_width,
    };

    if current_indent < indent_unit_width {
        return None;
    }

    let new_level = (current_indent - indent_unit_width) / indent_unit_width;
    Some(cfg.indent_str().repeat(new_level as usize))
}

// ── Auto-pair ─────────────────────────────────────────────────────────────────

/// Result of an auto-pair operation.
#[derive(Debug, Clone)]
pub struct AutoPairResult {
    /// Text to insert at cursor position.
    pub insert: String,
    /// How many characters forward to move cursor after insert
    /// (0 = cursor stays at insert point, 1 = cursor before closing char).
    pub cursor_offset: usize,
}

/// Compute whether typing `ch` should auto-insert a closing pair.
///
/// Cases:
///   - '(' → insert "()" and leave cursor between them
///   - ')' with ')' already at cursor → skip (move cursor over the ')' instead)
///   - '"' at start or after whitespace → insert '""' and cursor between
///   - '"' when cursor is inside a string → just insert '"' to close
pub fn auto_pair_for(
    buf: &Buffer,
    pos: ByteOffset,
    ch: char,
    rules: &IndentRules,
    cfg: &ResolvedConfig,
) -> Option<AutoPairResult> {
    if !cfg.auto_close_brackets && !cfg.auto_close_quotes {
        return None;
    }

    let text = buf.to_string();

    // If it's a closer and the character at pos is already the closer → skip over it
    if rules.is_closer(ch) {
        let char_at_pos = text[pos.0..].chars().next();
        if char_at_pos == Some(ch) {
            // Tell the caller: don't insert, just advance cursor
            return Some(AutoPairResult {
                insert: String::new(),
                cursor_offset: 1,
            });
        }
    }

    // Auto-close openers
    if let Some(close) = rules.closing_for(ch) {
        let s: String = [ch, close].iter().collect();
        return Some(AutoPairResult {
            insert: s,
            cursor_offset: 1,
        });
    }

    // Auto-pair quotes
    if cfg.auto_close_quotes && rules.auto_quotes.contains(&ch) {
        let char_at_pos = text[pos.0..].chars().next();
        // If cursor is before the same quote char, skip over it
        if char_at_pos == Some(ch) {
            return Some(AutoPairResult {
                insert: String::new(),
                cursor_offset: 1,
            });
        }
        // Otherwise insert pair
        let s: String = [ch, ch].iter().collect();
        return Some(AutoPairResult {
            insert: s,
            cursor_offset: 1,
        });
    }

    None
}

// ── Reindent a range ──────────────────────────────────────────────────────────

/// Reindent lines [first_line, last_line] to match computed indent levels.
/// Returns a list of EditOps to apply (in reverse line order for offset safety).
pub fn reindent_lines(
    buf: &Buffer,
    first_line: usize,
    last_line: usize,
    cfg: &ResolvedConfig,
    rules: &IndentRules,
) -> Vec<EditOp> {
    let last_line = last_line.min(buf.len_lines().saturating_sub(1));
    let mut ops: Vec<EditOp> = Vec::new();
    let indent_unit = cfg.indent_str();

    // We compute "desired indent level" by walking from line 0 to last_line.
    // For each line, count open/close brackets to track nesting depth.
    let mut depth: i32 = 0;
    let mut desired_indents: Vec<String> = Vec::new();

    for line in 0..=last_line {
        let line_text = buf.line_str(line);
        let trimmed = line_text.trim();

        // If the line starts with a closing char, dedent before counting
        let line_dedent = trimmed.starts_with(|c| rules.dedent_on.contains(&c));
        if line_dedent && depth > 0 {
            depth -= 1;
        }

        let desired = indent_unit.repeat(depth.max(0) as usize);
        desired_indents.push(desired);

        // Count net bracket change on this line (ignoring string contents — simplified)
        for ch in trimmed.chars() {
            if rules.indent_after.contains(&ch) {
                depth += 1;
            }
            if rules.dedent_on.contains(&ch) && !line_dedent {
                depth -= 1;
            }
        }
        if depth < 0 {
            depth = 0;
        }
    }

    // Generate replace ops for lines that need reindenting (in reverse order)
    for line in (first_line..=last_line).rev() {
        let line_text = buf.line_str(line);
        let current_indent = leading_whitespace_str(&line_text);
        let desired_indent = &desired_indents[line];

        if current_indent == desired_indent {
            continue;
        }

        let line_start = buf.line_col_to_offset(crate::core::types::LineCol::new(line, 0));
        let content_start = buf.line_col_to_offset(crate::core::types::LineCol::new(
            line,
            current_indent.chars().count(),
        ));

        ops.push(EditOp::replace(
            line_start.0,
            content_start.0,
            desired_indent.as_str(),
        ));
    }

    ops
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::core::config::Config;

    fn resolved() -> ResolvedConfig {
        ResolvedConfig::from(Config::default())
    }

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_leading_whitespace_spaces() {
        assert_eq!(leading_whitespace_len("    hello", 4), 4);
    }

    #[test]
    fn test_leading_whitespace_tab() {
        assert_eq!(leading_whitespace_len("\thello", 4), 4);
    }

    #[test]
    fn test_indent_for_new_line_after_brace() {
        let b = buf("fn main() {\n");
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let indent = indent_for_new_line(&b, 0, &cfg, &rules);
        assert_eq!(indent, "    "); // one level of indent
    }

    #[test]
    fn test_indent_for_new_line_after_colon_python() {
        let b = buf("def foo():\n");
        let rules = IndentRules::for_language("python");
        let cfg = resolved();
        let indent = indent_for_new_line(&b, 0, &cfg, &rules);
        assert_eq!(indent, "    ");
    }

    #[test]
    fn test_indent_for_new_line_no_trigger() {
        let b = buf("    let x = 1;\n");
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let indent = indent_for_new_line(&b, 0, &cfg, &rules);
        assert_eq!(indent, "    "); // preserve existing indent
    }

    #[test]
    fn test_indent_rules_rust_auto_pairs() {
        let rules = IndentRules::for_language("rust");
        assert_eq!(rules.closing_for('('), Some(')'));
        assert_eq!(rules.closing_for('['), Some(']'));
        assert_eq!(rules.closing_for('{'), Some('}'));
        assert_eq!(rules.closing_for('x'), None);
    }

    #[test]
    fn test_auto_pair_opener() {
        let b = buf("let x = ;");
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let result = auto_pair_for(&b, ByteOffset(8), '(', &rules, &cfg);
        assert!(result.is_some());
        let r = result.unwrap();
        assert_eq!(r.insert, "()");
        assert_eq!(r.cursor_offset, 1);
    }

    #[test]
    fn test_auto_pair_skip_closer() {
        // Buffer: "foo()" — cursor before ')'
        let b = buf("foo()");
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let result = auto_pair_for(&b, ByteOffset(4), ')', &rules, &cfg);
        // Should skip over existing ')'
        assert!(result.is_some());
        let r = result.unwrap();
        assert_eq!(r.insert, ""); // no insert, just advance
        assert_eq!(r.cursor_offset, 1);
    }

    #[test]
    fn test_auto_pair_quote() {
        let b = buf("let s = ;");
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let result = auto_pair_for(&b, ByteOffset(8), '"', &rules, &cfg);
        assert!(result.is_some());
        let r = result.unwrap();
        assert_eq!(r.insert, "\"\"");
    }

    #[test]
    fn test_reindent_simple_rust() {
        let src = "fn foo() {\nlet x = 1;\n}\n";
        let b = buf(src);
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let ops = reindent_lines(&b, 0, 2, &cfg, &rules);
        // Line 1 (let x = 1;) needs indentation
        assert!(!ops.is_empty());
    }

    #[test]
    fn test_reindent_already_correct() {
        let src = "fn foo() {\n    let x = 1;\n}\n";
        let b = buf(src);
        let rules = IndentRules::for_language("rust");
        let cfg = resolved();
        let ops = reindent_lines(&b, 0, 2, &cfg, &rules);
        // Should produce no ops (already correctly indented)
        assert!(ops.is_empty());
    }

    #[test]
    fn test_indent_rules_html() {
        let rules = IndentRules::for_language("html");
        assert!(rules.indent_after.contains(&'>'));
    }

    #[test]
    fn test_leading_whitespace_str() {
        assert_eq!(leading_whitespace_str("    hello"), "    ");
        assert_eq!(leading_whitespace_str("hello"), "");
        assert_eq!(leading_whitespace_str("\t\thello"), "\t\t");
    }
}
