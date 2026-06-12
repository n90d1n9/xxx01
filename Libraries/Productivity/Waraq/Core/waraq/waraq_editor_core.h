/* waraq_editor_core.h
 * C header for the Waraq editor engine core.
 * Use with Dart FFI, Java FFM, Swift, or any C/C++ consumer.
 *
 * Memory rules:
 *   - EditorHandle*  is owned by Rust. Free with editor_destroy().
 *   - char*  returned by API functions is owned by Rust.
 *              MUST be freed with editor_free_str() exactly once.
 *   - const char* inputs are borrowed for the call duration only.
 *
 * Error handling:
 *   - Functions that can fail return int: 0 = success, -1 = error.
 *   - Call editor_last_error() to get a description of the last error.
 */
#ifndef GOLLEK_EDITOR_CORE_H
#define GOLLEK_EDITOR_CORE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Opaque editor handle. Never dereference directly. */
typedef struct EditorHandle EditorHandle;

/* ── Lifecycle ──────────────────────────────────────────────────────────── */

/** Create a new empty editor. Returns NULL on failure. */
EditorHandle* editor_create(void);

/** Create an editor pre-loaded with content (UTF-8, null-terminated).
 *  Returns NULL if content is not valid UTF-8. */
EditorHandle* editor_create_with_content(const char* content);

/** Free an editor handle. Passing NULL is safe. */
void editor_destroy(EditorHandle* handle);

/* ── Metrics ────────────────────────────────────────────────────────────── */

/** Total byte length of the document. */
uint64_t editor_byte_len(const EditorHandle* handle);

/** Total number of lines. An empty document has 1 line. */
uint64_t editor_line_count(const EditorHandle* handle);

/* ── Text queries ───────────────────────────────────────────────────────── */

/** Get full document text. Caller MUST call editor_free_str(). */
char* editor_get_text(const EditorHandle* handle);

/** Get text of line `line_num` (0-based). Caller MUST call editor_free_str().
 *  Returns NULL if line_num is out of range. */
char* editor_get_line(const EditorHandle* handle, uint64_t line_num);

/* ── Mutations ──────────────────────────────────────────────────────────── */

/** Insert text at byte offset `pos`. Returns 0 on success, -1 on error. */
int editor_insert(EditorHandle* handle, uint64_t pos, const char* text);

/** Delete bytes in [start, end). Returns 0 on success, -1 on error. */
int editor_delete(EditorHandle* handle, uint64_t start, uint64_t end);

/** Replace bytes in [start, end) with text. Returns 0 on success. */
int editor_replace(EditorHandle* handle, uint64_t start, uint64_t end,
                   const char* text);

/* ── Undo / Redo ────────────────────────────────────────────────────────── */

/** Undo last edit. Returns 1 if performed, 0 if nothing to undo. */
int editor_undo(EditorHandle* handle);

/** Redo last undone edit. Returns 1 if performed, 0 otherwise. */
int editor_redo(EditorHandle* handle);

/** Returns 1 if undo is available, 0 otherwise. */
int editor_can_undo(const EditorHandle* handle);

/** Returns 1 if redo is available, 0 otherwise. */
int editor_can_redo(const EditorHandle* handle);

/* ── Cursor ─────────────────────────────────────────────────────────────── */

/** Get primary cursor byte offset. */
uint64_t editor_cursor_pos(const EditorHandle* handle);

/** Move primary cursor to `pos`. Pass extend_selection=1 to extend selection. */
int editor_cursor_move(EditorHandle* handle, uint64_t pos,
                       int extend_selection);

/** Add a secondary cursor at `pos`. */
int editor_cursor_add(EditorHandle* handle, uint64_t pos);

/** Remove all secondary cursors; keep only primary. */
void editor_cursor_collapse(EditorHandle* handle);

/** Get the number of active cursors. */
uint64_t editor_cursor_count(const EditorHandle* handle);

/* ── Viewport ───────────────────────────────────────────────────────────── */

/** Set the viewport height (number of visible lines). */
void editor_set_viewport_height(EditorHandle* handle, uint64_t height);

/** Scroll the viewport by `delta` lines (positive = down, negative = up). */
void editor_scroll_by(EditorHandle* handle, int delta);

/** Scroll the viewport to ensure `line` is visible. */
void editor_ensure_line_visible(EditorHandle* handle, uint64_t line);

/* ── Search ─────────────────────────────────────────────────────────────── */

/** Find all occurrences of `pattern`. Returns JSON array of byte offsets.
 *  Caller MUST call editor_free_str(). */
char* editor_find_all(const EditorHandle* handle, const char* pattern);

/* ── Rendering ──────────────────────────────────────────────────────────── */

/** Serialise the current render frame to JSON (UTF-8, null-terminated).
 *  Caller MUST call editor_free_str().
 *
 *  JSON shape:
 *  {
 *    "lines": [{"line_number":0,"text":"...","byte_offset":0}],
 *    "cursors": [{"line":0,"col":5}],
 *    "tokens": [{"start":0,"end":5,"kind":1,"line":0,...}],
 *    "total_lines": 100,
 *    "scroll_offset": 0
 *  }
 */
char* editor_render_frame_json(const EditorHandle* handle);

/* ── Language / Syntax ──────────────────────────────────────────────────── */

/** Set syntax highlighting language (e.g. "rust", "python", "javascript").
 *  Pass NULL to disable highlighting. Returns 0 on success. */
int editor_set_language(EditorHandle* handle, const char* language);

/* ── Batch API ──────────────────────────────────────────────────────────── */

/** Process a JSON array of commands atomically. Returns a JSON response.
 *  Caller MUST call editor_free_str() on the returned pointer.
 *
 *  commands_json format: [{"cmd":"insert","at":0,"text":"hello"}, ...]
 *  response format: {"ok":true,"frame":<Frame|null>,"errors":[],"ops_applied":1}
 */
char* editor_batch(EditorHandle* handle, const char* commands_json);

/* ── Memory management ──────────────────────────────────────────────────── */

/** Free a string returned by any API function. Passing NULL is safe. */
void editor_free_str(char* s);

/* ── Error reporting ────────────────────────────────────────────────────── */

/** Get a description of the last error. Caller MUST call editor_free_str(). */
char* editor_last_error(void);

/* ── Version ────────────────────────────────────────────────────────────── */

/** Get the library version string (e.g. "0.1.0"). Caller MUST call
 *  editor_free_str() on the returned pointer. */
char* editor_version(void);

/* ── Extended API (c_api_extended.rs) ──────────────────────────────────────── */

/* Search */
uint32_t editor_search_match_count(const EditorHandle* handle);
char* editor_search_start(EditorHandle* handle, const char* pattern, unsigned int flags);
char* editor_search_next(EditorHandle* handle);
char* editor_search_prev(EditorHandle* handle);
int   editor_replace_current(EditorHandle* handle, const char* replacement);
uint64_t editor_replace_all(EditorHandle* handle, const char* replacement);
void  editor_search_clear(EditorHandle* handle);

/* Configuration */
char* editor_get_config(const EditorHandle* handle);
int   editor_set_config(EditorHandle* handle, const char* config_json);
int   editor_set_config_value(EditorHandle* handle, const char* key, const char* value);

/* Folding */
int   editor_toggle_fold(EditorHandle* handle, uint64_t line);
void  editor_fold_all(EditorHandle* handle);
void  editor_unfold_all(EditorHandle* handle);
char* editor_get_folds(const EditorHandle* handle);

/* Diagnostics */
int      editor_set_diagnostics(EditorHandle* handle, const char* diag_json);
char*    editor_get_diagnostics_at_line(const EditorHandle* handle, uint64_t line_num);
uint64_t editor_error_count(const EditorHandle* handle);
uint64_t editor_warning_count(const EditorHandle* handle);

/* Motion (code values: 0-16, see c_api_extended.rs) */
int  editor_motion(EditorHandle* handle, unsigned int code, int extend);
void editor_move_up(EditorHandle* handle, uint64_t lines, int extend);
void editor_move_down(EditorHandle* handle, uint64_t lines, int extend);

/* Selection */
void  editor_select_word(EditorHandle* handle);
void  editor_select_line(EditorHandle* handle);
void  editor_select_all_text(EditorHandle* handle);
void  editor_expand_selection(EditorHandle* handle);
void  editor_add_cursor_next_occurrence(EditorHandle* handle);
char* editor_get_selection_text(const EditorHandle* handle);

/* Keyboard input */
int editor_type_char(EditorHandle* handle, uint32_t codepoint);
int editor_key_backspace(EditorHandle* handle);
int editor_key_delete(EditorHandle* handle);
int editor_key_enter(EditorHandle* handle);
int editor_key_tab(EditorHandle* handle);
int editor_key_shift_tab(EditorHandle* handle);

/* AI completion */
int   editor_has_completion(const EditorHandle* handle);
char* editor_get_completion_text(const EditorHandle* handle);
int   editor_completion_response(EditorHandle* handle, uint64_t request_id,
                                  const char* generated_text, uint64_t latency_ms);
void  editor_completion_dismiss(EditorHandle* handle);
char* editor_completion_stats(const EditorHandle* handle);

/* File metadata */
void  editor_set_file_uri(EditorHandle* handle, const char* file_uri);
char* editor_get_file_uri(const EditorHandle* handle);
char* editor_get_language(const EditorHandle* handle);

/* Bracket info */
char* editor_matching_bracket(const EditorHandle* handle, uint64_t pos);
char* editor_rainbow_brackets(const EditorHandle* handle);

/* Event bus */
char*    editor_poll_events(void);
uint32_t editor_event_count(void);
void     editor_clear_events(void);

/* ── Clipboard (c_api_extra.rs) ─────────────────────────────────────────── */
void     editor_copy(EditorHandle* handle);
uint64_t editor_cut(EditorHandle* handle);
uint64_t editor_paste(EditorHandle* handle);
uint64_t editor_cycle_paste(EditorHandle* handle);
char*    editor_clipboard_text(const EditorHandle* handle);
char*    editor_clipboard_history(const EditorHandle* handle);
uint64_t editor_clipboard_history_len(const EditorHandle* handle);

/* ── Macro recording ────────────────────────────────────────────────────── */
/* reg: ASCII char ('a'-'z' or '"') as uint8_t */
int      editor_macro_start(EditorHandle* handle, uint8_t reg);
int      editor_macro_stop(EditorHandle* handle);
int      editor_macro_is_recording(const EditorHandle* handle);
uint8_t  editor_macro_recording_register(const EditorHandle* handle);
uint64_t editor_macro_play(EditorHandle* handle, uint8_t reg, uint64_t count);
char*    editor_macro_get(const EditorHandle* handle, uint8_t reg);
char*    editor_macro_export(const EditorHandle* handle);
int      editor_macro_import(EditorHandle* handle, const char* json_str);

/* ── Formatting ─────────────────────────────────────────────────────────── */
uint64_t editor_format_document(EditorHandle* handle);
uint64_t editor_format_range(EditorHandle* handle, uint64_t first_line, uint64_t last_line);
uint64_t editor_format_on_save(EditorHandle* handle);
uint64_t editor_sort_imports(EditorHandle* handle);

/* ── Document statistics ─────────────────────────────────────────────────── */
/* Returns JSON: {"bytes":N,"chars":N,"words":N,"lines":N,...} */
char*    editor_document_stats(const EditorHandle* handle);
uint64_t editor_word_count(const EditorHandle* handle);
uint64_t editor_char_count(const EditorHandle* handle);
uint64_t editor_content_line_count(const EditorHandle* handle);

/* ── Artifact API (artifact_api.rs) ───────────────────────────────────────── */
/* Returned JSON strings are Rust-owned. Caller MUST call editor_free_str(). */

char* editor_artifact_capabilities_json(void);
char* editor_artifact_contract_json(void);
char* editor_artifact_boundary_json(void);
char* editor_artifact_engine_registry_json(void);
char* editor_artifact_readiness_manifest_json(void);
char* editor_artifact_test_profile_json(void);
char* editor_artifact_lifecycle_profile_json(void);

char* editor_artifact_capture(const EditorHandle* handle, const char* document_id,
                              const char* operation_log_json);
EditorHandle* editor_artifact_restore(const char* artifact_json);
char* editor_artifact_restore_preflight_result_json(const char* artifact_json);
char* editor_apply_operation_json(EditorHandle* handle, const char* operation_json);
char* editor_replay_log_json(EditorHandle* handle, const char* operation_log_json);
char* editor_artifact_compact(const char* artifact_json, uint64_t retain_tail_operations,
                              uint64_t compacted_at_ms);
char* editor_artifact_maintenance_plan(const char* artifact_json,
                                       uint64_t max_tail_operations,
                                       uint64_t retain_tail_operations);
char* editor_artifact_maintain(const char* artifact_json,
                               uint64_t max_tail_operations,
                               uint64_t retain_tail_operations,
                               uint64_t compacted_at_ms);

char* editor_artifact_capture_result_json(const EditorHandle* handle,
                                          const char* document_id,
                                          const char* operation_log_json);
char* editor_apply_operation_result_json(EditorHandle* handle,
                                         const char* operation_json);
char* editor_replay_log_result_json(EditorHandle* handle,
                                    const char* operation_log_json);
char* editor_artifact_compact_result_json(const char* artifact_json,
                                          uint64_t retain_tail_operations,
                                          uint64_t compacted_at_ms);
char* editor_artifact_maintenance_plan_result_json(
    const char* artifact_json,
    uint64_t max_tail_operations,
    uint64_t retain_tail_operations);
char* editor_artifact_maintain_result_json(const char* artifact_json,
                                           uint64_t max_tail_operations,
                                           uint64_t retain_tail_operations,
                                           uint64_t compacted_at_ms);
char* editor_artifact_capabilities_result_json(void);
char* editor_artifact_contract_result_json(void);
char* editor_artifact_boundary_result_json(void);
char* editor_artifact_engine_registry_result_json(void);
char* editor_artifact_resolve_engine_id_result_json(const char* engine_id);
char* editor_artifact_engine_contract_result_json(const char* engine_id);
char* editor_artifact_engine_readiness_manifest_result_json(const char* engine_id);
char* editor_artifact_validate_result_json(const char* artifact_json);
char* editor_artifact_readiness_manifest_result_json(void);
char* editor_artifact_test_profile_result_json(void);
char* editor_artifact_lifecycle_profile_result_json(void);

char* editor_operation_insert_json(const char* operation_id, const char* document_id,
                                   const char* actor_id, uint64_t sequence,
                                   uint64_t timestamp_ms, uint64_t at,
                                   const char* text);
char* editor_operation_delete_json(const char* operation_id, const char* document_id,
                                   const char* actor_id, uint64_t sequence,
                                   uint64_t timestamp_ms, uint64_t start,
                                   uint64_t end);
char* editor_operation_replace_json(const char* operation_id, const char* document_id,
                                    const char* actor_id, uint64_t sequence,
                                    uint64_t timestamp_ms, uint64_t start,
                                    uint64_t end, const char* text);
char* editor_operation_insert_result_json(const char* operation_id,
                                          const char* document_id,
                                          const char* actor_id,
                                          uint64_t sequence,
                                          uint64_t timestamp_ms,
                                          uint64_t at,
                                          const char* text);
char* editor_operation_delete_result_json(const char* operation_id,
                                          const char* document_id,
                                          const char* actor_id,
                                          uint64_t sequence,
                                          uint64_t timestamp_ms,
                                          uint64_t start,
                                          uint64_t end);
char* editor_operation_replace_result_json(const char* operation_id,
                                           const char* document_id,
                                           const char* actor_id,
                                           uint64_t sequence,
                                           uint64_t timestamp_ms,
                                           uint64_t start,
                                           uint64_t end,
                                           const char* text);

char* editor_operation_log_empty_json(void);
char* editor_operation_log_append_json(const char* operation_log_json,
                                       const char* operation_json);
char* editor_operation_log_append_for_document_json(
    const char* operation_log_json,
    const char* operation_json,
    const char* document_id);
char* editor_operation_log_validate_json(const char* operation_log_json);
char* editor_operation_log_validate_for_document_json(
    const char* operation_log_json,
    const char* document_id);
char* editor_operation_log_empty_result_json(void);
char* editor_operation_log_append_result_json(const char* operation_log_json,
                                              const char* operation_json);
char* editor_operation_log_append_for_document_result_json(
    const char* operation_log_json,
    const char* operation_json,
    const char* document_id);
char* editor_operation_log_validate_result_json(const char* operation_log_json);
char* editor_operation_log_validate_for_document_result_json(
    const char* operation_log_json,
    const char* document_id);

/* ── AI API ──────────────────────────────────────────────────────────────── */

extern int    editor_ai_has_completion(const void* handle);
extern char*  editor_ai_completion_text(const void* handle);
extern int    editor_ai_accept_completion(void* handle);
extern void   editor_ai_dismiss_completion(void* handle);
extern char*  editor_ai_on_change(void* handle);
extern int    editor_ai_apply_inline_completion(void* handle, unsigned long request_id, const char* completion_text);
extern char*  editor_ai_completion_stats(const void* handle);
extern char*  editor_ai_build_explain_prompt(const void* handle);
extern char*  editor_ai_build_edit_prompt(const void* handle, const char* instruction);
extern char*  editor_ai_build_fim_prompt(const void* handle);
extern char*  editor_ai_apply_result(void* handle, const char* task, const char* response_text);
extern char*  editor_ai_extract_context(const void* handle);

/* ── Workspace API ───────────────────────────────────────────────────────── */

extern void*  workspace_create(const char* root_uri);
extern void   workspace_destroy(void* handle);
extern int    workspace_open(void* handle, const char* file_uri, const char* language, const char* content);
extern int    workspace_open_untitled(void* handle, const char* language);
extern char*  workspace_close(void* handle, unsigned long tab_id);
extern int    workspace_switch_to(void* handle, unsigned long tab_id);
extern int    workspace_active_tab_id(const void* handle);
extern unsigned long workspace_tab_count(const void* handle);
extern char*  workspace_active_editor_info(const void* handle);
extern char*  workspace_tab_list(const void* handle);
extern char*  workspace_find_in_files(const void* handle, const char* query_json);
extern unsigned long workspace_replace_in_files(void* handle, const char* query_json, const char* replacement);

/* ── Session API ─────────────────────────────────────────────────────────── */

extern char*  editor_session_capture(const void* handle);
extern void*  editor_session_restore(const char* session_json);
extern int    editor_is_dirty(const void* handle);
extern void   editor_mark_clean(void* handle);
extern unsigned long editor_undo_depth(const void* handle);

/* ── LSP Pipeline ────────────────────────────────────────────────────────── */

extern unsigned long editor_lsp_apply_diagnostics(void* handle, const char* diagnostics_json);
extern void   editor_lsp_apply_hover(void* handle, const char* hover_json, unsigned long offset);
extern void   editor_lsp_clear_hover(void* handle);
extern char*  editor_lsp_code_actions(const void* handle, const char* actions_json);
extern unsigned long editor_lsp_apply_edit(void* handle, const char* edit_json);

/* ── Settings API ────────────────────────────────────────────────────────── */

extern int    editor_settings_load_user(void* handle, const char* json);
extern int    editor_settings_load_workspace(void* handle, const char* json);
extern void   editor_settings_set(void* handle, const char* key, const char* value);
extern char*  editor_settings_get_all(const void* handle);

/* ── Editor Groups ───────────────────────────────────────────────────────── */

extern char*  editor_group_layout_new(void);
extern char*  editor_group_layout_parse(const char* json);

#ifdef __cplusplus
}
#endif

#endif /* GOLLEK_EDITOR_CORE_H */
