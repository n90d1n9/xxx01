// src/ffi/json_bridge.rs
//
// JSON batch protocol — one JSON array in, one JSON object out.
// All editor operations available through this single endpoint,
// reducing FFI overhead from N calls to 1 call per frame.
//
// Command reference:
//   Text:      insert, delete, replace, undo, redo
//   Cursor:    cursor_move, cursor_add, cursor_collapse
//   Viewport:  scroll_by, set_viewport_height, ensure_line_visible
//   Motion:    motion (code 0-16), move_up, move_down
//   Selection: select_word, select_line, select_all, expand_selection,
//              add_cursor_next_occurrence
//   Key input: type_char, key_backspace, key_delete, key_enter, key_tab,
//              key_shift_tab
//   Search:    search_start, search_next, search_prev, search_clear,
//              replace_current, replace_all_matches
//   Folds:     toggle_fold, fold_all, unfold_all
//   Language:  set_language, set_file_uri
//   Config:    set_config_value
//   Render:    render_frame

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

use serde::{Deserialize, Serialize};

use super::c_api::EditorHandle;
use crate::core::edit::EditOp;
use crate::core::search::SearchQuery;
use crate::{Editor, KeyInput, MotionKind};

#[derive(Debug, Deserialize)]
#[serde(tag = "cmd", rename_all = "snake_case")]
enum Command {
    // Text mutations
    Insert {
        at: usize,
        text: String,
    },
    Delete {
        start: usize,
        end: usize,
    },
    Replace {
        start: usize,
        end: usize,
        text: String,
    },
    Undo,
    Redo,
    // Cursor
    CursorMove {
        pos: usize,
        #[serde(default)]
        extend: bool,
    },
    CursorAdd {
        pos: usize,
    },
    CursorCollapse,
    // Viewport
    ScrollBy {
        delta: i64,
    },
    SetViewportHeight {
        height: usize,
    },
    EnsureLineVisible {
        line: usize,
    },
    // Motion
    Motion {
        code: u32,
        #[serde(default)]
        extend: bool,
    },
    MoveUp {
        #[serde(default = "one")]
        lines: usize,
        #[serde(default)]
        extend: bool,
    },
    MoveDown {
        #[serde(default = "one")]
        lines: usize,
        #[serde(default)]
        extend: bool,
    },
    // Selection
    SelectWord,
    SelectLine,
    SelectAll,
    ExpandSelection,
    AddCursorNextOccurrence,
    // Key input
    TypeChar {
        codepoint: u32,
    },
    KeyBackspace,
    KeyDelete,
    KeyEnter,
    KeyTab,
    KeyShiftTab,
    // Search
    SearchStart {
        pattern: String,
        #[serde(default)]
        flags: u32,
    },
    SearchNext,
    SearchPrev,
    SearchClear,
    ReplaceCurrent {
        replacement: String,
    },
    ReplaceAllMatches {
        replacement: String,
    },
    // Folds
    ToggleFold {
        line: usize,
    },
    FoldAll,
    UnfoldAll,
    // Language / file
    SetLanguage {
        language: String,
    },
    SetFileUri {
        file_uri: String,
    },
    // Config
    SetConfigValue {
        key: String,
        value: String,
    },
    // Clipboard
    Copy,
    Cut,
    CyclePaste,
    // Formatting
    FormatDocument,
    FormatOnSave,
    SortImports,
    // Macro
    MacroStart {
        register: String,
    },
    MacroStop,
    MacroPlay {
        register: String,
        #[serde(default = "one")]
        count: usize,
    },
    // Extensions
    ExtCmdExecute {
        command: String,
        #[serde(default)]
        args: serde_json::Value,
    },
    ThemeSet {
        theme_id: String,
    },
    SnippetExpand {
        prefix: String,
    },
    ExtActivateStartup,
    // Decoration
    DeltaDecorations {
        #[serde(default)]
        remove_ids: Vec<u64>,
        #[serde(default)]
        add_specs: Vec<serde_json::Value>,
    },
    ClearDecorations {
        owner: String,
    },
    // TextModel
    ExecuteEdits {
        edits: Vec<serde_json::Value>,
    },
    // Render
    RenderFrame,
}

fn one() -> usize {
    1
}

#[derive(Debug, Serialize)]
struct SearchMatchInfo {
    start: usize,
    end: usize,
    index: usize,
    total: usize,
}

#[derive(Debug, Serialize)]
struct BatchResponse {
    ok: bool,
    frame: Option<crate::RenderFrame>,
    search: Option<SearchMatchInfo>,
    ext_result: Option<serde_json::Value>,
    errors: Vec<String>,
    ops_applied: usize,
}

/// Process a JSON batch of commands against an editor handle.
/// Returns a JSON response string.
/// CALLER MUST call `editor_free_str` on the returned pointer.
#[no_mangle]
pub extern "C" fn editor_batch(
    handle: *mut EditorHandle,
    commands_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || commands_json.is_null() {
        return err_response("null handle or commands");
    }
    let json_str = match unsafe { CStr::from_ptr(commands_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return err_response("commands_json is not valid UTF-8"),
    };
    let h = unsafe { &mut *handle };
    let result = process_batch_internal(&mut h.inner, json_str);
    CString::new(result)
        .map(|cs| cs.into_raw())
        .unwrap_or_else(|_| err_response("CString conversion failed"))
}

/// Internal batch processor shared with the WASM layer.
pub fn process_batch_internal(editor: &mut Editor, commands_json: &str) -> String {
    let commands: Vec<Command> = match serde_json::from_str(commands_json) {
        Ok(v) => v,
        Err(e) => {
            return format!(
                r#"{{"ok":false,"frame":null,"search":null,"errors":["{}"],"ops_applied":0}}"#,
                e.to_string().replace('"', "'")
            )
        }
    };

    let mut errors: Vec<String> = Vec::new();
    let mut ops_applied = 0usize;
    let mut last_frame = None;
    let mut last_search = None;
    let mut last_ext_result: Option<serde_json::Value> = None;

    for cmd in commands {
        match cmd {
            // ── Text ──────────────────────────────────────────────────────────
            Command::Insert { at, text } => {
                let len = editor.buffer.len_bytes();
                editor.apply(EditOp::insert(at.min(len), text));
                ops_applied += 1;
            }
            Command::Delete { start, end } => {
                let len = editor.buffer.len_bytes();
                let s = start.min(len);
                let e = end.min(len);
                if s < e {
                    editor.apply(EditOp::delete(s, e));
                    ops_applied += 1;
                }
            }
            Command::Replace { start, end, text } => {
                let len = editor.buffer.len_bytes();
                let s = start.min(len);
                let e = end.min(len);
                editor.apply(EditOp::replace(s, e, text));
                ops_applied += 1;
            }
            Command::Undo => {
                editor.undo();
                ops_applied += 1;
            }
            Command::Redo => {
                editor.redo();
                ops_applied += 1;
            }

            // ── Cursor ────────────────────────────────────────────────────────
            Command::CursorMove { pos, extend } => {
                editor.cursors.move_to(pos, extend);
            }
            Command::CursorAdd { pos } => {
                editor.cursors.add(pos);
            }
            Command::CursorCollapse => {
                editor.cursors.collapse_to_primary();
            }

            // ── Viewport ──────────────────────────────────────────────────────
            Command::ScrollBy { delta } => {
                let total = editor.buffer.len_lines();
                editor.viewport.scroll_by(delta, total);
            }
            Command::SetViewportHeight { height } => {
                editor.viewport.set_height(height);
            }
            Command::EnsureLineVisible { line } => {
                let total = editor.buffer.len_lines();
                editor.viewport.ensure_cursor_visible(line, total);
            }

            // ── Motion ────────────────────────────────────────────────────────
            Command::Motion { code, extend } => {
                let height = editor.viewport.height();
                let mk = motion_from_code(code, height);
                if let Some(m) = mk {
                    editor.handle_key(if extend {
                        KeyInput::Select(m)
                    } else {
                        KeyInput::Motion(m)
                    });
                } else {
                    errors.push(format!("unknown motion code {}", code));
                }
            }
            Command::MoveUp { lines, extend } => {
                editor.handle_key(if extend {
                    KeyInput::Select(MotionKind::LineUp(lines))
                } else {
                    KeyInput::Motion(MotionKind::LineUp(lines))
                });
            }
            Command::MoveDown { lines, extend } => {
                editor.handle_key(if extend {
                    KeyInput::Select(MotionKind::LineDown(lines))
                } else {
                    KeyInput::Motion(MotionKind::LineDown(lines))
                });
            }

            // ── Selection ─────────────────────────────────────────────────────
            Command::SelectWord => {
                editor.select_word_at_cursor();
            }
            Command::SelectLine => {
                editor.select_line_at_cursor();
            }
            Command::SelectAll => {
                editor.select_all();
            }
            Command::ExpandSelection => {
                editor.expand_selection();
            }
            Command::AddCursorNextOccurrence => {
                editor.add_cursor_at_next_occurrence();
            }

            // ── Key input ─────────────────────────────────────────────────────
            Command::TypeChar { codepoint } => {
                if let Some(ch) = char::from_u32(codepoint) {
                    editor.handle_key(KeyInput::Char(ch));
                    ops_applied += 1;
                } else {
                    errors.push(format!("invalid codepoint {}", codepoint));
                }
            }
            Command::KeyBackspace => {
                editor.handle_key(KeyInput::Backspace);
                ops_applied += 1;
            }
            Command::KeyDelete => {
                editor.handle_key(KeyInput::Delete);
                ops_applied += 1;
            }
            Command::KeyEnter => {
                editor.handle_key(KeyInput::Enter);
                ops_applied += 1;
            }
            Command::KeyTab => {
                editor.handle_key(KeyInput::Tab);
            }
            Command::KeyShiftTab => {
                editor.handle_key(KeyInput::ShiftTab);
            }

            // ── Search ────────────────────────────────────────────────────────
            Command::SearchStart { pattern, flags } => {
                let query = SearchQuery {
                    pattern,
                    case_sensitive: flags & 0x01 != 0,
                    whole_word: flags & 0x02 != 0,
                    regex: flags & 0x04 != 0,
                    wrap_around: true,
                };
                if let Some(m) = editor.search_start(query) {
                    last_search = Some(SearchMatchInfo {
                        start: m.start.0,
                        end: m.end.0,
                        index: m.index,
                        total: m.total,
                    });
                }
            }
            Command::SearchNext => {
                if let Some(m) = editor.search_next() {
                    last_search = Some(SearchMatchInfo {
                        start: m.start.0,
                        end: m.end.0,
                        index: m.index,
                        total: m.total,
                    });
                }
            }
            Command::SearchPrev => {
                if let Some(m) = editor.search_prev() {
                    last_search = Some(SearchMatchInfo {
                        start: m.start.0,
                        end: m.end.0,
                        index: m.index,
                        total: m.total,
                    });
                }
            }
            Command::SearchClear => {
                editor.search_clear();
            }
            Command::ReplaceCurrent { replacement } => {
                if editor.replace_current(&replacement).is_some() {
                    ops_applied += 1;
                }
            }
            Command::ReplaceAllMatches { replacement } => {
                let n = editor.replace_all_matches(&replacement).len();
                ops_applied += n;
            }

            // ── Folds ─────────────────────────────────────────────────────────
            Command::ToggleFold { line } => {
                editor.toggle_fold(line);
            }
            Command::FoldAll => {
                editor.fold_all();
            }
            Command::UnfoldAll => {
                editor.unfold_all();
            }

            // ── Language / file ────────────────────────────────────────────────
            Command::SetLanguage { language } => {
                editor.set_language(&language);
            }
            Command::SetFileUri { file_uri } => {
                editor.file_uri = file_uri;
            }

            // ── Config ────────────────────────────────────────────────────────
            Command::SetConfigValue { key, value } => {
                apply_config_value(editor, &key, &value);
            }

            // ── Clipboard ────────────────────────────────────────────────────
            Command::Copy => {
                editor.copy();
            }
            Command::Cut => {
                let r = editor.cut();
                ops_applied += r.len();
            }
            Command::CyclePaste => {
                let r = editor.cycle_paste();
                ops_applied += r.len();
            }

            // ── Formatting ───────────────────────────────────────────────────
            Command::FormatDocument => {
                let result = editor.format_document(None);
                if result.has_changes {
                    ops_applied += editor.apply_batch(result.ops).len();
                }
            }
            Command::FormatOnSave => {
                let result = editor.format_on_save();
                if result.has_changes {
                    ops_applied += editor.apply_batch(result.ops).len();
                }
            }
            Command::SortImports => {
                let lang = editor.language.clone();
                let result = crate::core::format::sort_imports(&editor.buffer, &lang);
                if result.has_changes {
                    ops_applied += editor.apply_batch(result.ops).len();
                }
            }

            // ── Macros ───────────────────────────────────────────────────────
            Command::MacroStart { register } => {
                let _ = editor.macro_start(register.chars().next().unwrap_or('"'));
            }
            Command::MacroStop => {
                let _ = editor.macro_stop();
            }
            Command::MacroPlay { register, count } => {
                let reg = register.chars().next().unwrap_or('"');
                ops_applied += editor.macro_play(reg, count).len();
            }

            // ── Extensions ───────────────────────────────────────────────────
            Command::ExtActivateStartup => {
                editor.extensions.activate_startup();
            }
            Command::ExtCmdExecute { command, args } => {
                editor.extensions.activate_for_command(&command);
                let bus_handle = editor.extensions.bus();
                let mut bus = bus_handle.lock().unwrap();
                let result = bus.commands.execute(&command, args);
                drop(bus);
                last_ext_result = Some(match result {
                    crate::CommandResult::Ok(v) => serde_json::json!({"ok":true,"value":v}),
                    crate::CommandResult::NoResult => serde_json::json!({"ok":true,"value":null}),
                    crate::CommandResult::Err(e) => serde_json::json!({"ok":false,"error":e}),
                });
            }
            Command::ThemeSet { theme_id } => {
                let bus_handle = editor.extensions.bus();
                let mut bus = bus_handle.lock().unwrap();
                let ok = bus.themes.activate(&theme_id);
                if ok {
                    let (tid, tn) = bus
                        .themes
                        .active()
                        .map(|t| (t.id.clone(), t.name.clone()))
                        .unwrap_or_default();
                    drop(bus);
                    editor.event_bus.emit_theme_changed(&tid, &tn);
                }
            }
            Command::SnippetExpand { prefix } => {
                let lang = editor.language.clone();
                let bus_handle = editor.extensions.bus();
                let bus = bus_handle.lock().unwrap();
                if let Some(sn) = bus.snippets.find_for_prefix(&lang, &prefix) {
                    let expanded = sn.expand(&std::collections::HashMap::new());
                    drop(bus);
                    let pos = editor.cursors.primary().pos.0;
                    let op = crate::core::edit::EditOp::insert(pos, &expanded.text);
                    editor.apply(op);
                    ops_applied += 1;
                    last_ext_result = Some(serde_json::json!({
                        "text": expanded.text,
                        "final_cursor": expanded.final_cursor(),
                    }));
                }
            }

            // ── Decorations ──────────────────────────────────────────────────
            Command::ClearDecorations { owner } => {
                editor.clear_decorations_by_owner(&owner);
            }
            Command::DeltaDecorations {
                remove_ids,
                add_specs,
            } => {
                let specs: Vec<(crate::DecorationSpec, String)> = add_specs
                    .into_iter()
                    .filter_map(|v| {
                        let start = v["range"]["start"].as_u64()? as usize;
                        let end = v["range"]["end"].as_u64()? as usize;
                        let owner = v["owner"].as_str().unwrap_or("batch").to_owned();
                        let opts = serde_json::from_value::<crate::DecorationOptions>(
                            v["options"].clone(),
                        )
                        .unwrap_or_default();
                        Some((
                            crate::DecorationSpec {
                                range: crate::core::types::Range::new(start, end),
                                options: opts,
                            },
                            owner,
                        ))
                    })
                    .collect();
                let new_ids = editor.delta_decorations(&remove_ids, &specs);
                last_ext_result = Some(serde_json::to_value(new_ids).unwrap_or_default());
            }

            // ── TextModel ────────────────────────────────────────────────────
            Command::ExecuteEdits { edits } => {
                let edit_ops: Vec<crate::SingleEditOperation> = edits
                    .into_iter()
                    .filter_map(|v| {
                        let sln = v["range"]["startLineNumber"].as_u64()? as u32;
                        let sc = v["range"]["startColumn"].as_u64()? as u32;
                        let eln = v["range"]["endLineNumber"].as_u64()? as u32;
                        let ec = v["range"]["endColumn"].as_u64()? as u32;
                        let range = crate::MonacoRange::new(sln, sc, eln, ec);
                        let text = v["text"].as_str().map(|s| s.to_owned());
                        Some(crate::SingleEditOperation {
                            range,
                            text,
                            force_move_markers: false,
                        })
                    })
                    .collect();
                ops_applied += editor.execute_edits(&edit_ops).len();
            }

            // ── Render ───────────────────────────────────────────────────────
            Command::RenderFrame => {
                last_frame = Some(editor.render_frame());
            }
        }
    }

    let response = BatchResponse {
        ok: errors.is_empty(),
        frame: last_frame,
        search: last_search,
        ext_result: last_ext_result,
        errors,
        ops_applied,
    };
    serde_json::to_string(&response).unwrap_or_else(|_| r#"{"ok":false}"#.into())
}

fn motion_from_code(code: u32, height: usize) -> Option<MotionKind> {
    Some(match code {
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
        _ => return None,
    })
}

fn apply_config_value(editor: &mut Editor, key: &str, value: &str) {
    match key {
        "tab_width" => {
            if let Ok(n) = value.parse::<u32>() {
                editor.config.tab_width = n;
            }
        }
        "indent_width" => {
            if let Ok(n) = value.parse::<u32>() {
                editor.config.indent_width = n;
            }
        }
        "indent_style" => {
            editor.config.indent_style = match value {
                "tabs" => crate::IndentStyle::Tabs,
                "spaces" => crate::IndentStyle::Spaces,
                _ => return,
            };
        }
        "line_ending" => {
            editor.config.line_ending = match value {
                "lf" => crate::LineEnding::Lf,
                "crlf" => crate::LineEnding::CrLf,
                _ => return,
            };
        }
        "auto_close_brackets" => {
            editor.config.auto_close_brackets = value == "true";
        }
        "ai_inline_completion" => {
            editor.config.ai_inline_completion = value == "true";
        }
        "ai_debounce_ms" => {
            if let Ok(n) = value.parse::<u64>() {
                editor.config.ai_debounce_ms = n;
            }
        }
        _ => {}
    }
}

/// Public alias used by the WASM layer.
pub fn apply_config_value_wasm(editor: &mut Editor, key: &str, value: &str) {
    apply_config_value(editor, key, value);
}

fn err_response(msg: &str) -> *mut std::os::raw::c_char {
    let json = format!(
        r#"{{"ok":false,"frame":null,"search":null,"errors":["{}"],"ops_applied":0}}"#,
        msg
    );
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ffi::c_api::{
        editor_create, editor_create_with_content, editor_cursor_pos, editor_destroy,
        editor_free_str, editor_get_text,
    };
    use std::ffi::CString;

    fn batch(h: *mut EditorHandle, json: &str) -> serde_json::Value {
        let cmd = CString::new(json).unwrap();
        let ptr = editor_batch(h, cmd.as_ptr());
        let s = unsafe { std::ffi::CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
        editor_free_str(ptr);
        serde_json::from_str(&s).unwrap()
    }

    fn get_text(h: *mut EditorHandle) -> String {
        let p = editor_get_text(h);
        let s = unsafe { std::ffi::CStr::from_ptr(p).to_str().unwrap().to_owned() };
        editor_free_str(p);
        s
    }

    #[test]
    fn test_insert_render() {
        let h = editor_create();
        let v = batch(
            h,
            r#"[{"cmd":"insert","at":0,"text":"hello"},{"cmd":"render_frame"}]"#,
        );
        assert_eq!(v["ok"], true);
        assert_eq!(v["ops_applied"], 1);
        assert_eq!(v["frame"]["lines"][0]["text"], "hello");
        editor_destroy(h);
    }

    #[test]
    fn test_undo_redo() {
        let h = editor_create();
        batch(h, r#"[{"cmd":"insert","at":0,"text":"hello"}]"#);
        batch(h, r#"[{"cmd":"undo"}]"#);
        assert_eq!(get_text(h), "");
        batch(h, r#"[{"cmd":"redo"}]"#);
        assert_eq!(get_text(h), "hello");
        editor_destroy(h);
    }

    #[test]
    fn test_type_char_sequence() {
        let h = editor_create();
        let v = batch(
            h,
            r#"[
            {"cmd":"type_char","codepoint":104},
            {"cmd":"type_char","codepoint":105}
        ]"#,
        );
        assert_eq!(v["ops_applied"], 2);
        assert_eq!(get_text(h), "hi");
        editor_destroy(h);
    }

    #[test]
    fn test_key_backspace() {
        let h = editor_create_with_content(CString::new("hello").unwrap().as_ptr());
        batch(
            h,
            r#"[{"cmd":"cursor_move","pos":5},{"cmd":"key_backspace"}]"#,
        );
        assert_eq!(get_text(h), "hell");
        editor_destroy(h);
    }

    #[test]
    fn test_key_enter_indent() {
        let h = editor_create_with_content(CString::new("fn main() {").unwrap().as_ptr());
        let lang = CString::new("rust").unwrap();
        crate::ffi::c_api::editor_set_language(h, lang.as_ptr());
        batch(h, r#"[{"cmd":"cursor_move","pos":11},{"cmd":"key_enter"}]"#);
        let text = get_text(h);
        assert!(text.contains('\n'), "Should have newline");
        editor_destroy(h);
    }

    #[test]
    fn test_motion_word_right() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        batch(
            h,
            r#"[{"cmd":"cursor_move","pos":0},{"cmd":"motion","code":3}]"#,
        );
        let pos = editor_cursor_pos(h);
        assert!(pos > 0 && pos <= 6);
        editor_destroy(h);
    }

    #[test]
    fn test_motion_document_end() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        batch(h, r#"[{"cmd":"motion","code":16}]"#);
        assert_eq!(editor_cursor_pos(h), 11);
        editor_destroy(h);
    }

    #[test]
    fn test_select_word() {
        let h = editor_create_with_content(CString::new("hello world").unwrap().as_ptr());
        batch(
            h,
            r#"[{"cmd":"cursor_move","pos":7},{"cmd":"select_word"}]"#,
        );
        let v = batch(h, r#"[{"cmd":"render_frame"}]"#);
        let sels = v["frame"]["selections"].as_array().unwrap();
        assert!(!sels.is_empty());
        editor_destroy(h);
    }

    #[test]
    fn test_search_start_next_prev() {
        let h = editor_create_with_content(CString::new("foo bar foo baz foo").unwrap().as_ptr());
        let v = batch(h, r#"[{"cmd":"search_start","pattern":"foo","flags":1}]"#);
        assert_eq!(v["search"]["total"], 3);
        assert_eq!(v["search"]["index"], 0);

        let v2 = batch(h, r#"[{"cmd":"search_next"}]"#);
        assert_eq!(v2["search"]["index"], 1);
        assert_eq!(v2["search"]["start"], 8);

        let v3 = batch(h, r#"[{"cmd":"search_prev"}]"#);
        assert_eq!(v3["search"]["index"], 0);
        assert_eq!(v3["search"]["start"], 0);

        editor_destroy(h);
    }

    #[test]
    fn test_replace_current_batch() {
        let h = editor_create_with_content(CString::new("foo bar foo").unwrap().as_ptr());
        batch(h, r#"[{"cmd":"search_start","pattern":"foo","flags":1}]"#);
        batch(h, r#"[{"cmd":"replace_current","replacement":"qux"}]"#);
        assert!(get_text(h).starts_with("qux"));
        editor_destroy(h);
    }

    #[test]
    fn test_replace_all_matches_batch() {
        let h = editor_create_with_content(CString::new("foo bar foo baz foo").unwrap().as_ptr());
        batch(h, r#"[{"cmd":"search_start","pattern":"foo","flags":1}]"#);
        let v = batch(h, r#"[{"cmd":"replace_all_matches","replacement":"X"}]"#);
        assert_eq!(v["ops_applied"], 3);
        assert!(!get_text(h).contains("foo"));
        editor_destroy(h);
    }

    #[test]
    fn test_fold_commands() {
        let h = editor_create_with_content(
            CString::new("fn foo() {\n    let x = 1;\n}\n")
                .unwrap()
                .as_ptr(),
        );
        let lang = CString::new("rust").unwrap();
        crate::ffi::c_api::editor_set_language(h, lang.as_ptr());
        let v = batch(h, r#"[{"cmd":"fold_all"},{"cmd":"render_frame"}]"#);
        assert_eq!(v["ok"], true);
        let v2 = batch(h, r#"[{"cmd":"unfold_all"},{"cmd":"render_frame"}]"#);
        assert_eq!(v2["ok"], true);
        editor_destroy(h);
    }

    #[test]
    fn test_set_config_value_batch() {
        let h = editor_create();
        let v = batch(
            h,
            r#"[{"cmd":"set_config_value","key":"tab_width","value":"2"}]"#,
        );
        assert_eq!(v["ok"], true);
        editor_destroy(h);
    }

    #[test]
    fn test_set_language_batch() {
        let h = editor_create_with_content(CString::new("def foo(): pass").unwrap().as_ptr());
        let v = batch(
            h,
            r#"[{"cmd":"set_language","language":"python"},{"cmd":"render_frame"}]"#,
        );
        assert_eq!(v["ok"], true);
        assert_eq!(v["frame"]["language"], "python");
        editor_destroy(h);
    }

    #[test]
    fn test_move_up_down_batch() {
        let h = editor_create_with_content(CString::new("line1\nline2\nline3\n").unwrap().as_ptr());
        batch(h, r#"[{"cmd":"motion","code":16}]"#); // doc end
        let v = batch(h, r#"[{"cmd":"move_up","lines":2}]"#);
        assert_eq!(v["ok"], true);
        editor_destroy(h);
    }

    #[test]
    fn test_batch_invalid_command() {
        let h = editor_create();
        let v = batch(h, r#"[{"cmd":"nonexistent_command"}]"#);
        assert_eq!(v["ok"], false);
        editor_destroy(h);
    }

    #[test]
    fn test_render_frame_new_fields() {
        let h = editor_create_with_content(
            CString::new("fn main() {\n    let x = 1;\n}\n")
                .unwrap()
                .as_ptr(),
        );
        let lang = CString::new("rust").unwrap();
        crate::ffi::c_api::editor_set_language(h, lang.as_ptr());
        let v = batch(
            h,
            r#"[{"cmd":"search_start","pattern":"let","flags":1},{"cmd":"render_frame"}]"#,
        );
        let frame = &v["frame"];
        assert!(frame["lines"].is_array());
        assert!(frame["cursors"].is_array());
        assert!(frame["selections"].is_array());
        assert!(frame["tokens"].is_array());
        assert!(frame["folds"].is_array());
        assert!(frame["diagnostics"].is_array());
        assert!(frame["search_matches"].is_array());
        assert!(frame["total_lines"].as_u64().unwrap() >= 3);
        assert!(frame["language"] == "rust");
        // search_matches should contain the "let" match
        let matches = frame["search_matches"].as_array().unwrap();
        assert!(!matches.is_empty());
        assert!(matches[0]["is_current"].as_bool().unwrap());
        editor_destroy(h);
    }
}
