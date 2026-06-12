// src/ffi/advanced_api.rs
//
// Advanced editor features C API:
//   • Git gutter (diff decorations)
//   • Word wrap (virtual line mapping)
//   • Breadcrumbs / document outline
//   • Semantic token highlighting
//   • Inlay hints pipeline

use super::c_api::EditorHandle;
use crate::core::config::WordWrap;
use crate::core::git_gutter::GitGutter;
use crate::core::wordwrap::WrapEngine;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

// ═══════════════════════════════════════════════════════════════════════════════
// GIT GUTTER
// ═══════════════════════════════════════════════════════════════════════════════

/// Compute a git diff between HEAD content and the current buffer.
/// head_content: the file content at HEAD (from git show HEAD:<file>)
/// Returns JSON array of GutterHunk objects:
///   [{"kind":"Added|Modified|Deleted","start_line":0,"end_line":3,"deleted_count":0}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_git_diff(
    handle: *const EditorHandle,
    head_content: *const c_char,
) -> *mut c_char {
    if handle.is_null() || head_content.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let head = match unsafe { CStr::from_ptr(head_content) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let current = h.inner.buffer.to_string();
    let hunks = GitGutter::diff(head, &current);
    let json = GitGutter::hunks_to_json(&hunks);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Apply git diff decorations to the editor.
/// head_content: HEAD file content — computes diff and updates decorations.
/// Returns number of hunks applied.
#[no_mangle]
pub extern "C" fn editor_git_apply_decorations(
    handle: *mut EditorHandle,
    head_content: *const c_char,
) -> c_ulong {
    if handle.is_null() || head_content.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let head = match unsafe { CStr::from_ptr(head_content) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let current = h.inner.buffer.to_string();
    let hunks = GitGutter::diff(head, &current);
    let n = hunks.len();
    GitGutter::apply_to_decorations(&mut h.inner.decorations, &hunks, &h.inner.buffer);
    n as c_ulong
}

/// Clear all git gutter decorations.
#[no_mangle]
pub extern "C" fn editor_git_clear(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .decorations
        .remove_by_kind(crate::core::decoration::DecorationKind::Diff);
}

// ═══════════════════════════════════════════════════════════════════════════════
// WORD WRAP
// ═══════════════════════════════════════════════════════════════════════════════

/// Set word wrap mode.
/// mode: 0=Off, 1=On (at viewport width), 2=Column
/// col: column width (only used when mode=2)
#[no_mangle]
pub extern "C" fn editor_set_word_wrap(handle: *mut EditorHandle, mode: c_int, col: c_ulong) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let wrap_mode = match mode {
        0 => WordWrap::Off,
        1 => WordWrap::On,
        2 => WordWrap::Column(col as u32),
        _ => WordWrap::Off,
    };
    h.inner.config.word_wrap = wrap_mode.clone();
    // Also invalidate the wrap engine cache — future render will recompute
}

/// Get word wrap mode.
/// Returns: 0=Off, 1=On, 2=Column(N)
#[no_mangle]
pub extern "C" fn editor_get_word_wrap(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    match unsafe { &*handle }.inner.config.word_wrap {
        WordWrap::Off => 0,
        WordWrap::On => 1,
        WordWrap::Column(_) => 2,
    }
}

/// Set the viewport column width (used for word wrap calculations).
#[no_mangle]
pub extern "C" fn editor_set_viewport_cols(handle: *mut EditorHandle, cols: c_ulong) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    // Store in config for future wrap calculations
    h.inner.config.ruler_columns = vec![cols as u32];
}

/// Compute wrapped lines for a viewport range.
/// first_visual_line, last_visual_line: the visual line range to compute.
/// Returns JSON array of WrappedLine objects.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_wrapped_lines(
    handle: *mut EditorHandle,
    first_visual_line: c_ulong,
    last_visual_line: c_ulong,
    viewport_cols: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let mode = h.inner.config.word_wrap.clone();
    let mut engine = WrapEngine::new(mode);
    engine.set_viewport_cols(viewport_cols as usize);
    let lines = engine.visual_lines(
        &h.inner.buffer,
        first_visual_line as usize,
        last_visual_line as usize,
    );
    let json = serde_json::to_string(&lines).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get total visual line count given word wrap settings.
#[no_mangle]
pub extern "C" fn editor_visual_line_count(
    handle: *const EditorHandle,
    viewport_cols: c_ulong,
) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    let mode = h.inner.config.word_wrap.clone();
    let mut engine = WrapEngine::new(mode);
    engine.set_viewport_cols(viewport_cols as usize);
    engine.total_visual_lines(&h.inner.buffer) as c_ulong
}

/// Convert a logical line to its first visual line.
#[no_mangle]
pub extern "C" fn editor_logical_to_visual_line(
    handle: *const EditorHandle,
    logical_line: c_ulong,
    viewport_cols: c_ulong,
) -> c_ulong {
    if handle.is_null() {
        return logical_line;
    }
    let h = unsafe { &*handle };
    let mode = h.inner.config.word_wrap.clone();
    let mut engine = WrapEngine::new(mode);
    engine.set_viewport_cols(viewport_cols as usize);
    engine.logical_to_visual_line(logical_line as usize, &h.inner.buffer) as c_ulong
}

/// Convert a visual line to its logical line.
/// Returns JSON: {"logical_line": N, "wrap_index": M}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_visual_to_logical_line(
    handle: *const EditorHandle,
    visual_line: c_ulong,
    viewport_cols: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let mode = h.inner.config.word_wrap.clone();
    let mut engine = WrapEngine::new(mode);
    engine.set_viewport_cols(viewport_cols as usize);
    let (logical, wrap_idx) = engine.visual_to_logical_line(visual_line as usize, &h.inner.buffer);
    let json = serde_json::json!({ "logical_line": logical, "wrap_index": wrap_idx }).to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ═══════════════════════════════════════════════════════════════════════════════
// BREADCRUMBS / DOCUMENT OUTLINE
// ═══════════════════════════════════════════════════════════════════════════════

/// Get document outline (breadcrumbs) as JSON.
/// Calls registered DocumentSymbolProvider for the current language.
/// Returns JSON array of DocumentSymbol objects.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_document_outline(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let req = crate::ext::providers::DocumentSymbolRequest {
        file_uri: h.inner.file_uri.clone(),
        content: h.inner.buffer.to_string(),
        language: h.inner.language.clone(),
    };
    let symbols = h.inner.lang_features.document_symbols(req);
    let json = serde_json::to_string(&symbols).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get breadcrumb path for the cursor position.
/// Walks the symbol tree to find which symbol(s) the cursor is inside.
/// Returns JSON array of {name, kind} from outermost to innermost.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_breadcrumbs(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let req = crate::ext::providers::DocumentSymbolRequest {
        file_uri: h.inner.file_uri.clone(),
        content: h.inner.buffer.to_string(),
        language: h.inner.language.clone(),
    };
    let all_symbols = h.inner.lang_features.document_symbols(req);
    let cursor_lc = h
        .inner
        .buffer
        .offset_to_line_col(h.inner.cursors.primary().pos);
    let cursor_pos = crate::ext::providers::Position::new(
        (cursor_lc.line + 1) as u32,
        (cursor_lc.col + 1) as u32,
    );

    // Walk symbols to find which ones contain the cursor
    fn find_path(
        symbols: &[crate::ext::providers::DocumentSymbol],
        pos: crate::ext::providers::Position,
    ) -> Vec<serde_json::Value> {
        for sym in symbols {
            if sym.range.start.line <= pos.line && sym.range.end.line >= pos.line {
                let mut path = vec![serde_json::json!({
                    "name": sym.name,
                    "kind": format!("{:?}", sym.kind),
                    "detail": sym.detail,
                })];
                let child_path = find_path(&sym.children, pos);
                path.extend(child_path);
                return path;
            }
        }
        vec![]
    }

    let path = find_path(&all_symbols, cursor_pos);
    let json = serde_json::to_string(&path).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEMANTIC TOKENS
// ═══════════════════════════════════════════════════════════════════════════════

/// Apply semantic tokens from an LSP `textDocument/semanticTokens/full` response.
/// tokens_json: the encoded token data from the LSP server (array of integers).
/// legend_json: the token types and modifiers legend from the server.
/// Creates decorations for each semantic token range.
/// Returns number of tokens applied.
#[no_mangle]
pub extern "C" fn editor_apply_semantic_tokens(
    handle: *mut EditorHandle,
    tokens_json: *const c_char,
    legend_json: *const c_char,
) -> c_ulong {
    if handle.is_null() || tokens_json.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let data_str = match unsafe { CStr::from_ptr(tokens_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let legend_str = if legend_json.is_null() {
        "[]"
    } else {
        match unsafe { CStr::from_ptr(legend_json) }.to_str() {
            Ok(s) => s,
            Err(_) => "[]",
        }
    };

    // Parse the encoded token data (groups of 5: deltaLine, deltaStart, length, tokenType, modifiers)
    let data: Vec<u32> = match serde_json::from_str(data_str) {
        Ok(v) => v,
        Err(_) => return 0,
    };
    let legend: Vec<String> = serde_json::from_str(legend_str).unwrap_or_default();

    // Remove old semantic decorations
    h.inner
        .decorations
        .remove_by_kind(crate::core::decoration::DecorationKind::Custom);

    // Decode delta-encoded token stream
    let mut specs: Vec<(crate::DecorationSpec, String)> = Vec::new();
    let mut abs_line = 0u32;
    let mut abs_start = 0u32;

    let chunks = data.chunks_exact(5);
    let _count = chunks.len();
    for chunk in chunks {
        let delta_line = chunk[0];
        let delta_start = chunk[1];
        let length = chunk[2];
        let token_type = chunk[3] as usize;
        let _modifiers = chunk[4];

        if delta_line > 0 {
            abs_line += delta_line;
            abs_start = delta_start;
        } else {
            abs_start += delta_start;
        }

        let line = abs_line as usize;
        let col = abs_start as usize;
        let end_col = col + length as usize;

        if line >= h.inner.buffer.len_lines() {
            continue;
        }

        let start_offset = h
            .inner
            .buffer
            .line_col_to_offset(crate::core::types::LineCol::new(line, col));
        let end_offset = h
            .inner
            .buffer
            .line_col_to_offset(crate::core::types::LineCol::new(
                line,
                end_col.min(h.inner.buffer.line_len_chars(line)),
            ));

        if start_offset.0 >= end_offset.0 {
            continue;
        }

        // Map token type to our TokenKind for colouring
        let token_name = legend
            .get(token_type)
            .map(|s| s.as_str())
            .unwrap_or("variable");
        let style = semantic_token_to_style(token_name);
        let mut opts = crate::DecorationOptions::default();
        opts.inline_style = Some(style);
        opts.kind = crate::DecorationKind::Custom;
        opts.z_index = 1; // semantic tokens render above syntax highlighting

        specs.push((
            crate::DecorationSpec {
                range: crate::core::types::Range::new(start_offset.0, end_offset.0),
                options: opts,
            },
            "semantic-tokens".into(),
        ));
    }

    let applied = specs.len();
    h.inner.decorations.delta(&[], &specs);
    applied as c_ulong
}

fn semantic_token_to_style(token_type: &str) -> crate::DecorationStyle {
    use crate::core::decoration::DecorationStyle;
    let color = match token_type {
        "namespace" | "module" => "var(--semantic-namespace)",
        "class" | "struct" | "interface" | "enum" | "typeParameter" => "var(--semantic-type)",
        "function" | "method" | "macro" => "var(--semantic-function)",
        "variable" | "parameter" => "var(--semantic-variable)",
        "property" => "var(--semantic-property)",
        "keyword" | "modifier" => "var(--semantic-keyword)",
        "string" => "var(--semantic-string)",
        "number" => "var(--semantic-number)",
        "comment" => "var(--semantic-comment)",
        "decorator" => "var(--semantic-decorator)",
        "operator" => "var(--semantic-operator)",
        _ => return DecorationStyle::default(),
    };
    DecorationStyle {
        foreground_color: Some(color.to_owned()),
        ..Default::default()
    }
}

/// Clear all semantic token decorations.
#[no_mangle]
pub extern "C" fn editor_clear_semantic_tokens(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    // Remove semantic token decorations by owner
    unsafe { &mut *handle }
        .inner
        .decorations
        .remove_by_owner("semantic-tokens");
}

// ═══════════════════════════════════════════════════════════════════════════════
// INLAY HINTS
// ═══════════════════════════════════════════════════════════════════════════════

/// Set inlay hints from an LSP `textDocument/inlayHint` response.
/// hints_json: JSON array of InlayHint objects from the LSP.
/// Returns number of hints applied.
#[no_mangle]
pub extern "C" fn editor_set_inlay_hints(
    handle: *mut EditorHandle,
    hints_json: *const c_char,
) -> c_ulong {
    if handle.is_null() || hints_json.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(hints_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let hints: Vec<crate::ext::providers::InlayHint> = match serde_json::from_str(json) {
        Ok(v) => v,
        Err(_) => return 0,
    };

    // Remove existing inlay hint decorations
    h.inner
        .decorations
        .remove_by_kind(crate::core::decoration::DecorationKind::InlayHint);

    let count = hints.len();
    let specs: Vec<(crate::DecorationSpec, String)> = hints
        .into_iter()
        .filter_map(|hint| {
            let line = hint.position.line as usize;
            let col = hint.position.column as usize;
            if line == 0 && col == 0 {
                return None;
            }
            let offset = h
                .inner
                .buffer
                .line_col_to_offset(crate::core::types::LineCol::new(
                    line.saturating_sub(1), // Monaco is 1-based
                    col.saturating_sub(1),
                ));

            let label_text = match &hint.label {
                crate::ext::providers::InlayHintLabel::String(s) => s.clone(),
                crate::ext::providers::InlayHintLabel::Parts(parts) => parts
                    .iter()
                    .map(|p| p.value.as_str())
                    .collect::<Vec<_>>()
                    .join(""),
            };

            let mut opts = crate::DecorationOptions::default();
            opts.kind = crate::core::decoration::DecorationKind::InlayHint;
            opts.before_content_text = Some(label_text.clone());
            opts.before_content_color = Some("var(--inlay-hint-color)".into());
            opts.hover_message = hint.tooltip.clone();
            opts.z_index = 10;

            Some((
                crate::DecorationSpec {
                    range: crate::core::types::Range::new(offset.0, offset.0),
                    options: opts,
                },
                "inlay-hints".into(),
            ))
        })
        .collect();

    h.inner.decorations.delta(&[], &specs);
    count as c_ulong
}

/// Clear all inlay hint decorations.
#[no_mangle]
pub extern "C" fn editor_clear_inlay_hints(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .decorations
        .remove_by_owner("inlay-hints");
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENT HIGHLIGHT (current word)
// ═══════════════════════════════════════════════════════════════════════════════

/// Highlight all occurrences of the word at the cursor.
/// Calls DocumentHighlightProvider if registered, otherwise finds literal matches.
/// Returns number of highlights added.
#[no_mangle]
pub extern "C" fn editor_highlight_word_at_cursor(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };

    // Remove existing word highlights
    h.inner
        .decorations
        .remove_by_kind(crate::core::decoration::DecorationKind::Highlight);

    let cursor = h.inner.cursors.primary().pos;
    let word_range = h.inner.buffer.word_range_at(cursor);
    if word_range.is_empty() {
        return 0;
    }

    let word = h.inner.buffer.text_in_range(word_range);
    if word.trim().is_empty() {
        return 0;
    }

    // Try DocumentHighlightProvider first
    let cursor_lc = h.inner.buffer.offset_to_line_col(cursor);
    let req = crate::ext::providers::DocumentHighlightRequest {
        file_uri: h.inner.file_uri.clone(),
        content: h.inner.buffer.to_string(),
        language: h.inner.language.clone(),
        position: crate::ext::providers::Position::new(
            (cursor_lc.line + 1) as u32,
            (cursor_lc.col + 1) as u32,
        ),
    };
    let provider_highlights = h.inner.lang_features.document_highlights(req);

    let specs: Vec<(crate::DecorationSpec, String)> = if !provider_highlights.is_empty() {
        provider_highlights
            .into_iter()
            .map(|hl| {
                let start_offset =
                    h.inner
                        .buffer
                        .line_col_to_offset(crate::core::types::LineCol::new(
                            (hl.range.start.line.saturating_sub(1)) as usize,
                            (hl.range.start.column.saturating_sub(1)) as usize,
                        ));
                let end_offset =
                    h.inner
                        .buffer
                        .line_col_to_offset(crate::core::types::LineCol::new(
                            (hl.range.end.line.saturating_sub(1)) as usize,
                            (hl.range.end.column.saturating_sub(1)) as usize,
                        ));
                let mut opts = crate::DecorationOptions::current_word_highlight();
                opts.kind = crate::core::decoration::DecorationKind::Highlight;
                (
                    crate::DecorationSpec {
                        range: crate::core::types::Range::new(start_offset.0, end_offset.0),
                        options: opts,
                    },
                    "word-highlight".into(),
                )
            })
            .collect()
    } else {
        // Fallback: find all literal occurrences
        h.inner
            .buffer
            .find_all(&word)
            .into_iter()
            .map(|start| {
                let end = start.0 + word.len();
                let opts = crate::DecorationOptions::current_word_highlight();
                (
                    crate::DecorationSpec {
                        range: crate::core::types::Range::new(start.0, end),
                        options: opts,
                    },
                    "word-highlight".into(),
                )
            })
            .collect()
    };

    let count = specs.len();
    h.inner.decorations.delta(&[], &specs);
    count as c_ulong
}

/// Clear word highlights.
#[no_mangle]
pub extern "C" fn editor_clear_word_highlights(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .decorations
        .remove_by_owner("word-highlight");
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi::c_api::{editor_create_with_content, editor_destroy, editor_free_str};
    use std::ffi::CString;

    fn get_str(ptr: *mut c_char) -> String {
        if ptr.is_null() {
            return String::new();
        }
        let s = unsafe { std::ffi::CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        editor_free_str(ptr);
        s
    }

    // ── Git gutter ────────────────────────────────────────────────────────────

    #[test]
    fn test_git_diff_added_lines() {
        let h = editor_create_with_content(CString::new("line1\nline2\nline3\n").unwrap().as_ptr());
        let head = CString::new("line1\nline3\n").unwrap();
        let ptr = editor_git_diff(h, head.as_ptr());
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        let hunks = arr.as_array().unwrap();
        assert!(!hunks.is_empty(), "Should find changed lines");
        editor_destroy(h);
    }

    #[test]
    fn test_git_diff_no_changes() {
        let content = "line1\nline2\nline3\n";
        let h = editor_create_with_content(CString::new(content).unwrap().as_ptr());
        let head = CString::new(content).unwrap();
        let ptr = editor_git_diff(h, head.as_ptr());
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(arr.as_array().unwrap().len(), 0);
        editor_destroy(h);
    }

    #[test]
    fn test_git_apply_decorations() {
        let h = editor_create_with_content(CString::new("new line\noriginal\n").unwrap().as_ptr());
        let head = CString::new("original\n").unwrap();
        let n = editor_git_apply_decorations(h, head.as_ptr());
        assert_eq!(n, 1, "Should apply one inserted-line hunk");
        editor_destroy(h);
    }

    #[test]
    fn test_git_clear() {
        let h = editor_create_with_content(CString::new("a\nb\n").unwrap().as_ptr());
        let head = CString::new("a\n").unwrap();
        editor_git_apply_decorations(h, head.as_ptr());
        editor_git_clear(h);
        // Decorations should be cleared
        let ptr = crate::ffi::decoration_api::editor_get_decorations(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(arr.as_array().unwrap().is_empty());
        editor_destroy(h);
    }

    // ── Word wrap ─────────────────────────────────────────────────────────────

    #[test]
    fn test_set_get_word_wrap() {
        let h = editor_create_with_content(CString::new("test").unwrap().as_ptr());
        editor_set_word_wrap(h, 0, 0); // Off
        assert_eq!(editor_get_word_wrap(h), 0);
        editor_set_word_wrap(h, 1, 0); // On
        assert_eq!(editor_get_word_wrap(h), 1);
        editor_set_word_wrap(h, 2, 80); // Column(80)
        assert_eq!(editor_get_word_wrap(h), 2);
        editor_destroy(h);
    }

    #[test]
    fn test_visual_line_count_no_wrap() {
        let h = editor_create_with_content(CString::new("line1\nline2\nline3\n").unwrap().as_ptr());
        editor_set_word_wrap(h, 0, 0); // Off
        let count = editor_visual_line_count(h, 80);
        assert_eq!(count, 4); // 3 lines + trailing empty
        editor_destroy(h);
    }

    #[test]
    fn test_visual_line_count_with_wrap() {
        let long_content = "a".repeat(200); // line longer than 80 chars
        let h = editor_create_with_content(CString::new(long_content).unwrap().as_ptr());
        editor_set_word_wrap(h, 2, 80); // Column(80)
        let count = editor_visual_line_count(h, 80);
        assert!(count >= 2, "Long line should produce multiple visual lines");
        editor_destroy(h);
    }

    #[test]
    fn test_wrapped_lines_structure() {
        let h = editor_create_with_content(CString::new("hello world foo bar\n").unwrap().as_ptr());
        editor_set_word_wrap(h, 2, 10);
        let ptr = editor_wrapped_lines(h, 0, 5, 10);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(!arr.as_array().unwrap().is_empty());
        editor_destroy(h);
    }

    #[test]
    fn test_logical_visual_line_conversion() {
        let h = editor_create_with_content(CString::new("line1\nline2\nline3\n").unwrap().as_ptr());
        editor_set_word_wrap(h, 0, 0);
        // No wrap: identity mapping
        assert_eq!(editor_logical_to_visual_line(h, 0, 80), 0);
        assert_eq!(editor_logical_to_visual_line(h, 2, 80), 2);
        editor_destroy(h);
    }

    #[test]
    fn test_visual_to_logical_json() {
        let h = editor_create_with_content(CString::new("line1\nline2\n").unwrap().as_ptr());
        editor_set_word_wrap(h, 0, 0);
        let ptr = editor_visual_to_logical_line(h, 1, 80);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["logical_line"], 1);
        assert_eq!(v["wrap_index"], 0);
        editor_destroy(h);
    }

    // ── Document highlight ────────────────────────────────────────────────────

    #[test]
    fn test_highlight_word_at_cursor() {
        let h = editor_create_with_content(CString::new("foo bar foo baz foo").unwrap().as_ptr());
        // Cursor on first "foo"
        crate::ffi::c_api::editor_cursor_move(h, 1, 0); // pos 1, inside "foo"
        let n = editor_highlight_word_at_cursor(h);
        assert_eq!(n, 3, "Should find all 3 occurrences of 'foo'");
        editor_destroy(h);
    }

    #[test]
    fn test_clear_word_highlights() {
        let h = editor_create_with_content(CString::new("foo bar foo").unwrap().as_ptr());
        editor_highlight_word_at_cursor(h);
        editor_clear_word_highlights(h);
        let ptr = crate::ffi::decoration_api::editor_get_decorations(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(arr.as_array().unwrap().is_empty());
        editor_destroy(h);
    }

    // ── Null safety ───────────────────────────────────────────────────────────

    #[test]
    fn test_null_safety_advanced_api() {
        assert!(editor_git_diff(std::ptr::null(), std::ptr::null()).is_null());
        assert_eq!(
            editor_git_apply_decorations(std::ptr::null_mut(), std::ptr::null()),
            0
        );
        assert_eq!(editor_get_word_wrap(std::ptr::null()), 0);
        assert_eq!(editor_visual_line_count(std::ptr::null(), 80), 0);
        assert!(editor_wrapped_lines(std::ptr::null_mut(), 0, 10, 80).is_null());
        assert!(editor_document_outline(std::ptr::null()).is_null());
        assert_eq!(editor_highlight_word_at_cursor(std::ptr::null_mut()), 0);
        assert_eq!(
            editor_set_inlay_hints(std::ptr::null_mut(), std::ptr::null()),
            0
        );
    }
}
