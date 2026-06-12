pub mod advanced_api;
pub mod ai_api;
pub mod artifact_api;
pub mod c_api;
pub mod c_api_extended;
pub mod c_api_extra;
pub mod decoration_api;
pub mod events;
pub mod ext_api;
pub mod json_bridge;
pub mod workspace_api;

#[cfg(feature = "wasm")]
pub mod wasm_api;

pub use advanced_api::*;
pub use ai_api::*;
pub use artifact_api::*;
pub use c_api::*;
pub use c_api_extended::*;
pub use c_api_extra::*;
pub use decoration_api::*;
pub use events::{emit, EditorEvent, EventQueue};
pub use ext_api::*;
pub use workspace_api::{
    editor_is_dirty, editor_lsp_apply_diagnostics, editor_lsp_apply_edit, editor_lsp_apply_hover,
    editor_lsp_clear_hover, editor_lsp_code_actions, editor_mark_clean, editor_session_capture,
    editor_session_restore, editor_undo_depth, workspace_active_editor_info,
    workspace_active_tab_id, workspace_close, workspace_create, workspace_destroy,
    workspace_find_in_files, workspace_open, workspace_open_untitled, workspace_replace_in_files,
    workspace_switch_to, workspace_tab_count, workspace_tab_list, WorkspaceHandle,
};
