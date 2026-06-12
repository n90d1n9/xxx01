// src/ffi/workspace_api.rs
//
// Workspace C API — multi-file workspace operations, session persistence,
// dirty tracking, and LSP → decoration pipeline.

use super::c_api::EditorHandle;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

// ═══════════════════════════════════════════════════════════════════════════════
// WORKSPACE
// ═══════════════════════════════════════════════════════════════════════════════

/// Workspace handle wrapping a Workspace + active editor.
pub struct WorkspaceHandle {
    pub inner: crate::core::workspace::Workspace,
}

/// Create a new workspace rooted at the given URI.
/// CALLER MUST call workspace_destroy.
#[no_mangle]
pub extern "C" fn workspace_create(root_uri: *const c_char) -> *mut WorkspaceHandle {
    let root = if root_uri.is_null() {
        "file:///".to_owned()
    } else {
        match unsafe { CStr::from_ptr(root_uri) }.to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => "file:///".to_owned(),
        }
    };
    let ws = crate::core::workspace::Workspace::new(&root);
    Box::into_raw(Box::new(WorkspaceHandle { inner: ws }))
}

/// Destroy a workspace.
#[no_mangle]
pub extern "C" fn workspace_destroy(handle: *mut WorkspaceHandle) {
    if !handle.is_null() {
        unsafe {
            drop(Box::from_raw(handle));
        }
    }
}

/// Open a file in the workspace.
/// Returns tab_id (>= 0) or -1 on error.
#[no_mangle]
pub extern "C" fn workspace_open(
    handle: *mut WorkspaceHandle,
    file_uri: *const c_char,
    language: *const c_char,
    content: *const c_char,
) -> c_int {
    if handle.is_null() || file_uri.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let uri = match unsafe { CStr::from_ptr(file_uri) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    let lang = if language.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(language) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    let text = if content.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(content) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    h.inner.open(uri, lang, text) as c_int
}

/// Open an untitled buffer.
#[no_mangle]
pub extern "C" fn workspace_open_untitled(
    handle: *mut WorkspaceHandle,
    language: *const c_char,
) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let lang = if language.is_null() {
        ""
    } else {
        match unsafe { CStr::from_ptr(language) }.to_str() {
            Ok(s) => s,
            Err(_) => "",
        }
    };
    h.inner.open_untitled(lang) as c_int
}

/// Close a tab by ID.
/// Returns JSON: {"closed": true, "was_dirty": false}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn workspace_close(handle: *mut WorkspaceHandle, tab_id: c_ulong) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let (closed, was_dirty) = h.inner.close(tab_id as usize);
    let json = serde_json::json!({"closed": closed, "was_dirty": was_dirty}).to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Switch to a tab by ID.
#[no_mangle]
pub extern "C" fn workspace_switch_to(handle: *mut WorkspaceHandle, tab_id: c_ulong) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &mut *handle }.inner.switch_to(tab_id as usize) {
        1
    } else {
        0
    }
}

/// Get active tab ID (-1 if no tabs).
#[no_mangle]
pub extern "C" fn workspace_active_tab_id(handle: *const WorkspaceHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    unsafe { &*handle }
        .inner
        .active_tab_id()
        .map(|id| id as c_int)
        .unwrap_or(-1)
}

/// Get total tab count.
#[no_mangle]
pub extern "C" fn workspace_tab_count(handle: *const WorkspaceHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.tab_count() as c_ulong
}

/// Get a snapshot of the active editor state as JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn workspace_active_editor_info(handle: *const WorkspaceHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    match h.inner.active_editor() {
        Some(ed) => {
            let lc = ed.buffer.offset_to_line_col(ed.cursors.primary().pos);
            let json = serde_json::json!({
                "file_uri":   ed.file_uri,
                "language":   ed.language,
                "byte_len":   ed.buffer.len_bytes(),
                "line_count": ed.buffer.len_lines(),
                "cursor_pos": ed.cursors.primary().pos.0,
                "cursor_line": lc.line,
                "cursor_col":  lc.col,
                "error_count":   ed.lsp_state.error_count(),
                "warning_count": ed.lsp_state.warning_count(),
            })
            .to_string();
            std::ffi::CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Get all open tabs as JSON.
/// JSON: [{"tab_id":0,"file_uri":"...","language":"...","dirty":false}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn workspace_tab_list(handle: *const WorkspaceHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let tabs: Vec<serde_json::Value> = h
        .inner
        .tab_list()
        .iter()
        .map(|t| {
            serde_json::json!({
                "tab_id":   t.tab_id,
                "file_uri": t.file_uri,
                "language": t.language,
                "dirty":    t.dirty,
            })
        })
        .collect();
    let json = serde_json::to_string(&tabs).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Find all occurrences of a search query across all files.
/// query_json: {"pattern":"...","case_sensitive":false,"whole_word":false,"regex":false}
/// Returns JSON array of matches: [{"file_uri":"...","line":0,"col":0,"text":"..."}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn workspace_find_in_files(
    handle: *const WorkspaceHandle,
    query_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || query_json.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let qstr = match unsafe { CStr::from_ptr(query_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let qval: serde_json::Value = serde_json::from_str(qstr).unwrap_or_default();
    let query = crate::core::search::SearchQuery {
        pattern: qval["pattern"].as_str().unwrap_or("").to_owned(),
        case_sensitive: qval["case_sensitive"].as_bool().unwrap_or(false),
        whole_word: qval["whole_word"].as_bool().unwrap_or(false),
        regex: qval["regex"].as_bool().unwrap_or(false),
        wrap_around: false,
    };
    let result = h.inner.find_in_files(&query);
    let json = serde_json::to_string(&result.matches).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Replace all matches in all files.
/// Returns count of replacements made.
#[no_mangle]
pub extern "C" fn workspace_replace_in_files(
    handle: *mut WorkspaceHandle,
    query_json: *const c_char,
    replacement: *const c_char,
) -> c_ulong {
    if handle.is_null() || query_json.is_null() || replacement.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let qstr = match unsafe { CStr::from_ptr(query_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let repl = match unsafe { CStr::from_ptr(replacement) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let qval: serde_json::Value = serde_json::from_str(qstr).unwrap_or_default();
    let query = crate::core::search::SearchQuery {
        pattern: qval["pattern"].as_str().unwrap_or("").to_owned(),
        case_sensitive: qval["case_sensitive"].as_bool().unwrap_or(false),
        whole_word: qval["whole_word"].as_bool().unwrap_or(false),
        regex: qval["regex"].as_bool().unwrap_or(false),
        wrap_around: false,
    };
    h.inner.replace_in_files(&query, repl) as c_ulong
}

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION
// ═══════════════════════════════════════════════════════════════════════════════

/// Capture the current editor state as a session JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_session_capture(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let session = crate::core::session::capture(&h.inner);
    let json = session.to_json_pretty();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Restore an editor from a session JSON.
/// Returns a new EditorHandle. CALLER MUST call editor_destroy.
#[no_mangle]
pub extern "C" fn editor_session_restore(session_json: *const c_char) -> *mut EditorHandle {
    if session_json.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { CStr::from_ptr(session_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match crate::core::session::Session::from_json(s) {
        Ok(session) => {
            let editor = crate::core::session::restore(&session);
            Box::into_raw(Box::new(EditorHandle { inner: editor }))
        }
        Err(_) => std::ptr::null_mut(),
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIRTY TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

/// Returns 1 if the editor has unsaved changes, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_is_dirty(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    // Dirty = undo stack has ops not yet saved
    if h.inner.undo_stack.depth() > 0 && !h.inner.undo_stack.is_at_saved_point() {
        1
    } else {
        0
    }
}

/// Mark the editor as clean (just saved).
#[no_mangle]
pub extern "C" fn editor_mark_clean(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.undo_stack.mark_save_point();
}

/// Get the depth of the undo stack (number of committed operations).
#[no_mangle]
pub extern "C" fn editor_undo_depth(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.undo_stack.depth() as c_ulong
}

// ═══════════════════════════════════════════════════════════════════════════════
// LSP → DECORATION PIPELINE
// ═══════════════════════════════════════════════════════════════════════════════

/// Apply LSP diagnostics as decorations.
/// diagnostics_json: JSON array of LSP Diagnostic objects (Monaco format):
///   [{"range":{"startLineNumber":1,"startColumn":5,...},"severity":1,"message":"...","source":"rustc"}]
/// Returns number of diagnostics applied.
#[no_mangle]
pub extern "C" fn editor_lsp_apply_diagnostics(
    handle: *mut EditorHandle,
    diagnostics_json: *const c_char,
) -> c_ulong {
    if handle.is_null() || diagnostics_json.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(diagnostics_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let diags: Vec<serde_json::Value> = serde_json::from_str(json).unwrap_or_default();

    // Remove existing diagnostic decorations
    h.inner
        .decorations
        .remove_by_kind(crate::core::decoration::DecorationKind::Diagnostic);

    // Build LspDiagnostic list for lsp_state
    let lsp_diags: Vec<crate::lsp::protocol::Diagnostic> = diags
        .iter()
        .filter_map(|d| {
            let sln = d["range"]["startLineNumber"].as_u64()? as u32;
            let sc = d["range"]["startColumn"].as_u64()? as u32;
            let eln = d["range"]["endLineNumber"].as_u64()? as u32;
            let ec = d["range"]["endColumn"].as_u64()? as u32;
            let sev = d["severity"].as_u64().unwrap_or(1) as u8;
            let msg = d["message"].as_str().unwrap_or("").to_owned();
            let src = d["source"].as_str().map(|s| s.to_owned());
            Some(crate::lsp::protocol::Diagnostic {
                range: crate::lsp::protocol::LspRange {
                    start: crate::lsp::protocol::LspPosition {
                        line: sln.saturating_sub(1),
                        character: sc.saturating_sub(1),
                    },
                    end: crate::lsp::protocol::LspPosition {
                        line: eln.saturating_sub(1),
                        character: ec.saturating_sub(1),
                    },
                },
                severity: match sev {
                    1 => crate::lsp::protocol::DiagnosticSeverity::Error,
                    2 => crate::lsp::protocol::DiagnosticSeverity::Warning,
                    3 => crate::lsp::protocol::DiagnosticSeverity::Information,
                    _ => crate::lsp::protocol::DiagnosticSeverity::Hint,
                },
                message: msg,
                source: src,
                code: None,
            })
        })
        .collect();

    let count = lsp_diags.len();
    h.inner.lsp_state.update_diagnostics(lsp_diags);

    // Add squiggle decorations
    let specs: Vec<(crate::DecorationSpec, String)> = diags
        .iter()
        .filter_map(|d| {
            let sln = d["range"]["startLineNumber"].as_u64()? as u32;
            let sc = d["range"]["startColumn"].as_u64()? as u32;
            let eln = d["range"]["endLineNumber"].as_u64()? as u32;
            let ec = d["range"]["endColumn"].as_u64()? as u32;
            let sev = d["severity"].as_u64().unwrap_or(1) as u8;

            let start = h
                .inner
                .buffer
                .line_col_to_offset(crate::core::types::LineCol::new(
                    (sln.saturating_sub(1)) as usize,
                    (sc.saturating_sub(1)) as usize,
                ));
            let end = h
                .inner
                .buffer
                .line_col_to_offset(crate::core::types::LineCol::new(
                    (eln.saturating_sub(1)) as usize,
                    (ec.saturating_sub(1)) as usize,
                ));
            if start.0 >= end.0 {
                return None;
            }

            let opts = match sev {
                1 => crate::DecorationOptions::error_squiggle(),
                2 => crate::DecorationOptions::warning_squiggle(),
                _ => crate::DecorationOptions::info_squiggle(),
            };
            Some((
                crate::DecorationSpec {
                    range: crate::core::types::Range::new(start.0, end.0),
                    options: opts,
                },
                "lsp-diagnostics".into(),
            ))
        })
        .collect();

    h.inner.decorations.delta(&[], &specs);
    count as c_ulong
}

/// Apply LSP hover result as a tooltip decoration.
/// hover_json: {"contents":{"kind":"markdown","value":"..."}} or just string
/// offset: byte offset where the hover was triggered.
#[no_mangle]
pub extern "C" fn editor_lsp_apply_hover(
    handle: *mut EditorHandle,
    hover_json: *const c_char,
    offset: c_ulong,
) {
    if handle.is_null() || hover_json.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(hover_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };
    let v: serde_json::Value = serde_json::from_str(json).unwrap_or_default();

    let text = v["contents"]["value"]
        .as_str()
        .or_else(|| v["contents"].as_str())
        .or_else(|| v.as_str())
        .unwrap_or("")
        .to_owned();

    if text.is_empty() {
        return;
    }

    // Remove old hover decoration
    h.inner.decorations.remove_by_owner("lsp-hover");

    let off = (offset as usize).min(h.inner.buffer.len_bytes());
    let word_range = h.inner.buffer.word_range_at(crate::ByteOffset(off));
    let range = if word_range.is_empty() {
        crate::core::types::Range::new(off, off + 1)
    } else {
        word_range
    };

    let mut opts = crate::DecorationOptions::default();
    opts.hover_message = Some(text);
    opts.kind = crate::DecorationKind::Custom;

    h.inner.decorations.delta(
        &[],
        &[(
            crate::DecorationSpec {
                range,
                options: opts,
            },
            "lsp-hover".into(),
        )],
    );
}

/// Clear LSP hover decoration.
#[no_mangle]
pub extern "C" fn editor_lsp_clear_hover(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .decorations
        .remove_by_owner("lsp-hover");
}

/// Apply LSP code actions for the current cursor position.
/// actions_json: JSON array of code action objects:
///   [{"title":"Fix import","kind":"quickfix","edit":{"changes":{"file:///a.rs":[...]}}}]
/// Returns the list as JSON for the host to present in a menu.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_lsp_code_actions(
    handle: *const EditorHandle,
    actions_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || actions_json.is_null() {
        return std::ptr::null_mut();
    }
    let json = match unsafe { CStr::from_ptr(actions_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    // Parse and re-serialize with cursor context added
    let actions: serde_json::Value = serde_json::from_str(json).unwrap_or_default();
    let h = unsafe { &*handle };
    let cursor_lc = h
        .inner
        .buffer
        .offset_to_line_col(h.inner.cursors.primary().pos);
    let enhanced = serde_json::json!({
        "actions": actions,
        "cursor": { "line": cursor_lc.line + 1, "col": cursor_lc.col + 1 },
        "count": actions.as_array().map(|a| a.len()).unwrap_or(0),
    });
    let out = enhanced.to_string();
    CString::new(out)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Execute a code action by applying its workspace edits to the current editor.
/// edit_json: LSP textEdit array or workspaceEdit:
///   {"changes":{"file:///a.rs":[{"range":{"start":{"line":0,"character":0},"end":{"line":0,"character":5}},"newText":"hello"}]}}
/// Returns number of edits applied.
#[no_mangle]
pub extern "C" fn editor_lsp_apply_edit(
    handle: *mut EditorHandle,
    edit_json: *const c_char,
) -> c_ulong {
    if handle.is_null() || edit_json.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(edit_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let v: serde_json::Value = serde_json::from_str(json).unwrap_or_default();

    // Try changes["file_uri"] first, then documentChanges
    let file_uri = h.inner.file_uri.clone();
    let edits_arr = v["changes"]
        .as_object()
        .and_then(|m| m.get(&file_uri))
        .and_then(|v| v.as_array())
        .cloned()
        .unwrap_or_default();

    if edits_arr.is_empty() {
        return 0;
    }

    let mono_edits: Vec<crate::SingleEditOperation> = edits_arr
        .iter()
        .filter_map(|e| {
            let sln = e["range"]["start"]["line"].as_u64()? as u32 + 1;
            let sc = e["range"]["start"]["character"].as_u64()? as u32 + 1;
            let eln = e["range"]["end"]["line"].as_u64()? as u32 + 1;
            let ec = e["range"]["end"]["character"].as_u64()? as u32 + 1;
            let new_text = e["newText"].as_str().map(|s| s.to_owned());
            Some(crate::SingleEditOperation {
                range: crate::MonacoRange::new(sln, sc, eln, ec),
                text: new_text,
                force_move_markers: false,
            })
        })
        .collect();

    h.inner.execute_edits(&mono_edits).len() as c_ulong
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
        let s = unsafe { CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        editor_free_str(ptr);
        s
    }

    // ── Workspace ─────────────────────────────────────────────────────────────

    #[test]
    fn test_workspace_create_destroy() {
        let root = CString::new("file:///project").unwrap();
        let h = workspace_create(root.as_ptr());
        assert!(!h.is_null());
        assert_eq!(workspace_tab_count(h), 0);
        workspace_destroy(h);
    }

    #[test]
    fn test_workspace_open_close() {
        let root = CString::new("file:///").unwrap();
        let h = workspace_create(root.as_ptr());
        let uri = CString::new("file:///a.rs").unwrap();
        let lang = CString::new("rust").unwrap();
        let cont = CString::new("fn main() {}").unwrap();
        let tid = workspace_open(h, uri.as_ptr(), lang.as_ptr(), cont.as_ptr());
        assert!(tid >= 0);
        assert_eq!(workspace_tab_count(h), 1);
        let close_ptr = workspace_close(h, tid as c_ulong);
        let close_json = get_str(close_ptr);
        let v: serde_json::Value = serde_json::from_str(&close_json).unwrap();
        assert_eq!(v["closed"], true);
        assert_eq!(workspace_tab_count(h), 0);
        workspace_destroy(h);
    }

    #[test]
    fn test_workspace_find_in_files() {
        let root = CString::new("file:///").unwrap();
        let h = workspace_create(root.as_ptr());
        let u1 = CString::new("file:///a.rs").unwrap();
        let l1 = CString::new("rust").unwrap();
        let c1 = CString::new("fn main() { let x = 42; }").unwrap();
        workspace_open(h, u1.as_ptr(), l1.as_ptr(), c1.as_ptr());
        let u2 = CString::new("file:///b.rs").unwrap();
        let c2 = CString::new("fn other() { let x = 1; }").unwrap();
        workspace_open(h, u2.as_ptr(), l1.as_ptr(), c2.as_ptr());
        let q = CString::new(r#"{"pattern":"fn ","case_sensitive":true}"#).unwrap();
        let ptr = workspace_find_in_files(h, q.as_ptr());
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(
            arr.as_array().unwrap().len() >= 2,
            "Should find 'fn ' in both files"
        );
        workspace_destroy(h);
    }

    #[test]
    fn test_workspace_tab_list() {
        let root = CString::new("file:///").unwrap();
        let h = workspace_create(root.as_ptr());
        let u = CString::new("file:///main.py").unwrap();
        let l = CString::new("python").unwrap();
        let c = CString::new("x = 1").unwrap();
        workspace_open(h, u.as_ptr(), l.as_ptr(), c.as_ptr());
        let ptr = workspace_tab_list(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(arr.as_array().unwrap().len(), 1);
        assert_eq!(arr[0]["language"], "python");
        workspace_destroy(h);
    }

    // ── Session ───────────────────────────────────────────────────────────────

    #[test]
    fn test_session_capture_restore() {
        let h = editor_create_with_content(
            CString::new("fn main() {\n    let x = 42;\n}")
                .unwrap()
                .as_ptr(),
        );
        crate::ffi::c_api::editor_cursor_move(h, 15, 0);
        let ptr = editor_session_capture(h);
        let session = get_str(ptr);
        assert!(!session.is_empty());
        let v: serde_json::Value = serde_json::from_str(&session).unwrap();
        assert!(v.get("cursors").is_some() || v.get("content").is_some());
        // Restore
        let sess_str = CString::new(session.clone()).unwrap();
        let h2 = editor_session_restore(sess_str.as_ptr());
        assert!(!h2.is_null());
        editor_destroy(h);
        editor_destroy(h2);
    }

    #[test]
    fn test_session_restore_invalid_json() {
        let bad = CString::new("not json").unwrap();
        let h = editor_session_restore(bad.as_ptr());
        assert!(h.is_null(), "Invalid JSON should return null");
    }

    // ── Dirty tracking ────────────────────────────────────────────────────────

    #[test]
    fn test_dirty_tracking() {
        let h = editor_create_with_content(CString::new("hello").unwrap().as_ptr());
        // After creation, not dirty (at save point)
        editor_mark_clean(h);
        assert_eq!(editor_is_dirty(h), 0);
        // After modification, dirty
        crate::ffi::c_api::editor_insert(h, 5, CString::new(" world").unwrap().as_ptr());
        assert_eq!(editor_is_dirty(h), 1);
        // Mark clean again
        editor_mark_clean(h);
        assert_eq!(editor_is_dirty(h), 0);
        editor_destroy(h);
    }

    // ── LSP diagnostics ───────────────────────────────────────────────────────

    #[test]
    fn test_lsp_apply_diagnostics() {
        let h =
            editor_create_with_content(CString::new("let x = undefined_var;").unwrap().as_ptr());
        let diag = CString::new(
            r#"[{
            "range":{"startLineNumber":1,"startColumn":9,"endLineNumber":1,"endColumn":22},
            "severity":1,
            "message":"undefined variable 'undefined_var'",
            "source":"rustc"
        }]"#,
        )
        .unwrap();
        let n = editor_lsp_apply_diagnostics(h, diag.as_ptr());
        assert_eq!(n, 1);
        let ptr = crate::ffi::decoration_api::editor_get_decorations(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(
            !arr.as_array().unwrap().is_empty(),
            "Diagnostic should create a decoration"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_lsp_apply_hover() {
        let h = editor_create_with_content(CString::new("fn main() {}").unwrap().as_ptr());
        let json = CString::new(r#"{"contents":{"kind":"markdown","value":"The main function"}}"#)
            .unwrap();
        editor_lsp_apply_hover(h, json.as_ptr(), 3);
        // Verify hover decoration was added
        let ptr = crate::ffi::decoration_api::editor_get_decorations(h);
        let decs = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&decs).unwrap();
        assert!(!arr.as_array().unwrap().is_empty());
        editor_lsp_clear_hover(h);
        editor_destroy(h);
    }

    #[test]
    fn test_lsp_clear_hover() {
        let h = editor_create_with_content(CString::new("fn main() {}").unwrap().as_ptr());
        let json = CString::new(r#"{"contents":{"value":"doc"}}"#).unwrap();
        editor_lsp_apply_hover(h, json.as_ptr(), 3);
        editor_lsp_clear_hover(h);
        let ptr = crate::ffi::decoration_api::editor_get_decorations(h);
        let decs = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&decs).unwrap();
        assert!(
            arr.as_array().unwrap().is_empty(),
            "Hover should be cleared"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_workspace_api() {
        // workspace_create(null) creates default workspace, not null
        let h = workspace_create(std::ptr::null_mut());
        assert!(!h.is_null(), "workspace_create with null uses default root");
        workspace_destroy(h);
        // These should not crash
        workspace_destroy(std::ptr::null_mut());
        assert_eq!(workspace_tab_count(std::ptr::null()), 0);
        assert!(editor_session_capture(std::ptr::null()).is_null());
        assert_eq!(editor_is_dirty(std::ptr::null()), 0);
        editor_mark_clean(std::ptr::null_mut());
    }
}
