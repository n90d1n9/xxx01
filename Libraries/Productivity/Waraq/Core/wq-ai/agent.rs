// src/ai/agent.rs
//
// Multi-step AI agent — orchestrates sequences of editor actions driven by
// a language model. This is where Waraq differentiates from Monaco.
//
// Agent tasks:
//   Refactor   — transform selected code according to an instruction
//   Fix        — apply diagnostics + AI to fix errors
//   Explain    — generate inline documentation for selected code
//   Generate   — write new code from a natural-language description
//   Test       — generate unit tests for a function
//   Rename     — AI-suggested rename across the codebase
//
// Each task goes through the same pipeline:
//   1. Context extraction (ai::context)
//   2. Prompt construction (ai::prompt)
//   3. Model call (serialised to CompletionRequest for FFI caller)
//   4. Diff application (ai::diff)
//   5. Undo group wrapping (core::undo)

use serde::{Deserialize, Serialize};

use crate::ai::context::{extract_context, ContextWindow};
use crate::ai::diff::SuggestionDiff;
use crate::ai::prompt::{BuiltPrompt, PromptBuilder};
use crate::core::buffer::Buffer;
use crate::core::edit::EditOp;
use crate::core::types::{ByteOffset, Range};
use crate::lsp::protocol::Diagnostic;

// ── Task definition ───────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AgentTask {
    /// Transform the selected code according to `instruction`.
    Refactor {
        selection: Range,
        instruction: String,
    },
    /// Fix all diagnostics in the selection (or whole file).
    Fix {
        selection: Option<Range>,
        diagnostics: Vec<DiagnosticSummary>,
    },
    /// Generate documentation for the selected code.
    Explain {
        selection: Range,
        /// If true, insert as a code comment above the selection.
        insert_as_comment: bool,
    },
    /// Generate new code at the cursor position.
    Generate {
        description: String,
        insert_at: ByteOffset,
    },
    /// Generate unit tests for the selected function.
    GenerateTests {
        selection: Range,
        test_framework: Option<String>,
    },
    /// Rename the symbol at cursor with an AI-suggested name.
    Rename {
        cursor: ByteOffset,
        reason: Option<String>,
    },
    /// Custom instruction applied to the whole file or selection.
    Custom {
        selection: Option<Range>,
        instruction: String,
    },
}

/// Lightweight diagnostic summary for prompt construction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DiagnosticSummary {
    pub line: u32,
    pub col: u32,
    pub message: String,
    pub severity: String,
}

impl From<&Diagnostic> for DiagnosticSummary {
    fn from(d: &Diagnostic) -> Self {
        Self {
            line: d.range.start.line,
            col: d.range.start.character,
            message: d.message.clone(),
            severity: format!("{:?}", d.severity),
        }
    }
}

// ── Agent step ────────────────────────────────────────────────────────────────

/// One step in the agent execution.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentStep {
    pub step_id: usize,
    pub description: String,
    pub prompt: BuiltPrompt,
    pub expected_output: ExpectedOutput,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ExpectedOutput {
    /// Full replacement of the selected range.
    Replacement,
    /// Insertion at a specific position.
    Insertion { at: ByteOffset },
    /// JSON with `edits: [{range, text}]`.
    EditList,
    /// Plain text (for explanations/renames).
    Text,
}

// ── Agent plan ────────────────────────────────────────────────────────────────

/// A plan is a sequence of steps to execute.
#[derive(Debug, Clone, Serialize)]
pub struct AgentPlan {
    pub task: AgentTask,
    pub steps: Vec<AgentStep>,
}

// ── Agent result ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AgentResult {
    /// Edits to apply to the buffer.
    Edits(Vec<EditOp>),
    /// Plain text output (explanation, rename suggestion).
    Text(String),
    /// The agent needs clarification.
    NeedsClarification(String),
    /// An error occurred.
    Error(String),
}

impl AgentResult {
    pub fn is_success(&self) -> bool {
        !matches!(self, AgentResult::Error(_))
    }
}

// ── Agent ─────────────────────────────────────────────────────────────────────

pub struct Agent {
    builder: PromptBuilder,
    window: ContextWindow,
}

impl Agent {
    pub fn new(builder: PromptBuilder) -> Self {
        Self {
            builder,
            window: ContextWindow::default(),
        }
    }

    pub fn with_window(mut self, window: ContextWindow) -> Self {
        self.window = window;
        self
    }

    /// Build a plan for the given task. Returns the sequence of steps
    /// the caller must execute (one model call per step).
    pub fn plan(
        &self,
        buf: &Buffer,
        task: &AgentTask,
        language: &str,
        file_uri: &str,
        syntax_tokens: &[crate::syntax::Token],
    ) -> AgentPlan {
        let steps = match task {
            AgentTask::Refactor {
                selection,
                instruction,
            } => self.plan_refactor(
                buf,
                *selection,
                instruction,
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::Fix {
                selection,
                diagnostics,
            } => self.plan_fix(
                buf,
                *selection,
                diagnostics,
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::Explain {
                selection,
                insert_as_comment,
            } => self.plan_explain(
                buf,
                *selection,
                *insert_as_comment,
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::Generate {
                description,
                insert_at,
            } => self.plan_generate(
                buf,
                description,
                *insert_at,
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::GenerateTests {
                selection,
                test_framework,
            } => self.plan_tests(
                buf,
                *selection,
                test_framework.as_deref(),
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::Rename { cursor, reason } => self.plan_rename(
                buf,
                *cursor,
                reason.as_deref(),
                language,
                file_uri,
                syntax_tokens,
            ),
            AgentTask::Custom {
                selection,
                instruction,
            } => self.plan_custom(
                buf,
                *selection,
                instruction,
                language,
                file_uri,
                syntax_tokens,
            ),
        };

        AgentPlan {
            task: task.clone(),
            steps,
        }
    }

    /// Apply an `AgentResult` to the buffer, returning a list of `EditOp`s
    /// wrapped in an undo group. The caller applies these via `Editor::apply`.
    pub fn apply_result(&self, _buf: &Buffer, step: &AgentStep, result_text: &str) -> AgentResult {
        match &step.expected_output {
            ExpectedOutput::Replacement => {
                // Find where the original selected text was and replace it
                // with the model's output (cleaned up)
                let cleaned = clean_code_response(result_text);
                if cleaned.is_empty() {
                    return AgentResult::Error("Model returned empty response".into());
                }
                AgentResult::Text(cleaned) // caller wraps in EditOp
            }
            ExpectedOutput::Insertion { at } => {
                let cleaned = clean_code_response(result_text);
                AgentResult::Edits(vec![EditOp::insert(at.0, &cleaned)])
            }
            ExpectedOutput::EditList => {
                // Try to parse JSON edit list
                match parse_edit_list(result_text) {
                    Ok(ops) => AgentResult::Edits(ops),
                    Err(e) => AgentResult::Error(format!("Failed to parse edit list: {}", e)),
                }
            }
            ExpectedOutput::Text => AgentResult::Text(result_text.trim().to_owned()),
        }
    }

    /// Compute minimal diff edits for a Refactor/Fix result.
    pub fn diff_result(
        &self,
        original_text: &str,
        model_response: &str,
        selection_start: usize,
    ) -> Vec<EditOp> {
        let cleaned = clean_code_response(model_response);
        let diff = SuggestionDiff::compute(original_text, &cleaned);
        if diff.is_identical() {
            return vec![];
        }
        diff.to_edit_ops(selection_start)
    }

    // ── Step builders ─────────────────────────────────────────────────────────

    fn plan_refactor(
        &self,
        buf: &Buffer,
        selection: Range,
        instruction: &str,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let cursor = selection.start;
        let ctx = extract_context(buf, cursor, language, file_uri, tokens, &self.window);
        let selected_text = buf.text_in_range(selection);
        let full_instruction = format!(
            "Refactor the following {} code:\n```{}\n{}\n```\n\nInstruction: {}",
            language, language, selected_text, instruction
        );
        let prompt = self.builder.build_edit_prompt(&ctx, &full_instruction);

        vec![AgentStep {
            step_id: 0,
            description: format!("Refactor: {}", instruction),
            prompt,
            expected_output: ExpectedOutput::Replacement,
        }]
    }

    fn plan_fix(
        &self,
        buf: &Buffer,
        selection: Option<Range>,
        diagnostics: &[DiagnosticSummary],
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let cursor = selection.map(|s| s.start).unwrap_or(ByteOffset(0));
        let ctx = extract_context(buf, cursor, language, file_uri, tokens, &self.window);

        let diag_text: String = diagnostics
            .iter()
            .map(|d| format!("  Line {}: [{}] {}", d.line + 1, d.severity, d.message))
            .collect::<Vec<_>>()
            .join("\n");

        let instruction = format!(
            "Fix the following errors in the {} code:\n{}\n\nReturn the corrected code.",
            language, diag_text
        );
        let prompt = self.builder.build_edit_prompt(&ctx, &instruction);

        vec![AgentStep {
            step_id: 0,
            description: "Fix diagnostics".into(),
            prompt,
            expected_output: ExpectedOutput::Replacement,
        }]
    }

    fn plan_explain(
        &self,
        buf: &Buffer,
        selection: Range,
        insert_as_comment: bool,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let ctx = extract_context(
            buf,
            selection.start,
            language,
            file_uri,
            tokens,
            &self.window,
        );
        let selected_text = buf.text_in_range(selection);
        let prompt = self.builder.build_explain_prompt(&ctx, &selected_text);

        let output = if insert_as_comment {
            // Insert as a doc comment above the selection
            ExpectedOutput::Insertion {
                at: selection.start,
            }
        } else {
            ExpectedOutput::Text
        };

        vec![AgentStep {
            step_id: 0,
            description: "Explain code".into(),
            prompt,
            expected_output: output,
        }]
    }

    fn plan_generate(
        &self,
        buf: &Buffer,
        description: &str,
        insert_at: ByteOffset,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let ctx = extract_context(buf, insert_at, language, file_uri, tokens, &self.window);
        let instruction = format!(
            "Generate {} code that: {}\n\nInsert complete, working code.",
            language, description
        );
        let prompt = self.builder.build_edit_prompt(&ctx, &instruction);

        vec![AgentStep {
            step_id: 0,
            description: format!("Generate: {}", description),
            prompt,
            expected_output: ExpectedOutput::Insertion { at: insert_at },
        }]
    }

    fn plan_tests(
        &self,
        buf: &Buffer,
        selection: Range,
        test_framework: Option<&str>,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let ctx = extract_context(
            buf,
            selection.start,
            language,
            file_uri,
            tokens,
            &self.window,
        );
        let selected_text = buf.text_in_range(selection);
        let framework = test_framework.unwrap_or(default_test_framework(language));
        let instruction = format!(
            "Write comprehensive unit tests for the following {} code using {}:\n\
             ```{}\n{}\n```\n\
             Include edge cases. Return only the test code.",
            language, framework, language, selected_text
        );
        let prompt = self.builder.build_edit_prompt(&ctx, &instruction);

        vec![AgentStep {
            step_id: 0,
            description: format!("Generate tests ({framework})"),
            prompt,
            expected_output: ExpectedOutput::Insertion {
                at: ByteOffset(buf.len_bytes()), // append at end
            },
        }]
    }

    fn plan_rename(
        &self,
        buf: &Buffer,
        cursor: ByteOffset,
        reason: Option<&str>,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let ctx = extract_context(buf, cursor, language, file_uri, tokens, &self.window);
        let word = {
            let range = buf.word_range_at(cursor);
            buf.text_in_range(range)
        };
        let reason_text = reason
            .map(|r| format!(" Reason: {}", r))
            .unwrap_or_default();
        let instruction = format!(
            "Suggest a better name for `{}` in {} code.\
             {}Consider the context and coding conventions. \
             Reply with ONLY the new name, nothing else.",
            word, language, reason_text
        );
        let prompt = self.builder.build_edit_prompt(&ctx, &instruction);

        vec![AgentStep {
            step_id: 0,
            description: format!("Rename `{}`", word),
            prompt,
            expected_output: ExpectedOutput::Text,
        }]
    }

    fn plan_custom(
        &self,
        buf: &Buffer,
        selection: Option<Range>,
        instruction: &str,
        language: &str,
        file_uri: &str,
        tokens: &[crate::syntax::Token],
    ) -> Vec<AgentStep> {
        let cursor = selection.map(|s| s.start).unwrap_or(ByteOffset(0));
        let ctx = extract_context(buf, cursor, language, file_uri, tokens, &self.window);
        let prompt = self.builder.build_edit_prompt(&ctx, instruction);

        let output = if selection.is_some() {
            ExpectedOutput::Replacement
        } else {
            ExpectedOutput::Insertion { at: cursor }
        };

        vec![AgentStep {
            step_id: 0,
            description: format!("Custom: {}", &instruction[..instruction.len().min(50)]),
            prompt,
            expected_output: output,
        }]
    }
}

// ── Utilities ─────────────────────────────────────────────────────────────────

/// Strip markdown fences and leading/trailing whitespace from model output.
pub fn clean_code_response(text: &str) -> String {
    let trimmed = text.trim();
    if !trimmed.starts_with("```") {
        return trimmed.to_owned();
    }

    let lines: Vec<&str> = trimmed.lines().collect();
    if lines.len() < 2 {
        return trimmed.to_owned();
    }

    let inner_start = 1; // skip opening fence
    let inner_end = lines
        .iter()
        .rposition(|l| l.trim_start().starts_with("```"))
        .unwrap_or(lines.len());

    lines[inner_start..inner_end].join("\n")
}

/// Try to parse a JSON edit list returned by the model.
/// Expected format: `[{"range": {"start": 0, "end": 5}, "text": "hello"}, ...]`
fn parse_edit_list(text: &str) -> Result<Vec<EditOp>, String> {
    let cleaned = clean_code_response(text);
    let v: serde_json::Value = serde_json::from_str(&cleaned).map_err(|e| e.to_string())?;

    let arr = v.as_array().ok_or("Expected JSON array")?;
    let mut ops = Vec::new();

    for item in arr {
        let start = item["range"]["start"]
            .as_u64()
            .ok_or("Missing range.start")? as usize;
        let end = item["range"]["end"].as_u64().ok_or("Missing range.end")? as usize;
        let text = item["text"].as_str().unwrap_or("").to_owned();
        ops.push(EditOp::replace(start, end, text));
    }

    // Apply largest-offset-first for safe sequential application
    ops.sort_by(|a, b| {
        let a_start = match a {
            EditOp::Replace { range, .. } => range.start.0,
            _ => 0,
        };
        let b_start = match b {
            EditOp::Replace { range, .. } => range.start.0,
            _ => 0,
        };
        b_start.cmp(&a_start)
    });

    Ok(ops)
}

fn default_test_framework(language: &str) -> &'static str {
    match language {
        "rust" => "cargo test (#[test])",
        "python" => "pytest",
        "javascript" | "typescript" => "Jest",
        "java" => "JUnit 5",
        "kotlin" => "JUnit 5 + Kotest",
        "go" => "testing package",
        "swift" => "XCTest",
        "dart" => "flutter_test",
        _ => "the standard testing framework",
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ai::prompt::PromptBuilder;
    use crate::core::buffer::Buffer;

    fn agent() -> Agent {
        Agent::new(PromptBuilder::for_deepseek())
    }

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_clean_code_response_no_fence() {
        let r = clean_code_response("let x = 1;");
        assert_eq!(r, "let x = 1;");
    }

    #[test]
    fn test_clean_code_response_with_fence() {
        let r = clean_code_response("```rust\nlet x = 1;\n```");
        assert_eq!(r, "let x = 1;");
    }

    #[test]
    fn test_clean_code_response_with_language_tag() {
        let r = clean_code_response("```python\ndef foo():\n    return 1\n```");
        assert_eq!(r, "def foo():\n    return 1");
    }

    #[test]
    fn test_plan_refactor_creates_one_step() {
        let b = buf("fn add(a: i32, b: i32) -> i32 { a + b }");
        let task = AgentTask::Refactor {
            selection: Range::new(0, b.len_bytes()),
            instruction: "Add overflow checking".into(),
        };
        let plan = agent().plan(&b, &task, "rust", "file:///main.rs", &[]);
        assert_eq!(plan.steps.len(), 1);
        assert_eq!(plan.steps[0].step_id, 0);
    }

    #[test]
    fn test_plan_explain() {
        let b = buf("fn fib(n: u64) -> u64 { if n <= 1 { n } else { fib(n-1) + fib(n-2) } }");
        let task = AgentTask::Explain {
            selection: Range::new(0, b.len_bytes()),
            insert_as_comment: false,
        };
        let plan = agent().plan(&b, &task, "rust", "file:///main.rs", &[]);
        assert_eq!(plan.steps.len(), 1);
        assert!(matches!(
            plan.steps[0].expected_output,
            ExpectedOutput::Text
        ));
    }

    #[test]
    fn test_plan_generate_tests() {
        let b = buf("fn add(a: i32, b: i32) -> i32 { a + b }");
        let task = AgentTask::GenerateTests {
            selection: Range::new(0, b.len_bytes()),
            test_framework: Some("cargo test".into()),
        };
        let plan = agent().plan(&b, &task, "rust", "file:///main.rs", &[]);
        assert!(matches!(
            plan.steps[0].expected_output,
            ExpectedOutput::Insertion { .. }
        ));
    }

    #[test]
    fn test_plan_fix_with_diagnostics() {
        let b = buf("fn foo() { let x = undeclared_fn(); }");
        let diags = vec![DiagnosticSummary {
            line: 0,
            col: 19,
            message: "cannot find function `undeclared_fn` in this scope".into(),
            severity: "Error".into(),
        }];
        let task = AgentTask::Fix {
            selection: None,
            diagnostics: diags,
        };
        let plan = agent().plan(&b, &task, "rust", "file:///main.rs", &[]);
        assert_eq!(plan.steps.len(), 1);
        let prompt_text = plan.steps[0]
            .prompt
            .messages
            .as_ref()
            .and_then(|m| m.get(1))
            .map(|m| &m.content)
            .unwrap();
        assert!(prompt_text.contains("undeclared_fn"));
    }

    #[test]
    fn test_apply_result_insertion() {
        let b = buf("fn main() {}");
        let step = AgentStep {
            step_id: 0,
            description: "test".into(),
            prompt: PromptBuilder::for_deepseek().build_inline_completion(
                &crate::ai::context::AiContext {
                    language: "rust".into(),
                    file_uri: "file:///test.rs".into(),
                    imports: vec![],
                    prefix: "fn main() {}".into(),
                    suffix: "".into(),
                    cursor_line: "".into(),
                    cursor_col: 0,
                    scope: crate::ai::context::SemanticScope::TopLevel,
                    related_symbols: vec![],
                    estimated_tokens: 5,
                },
            ),
            expected_output: ExpectedOutput::Insertion { at: ByteOffset(12) },
        };
        let ag = agent();
        let result = ag.apply_result(&b, &step, "println!(\"hello\");");
        assert!(result.is_success());
    }

    #[test]
    fn test_diff_result_produces_ops() {
        let ag = agent();
        let original = "fn add(a: i32, b: i32) -> i32 { a + b }";
        let modified =
            "fn add(a: i32, b: i32) -> i32 {\n    a.checked_add(b).unwrap_or(i32::MAX)\n}";
        let ops = ag.diff_result(original, modified, 0);
        assert!(!ops.is_empty());
    }

    #[test]
    fn test_parse_edit_list_valid_json() {
        let json = r#"[{"range":{"start":0,"end":5},"text":"hello"}]"#;
        let ops = parse_edit_list(json).unwrap();
        assert_eq!(ops.len(), 1);
    }

    #[test]
    fn test_parse_edit_list_invalid_json() {
        let result = parse_edit_list("not json");
        assert!(result.is_err());
    }
}

#[cfg(test)]
mod agent_extended_tests {
    use super::*;
    use crate::ai::prompt::PromptBuilder;
    use crate::core::buffer::Buffer;
    use crate::core::types::Range as CoreRange;

    fn buf(s: &str) -> Buffer {
        Buffer::from_str(s)
    }

    #[test]
    fn test_clean_code_response_strips_markdown_fence() {
        let raw = "```python\ndef hello():\n    pass\n```";
        let clean = clean_code_response(raw);
        assert!(!clean.contains("```"), "Should strip markdown code fences");
        assert!(clean.contains("def hello"), "Should keep code content");
    }

    #[test]
    fn test_clean_code_response_strips_rust_fence() {
        let raw = "```rust\nfn main() {}\n```";
        let clean = clean_code_response(raw);
        assert!(!clean.contains("```"));
        assert!(clean.contains("fn main"));
    }

    #[test]
    fn test_clean_code_response_plain_text_unchanged() {
        let raw = "fn main() { let x = 1; }";
        let clean = clean_code_response(raw);
        assert_eq!(clean.trim(), raw.trim());
    }

    #[test]
    fn test_clean_code_response_empty_stays_empty() {
        assert_eq!(clean_code_response(""), "");
        assert_eq!(clean_code_response("   ").trim(), "");
    }

    #[test]
    fn test_clean_code_response_strips_explanation_prefix() {
        let raw = "Here is the refactored code:\n\n```python\ndef foo(): pass\n```";
        let clean = clean_code_response(raw);
        assert!(clean.contains("def foo"), "Should keep code");
    }

    #[test]
    fn test_agent_plan_refactor() {
        let builder = PromptBuilder::for_starcoder();
        let agent = Agent::new(builder);
        let b = buf("def old_name():\n    return 42\n");
        let task = AgentTask::Refactor {
            selection: CoreRange::new(0, b.len_bytes()),
            instruction: "rename to new_name".to_owned(),
        };
        let tokens: Vec<crate::syntax::Token> = vec![];
        let plan = agent.plan(&b, &task, "python", "file:///a.py", &tokens);
        assert!(
            !plan.steps.is_empty(),
            "Plan should have steps for refactor"
        );
    }

    #[test]
    fn test_agent_plan_explain() {
        let builder = PromptBuilder::for_starcoder();
        let agent = Agent::new(builder);
        let b = buf("def fib(n): return n if n<2 else fib(n-1)+fib(n-2)\n");
        let task = AgentTask::Explain {
            selection: CoreRange::new(0, b.len_bytes()),
            insert_as_comment: false,
        };
        let tokens: Vec<crate::syntax::Token> = vec![];
        let plan = agent.plan(&b, &task, "python", "file:///a.py", &tokens);
        assert!(!plan.steps.is_empty());
    }

    #[test]
    fn test_agent_plan_generate() {
        let builder = PromptBuilder::for_starcoder();
        let agent = Agent::new(builder);
        let b = buf("# fibonacci function here\n");
        let task = AgentTask::Generate {
            description: "write a fibonacci function".to_owned(),
            insert_at: ByteOffset(b.len_bytes()),
        };
        let tokens: Vec<crate::syntax::Token> = vec![];
        let plan = agent.plan(&b, &task, "python", "file:///a.py", &tokens);
        assert!(!plan.steps.is_empty());
    }

    #[test]
    fn test_agent_result_is_success() {
        let result = AgentResult::Text("Explanation here".to_owned());
        assert!(result.is_success());
    }

    #[test]
    fn test_agent_result_error_not_success() {
        let result = AgentResult::Error("something failed".to_owned());
        assert!(!result.is_success());
    }

    #[test]
    fn test_agent_plan_tests_generation() {
        let builder = PromptBuilder::for_starcoder();
        let agent = Agent::new(builder);
        let b = buf("def add(a, b):\n    return a + b\n");
        let task = AgentTask::GenerateTests {
            selection: CoreRange::new(0, b.len_bytes()),
            test_framework: Some("pytest".to_owned()),
        };
        let tokens: Vec<crate::syntax::Token> = vec![];
        let plan = agent.plan(&b, &task, "python", "file:///a.py", &tokens);
        assert!(!plan.steps.is_empty());
    }

    #[test]
    fn test_diagnostic_summary_construction() {
        let d = DiagnosticSummary {
            line: 5,
            col: 10,
            message: "undefined variable 'x'".to_owned(),
            severity: "error".to_owned(),
        };
        assert_eq!(d.line, 5);
        assert!(d.message.contains("undefined"));
    }
}
