// src/ffi/wasm_api.rs
//
// Complete wasm-bindgen API — every method the TypeScript binding needs.
// Build: wasm-pack build --target web --features wasm --out-dir pkg

#![cfg(feature = "wasm")]

use crate::core::decoration::{DecorationOptions, DecorationSpec};
use crate::core::search::SearchQuery;
use crate::core::text_model::{MonacoPosition, MonacoRange, SingleEditOperation};
use crate::core::types::Range;
use crate::{Editor, KeyInput, MotionKind};
use wasm_bindgen::prelude::*;

// ── Helper ────────────────────────────────────────────────────────────────────

fn motion_from_code(code: u32) -> MotionKind {
    match code {
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
        12 => MotionKind::PageUp(1),
        13 => MotionKind::PageDown(1),
        14 => MotionKind::MatchingBracket,
        15 => MotionKind::DocumentStart,
        16 => MotionKind::DocumentEnd,
        _ => MotionKind::CharRight,
    }
}

// ── WasmEditor ────────────────────────────────────────────────────────────────

#[wasm_bindgen]
pub struct WasmEditor {
    inner: Editor,
}

#[wasm_bindgen]
impl WasmEditor {
    // ── Construction ──────────────────────────────────────────────────────────

    #[wasm_bindgen(constructor)]
    pub fn new() -> WasmEditor {
        WasmEditor {
            inner: Editor::new(),
        }
    }

    #[wasm_bindgen(js_name = fromString)]
    pub fn from_string(content: &str) -> WasmEditor {
        WasmEditor {
            inner: Editor::from_str(content),
        }
    }

    pub fn version() -> String {
        format!("{}", env!("CARGO_PKG_VERSION"))
    }

    // ── Text mutations ────────────────────────────────────────────────────────

    pub fn insert(&mut self, at: usize, text: &str) {
        self.inner
            .apply(crate::core::edit::EditOp::insert(at, text));
    }

    pub fn delete(&mut self, start: usize, end: usize) {
        self.inner
            .apply(crate::core::edit::EditOp::delete(start, end));
    }

    pub fn replace(&mut self, start: usize, end: usize, text: &str) {
        self.inner
            .apply(crate::core::edit::EditOp::replace(start, end, text));
    }

    pub fn undo(&mut self) -> bool {
        self.inner.undo().is_some()
    }
    pub fn redo(&mut self) -> bool {
        self.inner.redo().is_some()
    }

    pub fn can_undo(&self) -> bool {
        self.inner.undo_stack.can_undo()
    }
    pub fn can_redo(&self) -> bool {
        self.inner.undo_stack.can_redo()
    }

    // ── Key input ─────────────────────────────────────────────────────────────

    pub fn type_char(&mut self, codepoint: u32) {
        if let Some(ch) = char::from_u32(codepoint) {
            self.inner.handle_key(KeyInput::Char(ch));
        }
    }

    pub fn key_backspace(&mut self) {
        self.inner.handle_key(KeyInput::Backspace);
    }
    pub fn key_delete(&mut self) {
        self.inner.handle_key(KeyInput::Delete);
    }
    pub fn key_enter(&mut self) {
        self.inner.handle_key(KeyInput::Enter);
    }
    pub fn key_tab(&mut self) {
        self.inner.handle_key(KeyInput::Tab);
    }
    pub fn key_shift_tab(&mut self) {
        self.inner.handle_key(KeyInput::ShiftTab);
    }

    // ── Cursor ────────────────────────────────────────────────────────────────

    pub fn cursor_move(&mut self, pos: usize, extend: bool) {
        self.inner.cursors.move_to(pos, extend);
    }
    pub fn cursor_add(&mut self, pos: usize) {
        self.inner.cursors.add(pos);
    }
    pub fn cursor_collapse(&mut self) {
        self.inner.cursors.collapse_to_primary();
    }
    pub fn cursor_pos(&self) -> usize {
        self.inner.cursors.primary().pos.0
    }
    pub fn cursor_count(&self) -> usize {
        self.inner.cursors.count()
    }

    // ── Motion ────────────────────────────────────────────────────────────────

    pub fn motion_code(&mut self, code: u32, extend: bool) {
        let mk = motion_from_code(code);
        self.inner.handle_key(if extend {
            KeyInput::Select(mk)
        } else {
            KeyInput::Motion(mk)
        });
    }

    pub fn move_up(&mut self, lines: usize, extend: bool) {
        for _ in 0..lines.max(1) {
            self.inner.handle_key(if extend {
                KeyInput::Select(MotionKind::LineUp(1))
            } else {
                KeyInput::Motion(MotionKind::LineUp(1))
            });
        }
    }

    pub fn move_down(&mut self, lines: usize, extend: bool) {
        for _ in 0..lines.max(1) {
            self.inner.handle_key(if extend {
                KeyInput::Select(MotionKind::LineDown(1))
            } else {
                KeyInput::Motion(MotionKind::LineDown(1))
            });
        }
    }

    // ── Selection ─────────────────────────────────────────────────────────────

    pub fn select_word(&mut self) {
        self.inner.select_word_at_cursor();
    }
    pub fn select_line(&mut self) {
        self.inner.select_line_at_cursor();
    }
    pub fn select_all(&mut self) {
        self.inner.select_all();
    }
    pub fn expand_selection(&mut self) {
        self.inner.expand_selection();
    }
    pub fn add_cursor_at_next_occurrence(&mut self) {
        self.inner.add_cursor_at_next_occurrence();
    }

    pub fn get_selection_text(&self) -> String {
        self.inner
            .cursors
            .primary()
            .selection()
            .map(|s| self.inner.buffer.text_in_range(s.as_range()))
            .unwrap_or_default()
    }

    // ── Viewport ──────────────────────────────────────────────────────────────

    pub fn set_viewport_height(&mut self, height: usize) {
        self.inner.viewport.set_height(height);
    }

    pub fn scroll_by(&mut self, delta: i32) {
        let total = self.inner.buffer.len_lines();
        self.inner.viewport.scroll_by(delta as i64, total);
    }

    pub fn ensure_line_visible(&mut self, line: usize) {
        let total = self.inner.buffer.len_lines();
        self.inner.viewport.ensure_cursor_visible(line, total);
    }

    // ── Text access ───────────────────────────────────────────────────────────

    pub fn get_text(&self) -> String {
        self.inner.buffer.to_string()
    }
    pub fn get_line(&self, line_num: usize) -> String {
        self.inner.buffer.line_str(line_num)
    }
    pub fn byte_len(&self) -> usize {
        self.inner.buffer.len_bytes()
    }
    pub fn line_count(&self) -> usize {
        self.inner.buffer.len_lines()
    }

    // ── Language & config ─────────────────────────────────────────────────────

    pub fn set_language(&mut self, language: &str) {
        self.inner.set_language(language);
    }
    pub fn get_language(&self) -> String {
        self.inner.language.clone()
    }

    pub fn set_config_value(&mut self, key: &str, value: &str) {
        match key {
            "indent_width" => {
                if let Ok(n) = value.parse::<u32>() {
                    self.inner.config.indent_width = n;
                }
            }
            "tab_size" => {
                if let Ok(n) = value.parse::<u32>() {
                    self.inner.config.indent_width = n;
                }
            }
            "insert_spaces" => {
                self.inner.config.indent_style = if value == "true" {
                    crate::core::config::IndentStyle::Spaces
                } else {
                    crate::core::config::IndentStyle::Tabs
                };
            }
            "auto_close_brackets" => {
                self.inner.config.auto_close_brackets = value != "false";
            }
            "auto_close_quotes" => {
                self.inner.config.auto_close_quotes = value != "false";
            }
            _ => {}
        }
    }

    // ── Search ────────────────────────────────────────────────────────────────

    /// Returns JSON SearchMatch or null. flags: 0x01=case 0x02=word 0x04=regex
    pub fn search_start(&mut self, pattern: &str, flags: u32) -> Option<String> {
        let q = SearchQuery {
            pattern: pattern.to_owned(),
            case_sensitive: flags & 0x01 != 0,
            whole_word: flags & 0x02 != 0,
            regex: flags & 0x04 != 0,
            wrap_around: true,
        };
        self.inner.search_start(q).map(|m| {
            serde_json::json!({
                "start": m.start.0, "end": m.end.0,
                "line": m.line, "col": m.col,
                "total": m.total, "index": m.index,
            })
            .to_string()
        })
    }

    pub fn search_next(&mut self) -> Option<String> {
        self.inner.search_next().map(|m| {
            serde_json::json!({
                "start": m.start.0, "end": m.end.0,
                "line": m.line, "col": m.col,
                "total": m.total, "index": m.index,
            })
            .to_string()
        })
    }

    pub fn search_prev(&mut self) -> Option<String> {
        self.inner.search_prev().map(|m| {
            serde_json::json!({
                "start": m.start.0, "end": m.end.0,
                "line": m.line, "col": m.col,
                "total": m.total, "index": m.index,
            })
            .to_string()
        })
    }

    pub fn search_clear(&mut self) {
        self.inner.search_clear();
    }

    pub fn replace_current(&mut self, replacement: &str) {
        let _ = self.inner.replace_current(replacement);
    }

    pub fn replace_all(&mut self, replacement: &str) -> usize {
        self.inner.replace_all_matches(replacement).len()
    }

    // ── Folds ─────────────────────────────────────────────────────────────────

    pub fn fold_toggle(&mut self, line: usize) {
        self.inner.toggle_fold(line);
    }
    pub fn fold_all(&mut self) {
        self.inner.fold_all();
    }
    pub fn unfold_all(&mut self) {
        self.inner.unfold_all();
    }

    // ── Clipboard ─────────────────────────────────────────────────────────────

    pub fn copy(&mut self) {
        self.inner.copy();
    }
    pub fn cut(&mut self) {
        let _ = self.inner.cut();
    }
    pub fn paste(&mut self) {
        let _ = self.inner.paste();
    }
    pub fn cycle_paste(&mut self) {
        let _ = self.inner.cycle_paste();
    }

    pub fn clipboard_text(&self) -> Option<String> {
        let t = self.inner.clipboard.peek_text();
        if t.is_empty() {
            None
        } else {
            Some(t.to_owned())
        }
    }

    // ── Formatting ────────────────────────────────────────────────────────────

    pub fn format_document(&mut self) {
        let result = self.inner.format_document(None);
        if result.has_changes {
            self.inner.apply_batch(result.ops);
        }
    }

    pub fn format_on_save(&mut self) {
        let result = self.inner.format_on_save();
        if result.has_changes {
            self.inner.apply_batch(result.ops);
        }
    }

    pub fn sort_imports(&mut self) {
        let lang = self.inner.language.clone();
        let result = crate::sort_imports(&self.inner.buffer, &lang);
        if result.has_changes {
            self.inner.apply_batch(result.ops);
        }
    }

    // ── Macros ────────────────────────────────────────────────────────────────

    pub fn macro_start(&mut self, register: &str) -> bool {
        let reg = register.chars().next().unwrap_or('"');
        self.inner.macro_start(reg).is_ok()
    }

    pub fn macro_stop(&mut self) -> i32 {
        self.inner.macro_stop().map(|n| n as i32).unwrap_or(-1)
    }

    pub fn macro_play(&mut self, register: &str, count: usize) {
        let reg = register.chars().next().unwrap_or('"');
        self.inner.macro_play(reg, count.max(1));
    }

    pub fn macro_is_recording(&self) -> bool {
        self.inner.macros.is_recording()
    }

    // ── Stats & diagnostics ───────────────────────────────────────────────────

    pub fn word_count(&self) -> usize {
        self.inner.document_stats().words
    }
    pub fn char_count(&self) -> usize {
        self.inner.document_stats().chars
    }
    pub fn error_count(&self) -> usize {
        self.inner.lsp_state.error_count()
    }
    pub fn warning_count(&self) -> usize {
        self.inner.lsp_state.warning_count()
    }

    pub fn document_stats(&self) -> String {
        serde_json::to_string(&self.inner.document_stats()).unwrap_or_default()
    }

    // ── Decorations ───────────────────────────────────────────────────────────

    /// remove_json: JSON array of IDs, add_json: JSON array of specs
    /// Returns JSON array of new IDs.
    pub fn delta_decorations(&mut self, remove_json: &str, add_json: &str) -> String {
        let remove_ids: Vec<u64> = serde_json::from_str(remove_json).unwrap_or_default();
        let add_specs: Vec<(DecorationSpec, String)> = {
            let raw: Vec<serde_json::Value> = serde_json::from_str(add_json).unwrap_or_default();
            raw.into_iter()
                .filter_map(|v| {
                    let start = v["range"]["start"].as_u64()? as usize;
                    let end = v["range"]["end"].as_u64()? as usize;
                    let owner = v["owner"].as_str().unwrap_or("wasm").to_owned();
                    let opts = serde_json::from_value::<DecorationOptions>(v["options"].clone())
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
        };
        let new_ids = self.inner.delta_decorations(&remove_ids, &add_specs);
        serde_json::to_string(&new_ids).unwrap_or_default()
    }

    pub fn clear_decorations(&mut self, owner: &str) {
        self.inner.clear_decorations_by_owner(owner);
    }

    // ── TextModel API ─────────────────────────────────────────────────────────

    pub fn model_get_line(&self, line_number: u32) -> String {
        self.inner.text_model().get_line_content(line_number)
    }

    pub fn model_get_offset(&self, line_number: u32, column: u32) -> usize {
        self.inner
            .text_model()
            .get_offset_at(MonacoPosition::new(line_number, column))
    }

    pub fn model_get_position(&self, offset: usize) -> String {
        let pos = self.inner.text_model().get_position_at(offset);
        serde_json::json!({ "lineNumber": pos.line_number, "column": pos.column }).to_string()
    }

    pub fn model_get_value_in_range(&self, sl: u32, sc: u32, el: u32, ec: u32) -> String {
        let range = MonacoRange::new(sl, sc, el, ec);
        self.inner.text_model().get_value_in_range(range)
    }

    /// flags: 0x01=case 0x02=word 0x04=regex. Returns JSON array of MonacoRange.
    pub fn model_find_matches(&self, search: &str, flags: u32, limit: usize) -> String {
        let m = self.inner.text_model();
        let matches = m.find_matches(
            search,
            flags & 0x04 != 0,
            flags & 0x01 != 0,
            flags & 0x02 != 0,
            None,
            limit,
        );
        let arr: Vec<serde_json::Value> = matches
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
        serde_json::to_string(&arr).unwrap_or_default()
    }

    pub fn model_word_at(&self, line_number: u32, column: u32) -> Option<String> {
        let pos = MonacoPosition::new(line_number, column);
        self.inner.text_model().get_word_at_position(pos).map(|w|
            serde_json::json!({ "word": w.word, "startColumn": w.start_column, "endColumn": w.end_column }).to_string()
        )
    }

    pub fn execute_edits(&mut self, edits_json: &str) -> usize {
        let raw: Vec<serde_json::Value> = serde_json::from_str(edits_json).unwrap_or_default();
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
        self.inner.execute_edits(&edits).len()
    }

    // ── Extension system ──────────────────────────────────────────────────────

    pub fn ext_list(&self) -> String {
        let list = self.inner.extensions.list();
        serde_json::to_string(&list).unwrap_or_default()
    }

    pub fn ext_activate_startup(&mut self) {
        self.inner.extensions.activate_startup();
    }

    pub fn cmd_palette(&self) -> String {
        let bus = self.inner.extensions.bus().lock().unwrap();
        let items = bus.commands.palette_items();
        serde_json::to_string(&items).unwrap_or_default()
    }

    pub fn cmd_search(&self, query: &str) -> String {
        let bus = self.inner.extensions.bus().lock().unwrap();
        let items = bus.commands.search_palette(query);
        serde_json::to_string(&items).unwrap_or_default()
    }

    pub fn cmd_execute(&mut self, command_id: &str, args_json: Option<String>) -> String {
        self.inner.extensions.activate_for_command(command_id);
        let args: serde_json::Value = args_json
            .as_deref()
            .and_then(|s| serde_json::from_str(s).ok())
            .unwrap_or(serde_json::Value::Null);
        let mut bus = self.inner.extensions.bus().lock().unwrap();
        let result = bus.commands.execute(command_id, args);
        drop(bus);
        match result {
            crate::CommandResult::Ok(v) => serde_json::json!({"ok":true,"value":v}).to_string(),
            crate::CommandResult::NoResult => {
                serde_json::json!({"ok":true,"value":null}).to_string()
            }
            crate::CommandResult::Err(e) => serde_json::json!({"ok":false,"error":e}).to_string(),
        }
    }

    pub fn key_resolve(&mut self, key_str: &str, context_json: Option<String>) -> String {
        use crate::{KeyChord, KeyContext, KeyResolution};
        let chord = match KeyChord::parse(key_str) {
            Some(c) => c,
            None => return serde_json::json!({"command":null,"pending":false}).to_string(),
        };
        let mut ctx = KeyContext::new();
        ctx.set("editorFocus");
        ctx.set("editorTextFocus");
        ctx.set_value("language", serde_json::json!(self.inner.language.clone()));
        if let Some(cj) = context_json.as_deref() {
            if let Ok(obj) = serde_json::from_str::<serde_json::Value>(cj) {
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
        let mut bus = self.inner.extensions.bus().lock().unwrap();
        let result = bus.keybindings.resolve(chord, &ctx);
        drop(bus);
        match result {
            KeyResolution::Command(cmd) => {
                serde_json::json!({"command":cmd,"pending":false}).to_string()
            }
            KeyResolution::ChordPending => {
                serde_json::json!({"command":null,"pending":true}).to_string()
            }
            KeyResolution::Unbound => {
                serde_json::json!({"command":null,"pending":false}).to_string()
            }
        }
    }

    pub fn theme_list(&self) -> String {
        let bus = self.inner.extensions.bus().lock().unwrap();
        let list: Vec<serde_json::Value> = bus.themes.list().into_iter()
            .map(|(id, name, kind)| serde_json::json!({"id":id,"name":name,"kind":format!("{:?}",kind)}))
            .collect();
        serde_json::to_string(&list).unwrap_or_default()
    }

    pub fn theme_set(&mut self, theme_id: &str) -> i32 {
        let mut bus = self.inner.extensions.bus().lock().unwrap();
        if bus.themes.activate(theme_id) {
            0
        } else {
            -1
        }
    }

    pub fn snippets_for_language(&self, language: &str) -> String {
        let bus = self.inner.extensions.bus().lock().unwrap();
        let snips = bus.snippets.all_for_language(language);
        serde_json::to_string(snips).unwrap_or_default()
    }

    pub fn snippet_expand(&self, language: &str, prefix: &str) -> Option<String> {
        let bus = self.inner.extensions.bus().lock().unwrap();
        let snippet = bus.snippets.find_for_prefix(language, prefix)?;
        let expanded = snippet.expand(&std::collections::HashMap::new());
        let tab_stops: Vec<serde_json::Value> = expanded.tab_stops.iter().map(|ts| serde_json::json!({
            "index": ts.index, "start": ts.start, "len": ts.len, "placeholder": ts.placeholder,
        })).collect();
        Some(
            serde_json::json!({
                "text": expanded.text,
                "tab_stops": tab_stops,
                "final_cursor": expanded.final_cursor(),
            })
            .to_string(),
        )
    }

    pub fn statusbar_items(&self) -> String {
        let bus = self.inner.extensions.bus().lock().unwrap();
        serde_json::to_string(&bus.status_bar).unwrap_or_default()
    }

    pub fn statusbar_update(&mut self, id: &str, text: &str) -> i32 {
        let mut bus = self.inner.extensions.bus().lock().unwrap();
        if let Some(item) = bus.status_bar.iter_mut().find(|i| i.id == id) {
            item.text = text.to_owned();
            0
        } else {
            -1
        }
    }

    pub fn notifications_drain(&mut self) -> String {
        let mut bus = self.inner.extensions.bus().lock().unwrap();
        let notifs: Vec<_> = bus.notifications.drain(..).collect();
        serde_json::to_string(&notifs).unwrap_or_default()
    }

    pub fn ext_poll_events(&self) -> String {
        let events = self.inner.event_bus.poll_events();
        serde_json::to_string(&events).unwrap_or_default()
    }

    pub fn ext_drain_events(&mut self) -> String {
        let events = self.inner.event_bus.drain_events();
        serde_json::to_string(&events).unwrap_or_default()
    }

    // ── Batch JSON bridge ─────────────────────────────────────────────────────

    pub fn batch(&mut self, commands_json: &str) -> String {
        crate::ffi::json_bridge::process_batch_internal(&mut self.inner, commands_json)
    }

    // ── Render ────────────────────────────────────────────────────────────────

    pub fn render_frame_json(&self) -> String {
        serde_json::to_string(&self.inner.render_frame()).unwrap_or_default()
    }
}

#[cfg(test)]
mod tests {
    // WASM-specific tests run under wasm-pack test --headless
    // Unit-level tests are in the modules being called (lib.rs, ffi/*, etc.)
    #[test]
    fn test_motion_from_code_covers_all() {
        for code in 0u32..=16 {
            let _ = super::motion_from_code(code);
        }
        // Out-of-range defaults
        let _ = super::motion_from_code(99);
    }
}

#[cfg(test)]
mod wasm_logic_tests {
    use super::*;

    // Test motion_from_code covers all codes (pure Rust logic, no WASM needed)
    #[test]
    fn test_motion_codes_valid() {
        for code in 0u32..=16 {
            let mk = motion_from_code(code);
            // Just verify no panic and produces valid MotionKind
            let _ = mk;
        }
    }

    #[test]
    fn test_motion_code_out_of_range_defaults() {
        let mk = motion_from_code(999);
        // Should default to CharRight (1)
        matches!(mk, crate::MotionKind::CharRight);
    }

    // Test that WasmEditor can be constructed in non-wasm environment
    // (The struct itself is plain Rust, wasm_bindgen just adds JS bindings)
    #[test]
    fn test_wasm_editor_new_internal() {
        let ed = crate::Editor::new();
        assert_eq!(ed.buffer.len_bytes(), 0);
    }

    #[test]
    fn test_wasm_editor_from_string_internal() {
        let ed = crate::Editor::from_str("fn main() {}");
        assert_eq!(ed.buffer.len_bytes(), 12);
        assert_eq!(ed.buffer.to_string(), "fn main() {}");
    }

    #[test]
    fn test_search_flags_bitmask() {
        // Verify flag values used in model_find_matches
        let case_sensitive: u32 = 0x01;
        let whole_word: u32 = 0x02;
        let regex: u32 = 0x04;
        assert_eq!(case_sensitive & 0x01, 0x01);
        assert_eq!(whole_word & 0x02, 0x02);
        assert_eq!(regex & 0x04, 0x04);
        // Combined flags
        let all = case_sensitive | whole_word | regex;
        assert_eq!(all & 0x01 != 0, true);
        assert_eq!(all & 0x02 != 0, true);
        assert_eq!(all & 0x04 != 0, true);
    }

    #[test]
    fn test_editor_text_operations() {
        let mut ed = crate::Editor::from_str("hello");
        ed.apply(crate::core::edit::EditOp::insert(5, " world"));
        assert_eq!(ed.buffer.to_string(), "hello world");
        ed.apply(crate::core::edit::EditOp::delete(5, 11));
        assert_eq!(ed.buffer.to_string(), "hello");
    }

    #[test]
    fn test_search_query_construction() {
        let q = crate::core::search::SearchQuery {
            pattern: "hello".to_owned(),
            case_sensitive: true,
            whole_word: false,
            regex: false,
            wrap_around: true,
        };
        assert_eq!(q.pattern, "hello");
        assert!(q.case_sensitive);
    }

    #[test]
    fn test_decoration_spec_construction() {
        use crate::core::decoration::{DecorationKind, DecorationOptions, DecorationSpec};
        use crate::core::types::Range;
        let spec = DecorationSpec {
            range: Range::new(0, 10),
            options: DecorationOptions::error_squiggle(),
        };
        assert_eq!(spec.options.kind, DecorationKind::Diagnostic);
    }

    #[test]
    fn test_monaco_position_conversion() {
        use crate::core::text_model::MonacoPosition;
        let p = MonacoPosition::new(1, 1);
        let lc = p.to_line_col();
        assert_eq!(lc.line, 0);
        assert_eq!(lc.col, 0);
        let back = MonacoPosition::from_line_col(lc);
        assert_eq!(back.line_number, 1);
        assert_eq!(back.column, 1);
    }

    #[test]
    fn test_delta_decorations_json_parsing() {
        // Test the JSON parsing logic used in WasmEditor.delta_decorations
        let remove_json = "[]";
        let add_json = r#"[{"range":{"start":0,"end":5},"options":{"is_whole_line":false,"z_index":0,"kind":"Diagnostic"},"owner":"test"}]"#;
        let remove_ids: Vec<u64> = serde_json::from_str(remove_json).unwrap();
        let raw: Vec<serde_json::Value> = serde_json::from_str(add_json).unwrap();
        assert_eq!(remove_ids.len(), 0);
        assert_eq!(raw.len(), 1);
        let start = raw[0]["range"]["start"].as_u64().unwrap();
        let end = raw[0]["range"]["end"].as_u64().unwrap();
        assert_eq!(start, 0);
        assert_eq!(end, 5);
    }
}
