// src/syntax/bracket.rs
//
// Bracket analysis — three distinct features:
//
//   1. Matching          — find the pair for the bracket under cursor
//   2. Rainbow levels    — assign a depth (0-N) to each bracket for rendering
//   3. Auto-close state  — track which brackets were auto-inserted so we can
//                          remove both when the user backspaces the opener
//
// All functions are pure (take &Buffer, return data structures).
// The FFI layer serialises RainbowBracket lists to the renderer.

use serde::{Deserialize, Serialize};

use crate::core::buffer::Buffer;
use crate::core::types::{ByteOffset, Range};

// ── Bracket pair types ────────────────────────────────────────────────────────

const PAIRS: &[(char, char)] = &[('(', ')'), ('[', ']'), ('{', '}')];

fn is_opener(c: char) -> bool {
    PAIRS.iter().any(|(o, _)| *o == c)
}
fn is_closer(c: char) -> bool {
    PAIRS.iter().any(|(_, cl)| *cl == c)
}

fn partner_of(c: char) -> Option<char> {
    for &(open, close) in PAIRS {
        if c == open {
            return Some(close);
        }
        if c == close {
            return Some(open);
        }
    }
    None
}

// ── Match result ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct BracketMatch {
    pub open: ByteOffset,
    pub close: ByteOffset,
}

/// Find the bracket pair containing / at `pos`.
/// Searches within ±`radius` characters for performance on large files.
pub fn find_matching_bracket(buf: &Buffer, pos: ByteOffset, radius: usize) -> Option<BracketMatch> {
    let text = buf.to_string();
    let chars: Vec<(usize, char)> = text.char_indices().collect();
    let idx = chars.iter().position(|(b, _)| *b == pos.0)?;
    let ch = chars[idx].1;

    if is_opener(ch) {
        let close_ch = partner_of(ch)?;
        let mut depth = 0i32;
        let end = (idx + radius).min(chars.len());
        for &(byte, c) in &chars[idx..end] {
            if c == ch {
                depth += 1;
            }
            if c == close_ch {
                depth -= 1;
            }
            if depth == 0 {
                return Some(BracketMatch {
                    open: ByteOffset(chars[idx].0),
                    close: ByteOffset(byte),
                });
            }
        }
    } else if is_closer(ch) {
        let open_ch = partner_of(ch)?;
        let mut depth = 0i32;
        let start = idx.saturating_sub(radius);
        for &(byte, c) in chars[start..=idx].iter().rev() {
            if c == ch {
                depth += 1;
            }
            if c == open_ch {
                depth -= 1;
            }
            if depth == 0 {
                return Some(BracketMatch {
                    open: ByteOffset(byte),
                    close: ByteOffset(chars[idx].0),
                });
            }
        }
    }
    None
}

// ── Rainbow bracket data ──────────────────────────────────────────────────────

/// A bracket with its nesting depth.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct RainbowBracket {
    pub byte_offset: usize,
    pub char_col: usize,
    pub line: usize,
    pub depth: u8, // 0-based nesting level
    pub is_opener: bool,
    pub kind: BracketKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BracketKind {
    Paren,
    Square,
    Curly,
}

impl BracketKind {
    fn from_char(c: char) -> Option<Self> {
        match c {
            '(' | ')' => Some(BracketKind::Paren),
            '[' | ']' => Some(BracketKind::Square),
            '{' | '}' => Some(BracketKind::Curly),
            _ => None,
        }
    }
}

/// Compute rainbow bracket data for the visible viewport lines.
/// Pass the full document text so depth counts are correct from the beginning.
pub fn rainbow_brackets_for_viewport(
    buf: &Buffer,
    first_line: usize,
    last_line: usize,
) -> Vec<RainbowBracket> {
    let text = buf.to_string();
    let mut depth: u8 = 0;
    let mut results = Vec::new();

    // Walk from the start so depth is accurate
    for (byte_offset, ch) in text.char_indices() {
        let lc = buf.offset_to_line_col(ByteOffset(byte_offset));
        let line = lc.line;

        let opener = is_opener(ch);
        let closer = is_closer(ch);

        if !opener && !closer {
            continue;
        }

        if closer && depth > 0 {
            depth -= 1;
        }

        if line >= first_line && line <= last_line {
            if let Some(kind) = BracketKind::from_char(ch) {
                results.push(RainbowBracket {
                    byte_offset,
                    char_col: lc.col,
                    line,
                    depth,
                    is_opener: opener,
                    kind,
                });
            }
        }

        if opener {
            depth = depth.saturating_add(1);
        }

        // Stop early once we're well past the viewport
        if line > last_line + 1 {
            break;
        }
    }

    results
}

// ── Auto-close tracking ───────────────────────────────────────────────────────

/// Tracks auto-inserted bracket pairs so backspace can remove both.
#[derive(Debug, Default)]
pub struct AutoCloseTracker {
    /// Stack of (opener_byte, closer_byte) pairs that were auto-inserted.
    pairs: Vec<(usize, usize)>,
}

impl AutoCloseTracker {
    pub fn new() -> Self {
        Self::default()
    }

    /// Record that we auto-inserted a pair at (opener_byte, closer_byte).
    pub fn push(&mut self, opener: usize, closer: usize) {
        self.pairs.push((opener, closer));
    }

    /// When the user backspaces at `pos`, check if we should also delete the
    /// auto-inserted closer. Returns Some(closer_byte) if yes.
    pub fn should_delete_pair(&mut self, pos: ByteOffset) -> Option<usize> {
        // pos is the byte AFTER the opener (cursor is between the pair)
        let opener_pos = pos.0.saturating_sub(1);
        let idx = self.pairs.iter().position(|(o, _)| *o == opener_pos)?;
        let (_, closer) = self.pairs.remove(idx);
        Some(closer)
    }

    /// Adjust stored byte offsets after an edit at `edit_start` with `byte_delta`.
    pub fn adjust(&mut self, edit_start: usize, byte_delta: i64) {
        for (o, c) in &mut self.pairs {
            if *o >= edit_start {
                *o = (*o as i64 + byte_delta).max(0) as usize;
            }
            if *c >= edit_start {
                *c = (*c as i64 + byte_delta).max(0) as usize;
            }
        }
    }

    /// Remove stale pairs (e.g. after undo).
    pub fn clear(&mut self) {
        self.pairs.clear();
    }

    pub fn len(&self) -> usize {
        self.pairs.len()
    }
}

// ── Bracket scope extractor ───────────────────────────────────────────────────

/// Return the byte range of the innermost bracket scope containing `pos`.
/// Useful for "select inside brackets" and code folding.
pub fn innermost_scope(buf: &Buffer, pos: ByteOffset) -> Option<Range> {
    let text = buf.to_string();
    let chars: Vec<(usize, char)> = text.char_indices().collect();
    let cur_idx = chars
        .iter()
        .position(|(b, _)| *b >= pos.0)
        .unwrap_or(chars.len());

    // Walk backward looking for an unmatched opener
    let mut depth = 0i32;
    let mut scope_open: Option<usize> = None;
    let mut open_char = '(';

    for &(byte, ch) in chars[..cur_idx].iter().rev() {
        if is_closer(ch) {
            depth += 1;
        }
        if is_opener(ch) {
            if depth == 0 {
                scope_open = Some(byte);
                open_char = ch;
                break;
            }
            depth -= 1;
        }
    }

    let open_byte = scope_open?;
    let close_ch = partner_of(open_char)?;

    // Walk forward from the opener to find the matching closer
    let open_idx = chars.iter().position(|(b, _)| *b == open_byte)?;
    let mut depth = 0i32;
    for &(byte, ch) in &chars[open_idx..] {
        if ch == open_char {
            depth += 1;
        }
        if ch == close_ch {
            depth -= 1;
        }
        if depth == 0 {
            return Some(Range::new(open_byte, byte + ch.len_utf8()));
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_find_matching_forward() {
        let b = buf("fn foo(a, b) {}");
        let m = find_matching_bracket(&b, ByteOffset(6), 1024).unwrap();
        assert_eq!(m.open.0, 6);
        assert_eq!(&b.to_string()[m.close.0..m.close.0 + 1], ")");
    }

    #[test]
    fn test_find_matching_backward() {
        let b = buf("fn foo(a, b) {}");
        let close_pos = b.to_string().find(')').unwrap();
        let m = find_matching_bracket(&b, ByteOffset(close_pos), 1024).unwrap();
        assert_eq!(m.open.0, 6);
        assert_eq!(m.close.0, close_pos);
    }

    #[test]
    fn test_find_matching_nested() {
        let b = buf("((a + (b)))");
        let m = find_matching_bracket(&b, ByteOffset(0), 1024).unwrap();
        assert_eq!(m.close.0, 10); // outermost )
    }

    #[test]
    fn test_no_match_on_non_bracket() {
        let b = buf("hello");
        assert!(find_matching_bracket(&b, ByteOffset(0), 1024).is_none());
    }

    #[test]
    fn test_rainbow_brackets_depth() {
        let b = buf("fn foo() {\n    bar()\n}\n");
        let brackets = rainbow_brackets_for_viewport(&b, 0, 10);
        // Find the outer '{'
        let outer_curly = brackets
            .iter()
            .find(|rb| rb.kind == BracketKind::Curly && rb.is_opener);
        assert!(outer_curly.is_some());
        assert_eq!(outer_curly.unwrap().depth, 0); // outermost
    }

    #[test]
    fn test_rainbow_brackets_nested_depth() {
        let b = buf("fn f(g(h()))");
        let brackets = rainbow_brackets_for_viewport(&b, 0, 0);
        let depths: Vec<u8> = brackets
            .iter()
            .filter(|rb| rb.is_opener)
            .map(|rb| rb.depth)
            .collect();
        // Three openers at increasing depths
        assert_eq!(depths, vec![0, 1, 2]);
    }

    #[test]
    fn test_auto_close_tracker_basic() {
        let mut tracker = AutoCloseTracker::new();
        // Auto-inserted "()" at positions 5 and 6
        tracker.push(5, 6);
        // User backspaces at position 6 (cursor between the pair)
        let closer = tracker.should_delete_pair(ByteOffset(6));
        assert_eq!(closer, Some(6));
        assert_eq!(tracker.len(), 0);
    }

    #[test]
    fn test_auto_close_tracker_adjust() {
        let mut tracker = AutoCloseTracker::new();
        tracker.push(10, 11);
        // Insert 3 bytes at position 5
        tracker.adjust(5, 3);
        // Offsets should have shifted
        assert_eq!(tracker.pairs[0], (13, 14));
    }

    #[test]
    fn test_innermost_scope() {
        let b = buf("fn main() {\n    foo(bar)\n}\n");
        // Cursor inside "bar" — byte ~20
        let scope = innermost_scope(&b, ByteOffset(21));
        assert!(scope.is_some());
        let r = scope.unwrap();
        // Should be the inner parentheses of foo(bar)
        let text = b.to_string();
        let scoped = &text[r.start.0..r.end.0];
        assert!(scoped.contains("bar") || scoped.contains("foo"));
    }

    #[test]
    fn test_innermost_scope_nested() {
        let b = buf("((a + b) * c)");
        // Cursor inside inner parens
        let scope = innermost_scope(&b, ByteOffset(3));
        assert!(scope.is_some());
        let r = scope.unwrap();
        assert_eq!(&b.to_string()[r.start.0..r.end.0], "(a + b)");
    }
}
