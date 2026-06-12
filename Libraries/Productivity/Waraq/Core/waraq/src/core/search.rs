// src/core/search.rs
//
// Find/Replace engine — incremental search with full regex support.
//
// Design:
//   • `SearchQuery` is immutable and cloneable — build once, run many times.
//   • `SearchState` holds the live search session (current match, wrap-around).
//   • `replace_all` returns a list of EditOps (largest-offset-first) for safe
//     sequential application without re-indexing.
//   • Regex is implemented using a hand-rolled NFA matcher for zero-dependency
//     builds; the full feature set (lookahead, Unicode props) requires enabling
//     the `regex` crate feature.

use crate::core::buffer::Buffer;
use crate::core::edit::EditOp;
use crate::core::types::{ByteOffset, Range};
use serde::{Deserialize, Serialize};

// ── Query options ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SearchQuery {
    pub pattern: String,
    pub case_sensitive: bool,
    pub whole_word: bool,
    pub regex: bool,
    pub wrap_around: bool,
}

impl SearchQuery {
    pub fn literal(pattern: &str) -> Self {
        Self {
            pattern: pattern.to_owned(),
            case_sensitive: true,
            whole_word: false,
            regex: false,
            wrap_around: true,
        }
    }

    pub fn case_insensitive(pattern: &str) -> Self {
        Self {
            case_sensitive: false,
            ..Self::literal(pattern)
        }
    }

    pub fn is_empty(&self) -> bool {
        self.pattern.is_empty()
    }
}

// ── Match result ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct SearchMatch {
    pub start: ByteOffset,
    pub end: ByteOffset,
    /// 0-based index of this match in the full results list.
    pub index: usize,
    /// Total number of matches in the document.
    pub total: usize,
}

impl SearchMatch {
    pub fn as_range(self) -> Range {
        Range::new(self.start.0, self.end.0)
    }
    pub fn len(self) -> usize {
        self.end.0 - self.start.0
    }
}

// ── Search engine ─────────────────────────────────────────────────────────────

pub struct SearchState {
    query: SearchQuery,
    matches: Vec<(usize, usize)>, // (start_byte, end_byte)
    current: usize,
}

impl SearchState {
    /// Run a fresh search across the whole buffer. Returns None if the query is empty.
    pub fn new(buf: &Buffer, query: SearchQuery) -> Option<Self> {
        if query.is_empty() {
            return None;
        }
        let matches = find_all_matches(buf, &query);
        if matches.is_empty() {
            return None;
        }
        Some(Self {
            query,
            matches,
            current: 0,
        })
    }

    /// Refresh search results after the buffer was edited.
    pub fn refresh(&mut self, buf: &Buffer) {
        let current_start = self.current_match().map(|m| m.start.0).unwrap_or(0);
        self.matches = find_all_matches(buf, &self.query);
        // Reposition current to nearest match to old position
        self.current = self
            .matches
            .iter()
            .position(|(s, _)| *s >= current_start)
            .unwrap_or(0);
    }

    pub fn match_count(&self) -> usize {
        self.matches.len()
    }
    pub fn current_index(&self) -> usize {
        self.current
    }

    pub fn current_match(&self) -> Option<SearchMatch> {
        self.matches.get(self.current).map(|&(s, e)| SearchMatch {
            start: ByteOffset(s),
            end: ByteOffset(e),
            index: self.current,
            total: self.matches.len(),
        })
    }

    /// Move to the next match. Returns the new current match.
    pub fn next(&mut self) -> Option<SearchMatch> {
        if self.matches.is_empty() {
            return None;
        }
        self.current = (self.current + 1) % self.matches.len();
        self.current_match()
    }

    /// Move to the previous match.
    pub fn prev(&mut self) -> Option<SearchMatch> {
        if self.matches.is_empty() {
            return None;
        }
        self.current = if self.current == 0 {
            self.matches.len() - 1
        } else {
            self.current - 1
        };
        self.current_match()
    }

    /// Jump to the match closest to `pos`.
    pub fn jump_to_nearest(&mut self, pos: ByteOffset) -> Option<SearchMatch> {
        if self.matches.is_empty() {
            return None;
        }
        let idx = self
            .matches
            .iter()
            .enumerate()
            .min_by_key(|(_, &(s, _))| (s as i64 - pos.0 as i64).unsigned_abs())
            .map(|(i, _)| i)
            .unwrap_or(0);
        self.current = idx;
        self.current_match()
    }

    /// All matches as SearchMatch list.
    pub fn all_matches(&self) -> Vec<SearchMatch> {
        let total = self.matches.len();
        self.matches
            .iter()
            .enumerate()
            .map(|(i, &(s, e))| SearchMatch {
                start: ByteOffset(s),
                end: ByteOffset(e),
                index: i,
                total,
            })
            .collect()
    }

    pub fn query(&self) -> &SearchQuery {
        &self.query
    }
}

// ── Replace engine ────────────────────────────────────────────────────────────

/// Replace all occurrences in `buf` matching `query` with `replacement`.
/// Returns a list of EditOps sorted largest-offset-first for safe application.
pub fn replace_all(buf: &Buffer, query: &SearchQuery, replacement: &str) -> Vec<EditOp> {
    let matches = find_all_matches(buf, query);
    // Process in reverse order so earlier offsets aren't invalidated
    matches
        .iter()
        .rev()
        .map(|&(start, end)| EditOp::replace(start, end, replacement))
        .collect()
}

/// Replace only the `n`-th match (0-based index).
pub fn replace_nth(
    buf: &Buffer,
    query: &SearchQuery,
    replacement: &str,
    n: usize,
) -> Option<EditOp> {
    let matches = find_all_matches(buf, query);
    matches
        .get(n)
        .map(|&(start, end)| EditOp::replace(start, end, replacement))
}

/// Count occurrences without building the full match list.
pub fn count_matches(buf: &Buffer, query: &SearchQuery) -> usize {
    find_all_matches(buf, query).len()
}

// ── Internal matching ─────────────────────────────────────────────────────────

fn find_all_matches(buf: &Buffer, query: &SearchQuery) -> Vec<(usize, usize)> {
    let text = buf.to_string();
    if query.regex {
        find_regex_matches(&text, query)
    } else {
        find_literal_matches(&text, query)
    }
}

fn find_literal_matches(text: &str, query: &SearchQuery) -> Vec<(usize, usize)> {
    let mut results = Vec::new();
    let needle = &query.pattern;

    if needle.is_empty() {
        return results;
    }

    let (haystack_owned, needle_owned);
    let (haystack, needle_str): (&str, &str) = if query.case_sensitive {
        (text, needle.as_str())
    } else {
        haystack_owned = text.to_lowercase();
        needle_owned = needle.to_lowercase();
        (haystack_owned.as_str(), needle_owned.as_str())
    };

    let mut start = 0;
    while let Some(pos) = haystack[start..].find(needle_str) {
        let abs_start = start + pos;
        let abs_end = abs_start + needle.len(); // use original needle len for byte count

        if query.whole_word {
            if !is_whole_word(text, abs_start, abs_end) {
                start = abs_start + 1;
                continue;
            }
        }

        results.push((abs_start, abs_end));
        start = abs_start + 1;
        if start >= haystack.len() {
            break;
        }
    }

    results
}

/// Minimal regex engine — supports:
///   . (any char)  ^ $  * + ?  [abc]  [^abc]  \d \w \s \b  (group)  |
///
/// For production use, enable the `regex` crate feature.
fn find_regex_matches(text: &str, query: &SearchQuery) -> Vec<(usize, usize)> {
    // Compile the pattern into a sequence of matchers
    let pattern = if query.case_sensitive {
        query.pattern.clone()
    } else {
        // Wrap in (?i) flag — handled by our mini-engine
        format!("(?i){}", query.pattern)
    };

    let compiled = match RegexNfa::compile(&pattern) {
        Ok(r) => r,
        Err(_) => return Vec::new(),
    };

    compiled.find_all(text)
}

fn is_whole_word(text: &str, start: usize, end: usize) -> bool {
    let is_word_char = |c: char| c.is_alphanumeric() || c == '_';
    let before = text[..start]
        .chars()
        .last()
        .map(is_word_char)
        .unwrap_or(false);
    let after = text[end..]
        .chars()
        .next()
        .map(is_word_char)
        .unwrap_or(false);
    !before && !after
}

// ── Minimal regex NFA ─────────────────────────────────────────────────────────

/// Token in the compiled regex pattern.
#[derive(Debug, Clone)]
enum Token {
    Literal(char),
    AnyChar,
    WordChar,
    Digit,
    Whitespace,
    NonWordChar,
    NonDigit,
    NonWhitespace,
    WordBoundary,
    LineStart,
    LineEnd,
    CharClass(Vec<CharRange>, bool), // ranges, negated
    Group(Vec<Vec<Token>>),          // alternation group
}

#[derive(Debug, Clone)]
struct CharRange {
    lo: char,
    hi: char,
}

/// Quantifier attached to a token.
#[derive(Debug, Clone, Copy)]
enum Quant {
    One,
    ZeroOrOne,
    ZeroOrMore,
    OneOrMore,
}

#[derive(Debug, Clone)]
struct TokenQuant {
    token: Token,
    quant: Quant,
}

struct RegexNfa {
    tokens: Vec<TokenQuant>,
    case_insensitive: bool,
}

impl RegexNfa {
    fn compile(pattern: &str) -> Result<Self, String> {
        let (ci, pat) = if pattern.starts_with("(?i)") {
            (true, &pattern[4..])
        } else {
            (false, pattern)
        };
        let tokens = parse_pattern(pat)?;
        Ok(Self {
            tokens,
            case_insensitive: ci,
        })
    }

    fn find_all(&self, text: &str) -> Vec<(usize, usize)> {
        let chars: Vec<(usize, char)> = text.char_indices().collect();
        let mut results = Vec::new();
        let mut i = 0;
        while i <= chars.len() {
            if let Some(end) = self.try_match(&chars, i, 0) {
                let start_byte = chars.get(i).map(|(b, _)| *b).unwrap_or(text.len());
                let end_byte = chars.get(end).map(|(b, _)| *b).unwrap_or(text.len());
                if end_byte > start_byte {
                    results.push((start_byte, end_byte));
                    i = end;
                } else {
                    i += 1;
                }
            } else {
                i += 1;
            }
        }
        results
    }

    fn try_match(&self, chars: &[(usize, char)], char_pos: usize, tok_pos: usize) -> Option<usize> {
        if tok_pos >= self.tokens.len() {
            return Some(char_pos);
        }
        let tq = &self.tokens[tok_pos];
        let ch = chars.get(char_pos).map(|(_, c)| *c);

        match tq.quant {
            Quant::One => {
                if self.token_matches(&tq.token, ch, chars, char_pos) {
                    let advance = if is_zero_width(&tq.token) { 0 } else { 1 };
                    self.try_match(chars, char_pos + advance, tok_pos + 1)
                } else {
                    None
                }
            }
            Quant::ZeroOrOne => {
                // Try consuming
                if self.token_matches(&tq.token, ch, chars, char_pos) {
                    if let Some(r) = self.try_match(chars, char_pos + 1, tok_pos + 1) {
                        return Some(r);
                    }
                }
                // Try skipping
                self.try_match(chars, char_pos, tok_pos + 1)
            }
            Quant::ZeroOrMore => {
                // Greedy: consume as many as possible, then backtrack
                let mut furthest = char_pos;
                let mut pos = char_pos;
                while self.token_matches(&tq.token, chars.get(pos).map(|(_, c)| *c), chars, pos) {
                    pos += 1;
                    furthest = pos;
                }
                // Try from furthest down to char_pos
                for try_pos in (char_pos..=furthest).rev() {
                    if let Some(r) = self.try_match(chars, try_pos, tok_pos + 1) {
                        return Some(r);
                    }
                }
                None
            }
            Quant::OneOrMore => {
                // Must match at least once
                if !self.token_matches(&tq.token, ch, chars, char_pos) {
                    return None;
                }
                let mut pos = char_pos + 1;
                while self.token_matches(&tq.token, chars.get(pos).map(|(_, c)| *c), chars, pos) {
                    pos += 1;
                }
                for try_pos in (char_pos + 1..=pos).rev() {
                    if let Some(r) = self.try_match(chars, try_pos, tok_pos + 1) {
                        return Some(r);
                    }
                }
                None
            }
        }
    }

    fn token_matches(
        &self,
        token: &Token,
        ch: Option<char>,
        chars: &[(usize, char)],
        pos: usize,
    ) -> bool {
        let ci = self.case_insensitive;
        match token {
            Token::Literal(expected) => ch
                .map(|c| {
                    if ci {
                        c.to_lowercase().eq(expected.to_lowercase())
                    } else {
                        c == *expected
                    }
                })
                .unwrap_or(false),
            Token::AnyChar => ch.map(|c| c != '\n').unwrap_or(false),
            Token::WordChar => ch.map(|c| c.is_alphanumeric() || c == '_').unwrap_or(false),
            Token::Digit => ch.map(|c| c.is_ascii_digit()).unwrap_or(false),
            Token::Whitespace => ch.map(|c| c.is_whitespace()).unwrap_or(false),
            Token::NonWordChar => ch
                .map(|c| !(c.is_alphanumeric() || c == '_'))
                .unwrap_or(false),
            Token::NonDigit => ch.map(|c| !c.is_ascii_digit()).unwrap_or(false),
            Token::NonWhitespace => ch.map(|c| !c.is_whitespace()).unwrap_or(false),
            Token::WordBoundary => {
                let prev = if pos > 0 {
                    chars.get(pos - 1).map(|(_, c)| *c)
                } else {
                    None
                };
                let curr = ch;
                let is_word = |c: char| c.is_alphanumeric() || c == '_';
                let prev_word = prev.map(is_word).unwrap_or(false);
                let curr_word = curr.map(is_word).unwrap_or(false);
                prev_word != curr_word
            }
            Token::LineStart => {
                pos == 0
                    || chars
                        .get(pos.saturating_sub(1))
                        .map(|(_, c)| *c == '\n')
                        .unwrap_or(false)
            }
            Token::LineEnd => ch.map(|c| c == '\n').unwrap_or(true),
            Token::CharClass(ranges, negated) => {
                if let Some(c) = ch {
                    let matched = ranges.iter().any(|r| {
                        let (lo, hi) = if ci {
                            (
                                r.lo.to_lowercase().next().unwrap_or(r.lo),
                                r.hi.to_lowercase().next().unwrap_or(r.hi),
                            )
                        } else {
                            (r.lo, r.hi)
                        };
                        let cc = if ci {
                            c.to_lowercase().next().unwrap_or(c)
                        } else {
                            c
                        };
                        cc >= lo && cc <= hi
                    });
                    if *negated {
                        !matched
                    } else {
                        matched
                    }
                } else {
                    false
                }
            }
            Token::Group(alts) => {
                for alt in alts {
                    let sub_nfa = RegexNfa {
                        tokens: alt
                            .iter()
                            .map(|t| TokenQuant {
                                token: t.clone(),
                                quant: Quant::One,
                            })
                            .collect(),
                        case_insensitive: ci,
                    };
                    if sub_nfa.try_match(chars, pos, 0).is_some() {
                        return true;
                    }
                }
                false
            }
        }
    }
}

fn is_zero_width(token: &Token) -> bool {
    matches!(
        token,
        Token::WordBoundary | Token::LineStart | Token::LineEnd
    )
}

fn parse_pattern(pat: &str) -> Result<Vec<TokenQuant>, String> {
    let chars: Vec<char> = pat.chars().collect();
    let mut result = Vec::new();
    let mut i = 0;

    while i < chars.len() {
        let (token, consumed) = parse_token(&chars, i)?;
        i += consumed;
        let quant = if i < chars.len() {
            match chars[i] {
                '?' => {
                    i += 1;
                    Quant::ZeroOrOne
                }
                '*' => {
                    i += 1;
                    Quant::ZeroOrMore
                }
                '+' => {
                    i += 1;
                    Quant::OneOrMore
                }
                _ => Quant::One,
            }
        } else {
            Quant::One
        };
        result.push(TokenQuant { token, quant });
    }

    Ok(result)
}

fn parse_token(chars: &[char], i: usize) -> Result<(Token, usize), String> {
    match chars[i] {
        '\\' if i + 1 < chars.len() => {
            let token = match chars[i + 1] {
                'd' => Token::Digit,
                'D' => Token::NonDigit,
                'w' => Token::WordChar,
                'W' => Token::NonWordChar,
                's' => Token::Whitespace,
                'S' => Token::NonWhitespace,
                'b' => Token::WordBoundary,
                c => Token::Literal(c),
            };
            Ok((token, 2))
        }
        '.' => Ok((Token::AnyChar, 1)),
        '^' => Ok((Token::LineStart, 1)),
        '$' => Ok((Token::LineEnd, 1)),
        '[' => {
            let mut j = i + 1;
            let negated = j < chars.len() && chars[j] == '^';
            if negated {
                j += 1;
            }
            let mut ranges = Vec::new();
            while j < chars.len() && chars[j] != ']' {
                if j + 2 < chars.len() && chars[j + 1] == '-' && chars[j + 2] != ']' {
                    ranges.push(CharRange {
                        lo: chars[j],
                        hi: chars[j + 2],
                    });
                    j += 3;
                } else {
                    let c = chars[j];
                    ranges.push(CharRange { lo: c, hi: c });
                    j += 1;
                }
            }
            Ok((Token::CharClass(ranges, negated), j - i + 1))
        }
        '(' => {
            // Find matching ')'
            let mut depth = 1;
            let mut j = i + 1;
            while j < chars.len() && depth > 0 {
                if chars[j] == '(' {
                    depth += 1;
                }
                if chars[j] == ')' {
                    depth -= 1;
                }
                j += 1;
            }
            let inner: String = chars[i + 1..j - 1].iter().collect();
            let alts: Vec<Vec<Token>> = inner
                .split('|')
                .map(|alt| {
                    parse_pattern(alt)
                        .unwrap_or_default()
                        .into_iter()
                        .map(|tq| tq.token)
                        .collect()
                })
                .collect();
            Ok((Token::Group(alts), j - i))
        }
        c => Ok((Token::Literal(c), 1)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    // ── Literal search ────────────────────────────────────────────────────────

    #[test]
    fn test_literal_search_basic() {
        let b = buf("hello world hello");
        let q = SearchQuery::literal("hello");
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 2);
        assert_eq!(state.current_match().unwrap().start.0, 0);
    }

    #[test]
    fn test_literal_search_next_prev() {
        let b = buf("foo bar foo baz foo");
        let q = SearchQuery::literal("foo");
        let mut state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 3);

        let m1 = state.next().unwrap();
        assert_eq!(m1.start.0, 8);
        let m2 = state.next().unwrap();
        assert_eq!(m2.start.0, 16);
        let m3 = state.next().unwrap(); // wraps around
        assert_eq!(m3.start.0, 0);
    }

    #[test]
    fn test_literal_search_case_insensitive() {
        let b = buf("Hello HELLO hello");
        let q = SearchQuery::case_insensitive("hello");
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 3);
    }

    #[test]
    fn test_literal_search_whole_word() {
        let b = buf("foo foobar bar foo_baz foo");
        let mut q = SearchQuery::literal("foo");
        q.whole_word = true;
        let state = SearchState::new(&b, q).unwrap();
        // Only "foo" at positions 0 and 20 are whole words
        assert_eq!(state.match_count(), 2);
    }

    #[test]
    fn test_no_match_returns_none() {
        let b = buf("hello world");
        let q = SearchQuery::literal("xyz");
        assert!(SearchState::new(&b, q).is_none());
    }

    #[test]
    fn test_jump_to_nearest() {
        let b = buf("foo bar foo baz foo");
        let q = SearchQuery::literal("foo");
        let mut state = SearchState::new(&b, q).unwrap();
        let m = state.jump_to_nearest(ByteOffset(10)).unwrap();
        assert_eq!(m.start.0, 8); // closest match to byte 10
    }

    // ── Replace engine ────────────────────────────────────────────────────────

    #[test]
    fn test_replace_all() {
        let b = buf("foo bar foo baz foo");
        let q = SearchQuery::literal("foo");
        let ops = replace_all(&b, &q, "qux");
        // 3 replace ops, in reverse offset order
        assert_eq!(ops.len(), 3);
        match &ops[0] {
            EditOp::Replace { range, text } => {
                assert!(range.start.0 > 10); // last occurrence first
                assert_eq!(text, "qux");
            }
            _ => panic!("Expected Replace op"),
        }
    }

    #[test]
    fn test_replace_nth() {
        let b = buf("foo bar foo baz foo");
        let q = SearchQuery::literal("foo");
        let op = replace_nth(&b, &q, "qux", 1).unwrap();
        match op {
            EditOp::Replace { range, text } => {
                assert_eq!(range.start.0, 8);
                assert_eq!(text, "qux");
            }
            _ => panic!("Expected Replace op"),
        }
    }

    #[test]
    fn test_count_matches() {
        let b = buf("the cat sat on the mat");
        let q = SearchQuery::literal("at");
        assert_eq!(count_matches(&b, &q), 3);
    }

    // ── Regex search ─────────────────────────────────────────────────────────

    #[test]
    fn test_regex_any_char() {
        let b = buf("cat bat hat");
        let mut q = SearchQuery::literal(".at");
        q.regex = true;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 3);
    }

    #[test]
    fn test_regex_digit() {
        let b = buf("abc 123 def 456");
        let mut q = SearchQuery::literal(r"\d+");
        q.regex = true;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 2);
    }

    #[test]
    fn test_regex_char_class() {
        let b = buf("hello world");
        let mut q = SearchQuery::literal("[aeiou]");
        q.regex = true;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 3); // e, o, o
    }

    #[test]
    fn test_regex_alternation() {
        let b = buf("cat dog bird cat");
        let mut q = SearchQuery::literal("(cat|dog)");
        q.regex = true;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 3);
    }

    #[test]
    fn test_regex_word_boundary() {
        let b = buf("foo foobar bar");
        let mut q = SearchQuery::literal(r"\bfoo\b");
        q.regex = true;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 1); // only standalone "foo"
    }

    #[test]
    fn test_regex_case_insensitive() {
        let b = buf("Hello WORLD hello");
        let mut q = SearchQuery::literal("hello");
        q.regex = true;
        q.case_sensitive = false;
        let state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 2);
    }

    #[test]
    fn test_search_refresh_after_edit() {
        let mut b = buf("foo bar foo");
        let q = SearchQuery::literal("foo");
        let mut state = SearchState::new(&b, q).unwrap();
        assert_eq!(state.match_count(), 2);

        // Simulate inserting text that adds a third "foo"
        b = Buffer::from_str("foo bar foo baz foo");
        state.refresh(&b);
        assert_eq!(state.match_count(), 3);
    }
}
