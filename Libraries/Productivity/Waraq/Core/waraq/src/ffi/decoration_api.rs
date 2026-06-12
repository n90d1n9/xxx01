// src/ffi/decoration_api.rs
// C API for Monaco-compatible decorations and TextModel operations.

use super::c_api::EditorHandle;
use crate::core::decoration::{DecorationId, DecorationRenderInfo};
use crate::core::text_model::{MonacoPosition, MonacoRange, SingleEditOperation};
use crate::core::types::Range;
use crate::{DecorationOptions, DecorationSpec};
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_ulong};

// ── deltaDecorations ──────────────────────────────────────────────────────────

/// Apply decoration delta.
/// `remove_json`: JSON array of DecorationId numbers to remove: [1, 3, 7]
/// `add_json`: JSON array of decoration specs:
///   [{"range":{"start":0,"end":5},"options":{"kind":"Diagnostic","is_whole_line":false,...},"owner":"myext"}]
/// Returns JSON array of new decoration IDs: [8, 9, 10]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_delta_decorations(
    handle: *mut EditorHandle,
    remove_json: *const c_char,
    add_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };

    // Parse IDs to remove
    let remove_ids: Vec<DecorationId> = if remove_json.is_null() {
        vec![]
    } else {
        match unsafe { CStr::from_ptr(remove_json) }.to_str() {
            Ok(s) => serde_json::from_str(s).unwrap_or_default(),
            Err(_) => vec![],
        }
    };

    // Parse specs to add
    let add_specs: Vec<(DecorationSpec, String)> = if add_json.is_null() {
        vec![]
    } else {
        match unsafe { CStr::from_ptr(add_json) }.to_str() {
            Ok(s) => {
                let raw: Vec<serde_json::Value> = serde_json::from_str(s).unwrap_or_default();
                raw.into_iter()
                    .filter_map(|v| {
                        let start = v["range"]["start"].as_u64()? as usize;
                        let end = v["range"]["end"].as_u64()? as usize;
                        let owner = v["owner"].as_str().unwrap_or("unknown").to_owned();
                        let opts =
                            serde_json::from_value::<DecorationOptions>(v["options"].clone())
                                .unwrap_or_default();
                        Some((
                            DecorationSpec {
                                range: Range::new(start, end),
                                options: opts,
                            },
                            owner,
                        ))
                    })
                    .collect()
            }
            Err(_) => vec![],
        }
    };

    let new_ids = h.inner.delta_decorations(&remove_ids, &add_specs);
    let json = serde_json::to_string(&new_ids).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Remove all decorations from a specific owner.
#[no_mangle]
pub extern "C" fn editor_clear_decorations(handle: *mut EditorHandle, owner: *const c_char) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let owner_str = if owner.is_null() {
        "unknown".to_owned()
    } else {
        match unsafe { CStr::from_ptr(owner) }.to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return,
        }
    };
    h.inner.clear_decorations_by_owner(&owner_str);
}

/// Get all visible decorations as a JSON array.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_get_decorations(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let decs = h.inner.viewport_decorations();
    let json = serde_json::to_string(&decs).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get decorations at a specific byte offset (for hover tooltips).
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_decorations_at(
    handle: *const EditorHandle,
    offset: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let decs: Vec<DecorationRenderInfo> = h
        .inner
        .decorations
        .at_offset(crate::ByteOffset(offset as usize))
        .into_iter()
        .map(|d| DecorationRenderInfo::from_decoration(d, &h.inner.buffer))
        .collect();
    let json = serde_json::to_string(&decs).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get overview ruler items (for the scrollbar minimap).
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_overview_ruler(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let total = h.inner.buffer.len_lines();
    let items = h
        .inner
        .decorations
        .overview_ruler_items(&h.inner.buffer, total);
    let json = serde_json::to_string(&items).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── TextModel API ─────────────────────────────────────────────────────────────

/// Get line content (1-based line number, without newline).
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_model_get_line(
    handle: *const EditorHandle,
    line_number: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let m = h.inner.text_model();
    let text = m.get_line_content(line_number as u32);
    CString::new(text)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get byte offset for a Monaco position (1-based line, 1-based column).
#[no_mangle]
pub extern "C" fn editor_model_get_offset(
    handle: *const EditorHandle,
    line_number: c_ulong,
    column: c_ulong,
) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    let m = h.inner.text_model();
    m.get_offset_at(MonacoPosition::new(line_number as u32, column as u32)) as c_ulong
}

/// Get Monaco position for a byte offset. Returns JSON {"lineNumber":1,"column":1}.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_model_get_position(
    handle: *const EditorHandle,
    offset: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let m = h.inner.text_model();
    let pos = m.get_position_at(offset as usize);
    let json = serde_json::json!({"lineNumber": pos.line_number, "column": pos.column}).to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get text in a Monaco range.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_model_get_value_in_range(
    handle: *const EditorHandle,
    start_line_number: c_ulong,
    start_column: c_ulong,
    end_line_number: c_ulong,
    end_column: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let m = h.inner.text_model();
    let range = MonacoRange::new(
        start_line_number as u32,
        start_column as u32,
        end_line_number as u32,
        end_column as u32,
    );
    let text = m.get_value_in_range(range);
    CString::new(text)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Find all matches for a search string in the document.
/// flags: 0x01=case_sensitive, 0x02=whole_word, 0x04=regex
/// Returns JSON array of MonacoRange objects.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_model_find_matches(
    handle: *const EditorHandle,
    search: *const c_char,
    flags: c_ulong,
    limit: c_ulong,
) -> *mut c_char {
    if handle.is_null() || search.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let s = match unsafe { CStr::from_ptr(search) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let m = h.inner.text_model();
    let matches = m.find_matches(
        s,
        flags & 0x04 != 0, // regex
        flags & 0x01 != 0, // case sensitive
        flags & 0x02 != 0, // whole word
        None,
        limit as usize,
    );
    let json_arr: Vec<serde_json::Value> = matches
        .iter()
        .map(|fm| {
            serde_json::json!({
                "startLineNumber": fm.range.start_line_number,
                "startColumn":     fm.range.start_column,
                "endLineNumber":   fm.range.end_line_number,
                "endColumn":       fm.range.end_column,
            })
        })
        .collect();
    let json = serde_json::to_string(&json_arr).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get the word at a Monaco position.
/// Returns JSON: {"word":"...","startColumn":1,"endColumn":6} or null.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_model_word_at(
    handle: *const EditorHandle,
    line_number: c_ulong,
    column: c_ulong,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let m = h.inner.text_model();
    match m.get_word_at_position(MonacoPosition::new(line_number as u32, column as u32)) {
        Some(w) => {
            let json = serde_json::json!({
                "word": w.word,
                "startColumn": w.start_column,
                "endColumn": w.end_column,
            })
            .to_string();
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => std::ptr::null_mut(),
    }
}

/// Apply a list of Monaco-style edits (JSON array of SingleEditOperation).
/// Returns number of edits applied.
#[no_mangle]
pub extern "C" fn editor_execute_edits(
    handle: *mut EditorHandle,
    edits_json: *const c_char,
) -> c_ulong {
    if handle.is_null() || edits_json.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(edits_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    let raw: Vec<serde_json::Value> = match serde_json::from_str(json) {
        Ok(v) => v,
        Err(_) => return 0,
    };
    let edits: Vec<SingleEditOperation> = raw
        .into_iter()
        .filter_map(|v| {
            let sln = v["range"]["startLineNumber"].as_u64()? as u32;
            let sc = v["range"]["startColumn"].as_u64()? as u32;
            let eln = v["range"]["endLineNumber"].as_u64()? as u32;
            let ec = v["range"]["endColumn"].as_u64()? as u32;
            let range = MonacoRange::new(sln, sc, eln, ec);
            let text = v["text"].as_str().map(|s| s.to_owned());
            Some(SingleEditOperation {
                range,
                text,
                force_move_markers: false,
            })
        })
        .collect();

    h.inner.execute_edits(&edits).len() as c_ulong
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

    #[test]
    fn test_delta_decorations_add() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        let remove = CString::new("[]").unwrap();
        let add    = CString::new(r#"[{"range":{"start":0,"end":5},"options":{"is_whole_line":false,"z_index":0,"kind":"Highlight"},"owner":"test"}]"#).unwrap();
        let ptr = editor_delta_decorations(h, remove.as_ptr(), add.as_ptr());
        let ids = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&ids).unwrap();
        assert!(v.as_array().unwrap().len() == 1);
        editor_destroy(h);
    }

    #[test]
    fn test_clear_decorations() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        let remove = CString::new("[]").unwrap();
        let add    = CString::new(r#"[{"range":{"start":0,"end":5},"options":{"is_whole_line":false,"z_index":0,"kind":"Custom"},"owner":"myext"}]"#).unwrap();
        editor_delta_decorations(h, remove.as_ptr(), add.as_ptr());
        let owner = CString::new("myext").unwrap();
        editor_clear_decorations(h, owner.as_ptr());
        let ptr = editor_get_decorations(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(v.as_array().unwrap().is_empty());
        editor_destroy(h);
    }

    #[test]
    fn test_model_get_line() {
        let h = editor_create_with_content(CString::new("hello\nworld\n").unwrap().as_ptr());
        let ptr = editor_model_get_line(h, 1);
        let text = get_str(ptr);
        assert_eq!(text, "hello");
        let ptr2 = editor_model_get_line(h, 2);
        let text2 = get_str(ptr2);
        assert_eq!(text2, "world");
        editor_destroy(h);
    }

    #[test]
    fn test_model_get_offset() {
        let h = editor_create_with_content(CString::new("hello\nworld\n").unwrap().as_ptr());
        assert_eq!(editor_model_get_offset(h, 1, 1), 0);
        assert_eq!(editor_model_get_offset(h, 2, 1), 6);
        editor_destroy(h);
    }

    #[test]
    fn test_model_get_position() {
        let h = editor_create_with_content(CString::new("hello\nworld\n").unwrap().as_ptr());
        let ptr = editor_model_get_position(h, 6);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["lineNumber"], 2);
        assert_eq!(v["column"], 1);
        editor_destroy(h);
    }

    #[test]
    fn test_model_find_matches() {
        let h = editor_create_with_content(CString::new("foo bar foo baz foo").unwrap().as_ptr());
        let s = CString::new("foo").unwrap();
        let ptr = editor_model_find_matches(h, s.as_ptr(), 0x01, 0);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(arr.as_array().unwrap().len(), 3);
        editor_destroy(h);
    }

    #[test]
    fn test_model_word_at() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        let ptr = editor_model_word_at(h, 1, 7);
        let json = get_str(ptr);
        assert!(!json.is_empty());
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["word"], "world");
        editor_destroy(h);
    }

    #[test]
    fn test_execute_edits() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        let json = CString::new(r#"[{"range":{"startLineNumber":1,"startColumn":7,"endLineNumber":1,"endColumn":12},"text":"Rust"}]"#).unwrap();
        let n = editor_execute_edits(h, json.as_ptr());
        assert_eq!(n, 1);
        let ptr = crate::ffi::c_api::editor_get_text(h);
        let text = get_str(ptr);
        assert!(text.contains("Rust"), "Got: {}", text);
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_decoration_api() {
        assert!(
            editor_delta_decorations(std::ptr::null_mut(), std::ptr::null(), std::ptr::null())
                .is_null()
        );
        assert_eq!(editor_model_get_offset(std::ptr::null(), 1, 1), 0);
        assert!(editor_model_get_position(std::ptr::null(), 0).is_null());
        assert!(editor_model_find_matches(std::ptr::null(), std::ptr::null(), 0, 0).is_null());
    }
}
