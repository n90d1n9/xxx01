// src/ffi/c_api.rs
//
// C-compatible API — callable from Dart FFI (Flutter), Java FFM, Swift, and C/C++.
//
// Memory ownership rules:
//   • `Editor*`  — allocated by Rust, freed by `editor_destroy`.
//   • `char*`    — returned strings are Rust-owned.  Caller MUST call
//                  `editor_free_str` exactly once.
//   • Input `const char*` — borrowed for the duration of the call only.
//
// Error handling:
//   • Functions that can fail return int: 0 = success, non-zero = error code.
//   • `editor_last_error()` returns a description of the last error.

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};
use std::panic;

use crate::core::edit::EditOp;
use crate::Editor;

// ── Opaque handle ─────────────────────────────────────────────────────────────

/// Opaque editor handle.  Never dereference this from the caller side.
pub struct EditorHandle {
    pub(crate) inner: Editor,
}

// Thread-local last error (so multi-editor hosts don't share error state)
thread_local! {
    static LAST_ERROR: std::cell::RefCell<String> = std::cell::RefCell::new(String::new());
}

fn set_last_error(msg: &str) {
    LAST_ERROR.with(|e| *e.borrow_mut() = msg.to_owned());
}

// ── Lifecycle ─────────────────────────────────────────────────────────────────

/// Create a new empty editor. Returns null on allocation failure.
#[no_mangle]
pub extern "C" fn editor_create() -> *mut EditorHandle {
    let handle = Box::new(EditorHandle {
        inner: Editor::new(),
    });
    Box::into_raw(handle)
}

/// Create an editor pre-loaded with `content` (UTF-8, null-terminated).
/// Returns null if `content` is not valid UTF-8.
#[no_mangle]
pub extern "C" fn editor_create_with_content(content: *const c_char) -> *mut EditorHandle {
    let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
        let s = unsafe {
            if content.is_null() {
                return std::ptr::null_mut();
            }
            match CStr::from_ptr(content).to_str() {
                Ok(s) => s.to_owned(),
                Err(_) => {
                    set_last_error("content is not valid UTF-8");
                    return std::ptr::null_mut();
                }
            }
        };
        let handle = Box::new(EditorHandle {
            inner: Editor::from_str(&s),
        });
        Box::into_raw(handle)
    }));
    result.unwrap_or(std::ptr::null_mut())
}

/// Free an editor handle.  Passing null is a no-op.
#[no_mangle]
pub extern "C" fn editor_destroy(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe {
        drop(Box::from_raw(handle));
    }
}

// ── Text queries ──────────────────────────────────────────────────────────────

/// Return the total number of bytes in the document.
#[no_mangle]
pub extern "C" fn editor_byte_len(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    h.inner.buffer.len_bytes() as c_ulong
}

/// Return the total number of lines in the document.
#[no_mangle]
pub extern "C" fn editor_line_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    h.inner.buffer.len_lines() as c_ulong
}

/// Get the text of line `line_num` (0-based) as a null-terminated UTF-8 string.
/// Returns null if `line_num` is out of range.
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_get_line(handle: *const EditorHandle, line_num: c_ulong) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let line = h.inner.buffer.line_str(line_num as usize);
    match CString::new(line) {
        Ok(cs) => cs.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return the full document text as a null-terminated UTF-8 string.
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_get_text(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let text = h.inner.buffer.to_string();
    match CString::new(text) {
        Ok(cs) => cs.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

// ── Mutations ─────────────────────────────────────────────────────────────────

/// Insert `text` (UTF-8, null-terminated) at byte offset `pos`.
/// Returns 0 on success, -1 on error.
#[no_mangle]
pub extern "C" fn editor_insert(
    handle: *mut EditorHandle,
    pos: c_ulong,
    text: *const c_char,
) -> c_int {
    if handle.is_null() || text.is_null() {
        return -1;
    }

    let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
        let h = unsafe { &mut *handle };
        let s = match unsafe { CStr::from_ptr(text) }.to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => {
                set_last_error("text is not valid UTF-8");
                return -1;
            }
        };
        h.inner.apply(EditOp::insert(pos as usize, s));
        0
    }));

    result.unwrap_or_else(|_e| {
        set_last_error("panic in editor_insert");
        -1
    })
}

/// Delete bytes in range [start, end).
/// Returns 0 on success, -1 on error.
#[no_mangle]
pub extern "C" fn editor_delete(handle: *mut EditorHandle, start: c_ulong, end: c_ulong) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
        let h = unsafe { &mut *handle };
        let buf_len = h.inner.buffer.len_bytes();
        let s = (start as usize).min(buf_len);
        let e = (end as usize).min(buf_len);
        if s >= e {
            return 0;
        }
        h.inner.apply(EditOp::delete(s, e));
        0
    }));
    result.unwrap_or(-1)
}

/// Replace bytes in range [start, end) with `text`.
/// Returns 0 on success, -1 on error.
#[no_mangle]
pub extern "C" fn editor_replace(
    handle: *mut EditorHandle,
    start: c_ulong,
    end: c_ulong,
    text: *const c_char,
) -> c_int {
    if handle.is_null() || text.is_null() {
        return -1;
    }
    let result = panic::catch_unwind(panic::AssertUnwindSafe(|| {
        let h = unsafe { &mut *handle };
        let s = match unsafe { CStr::from_ptr(text) }.to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => {
                set_last_error("text is not valid UTF-8");
                return -1;
            }
        };
        let buf_len = h.inner.buffer.len_bytes();
        let st = (start as usize).min(buf_len);
        let en = (end as usize).min(buf_len);
        h.inner.apply(EditOp::replace(st, en, s));
        0
    }));
    result.unwrap_or(-1)
}

// ── Undo / Redo ───────────────────────────────────────────────────────────────

/// Undo the last edit. Returns 1 if undo was performed, 0 if nothing to undo.
#[no_mangle]
pub extern "C" fn editor_undo(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    if h.inner.undo().is_some() {
        1
    } else {
        0
    }
}

/// Redo the last undone edit. Returns 1 if redo was performed, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_redo(handle: *mut EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &mut *handle };
    if h.inner.redo().is_some() {
        1
    } else {
        0
    }
}

/// Returns 1 if undo is available, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_can_undo(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    if h.inner.undo_stack.can_undo() {
        1
    } else {
        0
    }
}

/// Returns 1 if redo is available, 0 otherwise.
#[no_mangle]
pub extern "C" fn editor_can_redo(handle: *const EditorHandle) -> c_int {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    if h.inner.undo_stack.can_redo() {
        1
    } else {
        0
    }
}

// ── Cursor ────────────────────────────────────────────────────────────────────

/// Move the primary cursor to byte offset `pos`.
#[no_mangle]
pub extern "C" fn editor_cursor_move(
    handle: *mut EditorHandle,
    pos: c_ulong,
    extend_selection: c_int,
) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    h.inner.cursors.move_to(pos as usize, extend_selection != 0);
    0
}

/// Add a secondary cursor at byte offset `pos`.
#[no_mangle]
pub extern "C" fn editor_cursor_add(handle: *mut EditorHandle, pos: c_ulong) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    h.inner.cursors.add(pos as usize);
    0
}

/// Remove all secondary cursors; keep only the primary.
#[no_mangle]
pub extern "C" fn editor_cursor_collapse(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    h.inner.cursors.collapse_to_primary();
}

/// Get the current primary cursor byte offset.
#[no_mangle]
pub extern "C" fn editor_cursor_pos(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    h.inner.cursors.primary().pos.0 as c_ulong
}

/// Get the number of active cursors.
#[no_mangle]
pub extern "C" fn editor_cursor_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    h.inner.cursors.count() as c_ulong
}

// ── Viewport ──────────────────────────────────────────────────────────────────

/// Set the viewport height (number of visible lines).
#[no_mangle]
pub extern "C" fn editor_set_viewport_height(handle: *mut EditorHandle, height: c_ulong) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    h.inner.viewport.set_height(height as usize);
}

/// Scroll the viewport to ensure `line` is visible.
#[no_mangle]
pub extern "C" fn editor_ensure_line_visible(handle: *mut EditorHandle, line: c_ulong) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let total = h.inner.buffer.len_lines();
    h.inner.viewport.ensure_cursor_visible(line as usize, total);
}

/// Scroll by `delta` lines (positive = down, negative = up).
#[no_mangle]
pub extern "C" fn editor_scroll_by(handle: *mut EditorHandle, delta: c_int) {
    if handle.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let total = h.inner.buffer.len_lines();
    h.inner.viewport.scroll_by(delta as i64, total);
}

// ── Frame rendering ───────────────────────────────────────────────────────────

/// Serialise the current render frame to JSON (UTF-8).
/// Returns a null-terminated JSON string.
/// CALLER MUST call `editor_free_str` on the returned pointer.
///
/// JSON shape:
/// {
///   "lines": [{ "line_number": 0, "text": "...", "byte_offset": 0 }],
///   "cursors": [{ "line": 0, "col": 5 }],
///   "tokens": [{ "start": 0, "end": 5, "kind": 1, "line": 0, ... }],
///   "total_lines": 100,
///   "scroll_offset": 0
/// }
#[no_mangle]
pub extern "C" fn editor_render_frame_json(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let frame = h.inner.render_frame();
    match serde_json::to_string(&frame) {
        Ok(json) => match CString::new(json) {
            Ok(cs) => cs.into_raw(),
            Err(_) => std::ptr::null_mut(),
        },
        Err(e) => {
            set_last_error(&e.to_string());
            std::ptr::null_mut()
        }
    }
}

// ── Language / Syntax ─────────────────────────────────────────────────────────

/// Set the syntax highlighting language (e.g. "rust", "python", "javascript").
/// Pass null or empty string to disable highlighting.
#[cfg(feature = "syntax")]
#[no_mangle]
pub extern "C" fn editor_set_language(handle: *mut EditorHandle, language: *const c_char) -> c_int {
    if handle.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    if language.is_null() {
        return 0;
    }
    let lang = match unsafe { CStr::from_ptr(language) }.to_str() {
        Ok(s) => s.to_owned(),
        Err(_) => return -1,
    };
    h.inner.set_language(&lang);
    0
}

// ── Search ────────────────────────────────────────────────────────────────────

/// Find all occurrences of `pattern` in the document.
/// Returns a JSON array of byte offsets: [0, 42, 88, ...]
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_find_all(
    handle: *const EditorHandle,
    pattern: *const c_char,
) -> *mut c_char {
    if handle.is_null() || pattern.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let pat = match unsafe { CStr::from_ptr(pattern) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let offsets = h.inner.buffer.find_all(pat);
    let offsets_raw: Vec<usize> = offsets.iter().map(|o| o.0).collect();
    match serde_json::to_string(&offsets_raw) {
        Ok(json) => CString::new(json)
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut()),
        Err(_) => std::ptr::null_mut(),
    }
}

// ── Memory management ─────────────────────────────────────────────────────────

/// Free a string previously returned by this API.
/// Passing null is a no-op.
#[no_mangle]
pub extern "C" fn editor_free_str(s: *mut c_char) {
    if s.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(s));
    }
}

// ── Error reporting ───────────────────────────────────────────────────────────

/// Return a description of the last error (null-terminated UTF-8).
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_last_error() -> *mut c_char {
    let msg = LAST_ERROR.with(|e| e.borrow().clone());
    CString::new(msg)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Version ───────────────────────────────────────────────────────────────────

/// Return the library version string (e.g. "0.1.0").
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_version() -> *mut c_char {
    let v = env!("CARGO_PKG_VERSION");
    CString::new(v)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    #[test]
    fn test_create_destroy() {
        let h = editor_create();
        assert!(!h.is_null());
        editor_destroy(h);
    }

    #[test]
    fn test_create_with_content() {
        let content = CString::new("hello world").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        assert!(!h.is_null());
        assert_eq!(editor_byte_len(h), 11);
        editor_destroy(h);
    }

    #[test]
    fn test_insert_and_get_text() {
        let h = editor_create();
        let text = CString::new("Hello").unwrap();
        assert_eq!(editor_insert(h, 0, text.as_ptr()), 0);
        let result = editor_get_text(h);
        let s = unsafe { CStr::from_ptr(result).to_str().unwrap().to_owned() };
        editor_free_str(result);
        assert_eq!(s, "Hello");
        editor_destroy(h);
    }

    #[test]
    fn test_delete() {
        let content = CString::new("Hello World").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        assert_eq!(editor_delete(h, 5, 11), 0);
        let result = editor_get_text(h);
        let s = unsafe { CStr::from_ptr(result).to_str().unwrap().to_owned() };
        editor_free_str(result);
        assert_eq!(s, "Hello");
        editor_destroy(h);
    }

    #[test]
    fn test_replace() {
        let content = CString::new("Hello World").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let replacement = CString::new("Rust").unwrap();
        assert_eq!(editor_replace(h, 6, 11, replacement.as_ptr()), 0);
        let result = editor_get_text(h);
        let s = unsafe { CStr::from_ptr(result).to_str().unwrap().to_owned() };
        editor_free_str(result);
        assert_eq!(s, "Hello Rust");
        editor_destroy(h);
    }

    #[test]
    fn test_undo_redo() {
        let h = editor_create();
        let text = CString::new("abc").unwrap();
        editor_insert(h, 0, text.as_ptr());
        assert_eq!(editor_can_undo(h), 1);
        assert_eq!(editor_can_redo(h), 0);
        editor_undo(h);
        assert_eq!(editor_can_undo(h), 0);
        assert_eq!(editor_can_redo(h), 1);
        editor_redo(h);
        assert_eq!(editor_can_undo(h), 1);
        editor_destroy(h);
    }

    #[test]
    fn test_line_count() {
        let content = CString::new("line1\nline2\nline3").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        assert_eq!(editor_line_count(h), 3);
        editor_destroy(h);
    }

    #[test]
    fn test_get_line() {
        let content = CString::new("foo\nbar\nbaz").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let line = editor_get_line(h, 1);
        let s = unsafe { CStr::from_ptr(line).to_str().unwrap().to_owned() };
        editor_free_str(line);
        assert_eq!(s, "bar");
        editor_destroy(h);
    }

    #[test]
    fn test_cursor_move() {
        let content = CString::new("hello world").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        editor_cursor_move(h, 6, 0);
        assert_eq!(editor_cursor_pos(h), 6);
        editor_destroy(h);
    }

    #[test]
    fn test_find_all() {
        let content = CString::new("foo bar foo baz foo").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let pat = CString::new("foo").unwrap();
        let result = editor_find_all(h, pat.as_ptr());
        let json = unsafe { CStr::from_ptr(result).to_str().unwrap().to_owned() };
        editor_free_str(result);
        let offsets: Vec<usize> = serde_json::from_str(&json).unwrap();
        assert_eq!(offsets, vec![0, 8, 16]);
        editor_destroy(h);
    }

    #[test]
    fn test_render_frame_json() {
        let content = CString::new("hello\nworld").unwrap();
        let h = editor_create_with_content(content.as_ptr());
        let json_ptr = editor_render_frame_json(h);
        assert!(!json_ptr.is_null());
        let json = unsafe { CStr::from_ptr(json_ptr).to_str().unwrap().to_owned() };
        editor_free_str(json_ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(v["lines"].is_array());
        assert!(v["total_lines"].as_u64().unwrap() >= 2);
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety() {
        // All public functions must handle null without panicking
        editor_destroy(std::ptr::null_mut());
        assert_eq!(editor_byte_len(std::ptr::null()), 0);
        assert_eq!(editor_line_count(std::ptr::null()), 0);
        assert!(editor_get_text(std::ptr::null()).is_null());
        assert_eq!(editor_insert(std::ptr::null_mut(), 0, std::ptr::null()), -1);
        assert_eq!(editor_delete(std::ptr::null_mut(), 0, 0), -1);
        assert_eq!(editor_undo(std::ptr::null_mut()), 0);
        assert_eq!(editor_redo(std::ptr::null_mut()), 0);
    }

    #[test]
    fn test_version_string() {
        let v = editor_version();
        assert!(!v.is_null());
        let s = unsafe { CStr::from_ptr(v).to_str().unwrap().to_owned() };
        editor_free_str(v);
        assert!(!s.is_empty());
    }
}
