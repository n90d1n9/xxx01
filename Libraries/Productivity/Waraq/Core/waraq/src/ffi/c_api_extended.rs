// src/ffi/c_api_extended.rs
//
// Extended C API — search, config, folding, motion, selection, completion.
// These complement the base 28 functions in c_api.rs.
//
// All functions follow the same conventions as c_api.rs:
//   • #[no_mangle] extern "C"
//   • Null-safe
//   • Panics caught via catch_unwind
//   • Returned strings freed with editor_free_str

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_uint, c_ulong};
use std::panic;

use super::c_api::EditorHandle;
use crate::core::search::SearchQuery;
use crate::core::types::ByteOffset;
use crate::{KeyInput, MotionKind};

// ── Search ────────────────────────────────────────────────────────────────────

/// Start a search session. Returns JSON with first match or null.
/// pattern: null-terminated UTF-8
/// flags:   0x01 = case_sensitive, 0x02 = whole_word, 0x04 = regex
/// Returns JSON: {"start":0,"end":3,"index":0,"total":5} or null on no match.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_search_start(
    handle: *mut EditorHandle,
    pattern: *const c_char,
    flags: c_uint,
) -> *mut c_char {
    if handle.is_null() || pattern.is_null() {
        return std::ptr::null_mut();
    }
    let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
        let h = unsafe { &mut *handle };
        let pat = match unsafe { CStr::from_ptr(pattern) }.to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return std::ptr::null_mut(),
        };
        let query = SearchQuery {
            pattern: pat,
            case_sensitive: flags & 0x01 != 0,
            whole_word: flags & 0x02 != 0,
            regex: flags & 0x04 != 0,
            wrap_around: true,
        };
        match h.inner.search_start(query) {
            Some(m) => {
                let json = serde_json::json!({
                    "start": m.start.0, "end": m.end.0,
                    "index": m.index,   "total": m.total,
                });
                CString::new(json.to_string())
                    .map(|cs| cs.into_raw())
                    .unwrap_or(std::ptr::null_mut())
            }
            None => std::ptr::null_mut(),
        }
    }));
    result.unwrap_or(std::ptr::null_mut())
}

/// Move to the next search match. Returns JSON match or null.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_search_next(handle: *mut EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    match h.inner.search_next() {
        Some(m) => {
            let json = serde_json::json!({
                "start": m.start.0, "end": m.end.0,
                "index": m.index,   "total": m.total,
            });
            CString::new(json.to_string())
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Move to the previous search match. Returns JSON match or null.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_search_prev(handle: *mut EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    match h.inner.search_prev() {
        Some(m) => {
            let json = serde_json::json!({
                "start": m.start.0, "end": m.end.0,
                "index": m.index,   "total": m.total,
            });
            CString::new(json.to_string())
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Replace the current search match with `replacement`. Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_replace_current(
    handle: *mut EditorHandle,
    replacement: *const c_char,
) -> c_int {
    if handle.is_null() || replacement.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let rep = match unsafe { CStr::from_ptr(replacement) }.to_str() {
        Ok(s) => s.to_owned(),
        Err(_) => return -1,
    };
    if h.inner.replace_current(&rep).is_some() {
        0
    } else {
        -1
    }
}

/// Replace all search matches with `replacement`.
/// Returns the number of replacements made.
#[no_mangle]
pub extern "C" fn editor_replace_all(
    handle: *mut EditorHandle,
    replacement: *const c_char,
) -> c_ulong {
    if handle.is_null() || replacement.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let rep = match unsafe { CStr::from_ptr(replacement) }.to_str() {
        Ok(s) => s.to_owned(),
        Err(_) => return 0,
    };
    h.inner.replace_all_matches(&rep).len() as c_ulong
}

/// Clear the current search session.
#[no_mangle]
pub extern "C" fn editor_search_clear(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.search_clear();
}

/// Get total number of matches for the active search.
/// Returns 0 if no search is active.
#[no_mangle]
pub extern "C" fn editor_search_match_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    h.inner
        .search
        .as_ref()
        .map(|s| s.match_count() as c_ulong)
        .unwrap_or(0)
}

// ── Configuration ─────────────────────────────────────────────────────────────

/// Get the current editor configuration as a JSON string.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_get_config(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let json = h.inner.config.to_json();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Set the editor configuration from a JSON string. Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_set_config(
    handle: *mut EditorHandle,
    config_json: *const c_char,
) -> c_int {
    if handle.is_null() || config_json.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(config_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match crate::Config::from_json(json) {
        Ok(cfg) => {
            h.inner.config = cfg;
            0
        }
        Err(_) => -1,
    }
}

/// Set a single config value by key. Returns 0 on success.
/// Supported keys: "tab_width", "indent_width", "indent_style" ("spaces"/"tabs"),
///   "line_ending" ("lf"/"crlf"), "auto_close_brackets" ("true"/"false"),
///   "ai_inline_completion" ("true"/"false"), "ai_debounce_ms" (number string)
#[no_mangle]
pub extern "C" fn editor_set_config_value(
    handle: *mut EditorHandle,
    key: *const c_char,
    value: *const c_char,
) -> c_int {
    if handle.is_null() || key.is_null() || value.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let k = match unsafe { CStr::from_ptr(key) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    let v = match unsafe { CStr::from_ptr(value) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };

    match k {
        "tab_width" => {
            if let Ok(n) = v.parse::<u32>() {
                h.inner.config.tab_width = n;
                0
            } else {
                -1
            }
        }
        "indent_width" => {
            if let Ok(n) = v.parse::<u32>() {
                h.inner.config.indent_width = n;
                0
            } else {
                -1
            }
        }
        "indent_style" => {
            h.inner.config.indent_style = match v {
                "tabs" => crate::IndentStyle::Tabs,
                "spaces" => crate::IndentStyle::Spaces,
                _ => return -1,
            };
            0
        }
        "line_ending" => {
            h.inner.config.line_ending = match v {
                "lf" => crate::LineEnding::Lf,
                "crlf" => crate::LineEnding::CrLf,
                "cr" => crate::LineEnding::Cr,
                _ => return -1,
            };
            0
        }
        "auto_close_brackets" => {
            h.inner.config.auto_close_brackets = v == "true";
            0
        }
        "ai_inline_completion" => {
            h.inner.config.ai_inline_completion = v == "true";
            0
        }
        "ai_debounce_ms" => {
            if let Ok(n) = v.parse::<u64>() {
                h.inner.config.ai_debounce_ms = n;
                0
            } else {
                -1
            }
        }
        _ => -1,
    }
}

// ── Folding ────────────────────────────────────────────────────────────────────

/// Toggle fold at `line`. Returns 1 if now collapsed, 0 if expanded.
#[no_mangle]
pub extern "C" fn editor_toggle_fold(handle: *mut EditorHandle, line: c_ulong) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    h.inner.toggle_fold(line as usize);
    if h.inner.folds.is_line_hidden(line as usize + 1) {
        1
    } else {
        0
    }
}

/// Collapse all folds.
#[no_mangle]
pub extern "C" fn editor_fold_all(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.fold_all();
}

/// Expand all folds.
#[no_mangle]
pub extern "C" fn editor_unfold_all(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.unfold_all();
}

/// Get all fold ranges as a JSON array.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_get_folds(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let json = serde_json::to_string(h.inner.folds.all()).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Diagnostics ───────────────────────────────────────────────────────────────

/// Set LSP diagnostics from a JSON array. Returns 0 on success.
/// JSON format: [{"range":{"start":{"line":0,"character":0},"end":{"line":0,"character":5}},
///                "severity":1,"message":"error text","source":"rustc"}]
#[no_mangle]
pub extern "C" fn editor_set_diagnostics(
    handle: *mut EditorHandle,
    diag_json: *const c_char,
) -> c_int {
    if handle.is_null() || diag_json.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(diag_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match serde_json::from_str::<Vec<crate::lsp::protocol::Diagnostic>>(json) {
        Ok(diags) => {
            let error_count = diags
                .iter()
                .filter(|d| d.severity == crate::lsp::protocol::DiagnosticSeverity::Error)
                .count();
            let warning_count = diags
                .iter()
                .filter(|d| d.severity == crate::lsp::protocol::DiagnosticSeverity::Warning)
                .count();
            crate::ffi::events::emit_diagnostics_updated(
                &h.inner.file_uri,
                error_count,
                warning_count,
            );
            h.inner.lsp_state.update_diagnostics(diags);
            0
        }
        Err(_) => -1,
    }
}

/// Get diagnostics for a specific line as a JSON array.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_get_diagnostics_at_line(
    handle: *const EditorHandle,
    line_num: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let diags = h.inner.lsp_state.diagnostics_at_line(line_num as usize);
    let json = serde_json::to_string(&diags).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get error count.
#[no_mangle]
pub extern "C" fn editor_error_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.lsp_state.error_count() as c_ulong
}

/// Get warning count.
#[no_mangle]
pub extern "C" fn editor_warning_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.lsp_state.warning_count() as c_ulong
}

// ── Motion ─────────────────────────────────────────────────────────────────────

/// Move cursor using a motion code. `extend` = 1 to extend selection.
/// Motion codes:
///   0=CharLeft  1=CharRight  2=WordLeft  3=WordRight  4=WordEnd
///   5=LineStart 6=LineFirstNonWs 7=LineEnd
///   8=LineUp(1) 9=LineDown(1)  10=ParagraphUp  11=ParagraphDown
///   12=PageUp(viewport_height)  13=PageDown(viewport_height)
///   14=MatchingBracket  15=DocumentStart  16=DocumentEnd
#[no_mangle]
pub extern "C" fn editor_motion(handle: *mut EditorHandle, code: c_uint, extend: c_int) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let height = h.inner.viewport.height();
    let motion = match code {
        0 => MotionKind::CharLeft,
        1 => MotionKind::CharRight,
        2 => MotionKind::WordLeft,
        3 => MotionKind::WordRight,
        4 => MotionKind::WordEnd,
        5 => MotionKind::LineStart,
        6 => MotionKind::LineFirstNonWs,
        7 => MotionKind::LineEnd,
        8 => MotionKind::LineUp(1),
        9 => MotionKind::LineDown(1),
        10 => MotionKind::ParagraphUp,
        11 => MotionKind::ParagraphDown,
        12 => MotionKind::PageUp(height),
        13 => MotionKind::PageDown(height),
        14 => MotionKind::MatchingBracket,
        15 => MotionKind::DocumentStart,
        16 => MotionKind::DocumentEnd,
        _ => return -1,
    };
    let key = if extend != 0 {
        KeyInput::Select(motion)
    } else {
        KeyInput::Motion(motion)
    };
    h.inner.handle_key(key);
    0
}

/// Move cursor up by `lines` lines, optionally extending selection.
#[no_mangle]
pub extern "C" fn editor_move_up(handle: *mut EditorHandle, lines: c_ulong, extend: c_int) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let key = if extend != 0 {
        KeyInput::Select(MotionKind::LineUp(lines as usize))
    } else {
        KeyInput::Motion(MotionKind::LineUp(lines as usize))
    };
    h.inner.handle_key(key);
}

/// Move cursor down by `lines` lines, optionally extending selection.
#[no_mangle]
pub extern "C" fn editor_move_down(handle: *mut EditorHandle, lines: c_ulong, extend: c_int) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let key = if extend != 0 {
        KeyInput::Select(MotionKind::LineDown(lines as usize))
    } else {
        KeyInput::Motion(MotionKind::LineDown(lines as usize))
    };
    h.inner.handle_key(key);
}

// ── Selection ─────────────────────────────────────────────────────────────────

/// Select the word at the current cursor position.
#[no_mangle]
pub extern "C" fn editor_select_word(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.select_word_at_cursor();
}

/// Select the entire current line.
#[no_mangle]
pub extern "C" fn editor_select_line(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.select_line_at_cursor();
}

/// Select all text in the document.
#[no_mangle]
pub extern "C" fn editor_select_all_text(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.select_all();
}

/// Expand selection to the next enclosing scope (VS Code alt+shift+right).
#[no_mangle]
pub extern "C" fn editor_expand_selection(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.expand_selection();
}

/// Add a cursor at the next occurrence of the selected text (Ctrl+D).
#[no_mangle]
pub extern "C" fn editor_add_cursor_next_occurrence(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .add_cursor_at_next_occurrence();
}

/// Get the selected text as a null-terminated UTF-8 string.
/// Returns empty string if no selection. CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_get_selection_text(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return CString::new("")
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut());
    }
    let h = unsafe { &*handle };
    let text = match h.inner.cursors.primary().selection() {
        Some(sel) => h.inner.buffer.text_in_range(sel.as_range()),
        None => String::new(),
    };
    CString::new(text)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Keyboard input ─────────────────────────────────────────────────────────────

/// Send a Unicode character to the editor (handles auto-pair, auto-indent).
/// Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_type_char(handle: *mut EditorHandle, codepoint: u32) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let ch = match char::from_u32(codepoint) {
        Some(c) => c,
        None => return -1,
    };
    let h = unsafe { &mut *handle };
    h.inner.handle_key(KeyInput::Char(ch));
    0
}

/// Send Backspace. Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_key_backspace(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &mut *handle }
        .inner
        .handle_key(KeyInput::Backspace);
    0
}

/// Send Delete (forward delete). Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_key_delete(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &mut *handle }.inner.handle_key(KeyInput::Delete);
    0
}

/// Send Enter (with auto-indent). Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_key_enter(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &mut *handle }.inner.handle_key(KeyInput::Enter);
    0
}

/// Send Tab (accepts AI completion if active, else inserts indent). Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_key_tab(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &mut *handle }.inner.handle_key(KeyInput::Tab);
    0
}

/// Send Shift+Tab (dedent). Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_key_shift_tab(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &mut *handle }.inner.handle_key(KeyInput::ShiftTab);
    0
}

// ── AI completion ──────────────────────────────────────────────────────────────

/// Check if an AI completion suggestion is currently visible.
/// Returns 1 if visible, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_has_completion(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &*handle }.inner.completion.suggestion_visible {
        1
    } else {
        0
    }
}

/// Get the current AI completion suggestion text.
/// Returns null if no suggestion is active.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_get_completion_text(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    match &h.inner.completion.active_suggestion {
        Some(s) => CString::new(s.text.clone())
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

/// Feed an AI completion response to the engine.
/// request_id must match the pending request.
/// generated_text: null-terminated UTF-8.
/// Returns 1 if the suggestion is now active, 0 if stale/empty.
#[no_mangle]
pub extern "C" fn editor_completion_response(
    handle: *mut EditorHandle,
    request_id: u64,
    generated_text: *const c_char,
    latency_ms: u64,
) -> c_int {
    if handle.is_null() || generated_text.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let text = match unsafe { CStr::from_ptr(generated_text) }.to_str() {
        Ok(s) => s.to_owned(),
        Err(_) => return 0,
    };
    let pos = h.inner.cursors.primary().pos;
    let lc = h.inner.buffer.offset_to_line_col(pos);
    let prefix = h.inner.buffer.line_str(lc.line)
        [..lc.col.min(h.inner.buffer.line_str(lc.line).len())]
        .to_owned();

    let response = crate::ai::CompletionResponse {
        request_id,
        generated_text: text,
        truncated: false,
        finish_reason: "stop".into(),
        latency_ms,
    };

    let lang = h.inner.language.clone();
    if h.inner
        .completion
        .on_response(response, &prefix, lc.col, &lang, pos.0)
        .is_some()
    {
        // Notify host that completion is ready
        crate::ffi::events::emit_completion_ready(
            request_id,
            &h.inner.completion.active_suggestion.as_ref().unwrap().text,
            pos.0,
            h.inner
                .completion
                .active_suggestion
                .as_ref()
                .unwrap()
                .is_multiline,
        );
        1
    } else {
        0
    }
}

/// Dismiss the current completion suggestion without accepting it.
#[no_mangle]
pub extern "C" fn editor_completion_dismiss(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .completion
        .dismiss_suggestion();
}

/// Get completion stats as a JSON object.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_completion_stats(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let stats = &h.inner.completion.stats;
    let json = serde_json::to_string(stats).unwrap_or_else(|_| "{}".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── File metadata ──────────────────────────────────────────────────────────────

/// Set the file URI for this editor (used in LSP and event notifications).
#[no_mangle]
pub extern "C" fn editor_set_file_uri(handle: *mut EditorHandle, file_uri: *const c_char) {
    if handle.is_null() || file_uri.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    if let Ok(uri) = unsafe { CStr::from_ptr(file_uri) }.to_str() {
        h.inner.file_uri = uri.to_owned();
    }
}

/// Get the file URI. CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_get_file_uri(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    CString::new(h.inner.file_uri.clone())
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get the current language. CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_get_language(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    CString::new(h.inner.language.clone())
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Bracket info ───────────────────────────────────────────────────────────────

/// Find the matching bracket for the character at `pos`.
/// Returns JSON {"open": offset, "close": offset} or null if no match.
/// CALLER MUST call editor_free_str on the return value.
#[no_mangle]
pub extern "C" fn editor_matching_bracket(
    handle: *const EditorHandle,
    pos: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    match crate::syntax::bracket::find_matching_bracket(
        &h.inner.buffer,
        ByteOffset(pos as usize),
        8192,
    ) {
        Some(m) => {
            let json = serde_json::json!({ "open": m.open.0, "close": m.close.0 });
            CString::new(json.to_string())
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Get rainbow bracket data for the viewport.
/// Returns a JSON array. CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_rainbow_brackets(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let first = h.inner.viewport.first_line();
    let last = first + h.inner.viewport.height();
    let brackets =
        crate::syntax::bracket::rainbow_brackets_for_viewport(&h.inner.buffer, first, last);
    let json = serde_json::to_string(&brackets).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi::c_api::{
        editor_create, editor_create_with_content, editor_destroy, editor_free_str,
    };
    use std::ffi::CString;

    #[test]
    fn test_search_start_and_next() {
        let content = CString::new("foo bar foo baz foo").unwrap();
        let h = editor_create_with_content(content.as_ptr());

        let pat = CString::new("foo").unwrap();
        let m_ptr = editor_search_start(h, pat.as_ptr(), 0x01); // case sensitive
        assert!(!m_ptr.is_null());
        let json = unsafe { std::ffi::CStr::from_ptr(m_ptr).to_str().unwrap().to_owned() };
        editor_free_str(m_ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["start"], 0);
        assert_eq!(v["total"], 3);

        let m2 = editor_search_next(h);
        let j2 = unsafe { std::ffi::CStr::from_ptr(m2).to_str().unwrap().to_owned() };
        editor_free_str(m2);
        let v2: serde_json::Value = serde_json::from_str(&j2).unwrap();
        assert_eq!(v2["start"], 8);

        assert_eq!(editor_search_match_count(h), 3);
        editor_search_clear(h);
        assert_eq!(editor_search_match_count(h), 0);

        editor_destroy(h);
    }

    #[test]
    fn test_replace_current() {
        let content = CString::new("foo bar foo").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let pat = CString::new("foo").unwrap();
        editor_search_start(h, pat.as_ptr(), 0x01);
        let rep = CString::new("qux").unwrap();
        assert_eq!(editor_replace_current(h, rep.as_ptr()), 0);

        let text_ptr = crate::ffi::c_api::editor_get_text(h);
        let text = unsafe {
            std::ffi::CStr::from_ptr(text_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(text_ptr);
        assert!(text.starts_with("qux"));
        editor_destroy(h);
    }

    #[test]
    fn test_replace_all_search() {
        let content = CString::new("foo bar foo baz foo").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let pat = CString::new("foo").unwrap();
        editor_search_start(h, pat.as_ptr(), 0x01);
        let rep = CString::new("X").unwrap();
        let count = editor_replace_all(h, rep.as_ptr());
        assert_eq!(count, 3);
        editor_destroy(h);
    }

    #[test]
    fn test_set_get_config() {
        let h = editor_create();
        let cfg_ptr = editor_get_config(h);
        assert!(!cfg_ptr.is_null());
        let cfg_json = unsafe {
            std::ffi::CStr::from_ptr(cfg_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(cfg_ptr);
        // Modify and re-set
        assert_eq!(
            editor_set_config(h, CString::new(&cfg_json as &str).unwrap().as_ptr()),
            0
        );
        editor_destroy(h);
    }

    #[test]
    fn test_set_config_value() {
        let h = editor_create();
        let k = CString::new("tab_width").unwrap();
        let v = CString::new("2").unwrap();
        assert_eq!(editor_set_config_value(h, k.as_ptr(), v.as_ptr()), 0);
        let cfg_ptr = editor_get_config(h);
        let cfg_json = unsafe {
            std::ffi::CStr::from_ptr(cfg_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(cfg_ptr);
        let val: serde_json::Value = serde_json::from_str(&cfg_json).unwrap();
        assert_eq!(val["tab_width"], 2);
        editor_destroy(h);
    }

    #[test]
    fn test_fold_toggle_and_count() {
        let src = CString::new("fn main() {\n    let x = 1;\n    let y = 2;\n}\n").unwrap();
        let h = editor_create_with_content(src.as_ptr());
        let lang = CString::new("rust").unwrap();
        crate::ffi::c_api::editor_set_language(h, lang.as_ptr());

        let folds_ptr = editor_get_folds(h);
        assert!(!folds_ptr.is_null());
        let folds_json = unsafe {
            std::ffi::CStr::from_ptr(folds_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(folds_ptr);
        let folds: serde_json::Value = serde_json::from_str(&folds_json).unwrap();
        assert!(folds.as_array().is_some());
        editor_destroy(h);
    }

    #[test]
    fn test_motion_char_left_right() {
        let content = CString::new("hello").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        crate::ffi::c_api::editor_cursor_move(h, 3, 0);
        editor_motion(h, 0, 0); // CharLeft
        assert_eq!(crate::ffi::c_api::editor_cursor_pos(h), 2);
        editor_motion(h, 1, 0); // CharRight
        assert_eq!(crate::ffi::c_api::editor_cursor_pos(h), 3);
        editor_destroy(h);
    }

    #[test]
    fn test_type_char_and_backspace() {
        let h = editor_create();
        editor_type_char(h, 'h' as u32);
        editor_type_char(h, 'i' as u32);
        assert_eq!(crate::ffi::c_api::editor_byte_len(h), 2);
        editor_key_backspace(h);
        assert_eq!(crate::ffi::c_api::editor_byte_len(h), 1);
        editor_destroy(h);
    }

    #[test]
    fn test_key_enter_with_indent() {
        let src = CString::new("fn main() {\n").unwrap();
        let h = editor_create_with_content(src.as_ptr());
        let lang = CString::new("rust").unwrap();
        crate::ffi::c_api::editor_set_language(h, lang.as_ptr());
        // Move cursor to end of first line (before \n would go to position 11)
        crate::ffi::c_api::editor_cursor_move(h, 11, 0);
        editor_key_enter(h);
        // After Enter on a line ending with {, next line should be indented
        let text_ptr = crate::ffi::c_api::editor_get_text(h);
        let text = unsafe {
            std::ffi::CStr::from_ptr(text_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(text_ptr);
        assert!(
            text.contains("\n    ") || text.contains("\n\t"),
            "Should have indent after enter: {:?}",
            text
        );
        editor_destroy(h);
    }

    #[test]
    fn test_select_word() {
        let content = CString::new("hello world").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        crate::ffi::c_api::editor_cursor_move(h, 7, 0); // inside "world"
        editor_select_word(h);
        let sel_ptr = editor_get_selection_text(h);
        let sel = unsafe {
            std::ffi::CStr::from_ptr(sel_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(sel_ptr);
        assert_eq!(sel, "world");
        editor_destroy(h);
    }

    #[test]
    fn test_select_all_text() {
        let content = CString::new("hello world").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        editor_select_all_text(h);
        let sel_ptr = editor_get_selection_text(h);
        let sel = unsafe {
            std::ffi::CStr::from_ptr(sel_ptr)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(sel_ptr);
        assert_eq!(sel, "hello world");
        editor_destroy(h);
    }

    #[test]
    fn test_matching_bracket() {
        let content = CString::new("fn foo(a, b) {}").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let m_ptr = editor_matching_bracket(h, 6); // '('
        assert!(!m_ptr.is_null());
        let json = unsafe { std::ffi::CStr::from_ptr(m_ptr).to_str().unwrap().to_owned() };
        editor_free_str(m_ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["open"], 6);
        assert!(v["close"].as_u64().unwrap() > 6);
        editor_destroy(h);
    }

    #[test]
    fn test_diagnostics() {
        let h = editor_create_with_content(CString::new("let x = undeclared;").unwrap().as_ptr());
        let diag_json = CString::new(r#"[{"range":{"start":{"line":0,"character":8},"end":{"line":0,"character":18}},"severity":1,"message":"cannot find value `undeclared`"}]"#).unwrap();
        assert_eq!(editor_set_diagnostics(h, diag_json.as_ptr()), 0);
        assert_eq!(editor_error_count(h), 1);
        assert_eq!(editor_warning_count(h), 0);
        let d_ptr = editor_get_diagnostics_at_line(h, 0);
        let d_json = unsafe { std::ffi::CStr::from_ptr(d_ptr).to_str().unwrap().to_owned() };
        editor_free_str(d_ptr);
        let arr: serde_json::Value = serde_json::from_str(&d_json).unwrap();
        assert!(arr.as_array().unwrap().len() >= 1);
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_extended() {
        assert_eq!(
            editor_search_start(std::ptr::null_mut(), std::ptr::null(), 0),
            std::ptr::null_mut()
        );
        assert_eq!(
            editor_replace_current(std::ptr::null_mut(), std::ptr::null()),
            -1
        );
        assert_eq!(
            editor_replace_all(std::ptr::null_mut(), std::ptr::null()),
            0
        );
        editor_search_clear(std::ptr::null_mut());
        assert_eq!(editor_get_config(std::ptr::null()), std::ptr::null_mut());
        assert_eq!(
            editor_set_config(std::ptr::null_mut(), std::ptr::null()),
            -1
        );
        editor_toggle_fold(std::ptr::null_mut(), 0);
        editor_fold_all(std::ptr::null_mut());
        assert_eq!(editor_type_char(std::ptr::null_mut(), 65), -1);
        assert_eq!(editor_key_backspace(std::ptr::null_mut()), -1);
        assert_eq!(editor_motion(std::ptr::null_mut(), 0, 0), -1);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════

/// Load user settings from JSON.
/// json: a JSON object with VS Code-style settings keys.
/// Returns 0 on success, -1 on parse error.
#[no_mangle]
pub extern "C" fn editor_settings_load_user(
    handle: *mut EditorHandle,
    json: *const c_char,
) -> c_int {
    if handle.is_null() || json.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let s = match unsafe { std::ffi::CStr::from_ptr(json) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match crate::core::settings::SettingsStore::from_json(s) {
        Ok(store) => {
            h.inner.settings.user = store;
            // Re-apply to current config
            h.inner.settings.apply_to_config(
                &mut h.inner.config,
                if h.inner.language.is_empty() {
                    None
                } else {
                    Some(&h.inner.language)
                },
            );
            0
        }
        Err(_) => -1,
    }
}

/// Load workspace settings from JSON (overrides user settings).
#[no_mangle]
pub extern "C" fn editor_settings_load_workspace(
    handle: *mut EditorHandle,
    json: *const c_char,
) -> c_int {
    if handle.is_null() || json.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let s = match unsafe { std::ffi::CStr::from_ptr(json) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match crate::core::settings::SettingsStore::from_json(s) {
        Ok(store) => {
            h.inner.settings.workspace = store;
            h.inner.settings.apply_to_config(
                &mut h.inner.config,
                if h.inner.language.is_empty() {
                    None
                } else {
                    Some(&h.inner.language)
                },
            );
            0
        }
        Err(_) => -1,
    }
}

/// Set a single setting value (JSON-encoded).
/// key: e.g. "editor.tabSize", value: e.g. "4"
#[no_mangle]
pub extern "C" fn editor_settings_set(
    handle: *mut EditorHandle,
    key: *const c_char,
    value: *const c_char,
) {
    if handle.is_null() || key.is_null() || value.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let k = match unsafe { std::ffi::CStr::from_ptr(key) }.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };
    let v = match unsafe { std::ffi::CStr::from_ptr(value) }.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };
    let json_val = serde_json::from_str(v).unwrap_or(serde_json::Value::String(v.to_owned()));
    h.inner.settings.user.set(k, json_val);
    h.inner.settings.apply_to_config(
        &mut h.inner.config,
        if h.inner.language.is_empty() {
            None
        } else {
            Some(&h.inner.language)
        },
    );
}

/// Get all effective settings as a JSON object.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_settings_get_all(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let json = h.inner.settings.to_json();
    std::ffi::CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDITOR GROUPS
// ═══════════════════════════════════════════════════════════════════════════════

/// Get the editor group layout as JSON.
/// This is a static representation; the editor_create doesn't hold a layout —
/// it's managed at the application level. This API provides layout serialisation helpers.
/// Returns JSON of a new default layout.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_group_layout_new() -> *mut c_char {
    let l = crate::core::editor_groups::EditorGroupLayout::new();
    let json = l.to_json();
    std::ffi::CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Parse a layout JSON and return it serialised (round-trip validation).
/// Returns null if invalid.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_group_layout_parse(json: *const c_char) -> *mut c_char {
    if json.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { std::ffi::CStr::from_ptr(json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match crate::core::editor_groups::EditorGroupLayout::from_json(s) {
        Ok(layout) => {
            let out = layout.to_json();
            std::ffi::CString::new(out)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        Err(_) => std::ptr::null_mut(),
    }
}
