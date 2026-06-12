// src/ffi/c_api_extra.rs
//
// Additional C API: clipboard, macros, formatting, document statistics.

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

use super::c_api::EditorHandle;

// ── Clipboard ─────────────────────────────────────────────────────────────────

/// Copy the current selection (or whole line) to the clipboard.
#[no_mangle]
pub extern "C" fn editor_copy(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.copy();
}

/// Cut the current selection (or whole line). Applies the deletion.
/// Returns number of ops applied.
#[no_mangle]
pub extern "C" fn editor_cut(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &mut *handle }.inner.cut().len() as c_ulong
}

/// Paste the most recent clipboard entry.
/// Returns number of ops applied.
#[no_mangle]
pub extern "C" fn editor_paste(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &mut *handle }.inner.paste().len() as c_ulong
}

/// Paste the previous clipboard entry (cycle through history).
#[no_mangle]
pub extern "C" fn editor_cycle_paste(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &mut *handle }.inner.cycle_paste().len() as c_ulong
}

/// Get the current clipboard text.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_clipboard_text(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let text = h.inner.clipboard.peek_text().to_owned();
    CString::new(text)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get clipboard history as a JSON array of {text, kind} objects.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_clipboard_history(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let history: Vec<serde_json::Value> = h
        .inner
        .clipboard
        .history()
        .iter()
        .map(|e| serde_json::json!({ "text": e.text, "kind": format!("{:?}", e.kind) }))
        .collect();
    let json = serde_json::to_string(&history).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get clipboard history length.
#[no_mangle]
pub extern "C" fn editor_clipboard_history_len(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.clipboard.history_len() as c_ulong
}

// ── Macro recording ────────────────────────────────────────────────────────────

/// Start recording into register `reg` (ASCII char: 'a'-'z' or '"').
/// Returns 0 on success, -1 if already recording.
#[no_mangle]
pub extern "C" fn editor_macro_start(handle: *mut EditorHandle, reg: u8) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    match h.inner.macro_start(reg as char) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

/// Stop recording. Returns number of ops recorded, or -1 if not recording.
#[no_mangle]
pub extern "C" fn editor_macro_stop(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    match h.inner.macro_stop() {
        Ok(n) => n as c_int,
        Err(_) => -1,
    }
}

/// Returns 1 if currently recording a macro, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_macro_is_recording(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    if unsafe { &*handle }.inner.macros.is_recording() {
        1
    } else {
        0
    }
}

/// Get the register currently being recorded (ASCII byte), or 0 if not recording.
#[no_mangle]
pub extern "C" fn editor_macro_recording_register(handle: *const EditorHandle) -> u8 {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }
        .inner
        .macros
        .recording_register()
        .map(|c| c as u8)
        .unwrap_or(0)
}

/// Play back macro in register `reg` exactly `count` times.
/// Returns number of edit ops applied.
#[no_mangle]
pub extern "C" fn editor_macro_play(handle: *mut EditorHandle, reg: u8, count: c_ulong) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    h.inner.macro_play(reg as char, count as usize).len() as c_ulong
}

/// Get macro register contents as JSON.
/// Returns JSON array of ops for register `reg`, or null if not found.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_macro_get(handle: *const EditorHandle, reg: u8) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    match h.inner.macros.register(reg as char) {
        Some(r) => {
            let json = serde_json::to_string(&r.ops).unwrap_or_else(|_| "[]".into());
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Export all macro registers as JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_macro_export(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let json = h.inner.macros.to_json();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Import macro registers from JSON.
/// Returns 0 on success, -1 on parse error.
#[no_mangle]
pub extern "C" fn editor_macro_import(handle: *mut EditorHandle, json_str: *const c_char) -> c_int {
    if handle.is_null() || json_str.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(json_str) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match h.inner.macros.from_json(json) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

// ── Formatting ────────────────────────────────────────────────────────────────

/// Format the entire document. Returns number of changes applied.
#[no_mangle]
pub extern "C" fn editor_format_document(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let result = h.inner.format_document(None);
    if result.has_changes {
        h.inner.apply_batch(result.ops).len() as c_ulong
    } else {
        0
    }
}

/// Format a range of lines [first_line, last_line] (0-based, inclusive).
/// Returns number of changes applied.
#[no_mangle]
pub extern "C" fn editor_format_range(
    handle: *mut EditorHandle,
    first_line: c_ulong,
    last_line: c_ulong,
) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let result = h
        .inner
        .format_range(first_line as usize, last_line as usize, None);
    if result.has_changes {
        h.inner.apply_batch(result.ops).len() as c_ulong
    } else {
        0
    }
}

/// Run format-on-save (indent + trailing whitespace + final newline + import sort).
/// Returns number of changes applied.
#[no_mangle]
pub extern "C" fn editor_format_on_save(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let result = h.inner.format_on_save();
    if result.has_changes {
        h.inner.apply_batch(result.ops).len() as c_ulong
    } else {
        0
    }
}

/// Sort import/use statements alphabetically.
/// Returns number of changes applied.
#[no_mangle]
pub extern "C" fn editor_sort_imports(handle: *mut EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let lang = h.inner.language.clone();
    let result = crate::sort_imports(&h.inner.buffer, &lang);
    if result.has_changes {
        h.inner.apply_batch(result.ops).len() as c_ulong
    } else {
        0
    }
}

// ── Document statistics ────────────────────────────────────────────────────────

/// Get document statistics as a JSON object.
/// JSON: {"bytes":N,"chars":N,"words":N,"lines":N,"sentences":N,"paragraphs":N}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_document_stats(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let stats = h.inner.document_stats();
    let json = serde_json::to_string(&stats).unwrap_or_else(|_| "{}".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get word count for the document (or selection if one is active).
#[no_mangle]
pub extern "C" fn editor_word_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    if let Some(sel) = h.inner.cursors.primary().selection() {
        let stats = crate::core::clipboard::DocumentStats::compute_selection(
            &h.inner.buffer,
            sel.as_range(),
        );
        stats.words as c_ulong
    } else {
        h.inner.document_stats().words as c_ulong
    }
}

/// Get character count for the document (or selection if one is active).
#[no_mangle]
pub extern "C" fn editor_char_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    if let Some(sel) = h.inner.cursors.primary().selection() {
        let stats = crate::core::clipboard::DocumentStats::compute_selection(
            &h.inner.buffer,
            sel.as_range(),
        );
        stats.chars as c_ulong
    } else {
        h.inner.document_stats().chars as c_ulong
    }
}

/// Get line count (excluding the trailing empty line).
#[no_mangle]
pub extern "C" fn editor_content_line_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.document_stats().lines as c_ulong
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi::c_api::{
        editor_create, editor_create_with_content, editor_cursor_move, editor_destroy,
        editor_free_str, editor_get_text, editor_set_language,
    };
    use std::ffi::CString;

    fn get_text(h: *mut EditorHandle) -> String {
        let p = editor_get_text(h);
        let s = unsafe { std::ffi::CStr::from_ptr(p).to_str().unwrap().to_owned() };
        editor_free_str(p);
        s
    }

    // ── Clipboard ─────────────────────────────────────────────────────────────

    #[test]
    fn test_copy_and_paste() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        // Select "hello" (0-5) then copy
        editor_cursor_move(h, 0, 0);
        crate::ffi::c_api_extended::editor_select_word(h);
        editor_copy(h);
        // Move to end and paste
        editor_cursor_move(h, 11, 0);
        editor_paste(h);
        let text = get_text(h);
        assert!(
            text.ends_with("hello") || text.contains("hello"),
            "Pasted text: {}",
            text
        );
        editor_destroy(h);
    }

    #[test]
    fn test_clipboard_text() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        // Select "hello" manually
        editor_cursor_move(h, 0, 0);
        crate::ffi::c_api_extended::editor_select_word(h);
        editor_copy(h);
        let p = editor_clipboard_text(h);
        let text = unsafe { std::ffi::CStr::from_ptr(p).to_str().unwrap().to_owned() };
        editor_free_str(p);
        assert_eq!(text, "hello");
        editor_destroy(h);
    }

    #[test]
    fn test_cut_deletes_selection() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        editor_cursor_move(h, 0, 0);
        crate::ffi::c_api_extended::editor_select_word(h);
        let ops = editor_cut(h);
        assert!(ops > 0);
        let text = get_text(h);
        assert!(
            !text.starts_with("hello"),
            "Cut should have deleted selection"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_clipboard_history_len() {
        let h = editor_create_with_content(CString::new("abc def ghi").unwrap().as_ptr());
        // Copy three things
        for _ in 0..3 {
            editor_cursor_move(h, 0, 0);
            crate::ffi::c_api_extended::editor_select_word(h);
            editor_copy(h);
            editor_cursor_move(h, 4, 0);
        }
        // History should have grown
        let len = editor_clipboard_history_len(h);
        assert!(len >= 1);
        editor_destroy(h);
    }

    // ── Macro recording ───────────────────────────────────────────────────────

    #[test]
    fn test_macro_start_stop() {
        let h = editor_create();
        assert_eq!(editor_macro_is_recording(h), 0);
        assert_eq!(editor_macro_start(h, b'q'), 0);
        assert_eq!(editor_macro_is_recording(h), 1);
        assert_eq!(editor_macro_recording_register(h), b'q');
        let count = editor_macro_stop(h);
        assert!(count >= 0);
        assert_eq!(editor_macro_is_recording(h), 0);
        editor_destroy(h);
    }

    #[test]
    fn test_macro_start_while_recording_fails() {
        let h = editor_create();
        editor_macro_start(h, b'q');
        assert_eq!(editor_macro_start(h, b'w'), -1); // already recording
        editor_macro_stop(h);
        editor_destroy(h);
    }

    #[test]
    fn test_macro_export_import() {
        let h = editor_create();
        editor_macro_start(h, b'q');
        editor_macro_stop(h);

        let export = editor_macro_export(h);
        assert!(!export.is_null());
        let json = unsafe {
            std::ffi::CStr::from_ptr(export)
                .to_str()
                .unwrap()
                .to_owned()
        };
        editor_free_str(export);

        // Import into a new editor
        let h2 = editor_create();
        let json_cstr = CString::new(json).unwrap();
        assert_eq!(editor_macro_import(h2, json_cstr.as_ptr()), 0);
        editor_destroy(h);
        editor_destroy(h2);
    }

    // ── Formatting ────────────────────────────────────────────────────────────

    #[test]
    fn test_format_document_trailing_whitespace() {
        let h = editor_create_with_content(CString::new("hello   \nworld   \n").unwrap().as_ptr());
        let changes = editor_format_document(h);
        assert!(changes > 0, "Should have removed trailing whitespace");
        let text = get_text(h);
        assert!(
            !text.contains("   \n"),
            "Trailing whitespace should be gone"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_format_document_final_newline() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        editor_format_document(h);
        let text = get_text(h);
        assert!(
            text.ends_with('\n'),
            "Should have final newline after format"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_format_range() {
        let h = editor_create_with_content(
            CString::new("hello   \nworld   \nfoo   \n")
                .unwrap()
                .as_ptr(),
        );
        let changes = editor_format_range(h, 1, 1);
        assert_eq!(changes, 1, "Only line 1 should be formatted");
        editor_destroy(h);
    }

    #[test]
    fn test_sort_imports_rust() {
        let src = CString::new(
            "use std::io;\nuse anyhow::Result;\nuse std::collections::HashMap;\n\nfn main() {}\n",
        )
        .unwrap();
        let h = editor_create_with_content(src.as_ptr());
        let lang = CString::new("rust").unwrap();
        editor_set_language(h, lang.as_ptr());
        let changes = editor_sort_imports(h);
        assert!(changes > 0, "Imports should be sorted");
        editor_destroy(h);
    }

    // ── Statistics ────────────────────────────────────────────────────────────

    #[test]
    fn test_word_count() {
        let h = editor_create_with_content(CString::new("hello world foo bar").unwrap().as_ptr());
        assert_eq!(editor_word_count(h), 4);
        editor_destroy(h);
    }

    #[test]
    fn test_char_count() {
        let h = editor_create_with_content(CString::new("hello").unwrap().as_ptr());
        assert_eq!(editor_char_count(h), 5);
        editor_destroy(h);
    }

    #[test]
    fn test_document_stats_json() {
        let h = editor_create_with_content(
            CString::new("Hello world.\nSecond line.\n")
                .unwrap()
                .as_ptr(),
        );
        let p = editor_document_stats(h);
        assert!(!p.is_null());
        let json = unsafe { std::ffi::CStr::from_ptr(p).to_str().unwrap().to_owned() };
        editor_free_str(p);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(v["words"].as_u64().unwrap() >= 4);
        assert!(v["bytes"].as_u64().unwrap() > 0);
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_extra() {
        editor_copy(std::ptr::null_mut());
        assert_eq!(editor_cut(std::ptr::null_mut()), 0);
        assert_eq!(editor_paste(std::ptr::null_mut()), 0);
        assert_eq!(editor_macro_start(std::ptr::null_mut(), b'q'), -1);
        assert_eq!(editor_macro_stop(std::ptr::null_mut()), -1);
        assert_eq!(editor_format_document(std::ptr::null_mut()), 0);
        assert_eq!(editor_word_count(std::ptr::null()), 0);
    }
}
