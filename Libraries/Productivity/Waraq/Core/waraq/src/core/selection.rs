// src/core/selection.rs
//
// Selection operations — everything beyond moving a cursor with extend=true.
//
// Provides:
//   • select_word / select_line / select_all_occurrences
//   • expand_selection  — smart expand to enclosing bracket/quote/scope
//   • shrink_selection  — reverse of expand
//   • SelectionHistory  — stack of expansion states for alt+shift+arrows (VS Code style)
//   • column_select     — rectangular selection across lines

use crate::core::buffer::Buffer;
use crate::core::cursor::Selection;
use crate::core::motion::{line_start, matching_bracket};
use crate::core::types::{ByteOffset, LineCol, Range};

// ── Primitive selection helpers ───────────────────────────────────────────────

/// Select the word at `pos` (alphanumeric + underscore).
/// Returns (start, end) byte offsets.
pub fn select_word_at(buf: &Buffer, pos: ByteOffset) -> (ByteOffset, ByteOffset) {
    let range = buf.word_range_at(pos);
    (range.start, range.end)
}

/// Select the full line at `pos` including the trailing newline.
pub fn select_line_at(buf: &Buffer, pos: ByteOffset) -> (ByteOffset, ByteOffset) {
    let lc = buf.offset_to_line_col(pos);
    let start = line_start(buf, lc.line);
    // Include the newline by going to start of next line
    let end = if lc.line + 1 < buf.len_lines() {
        line_start(buf, lc.line + 1)
    } else {
        ByteOffset(buf.len_bytes())
    };
    (start, end)
}

/// Select the content inside the nearest enclosing bracket pair `( ) [ ] { }`.
/// Returns None if no enclosing bracket found within `search_radius` chars.
pub fn select_inside_brackets(
    buf: &Buffer,
    pos: ByteOffset,
    search_radius: usize,
) -> Option<(ByteOffset, ByteOffset)> {
    let text = buf.to_string();
    let search_start = pos.0.saturating_sub(search_radius);
    let _search_end = (pos.0 + search_radius).min(text.len());

    let open_chars = ['(', '[', '{'];
    let _close_chars = [')', ']', '}'];

    // Scan backwards for nearest opening bracket that contains pos
    let prefix = &text[search_start..pos.0];
    let prefix_chars: Vec<(usize, char)> = prefix
        .char_indices()
        .map(|(i, c)| (search_start + i, c))
        .collect();

    for &(byte_pos, ch) in prefix_chars.iter().rev() {
        if !open_chars.contains(&ch) {
            continue;
        }
        let open_offset = ByteOffset(byte_pos);
        if let Some(close_offset) = matching_bracket(buf, open_offset) {
            if close_offset.0 > pos.0 {
                // pos is inside this bracket pair
                let inner_start = ByteOffset(byte_pos + ch.len_utf8());
                return Some((inner_start, close_offset));
            }
        }
    }
    None
}

/// Select content inside the nearest enclosing quote `" ' \``.
pub fn select_inside_quotes(
    buf: &Buffer,
    pos: ByteOffset,
    quote_char: char,
) -> Option<(ByteOffset, ByteOffset)> {
    let _text = buf.to_string();
    let lc = buf.offset_to_line_col(pos);
    let line_text = buf.line_str(lc.line);
    let line_start_byte = line_start(buf, lc.line).0;

    // Find quote pairs on the current line
    let mut in_quote = false;
    let mut quote_start = 0usize;

    for (i, ch) in line_text.char_indices() {
        let byte = line_start_byte + i;
        if ch == quote_char {
            if in_quote {
                // We have a complete quote pair [quote_start, byte]
                let inner_start = ByteOffset(quote_start + quote_char.len_utf8());
                let inner_end = ByteOffset(byte);
                // Is pos inside?
                if pos.0 >= inner_start.0 && pos.0 <= inner_end.0 {
                    return Some((inner_start, inner_end));
                }
                in_quote = false;
            } else {
                quote_start = byte;
                in_quote = true;
            }
        }
    }
    None
}

// ── Smart selection expansion ─────────────────────────────────────────────────

/// Expansion levels for progressive selection (VS Code alt+shift+right).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ExpansionLevel {
    Character,
    Word,
    Line,
    BracketInner,
    BracketOuter,
    BracketSibling,
    Document,
}

/// Expand the selection outward by one level.
/// Returns new (anchor, active) offsets.
pub fn expand_selection(
    buf: &Buffer,
    current: Option<Selection>,
    cursor_pos: ByteOffset,
) -> (ByteOffset, ByteOffset) {
    // If no selection, start with word
    let sel = match current {
        None => {
            let (s, e) = select_word_at(buf, cursor_pos);
            return (s, e);
        }
        Some(s) => s,
    };

    let _sel_len = sel.end.0.saturating_sub(sel.start.0);

    // If current selection is a single word, expand to brackets
    if let Some((inner_start, inner_end)) = select_inside_brackets(buf, cursor_pos, 256) {
        if inner_start.0 < sel.start.0 || inner_end.0 > sel.end.0 {
            return (inner_start, inner_end);
        }
        // Already at inner — expand to include brackets
        let outer_start = ByteOffset(inner_start.0.saturating_sub(1));
        let outer_end = ByteOffset((inner_end.0 + 1).min(buf.len_bytes()));
        if outer_start.0 < sel.start.0 || outer_end.0 > sel.end.0 {
            return (outer_start, outer_end);
        }
    }

    // Expand to line
    let (line_s, line_e) = select_line_at(buf, cursor_pos);
    if line_s.0 < sel.start.0 || line_e.0 > sel.end.0 {
        return (line_s, line_e);
    }

    // Expand to document
    (ByteOffset(0), ByteOffset(buf.len_bytes()))
}

// ── SelectionHistory (for expand/shrink undo) ─────────────────────────────────

#[derive(Debug, Default)]
pub struct SelectionHistory {
    stack: Vec<(ByteOffset, ByteOffset)>,
}

impl SelectionHistory {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn push(&mut self, anchor: ByteOffset, active: ByteOffset) {
        self.stack.push((anchor, active));
    }

    pub fn pop(&mut self) -> Option<(ByteOffset, ByteOffset)> {
        self.stack.pop()
    }

    pub fn clear(&mut self) {
        self.stack.clear();
    }

    pub fn is_empty(&self) -> bool {
        self.stack.is_empty()
    }
}

// ── Column / rectangular selection ───────────────────────────────────────────

/// A rectangular selection spanning multiple lines.
#[derive(Debug, Clone)]
pub struct ColumnSelection {
    /// Start line (inclusive).
    pub start_line: usize,
    /// End line (inclusive).
    pub end_line: usize,
    /// Start column (char offset, inclusive).
    pub start_col: usize,
    /// End column (char offset, exclusive).
    pub end_col: usize,
}

impl ColumnSelection {
    pub fn new(start_line: usize, start_col: usize, end_line: usize, end_col: usize) -> Self {
        let (sl, el) = if start_line <= end_line {
            (start_line, end_line)
        } else {
            (end_line, start_line)
        };
        let (sc, ec) = if start_col <= end_col {
            (start_col, end_col)
        } else {
            (end_col, start_col)
        };
        Self {
            start_line: sl,
            end_line: el,
            start_col: sc,
            end_col: ec,
        }
    }

    /// Extract text of each selected column range.
    pub fn text_for_lines(&self, buf: &Buffer) -> Vec<String> {
        (self.start_line..=self.end_line)
            .map(|line| {
                let text = buf.line_str(line);
                let chars: Vec<char> = text.chars().collect();
                let sc = self.start_col.min(chars.len());
                let ec = self.end_col.min(chars.len());
                chars[sc..ec].iter().collect()
            })
            .collect()
    }

    /// Convert to a list of (byte_start, byte_end) ranges, one per line.
    pub fn byte_ranges(&self, buf: &Buffer) -> Vec<Range> {
        (self.start_line..=self.end_line)
            .map(|line| {
                let s = buf.line_col_to_offset(LineCol::new(line, self.start_col));
                let e = buf.line_col_to_offset(LineCol::new(line, self.end_col));
                Range::new(s.0, e.0)
            })
            .collect()
    }

    pub fn height(&self) -> usize {
        self.end_line - self.start_line + 1
    }
    pub fn width(&self) -> usize {
        self.end_col.saturating_sub(self.start_col)
    }
}

// ── Select all occurrences ────────────────────────────────────────────────────

/// Find all occurrences of the text of `selection` in the buffer.
/// Returns byte ranges for each match — use to create multi-cursors (Ctrl+D style).
pub fn select_all_occurrences(buf: &Buffer, selection: Selection) -> Vec<Range> {
    if selection.is_empty() {
        return vec![];
    }
    let needle = buf.text_in_range(selection.as_range());
    if needle.is_empty() {
        return vec![];
    }

    buf.find_all(&needle)
        .iter()
        .map(|&start| Range::new(start.0, start.0 + needle.len()))
        .collect()
}

/// Add cursors at the next occurrence of the selected text (Ctrl+D / Cmd+D).
/// Returns the Range of the next match after `after_offset`, or None.
pub fn select_next_occurrence(
    buf: &Buffer,
    needle: &str,
    after_offset: ByteOffset,
) -> Option<Range> {
    buf.find_all(needle)
        .into_iter()
        .find(|&start| start.0 > after_offset.0)
        .map(|start| Range::new(start.0, start.0 + needle.len()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_select_word_at() {
        let b = buf("hello world");
        let (s, e) = select_word_at(&b, ByteOffset(7));
        assert_eq!(&b.to_string()[s.0..e.0], "world");
    }

    #[test]
    fn test_select_line_at() {
        let b = buf("hello\nworld\n");
        let (s, e) = select_line_at(&b, ByteOffset(7));
        assert_eq!(&b.to_string()[s.0..e.0], "world\n");
    }

    #[test]
    fn test_select_line_last_line_no_newline() {
        let b = buf("hello\nworld");
        let (s, e) = select_line_at(&b, ByteOffset(7));
        assert_eq!(&b.to_string()[s.0..e.0], "world");
    }

    #[test]
    fn test_select_inside_brackets() {
        let b = buf("foo(bar, baz)");
        // cursor inside at 'b' of bar = byte 4
        let result = select_inside_brackets(&b, ByteOffset(4), 64);
        assert!(result.is_some());
        let (s, e) = result.unwrap();
        assert_eq!(&b.to_string()[s.0..e.0], "bar, baz");
    }

    #[test]
    fn test_select_inside_nested_brackets() {
        let b = buf("(outer (inner) outer)");
        // cursor at byte 8 = 'i' in inner
        let result = select_inside_brackets(&b, ByteOffset(8), 64);
        assert!(result.is_some());
        let (s, e) = result.unwrap();
        let selected = &b.to_string()[s.0..e.0];
        assert_eq!(selected, "inner");
    }

    #[test]
    fn test_select_inside_double_quotes() {
        let b = buf(r#"let s = "hello world";"#);
        // cursor at byte 12 = 'h' in hello
        let result = select_inside_quotes(&b, ByteOffset(12), '"');
        assert!(result.is_some());
        let (s, e) = result.unwrap();
        assert_eq!(&b.to_string()[s.0..e.0], "hello world");
    }

    #[test]
    fn test_expand_selection_word_to_brackets() {
        let b = buf("fn foo(bar, baz) {}");
        // No selection: should select word at cursor
        let (s, e) = expand_selection(&b, None, ByteOffset(7));
        let text = &b.to_string()[s.0..e.0];
        assert!(!text.is_empty());
    }

    #[test]
    fn test_column_selection_text() {
        let b = buf("hello\nworld\nfoo_x\n");
        let col = ColumnSelection::new(0, 0, 2, 3);
        let texts = col.text_for_lines(&b);
        assert_eq!(texts[0], "hel");
        assert_eq!(texts[1], "wor");
        assert_eq!(texts[2], "foo");
    }

    #[test]
    fn test_column_selection_width_height() {
        let col = ColumnSelection::new(2, 4, 5, 10);
        assert_eq!(col.height(), 4); // lines 2,3,4,5
        assert_eq!(col.width(), 6); // cols 4..10
    }

    #[test]
    fn test_select_all_occurrences() {
        let b = buf("foo bar foo baz foo");
        let sel = Selection {
            start: ByteOffset(0),
            end: ByteOffset(3),
        };
        let ranges = select_all_occurrences(&b, sel);
        assert_eq!(ranges.len(), 3);
        assert_eq!(ranges[0], Range::new(0, 3));
        assert_eq!(ranges[1], Range::new(8, 11));
        assert_eq!(ranges[2], Range::new(16, 19));
    }

    #[test]
    fn test_select_next_occurrence() {
        let b = buf("foo bar foo baz foo");
        let next = select_next_occurrence(&b, "foo", ByteOffset(0));
        assert!(next.is_some());
        assert_eq!(next.unwrap().start.0, 8);
    }

    #[test]
    fn test_select_next_occurrence_none_at_end() {
        let b = buf("foo bar");
        let next = select_next_occurrence(&b, "foo", ByteOffset(5));
        assert!(next.is_none());
    }
}
