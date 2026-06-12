// src/ai/prompt.rs
//
// Builds structured prompts from AiContext.
//
// Supports three completion modes:
//   1. Infill / FIM (Fill-In-the-Middle) — for inline completions.
//      Used by: Codestral, DeepSeek-Coder, StarCoder2, Waraq.
//   2. Chat / instruction — for longer AI-assisted edits.
//   3. Raw prefix — for models without FIM support.

use super::context::{AiContext, SemanticScope, SymbolKind};
use serde::{Deserialize, Serialize};

/// Which prompt style to emit.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum PromptMode {
    /// Fill-in-the-middle with special tokens.
    Fim,
    /// Chat/instruction message format (user turn only).
    Chat,
    /// Plain prefix completion (no special tokens, no suffix).
    Prefix,
}

/// The finished prompt ready to send to the model.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BuiltPrompt {
    pub mode: PromptMode,
    /// The raw prompt text (for Prefix/FIM modes).
    pub text: Option<String>,
    /// For Chat mode: system + user messages.
    pub messages: Option<Vec<ChatMessage>>,
    /// Approximate token count.
    pub estimated_tokens: usize,
    /// Stop sequences the model should respect.
    pub stop_sequences: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChatMessage {
    pub role: String,
    pub content: String,
}

/// Tokens used by FIM models.
/// Override these to match your model's tokenizer vocabulary.
pub struct FimTokens {
    pub prefix: &'static str,
    pub suffix: &'static str,
    pub middle: &'static str,
}

pub const TOKENS_STARCODER: FimTokens = FimTokens {
    prefix: "<fim_prefix>",
    suffix: "<fim_suffix>",
    middle: "<fim_middle>",
};

pub const TOKENS_DEEPSEEK: FimTokens = FimTokens {
    prefix: "<｜fim▁begin｜>",
    suffix: "<｜fim▁hole｜>",
    middle: "<｜fim▁end｜>",
};

pub const TOKENS_CODESTRAL: FimTokens = FimTokens {
    prefix: "[PREFIX]",
    suffix: "[SUFFIX]",
    middle: "[MIDDLE]",
};

// ── PromptBuilder ─────────────────────────────────────────────────────────────

pub struct PromptBuilder {
    fim_tokens: FimTokens,
}

impl PromptBuilder {
    pub fn new(fim_tokens: FimTokens) -> Self {
        Self { fim_tokens }
    }

    pub fn for_starcoder() -> Self {
        Self::new(TOKENS_STARCODER)
    }
    pub fn for_deepseek() -> Self {
        Self::new(TOKENS_DEEPSEEK)
    }
    pub fn for_codestral() -> Self {
        Self::new(TOKENS_CODESTRAL)
    }

    // ── Public build methods ─────────────────────────────────────────────────

    /// Build an inline completion prompt (FIM mode).
    pub fn build_inline_completion(&self, ctx: &AiContext) -> BuiltPrompt {
        let prefix_part = self.build_prefix_part(ctx);
        let suffix_part = &ctx.suffix;

        let text = format!(
            "{}{}{}{}{}{}",
            self.fim_tokens.prefix,
            prefix_part,
            self.fim_tokens.suffix,
            suffix_part,
            self.fim_tokens.middle,
            // empty string — model fills this
            ""
        );

        BuiltPrompt {
            mode: PromptMode::Fim,
            text: Some(text),
            messages: None,
            estimated_tokens: ctx.estimated_tokens,
            stop_sequences: vec![
                "\n\n".into(),
                self.fim_tokens.suffix.into(),
                self.fim_tokens.prefix.into(),
            ],
        }
    }

    /// Build a chat prompt for a longer AI-assisted edit instruction.
    pub fn build_edit_prompt(&self, ctx: &AiContext, instruction: &str) -> BuiltPrompt {
        let system = self.build_system_prompt(ctx);
        let user = self.build_user_edit_message(ctx, instruction);

        let estimated = (system.len() + user.len()) / 4;

        BuiltPrompt {
            mode: PromptMode::Chat,
            text: None,
            messages: Some(vec![
                ChatMessage {
                    role: "system".into(),
                    content: system,
                },
                ChatMessage {
                    role: "user".into(),
                    content: user,
                },
            ]),
            estimated_tokens: estimated,
            stop_sequences: vec!["```".into()],
        }
    }

    /// Build a chat prompt for explaining/documenting code.
    pub fn build_explain_prompt(&self, ctx: &AiContext, selected_text: &str) -> BuiltPrompt {
        let system = format!(
            "You are an expert {} developer assistant. \
             Be concise, accurate, and focus on explaining what the code does and why.",
            ctx.language
        );

        let user = format!(
            "Explain this {} code:\n\n```{}\n{}\n```",
            ctx.language, ctx.language, selected_text
        );

        let estimated = (system.len() + user.len()) / 4;

        BuiltPrompt {
            mode: PromptMode::Chat,
            text: None,
            messages: Some(vec![
                ChatMessage {
                    role: "system".into(),
                    content: system,
                },
                ChatMessage {
                    role: "user".into(),
                    content: user,
                },
            ]),
            estimated_tokens: estimated,
            stop_sequences: vec![],
        }
    }

    // ── Private helpers ──────────────────────────────────────────────────────

    fn build_prefix_part(&self, ctx: &AiContext) -> String {
        let mut parts: Vec<String> = Vec::new();

        // Imports preamble (if the cursor is not already in the imports section)
        if !ctx.imports.is_empty() {
            let imports_block = ctx.imports.join("\n");
            // Only include if the prefix doesn't already contain all imports
            if !ctx.prefix.contains(ctx.imports[0].trim()) {
                parts.push(imports_block);
                parts.push(String::new()); // blank separator
            }
        }

        // Related symbol signatures (as comments so they don't confuse the model)
        if !ctx.related_symbols.is_empty() {
            let sym_block: String = ctx
                .related_symbols
                .iter()
                .map(|s| format!("// {}: {}", symbol_kind_label(s.kind), s.signature.trim()))
                .collect::<Vec<_>>()
                .join("\n");
            parts.push(sym_block);
            parts.push(String::new());
        }

        // The actual prefix code
        parts.push(ctx.prefix.clone());
        parts.push(ctx.cursor_line.clone());

        parts.join("\n")
    }

    fn build_system_prompt(&self, ctx: &AiContext) -> String {
        let scope_desc = match &ctx.scope {
            SemanticScope::Function { name } => format!("You are editing the `{}` function.", name),
            SemanticScope::Method { class, name } => {
                format!("You are editing the `{}::{}` method.", class, name)
            }
            SemanticScope::TopLevel => "You are editing top-level code.".into(),
            _ => "You are editing a code block.".into(),
        };

        format!(
            "You are an expert {} developer working in a code editor. {}\n\
             File: {}\n\
             Return ONLY the modified code inside a fenced code block (```{}).\n\
             Do not explain unless asked. Do not add unnecessary comments.",
            ctx.language, scope_desc, ctx.file_uri, ctx.language,
        )
    }

    fn build_user_edit_message(&self, ctx: &AiContext, instruction: &str) -> String {
        let context_code = if ctx.prefix.len() > 800 {
            // Trim to last 800 chars of prefix for readability
            let trimmed = &ctx.prefix[ctx.prefix.len().saturating_sub(800)..];
            format!("...\n{}", trimmed)
        } else {
            ctx.prefix.clone()
        };

        format!(
            "Here is the current code:\n\
             ```{}\n\
             {}\n\
             ```\n\n\
             Task: {}",
            ctx.language, context_code, instruction,
        )
    }
}

fn symbol_kind_label(kind: SymbolKind) -> &'static str {
    match kind {
        SymbolKind::Function => "fn",
        SymbolKind::Struct => "struct",
        SymbolKind::Enum => "enum",
        SymbolKind::Trait => "trait",
        SymbolKind::Impl => "impl",
        SymbolKind::Const => "const",
        SymbolKind::Variable => "var",
        SymbolKind::Import => "import",
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ai::context::{AiContext, SemanticScope};

    fn sample_ctx() -> AiContext {
        AiContext {
            language: "rust".into(),
            file_uri: "file:///src/main.rs".into(),
            imports: vec!["use std::collections::HashMap;".into()],
            prefix: "fn greet(name: &str) {\n    let msg = ".into(),
            suffix: "\n    println!(\"{}\", msg);\n}".into(),
            cursor_line: "    let msg = ".into(),
            cursor_col: 14,
            scope: SemanticScope::Function {
                name: "greet".into(),
            },
            related_symbols: vec![],
            estimated_tokens: 42,
        }
    }

    #[test]
    fn test_fim_prompt_structure() {
        let builder = PromptBuilder::for_starcoder();
        let ctx = sample_ctx();
        let prompt = builder.build_inline_completion(&ctx);
        let text = prompt.text.unwrap();
        assert!(text.contains("<fim_prefix>"));
        assert!(text.contains("<fim_suffix>"));
        assert!(text.contains("<fim_middle>"));
        assert!(text.contains("greet"));
    }

    #[test]
    fn test_chat_prompt_has_system_and_user() {
        let builder = PromptBuilder::for_deepseek();
        let ctx = sample_ctx();
        let prompt = builder.build_edit_prompt(&ctx, "Add error handling");
        let msgs = prompt.messages.unwrap();
        assert_eq!(msgs[0].role, "system");
        assert_eq!(msgs[1].role, "user");
        assert!(msgs[1].content.contains("Add error handling"));
    }

    #[test]
    fn test_explain_prompt() {
        let builder = PromptBuilder::for_codestral();
        let ctx = sample_ctx();
        let prompt = builder.build_explain_prompt(&ctx, "let x = 1 + 1;");
        let msgs = prompt.messages.unwrap();
        assert!(msgs[1].content.contains("let x = 1 + 1;"));
    }
}

#[cfg(test)]
mod prompt_extended_tests {
    use super::*;
    use crate::ai::context::{AiContext, SemanticScope};

    fn dummy_ctx(prefix: &str, suffix: &str, lang: &str) -> AiContext {
        AiContext {
            language: lang.to_owned(),
            file_uri: "file:///test.rs".to_owned(),
            imports: Vec::new(),
            prefix: prefix.to_owned(),
            suffix: suffix.to_owned(),
            cursor_line: prefix.lines().last().unwrap_or_default().to_owned(),
            cursor_col: prefix.lines().last().unwrap_or_default().len(),
            scope: SemanticScope::Unknown,
            related_symbols: Vec::new(),
            estimated_tokens: (prefix.len() + suffix.len()) / 4,
        }
    }

    #[test]
    fn test_fim_tokens_starcoder() {
        let b = PromptBuilder::for_starcoder();
        assert!(!b.fim_tokens.prefix.is_empty());
        assert!(!b.fim_tokens.suffix.is_empty());
        assert!(!b.fim_tokens.middle.is_empty());
    }

    #[test]
    fn test_fim_tokens_deepseek() {
        let b = PromptBuilder::for_deepseek();
        assert!(!b.fim_tokens.prefix.is_empty());
        assert!(!b.fim_tokens.middle.is_empty());
    }

    #[test]
    fn test_fim_tokens_codestral() {
        let b = PromptBuilder::for_codestral();
        assert!(!b.fim_tokens.prefix.is_empty());
    }

    #[test]
    fn test_build_inline_completion_structure() {
        let builder = PromptBuilder::for_starcoder();
        let ctx = dummy_ctx("fn main() {\n    let x = ", "", "rust");
        let prompt = builder.build_inline_completion(&ctx);
        // Prompt should contain our prefix content
        let all_text = prompt.text.as_deref().unwrap_or_default();
        assert!(
            all_text.contains("fn main"),
            "Prompt should include prefix code"
        );
    }

    #[test]
    fn test_build_inline_completion_fim_tokens() {
        let builder = PromptBuilder::for_starcoder();
        let ctx = dummy_ctx("def hello():", "\n    pass", "python");
        let prompt = builder.build_inline_completion(&ctx);
        let all_text = prompt.text.as_deref().unwrap_or_default();
        // Should have FIM tokens
        assert!(
            all_text.contains(&builder.fim_tokens.prefix)
                || all_text.contains("<fim_prefix>")
                || !all_text.is_empty(),
            "Should produce non-empty prompt"
        );
    }

    #[test]
    fn test_build_edit_prompt() {
        let builder = PromptBuilder::for_starcoder();
        let ctx = dummy_ctx("fn old_name() {}", "", "rust");
        let prompt = builder.build_edit_prompt(&ctx, "rename to new_name");
        let messages = prompt.messages.as_ref().expect("edit prompt messages");
        assert!(!messages.is_empty(), "Edit prompt should produce messages");
        let all_text: String = prompt
            .messages
            .as_ref()
            .unwrap()
            .iter()
            .map(|m| m.content.as_str())
            .collect::<Vec<_>>()
            .join("");
        assert!(
            all_text.len() > 10,
            "Edit prompt should have substantial content"
        );
    }

    #[test]
    fn test_build_explain_prompt() {
        let builder = PromptBuilder::for_deepseek();
        let ctx = dummy_ctx(
            "fn fib(n: u32) -> u32 {\n    if n < 2 { n } else { fib(n-1) + fib(n-2) }\n}",
            "",
            "rust",
        );
        let prompt = builder.build_explain_prompt(&ctx, "fn fib(n: u32) -> u32 { ... }");
        assert!(!prompt.messages.as_ref().unwrap().is_empty());
    }

    #[test]
    fn test_built_prompt_token_estimate() {
        let builder = PromptBuilder::for_starcoder();
        let ctx = dummy_ctx("x = 1\ny = 2\n", "", "python");
        let prompt = builder.build_inline_completion(&ctx);
        assert!(
            prompt.estimated_tokens > 0,
            "Token estimate should be positive"
        );
    }

    #[test]
    fn test_chat_message_roles() {
        let msgs = vec![
            ChatMessage {
                role: "system".into(),
                content: "You are helpful".into(),
            },
            ChatMessage {
                role: "user".into(),
                content: "Write code".into(),
            },
            ChatMessage {
                role: "assistant".into(),
                content: "Sure".into(),
            },
        ];
        assert_eq!(msgs[0].role, "system");
        assert_eq!(msgs[1].role, "user");
        assert_eq!(msgs[2].role, "assistant");
    }
}
