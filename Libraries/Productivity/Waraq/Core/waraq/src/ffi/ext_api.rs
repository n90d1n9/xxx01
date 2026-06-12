// src/ffi/ext_api.rs
//
// C API for the extension system — allows the host application (Flutter / Java)
// to call into the extension system, register extensions from JSON manifests,
// activate/deactivate extensions, dispatch events, and query the language
// feature registry.
//
// This is analogous to the Monaco `editor.addAction`, `languages.register`,
// etc. functions, but exposed over C FFI.

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_ulong};

use super::c_api::EditorHandle;

// ── Extension lifecycle ───────────────────────────────────────────────────────

/// Register an extension from a JSON manifest string.
/// Returns the extension ID as a null-terminated string, or null on error.
/// The extension is NOT yet activated — call `editor_ext_activate` to activate.
/// CALLER MUST call editor_free_str on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_ext_register(
    handle: *mut EditorHandle,
    manifest_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || manifest_json.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(manifest_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    match h.inner.extensions.register_from_json(json) {
        Ok(id) => CString::new(id)
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut()),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Activate a registered extension by ID.
/// Returns 0 on success, -1 on error.
#[no_mangle]
pub extern "C" fn editor_ext_activate(handle: *mut EditorHandle, ext_id: *const c_char) -> c_int {
    if handle.is_null() || ext_id.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let id = match unsafe { CStr::from_ptr(ext_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match h.inner.extensions.activate(id) {
        Ok(()) => 0,
        Err(_) => -1,
    }
}

/// Deactivate an active extension.
/// Returns 0 on success, -1 on error.
#[no_mangle]
pub extern "C" fn editor_ext_deactivate(handle: *mut EditorHandle, ext_id: *const c_char) -> c_int {
    if handle.is_null() || ext_id.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let id = match unsafe { CStr::from_ptr(ext_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match h.inner.extensions.deactivate(id) {
        Ok(()) => 0,
        Err(_) => -1,
    }
}

/// Activate all extensions that respond to OnStartup.
#[no_mangle]
pub extern "C" fn editor_ext_activate_startup(handle: *mut EditorHandle) {
    if handle.is_null() {
        return;
    }
    unsafe { &mut *handle }.inner.extensions.activate_startup();
}

/// Activate all extensions that handle the given language.
#[no_mangle]
pub extern "C" fn editor_ext_activate_for_language(
    handle: *mut EditorHandle,
    language: *const c_char,
) {
    if handle.is_null() || language.is_null() {
        return;
    }
    let h = unsafe { &mut *handle };
    let lang = match unsafe { CStr::from_ptr(language) }.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };
    h.inner.extensions.activate_for_language(lang);
}

/// Get info about all registered extensions as a JSON array.
/// JSON: [{"id":"...","name":"...","version":"...","state":"Active/Registered/..."}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ext_list(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let list = h.inner.extensions.list();
    let json = serde_json::to_string(&list).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get the state of a specific extension.
/// Returns: 0=Registered, 1=Activating, 2=Active, 3=Deactivating, 4=Disposed, 5=Failed, -1=not found
#[no_mangle]
pub extern "C" fn editor_ext_state(handle: *const EditorHandle, ext_id: *const c_char) -> c_int {
    if handle.is_null() || ext_id.is_null() {
        return -1;
    }
    let h = unsafe { &*handle };
    let id = match unsafe { CStr::from_ptr(ext_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match h.inner.extensions.get(id) {
        Some(entry) => entry.state as c_int,
        None => -1,
    }
}

/// Get count of registered extensions.
#[no_mangle]
pub extern "C" fn editor_ext_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.extensions.count() as c_ulong
}

/// Get count of active extensions.
#[no_mangle]
pub extern "C" fn editor_ext_active_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.extensions.active_count() as c_ulong
}

// ── Command palette ───────────────────────────────────────────────────────────

/// Get all registered commands as a JSON array for the command palette.
/// JSON: [{"id":"...","title":"...","enabled":true}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_cmd_palette(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let items = bus.commands.palette_items();
    let json = serde_json::to_string(&items).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Search the command palette with a fuzzy query.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_cmd_search(
    handle: *const EditorHandle,
    query: *const c_char,
) -> *mut c_char {
    if handle.is_null() || query.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let q = match unsafe { CStr::from_ptr(query) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let items = bus.commands.search_palette(q);
    let json = serde_json::to_string(&items).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Execute a command by ID with optional JSON arguments.
/// Returns JSON result: {"ok":true,"value":...} or {"ok":false,"error":"..."}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_cmd_execute(
    handle: *mut EditorHandle,
    command_id: *const c_char,
    args_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || command_id.is_null() {
        return null_result("null arguments");
    }
    let h = unsafe { &mut *handle };
    let id = match unsafe { CStr::from_ptr(command_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return null_result("invalid command_id"),
    };
    let args: serde_json::Value = if args_json.is_null() {
        serde_json::Value::Null
    } else {
        match unsafe { CStr::from_ptr(args_json) }.to_str() {
            Ok(s) => serde_json::from_str(s).unwrap_or(serde_json::Value::Null),
            Err(_) => serde_json::Value::Null,
        }
    };

    // Activate extensions lazily for this command
    h.inner.extensions.activate_for_command(id);

    let mut bus = h.inner.extensions.bus().lock().unwrap();
    let result = bus.commands.execute(id, args);
    drop(bus);

    let json = match result {
        crate::CommandResult::Ok(v) => serde_json::json!({"ok":true,"value":v}).to_string(),
        crate::CommandResult::NoResult => serde_json::json!({"ok":true,"value":null}).to_string(),
        crate::CommandResult::Err(e) => serde_json::json!({"ok":false,"error":e}).to_string(),
    };
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Keybinding ────────────────────────────────────────────────────────────────

/// Resolve a key chord to a command.
/// `key_str`: "ctrl+shift+p", "ctrl+k ctrl+f", etc.
/// `context_json`: JSON object of when-clause context values.
/// Returns: {"command":"...","pending":false} or {"command":null,"pending":true} or {"command":null,"pending":false}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_key_resolve(
    handle: *mut EditorHandle,
    key_str: *const c_char,
    context_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || key_str.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let key = match unsafe { CStr::from_ptr(key_str) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    // Parse key chord
    let chord = match crate::KeyChord::parse(key) {
        Some(c) => c,
        None => {
            let r = serde_json::json!({"command":null,"pending":false,"error":"invalid key"});
            return CString::new(r.to_string())
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut());
        }
    };

    // Build context
    let mut ctx = crate::KeyContext::new();
    ctx.set("editorFocus");
    ctx.set("editorTextFocus");
    ctx.set_value("language", serde_json::json!(h.inner.language.clone()));
    if let Some(_cj) = unsafe { context_json.as_ref() } {
        if let Ok(s) = unsafe { CStr::from_ptr(context_json) }.to_str() {
            if let Ok(obj) = serde_json::from_str::<serde_json::Value>(s) {
                if let Some(map) = obj.as_object() {
                    for (k, v) in map {
                        if v.as_bool() == Some(true) {
                            ctx.set(k);
                        }
                        ctx.set_value(k, v.clone());
                    }
                }
            }
        }
    }

    let mut bus = h.inner.extensions.bus().lock().unwrap();
    let result = bus.keybindings.resolve(chord, &ctx);
    drop(bus);

    let json = match result {
        crate::KeyResolution::Command(cmd) => {
            serde_json::json!({"command": cmd, "pending": false}).to_string()
        }
        crate::KeyResolution::ChordPending => {
            serde_json::json!({"command": null, "pending": true}).to_string()
        }
        crate::KeyResolution::Unbound => {
            serde_json::json!({"command": null, "pending": false}).to_string()
        }
    };
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

// ── Theme ─────────────────────────────────────────────────────────────────────

/// Get all available themes as a JSON array.
/// JSON: [{"id":"...","name":"...","kind":"Dark/Light/HighContrast"}]
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_theme_list(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let list: Vec<serde_json::Value> = bus
        .themes
        .list()
        .into_iter()
        .map(|(id, name, kind)| {
            serde_json::json!({
                "id": id, "name": name, "kind": format!("{:?}", kind)
            })
        })
        .collect();
    let json = serde_json::to_string(&list).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Set the active theme by ID.
/// Returns 0 on success, -1 if theme not found.
#[no_mangle]
pub extern "C" fn editor_theme_set(handle: *mut EditorHandle, theme_id: *const c_char) -> c_int {
    if handle.is_null() || theme_id.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let id = match unsafe { CStr::from_ptr(theme_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    let mut bus = h.inner.extensions.bus().lock().unwrap();
    let ok = bus.themes.activate(id);
    if ok {
        let (tid, tname) = bus
            .themes
            .active()
            .map(|t| (t.id.clone(), t.name.clone()))
            .unwrap_or_default();
        drop(bus);
        h.inner.event_bus.emit_theme_changed(&tid, &tname);
        0
    } else {
        -1
    }
}

/// Get the active theme as a JSON object.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_theme_get_active(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let bus = h.inner.extensions.bus().lock().unwrap();
    match bus.themes.active() {
        Some(theme) => {
            let json = serde_json::to_string(theme).unwrap_or_else(|_| "{}".into());
            drop(bus);
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => {
            drop(bus);
            std::ptr::null_mut()
        }
    }
}

// ── Snippets ──────────────────────────────────────────────────────────────────

/// Get all snippets for a language as a JSON array.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_snippets_for_language(
    handle: *const EditorHandle,
    language: *const c_char,
) -> *mut c_char {
    if handle.is_null() || language.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let lang = match unsafe { CStr::from_ptr(language) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let snips = bus.snippets.all_for_language(lang);
    let json = serde_json::to_string(snips).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Find a snippet by prefix and expand it.
/// Returns JSON: {"text":"...","tab_stops":[{"index":1,"start":5,"len":4,"placeholder":"name"},...]}
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_snippet_expand(
    handle: *const EditorHandle,
    language: *const c_char,
    prefix: *const c_char,
) -> *mut c_char {
    if handle.is_null() || language.is_null() || prefix.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let lang = match unsafe { CStr::from_ptr(language) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let pref = match unsafe { CStr::from_ptr(prefix) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let snippet = bus.snippets.find_for_prefix(lang, pref);
    match snippet {
        Some(s) => {
            let expanded = s.expand(&std::collections::HashMap::new());
            let tab_stops: Vec<serde_json::Value> = expanded
                .tab_stops
                .iter()
                .map(|ts| {
                    serde_json::json!({
                        "index": ts.index, "start": ts.start,
                        "len": ts.len, "placeholder": ts.placeholder,
                    })
                })
                .collect();
            let json = serde_json::json!({
                "text": expanded.text,
                "tab_stops": tab_stops,
                "final_cursor": expanded.final_cursor(),
            })
            .to_string();
            drop(bus);
            CString::new(json)
                .map(|cs| cs.into_raw())
                .unwrap_or(std::ptr::null_mut())
        }
        None => {
            drop(bus);
            std::ptr::null_mut()
        }
    }
}

// ── Event bus ─────────────────────────────────────────────────────────────────

/// Poll all pending extension events as a JSON array.
/// Events are NOT consumed — call editor_ext_drain_events to consume.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ext_poll_events(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let events = h.inner.event_bus.poll_events();
    let json = serde_json::to_string(&events).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Drain (consume) all pending extension events as a JSON array.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_ext_drain_events(handle: *mut EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let events = h.inner.event_bus.drain_events();
    let json = serde_json::to_string(&events).unwrap_or_else(|_| "[]".into());
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get pending extension event count.
#[no_mangle]
pub extern "C" fn editor_ext_event_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    unsafe { &*handle }.inner.event_bus.pending_count() as c_ulong
}

/// Manually emit a custom extension event (JSON).
/// `event_json` must be a valid ExtensionEvent-shaped JSON object.
/// Returns 0 on success.
#[no_mangle]
pub extern "C" fn editor_ext_emit_event(
    handle: *mut EditorHandle,
    event_json: *const c_char,
) -> c_int {
    if handle.is_null() || event_json.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let json = match unsafe { CStr::from_ptr(event_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    match serde_json::from_str::<crate::ExtensionEvent>(json) {
        Ok(event) => {
            h.inner.event_bus.emit(event);
            0
        }
        Err(_) => -1,
    }
}

// ── Status bar ────────────────────────────────────────────────────────────────

/// Get all status bar items as a JSON array.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_statusbar_items(handle: *const EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let json = serde_json::to_string(&bus.status_bar).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Update the text of a status bar item.
/// Returns 0 on success, -1 if not found.
#[no_mangle]
pub extern "C" fn editor_statusbar_update(
    handle: *mut EditorHandle,
    item_id: *const c_char,
    text: *const c_char,
) -> c_int {
    if handle.is_null() || item_id.is_null() || text.is_null() {
        return -1;
    }
    let h = unsafe { &mut *handle };
    let id = match unsafe { CStr::from_ptr(item_id) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    let txt = match unsafe { CStr::from_ptr(text) }.to_str() {
        Ok(s) => s,
        Err(_) => return -1,
    };
    let mut bus = h.inner.extensions.bus().lock().unwrap();
    if let Some(item) = bus.status_bar.iter_mut().find(|i| i.id == id) {
        item.text = txt.to_owned();
        0
    } else {
        -1
    }
}

// ── Notifications ─────────────────────────────────────────────────────────────

/// Get all pending notifications as a JSON array.
/// Drains the notification queue.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_notifications_drain(handle: *mut EditorHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let mut bus = h.inner.extensions.bus().lock().unwrap();
    let notifs: Vec<_> = bus.notifications.drain(..).collect();
    let json = serde_json::to_string(&notifs).unwrap_or_else(|_| "[]".into());
    drop(bus);
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

/// Get pending notification count.
#[no_mangle]
pub extern "C" fn editor_notifications_count(handle: *const EditorHandle) -> c_ulong {
    if handle.is_null() {
        return 0;
    }
    let h = unsafe { &*handle };
    let bus = h.inner.extensions.bus().lock().unwrap();
    let n = bus.notifications.len();
    drop(bus);
    n as c_ulong
}

// ── Language detect ────────────────────────────────────────────────────────────

/// Detect the language for a filename and optional first line.
/// Returns language ID string or null if unknown.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_detect_language(
    handle: *const EditorHandle,
    filename: *const c_char,
    first_line: *const c_char,
) -> *mut c_char {
    if handle.is_null() || filename.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let name = match unsafe { CStr::from_ptr(filename) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let first = if first_line.is_null() {
        None
    } else {
        unsafe { CStr::from_ptr(first_line) }.to_str().ok()
    };

    let bus = h.inner.extensions.bus().lock().unwrap();
    // Use our built-in LanguageRegistry
    let reg = crate::LanguageRegistry::new();
    drop(bus);
    match reg.detect(name, first) {
        Some(lang) => CString::new(lang)
            .map(|cs| cs.into_raw())
            .unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

// ── Helper ────────────────────────────────────────────────────────────────────

fn null_result(msg: &str) -> *mut c_char {
    let json = serde_json::json!({"ok":false,"error":msg}).to_string();
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi::c_api::{
        editor_create, editor_create_with_content, editor_destroy, editor_free_str,
        editor_set_language,
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
    fn test_ext_activate_startup() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let active = editor_ext_active_count(h);
        assert!(active > 0, "Startup extensions should be active");
        editor_destroy(h);
    }

    #[test]
    fn test_ext_list() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let ptr = editor_ext_list(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(arr.as_array().unwrap().len() > 0);
        editor_destroy(h);
    }

    #[test]
    fn test_ext_register_from_json() {
        let h = editor_create();
        let manifest = serde_json::json!({
            "id": "test.ext", "name": "Test", "version": "1.0.0",
            "description": "", "author": "", "engine_version": "0.1.0",
            "activation_events": [], "contributes": {
                "commands": [], "keybindings": [], "languages": [],
                "grammars": [], "themes": [], "snippets": [],
                "menus": {}, "status_bar": [],
                "hover_providers": [], "completion_providers": [],
                "diagnostic_providers": [], "code_action_providers": [],
                "formatter_providers": []
            },
            "kind": "Builtin"
        })
        .to_string();
        let json_str = CString::new(manifest).unwrap();
        let id_ptr = editor_ext_register(h, json_str.as_ptr());
        assert!(!id_ptr.is_null());
        let id = get_str(id_ptr);
        assert_eq!(id, "test.ext");
        assert_eq!(editor_ext_count(h), 5); // 4 built-in + 1
        editor_destroy(h);
    }

    #[test]
    fn test_cmd_palette() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let ptr = editor_cmd_palette(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(
            arr.as_array().unwrap().len() > 20,
            "Should have builtins in palette"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_cmd_search() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let q = CString::new("format").unwrap();
        let ptr = editor_cmd_search(h, q.as_ptr());
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        let items = arr.as_array().unwrap();
        assert!(!items.is_empty(), "Should find format commands");
        editor_destroy(h);
    }

    #[test]
    fn test_cmd_execute_builtin() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let id = CString::new("waraq.wordcount.show").unwrap();
        let ptr = editor_cmd_execute(h, id.as_ptr(), std::ptr::null());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["ok"], true);
        editor_destroy(h);
    }

    #[test]
    fn test_cmd_execute_unknown() {
        let h = editor_create();
        let id = CString::new("nonexistent.command").unwrap();
        let ptr = editor_cmd_execute(h, id.as_ptr(), std::ptr::null());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["ok"], false);
        editor_destroy(h);
    }

    #[test]
    fn test_key_resolve() {
        let h = editor_create();
        let key = CString::new("ctrl+s").unwrap();
        let ptr = editor_key_resolve(h, key.as_ptr(), std::ptr::null());
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["command"], "workbench.action.files.save");
        assert_eq!(v["pending"], false);
        editor_destroy(h);
    }

    #[test]
    fn test_key_resolve_multi_chord_pending() {
        let h = editor_create();
        let key1 = CString::new("ctrl+k").unwrap();
        let ptr1 = editor_key_resolve(h, key1.as_ptr(), std::ptr::null());
        let json1 = get_str(ptr1);
        let v1: serde_json::Value = serde_json::from_str(&json1).unwrap();
        assert_eq!(
            v1["pending"], true,
            "ctrl+k should be pending (multi-chord)"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_theme_list() {
        let h = editor_create();
        let ptr = editor_theme_list(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        let themes = arr.as_array().unwrap();
        assert!(themes.iter().any(|t| t["id"] == "waraq.dracula"));
        assert!(themes.iter().any(|t| t["id"] == "waraq.github-light"));
        editor_destroy(h);
    }

    #[test]
    fn test_theme_set_and_get() {
        let h = editor_create();
        let id = CString::new("waraq.github-light").unwrap();
        assert_eq!(editor_theme_set(h, id.as_ptr()), 0);
        let ptr = editor_theme_get_active(h);
        let json = get_str(ptr);
        let v: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert_eq!(v["id"], "waraq.github-light");
        editor_destroy(h);
    }

    #[test]
    fn test_snippets_for_language() {
        let h = editor_create();
        let lang = CString::new("rust").unwrap();
        editor_set_language(h, lang.as_ptr()); // triggers rust-snippets activation
        let ptr = editor_snippets_for_language(h, lang.as_ptr());
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(
            !arr.as_array().unwrap().is_empty(),
            "Should have Rust snippets after language set"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_snippet_expand() {
        let h = editor_create();
        let lang = CString::new("rust").unwrap();
        editor_set_language(h, lang.as_ptr());
        let prefix = CString::new("fn").unwrap();
        let ptr = editor_snippet_expand(h, lang.as_ptr(), prefix.as_ptr());
        let json = get_str(ptr);
        if !json.is_empty() {
            let v: serde_json::Value = serde_json::from_str(&json).unwrap();
            assert!(!v["text"].as_str().unwrap().is_empty());
        }
        editor_destroy(h);
    }

    #[test]
    fn test_ext_events_emitted_on_text_change() {
        let h = editor_create_with_content(CString::new("hello").unwrap().as_ptr());
        let initial = editor_ext_event_count(h);
        // Insert text — should emit a textChanged event
        crate::ffi::c_api::editor_insert(h, 5, CString::new(" world").unwrap().as_ptr());
        // Event should have been emitted
        let after = editor_ext_event_count(h);
        assert!(after > initial, "Text change should emit event");
        editor_destroy(h);
    }

    #[test]
    fn test_ext_drain_events() {
        let h = editor_create();
        crate::ffi::c_api::editor_insert(h, 0, CString::new("hello").unwrap().as_ptr());
        assert!(editor_ext_event_count(h) > 0);
        let ptr = editor_ext_drain_events(h);
        let _ = get_str(ptr);
        assert_eq!(
            editor_ext_event_count(h),
            0,
            "Events should be consumed after drain"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_statusbar_items_after_startup() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let ptr = editor_statusbar_items(h);
        let json = get_str(ptr);
        let arr: serde_json::Value = serde_json::from_str(&json).unwrap();
        assert!(
            !arr.as_array().unwrap().is_empty(),
            "Wordcount should add a status bar item"
        );
        editor_destroy(h);
    }

    #[test]
    fn test_statusbar_update() {
        let h = editor_create();
        editor_ext_activate_startup(h);
        let id = CString::new("waraq.wordcount.status").unwrap();
        let text = CString::new("42 words").unwrap();
        assert_eq!(editor_statusbar_update(h, id.as_ptr(), text.as_ptr()), 0);
        editor_destroy(h);
    }

    #[test]
    fn test_notifications_drain() {
        let h = editor_create();
        editor_ext_activate_startup(h); // bracket-coloriser shows a notification
        let _count_before = editor_notifications_count(h);
        let ptr = editor_notifications_drain(h);
        let _ = get_str(ptr);
        assert_eq!(editor_notifications_count(h), 0);
        editor_destroy(h);
    }

    #[test]
    fn test_detect_language_by_extension() {
        let h = editor_create();
        let file = CString::new("main.rs").unwrap();
        let ptr = editor_detect_language(h, file.as_ptr(), std::ptr::null());
        let lang = get_str(ptr);
        assert_eq!(lang, "rust");
        editor_destroy(h);
    }

    #[test]
    fn test_null_safety_ext_api() {
        assert!(editor_ext_list(std::ptr::null()).is_null());
        assert_eq!(
            editor_ext_activate(std::ptr::null_mut(), std::ptr::null()),
            -1
        );
        assert_eq!(editor_ext_state(std::ptr::null(), std::ptr::null()), -1);
        assert!(editor_cmd_palette(std::ptr::null()).is_null());
        assert_eq!(editor_ext_event_count(std::ptr::null()), 0);
        assert_eq!(editor_notifications_count(std::ptr::null()), 0);
    }
}
