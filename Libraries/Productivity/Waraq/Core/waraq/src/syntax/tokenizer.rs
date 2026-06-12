// src/syntax/tokenizer.rs
//
// Tokenizer — wraps tree-sitter for incremental parsing.
// When tree-sitter is not available, falls back to a regex-based tokenizer.

use super::{Token, TokenKind};
use crate::core::buffer::Buffer;

/// Tracks which line ranges need re-tokenizing.
#[derive(Default)]
pub struct InvalidationSet {
    ranges: Vec<(usize, usize)>,
}

impl InvalidationSet {
    pub fn add(&mut self, first: usize, last: usize) {
        self.ranges.push((first, last));
    }

    pub fn clear(&mut self) {
        self.ranges.clear();
    }

    pub fn is_dirty(&self) -> bool {
        !self.ranges.is_empty()
    }
}

pub struct Tokenizer {
    invalidation: InvalidationSet,
}

impl Tokenizer {
    pub fn new() -> Self {
        Self {
            invalidation: InvalidationSet::default(),
        }
    }

    pub fn invalidate_range(&mut self, first: usize, last: usize) {
        self.invalidation.add(first, last);
    }

    pub fn is_dirty(&self) -> bool {
        self.invalidation.is_dirty()
    }
    pub fn clear(&mut self) {
        self.invalidation.clear();
    }

    /// Full tokenize — called on first open or language change.
    /// Returns tokens sorted by `start` byte offset.
    pub fn tokenize_full(&mut self, buffer: &Buffer, lang: &str) -> Vec<Token> {
        self.invalidation.clear();
        tokenize_buffer(buffer, lang)
    }

    /// Incremental tokenize — re-tokenize only dirty ranges.
    pub fn tokenize_incremental(&mut self, buffer: &Buffer, lang: &str, existing: &mut Vec<Token>) {
        if !self.invalidation.is_dirty() {
            return;
        }

        let dirty_ranges: Vec<_> = self.invalidation.ranges.drain(..).collect();
        for (first, last) in dirty_ranges {
            // Remove tokens in dirty range
            existing.retain(|t| t.line < first || t.line > last);
            // Re-tokenize and insert
            let new_tokens = tokenize_lines(buffer, lang, first, last + 1);
            existing.extend(new_tokens);
        }
        // Re-sort
        existing.sort_by_key(|t| t.start);
    }
}

/// Tokenize the entire buffer.
fn tokenize_buffer(buffer: &Buffer, lang: &str) -> Vec<Token> {
    tokenize_lines(buffer, lang, 0, buffer.len_lines())
}

/// Tokenize a range of lines [first_line, last_line).
fn tokenize_lines(buffer: &Buffer, lang: &str, first_line: usize, last_line: usize) -> Vec<Token> {
    let last_line = last_line.min(buffer.len_lines());
    let mut tokens = Vec::new();

    for line_num in first_line..last_line {
        let text = buffer.line_str(line_num);
        let line_byte_offset = buffer
            .line_col_to_offset(crate::core::types::LineCol::new(line_num, 0))
            .0;
        let line_tokens = tokenize_line(line_num, line_byte_offset, &text, lang);
        tokens.extend(line_tokens);
    }

    tokens
}

/// Single-line tokenizer — regex based fallback when tree-sitter is unavailable.
/// In production, this should delegate to tree-sitter.
fn tokenize_line(line: usize, byte_offset: usize, text: &str, lang: &str) -> Vec<Token> {
    match lang {
        "rust" => tokenize_rust_line(line, byte_offset, text),
        "javascript" | "typescript" => tokenize_js_line(line, byte_offset, text),
        "python" => tokenize_python_line(line, byte_offset, text),
        _ => tokenize_generic_line(line, byte_offset, text),
    }
}

/// Rust keywords for the fallback tokenizer
const RUST_KEYWORDS: &[&str] = &[
    "fn", "let", "mut", "pub", "use", "mod", "struct", "enum", "trait", "impl", "for", "while",
    "loop", "if", "else", "match", "return", "self", "Self", "const", "static", "type", "where",
    "async", "await", "move", "ref", "in", "box", "dyn", "extern", "crate", "super", "unsafe",
    "true", "false",
];

const JS_KEYWORDS: &[&str] = &[
    "const",
    "let",
    "var",
    "function",
    "class",
    "return",
    "if",
    "else",
    "for",
    "while",
    "do",
    "switch",
    "case",
    "break",
    "continue",
    "new",
    "delete",
    "typeof",
    "instanceof",
    "import",
    "export",
    "default",
    "async",
    "await",
    "yield",
    "try",
    "catch",
    "finally",
    "throw",
    "true",
    "false",
    "null",
    "undefined",
    "this",
    "super",
    "extends",
    "static",
    "get",
    "set",
    "of",
    "in",
    "from",
    "as",
];

const PYTHON_KEYWORDS: &[&str] = &[
    "def", "class", "import", "from", "as", "return", "if", "elif", "else", "for", "while",
    "break", "continue", "pass", "lambda", "with", "try", "except", "finally", "raise", "yield",
    "global", "nonlocal", "del", "True", "False", "None", "and", "or", "not", "in", "is",
];

fn tokenize_rust_line(line: usize, byte_offset: usize, text: &str) -> Vec<Token> {
    tokenize_with_keywords(line, byte_offset, text, RUST_KEYWORDS, "//")
}

fn tokenize_js_line(line: usize, byte_offset: usize, text: &str) -> Vec<Token> {
    tokenize_with_keywords(line, byte_offset, text, JS_KEYWORDS, "//")
}

fn tokenize_python_line(line: usize, byte_offset: usize, text: &str) -> Vec<Token> {
    tokenize_with_keywords(line, byte_offset, text, PYTHON_KEYWORDS, "#")
}

fn tokenize_generic_line(line: usize, byte_offset: usize, text: &str) -> Vec<Token> {
    tokenize_with_keywords(line, byte_offset, text, &[], "//")
}

/// Simple character-walking tokenizer.
/// Production should replace this with tree-sitter.
fn tokenize_with_keywords(
    line: usize,
    byte_offset: usize,
    text: &str,
    keywords: &[&str],
    line_comment: &str,
) -> Vec<Token> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = text.chars().collect();
    let mut i = 0;

    // Check if the entire line is a comment
    let trimmed = text.trim_start();
    if trimmed.starts_with(line_comment) {
        let col_start = text.len() - trimmed.len();
        tokens.push(Token {
            start: byte_offset + col_start,
            end: byte_offset + text.len(),
            kind: TokenKind::Comment,
            line,
            col_start,
            col_end: text.len(),
        });
        return tokens;
    }

    while i < chars.len() {
        let ch = chars[i];

        // String literals
        if ch == '"' || ch == '\'' || ch == '`' {
            let quote = ch;
            let col_start = i;
            let byte_start = byte_offset + char_col_to_byte(text, i);
            i += 1;
            while i < chars.len() && chars[i] != quote {
                if chars[i] == '\\' {
                    i += 1;
                } // escape
                i += 1;
            }
            i += 1; // closing quote
            let byte_end = byte_offset + char_col_to_byte(text, i.min(chars.len()));
            tokens.push(Token {
                start: byte_start,
                end: byte_end,
                kind: TokenKind::String,
                line,
                col_start,
                col_end: i,
            });
            continue;
        }

        // Numbers
        if ch.is_ascii_digit()
            || (ch == '-' && i + 1 < chars.len() && chars[i + 1].is_ascii_digit())
        {
            let col_start = i;
            let byte_start = byte_offset + char_col_to_byte(text, i);
            while i < chars.len()
                && (chars[i].is_ascii_alphanumeric() || chars[i] == '.' || chars[i] == '_')
            {
                i += 1;
            }
            let byte_end = byte_offset + char_col_to_byte(text, i);
            tokens.push(Token {
                start: byte_start,
                end: byte_end,
                kind: TokenKind::Number,
                line,
                col_start,
                col_end: i,
            });
            continue;
        }

        // Identifiers / keywords
        if ch.is_alphabetic() || ch == '_' {
            let col_start = i;
            let byte_start = byte_offset + char_col_to_byte(text, i);
            while i < chars.len() && (chars[i].is_alphanumeric() || chars[i] == '_') {
                i += 1;
            }
            let word: String = chars[col_start..i].iter().collect();
            let byte_end = byte_offset + char_col_to_byte(text, i);
            let kind = if keywords.contains(&word.as_str()) {
                TokenKind::Keyword
            } else if i < chars.len() && chars[i] == '(' {
                TokenKind::Function
            } else if word
                .chars()
                .next()
                .map(|c| c.is_uppercase())
                .unwrap_or(false)
            {
                TokenKind::Type
            } else {
                TokenKind::Variable
            };
            tokens.push(Token {
                start: byte_start,
                end: byte_end,
                kind,
                line,
                col_start,
                col_end: i,
            });
            continue;
        }

        // Operators
        if "+-*/%=<>!&|^~".contains(ch) {
            let byte_start = byte_offset + char_col_to_byte(text, i);
            i += 1;
            let byte_end = byte_offset + char_col_to_byte(text, i);
            tokens.push(Token {
                start: byte_start,
                end: byte_end,
                kind: TokenKind::Operator,
                line,
                col_start: i - 1,
                col_end: i,
            });
            continue;
        }

        // Punctuation
        if "(){}[];:,.".contains(ch) {
            let byte_start = byte_offset + char_col_to_byte(text, i);
            i += 1;
            let byte_end = byte_offset + char_col_to_byte(text, i);
            tokens.push(Token {
                start: byte_start,
                end: byte_end,
                kind: TokenKind::Punctuation,
                line,
                col_start: i - 1,
                col_end: i,
            });
            continue;
        }

        i += 1;
    }

    tokens
}

/// Convert a char index to a byte index within a &str.
fn char_col_to_byte(s: &str, char_col: usize) -> usize {
    s.char_indices()
        .nth(char_col)
        .map(|(b, _)| b)
        .unwrap_or(s.len())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;
    use crate::syntax::TokenKind;

    fn tok(lang: &str, src: &str) -> Vec<crate::syntax::Token> {
        let buf = Buffer::from_str(src);
        let mut t = Tokenizer::new();
        t.tokenize_full(&buf, lang)
    }

    #[test]
    fn test_rust_keywords() {
        let tokens = tok("rust", "fn main() { let x = 1; }");
        let kws: Vec<_> = tokens
            .iter()
            .filter(|t| t.kind == TokenKind::Keyword)
            .collect();
        assert!(!kws.is_empty(), "Should find Rust keywords");
        let kw_texts: Vec<String> = kws
            .iter()
            .map(|t| {
                let s = "fn main() { let x = 1; }";
                s[t.start..t.end.min(s.len())].to_owned()
            })
            .collect();
        assert!(kw_texts.iter().any(|k| k == "fn" || k == "let"));
    }

    #[test]
    fn test_rust_string_literal() {
        let src = "let s = \"hello world\";";
        let tokens = tok("rust", src);
        assert!(tokens.iter().any(|t| t.kind == TokenKind::String));
    }

    #[test]
    fn test_rust_number_literal() {
        let src = "let x = 42;";
        let tokens = tok("rust", src);
        assert!(tokens.iter().any(|t| t.kind == TokenKind::Number));
    }

    #[test]
    fn test_rust_line_comment() {
        let src = "// this is a comment\nlet x = 1;";
        let tokens = tok("rust", src);
        assert!(
            tokens.iter().any(|t| t.kind == TokenKind::Comment),
            "Should find comment token"
        );
    }

    #[test]
    fn test_rust_function_call() {
        let src = "fn greet() { println!(\"hi\"); }";
        let tokens = tok("rust", src);
        assert!(tokens.iter().any(|t| t.kind == TokenKind::Function));
    }

    #[test]
    fn test_javascript_keywords() {
        let tokens = tok("javascript", "const x = 1; function foo() { return x; }");
        let kws: Vec<_> = tokens
            .iter()
            .filter(|t| t.kind == TokenKind::Keyword)
            .collect();
        assert!(!kws.is_empty(), "Should find JS keywords");
    }

    #[test]
    fn test_javascript_string() {
        let tokens = tok("javascript", "const s = 'hello';");
        assert!(tokens.iter().any(|t| t.kind == TokenKind::String));
    }

    #[test]
    fn test_python_keywords() {
        let tokens = tok("python", "def foo():\n    return True");
        let kws: Vec<_> = tokens
            .iter()
            .filter(|t| t.kind == TokenKind::Keyword)
            .collect();
        assert!(
            !kws.is_empty(),
            "Should find Python keywords (def, return, True)"
        );
    }

    #[test]
    fn test_python_comment() {
        let src = "# this is a comment\nx = 1";
        let tokens = tok("python", src);
        assert!(tokens.iter().any(|t| t.kind == TokenKind::Comment));
    }

    #[test]
    fn test_generic_number() {
        let tokens = tok("text", "value = 3.14;");
        assert!(tokens.iter().any(|t| t.kind == TokenKind::Number));
    }

    #[test]
    fn test_empty_source() {
        let tokens = tok("rust", "");
        assert!(tokens.is_empty());
    }

    #[test]
    fn test_multiline_tokenization() {
        let src = "fn foo() {\n    let x = 1;\n    let y = 2;\n}\n";
        let tokens = tok("rust", src);
        // Should have tokens on multiple lines
        let lines: std::collections::HashSet<usize> = tokens.iter().map(|t| t.line).collect();
        assert!(lines.len() >= 3, "Should tokenize multiple lines");
    }

    #[test]
    fn test_token_positions_are_valid() {
        let src = "fn main() { let x = 42; }";
        let tokens = tok("rust", src);
        for t in &tokens {
            assert!(t.start <= t.end, "start > end: {:?}", t);
            assert!(t.end <= src.len(), "end out of bounds: {:?}", t);
        }
    }

    #[test]
    fn test_incremental_invalidation() {
        let buf = Buffer::from_str("fn foo() { let x = 1; }\n");
        let mut t = Tokenizer::new();
        let all = t.tokenize_full(&buf, "rust");
        assert!(!all.is_empty());
        // Invalidate line 0
        t.invalidate_range(0, 0);
        assert!(t.is_dirty());
        t.clear();
        assert!(!t.is_dirty());
    }
}
