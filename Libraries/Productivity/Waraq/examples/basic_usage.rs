// examples/basic_usage.rs
//
// Demonstrates the full editor API from Rust.
// Run with: cargo run --example basic_usage

use waraq_editor_core::{Editor, EditOp};
use waraq_editor_core::ai::context::{extract_context, ContextWindow};
use waraq_editor_core::ai::completion::{CompletionEngine, CompletionResponse};
use waraq_editor_core::ai::prompt::PromptBuilder;
use waraq_editor_core::ai::diff::SuggestionDiff;
use waraq_editor_core::core::types::{ByteOffset, LineCol};

fn main() {
    println!("=== Waraq Editor Core — Basic Usage ===\n");

    // ── 1. Create and edit a document ─────────────────────────────────────────
    println!("--- 1. Basic editing ---");
    let mut ed = Editor::from_str(
        "fn greet(name: &str) -> String {\n    todo!()\n}\n"
    );
    println!("Initial:\n{}", ed.buffer.to_string());

    // Replace the todo!() with real implementation
    let todo_start = ed.buffer.to_string().find("todo!()").unwrap();
    ed.apply(EditOp::replace(todo_start, todo_start + 7, "format!(\"Hello, {}!\", name)"));
    println!("After replace:\n{}", ed.buffer.to_string());

    // ── 2. Multi-cursor editing ───────────────────────────────────────────────
    println!("--- 2. Multi-cursor ---");
    let mut ed2 = Editor::from_str("foo\nbar\nbaz\n");
    let offsets = ed2.buffer.find_all("b");
    println!("Found 'b' at offsets: {:?}", offsets.iter().map(|o| o.0).collect::<Vec<_>>());
    for o in &offsets {
        ed2.cursors.add(o.0);
    }
    println!("Active cursors: {}", ed2.cursors.count());

    // ── 3. Undo / Redo ────────────────────────────────────────────────────────
    println!("\n--- 3. Undo/Redo ---");
    let mut ed3 = Editor::from_str("hello");
    ed3.apply(EditOp::insert(5, " world"));
    println!("After insert: {}", ed3.buffer.to_string());
    ed3.undo();
    println!("After undo:   {}", ed3.buffer.to_string());
    ed3.redo();
    println!("After redo:   {}", ed3.buffer.to_string());

    // ── 4. Render frame (simulates Flutter renderer input) ────────────────────
    println!("\n--- 4. Render frame ---");
    let ed4 = Editor::from_str("line 1\nline 2\nline 3\n");
    let frame = ed4.render_frame();
    println!("Total lines: {}", frame.total_lines);
    println!("Visible lines ({}):", frame.lines.len());
    for line in &frame.lines {
        println!("  [{:3}] {}", line.line_number, line.text);
    }

    // ── 5. Search ─────────────────────────────────────────────────────────────
    println!("\n--- 5. Search ---");
    let src = "let x = 1;\nlet y = 2;\nlet z = x + y;\n";
    let ed5 = Editor::from_str(src);
    let matches = ed5.buffer.find_all("let");
    println!("'let' found at {} offsets: {:?}", matches.len(),
        matches.iter().map(|o| o.0).collect::<Vec<_>>());

    // ── 6. Coordinate conversion ──────────────────────────────────────────────
    println!("\n--- 6. Coordinate conversion ---");
    let ed6 = Editor::from_str("hello\ncafé\nworld\n");
    let byte14 = ed6.buffer.offset_to_line_col(ByteOffset(14));
    println!("Byte 14 → line {}, col {}", byte14.line, byte14.col);
    let back = ed6.buffer.line_col_to_offset(byte14);
    println!("line {}, col {} → byte {}", byte14.line, byte14.col, back.0);
    assert_eq!(back.0, 14);

    // ── 7. AI context extraction ──────────────────────────────────────────────
    println!("\n--- 7. AI context extraction ---");
    let rust_code = r#"use std::collections::HashMap;

fn process_items(items: &[u32]) -> HashMap<u32, u32> {
    let mut counts = HashMap::new();
    for &item in items {
        *counts.entry(item).or_insert(0) += 1;
    }
    counts
}

fn main() {
    let data = vec![1, 2, 1, 3, 2, 1];
    let result = process_items(&data);
    // cursor is here
}
"#;
    let buf = waraq_editor_core::core::buffer::Buffer::from_str(rust_code);
    let cursor_line = 11; // "    // cursor is here"
    let cursor = buf.line_col_to_offset(LineCol::new(cursor_line, 4));
    let window = ContextWindow::default();
    let ctx = extract_context(&buf, cursor, "rust", "file:///main.rs", &[], &window);

    println!("Language: {}", ctx.language);
    println!("Imports: {:?}", ctx.imports);
    println!("Scope: {:?}", ctx.scope);
    println!("Est. tokens: {}", ctx.estimated_tokens);
    println!("Related symbols: {}", ctx.related_symbols.len());
    for sym in &ctx.related_symbols {
        println!("  {} {:?} @ line {}", sym.name, sym.kind, sym.line);
    }

    // ── 8. Prompt building ────────────────────────────────────────────────────
    println!("\n--- 8. Prompt building ---");
    let builder = PromptBuilder::for_deepseek();
    let completion_prompt = builder.build_inline_completion(&ctx);
    println!("FIM prompt mode: {:?}", completion_prompt.mode);
    println!("Est. tokens: {}", completion_prompt.estimated_tokens);
    let preview = completion_prompt.text.as_deref().unwrap_or("").chars().take(80).collect::<String>();
    println!("Prompt preview: {}...", preview);

    let edit_prompt = builder.build_edit_prompt(&ctx, "Add input validation");
    let msgs = edit_prompt.messages.as_ref().unwrap();
    println!("\nChat prompt has {} messages", msgs.len());
    println!("System: {}...", &msgs[0].content.chars().take(60).collect::<String>());

    // ── 9. Completion engine ──────────────────────────────────────────────────
    println!("\n--- 9. Completion engine ---");
    let mut engine = CompletionEngine::new();
    let prefix = "fn calculate(x: i32) -> i32 {\n    x * ";

    // Simulate first keystroke (starts debounce)
    engine.on_change(prefix, 10, "rust", 40);
    println!("After keystroke: pending = {}", engine.has_pending_request());

    // Simulate receiving a response
    let fake_response = CompletionResponse {
        request_id: 1,
        generated_text: "2 + 1".into(),
        truncated: false,
        finish_reason: "stop".into(),
        latency_ms: 85,
    };
    engine.pending_request_id = Some(1); // for test purposes
    if let Some(suggestion) = engine.on_response(fake_response, prefix, 10, "rust", 40) {
        println!("Suggestion: {:?}", suggestion.text);
        println!("Is multiline: {}", suggestion.is_multiline);
    }

    // Accept the suggestion
    if let Some(op) = engine.accept() {
        println!("Accepted → EditOp: {:?}", op);
    }
    println!("Stats: {:?}", engine.stats);

    // ── 10. Myers diff ────────────────────────────────────────────────────────
    println!("\n--- 10. Myers diff ---");
    let original = "fn greet(name: &str) {\n    println!(\"Hello\");\n}";
    let suggested = "fn greet(name: &str) {\n    println!(\"Hello, {}!\", name);\n    // Added\n}";
    let diff = SuggestionDiff::compute(original, suggested);
    println!("Diff summary: {}", diff.summary());
    println!("Is identical: {}", diff.is_identical());
    let ops = diff.to_edit_ops(0);
    println!("Generated {} edit ops", ops.len());

    // ── 11. Syntax tokenizer ──────────────────────────────────────────────────
    println!("\n--- 11. Syntax tokenizer ---");
    use waraq_editor_core::syntax::tokenizer::Tokenizer;
    let code = "fn main() {\n    let x: i32 = 42;\n    println!(\"{}\", x);\n}\n";
    let code_buf = waraq_editor_core::core::buffer::Buffer::from_str(code);
    let mut tokenizer = Tokenizer::new();
    let tokens = tokenizer.tokenize_full(&code_buf, "rust");
    println!("Tokenized {} tokens:", tokens.len());
    for tok in tokens.iter().take(10) {
        let text = &code[tok.start..tok.end.min(code.len())];
        println!("  line={} col={}-{} kind={:?} text={:?}",
            tok.line, tok.col_start, tok.col_end, tok.kind, text);
    }
    if tokens.len() > 10 { println!("  ... and {} more", tokens.len() - 10); }

    println!("\n=== Done ===");
}
