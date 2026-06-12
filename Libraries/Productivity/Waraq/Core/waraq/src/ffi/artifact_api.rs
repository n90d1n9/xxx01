//! C-compatible editor artifact API for native host integrations.
//!
//! This hub keeps the public FFI surface in one place while delegating
//! lifecycle, operation, parsing, result, and contract behavior to focused
//! implementation modules.

mod artifact_lifecycle;
mod contract;
mod error_codes;
mod numeric;
mod operation_builders;
mod operation_log;
mod parsing;
mod result;
mod surface;

pub use artifact_lifecycle::{
    editor_apply_operation_json, editor_apply_operation_result_json, editor_artifact_capture,
    editor_artifact_capture_result_json, editor_artifact_compact,
    editor_artifact_compact_result_json, editor_artifact_maintain,
    editor_artifact_maintain_result_json, editor_artifact_maintenance_plan,
    editor_artifact_maintenance_plan_result_json, editor_artifact_restore,
    editor_artifact_restore_preflight_result_json, editor_artifact_validate_result_json,
    editor_replay_log_json, editor_replay_log_result_json,
};
pub use contract::{
    editor_artifact_boundary_json, editor_artifact_boundary_result_json,
    editor_artifact_capabilities_json, editor_artifact_capabilities_result_json,
    editor_artifact_contract_json, editor_artifact_contract_result_json,
    editor_artifact_engine_contract_result_json,
    editor_artifact_engine_readiness_manifest_result_json, editor_artifact_engine_registry_json,
    editor_artifact_engine_registry_result_json, editor_artifact_lifecycle_profile_json,
    editor_artifact_lifecycle_profile_result_json, editor_artifact_readiness_manifest_json,
    editor_artifact_readiness_manifest_result_json, editor_artifact_resolve_engine_id_result_json,
    editor_artifact_test_profile_json, editor_artifact_test_profile_result_json,
};
pub use operation_builders::{
    editor_operation_delete_json, editor_operation_delete_result_json,
    editor_operation_insert_json, editor_operation_insert_result_json,
    editor_operation_replace_json, editor_operation_replace_result_json,
};
pub use operation_log::{
    editor_operation_log_append_for_document_json,
    editor_operation_log_append_for_document_result_json, editor_operation_log_append_json,
    editor_operation_log_append_result_json, editor_operation_log_empty_json,
    editor_operation_log_empty_result_json, editor_operation_log_validate_for_document_json,
    editor_operation_log_validate_for_document_result_json, editor_operation_log_validate_json,
    editor_operation_log_validate_result_json,
};

#[cfg(test)]
mod tests;
