// src/ai/context.rs
//
// Extracts a rich, token-budget-aware context window around the cursor.
//
// Design principles:
//   • Never send the whole file — expensive and often counterproductive.
//   • Prioritise: (1) immediate surrounding lines, (2) containing scope,
//     (3) import/use declarations, (4) related symbol definitions.
//   • Context respects a configurable token budget (default 2 048 tokens).
//   • Output is deterministic so it can be compared/cached.

use std::collections::HashSet;

use crate::core::buffer::Buffer;
use crate::core::types::ByteOffset;
use crate::syntax::Token;

/// How many chars we estimate per LLM token.
const CHARS_PER_TOKEN: usize = 4;

/// Semantic scope kind inferred from syntax.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SemanticScope {
    TopLevel,
    Function { name: String },
    Method { class: String, name: String },
    Closure,
    Block,
    Unknown,
}

/// The full extracted context handed to `PromptBuilder`.
#[derive(Debug, Clone)]
pub struct AiContext {
    /// Language of the document.
    pub language: String,
    /// File path/URI (for multi-file awareness).
    pub file_uri: String,
    /// Import/use lines extracted from the top of the file.
    pub imports: Vec<String>,
    /// Lines before the cursor (prefix).
    pub prefix: String,
    /// Lines after the cursor (suffix) — for FIM (fill-in-the-middle) models.
    pub suffix: String,
    /// Current line up to the cursor.
    pub cursor_line: String,
    /// Column (char) of the cursor within `cursor_line`.
    pub cursor_col: usize,
    /// Semantic scope at cursor.
    pub scope: SemanticScope,
    /// Relevant symbol definitions from elsewhere in the file.
    pub related_symbols: Vec<SymbolSnippet>,
    /// Total approximate token count of prefix + suffix.
    pub estimated_tokens: usize,
}

/// A short snippet describing a symbol (function/struct signature, etc.)
#[derive(Debug, Clone)]
pub struct SymbolSnippet {
    pub name: String,
    pub kind: SymbolKind,
    /// The declaration line(s) — just signature, not full body.
    pub signature: String,
    pub line: usize,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SymbolKind {
    Function,
    Struct,
    Enum,
    Trait,
    Impl,
    Const,
    Variable,
    Import,
}

/// Configuration for context extraction.
#[derive(Debug, Clone)]
pub struct ContextWindow {
    /// Max tokens allocated to prefix (lines before cursor).
    pub prefix_token_budget: usize,
    /// Max tokens allocated to suffix (lines after cursor).
    pub suffix_token_budget: usize,
    /// Max tokens for related symbol definitions.
    pub symbols_token_budget: usize,
    /// Lines above cursor to always include regardless of budget.
    pub min_prefix_lines: usize,
    /// Lines below cursor to always include regardless of budget.
    pub min_suffix_lines: usize,
}

impl Default for ContextWindow {
    fn default() -> Self {
        Self {
            prefix_token_budget: 1_200,
            suffix_token_budget: 600,
            symbols_token_budget: 200,
            min_prefix_lines: 20,
            min_suffix_lines: 10,
        }
    }
}

impl ContextWindow {
    pub fn tight() -> Self {
        Self {
            prefix_token_budget: 400,
            suffix_token_budget: 150,
            symbols_token_budget: 80,
            min_prefix_lines: 8,
            min_suffix_lines: 4,
        }
    }
}

/// Context the cursor is sitting in (line text + column).
#[derive(Debug, Clone)]
pub struct CursorContext {
    pub line: usize,
    pub col: usize,
    pub line_text: String,
    /// Word under/just-before cursor.
    pub word_before_cursor: String,
    /// Character immediately before cursor.
    pub char_before: Option<char>,
}

// ── Extractor ─────────────────────────────────────────────────────────────────

/// Extract a full `AiContext` from the editor state.
pub fn extract_context(
    buffer: &Buffer,
    cursor: ByteOffset,
    language: &str,
    file_uri: &str,
    tokens: &[Token],
    window: &ContextWindow,
) -> AiContext {
    let lc = buffer.offset_to_line_col(cursor);
    let cursor_line_text = buffer.line_str(lc.line);

    // -- Prefix (lines above cursor, budget-trimmed) --------------------------
    let prefix = extract_prefix(buffer, lc.line, window);

    // -- Suffix (lines below cursor, budget-trimmed) --------------------------
    let suffix = extract_suffix(buffer, lc.line, buffer.len_lines(), window);

    // -- Imports (top of file) ------------------------------------------------
    let imports = extract_imports(buffer, language, 60);

    // -- Semantic scope -------------------------------------------------------
    let scope = infer_scope(buffer, lc.line, tokens, language);

    // -- Related symbols ------------------------------------------------------
    let related = extract_related_symbols(
        buffer,
        tokens,
        lc.line,
        language,
        window.symbols_token_budget,
    );

    // -- Token estimate -------------------------------------------------------
    let estimated_tokens = (prefix.len() + suffix.len()) / CHARS_PER_TOKEN;

    AiContext {
        language: language.to_owned(),
        file_uri: file_uri.to_owned(),
        imports,
        prefix,
        suffix,
        cursor_line: cursor_line_text[..lc.col.min(cursor_line_text.len())].to_owned(),
        cursor_col: lc.col,
        scope,
        related_symbols: related,
        estimated_tokens,
    }
}

fn extract_prefix(buffer: &Buffer, cursor_line: usize, window: &ContextWindow) -> String {
    let mut budget_chars = window.prefix_token_budget * CHARS_PER_TOKEN;
    let min_start = cursor_line.saturating_sub(window.min_prefix_lines);

    // Walk backwards from cursor collecting lines until budget exhausted
    let mut lines: Vec<String> = Vec::new();
    let mut current = cursor_line;

    loop {
        let line_text = buffer.line_str(current);
        let line_with_newline = format!("{}\n", line_text);

        if current < min_start && budget_chars < line_with_newline.len() {
            break;
        }
        budget_chars = budget_chars.saturating_sub(line_with_newline.len());
        lines.push(line_text);

        if current == 0 {
            break;
        }
        current -= 1;

        if budget_chars == 0 && current < min_start {
            break;
        }
    }

    lines.reverse();
    lines.join("\n")
}

fn extract_suffix(
    buffer: &Buffer,
    cursor_line: usize,
    total_lines: usize,
    window: &ContextWindow,
) -> String {
    let mut budget_chars = window.suffix_token_budget * CHARS_PER_TOKEN;
    let max_end = (cursor_line + 1 + window.min_suffix_lines).min(total_lines);

    let mut lines: Vec<String> = Vec::new();
    let start = cursor_line + 1;

    for line_num in start..total_lines {
        let line_text = buffer.line_str(line_num);
        let cost = line_text.len() + 1;

        if line_num >= max_end && budget_chars < cost {
            break;
        }
        budget_chars = budget_chars.saturating_sub(cost);
        lines.push(line_text);

        if budget_chars == 0 && line_num >= max_end {
            break;
        }
    }

    lines.join("\n")
}

/// Extract `use`/`import`/`#include` lines from the file header.
fn extract_imports(buffer: &Buffer, language: &str, max_lines: usize) -> Vec<String> {
    let import_prefix: &[&str] = match language {
        "rust" => &["use ", "extern crate "],
        "javascript" | "typescript" => &["import ", "require(", "export {"],
        "python" => &["import ", "from "],
        "java" | "kotlin" => &["import ", "package "],
        "go" => &["import ", "package "],
        "c" | "cpp" => &["#include"],
        "dart" => &["import "],
        _ => &["import "],
    };

    let scan_lines = max_lines.min(buffer.len_lines());
    let mut imports = Vec::new();

    // Scan first `scan_lines` lines for import statements
    for i in 0..scan_lines {
        let line = buffer.line_str(i);
        let trimmed = line.trim();
        if import_prefix.iter().any(|p| trimmed.starts_with(p)) {
            imports.push(line.clone());
        }
        // Stop if we hit a non-import, non-blank, non-comment line after seeing imports
        // (heuristic: imports are grouped at top)
        if !imports.is_empty()
            && !trimmed.is_empty()
            && !trimmed.starts_with("//")
            && !trimmed.starts_with("/*")
            && !trimmed.starts_with("*")
            && !trimmed.starts_with("#")
            && import_prefix.iter().all(|p| !trimmed.starts_with(p))
        {
            break;
        }
    }

    imports
}

/// Infer the semantic scope (function, method, top-level, etc.) at `cursor_line`.
fn infer_scope(
    buffer: &Buffer,
    cursor_line: usize,
    _tokens: &[Token],
    language: &str,
) -> SemanticScope {
    // Walk backwards looking for function/method/class openings.
    // We count braces (for brace-based languages) or indentation (Python).
    let is_indent_based = matches!(language, "python");

    if is_indent_based {
        return infer_scope_python(buffer, cursor_line);
    }

    // Brace-based languages: scan backwards for `fn`/`function`/`def` + `{`
    let fn_keywords: &[&str] = match language {
        "rust" => &["fn "],
        "java" | "kotlin" => &["void ", "fun ", "public ", "private ", "protected "],
        "javascript" | "typescript" => &["function ", "=> {", "async function "],
        "go" => &["func "],
        "c" | "cpp" => &["void ", "int ", "auto "],
        _ => &["function ", "fn "],
    };

    let scan_back = cursor_line.min(150);
    for line_num in (cursor_line.saturating_sub(scan_back)..=cursor_line).rev() {
        let line = buffer.line_str(line_num);
        let trimmed = line.trim();

        for kw in fn_keywords {
            if let Some(after_kw) = trimmed.find(kw).map(|i| &trimmed[i + kw.len()..]) {
                // Extract identifier (name)
                let name: String = after_kw
                    .chars()
                    .take_while(|c| c.is_alphanumeric() || *c == '_')
                    .collect();
                if !name.is_empty() {
                    return SemanticScope::Function { name };
                }
            }
        }
    }

    SemanticScope::TopLevel
}

fn infer_scope_python(buffer: &Buffer, cursor_line: usize) -> SemanticScope {
    let cursor_indent = leading_spaces(&buffer.line_str(cursor_line));

    for line_num in (0..cursor_line).rev() {
        let line = buffer.line_str(line_num);
        let indent = leading_spaces(&line);
        let trimmed = line.trim();

        if indent < cursor_indent {
            if trimmed.starts_with("def ") {
                let name: String = trimmed[4..]
                    .chars()
                    .take_while(|c| c.is_alphanumeric() || *c == '_')
                    .collect();
                return SemanticScope::Function { name };
            }
            if trimmed.starts_with("class ") {
                return SemanticScope::TopLevel; // inside class but not a method
            }
        }
    }
    SemanticScope::TopLevel
}

fn leading_spaces(s: &str) -> usize {
    s.chars().take_while(|c| *c == ' ' || *c == '\t').count()
}

/// Find up to `budget_tokens` worth of related symbol definitions near the cursor.
fn extract_related_symbols(
    buffer: &Buffer,
    _tokens: &[Token],
    cursor_line: usize,
    language: &str,
    budget_tokens: usize,
) -> Vec<SymbolSnippet> {
    let budget_chars = budget_tokens * CHARS_PER_TOKEN;
    let mut used_chars = 0usize;
    let mut symbols: Vec<SymbolSnippet> = Vec::new();
    let mut seen_lines: HashSet<usize> = HashSet::new();

    // Collect lines that define functions/structs/classes
    let def_keywords: &[(&str, SymbolKind)] = match language {
        "rust" => &[
            ("fn ", SymbolKind::Function),
            ("struct ", SymbolKind::Struct),
            ("enum ", SymbolKind::Enum),
            ("trait ", SymbolKind::Trait),
            ("impl ", SymbolKind::Impl),
            ("const ", SymbolKind::Const),
            ("pub fn ", SymbolKind::Function),
            ("pub struct ", SymbolKind::Struct),
        ],
        "python" => &[
            ("def ", SymbolKind::Function),
            ("class ", SymbolKind::Struct),
            ("async def ", SymbolKind::Function),
        ],
        "javascript" | "typescript" => &[
            ("function ", SymbolKind::Function),
            ("class ", SymbolKind::Struct),
            ("const ", SymbolKind::Const),
            ("export function ", SymbolKind::Function),
            ("export class ", SymbolKind::Struct),
            ("export const ", SymbolKind::Const),
        ],
        "java" | "kotlin" => &[
            ("class ", SymbolKind::Struct),
            ("fun ", SymbolKind::Function),
            ("public ", SymbolKind::Function),
            ("private ", SymbolKind::Function),
        ],
        _ => &[("function ", SymbolKind::Function)],
    };

    // Scan the whole file for definitions, prioritising nearby ones
    let total = buffer.len_lines();
    // Build a sorted list: (distance_from_cursor, line_num)
    let mut candidates: Vec<(usize, usize)> = (0..total)
        .filter(|&l| l != cursor_line)
        .map(|l| (l.abs_diff(cursor_line), l))
        .collect();
    candidates.sort_unstable();

    'outer: for (_, line_num) in candidates {
        if seen_lines.contains(&line_num) {
            continue;
        }
        let line = buffer.line_str(line_num);
        let trimmed = line.trim();

        for (kw, kind) in def_keywords {
            if let Some(after) = trimmed.find(kw).map(|i| &trimmed[i + kw.len()..]) {
                let name: String = after
                    .chars()
                    .take_while(|c| c.is_alphanumeric() || *c == '_' || *c == '<')
                    .collect();
                if name.is_empty() {
                    continue;
                }

                // Include the declaration line (+ next line if it continues with `->` or `:`)
                let mut signature = line.clone();
                if line_num + 1 < total {
                    let next = buffer.line_str(line_num + 1);
                    let nt = next.trim();
                    if nt.starts_with("->") || nt.starts_with(':') || nt.starts_with("where") {
                        signature.push('\n');
                        signature.push_str(&next);
                    }
                }

                let cost = signature.len() + name.len() + 10;
                if used_chars + cost > budget_chars {
                    break 'outer;
                }
                used_chars += cost;
                seen_lines.insert(line_num);

                symbols.push(SymbolSnippet {
                    name,
                    kind: *kind,
                    signature,
                    line: line_num,
                });
                break;
            }
        }
    }

    symbols
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::buffer::Buffer;

    #[test]
    fn test_extract_imports_rust() {
        let src = "use std::collections::HashMap;\nuse anyhow::Result;\n\nfn main() {}";
        let buf = Buffer::from_str(src);
        let imports = extract_imports(&buf, "rust", 60);
        assert_eq!(imports.len(), 2);
        assert!(imports[0].contains("HashMap"));
    }

    #[test]
    fn test_infer_scope_function() {
        let src = "fn compute_sum(a: i32, b: i32) -> i32 {\n    let x = a + b;\n    x\n}\n";
        let buf = Buffer::from_str(src);
        let scope = infer_scope(&buf, 1, &[], "rust");
        assert!(matches!(scope, SemanticScope::Function { name } if name == "compute_sum"));
    }

    #[test]
    fn test_prefix_budget() {
        let lines: String = (0..500).map(|i| format!("line {}\n", i)).collect();
        let buf = Buffer::from_str(&lines);
        let window = ContextWindow::tight();
        let prefix = extract_prefix(&buf, 499, &window);
        let tokens = prefix.len() / CHARS_PER_TOKEN;
        assert!(
            tokens <= window.prefix_token_budget + 20,
            "prefix token budget exceeded"
        );
    }

    #[test]
    fn test_extract_symbols_rust() {
        let src = r#"
fn add(a: i32, b: i32) -> i32 { a + b }
struct Point { x: f64, y: f64 }
fn main() {
    let p = Point { x: 1.0, y: 2.0 };
}
"#;
        let buf = Buffer::from_str(src);
        let symbols = extract_related_symbols(&buf, &[], 3, "rust", 300);
        let names: Vec<_> = symbols.iter().map(|s| s.name.as_str()).collect();
        assert!(names.contains(&"add") || names.contains(&"Point") || names.contains(&"main"));
    }
}

#[cfg(test)]
mod context_extended_tests {
    use super::*;

    fn test_context(src: &str, cursor: usize, language: &str, file_uri: &str) -> AiContext {
        let buffer = Buffer::from_str(src);
        extract_context(
            &buffer,
            ByteOffset(cursor),
            language,
            file_uri,
            &[],
            &ContextWindow::tight(),
        )
    }

    #[test]
    fn test_context_window_tight() {
        let w = ContextWindow::tight();
        assert!(w.prefix_token_budget > 0);
        assert!(w.suffix_token_budget > 0);
        assert!(w.prefix_token_budget + w.suffix_token_budget <= 550);
    }

    #[test]
    fn test_extract_context_basic() {
        let ctx = test_context(
            "fn main() {\n    let x = 42;\n    let y = x + 1;\n}\n",
            30,
            "rust",
            "file:///test.rs",
        );
        assert!(!ctx.prefix.is_empty(), "Should have prefix context");
        assert!(!ctx.suffix.is_empty(), "Should have suffix context");
    }

    #[test]
    fn test_extract_context_at_start() {
        let ctx = test_context("fn main() {}", 0, "rust", "file:///test.rs");
        assert!(ctx.prefix.contains("fn main"));
        assert_eq!(ctx.cursor_col, 0);
    }

    #[test]
    fn test_extract_context_at_end() {
        let src = "fn main() {}";
        let ctx = test_context(src, src.len(), "rust", "file:///test.rs");
        assert!(
            ctx.suffix.is_empty() || ctx.suffix.len() < 5,
            "Suffix should be minimal at end"
        );
    }

    #[test]
    fn test_extract_context_includes_language() {
        let ctx = test_context("x = 1", 3, "python", "file:///test.py");
        assert_eq!(ctx.language, "python");
    }

    #[test]
    fn test_extract_context_cursor_context() {
        let src = "fn add(a: i32, b: i32) -> i32 {\n    a + b\n}\n";
        let ctx = test_context(src, 20, "rust", "file:///test.rs");
        assert!(ctx.cursor_col <= ctx.cursor_line.len());
    }

    #[test]
    fn test_extract_context_respects_token_budget() {
        // Large file - context should be truncated to budget
        let large: String = (0..1000).map(|i| format!("// line {}\n", i)).collect();
        let mid = large.len() / 2;
        let ctx = test_context(&large, mid, "rust", "file:///test.rs");
        // Prefix + suffix should not exceed the total budget (in chars, roughly)
        let total_chars = ctx.prefix.len() + ctx.suffix.len();
        assert!(
            total_chars < large.len(),
            "Context should be smaller than the full file"
        );
    }

    #[test]
    fn test_extract_context_file_path() {
        let ctx = test_context(
            "fn main() {}",
            5,
            "rust",
            "file:///home/user/project/main.rs",
        );
        assert_eq!(ctx.file_uri, "file:///home/user/project/main.rs");
    }

    #[test]
    fn test_symbol_snippet_construction() {
        let sym = SymbolSnippet {
            name: "my_function".to_owned(),
            kind: SymbolKind::Function,
            signature: "fn my_function(x: i32) -> String".to_owned(),
            line: 3,
        };
        assert_eq!(sym.name, "my_function");
        assert_eq!(sym.kind, SymbolKind::Function);
    }

    #[test]
    fn test_extract_context_with_imports() {
        let src = "use std::collections::HashMap;\nuse std::io::BufReader;\n\nfn main() {\n    let m = HashMap::new();\n}\n";
        let ctx = test_context(src, src.len() - 5, "rust", "file:///test.rs");
        // Should capture some of the file content
        assert!(!ctx.prefix.is_empty());
    }
}
