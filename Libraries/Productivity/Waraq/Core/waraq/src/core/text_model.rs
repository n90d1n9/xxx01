// src/core/text_model.rs
//
// TextModel — Monaco-compatible document model interface.
//
// Provides the same API surface as `monaco.editor.ITextModel`:
//   getLineContent(lineNumber)   → line text (1-based)
//   getLineCount()               → total lines
//   getOffsetAt(position)        → byte offset from line/col
//   getPositionAt(offset)        → line/col from byte offset
//   getValueInRange(range)       → text within a line/col range
//   getValue()                   → entire document text
//   findMatches(...)             → all regex/literal matches
//   findNextMatch(...)           → next match after offset
//   getWordAtPosition(position)  → word under cursor
//   getLineFirstNonWhitespaceColumn(lineNumber)
//   getLineLastNonWhitespaceColumn(lineNumber)
//   getLineMaxColumn(lineNumber)
//   getLineMinColumn(lineNumber)
//   getFullModelRange()          → range covering the whole document
//   getEOL()                     → line ending string
//   applyEdits(edits)            → apply a list of IIdentifiedSingleEditOperation
//   pushEditOperations(...)      → apply with undo grouping
//
// Note: Monaco uses 1-based line numbers and 1-based columns throughout.
// Our internal buffer uses 0-based line numbers and 0-based byte offsets.
// The TextModel translates between these conventions.

use crate::core::buffer::Buffer;
use crate::core::edit::EditOp;
use crate::core::search::SearchQuery;
use crate::core::types::{ByteOffset, LineCol};
use serde::{Deserialize, Serialize};

// ── Monaco-convention position (1-based) ──────────────────────────────────────

/// Monaco IPosition — 1-based line and column.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct MonacoPosition {
    /// 1-based line number.
    pub line_number: u32,
    /// 1-based column.
    pub column: u32,
}

impl MonacoPosition {
    pub fn new(line_number: u32, column: u32) -> Self {
        Self {
            line_number,
            column,
        }
    }

    /// Convert to our 0-based `LineCol`.
    pub fn to_line_col(self) -> LineCol {
        LineCol::new(
            self.line_number.saturating_sub(1) as usize,
            self.column.saturating_sub(1) as usize,
        )
    }

    /// Create from our 0-based `LineCol`.
    pub fn from_line_col(lc: LineCol) -> Self {
        Self::new((lc.line + 1) as u32, (lc.col + 1) as u32)
    }
}

/// Monaco IRange — 1-based start and end positions.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct MonacoRange {
    pub start_line_number: u32,
    pub start_column: u32,
    pub end_line_number: u32,
    pub end_column: u32,
}

impl MonacoRange {
    pub fn new(start_line: u32, start_col: u32, end_line: u32, end_col: u32) -> Self {
        Self {
            start_line_number: start_line,
            start_column: start_col,
            end_line_number: end_line,
            end_column: end_col,
        }
    }

    pub fn from_byte_range(buf: &Buffer, start: usize, end: usize) -> Self {
        let s = buf.offset_to_line_col(ByteOffset(start));
        let e = buf.offset_to_line_col(ByteOffset(end));
        Self::new(
            (s.line + 1) as u32,
            (s.col + 1) as u32,
            (e.line + 1) as u32,
            (e.col + 1) as u32,
        )
    }

    pub fn is_empty(&self) -> bool {
        self.start_line_number == self.end_line_number && self.start_column == self.end_column
    }

    pub fn contains(&self, pos: &MonacoPosition) -> bool {
        if pos.line_number < self.start_line_number || pos.line_number > self.end_line_number {
            return false;
        }
        if pos.line_number == self.start_line_number && pos.column < self.start_column {
            return false;
        }
        if pos.line_number == self.end_line_number && pos.column > self.end_column {
            return false;
        }
        true
    }
}

// ── FindMatch result ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FindMatch {
    pub range: MonacoRange,
    pub matches: Option<Vec<String>>, // capture groups
}

// ── Single edit operation (Monaco IIdentifiedSingleEditOperation) ─────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SingleEditOperation {
    pub range: MonacoRange,
    pub text: Option<String>, // None = delete only
    pub force_move_markers: bool,
}

impl SingleEditOperation {
    pub fn insert(position: MonacoPosition, text: &str) -> Self {
        let r = MonacoRange::new(
            position.line_number,
            position.column,
            position.line_number,
            position.column,
        );
        Self {
            range: r,
            text: Some(text.to_owned()),
            force_move_markers: false,
        }
    }

    pub fn delete(range: MonacoRange) -> Self {
        Self {
            range,
            text: None,
            force_move_markers: false,
        }
    }

    pub fn replace(range: MonacoRange, text: &str) -> Self {
        Self {
            range,
            text: Some(text.to_owned()),
            force_move_markers: false,
        }
    }
}

// ── Word at position ──────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordAtPosition {
    pub word: String,
    pub start_column: u32, // 1-based
    pub end_column: u32,   // 1-based
}

// ── TextModel ─────────────────────────────────────────────────────────────────

/// Monaco-compatible read/write interface to the document.
/// This is a thin adapter over our `Buffer` + `Editor`.
///
/// Note: For mutation operations, the caller must apply the returned
/// `Vec<EditOp>` through `Editor::apply_batch` to get undo support.
pub struct TextModel<'a> {
    buf: &'a Buffer,
    eol: &'a str,
}

impl<'a> TextModel<'a> {
    pub fn new(buf: &'a Buffer, eol: &'a str) -> Self {
        Self { buf, eol }
    }

    // ── Read API ──────────────────────────────────────────────────────────────

    /// 1-based line number → line content (without newline).
    pub fn get_line_content(&self, line_number: u32) -> String {
        let line = line_number.saturating_sub(1) as usize;
        if line >= self.buf.len_lines() {
            return String::new();
        }
        let s = self.buf.line_str(line);
        s.trim_end_matches(['\n', '\r']).to_owned()
    }

    /// Total number of lines.
    pub fn get_line_count(&self) -> u32 {
        self.buf.len_lines() as u32
    }

    /// Convert Monaco position to byte offset.
    pub fn get_offset_at(&self, pos: MonacoPosition) -> usize {
        let lc = pos.to_line_col();
        let line = lc.line.min(self.buf.len_lines().saturating_sub(1));
        let col = lc.col.min(self.buf.line_len_chars(line));
        self.buf.line_col_to_offset(LineCol::new(line, col)).0
    }

    /// Convert byte offset to Monaco position.
    pub fn get_position_at(&self, offset: usize) -> MonacoPosition {
        let offset = offset.min(self.buf.len_bytes());
        let lc = self.buf.offset_to_line_col(ByteOffset(offset));
        MonacoPosition::from_line_col(lc)
    }

    /// Get text within a Monaco range.
    pub fn get_value_in_range(&self, range: MonacoRange) -> String {
        let start = self.get_offset_at(MonacoPosition::new(
            range.start_line_number,
            range.start_column,
        ));
        let end = self.get_offset_at(MonacoPosition::new(range.end_line_number, range.end_column));
        if start >= end {
            return String::new();
        }
        self.buf
            .text_in_range(crate::core::types::Range::new(start, end))
    }

    /// Get the entire document value.
    pub fn get_value(&self) -> String {
        self.buf.to_string()
    }

    /// Get the line ending sequence.
    pub fn get_eol(&self) -> &str {
        self.eol
    }

    /// 1-based line number → 1-based first non-whitespace column.
    pub fn get_line_first_nonwhitespace_column(&self, line_number: u32) -> u32 {
        let line = (line_number.saturating_sub(1)) as usize;
        if line >= self.buf.len_lines() {
            return 1;
        }
        let text = self.buf.line_str(line);
        let col = text.chars().take_while(|c| c.is_whitespace()).count();
        (col + 1) as u32
    }

    /// 1-based line number → 1-based last non-whitespace column.
    pub fn get_line_last_nonwhitespace_column(&self, line_number: u32) -> u32 {
        let line = (line_number.saturating_sub(1)) as usize;
        if line >= self.buf.len_lines() {
            return 1;
        }
        let text = self
            .buf
            .line_str(line)
            .trim_end_matches(['\n', '\r'])
            .to_owned();
        let trim = text.trim_end();
        (trim.chars().count() + 1) as u32
    }

    /// 1-based line number → 1-based max column (end of line + 1).
    pub fn get_line_max_column(&self, line_number: u32) -> u32 {
        let line = (line_number.saturating_sub(1)) as usize;
        if line >= self.buf.len_lines() {
            return 1;
        }
        let text = self
            .buf
            .line_str(line)
            .trim_end_matches(['\n', '\r'])
            .to_owned();
        (text.chars().count() + 1) as u32
    }

    /// Always returns 1 (first column is always 1).
    pub fn get_line_min_column(&self, _line_number: u32) -> u32 {
        1
    }

    /// Range covering the entire document.
    pub fn get_full_model_range(&self) -> MonacoRange {
        let total = self.buf.len_lines();
        if total == 0 {
            return MonacoRange::new(1, 1, 1, 1);
        }
        let last_line = total as u32;
        let last_col = self.get_line_max_column(last_line);
        MonacoRange::new(1, 1, last_line, last_col)
    }

    /// Find all matches for a search query.
    pub fn find_matches(
        &self,
        search: &str,
        is_regex: bool,
        match_case: bool,
        whole_word: bool,
        search_scope: Option<MonacoRange>,
        limit_result_count: usize,
    ) -> Vec<FindMatch> {
        let query = SearchQuery {
            pattern: search.to_owned(),
            case_sensitive: match_case,
            whole_word,
            regex: is_regex,
            wrap_around: false,
        };

        let all = find_matches_in_buffer(self.buf, &query);
        let limit = if limit_result_count == 0 {
            usize::MAX
        } else {
            limit_result_count
        };

        all.into_iter()
            .filter(|(start, _end)| {
                if let Some(scope) = &search_scope {
                    let start_pos = self.get_position_at(*start);
                    scope.contains(&start_pos)
                } else {
                    true
                }
            })
            .take(limit)
            .map(|(start, end)| FindMatch {
                range: MonacoRange::from_byte_range(self.buf, start, end),
                matches: None,
            })
            .collect()
    }

    /// Find the next match after a given position.
    pub fn find_next_match(
        &self,
        search: &str,
        search_start: MonacoPosition,
        is_regex: bool,
        match_case: bool,
        whole_word: bool,
    ) -> Option<FindMatch> {
        let start_offset = self.get_offset_at(search_start);
        let query = SearchQuery {
            pattern: search.to_owned(),
            case_sensitive: match_case,
            whole_word,
            regex: is_regex,
            wrap_around: true,
        };
        let all = find_matches_in_buffer(self.buf, &query);
        // Find first match after start, then wrap
        all.iter()
            .find(|(s, _)| *s > start_offset)
            .or_else(|| all.first())
            .map(|(start, end)| FindMatch {
                range: MonacoRange::from_byte_range(self.buf, *start, *end),
                matches: None,
            })
    }

    /// Find the previous match before a given position.
    pub fn find_previous_match(
        &self,
        search: &str,
        search_start: MonacoPosition,
        is_regex: bool,
        match_case: bool,
        whole_word: bool,
    ) -> Option<FindMatch> {
        let start_offset = self.get_offset_at(search_start);
        let query = SearchQuery {
            pattern: search.to_owned(),
            case_sensitive: match_case,
            whole_word,
            regex: is_regex,
            wrap_around: true,
        };
        let all = find_matches_in_buffer(self.buf, &query);
        all.iter()
            .rev()
            .find(|(s, _)| *s < start_offset)
            .or_else(|| all.last())
            .map(|(start, end)| FindMatch {
                range: MonacoRange::from_byte_range(self.buf, *start, *end),
                matches: None,
            })
    }

    /// Get the word at a given position.
    pub fn get_word_at_position(&self, pos: MonacoPosition) -> Option<WordAtPosition> {
        let offset = self.get_offset_at(pos);
        let range = self.buf.word_range_at(ByteOffset(offset));
        if range.is_empty() {
            return None;
        }

        let word = self.buf.text_in_range(range);
        let start_lc = self.buf.offset_to_line_col(range.start);
        let end_lc = self.buf.offset_to_line_col(range.end);

        Some(WordAtPosition {
            word,
            start_column: (start_lc.col + 1) as u32,
            end_column: (end_lc.col + 1) as u32,
        })
    }

    // ── Write API (returns EditOps, caller applies) ────────────────────────────

    /// Build EditOps for a list of SingleEditOperation.
    /// Ops are sorted largest-offset-first for safe sequential application.
    pub fn apply_edits(&self, edits: &[SingleEditOperation]) -> Vec<EditOp> {
        let mut ops: Vec<(usize, EditOp)> = edits
            .iter()
            .map(|edit| {
                let start = self.get_offset_at(MonacoPosition::new(
                    edit.range.start_line_number,
                    edit.range.start_column,
                ));
                let end = self.get_offset_at(MonacoPosition::new(
                    edit.range.end_line_number,
                    edit.range.end_column,
                ));
                let op = match &edit.text {
                    Some(text) if !text.is_empty() && start == end => EditOp::insert(start, text),
                    Some(text) if !text.is_empty() => EditOp::replace(start, end, text),
                    Some(_) | None => EditOp::delete(start, end),
                };
                (start, op)
            })
            .collect();

        ops.sort_by(|a, b| b.0.cmp(&a.0));
        ops.into_iter().map(|(_, op)| op).collect()
    }
}

// ── Internal helper ───────────────────────────────────────────────────────────

fn find_matches_in_buffer(buf: &Buffer, query: &SearchQuery) -> Vec<(usize, usize)> {
    use crate::core::search::SearchState;
    let text = buf.to_string();

    // Use our existing literal or regex search
    if query.regex {
        // Delegate to search module's regex engine
        let state = SearchState::new(buf, query.clone());
        state
            .map(|s| {
                s.all_matches()
                    .into_iter()
                    .map(|m| (m.start.0, m.end.0))
                    .collect()
            })
            .unwrap_or_default()
    } else {
        // Literal search
        let haystack_owned;
        let needle_owned;
        let (haystack_s, needle_s): (&str, &str) = if query.case_sensitive {
            (text.as_str(), query.pattern.as_str())
        } else {
            haystack_owned = text.to_lowercase();
            needle_owned = query.pattern.to_lowercase();
            (haystack_owned.as_str(), needle_owned.as_str())
        };

        let mut results = Vec::new();
        let mut start = 0;
        while let Some(pos) = haystack_s[start..].find(needle_s) {
            let abs = start + pos;
            let abs_end = abs + query.pattern.len();
            if query.whole_word {
                let is_word = |c: char| c.is_alphanumeric() || c == '_';
                let before = text[..abs].chars().last().map(is_word).unwrap_or(false);
                let after = text[abs_end..].chars().next().map(is_word).unwrap_or(false);
                if !before && !after {
                    results.push((abs, abs_end));
                }
            } else {
                results.push((abs, abs_end));
            }
            start = abs + 1;
            if start >= haystack_s.len() {
                break;
            }
        }
        results
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }
    fn model(b: &Buffer) -> TextModel<'_> {
        TextModel::new(b, "\n")
    }

    // ── Position/Range ────────────────────────────────────────────────────────

    #[test]
    fn test_monaco_position_conversion() {
        let p = MonacoPosition::new(1, 1);
        let lc = p.to_line_col();
        assert_eq!(lc.line, 0);
        assert_eq!(lc.col, 0);
        let back = MonacoPosition::from_line_col(lc);
        assert_eq!(back, p);
    }

    #[test]
    fn test_monaco_range_contains() {
        let r = MonacoRange::new(1, 1, 3, 10);
        assert!(r.contains(&MonacoPosition::new(2, 5)));
        assert!(r.contains(&MonacoPosition::new(1, 1)));
        assert!(!r.contains(&MonacoPosition::new(3, 11)));
        assert!(!r.contains(&MonacoPosition::new(4, 1)));
    }

    // ── Line queries ──────────────────────────────────────────────────────────

    #[test]
    fn test_get_line_content() {
        let b = buf("hello\nworld\nfoo\n");
        let m = model(&b);
        assert_eq!(m.get_line_content(1), "hello");
        assert_eq!(m.get_line_content(2), "world");
        assert_eq!(m.get_line_content(3), "foo");
        assert_eq!(m.get_line_content(99), ""); // out of bounds
    }

    #[test]
    fn test_get_line_count() {
        let b = buf("a\nb\nc\n");
        let m = model(&b);
        assert_eq!(m.get_line_count(), 4); // 3 lines + trailing empty
    }

    #[test]
    fn test_get_line_max_column() {
        let b = buf("hello\nworld\n");
        let m = model(&b);
        assert_eq!(m.get_line_max_column(1), 6); // "hello" = 5 chars, max col = 6
        assert_eq!(m.get_line_max_column(2), 6); // "world" = 5 chars
    }

    #[test]
    fn test_get_line_first_nonwhitespace_column() {
        let b = buf("    hello\n\tworld\n");
        let m = model(&b);
        assert_eq!(m.get_line_first_nonwhitespace_column(1), 5); // 4 spaces → col 5
    }

    // ── Offset conversion ─────────────────────────────────────────────────────

    #[test]
    fn test_get_offset_at() {
        let b = buf("hello\nworld\n");
        let m = model(&b);
        assert_eq!(m.get_offset_at(MonacoPosition::new(1, 1)), 0);
        assert_eq!(m.get_offset_at(MonacoPosition::new(2, 1)), 6);
        assert_eq!(m.get_offset_at(MonacoPosition::new(1, 6)), 5);
    }

    #[test]
    fn test_get_position_at() {
        let b = buf("hello\nworld\n");
        let m = model(&b);
        let p1 = m.get_position_at(0);
        assert_eq!(p1, MonacoPosition::new(1, 1));
        let p2 = m.get_position_at(6);
        assert_eq!(p2, MonacoPosition::new(2, 1));
    }

    #[test]
    fn test_offset_roundtrip() {
        let b = buf("fn main() {\n    let x = 42;\n}\n");
        let m = model(&b);
        for offset in [0, 5, 12, 20, 28] {
            let pos = m.get_position_at(offset);
            let back = m.get_offset_at(pos);
            assert_eq!(back, offset, "Roundtrip failed at offset {}", offset);
        }
    }

    // ── Value queries ─────────────────────────────────────────────────────────

    #[test]
    fn test_get_value_in_range() {
        let b = buf("hello world\nfoo bar\n");
        let m = model(&b);
        let r = MonacoRange::new(1, 1, 1, 6); // "hello"
        assert_eq!(m.get_value_in_range(r), "hello");
    }

    #[test]
    fn test_get_value() {
        let src = "hello\nworld\n";
        let b = buf(src);
        let m = model(&b);
        assert_eq!(m.get_value(), src);
    }

    #[test]
    fn test_get_full_model_range() {
        let b = buf("hello\nworld\n");
        let m = model(&b);
        let r = m.get_full_model_range();
        assert_eq!(r.start_line_number, 1);
        assert_eq!(r.start_column, 1);
        assert!(r.end_line_number >= 2);
    }

    // ── Find ──────────────────────────────────────────────────────────────────

    #[test]
    fn test_find_matches_literal() {
        let b = buf("foo bar foo baz foo");
        let m = model(&b);
        let results = m.find_matches("foo", false, true, false, None, 0);
        assert_eq!(results.len(), 3);
    }

    #[test]
    fn test_find_matches_case_insensitive() {
        let b = buf("Hello HELLO hello");
        let m = model(&b);
        let results = m.find_matches("hello", false, false, false, None, 0);
        assert_eq!(results.len(), 3);
    }

    #[test]
    fn test_find_matches_with_limit() {
        let b = buf("a a a a a a a a a a");
        let m = model(&b);
        let results = m.find_matches("a", false, true, false, None, 5);
        assert_eq!(results.len(), 5);
    }

    #[test]
    fn test_find_next_match() {
        let b = buf("foo bar foo baz foo");
        let m = model(&b);
        let start = MonacoPosition::new(1, 5); // after first "foo"
        let result = m.find_next_match("foo", start, false, true, false).unwrap();
        assert_eq!(result.range.start_column, 9); // second "foo" at col 9
    }

    #[test]
    fn test_find_next_match_wraps() {
        let b = buf("foo bar foo");
        let m = model(&b);
        let start = MonacoPosition::new(1, 9); // after second "foo"
        let result = m.find_next_match("foo", start, false, true, false).unwrap();
        assert_eq!(result.range.start_column, 1); // wraps to first
    }

    #[test]
    fn test_find_previous_match() {
        let b = buf("foo bar foo baz foo");
        let m = model(&b);
        let start = MonacoPosition::new(1, 12); // before third "foo"
        let result = m
            .find_previous_match("foo", start, false, true, false)
            .unwrap();
        assert_eq!(result.range.start_column, 9); // second "foo"
    }

    // ── Word at position ──────────────────────────────────────────────────────

    #[test]
    fn test_get_word_at_position() {
        let b = buf("hello world foo");
        let m = model(&b);
        let word = m.get_word_at_position(MonacoPosition::new(1, 7)).unwrap();
        assert_eq!(word.word, "world");
        assert_eq!(word.start_column, 7);
        assert_eq!(word.end_column, 12);
    }

    #[test]
    fn test_get_word_at_position_no_word() {
        let b = buf("hello   world");
        let m = model(&b);
        // Position in whitespace
        let word = m.get_word_at_position(MonacoPosition::new(1, 7));
        assert!(word.is_none() || word.unwrap().word.is_empty());
    }

    // ── Apply edits ───────────────────────────────────────────────────────────

    #[test]
    fn test_apply_edits_insert() {
        let b = buf("hello");
        let m = model(&b);
        let ops = m.apply_edits(&[SingleEditOperation::insert(
            MonacoPosition::new(1, 6),
            " world",
        )]);
        assert_eq!(ops.len(), 1);
    }

    #[test]
    fn test_apply_edits_delete() {
        let b = buf("hello world");
        let m = model(&b);
        let ops = m.apply_edits(&[SingleEditOperation::delete(MonacoRange::new(1, 6, 1, 12))]);
        assert_eq!(ops.len(), 1);
    }

    #[test]
    fn test_apply_edits_replace() {
        let b = buf("hello world");
        let m = model(&b);
        let ops = m.apply_edits(&[SingleEditOperation::replace(
            MonacoRange::new(1, 7, 1, 12),
            "Rust",
        )]);
        assert_eq!(ops.len(), 1);
    }

    #[test]
    fn test_apply_edits_sorted_largest_first() {
        let b = buf("hello world foo");
        let m = model(&b);
        let ops = m.apply_edits(&[
            SingleEditOperation::insert(MonacoPosition::new(1, 1), "A"),
            SingleEditOperation::insert(MonacoPosition::new(1, 7), "B"),
        ]);
        // Should be sorted largest-first (B before A)
        match &ops[0] {
            crate::core::edit::EditOp::Insert { at, text: _ } => {
                assert!(at.0 > 0, "First op should be the larger-offset one");
            }
            _ => panic!("Expected Insert"),
        }
    }
}
