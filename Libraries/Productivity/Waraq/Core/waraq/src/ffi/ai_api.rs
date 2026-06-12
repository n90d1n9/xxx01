// src/ffi/ai_api.rs
//
// AI agent C API — exposes the ai/agent.rs and ai/completion.rs functionality
// to the host platform (Flutter / Java / WASM).
//
// The host is responsible for:
//   1. Calling editor_ai_build_prompt() to get the prompt JSON
//   2. Sending it to the LLM (HTTP call, on-device model, etc.)
//   3. Passing the response back via editor_ai_apply_result()
//
// This keeps the core engine LLM-agnostic.

use super::c_api::EditorHandle;
use crate::ai::context::{extract_context, AiContext, ContextWindow};
use crate::syntax::Token;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

fn context_for_editor(editor: &crate::Editor) -> AiContext {
    let tokens: &[Token] = &[];
    extract_context(
        &editor.buffer,
        editor.cursors.primary().pos,
        &editor.language,
        &editor.file_uri,
        tokens,
        &ContextWindow::tight(),
    )
}

// ── Inline completion ─────────────────────────────────────────────────────────

/// Check whether an inline completion suggestion is available.
/// Returns 1 if a suggestion is ready, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_ai_has_completion(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    if h.inner.completion.suggestion_visible {
        1
    } else {
        0
    }
}

/// Get the current inline completion suggestion text.
/// Returns null if no suggestion is available.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_completion_text(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    match h.inner.completion.active_suggestion.as_ref() {
        Some(s) => CString::new(s.text.clone())
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

/// Accept the current inline completion suggestion.
/// Inserts it at the cursor position.
/// Returns 1 if accepted, 0 if no suggestion.
#[no_mangle]
pub extern "C" fn editor_ai_accept_completion(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    if let Some(op) = h.inner.completion.accept() {
        h.inner.apply(op);
        1
    } else {
        0
    }
}

/// Dismiss the current inline completion suggestion.
#[no_mangle]
pub extern "C" fn editor_ai_dismiss_completion(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }
        .inner
        .completion
        .dismiss_suggestion();
}

/// Notify the completion engine of a text change (triggers debounced re-request).
/// Returns JSON with the new completion request if one should be sent:
///   {"needs_request": true, "context": {"prefix":"...","suffix":"...","language":"..."}}
/// Returns {"needs_request": false} if no request needed yet.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_on_change(handle: *mut EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let cursor_pos = h.inner.cursors.primary().pos.0;
    let prefix = {
        let text = h.inner.buffer.to_string();
        text[..cursor_pos.min(text.len())].to_owned()
    };
    let lang = h.inner.language.clone();
    let lc = h
        .inner
        .buffer
        .offset_to_line_col(h.inner.cursors.primary().pos);
    let result = h
        .inner
        .completion
        .on_change(&prefix, lc.col, &lang, cursor_pos);
    let json = match result {
        Some(req) => serde_json::json!({
            "needs_request": true,
            "request_id": req.request_id,
            "prompt_len": req.prompt.len(),
        })
        .to_string(),
        None => serde_json::json!({"needs_request": false}).to_string(),
    };
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Apply an inline completion response from the LLM.
/// request_id: the ID from editor_ai_on_change
/// completion_text: the raw LLM response
/// Returns 1 if applied, 0 if stale/rejected.
#[no_mangle]
pub extern "C" fn editor_ai_apply_inline_completion(
    handle: *mut EditorHandle,
    request_id: c_ulong,
    completion_text: *const c_char,
) -> c_int {
    if handle.is_null() || completion_text.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let text = match unsafe { CStr::from_ptr(completion_text) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    // Check if this response is for our pending request
    if h.inner.completion.pending_request_id != Some(request_id as u64) {
        return 0;
    }
    let cursor_offset = h.inner.cursors.primary().pos.0;
    let prefix = {
        let text_so_far = h.inner.buffer.to_string();
        text_so_far[..cursor_offset.min(text_so_far.len())].to_owned()
    };
    let lang = h.inner.language.clone();
    let postprocessed = crate::ai::completion::postprocess_completion(text, &prefix, &lang, 6);
    let suggestion = crate::ai::completion::InlineSuggestion {
        text: postprocessed,
        insert_at: cursor_offset,
        confidence: 1.0,
        model: "ffi".into(),
        is_multiline: text.contains('\n'),
    };
    h.inner.completion.active_suggestion = Some(suggestion);
    h.inner.completion.suggestion_visible = true;
    h.inner.completion.pending_request_id = None;
    1
}

/// Get completion statistics as JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_completion_stats(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let json = serde_json::to_string(&h.inner.completion.stats).unwrap_or_default();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── AI agent prompts ──────────────────────────────────────────────────────────

/// Build an "explain code" prompt for the selected text (or whole file if no selection).
/// Returns JSON: {"prompt": [...messages...], "estimated_tokens": N, "task": "explain"}
/// The host sends this to the LLM. Pass the response to editor_ai_apply_result.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_build_explain_prompt(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };

    let selected = h
        .inner
        .cursors
        .primary()
        .selection()
        .map(|s| h.inner.buffer.text_in_range(s.as_range()))
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| h.inner.buffer.to_string());

    let ctx = context_for_editor(&h.inner);
    let builder = crate::ai::prompt::PromptBuilder::for_starcoder();
    let prompt = builder.build_explain_prompt(&ctx, &selected);

    let json = serde_json::json!({
        "task":             "explain",
        "messages":         prompt.messages,
        "estimated_tokens": prompt.estimated_tokens,
        "language":         h.inner.language,
    })
    .to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Build a "refactor / edit code" prompt.
/// instruction: natural language description of the change to make.
/// Returns JSON prompt object.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_build_edit_prompt(
    handle: *const EditorHandle,
    instruction: *const c_char,
) -> *mut c_char {
    if handle.is_null() || instruction.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let inst = match unsafe { CStr::from_ptr(instruction) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let ctx = context_for_editor(&h.inner);
    let builder = crate::ai::prompt::PromptBuilder::for_starcoder();
    let prompt = builder.build_edit_prompt(&ctx, inst);

    let json = serde_json::json!({
        "task":             "edit",
        "instruction":      inst,
        "messages":         prompt.messages,
        "estimated_tokens": prompt.estimated_tokens,
        "language":         h.inner.language,
    })
    .to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Build a "generate code" / FIM prompt at the cursor position.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_build_fim_prompt(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let ctx = context_for_editor(&h.inner);
    let builder = crate::ai::prompt::PromptBuilder::for_starcoder();
    let prompt = builder.build_inline_completion(&ctx);

    let json = serde_json::json!({
        "task":             "fim",
        "messages":         prompt.messages,
        "estimated_tokens": prompt.estimated_tokens,
        "language":         h.inner.language,
        "cursor_offset":    h.inner.cursors.primary().pos.0,
    })
    .to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Apply an LLM response to the editor (for explain, this is a no-op on the buffer;
/// for edit/generate it applies the diff).
/// task: "explain" | "edit" | "generate"
/// response_text: raw LLM response text
/// Returns JSON: {"applied": true, "ops": N} or {"applied": false, "error": "..."}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_apply_result(
    handle: *mut EditorHandle,
    task: *const c_char,
    response_text: *const c_char,
) -> *mut c_char {
    if handle.is_null() || task.is_null() || response_text.is_null() {
        let j = serde_json::json!({"applied": false, "error": "null argument"}).to_string();
        return CString::new(j)
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut());
    }
    let h = unsafe { &mut *handle };
    let task = match unsafe { CStr::from_ptr(task) }.to_str() {
        Ok(s) => s,
        Err(_) => return err_result("invalid task"),
    };
    let text = match unsafe { CStr::from_ptr(response_text) }.to_str() {
        Ok(s) => s,
        Err(_) => return err_result("invalid response"),
    };

    let json = match task {
        "explain" => {
            // Explain doesn't modify the buffer — just return the text
            serde_json::json!({"applied": true, "explanation": text, "ops": 0}).to_string()
        }
        "edit" | "generate" => {
            // Clean the response and apply as a diff
            let clean = crate::ai::agent::clean_code_response(text);
            if clean.is_empty() {
                serde_json::json!({"applied": false, "error": "empty response"}).to_string()
            } else {
                // Replace selected range or full file
                let (start, end) = if let Some(sel) = h.inner.cursors.primary().selection() {
                    (sel.start.0, sel.end.0)
                } else {
                    (0, h.inner.buffer.len_bytes())
                };
                h.inner
                    .apply(crate::core::edit::EditOp::replace(start, end, &clean));
                serde_json::json!({"applied": true, "ops": 1, "bytes_changed": clean.len()})
                    .to_string()
            }
        }
        "fim" => {
            let clean = crate::ai::agent::clean_code_response(text);
            if clean.is_empty() {
                serde_json::json!({"applied": false, "error": "empty response"}).to_string()
            } else {
                let pos = h.inner.cursors.primary().pos.0;
                h.inner
                    .apply(crate::core::edit::EditOp::insert(pos, &clean));
                serde_json::json!({"applied": true, "ops": 1, "inserted": clean.len()}).to_string()
            }
        }
        _ => err_result_str(&format!("unknown task: {}", task)),
    };
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

fn err_result(msg: &str) -> *mut c_char {
    let j = serde_json::json!({"applied": false, "error": msg}).to_string();
    CString::new(j)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

fn err_result_str(msg: &str) -> String {
    serde_json::json!({"applied": false, "error": msg}).to_string()
}

// ── Context extraction ────────────────────────────────────────────────────────

/// Extract the AI context (prefix, suffix, language) for the cursor position.
/// Useful for the host to build its own prompts.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ai_extract_context(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let ctx = context_for_editor(&h.inner);
    let json = serde_json::json!({
        "prefix":   ctx.prefix,
        "suffix":   ctx.suffix,
        "language": ctx.language,
        "file_uri": ctx.file_uri,
    })
    .to_string();
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

    fn get_str(ptr: *mut c_char) -> String {
        if ptr.is_null() {
            return String::new();
        }
        let s = unsafe { CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        editor_free_str(ptr);
        s
    }

    #[test]
    fn test_no_completion_initially() {
        let h = editor_create();
        assert_eq!(editor_ai_has_completion(h), 0);
        assert!(editor_ai_completion_text(h).is_null());
        editor_destroy(h);
    }

    #[test]
    fn test_dismiss_completion_noop_when_empty() {
        let h = editor_create();
        editor_ai_dismiss_completion(h); // should not panic
        editor_destroy(h);
    }

    #[test]
    fn test_ai_on_change_returns_json() {
        let h = editor_create_with_content(CString::new("def hello():").unwrap().as_ptr());
        let ptr = editor_ai_on_change(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(v.get("needs_request").is_some());
        editor_destroy(h);
    }

    #[test]
    fn test_build_explain_prompt() {
        let h = editor_create_with_content(
            CString::new("fn fib(n: u32) -> u32 { if n<2 {n} else {fib(n-1)+fib(n-2)} }")
                .unwrap()
                .as_ptr(),
        );
        let ptr = editor_ai_build_explain_prompt(h);
        let json = get_str(ptr);
        assert!(!json.is_empty());
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["task"], "explain");
        assert!(v["estimated_tokens"].as_u64().unwrap_or(0) > 0);
        editor_destroy(h);
    }

    #[test]
    fn test_build_edit_prompt() {
        let h = editor_create_with_content(CString::new("def foo(): pass").unwrap().as_ptr());
        let inst = CString::new("add a docstring").unwrap();
        let ptr = editor_ai_build_edit_prompt(h, inst.as_ptr());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["task"], "edit");
        assert_eq!(v["instruction"], "add a docstring");
        editor_destroy(h);
    }

    #[test]
    fn test_build_fim_prompt() {
        let h = editor_create_with_content(CString::new("def hello():\n    ").unwrap().as_ptr());
        let ptr = editor_ai_build_fim_prompt(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["task"], "fim");
        assert!(v["cursor_offset"].as_u64().is_some());
        editor_destroy(h);
    }

    #[test]
    fn test_apply_explain_result() {
        let h = editor_create_with_content(CString::new("x = 1").unwrap().as_ptr());
        let task = CString::new("explain").unwrap();
        let resp = CString::new("This assigns 1 to x.").unwrap();
        let ptr = editor_ai_apply_result(h, task.as_ptr(), resp.as_ptr());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["applied"], true);
        assert_eq!(v["explanation"], "This assigns 1 to x.");
        assert_eq!(v["ops"], 0); // explain doesn't modify buffer
        editor_destroy(h);
    }

    #[test]
    fn test_apply_edit_result() {
        let h = editor_create_with_content(CString::new("x = 1").unwrap().as_ptr());
        let task = CString::new("edit").unwrap();
        let resp = CString::new("y = 2\nz = 3\n").unwrap();
        let ptr = editor_ai_apply_result(h, task.as_ptr(), resp.as_ptr());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["applied"], true);
        assert_eq!(v["ops"], 1);
        editor_destroy(h);
    }

    #[test]
    fn test_apply_fim_result() {
        let h = editor_create_with_content(CString::new("def hello():\n    ").unwrap().as_ptr());
        // Move cursor to end
        crate::ffi::c_api::editor_cursor_move(h, 17, 0);
        let task = CString::new("fim").unwrap();
        let resp = CString::new("return 42").unwrap();
        let ptr = editor_ai_apply_result(h, task.as_ptr(), resp.as_ptr());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["applied"], true);
        editor_destroy(h);
    }

    #[test]
    fn test_apply_empty_response() {
        let h = editor_create();
        let task = CString::new("edit").unwrap();
        let resp = CString::new("").unwrap();
        let ptr = editor_ai_apply_result(h, task.as_ptr(), resp.as_ptr());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["applied"], false);
        editor_destroy(h);
    }

    #[test]
    fn test_ai_extract_context() {
        let h = editor_create_with_content(
            CString::new("fn main() {\n    let x = 42;\n}")
                .unwrap()
                .as_ptr(),
        );
        let ptr = editor_ai_extract_context(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(v["prefix"].is_string());
        assert!(v["suffix"].is_string());
        editor_destroy(h);
    }

    #[test]
    fn test_completion_stats() {
        let h = editor_create();
        let ptr = editor_ai_completion_stats(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        // Stats should be a valid JSON object
        assert!(v.is_object());
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_ai_api() {
        assert_eq!(editor_ai_has_completion(std::ptr::null()), 0);
        assert!(editor_ai_completion_text(std::ptr::null()).is_null());
        assert_eq!(editor_ai_accept_completion(std::ptr::null_mut()), 0);
        editor_ai_dismiss_completion(std::ptr::null_mut());
        assert!(editor_ai_on_change(std::ptr::null_mut()).is_null());
        assert!(editor_ai_build_explain_prompt(std::ptr::null()).is_null());
        assert!(editor_ai_extract_context(std::ptr::null()).is_null());
    }
}
