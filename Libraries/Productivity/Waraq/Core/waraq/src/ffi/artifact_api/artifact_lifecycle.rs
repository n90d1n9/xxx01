//! Artifact lifecycle FFI entry points for capture, restore, replay, compaction,
//! maintenance, and validation.
//!
//! Legacy functions preserve null-return semantics, while result-oriented
//! variants return stable JSON envelopes for hosts that need explicit errors.

use super::super::c_api::EditorHandle;
use super::error_codes::code;
use super::numeric::usize_from_u64;
use super::parsing::{
    document_id_from_ptr, document_id_from_ptr_result, editor_artifact_from_ptr,
    editor_artifact_from_ptr_result, editor_operation_from_ptr_result,
    editor_operation_log_from_ptr, editor_operation_log_from_ptr_result,
};
use super::result::{
    artifact_result_err, artifact_result_ok, editor_artifact_error, ArtifactApiError,
};
use crate::core::editor_artifact::{
    apply_editor_operation, compact_editor_artifact, editor_artifact, maintain_editor_artifact,
    plan_editor_artifact_maintenance, replay_editor_log, restore_editor_artifact, EditorArtifact,
    EditorArtifactMaintenancePolicy, EditorOperation, WARAQ_EDITOR_ENGINE_ID,
};
use serde::Serialize;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Compact validation summary for hosts that need to preflight artifacts.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
struct ArtifactValidationSummary {
    engine: String,
    document_id: String,
    operation_count: usize,
    first_sequence: Option<u64>,
    last_sequence: Option<u64>,
    last_operation_id: Option<String>,
}

/// Restore preflight summary for hosts that need diagnostics before opening.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
struct ArtifactRestorePreflightSummary {
    restore_ready: bool,
    schema_version: u32,
    engine: String,
    document_id: String,
    snapshot_file_uri: String,
    snapshot_language: String,
    has_snapshot_content: bool,
    has_operation_tail: bool,
    operation_count: usize,
    first_sequence: Option<u64>,
    last_sequence: Option<u64>,
    last_operation_id: Option<String>,
}

/// Capture the current editor as a Waraq editor artifact JSON.
/// `operation_log_json` may be null or empty to capture a snapshot-only artifact.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_capture(
    handle: *const EditorHandle,
    document_id: *const c_char,
    operation_log_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &*handle };
    let document_id = match document_id_from_ptr(document_id, &h.inner.file_uri) {
        Some(document_id) => document_id,
        None => return std::ptr::null_mut(),
    };
    let operation_log = match editor_operation_log_from_ptr(operation_log_json) {
        Some(operation_log) => operation_log,
        None => return std::ptr::null_mut(),
    };

    let artifact = editor_artifact(document_id, &h.inner, operation_log);
    match artifact.validate_for_engine(WARAQ_EDITOR_ENGINE_ID) {
        Ok(()) => legacy_pretty_json_to_c_string(&artifact),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Restore an editor from a Waraq editor artifact JSON.
/// Returns a new EditorHandle. CALLER MUST call editor_destroy.
#[no_mangle]
pub extern "C" fn editor_artifact_restore(artifact_json: *const c_char) -> *mut EditorHandle {
    if artifact_json.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { CStr::from_ptr(artifact_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let artifact = match EditorArtifact::from_json(s) {
        Ok(artifact) => artifact,
        Err(_) => return std::ptr::null_mut(),
    };
    match restore_editor_artifact(&artifact) {
        Ok(editor) => Box::into_raw(Box::new(EditorHandle { inner: editor })),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Preflight a Waraq editor artifact restore and return `{ ok, value, error }` JSON.
/// This does not create an EditorHandle; call editor_artifact_restore after success.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_restore_preflight_result_json(
    artifact_json: *const c_char,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr_result(artifact_json) {
        Ok(artifact) => artifact,
        Err(error) => return artifact_result_err(error),
    };

    match restore_editor_artifact(&artifact) {
        Ok(_) => artifact_result_ok(artifact_restore_preflight_summary(&artifact)),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Apply one Waraq editor operation JSON and return an operation outcome JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_apply_operation_json(
    handle: *mut EditorHandle,
    operation_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || operation_json.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let s = match unsafe { CStr::from_ptr(operation_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let operation = match EditorOperation::from_json(s) {
        Ok(operation) => operation,
        Err(_) => return std::ptr::null_mut(),
    };
    match apply_editor_operation(&mut h.inner, &operation) {
        Ok(outcome) => legacy_json_to_c_string(&outcome),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Replay a Waraq editor operation-log JSON and return operation outcomes JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_replay_log_json(
    handle: *mut EditorHandle,
    operation_log_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() || operation_log_json.is_null() {
        return std::ptr::null_mut();
    }
    let h = unsafe { &mut *handle };
    let operation_log = match editor_operation_log_from_ptr(operation_log_json) {
        Some(operation_log) => operation_log,
        None => return std::ptr::null_mut(),
    };
    match replay_editor_log(&mut h.inner, &operation_log) {
        Ok(outcomes) => legacy_json_to_c_string(&outcomes),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Compact a Waraq editor artifact JSON and return a new artifact JSON.
/// `retain_tail_operations` keeps the newest N operations outside the snapshot.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_compact(
    artifact_json: *const c_char,
    retain_tail_operations: u64,
    compacted_at_ms: u64,
) -> *mut c_char {
    if artifact_json.is_null() {
        return std::ptr::null_mut();
    }
    let s = match unsafe { CStr::from_ptr(artifact_json) }.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let artifact = match EditorArtifact::from_json(s) {
        Ok(artifact) => artifact,
        Err(_) => return std::ptr::null_mut(),
    };
    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(_) => return std::ptr::null_mut(),
        };
    match compact_editor_artifact(&artifact, retain_tail_operations, compacted_at_ms) {
        Ok(compacted) => legacy_pretty_json_to_c_string(&compacted),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return a JSON maintenance plan for a Waraq editor artifact.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_maintenance_plan(
    artifact_json: *const c_char,
    max_tail_operations: u64,
    retain_tail_operations: u64,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr(artifact_json) {
        Some(artifact) => artifact,
        None => return std::ptr::null_mut(),
    };
    let max_tail_operations = match usize_from_u64("max_tail_operations", max_tail_operations) {
        Ok(max_tail_operations) => max_tail_operations,
        Err(_) => return std::ptr::null_mut(),
    };
    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(_) => return std::ptr::null_mut(),
        };
    let policy = EditorArtifactMaintenancePolicy::new(max_tail_operations, retain_tail_operations);
    match plan_editor_artifact_maintenance(&artifact, policy) {
        Ok(plan) => legacy_json_to_c_string(&plan),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Apply artifact maintenance and return the original or compacted artifact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_maintain(
    artifact_json: *const c_char,
    max_tail_operations: u64,
    retain_tail_operations: u64,
    compacted_at_ms: u64,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr(artifact_json) {
        Some(artifact) => artifact,
        None => return std::ptr::null_mut(),
    };
    let max_tail_operations = match usize_from_u64("max_tail_operations", max_tail_operations) {
        Ok(max_tail_operations) => max_tail_operations,
        Err(_) => return std::ptr::null_mut(),
    };
    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(_) => return std::ptr::null_mut(),
        };
    let policy = EditorArtifactMaintenancePolicy::new(max_tail_operations, retain_tail_operations);
    match maintain_editor_artifact(&artifact, policy, compacted_at_ms) {
        Ok(maintained) => legacy_pretty_json_to_c_string(&maintained),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Capture the current editor and return `{ ok, value, error }` JSON.
/// `operation_log_json` may be null or empty to capture a snapshot-only artifact.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_capture_result_json(
    handle: *const EditorHandle,
    document_id: *const c_char,
    operation_log_json: *const c_char,
) -> *mut c_char {
    let artifact = capture_editor_artifact_for_result(handle, document_id, operation_log_json);
    match artifact {
        Ok(artifact) => artifact_result_ok(artifact),
        Err(error) => artifact_result_err(error),
    }
}

/// Apply one Waraq editor operation and return `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_apply_operation_result_json(
    handle: *mut EditorHandle,
    operation_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() {
        return artifact_result_err(ArtifactApiError::new(
            code::NULL_HANDLE,
            "handle must not be null",
        ));
    }

    let operation = match editor_operation_from_ptr_result(operation_json) {
        Ok(operation) => operation,
        Err(error) => return artifact_result_err(error),
    };

    let h = unsafe { &mut *handle };
    match apply_editor_operation(&mut h.inner, &operation) {
        Ok(outcome) => artifact_result_ok(outcome),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Replay a Waraq editor operation log and return `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_replay_log_result_json(
    handle: *mut EditorHandle,
    operation_log_json: *const c_char,
) -> *mut c_char {
    if handle.is_null() {
        return artifact_result_err(ArtifactApiError::new(
            code::NULL_HANDLE,
            "handle must not be null",
        ));
    }

    let operation_log = match editor_operation_log_from_ptr_result(operation_log_json, false) {
        Ok(operation_log) => operation_log,
        Err(error) => return artifact_result_err(error),
    };

    let h = unsafe { &mut *handle };
    match replay_editor_log(&mut h.inner, &operation_log) {
        Ok(outcomes) => artifact_result_ok(outcomes),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Compact an editor artifact and return `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_compact_result_json(
    artifact_json: *const c_char,
    retain_tail_operations: u64,
    compacted_at_ms: u64,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr_result(artifact_json) {
        Ok(artifact) => artifact,
        Err(error) => return artifact_result_err(error),
    };

    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(error) => return artifact_result_err(error),
        };

    match compact_editor_artifact(&artifact, retain_tail_operations, compacted_at_ms) {
        Ok(compacted) => artifact_result_ok(compacted),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Return an artifact maintenance plan as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_maintenance_plan_result_json(
    artifact_json: *const c_char,
    max_tail_operations: u64,
    retain_tail_operations: u64,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr_result(artifact_json) {
        Ok(artifact) => artifact,
        Err(error) => return artifact_result_err(error),
    };
    let max_tail_operations = match usize_from_u64("max_tail_operations", max_tail_operations) {
        Ok(max_tail_operations) => max_tail_operations,
        Err(error) => return artifact_result_err(error),
    };
    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(error) => return artifact_result_err(error),
        };
    let policy = EditorArtifactMaintenancePolicy::new(max_tail_operations, retain_tail_operations);

    match plan_editor_artifact_maintenance(&artifact, policy) {
        Ok(plan) => artifact_result_ok(plan),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Apply artifact maintenance and return `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_maintain_result_json(
    artifact_json: *const c_char,
    max_tail_operations: u64,
    retain_tail_operations: u64,
    compacted_at_ms: u64,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr_result(artifact_json) {
        Ok(artifact) => artifact,
        Err(error) => return artifact_result_err(error),
    };
    let max_tail_operations = match usize_from_u64("max_tail_operations", max_tail_operations) {
        Ok(max_tail_operations) => max_tail_operations,
        Err(error) => return artifact_result_err(error),
    };
    let retain_tail_operations =
        match usize_from_u64("retain_tail_operations", retain_tail_operations) {
            Ok(retain_tail_operations) => retain_tail_operations,
            Err(error) => return artifact_result_err(error),
        };
    let policy = EditorArtifactMaintenancePolicy::new(max_tail_operations, retain_tail_operations);

    match maintain_editor_artifact(&artifact, policy, compacted_at_ms) {
        Ok(maintained) => artifact_result_ok(maintained),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

/// Validate an editor artifact and return a compact summary as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_validate_result_json(
    artifact_json: *const c_char,
) -> *mut c_char {
    let artifact = match editor_artifact_from_ptr_result(artifact_json) {
        Ok(artifact) => artifact,
        Err(error) => return artifact_result_err(error),
    };

    match restore_editor_artifact(&artifact) {
        Ok(_) => artifact_result_ok(artifact_validation_summary(&artifact)),
        Err(error) => artifact_result_err(editor_artifact_error(error)),
    }
}

fn capture_editor_artifact_for_result(
    handle: *const EditorHandle,
    document_id: *const c_char,
    operation_log_json: *const c_char,
) -> Result<EditorArtifact, ArtifactApiError> {
    if handle.is_null() {
        return Err(ArtifactApiError::new(
            code::NULL_HANDLE,
            "handle must not be null",
        ));
    }

    let h = unsafe { &*handle };
    let document_id = document_id_from_ptr_result(document_id, &h.inner.file_uri)?;
    let operation_log = editor_operation_log_from_ptr_result(operation_log_json, true)?;
    let artifact = editor_artifact(document_id, &h.inner, operation_log);

    restore_editor_artifact(&artifact)
        .map(|_| artifact.clone())
        .map_err(editor_artifact_error)
}

fn legacy_json_to_c_string<T: Serialize>(value: &T) -> *mut c_char {
    legacy_serialized_json_to_c_string(serde_json::to_string(value).unwrap_or_default())
}

fn legacy_pretty_json_to_c_string<T: Serialize>(value: &T) -> *mut c_char {
    legacy_serialized_json_to_c_string(serde_json::to_string_pretty(value).unwrap_or_default())
}

fn legacy_serialized_json_to_c_string(json: String) -> *mut c_char {
    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

fn artifact_validation_summary(artifact: &EditorArtifact) -> ArtifactValidationSummary {
    ArtifactValidationSummary {
        engine: artifact.engine.clone(),
        document_id: artifact.document_id.clone(),
        operation_count: artifact.operation_log.len(),
        first_sequence: artifact.operation_log.first_sequence(),
        last_sequence: artifact.operation_log.last_sequence(),
        last_operation_id: artifact
            .operation_log
            .last_operation_id()
            .map(ToOwned::to_owned),
    }
}

fn artifact_restore_preflight_summary(
    artifact: &EditorArtifact,
) -> ArtifactRestorePreflightSummary {
    ArtifactRestorePreflightSummary {
        restore_ready: true,
        schema_version: artifact.schema_version,
        engine: artifact.engine.clone(),
        document_id: artifact.document_id.clone(),
        snapshot_file_uri: artifact.snapshot.file_uri.clone(),
        snapshot_language: artifact.snapshot.language.clone(),
        has_snapshot_content: artifact.snapshot.content.is_some(),
        has_operation_tail: !artifact.operation_log.operations.is_empty(),
        operation_count: artifact.operation_log.len(),
        first_sequence: artifact.operation_log.first_sequence(),
        last_sequence: artifact.operation_log.last_sequence(),
        last_operation_id: artifact
            .operation_log
            .last_operation_id()
            .map(ToOwned::to_owned),
    }
}
