//! FFI entry points for creating, appending, and validating editor operation logs.
//!
//! Document-scoped variants enforce that every operation targets the expected
//! artifact document before the log is accepted by a host editor.

use super::parsing::{
    editor_operation_from_ptr_result, editor_operation_log_from_ptr_result,
    required_document_id_from_ptr,
};
use super::result::{
    artifact_json_to_c_string, artifact_result_err, artifact_result_ok, operation_log_error,
    ArtifactApiError,
};
use crate::core::editor_artifact::{EditorOperation, EditorOperationLog, WARAQ_EDITOR_ENGINE_ID};
use crate::core::operation::OperationLogError;
use serde::Serialize;
use std::os::raw::c_char;

/// Compact validation summary for operation logs loaded by host editors.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
struct OperationLogValidationSummary {
    engine: &'static str,
    document_id: Option<String>,
    operation_count: usize,
    first_sequence: Option<u64>,
    last_sequence: Option<u64>,
    next_sequence: u64,
    last_operation_id: Option<String>,
}

/// Build an empty Waraq editor operation-log JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_empty_json() -> *mut c_char {
    artifact_json_to_c_string(&EditorOperationLog::new())
}

/// Append one operation to an operation log and return operation-log JSON.
/// `operation_log_json` may be null or empty to start a new log.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_append_json(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
) -> *mut c_char {
    match append_editor_operation_to_log(operation_log_json, operation_json) {
        Ok(log) => artifact_json_to_c_string(&log),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Append one operation to a document-scoped operation log and return operation-log JSON.
/// `operation_log_json` may be null or empty to start a new log.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_append_for_document_json(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
    document_id: *const c_char,
) -> *mut c_char {
    match append_editor_operation_to_log_for_document(
        operation_log_json,
        operation_json,
        document_id,
    ) {
        Ok(log) => artifact_json_to_c_string(&log),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Validate an operation log and return summary JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_validate_json(
    operation_log_json: *const c_char,
) -> *mut c_char {
    match validate_editor_operation_log_for_summary(operation_log_json) {
        Ok(summary) => artifact_json_to_c_string(&summary),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Validate an operation log for a specific document and return summary JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_validate_for_document_json(
    operation_log_json: *const c_char,
    document_id: *const c_char,
) -> *mut c_char {
    match validate_editor_operation_log_for_document_summary(operation_log_json, document_id) {
        Ok(summary) => artifact_json_to_c_string(&summary),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Build an empty Waraq editor operation log as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_empty_result_json() -> *mut c_char {
    artifact_result_ok(EditorOperationLog::new())
}

/// Append one operation to an operation log as `{ ok, value, error }` JSON.
/// `operation_log_json` may be null or empty to start a new log.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_append_result_json(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
) -> *mut c_char {
    match append_editor_operation_to_log(operation_log_json, operation_json) {
        Ok(log) => artifact_result_ok(log),
        Err(error) => artifact_result_err(error),
    }
}

/// Append one operation to a document-scoped operation log as `{ ok, value, error }` JSON.
/// `operation_log_json` may be null or empty to start a new log.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_append_for_document_result_json(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
    document_id: *const c_char,
) -> *mut c_char {
    match append_editor_operation_to_log_for_document(
        operation_log_json,
        operation_json,
        document_id,
    ) {
        Ok(log) => artifact_result_ok(log),
        Err(error) => artifact_result_err(error),
    }
}

/// Validate an operation log as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_validate_result_json(
    operation_log_json: *const c_char,
) -> *mut c_char {
    match validate_editor_operation_log_for_summary(operation_log_json) {
        Ok(summary) => artifact_result_ok(summary),
        Err(error) => artifact_result_err(error),
    }
}

/// Validate an operation log for a specific document as `{ ok, value, error }` JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_operation_log_validate_for_document_result_json(
    operation_log_json: *const c_char,
    document_id: *const c_char,
) -> *mut c_char {
    match validate_editor_operation_log_for_document_summary(operation_log_json, document_id) {
        Ok(summary) => artifact_result_ok(summary),
        Err(error) => artifact_result_err(error),
    }
}

fn append_editor_operation_to_log(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
) -> Result<EditorOperationLog, ArtifactApiError> {
    let mut log = editor_operation_log_from_ptr_result(operation_log_json, true)?;
    log.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    validate_operation_log_documents(&log)?;

    let operation = editor_operation_from_ptr_result(operation_json)?;
    validate_log_append_document(&log, &operation)?;
    log.push_checked(operation, WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    Ok(log)
}

fn append_editor_operation_to_log_for_document(
    operation_log_json: *const c_char,
    operation_json: *const c_char,
    document_id: *const c_char,
) -> Result<EditorOperationLog, ArtifactApiError> {
    let expected_document_id = required_document_id_from_ptr(document_id)?;
    let mut log = editor_operation_log_from_ptr_result(operation_log_json, true)?;
    log.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    validate_operation_log_documents(&log)?;
    validate_operation_log_expected_document(&log, &expected_document_id)?;

    let operation = editor_operation_from_ptr_result(operation_json)?;
    validate_operation_expected_document(&operation, &expected_document_id)?;
    log.push_checked(operation, WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    Ok(log)
}

fn validate_editor_operation_log_for_summary(
    operation_log_json: *const c_char,
) -> Result<OperationLogValidationSummary, ArtifactApiError> {
    let log = editor_operation_log_from_ptr_result(operation_log_json, false)?;
    log.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    validate_operation_log_documents(&log)?;
    Ok(operation_log_validation_summary(&log))
}

fn validate_editor_operation_log_for_document_summary(
    operation_log_json: *const c_char,
    document_id: *const c_char,
) -> Result<OperationLogValidationSummary, ArtifactApiError> {
    let expected_document_id = required_document_id_from_ptr(document_id)?;
    let log = editor_operation_log_from_ptr_result(operation_log_json, false)?;
    log.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)
        .map_err(operation_log_error)?;
    validate_operation_log_documents(&log)?;
    validate_operation_log_expected_document(&log, &expected_document_id)?;
    Ok(operation_log_validation_summary(&log))
}

fn validate_operation_log_documents(log: &EditorOperationLog) -> Result<(), ArtifactApiError> {
    let Some(first) = log.operations.first() else {
        return Ok(());
    };

    for operation in log.operations.iter().skip(1) {
        if operation.document_id != first.document_id {
            return Err(operation_log_error(
                OperationLogError::OperationDocumentMismatch {
                    operation_id: operation.operation_id.clone(),
                    expected: first.document_id.clone(),
                    actual: operation.document_id.clone(),
                },
            ));
        }
    }

    Ok(())
}

fn validate_operation_log_expected_document(
    log: &EditorOperationLog,
    expected_document_id: &str,
) -> Result<(), ArtifactApiError> {
    for operation in &log.operations {
        validate_operation_expected_document(operation, expected_document_id)?;
    }

    Ok(())
}

fn validate_operation_expected_document(
    operation: &EditorOperation,
    expected_document_id: &str,
) -> Result<(), ArtifactApiError> {
    if operation.document_id != expected_document_id {
        return Err(operation_log_error(
            OperationLogError::OperationDocumentMismatch {
                operation_id: operation.operation_id.clone(),
                expected: expected_document_id.to_owned(),
                actual: operation.document_id.clone(),
            },
        ));
    }

    Ok(())
}

fn operation_log_validation_summary(log: &EditorOperationLog) -> OperationLogValidationSummary {
    OperationLogValidationSummary {
        engine: WARAQ_EDITOR_ENGINE_ID,
        document_id: log
            .operations
            .first()
            .map(|operation| operation.document_id.clone()),
        operation_count: log.len(),
        first_sequence: log.first_sequence(),
        last_sequence: log.last_sequence(),
        next_sequence: log.next_sequence(),
        last_operation_id: log.last_operation_id().map(ToOwned::to_owned),
    }
}

fn validate_log_append_document(
    log: &EditorOperationLog,
    operation: &EditorOperation,
) -> Result<(), ArtifactApiError> {
    let Some(first) = log.operations.first() else {
        return Ok(());
    };

    if operation.document_id != first.document_id {
        return Err(operation_log_error(
            OperationLogError::OperationDocumentMismatch {
                operation_id: operation.operation_id.clone(),
                expected: first.document_id.clone(),
                actual: operation.document_id.clone(),
            },
        ));
    }

    Ok(())
}
