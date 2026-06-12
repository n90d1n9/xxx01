//! Result-envelope helpers for artifact FFI functions.
//!
//! This module owns stable error payloads, JSON serialization, and core
//! error-code mapping for host integrations.

use super::error_codes::code;
use crate::core::editor_artifact::EditorArtifactError;
use crate::core::operation::OperationLogError;
use serde::Serialize;
use std::ffi::CString;
use std::os::raw::c_char;

/// Stable host-readable identifier for Waraq artifact result envelopes.
pub(super) const ARTIFACT_RESULT_ENVELOPE: &str = "ok_value_error";

/// Host-readable schema description for result-oriented artifact FFI responses.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiResultEnvelopeDescription {
    /// Stable envelope identifier advertised in capabilities JSON.
    pub id: &'static str,
    /// Boolean field that separates success and failure responses.
    pub ok_field: &'static str,
    /// Field containing the successful function payload.
    pub value_field: &'static str,
    /// Field containing the error object on failure.
    pub error_field: &'static str,
    /// Nested field containing the stable machine-readable error code.
    pub error_code_field: &'static str,
    /// Nested field containing diagnostic text for logs and UI.
    pub error_message_field: &'static str,
    /// Whether success responses always contain the value field.
    pub value_required_on_success: bool,
    /// Whether success responses omit the error field.
    pub error_omitted_on_success: bool,
    /// Whether failure responses always contain the error field.
    pub error_required_on_failure: bool,
    /// Whether failure responses omit the value field.
    pub value_omitted_on_failure: bool,
    /// Whether error codes come from the advertised stable error-code catalog.
    pub stable_error_codes: bool,
    /// Error code emitted when result serialization itself fails.
    pub serialization_error_code: &'static str,
}

/// Stable error payload returned by result-oriented artifact FFI functions.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiError {
    code: String,
    message: String,
}

impl ArtifactApiError {
    pub(super) fn new(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            code: code.into(),
            message: message.into(),
        }
    }
}

/// JSON response envelope used by result-oriented artifact FFI functions.
#[derive(Debug, Serialize)]
struct ArtifactApiResult<T> {
    ok: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    value: Option<T>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<ArtifactApiError>,
}

pub(super) fn artifact_result_envelope_description() -> ArtifactApiResultEnvelopeDescription {
    ArtifactApiResultEnvelopeDescription {
        id: ARTIFACT_RESULT_ENVELOPE,
        ok_field: "ok",
        value_field: "value",
        error_field: "error",
        error_code_field: "code",
        error_message_field: "message",
        value_required_on_success: true,
        error_omitted_on_success: true,
        error_required_on_failure: true,
        value_omitted_on_failure: true,
        stable_error_codes: true,
        serialization_error_code: code::SERIALIZATION_FAILED,
    }
}

pub(super) fn artifact_result_ok<T: Serialize>(value: T) -> *mut c_char {
    artifact_result_to_c_string(ArtifactApiResult {
        ok: true,
        value: Some(value),
        error: None,
    })
}

pub(super) fn artifact_result_err(error: ArtifactApiError) -> *mut c_char {
    artifact_result_to_c_string(ArtifactApiResult::<serde_json::Value> {
        ok: false,
        value: None,
        error: Some(error),
    })
}

fn artifact_result_to_c_string<T: Serialize>(result: ArtifactApiResult<T>) -> *mut c_char {
    let json = match serde_json::to_string(&result) {
        Ok(json) => json,
        Err(error) => serde_json::to_string(&ArtifactApiResult::<serde_json::Value> {
            ok: false,
            value: None,
            error: Some(ArtifactApiError::new(
                code::SERIALIZATION_FAILED,
                format!("failed to serialize artifact API result: {error}"),
            )),
        })
        .unwrap_or_else(|_| {
            format!(
                "{{\"ok\":false,\"error\":{{\"code\":\"{}\",\"message\":\"failed to serialize artifact API result\"}}}}",
                code::SERIALIZATION_FAILED
            )
        }),
    };

    CString::new(json)
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

pub(super) fn artifact_json_to_c_string<T: Serialize>(value: &T) -> *mut c_char {
    serde_json::to_string(value)
        .ok()
        .and_then(|json| CString::new(json).ok())
        .map(|cs| cs.into_raw())
        .unwrap_or(std::ptr::null_mut())
}

pub(super) fn editor_artifact_error(error: EditorArtifactError) -> ArtifactApiError {
    match error {
        EditorArtifactError::InvalidOffset { offset, len_bytes } => ArtifactApiError::new(
            code::INVALID_OFFSET,
            format!("edit offset {offset} exceeds document length {len_bytes} bytes"),
        ),
        EditorArtifactError::InvalidRange {
            start,
            end,
            len_bytes,
        } => ArtifactApiError::new(
            code::INVALID_RANGE,
            format!("edit range {start}..{end} is invalid for document length {len_bytes} bytes"),
        ),
        EditorArtifactError::InvalidUtf8Boundary { offset } => ArtifactApiError::new(
            code::INVALID_UTF8_BOUNDARY,
            format!("edit offset {offset} is not a UTF-8 character boundary"),
        ),
        EditorArtifactError::SnapshotDocumentMismatch { expected, actual } => {
            ArtifactApiError::new(
                code::SNAPSHOT_DOCUMENT_MISMATCH,
                format!("snapshot document_id mismatch: expected {expected}, actual {actual}"),
            )
        }
        EditorArtifactError::OperationLog(error) => operation_log_error(error),
    }
}

pub(super) fn operation_log_error(error: OperationLogError) -> ArtifactApiError {
    match error {
        OperationLogError::UnsupportedSchemaVersion { expected, actual } => ArtifactApiError::new(
            code::UNSUPPORTED_SCHEMA_VERSION,
            format!("unsupported schema_version {actual}; expected {expected}"),
        ),
        OperationLogError::WrongEngine {
            expected,
            actual,
            operation_id,
        } => ArtifactApiError::new(
            code::WRONG_ENGINE,
            format!("operation {operation_id} uses engine {actual}; expected {expected}"),
        ),
        OperationLogError::EmptyOperationId { sequence } => ArtifactApiError::new(
            code::EMPTY_OPERATION_ID,
            format!("operation at sequence {sequence} has an empty operation_id"),
        ),
        OperationLogError::EmptyDocumentId { operation_id } => ArtifactApiError::new(
            code::EMPTY_DOCUMENT_ID,
            format!("operation {operation_id} has an empty document_id"),
        ),
        OperationLogError::EmptyArtifactDocumentId => ArtifactApiError::new(
            code::EMPTY_ARTIFACT_DOCUMENT_ID,
            "artifact document_id must not be empty",
        ),
        OperationLogError::EmptyActorId { operation_id } => ArtifactApiError::new(
            code::EMPTY_ACTOR_ID,
            format!("operation {operation_id} has an empty actor_id"),
        ),
        OperationLogError::InvalidSequence {
            operation_id,
            sequence,
        } => ArtifactApiError::new(
            code::INVALID_SEQUENCE,
            format!("operation {operation_id} has invalid sequence {sequence}"),
        ),
        OperationLogError::DuplicateOperationId { operation_id } => ArtifactApiError::new(
            code::DUPLICATE_OPERATION_ID,
            format!("operation_id {operation_id} appears more than once"),
        ),
        OperationLogError::NonMonotonicSequence {
            operation_id,
            previous,
            actual,
        } => ArtifactApiError::new(
            code::NON_MONOTONIC_SEQUENCE,
            format!("operation {operation_id} sequence {actual} must be greater than {previous}"),
        ),
        OperationLogError::OperationDocumentMismatch {
            operation_id,
            expected,
            actual,
        } => ArtifactApiError::new(
            code::OPERATION_DOCUMENT_MISMATCH,
            format!("operation {operation_id} targets {actual}; expected {expected}"),
        ),
    }
}
