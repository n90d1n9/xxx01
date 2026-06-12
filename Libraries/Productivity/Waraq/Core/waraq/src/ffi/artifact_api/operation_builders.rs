//! FFI builders for typed Waraq editor operations.
//!
//! These functions validate raw C string fields before creating operation
//! envelopes that hosts can append to logs or replay against an editor.

use super::error_codes::code;
use super::numeric::usize_from_u64;
use super::parsing::required_string_from_ptr;
use super::result::{
    artifact_json_to_c_string, artifact_result_err, artifact_result_ok, operation_log_error,
    ArtifactApiError,
};
use crate::core::edit::EditOp;
use crate::core::editor_artifact::{editor_operation, EditorOperation, WARAQ_EDITOR_ENGINE_ID};
use std::os::raw::c_char;

/// Build a Waraq editor insert operation JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_insert_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    at: u64,
    text: *const c_char,
) -> *mut c_char {
    match build_insert_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        at,
        text,
    ) {
        Ok(operation) => artifact_json_to_c_string(&operation),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Build a Waraq editor delete operation JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_delete_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
) -> *mut c_char {
    match build_delete_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        start,
        end,
    ) {
        Ok(operation) => artifact_json_to_c_string(&operation),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Build a Waraq editor replace operation JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_replace_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
    text: *const c_char,
) -> *mut c_char {
    match build_replace_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        start,
        end,
        text,
    ) {
        Ok(operation) => artifact_json_to_c_string(&operation),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Build a Waraq editor insert operation as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_insert_result_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    at: u64,
    text: *const c_char,
) -> *mut c_char {
    match build_insert_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        at,
        text,
    ) {
        Ok(operation) => artifact_result_ok(operation),
        Err(error) => artifact_result_err(error),
    }
}

/// Build a Waraq editor delete operation as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_delete_result_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
) -> *mut c_char {
    match build_delete_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        start,
        end,
    ) {
        Ok(operation) => artifact_result_ok(operation),
        Err(error) => artifact_result_err(error),
    }
}

/// Build a Waraq editor replace operation as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_replace_result_json(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
    text: *const c_char,
) -> *mut c_char {
    match build_replace_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        start,
        end,
        text,
    ) {
        Ok(operation) => artifact_result_ok(operation),
        Err(error) => artifact_result_err(error),
    }
}

fn build_insert_operation(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    at: u64,
    text: *const c_char,
) -> Result<EditorOperation, ArtifactApiError> {
    let text = required_string_from_ptr(text, "text", code::NULL_TEXT)?;
    let at = usize_from_u64("at", at)?;
    build_editor_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        EditOp::insert(at, text),
    )
}

fn build_delete_operation(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
) -> Result<EditorOperation, ArtifactApiError> {
    let start = usize_from_u64("start", start)?;
    let end = usize_from_u64("end", end)?;
    validate_builder_range(start, end)?;
    build_editor_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        EditOp::delete(start, end),
    )
}

fn build_replace_operation(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    start: u64,
    end: u64,
    text: *const c_char,
) -> Result<EditorOperation, ArtifactApiError> {
    let start = usize_from_u64("start", start)?;
    let end = usize_from_u64("end", end)?;
    validate_builder_range(start, end)?;
    let text = required_string_from_ptr(text, "text", code::NULL_TEXT)?;
    build_editor_operation(
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        EditOp::replace(start, end, text),
    )
}

fn build_editor_operation(
    operation_id: *const c_char,
    document_id: *const c_char,
    actor_id: *const c_char,
    sequence: u64,
    timestamp_ms: u64,
    edit: EditOp,
) -> Result<EditorOperation, ArtifactApiError> {
    let operation = editor_operation(
        required_string_from_ptr(operation_id, "operation_id", code::NULL_OPERATION_ID)?,
        required_string_from_ptr(document_id, "document_id", code::NULL_DOCUMENT_ID)?,
        required_string_from_ptr(actor_id, "actor_id", code::NULL_ACTOR_ID)?,
        sequence,
        timestamp_ms,
        edit,
    );

    operation
        .validate_for_engine(WARAQ_EDITOR_ENGINE_ID)
        .map(|_| operation)
        .map_err(operation_log_error)
}

fn validate_builder_range(start: usize, end: usize) -> Result<(), ArtifactApiError> {
    if start > end {
        return Err(ArtifactApiError::new(
            code::INVALID_RANGE,
            format!("operation range {start}..{end} must satisfy start <= end"),
        ));
    }
    Ok(())
}
