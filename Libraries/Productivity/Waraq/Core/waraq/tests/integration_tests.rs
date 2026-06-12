use waraq_core::core::config::{IndentStyle, LineEnding};
use waraq_core::core::search::SearchQuery;
use waraq_core::core::session::{capture, restore, Session, SessionStore};
use waraq_core::core::types::{ByteOffset, LineCol};
use waraq_core::core::workspace::Workspace;
use waraq_core::lsp::protocol::{Diagnostic, DiagnosticSeverity, LspPosition, LspRange};
use waraq_core::{EditOp, Editor};
use waraq_core::{KeyInput, MotionKind};

// ── Basic editing ────────────────────────────────────────────────────────────

#[test]
fn test_type_and_delete_roundtrip() {
    let mut ed = Editor::new();
    for (i, ch) in "Hello, World!".chars().enumerate() {
        ed.apply(EditOp::type_char(i, ch));
    }
    assert_eq!(ed.buffer.to_string(), "Hello, World!");
    ed.apply(EditOp::delete(5, 12));
    assert_eq!(ed.buffer.to_string(), "Hello!");
}

#[test]
fn test_replace_selection() {
    let mut ed = Editor::from_str("The quick brown fox");
    ed.apply(EditOp::replace(4, 9, "slow"));
    assert_eq!(ed.buffer.to_string(), "The slow brown fox");
}

#[test]
fn test_multiline_insert() {
    let mut ed = Editor::from_str("fn main() {\n}\n");
    ed.apply(EditOp::insert(12, "\n    println!(\"hello\");"));
    assert_eq!(ed.buffer.len_lines(), 4);
    assert!(ed.buffer.to_string().contains("println!"));
}

#[test]
fn test_large_file() {
    let content: String = (0..50_000)
        .map(|i| format!("    let x_{} = {};\n", i, i))
        .collect();
    let mut ed = Editor::from_str(&content);
    assert_eq!(ed.buffer.len_lines(), 50_001);
    let mid = ed.buffer.len_bytes() / 2;
    ed.apply(EditOp::insert(mid, "// inserted\n"));
    assert_eq!(ed.buffer.len_lines(), 50_002);
    ed.undo();
    assert_eq!(ed.buffer.len_lines(), 50_001);
}

// ── Undo / redo with groups ──────────────────────────────────────────────────

#[test]
fn test_undo_single_edit() {
    let mut ed = Editor::from_str("hello");
    ed.apply(EditOp::insert(5, " world"));
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "hello");
}

#[test]
fn test_redo_after_undo() {
    let mut ed = Editor::new();
    ed.apply(EditOp::insert(0, "abc"));
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "");
    ed.redo();
    assert_eq!(ed.buffer.to_string(), "abc");
}

#[test]
fn test_apply_batch_undoes_atomically() {
    let mut ed = Editor::new();
    ed.apply_batch(vec![
        EditOp::insert(0, "a"),
        EditOp::insert(1, "b"),
        EditOp::insert(2, "c"),
    ]);
    assert_eq!(ed.buffer.to_string(), "abc");
    ed.undo();
    assert_eq!(
        ed.buffer.to_string(),
        "",
        "Group undo must remove all 3 chars"
    );
}

#[test]
fn test_apply_batch_redo_atomically() {
    let mut ed = Editor::new();
    ed.apply_batch(vec![EditOp::insert(0, "x"), EditOp::insert(1, "y")]);
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "");
    ed.redo();
    assert_eq!(ed.buffer.to_string(), "xy", "Group redo must restore both");
}

#[test]
fn test_redo_cleared_after_new_edit() {
    let mut ed = Editor::from_str("hello");
    ed.apply(EditOp::insert(5, " world"));
    ed.undo();
    assert!(ed.undo_stack.can_redo());
    ed.apply(EditOp::insert(5, " rust"));
    assert!(!ed.undo_stack.can_redo());
    assert_eq!(ed.buffer.to_string(), "hello rust");
}

#[test]
fn test_undo_multiple_edits_sequential() {
    let mut ed = Editor::new();
    ed.apply(EditOp::insert(0, "a"));
    ed.apply(EditOp::insert(1, "b"));
    ed.apply(EditOp::insert(2, "c"));
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "ab");
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "a");
    ed.undo();
    assert_eq!(ed.buffer.to_string(), "");
    assert!(ed.undo().is_none());
}

// ── Key input handler ────────────────────────────────────────────────────────

#[test]
fn test_handle_key_char_basic() {
    let mut ed = Editor::new();
    ed.handle_key(KeyInput::Char('h'));
    ed.handle_key(KeyInput::Char('i'));
    assert_eq!(ed.buffer.to_string(), "hi");
    assert_eq!(ed.cursors.primary().pos.0, 2);
}

#[test]
fn test_handle_key_backspace() {
    let mut ed = Editor::from_str("hello");
    ed.cursors.move_to(5, false);
    ed.handle_key(KeyInput::Backspace);
    assert_eq!(ed.buffer.to_string(), "hell");
}

#[test]
fn test_handle_key_delete_forward() {
    let mut ed = Editor::from_str("hello");
    ed.cursors.move_to(0, false);
    ed.handle_key(KeyInput::Delete);
    assert_eq!(ed.buffer.to_string(), "ello");
}

#[test]
fn test_handle_key_enter_after_brace_rust() {
    let mut ed = Editor::from_str("fn main() {");
    ed.set_language("rust");
    ed.cursors.move_to(11, false);
    ed.handle_key(KeyInput::Enter);
    assert!(
        ed.buffer.to_string().contains("\n    "),
        "Auto-indent after brace: {:?}",
        ed.buffer.to_string()
    );
}

#[test]
fn test_handle_key_enter_after_colon_python() {
    let mut ed = Editor::from_str("def foo():");
    ed.set_language("python");
    ed.cursors.move_to(10, false);
    ed.handle_key(KeyInput::Enter);
    assert!(
        ed.buffer.to_string().contains("\n    "),
        "Python auto-indent after colon"
    );
}

#[test]
fn test_handle_key_tab_inserts_indent() {
    let mut ed = Editor::new();
    ed.handle_key(KeyInput::Tab);
    assert_eq!(ed.buffer.to_string(), "    ");
}

#[test]
fn test_auto_pair_open_bracket() {
    let mut ed = Editor::new();
    ed.set_language("rust");
    ed.handle_key(KeyInput::Char('('));
    assert_eq!(ed.buffer.to_string(), "()");
    assert_eq!(ed.cursors.primary().pos.0, 1);
}

#[test]
fn test_auto_pair_skip_close_bracket() {
    let mut ed = Editor::from_str("()");
    ed.set_language("rust");
    ed.cursors.move_to(1, false);
    ed.handle_key(KeyInput::Char(')'));
    assert_eq!(ed.buffer.to_string(), "()", "Should not insert extra )");
    assert_eq!(
        ed.cursors.primary().pos.0,
        2,
        "Cursor should skip to after )"
    );
}

#[test]
fn test_auto_pair_disabled() {
    let mut ed = Editor::new();
    ed.config.auto_close_brackets = false;
    ed.config.auto_close_quotes = false;
    ed.set_language("rust");
    ed.handle_key(KeyInput::Char('('));
    assert_eq!(ed.buffer.to_string(), "(");
}

// ── Motion ──────────────────────────────────────────────────────────────────

#[test]
fn test_motion_char_left_right() {
    let mut ed = Editor::from_str("hello");
    ed.cursors.move_to(3, false);
    ed.handle_key(KeyInput::Motion(MotionKind::CharLeft));
    assert_eq!(ed.cursors.primary().pos.0, 2);
    ed.handle_key(KeyInput::Motion(MotionKind::CharRight));
    assert_eq!(ed.cursors.primary().pos.0, 3);
}

#[test]
fn test_motion_document_start_end() {
    let mut ed = Editor::from_str("hello world");
    ed.cursors.move_to(5, false);
    ed.handle_key(KeyInput::Motion(MotionKind::DocumentEnd));
    assert_eq!(ed.cursors.primary().pos.0, 11);
    ed.handle_key(KeyInput::Motion(MotionKind::DocumentStart));
    assert_eq!(ed.cursors.primary().pos.0, 0);
}

#[test]
fn test_motion_with_selection() {
    let mut ed = Editor::from_str("hello world");
    ed.cursors.move_to(0, false);
    ed.handle_key(KeyInput::Select(MotionKind::LineEnd));
    let sel = ed.cursors.primary().selection();
    assert!(sel.is_some());
    assert_eq!(sel.unwrap().end.0, 11);
}

#[test]
fn test_motion_matching_bracket() {
    let mut ed = Editor::from_str("fn foo(a, b) {}");
    ed.cursors.move_to(6, false);
    ed.handle_key(KeyInput::Motion(MotionKind::MatchingBracket));
    let pos = ed.cursors.primary().pos.0;
    assert_eq!(&ed.buffer.to_string()[pos..pos + 1], ")");
}

#[test]
fn test_motion_updates_viewport() {
    let content: String = (0..100).map(|i| format!("line {}\n", i)).collect();
    let mut ed = Editor::from_str(&content);
    ed.viewport.set_height(20);
    ed.handle_key(KeyInput::Motion(MotionKind::DocumentEnd));
    let cursor_line = ed.buffer.offset_to_line_col(ed.cursors.primary().pos).line;
    assert!(
        ed.viewport.contains_line(cursor_line),
        "Viewport should follow cursor"
    );
}

// ── Selection ────────────────────────────────────────────────────────────────

#[test]
fn test_select_word_at_cursor() {
    let mut ed = Editor::from_str("hello world");
    ed.cursors.move_to(7, false);
    ed.select_word_at_cursor();
    let sel = ed.cursors.primary().selection().unwrap();
    assert_eq!(ed.buffer.text_in_range(sel.as_range()), "world");
}

#[test]
fn test_select_line_at_cursor() {
    let mut ed = Editor::from_str("hello\nworld\n");
    ed.cursors.move_to(7, false);
    ed.select_line_at_cursor();
    let sel = ed.cursors.primary().selection().unwrap();
    assert_eq!(ed.buffer.text_in_range(sel.as_range()), "world\n");
}

#[test]
fn test_select_all() {
    let mut ed = Editor::from_str("hello world");
    ed.select_all();
    let sel = ed.cursors.primary().selection().unwrap();
    assert_eq!(sel.start.0, 0);
    assert_eq!(sel.end.0, 11);
}

#[test]
fn test_add_cursor_at_next_occurrence() {
    let mut ed = Editor::from_str("foo bar foo baz foo");
    ed.cursors.move_to(0, false);
    ed.cursors.move_to(3, true);
    ed.add_cursor_at_next_occurrence();
    assert_eq!(ed.cursors.count(), 2);
}

#[test]
fn test_cursor_adjusts_after_insert() {
    let mut ed = Editor::from_str("hello world");
    ed.cursors.move_to(6, false);
    ed.apply(EditOp::insert(0, "say "));
    assert_eq!(ed.cursors.primary().pos.0, 10);
}

// ── Search ───────────────────────────────────────────────────────────────────

#[test]
fn test_search_start_finds_first() {
    let mut ed = Editor::from_str("foo bar foo baz foo");
    let m = ed.search_start(SearchQuery::literal("foo")).unwrap();
    assert_eq!(m.start.0, 0);
    assert_eq!(m.total, 3);
}

#[test]
fn test_search_next_and_prev() {
    let mut ed = Editor::from_str("foo bar foo baz foo");
    ed.search_start(SearchQuery::literal("foo"));
    let m = ed.search_next().unwrap();
    assert_eq!(m.start.0, 8);
    let m2 = ed.search_prev().unwrap();
    assert_eq!(m2.start.0, 0);
}

#[test]
fn test_search_next_wraps() {
    let mut ed = Editor::from_str("foo bar foo");
    ed.search_start(SearchQuery::literal("foo"));
    ed.search_next();
    let m = ed.search_next().unwrap();
    assert_eq!(m.index, 0);
}

#[test]
fn test_replace_current() {
    let mut ed = Editor::from_str("foo bar foo");
    ed.search_start(SearchQuery::literal("foo"));
    ed.replace_current("qux");
    assert!(ed.buffer.to_string().starts_with("qux"));
}

#[test]
fn test_replace_all_matches() {
    let mut ed = Editor::from_str("foo bar foo baz foo");
    ed.search_start(SearchQuery::literal("foo"));
    let results = ed.replace_all_matches("X");
    assert_eq!(results.len(), 3);
    assert!(!ed.buffer.to_string().contains("foo"));
}

#[test]
fn test_search_refreshes_after_edit() {
    let mut ed = Editor::from_str("foo bar foo");
    ed.search_start(SearchQuery::literal("foo"));
    assert_eq!(ed.search.as_ref().unwrap().match_count(), 2);
    ed.apply(EditOp::insert(ed.buffer.len_bytes(), " foo"));
    assert_eq!(ed.search.as_ref().unwrap().match_count(), 3);
}

#[test]
fn test_search_regex() {
    let mut ed = Editor::from_str("cat bat hat");
    let mut q = SearchQuery::literal(".at");
    q.regex = true;
    let m = ed.search_start(q).unwrap();
    assert_eq!(m.total, 3);
}

// ── Folding ──────────────────────────────────────────────────────────────────

#[test]
fn test_toggle_fold() {
    let src = "fn main() {\n    let x = 1;\n    let y = 2;\n}\n";
    let mut ed = Editor::from_str(src);
    ed.set_language("rust");
    if let Some(f) = ed.folds.all().iter().find(|f| f.is_valid()).cloned() {
        let start = f.start_line;
        assert!(!ed.folds.is_line_hidden(start + 1));
        ed.toggle_fold(start);
        assert!(ed.folds.is_line_hidden(start + 1));
        ed.toggle_fold(start);
        assert!(!ed.folds.is_line_hidden(start + 1));
    }
}

#[test]
fn test_fold_all_unfold_all() {
    let src = "fn foo() {\n    let a = 1;\n}\nfn bar() {\n    let b = 2;\n}\n";
    let mut ed = Editor::from_str(src);
    ed.set_language("rust");
    ed.fold_all();
    for r in ed.folds.all() {
        if r.is_valid() {
            assert!(r.collapsed);
        }
    }
    ed.unfold_all();
    for r in ed.folds.all() {
        assert!(!r.collapsed);
    }
}

// ── Config detection ─────────────────────────────────────────────────────────

#[test]
fn test_from_str_detects_spaces_4() {
    let ed = Editor::from_str("fn foo() {\n    let x = 1;\n}\n");
    assert_eq!(ed.config.indent_style, IndentStyle::Spaces);
    assert_eq!(ed.config.indent_width, 4);
}

#[test]
fn test_from_str_detects_tabs() {
    let ed = Editor::from_str("fn foo() {\n\tlet x = 1;\n}\n");
    assert_eq!(ed.config.indent_style, IndentStyle::Tabs);
}

#[test]
fn test_from_str_detects_crlf() {
    let ed = Editor::from_str("line1\r\nline2\r\nline3\r\n");
    assert_eq!(ed.config.line_ending, LineEnding::CrLf);
}

// ── Diagnostics ──────────────────────────────────────────────────────────────

#[test]
fn test_diagnostics_in_render_frame() {
    let mut ed = Editor::from_str("let x = undeclared;");
    ed.set_language("rust");
    ed.viewport.set_height(10);
    ed.lsp_state.update_diagnostics(vec![Diagnostic {
        range: LspRange {
            start: LspPosition {
                line: 0,
                character: 8,
            },
            end: LspPosition {
                line: 0,
                character: 18,
            },
        },
        severity: DiagnosticSeverity::Error,
        message: "cannot find value".into(),
        source: None,
        code: None,
    }]);
    let frame = ed.render_frame();
    assert!(!frame.diagnostics.is_empty());
    assert_eq!(frame.diagnostics[0].severity, 1);
}

// ── Render frame all fields ───────────────────────────────────────────────────

#[test]
fn test_render_frame_all_fields() {
    let mut ed = Editor::from_str("fn main() {\n    let x = 1;\n}\n");
    ed.set_language("rust");
    ed.viewport.set_height(20);
    ed.search_start(SearchQuery::literal("let"));
    let frame = ed.render_frame();
    assert!(!frame.lines.is_empty(), "lines");
    assert!(!frame.cursors.is_empty(), "cursors");
    assert_eq!(frame.language, "rust", "language");
    assert!(!frame.search_matches.is_empty(), "search_matches for 'let'");
    assert!(frame.search_matches[0].is_current, "first match is current");
}

#[test]
fn test_render_frame_with_selection() {
    let mut ed = Editor::from_str("hello world");
    ed.select_all();
    let frame = ed.render_frame();
    assert!(!frame.selections.is_empty());
    assert_eq!(frame.selections[0].start, 0);
    assert_eq!(frame.selections[0].end, 11);
}

#[test]
fn test_render_frame_viewport_clipping() {
    let content: String = (0..200).map(|i| format!("line {}\n", i)).collect();
    let mut ed = Editor::from_str(&content);
    ed.viewport.set_height(30);
    ed.viewport.scroll_to_line(50, 200);
    let frame = ed.render_frame();
    assert_eq!(frame.lines.len(), 30);
    assert_eq!(frame.lines[0].line_number, 50);
}

// ── Coordinates / Unicode ────────────────────────────────────────────────────

#[test]
fn test_byte_offset_to_line_col() {
    let ed = Editor::from_str("hello\nworld\nrust\n");
    let lc = ed.buffer.offset_to_line_col(ByteOffset(6));
    assert_eq!(lc.line, 1);
    assert_eq!(lc.col, 0);
}

#[test]
fn test_unicode_multibyte() {
    let content = "café\nbar\n";
    let ed = Editor::from_str(content);
    assert_eq!(ed.buffer.len_bytes(), content.len());
    assert_eq!(ed.buffer.len_lines(), 3);
}

#[test]
fn test_word_range() {
    let ed = Editor::from_str("fn compute_sum(a: i32) -> i32");
    let range = ed.buffer.word_range_at(ByteOffset(5));
    assert_eq!(ed.buffer.text_in_range(range), "compute_sum");
}

// ── Session ──────────────────────────────────────────────────────────────────

#[test]
fn test_session_capture_restore() {
    let mut ed = Editor::from_str("hello world\nline two\n");
    ed.set_language("rust");
    ed.file_uri = "file:///test.rs".into();
    ed.cursors.move_to(5, false);
    ed.viewport.set_height(30);
    let session = capture(&ed);
    let restored = restore(&session);
    assert_eq!(restored.language, "rust");
    assert_eq!(restored.file_uri, "file:///test.rs");
    assert_eq!(restored.cursors.primary().pos.0, 5);
    assert_eq!(restored.buffer.to_string(), ed.buffer.to_string());
}

#[test]
fn test_session_json_roundtrip() {
    let mut ed = Editor::from_str("fn main() {}");
    ed.set_language("rust");
    let session = capture(&ed);
    let json = session.to_json();
    let restored = Session::from_json(&json).unwrap();
    assert_eq!(restored.language, "rust");
    assert_eq!(restored.content, Some("fn main() {}".into()));
}

#[test]
fn test_session_restore_with_search() {
    let mut ed = Editor::from_str("foo bar foo baz");
    ed.search_start(SearchQuery::literal("foo"));
    let session = capture(&ed);
    let restored = restore(&session);
    assert!(restored.search.is_some());
    assert_eq!(restored.search.as_ref().unwrap().match_count(), 2);
}

// ── Workspace ────────────────────────────────────────────────────────────────

#[test]
fn test_workspace_open_close_switch() {
    let mut ws = Workspace::new("file:///project");
    let id1 = ws.open("file:///a.rs", "rust", "fn main() {}");
    let _id2 = ws.open("file:///b.py", "python", "print('hi')");
    assert_eq!(ws.tab_count(), 2);
    ws.switch_to(id1);
    assert_eq!(ws.active_file_uri(), Some("file:///a.rs"));
    ws.close(id1);
    assert_eq!(ws.tab_count(), 1);
}

#[test]
fn test_workspace_find_in_files() {
    let mut ws = Workspace::new("file:///project");
    ws.open("file:///a.rs", "rust", "fn foo() { let x = 1; }");
    ws.open("file:///b.rs", "rust", "fn bar() { let y = foo(); }");
    let result = ws.find_in_files(&SearchQuery::literal("foo"));
    assert_eq!(result.files_matched, 2);
    assert!(result.total_matches >= 2);
}

#[test]
fn test_workspace_replace_in_files() {
    let mut ws = Workspace::new("file:///project");
    ws.open("file:///a.rs", "rust", "foo bar foo");
    ws.open("file:///b.rs", "rust", "foo baz");
    let n = ws.replace_in_files(&SearchQuery::literal("foo"), "qux");
    assert_eq!(n, 3);
}

#[test]
fn test_workspace_session_roundtrip() {
    let mut ws = Workspace::new("file:///project");
    ws.open("file:///a.rs", "rust", "fn main() {}");
    ws.open("file:///b.py", "python", "print('hi')");
    let store = ws.save_sessions();
    let json = store.to_json();
    let mut ws2 = Workspace::new("file:///project");
    let store2 = SessionStore::from_json(&json).unwrap();
    ws2.load_sessions(&store2);
    assert_eq!(ws2.tab_count(), 2);
}

// ── AI ───────────────────────────────────────────────────────────────────────

#[test]
fn test_ai_context_imports_extracted() {
    use waraq_core::ai::context::{extract_context, ContextWindow};
    let src =
        "use std::collections::HashMap;\nuse anyhow::Result;\n\nfn main() {\n    let x = 1;\n}\n";
    let buf = waraq_core::core::buffer::Buffer::from_str(src);
    let cursor = buf.line_col_to_offset(LineCol::new(4, 14));
    let ctx = extract_context(
        &buf,
        cursor,
        "rust",
        "file:///main.rs",
        &[],
        &ContextWindow::default(),
    );
    assert!(ctx.imports.iter().any(|i| i.contains("HashMap")));
}

#[test]
fn test_diff_and_apply() {
    use waraq_core::ai::diff::SuggestionDiff;
    let diff = SuggestionDiff::compute(
        "fn greet() {\n    println!(\"Hello\");\n}",
        "fn greet() {\n    println!(\"Hello, world!\");\n}",
    );
    assert_eq!(diff.total_insertions, 1);
    assert_eq!(diff.total_deletions, 1);
}

#[test]
fn test_completion_postprocess() {
    use waraq_core::ai::completion::postprocess_completion;
    assert_eq!(
        postprocess_completion("```rust\nlet x = 42;\n```", "", "rust", 10),
        "let x = 42;"
    );
    assert_eq!(
        postprocess_completion("a\nb\nc\nd\ne", "", "rust", 3)
            .lines()
            .count(),
        3
    );
}

// ═══════════════════════════════════════════════════════════════════════════════
// INDENT GUIDES
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_indent_guides_basic() {
    use waraq_core::IndentGuideEngine;
    let src = "fn main() {\n    let x = 1;\n    if true {\n        let y = 2;\n    }\n}\n";
    let b = waraq_core::core::buffer::Buffer::from_str(src);
    let eng = IndentGuideEngine::new(4, false);
    let guides = eng.guides_for_viewport(&b, 0, 5, 3);
    // Line 0 (no indent) → 0 guides
    assert_eq!(guides[0].guides.len(), 0);
    // Line 1 (4 spaces, level 1) → 1 guide at col 0
    assert_eq!(guides[1].guides.len(), 1);
    assert_eq!(guides[1].guides[0].column, 0);
    // Line 3 (8 spaces, level 2) → 2 guides
    assert_eq!(guides[3].guides.len(), 2);
}

#[test]
fn test_indent_guides_in_render_frame() {
    let mut ed = Editor::from_str("fn main() {\n    let x = 1;\n}\n");
    ed.set_language("rust");
    ed.viewport.set_height(20);
    let frame = ed.render_frame();
    // RenderFrame should include indent_guides
    assert!(
        !frame.indent_guides.is_empty(),
        "RenderFrame should include indent guides"
    );
}

#[test]
fn test_render_frame_has_minimap_data() {
    let mut ed = Editor::from_str("hello world\n");
    ed.viewport.set_height(10);
    // Add a decoration with overview ruler
    use waraq_core::core::decoration::{
        DecorationOptions, DecorationSpec, OverviewRulerDecoration, OverviewRulerLane,
    };
    use waraq_core::core::types::Range;
    let mut opts = DecorationOptions::default();
    opts.overview_ruler = Some(OverviewRulerDecoration {
        color: "#FF0000".into(),
        lane: OverviewRulerLane::Left,
    });
    ed.delta_decorations(
        &[],
        &[(
            DecorationSpec {
                range: Range::new(0, 5),
                options: opts,
            },
            "test".into(),
        )],
    );
    let frame = ed.render_frame();
    assert!(
        !frame.minimap.is_empty(),
        "RenderFrame should include minimap items for decorated lines"
    );
}

#[test]
fn test_render_frame_word_wrap_field() {
    let mut ed = Editor::from_str("hello");
    ed.config.word_wrap = waraq_core::core::config::WordWrap::Off;
    let frame = ed.render_frame();
    assert!(!frame.word_wrap, "word_wrap should be false when Off");

    ed.config.word_wrap = waraq_core::core::config::WordWrap::On;
    let frame2 = ed.render_frame();
    assert!(frame2.word_wrap, "word_wrap should be true when On");
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORD WRAP
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_word_wrap_engine_off() {
    use waraq_core::core::wordwrap::WrapEngine;
    let b = Editor::from_str("hello\nworld\n").buffer;
    let mut eng = WrapEngine::off();
    assert_eq!(eng.total_visual_lines(&b), b.len_lines());
    assert_eq!(eng.logical_to_visual_line(0, &b), 0);
    assert_eq!(eng.logical_to_visual_line(1, &b), 1);
}

#[test]
fn test_word_wrap_engine_column() {
    use waraq_core::core::config::WordWrap;
    use waraq_core::core::wordwrap::WrapEngine;
    let long_line = "a".repeat(100);
    let b = Editor::from_str(&long_line).buffer;
    let mut eng = WrapEngine::new(WordWrap::Column(20));
    let total = eng.total_visual_lines(&b);
    assert!(
        total > 1,
        "100-char line should wrap into multiple visual lines"
    );
    // logical line 0 should map to visual line 0
    assert_eq!(eng.logical_to_visual_line(0, &b), 0);
}

#[test]
fn test_word_wrap_visual_lines_text_continuity() {
    use waraq_core::core::config::WordWrap;
    use waraq_core::core::wordwrap::WrapEngine;
    let src = "hello world foo bar baz";
    let b = Editor::from_str(src).buffer;
    let mut eng = WrapEngine::new(WordWrap::Column(10));
    let total = eng.total_visual_lines(&b);
    let lines = eng.visual_lines(&b, 0, total.saturating_sub(1));
    // Concatenating all visual line text should equal the original line
    let reconstructed: String = lines.iter().map(|l| l.text(src)).collect();
    assert_eq!(
        reconstructed, src,
        "Visual lines should reconstruct original text"
    );
}

// ═══════════════════════════════════════════════════════════════════════════════
// GIT GUTTER
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_git_gutter_no_changes() {
    use waraq_core::core::git_gutter::GitGutter;
    let content = "line1\nline2\nline3\n";
    let hunks = GitGutter::diff(content, content);
    assert!(hunks.is_empty(), "Identical content → no hunks");
}

#[test]
fn test_git_gutter_added_line() {
    use waraq_core::core::git_gutter::{GitGutter, GutterHunkKind};
    let head = "line1\nline3\n";
    let current = "line1\nline2\nline3\n";
    let hunks = GitGutter::diff(head, current);
    assert!(!hunks.is_empty());
    assert!(hunks.iter().any(|h| h.kind == GutterHunkKind::Added));
}

#[test]
fn test_git_gutter_deleted_line() {
    use waraq_core::core::git_gutter::{GitGutter, GutterHunkKind};
    let head = "line1\nline2\nline3\n";
    let current = "line1\nline3\n";
    let hunks = GitGutter::diff(head, current);
    assert!(!hunks.is_empty());
    assert!(hunks
        .iter()
        .any(|h| h.kind == GutterHunkKind::Deleted || h.kind == GutterHunkKind::Modified));
}

#[test]
fn test_git_gutter_modified_line() {
    use waraq_core::core::git_gutter::GitGutter;
    let head = "line1\noriginal\nline3\n";
    let current = "line1\nmodified\nline3\n";
    let hunks = GitGutter::diff(head, current);
    assert!(!hunks.is_empty());
}

#[test]
fn test_git_gutter_decorations_applied() {
    use waraq_core::core::decoration::DecorationKind;
    use waraq_core::core::git_gutter::GitGutter;
    let mut ed = Editor::from_str("line1\nnew line\nline3\n");
    let head = "line1\nline3\n";
    let hunks = GitGutter::diff(head, &ed.buffer.to_string());
    GitGutter::apply_to_decorations(&mut ed.decorations, &hunks, &ed.buffer);
    // Should have Diff decorations
    if !hunks.is_empty() {
        assert!(ed
            .decorations
            .all()
            .iter()
            .any(|d| d.options.kind == DecorationKind::Diff));
    }
}

#[test]
fn test_git_gutter_json_roundtrip() {
    use waraq_core::core::git_gutter::GitGutter;
    let hunks = GitGutter::diff("a\nb\nc\n", "a\nB\nc\nd\n");
    let json = GitGutter::hunks_to_json(&hunks);
    let restored = GitGutter::hunks_from_json(&json);
    assert_eq!(hunks.len(), restored.len());
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDITOR GROUPS
// ═══════════════════════════════════════════════════════════════════════════════

use waraq_core::{EditorGroupLayout, GroupOrientation};

#[test]
fn test_editor_group_layout_new() {
    let l = EditorGroupLayout::new();
    assert_eq!(l.group_count(), 1);
    assert!(l.active_group().is_some());
    assert_eq!(l.total_tabs(), 0);
}

#[test]
fn test_editor_group_split_and_close() {
    let mut l = EditorGroupLayout::new();
    let g2 = l.split(GroupOrientation::Column);
    assert_eq!(l.group_count(), 2);
    assert!(l.close_group(g2));
    assert_eq!(l.group_count(), 1);
}

#[test]
fn test_editor_group_open_file() {
    let mut l = EditorGroupLayout::new();
    let (gid, tid) = l.open_in_active("file:///main.rs", "rust");
    assert_eq!(gid, 0);
    assert_eq!(l.total_tabs(), 1);
    assert_eq!(l.active_group().unwrap().active_tab, Some(tid));
    assert_eq!(
        l.active_group().unwrap().active_tab().unwrap().file_uri,
        "file:///main.rs"
    );
}

#[test]
fn test_editor_group_no_duplicate_open() {
    let mut l = EditorGroupLayout::new();
    let (_, t1) = l.open_in_active("file:///a.rs", "rust");
    let (_, t2) = l.open_in_active("file:///a.rs", "rust");
    assert_eq!(t1, t2);
    assert_eq!(l.total_tabs(), 1);
}

#[test]
fn test_editor_group_move_tab_between_groups() {
    let mut l = EditorGroupLayout::new();
    let g2 = l.split(GroupOrientation::Column);
    l.focus_group(0);
    let (_, tid) = l.open_in_active("file:///a.rs", "rust");
    l.move_tab(tid, 0, g2);
    assert_eq!(l.group(0).unwrap().tab_count(), 0);
    assert_eq!(l.group(g2).unwrap().tab_count(), 1);
}

#[test]
fn test_editor_group_dirty_tracking() {
    let mut l = EditorGroupLayout::new();
    let (_, tid) = l.open_in_active("file:///a.rs", "rust");
    assert_eq!(l.dirty_tab_count(), 0);
    l.active_group_mut().unwrap().mark_dirty(tid, true);
    assert_eq!(l.dirty_tab_count(), 1);
}

#[test]
fn test_editor_group_json_roundtrip() {
    let mut l = EditorGroupLayout::new();
    l.open_in_active("file:///a.rs", "rust");
    let g2 = l.split(GroupOrientation::Column);
    l.open_in_group(g2, "file:///b.py", "python");
    let json = l.to_json();
    let l2 = EditorGroupLayout::from_json(&json).unwrap();
    assert_eq!(l2.group_count(), 2);
    assert_eq!(l2.total_tabs(), 2);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

use waraq_core::core::config::WordWrap;
use waraq_core::LayeredSettings;

#[test]
fn test_settings_apply_tab_size() {
    let mut ls = LayeredSettings::new();
    ls.user.set("editor.tabSize", serde_json::json!(2));
    ls.user.set("editor.insertSpaces", serde_json::json!(true));
    let cfg = ls.resolve_config(None);
    assert_eq!(cfg.indent_width, 2);
}

#[test]
fn test_settings_word_wrap() {
    let mut ls = LayeredSettings::new();
    ls.user.set("editor.wordWrap", serde_json::json!("bounded"));
    ls.user.set("editor.wordWrapColumn", serde_json::json!(120));
    let cfg = ls.resolve_config(None);
    assert!(matches!(cfg.word_wrap, WordWrap::Column(120)));
}

#[test]
fn test_settings_language_override() {
    let mut ls = LayeredSettings::new();
    ls.user.set("editor.tabSize", serde_json::json!(4));
    let mut go = waraq_core::core::settings::SettingsStore::new();
    go.set("editor.tabSize", serde_json::json!(8));
    go.set("editor.insertSpaces", serde_json::json!(false));
    ls.language_overrides.insert("go".to_owned(), go);
    let cfg_go = ls.resolve_config(Some("go"));
    let cfg_rust = ls.resolve_config(Some("rust"));
    assert_eq!(cfg_go.indent_width, 8);
    assert_eq!(cfg_rust.indent_width, 4);
}

#[test]
fn test_settings_workspace_overrides_user() {
    let mut ls = LayeredSettings::new();
    ls.user.set("editor.tabSize", serde_json::json!(4));
    ls.workspace.set("editor.tabSize", serde_json::json!(2));
    let cfg = ls.resolve_config(None);
    assert_eq!(cfg.indent_width, 2);
}

#[test]
fn test_settings_applied_to_editor() {
    let mut ed = Editor::from_str("x = 1");
    ed.settings.user.set("editor.tabSize", serde_json::json!(2));
    ed.settings
        .user
        .set("editor.insertSpaces", serde_json::json!(true));
    ed.settings.apply_to_config(&mut ed.config, None);
    assert_eq!(ed.config.indent_width, 2);
}

#[test]
fn test_settings_from_json() {
    let json =
        r#"{"editor.tabSize": 4, "editor.wordWrap": "on", "[python]": {"editor.tabSize": 4}}"#;
    let ls = LayeredSettings::from_json(json).unwrap();
    assert_eq!(ls.get("editor.tabSize").unwrap(), &serde_json::json!(4));
    assert!(ls.language_overrides.contains_key("python"));
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI API
// ═══════════════════════════════════════════════════════════════════════════════

fn extract_editor_context(ed: &Editor) -> waraq_core::ai::context::AiContext {
    waraq_core::ai::context::extract_context(
        &ed.buffer,
        ed.cursors.primary().pos,
        &ed.language,
        &ed.file_uri,
        &[],
        &waraq_core::ai::context::ContextWindow::tight(),
    )
}

#[test]
fn test_ai_no_completion_initially() {
    let ed = Editor::new();
    assert!(!ed.completion.suggestion_visible);
    assert!(ed.completion.active_suggestion.is_none());
}

#[test]
fn test_ai_extract_context() {
    let mut ed = Editor::from_str("fn main() {\n    let x = 42;\n}\n");
    ed.set_language("rust");
    ed.cursors.move_to(20, false);
    let ctx = extract_editor_context(&ed);
    assert!(!ctx.prefix.is_empty());
    assert_eq!(ctx.language, "rust");
}

#[test]
fn test_ai_build_explain_prompt() {
    let mut ed = Editor::from_str(
        "fn fib(n: u32) -> u32 {\n    if n < 2 { n } else { fib(n - 1) + fib(n - 2) }\n}\n",
    );
    ed.set_language("rust");
    ed.cursors.move_to(20, false);
    let ctx = extract_editor_context(&ed);
    let builder = waraq_core::ai::prompt::PromptBuilder::for_starcoder();
    let prompt = builder.build_explain_prompt(&ctx, &ed.buffer.to_string());
    assert!(!prompt.messages.as_ref().unwrap().is_empty());
    assert!(prompt.estimated_tokens > 0);
}

#[test]
fn test_ai_build_edit_prompt() {
    let mut ed = Editor::from_str("def foo(): pass");
    ed.set_language("python");
    let ctx = extract_editor_context(&ed);
    let builder = waraq_core::ai::prompt::PromptBuilder::for_starcoder();
    let prompt = builder.build_edit_prompt(&ctx, "add type hints");
    assert!(!prompt.messages.as_ref().unwrap().is_empty());
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIRTY TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_dirty_tracking_save_point() {
    let mut ed = Editor::from_str("hello");
    ed.undo_stack.mark_save_point();
    assert!(
        ed.undo_stack.is_at_saved_point(),
        "Should be at save point initially"
    );

    ed.apply(waraq_core::core::edit::EditOp::insert(5, " world"));
    assert!(
        !ed.undo_stack.is_at_saved_point(),
        "Should be dirty after edit"
    );

    ed.undo_stack.mark_save_point();
    assert!(
        ed.undo_stack.is_at_saved_point(),
        "Should be at save point after mark"
    );
}

#[test]
fn test_dirty_tracking_undo_to_clean() {
    let mut ed = Editor::from_str("hello");
    ed.undo_stack.mark_save_point();
    ed.apply(waraq_core::core::edit::EditOp::insert(5, " world"));
    assert!(!ed.undo_stack.is_at_saved_point());
    ed.undo();
    // After undo back to save point, should be clean
    assert!(
        ed.undo_stack.is_at_saved_point(),
        "Should be clean after undo to save point"
    );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_session_roundtrip() {
    let mut ed = Editor::from_str("fn main() {\n    let x = 42;\n}\n");
    ed.set_language("rust");
    ed.file_uri = "file:///test.rs".to_owned();
    ed.cursors.move_to(20, false);
    ed.viewport.set_height(30);

    let session = waraq_core::core::session::capture(&ed);
    let restored = waraq_core::core::session::restore(&session);

    assert_eq!(restored.language, "rust");
    assert_eq!(restored.file_uri, "file:///test.rs");
    assert_eq!(restored.cursors.primary().pos.0, 20);
    assert_eq!(restored.buffer.to_string(), ed.buffer.to_string());
}

#[test]
fn test_session_json_roundtrip_restores_editor() {
    let mut ed = Editor::from_str("let x = 1;");
    ed.set_language("javascript");
    let session = waraq_core::core::session::capture(&ed);
    let json = session.to_json();
    let s2 = waraq_core::core::session::Session::from_json(&json).unwrap();
    let ed2 = waraq_core::core::session::restore(&s2);
    assert_eq!(ed2.language, "javascript");
    assert_eq!(ed2.buffer.to_string(), "let x = 1;");
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORKSPACE
// ═══════════════════════════════════════════════════════════════════════════════

#[test]
fn test_workspace_basic_operations() {
    use waraq_core::core::workspace::Workspace;
    let mut ws = Workspace::new("file:///project");
    let tid1 = ws.open("file:///a.rs", "rust", "fn a() {}");
    let tid2 = ws.open("file:///b.py", "python", "def b(): pass");
    assert_eq!(ws.tab_count(), 2);
    assert!(ws.switch_to(tid1));
    assert_eq!(ws.active_file_uri(), Some("file:///a.rs"));
    let (closed, _dirty) = ws.close(tid2);
    assert!(closed);
    assert_eq!(ws.tab_count(), 1);
}

#[test]
fn test_workspace_find_in_files_prefix_query() {
    use waraq_core::core::search::SearchQuery;
    use waraq_core::core::workspace::Workspace;
    let mut ws = Workspace::new("file:///");
    ws.open("file:///a.rs", "rust", "fn main() { let x = 42; }");
    ws.open("file:///b.rs", "rust", "fn other() { let y = 1; }");
    let q = SearchQuery::literal("fn ");
    let r = ws.find_in_files(&q);
    assert_eq!(r.files_matched, 2, "Should find 'fn ' in both files");
    assert_eq!(r.total_matches, 2);
}

#[test]
fn test_workspace_dirty_tracking() {
    use waraq_core::core::edit::EditOp;
    use waraq_core::core::workspace::Workspace;
    let mut ws = Workspace::new("file:///");
    let tid = ws.open("file:///a.rs", "rust", "fn main() {}");
    assert_eq!(ws.dirty_count(), 0);
    if let Some(ed) = ws.editor_for_mut(tid) {
        ed.apply(EditOp::insert(12, "// change\n"));
    }
    ws.mark_dirty();
    assert_eq!(ws.dirty_count(), 1);
    ws.mark_clean(tid);
    assert_eq!(ws.dirty_count(), 0);
}
