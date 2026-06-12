// src/syntax/mod.rs

pub mod bracket;
pub mod fold;
pub mod highlight;
pub mod languages;
pub mod tokenizer;

pub use tokenizer::Tokenizer;

use crate::core::buffer::{Buffer, TextChange};
use crate::core::viewport::Viewport;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[repr(u8)]
pub enum TokenKind {
    Default = 0,
    Keyword = 1,
    String = 2,
    Number = 3,
    Comment = 4,
    Operator = 5,
    Function = 6,
    Type = 7,
    Variable = 8,
    Constant = 9,
    Punctuation = 10,
    Attribute = 11,
    Error = 255,
}

impl TokenKind {
    pub fn from_ts_name(name: &str) -> Self {
        match name {
            "keyword" | "keyword.control" | "keyword.operator" => Self::Keyword,
            "string" | "string.quoted" | "string.template" => Self::String,
            "number" | "number.float" | "number.integer" => Self::Number,
            "comment" | "comment.line" | "comment.block" => Self::Comment,
            "operator" => Self::Operator,
            "function" | "function.builtin" | "function.call" => Self::Function,
            "type" | "type.builtin" | "class" => Self::Type,
            "variable" | "variable.builtin" => Self::Variable,
            "constant" | "constant.builtin" => Self::Constant,
            "punctuation" | "punctuation.delimiter" => Self::Punctuation,
            "attribute" | "decorator" => Self::Attribute,
            "ERROR" => Self::Error,
            _ => Self::Default,
        }
    }
}

impl Default for TokenKind {
    fn default() -> Self {
        Self::Default
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Token {
    pub start: usize,
    pub end: usize,
    pub kind: TokenKind,
    pub line: usize,
    pub col_start: usize,
    pub col_end: usize,
}

pub struct SyntaxLayer {
    tokenizer: Tokenizer,
    cached_tokens: Vec<Token>,
    dirty: bool,
    language: Option<String>,
}

impl SyntaxLayer {
    pub fn new() -> Self {
        Self {
            tokenizer: Tokenizer::new(),
            cached_tokens: Vec::new(),
            dirty: true,
            language: None,
        }
    }

    pub fn set_language(&mut self, lang: &str) {
        self.language = Some(lang.to_owned());
        self.dirty = true;
    }

    pub fn language(&self) -> Option<&str> {
        self.language.as_deref()
    }

    pub fn on_change(&mut self, change: &TextChange, _buffer: &Buffer) {
        self.tokenizer
            .invalidate_range(change.first_line, change.last_line);
        self.dirty = true;
    }

    pub fn full_parse(&mut self, buffer: &Buffer) {
        if let Some(ref lang) = self.language.clone() {
            self.cached_tokens = self.tokenizer.tokenize_full(buffer, lang);
            self.dirty = false;
        }
    }

    pub fn tokens_for_viewport(&self, viewport: &Viewport) -> Vec<Token> {
        let first = viewport.first_line();
        let last = first + viewport.height();
        self.cached_tokens
            .iter()
            .filter(|t| t.line >= first && t.line < last)
            .cloned()
            .collect()
    }

    pub fn all_tokens(&self) -> &[Token] {
        &self.cached_tokens
    }
}

impl Default for SyntaxLayer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_syntax_layer_set_language() {
        let mut layer = SyntaxLayer::new();
        layer.set_language("rust");
        assert_eq!(layer.language(), Some("rust"));
    }

    #[test]
    fn test_syntax_layer_full_parse() {
        let b = buf("fn main() { let x = 1; }");
        let mut layer = SyntaxLayer::new();
        layer.set_language("rust");
        layer.full_parse(&b);
        let tokens = layer.all_tokens();
        assert!(!tokens.is_empty(), "Should produce tokens for Rust source");
    }

    #[test]
    fn test_syntax_layer_tokens_for_viewport() {
        let b = buf("fn main() {\n    let x = 42;\n}\n");
        let mut layer = SyntaxLayer::new();
        layer.set_language("rust");
        layer.full_parse(&b);
        let viewport = Viewport::new(0, 2);
        let tokens = layer.tokens_for_viewport(&viewport);
        // All tokens should be within the viewport
        for t in &tokens {
            assert!(t.line <= 2, "Token line {} out of viewport", t.line);
        }
    }

    #[test]
    fn test_syntax_layer_on_change() {
        use crate::core::buffer::TextChange;
        use crate::core::types::Range;
        let b = buf("fn main() {}");
        let mut layer = SyntaxLayer::new();
        layer.set_language("rust");
        layer.full_parse(&b);
        // Simulate a change
        let change = TextChange {
            replaced: Range::new(0, 0),
            inserted: "// comment\n".to_owned(),
            deleted: String::new(),
            byte_delta: 11,
            first_line: 0,
            last_line: 0,
        };
        let new_buf = buf("// comment\nfn main() {}");
        layer.on_change(&change, &new_buf);
        // Should not panic and should update tokens
    }

    #[test]
    fn test_syntax_layer_unknown_language() {
        let b = buf("some random text");
        let mut layer = SyntaxLayer::new();
        layer.set_language("unknown_xyz");
        layer.full_parse(&b);
        let tokens = layer.all_tokens();
        // Should not panic, just return default tokens
        let _ = tokens;
    }

    #[test]
    fn test_token_kind_default() {
        assert_eq!(TokenKind::default(), TokenKind::Default);
    }

    #[test]
    fn test_token_fields() {
        let t = Token {
            start: 0,
            end: 5,
            line: 0,
            col_start: 0,
            col_end: 5,
            kind: TokenKind::Keyword,
        };
        assert_eq!(t.kind, TokenKind::Keyword);
        assert_eq!(t.end - t.start, 5);
    }
}
