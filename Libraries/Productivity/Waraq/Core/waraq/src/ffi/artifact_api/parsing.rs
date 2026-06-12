//! C pointer parsing helpers for artifact FFI entry points.
//!
//! These helpers keep null, empty-string, UTF-8, and JSON decoding behavior
//! consistent across legacy null-return APIs and result-oriented APIs.

use super::error_codes::code;
use super::result::ArtifactApiError;
use crate::core::editor_artifact::{EditorArtifact, EditorOperation, EditorOperationLog};
use std::ffi::CStr;
use std::os::raw::c_char;

pub(super) fn document_id_from_ptr(ptr: *const c_char, fallback_file_uri: &str) -> Option<String> {
    if ptr.is_null() {
        return Some(non_empty_document_id(fallback_file_uri));
    }

    match unsafe { CStr::from_ptr(ptr) }.to_str() {
        Ok("") => Some(non_empty_document_id(fallback_file_uri)),
        Ok(s) => Some(s.to_owned()),
        Err(_) => None,
    }
}

fn non_empty_document_id(file_uri: &str) -> String {
    if file_uri.is_empty() {
        "untitled://waraq-editor".to_owned()
    } else {
        file_uri.to_owned()
    }
}

pub(super) fn editor_operation_log_from_ptr(ptr: *const c_char) -> Option<EditorOperationLog> {
    if ptr.is_null() {
        return Some(EditorOperationLog::new());
    }

    match unsafe { CStr::from_ptr(ptr) }.to_str() {
        Ok("") => Some(EditorOperationLog::new()),
        Ok(s) => EditorOperationLog::from_json(s).ok(),
        Err(_) => None,
    }
}

pub(super) fn editor_artifact_from_ptr(ptr: *const c_char) -> Option<EditorArtifact> {
    if ptr.is_null() {
        return None;
    }
    match unsafe { CStr::from_ptr(ptr) }.to_str() {
        Ok(s) => EditorArtifact::from_json(s).ok(),
        Err(_) => None,
    }
}

pub(super) fn required_document_id_from_ptr(
    ptr: *const c_char,
) -> Result<String, ArtifactApiError> {
    let document_id = required_string_from_ptr(ptr, "document_id", code::NULL_DOCUMENT_ID)?;
    if document_id.is_empty() {
        return Err(ArtifactApiError::new(
            code::INVALID_DOCUMENT_ID,
            "document_id must not be empty",
        ));
    }
    Ok(document_id)
}

pub(super) fn required_string_from_ptr(
    ptr: *const c_char,
    field_name: &str,
    null_code: &str,
) -> Result<String, ArtifactApiError> {
    if ptr.is_null() {
        return Err(ArtifactApiError::new(
            null_code,
            format!("{field_name} must not be null"),
        ));
    }

    unsafe { CStr::from_ptr(ptr) }
        .to_str()
        .map(ToOwned::to_owned)
        .map_err(|_| {
            ArtifactApiError::new(
                code::INVALID_UTF8,
                format!("{field_name} must be valid UTF-8"),
            )
        })
}

pub(super) fn document_id_from_ptr_result(
    ptr: *const c_char,
    fallback_file_uri: &str,
) -> Result<String, ArtifactApiError> {
    if ptr.is_null() {
        return Ok(non_empty_document_id(fallback_file_uri));
    }

    match unsafe { CStr::from_ptr(ptr) }.to_str() {
        Ok("") => Ok(non_empty_document_id(fallback_file_uri)),
        Ok(s) => Ok(s.to_owned()),
        Err(_) => Err(ArtifactApiError::new(
            code::INVALID_DOCUMENT_ID,
            "document_id must be valid UTF-8",
        )),
    }
}

pub(super) fn editor_operation_log_from_ptr_result(
    ptr: *const c_char,
    allow_empty_default: bool,
) -> Result<EditorOperationLog, ArtifactApiError> {
    if ptr.is_null() {
        if allow_empty_default {
            return Ok(EditorOperationLog::new());
        }
        return Err(ArtifactApiError::new(
            code::NULL_OPERATION_LOG_JSON,
            "operation_log_json must not be null",
        ));
    }

    let s = unsafe { CStr::from_ptr(ptr) }.to_str().map_err(|_| {
        ArtifactApiError::new(code::INVALID_UTF8, "operation_log_json must be valid UTF-8")
    })?;
    if s.is_empty() {
        return Ok(EditorOperationLog::new());
    }

    EditorOperationLog::from_json(s).map_err(|error| {
        ArtifactApiError::new(
            code::INVALID_OPERATION_LOG_JSON,
            format!("operation_log_json must be valid Waraq editor operation-log JSON: {error}"),
        )
    })
}

pub(super) fn editor_artifact_from_ptr_result(
    ptr: *const c_char,
) -> Result<EditorArtifact, ArtifactApiError> {
    if ptr.is_null() {
        return Err(ArtifactApiError::new(
            code::NULL_ARTIFACT_JSON,
            "artifact_json must not be null",
        ));
    }

    let s = unsafe { CStr::from_ptr(ptr) }.to_str().map_err(|_| {
        ArtifactApiError::new(code::INVALID_UTF8, "artifact_json must be valid UTF-8")
    })?;
    EditorArtifact::from_json(s).map_err(|error| {
        ArtifactApiError::new(
            code::INVALID_ARTIFACT_JSON,
            format!("artifact_json must be valid Waraq editor artifact JSON: {error}"),
        )
    })
}

pub(super) fn editor_operation_from_ptr_result(
    ptr: *const c_char,
) -> Result<EditorOperation, ArtifactApiError> {
    if ptr.is_null() {
        return Err(ArtifactApiError::new(
            code::NULL_OPERATION_JSON,
            "operation_json must not be null",
        ));
    }

    let s = unsafe { CStr::from_ptr(ptr) }.to_str().map_err(|_| {
        ArtifactApiError::new(code::INVALID_UTF8, "operation_json must be valid UTF-8")
    })?;
    EditorOperation::from_json(s).map_err(|error| {
        ArtifactApiError::new(
            code::INVALID_OPERATION_JSON,
            format!("operation_json must be valid Waraq editor operation JSON: {error}"),
        )
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    fn error_code(error: ArtifactApiError) -> String {
        serde_json::to_value(error)
            .unwrap()
            .get("code")
            .unwrap()
            .as_str()
            .unwrap()
            .to_owned()
    }

    fn invalid_utf8_ptr() -> *const c_char {
        static INVALID_UTF8: [u8; 2] = [0xff, 0x00];
        INVALID_UTF8.as_ptr().cast()
    }

    #[test]
    fn document_id_from_ptr_defaults_null_and_empty_to_fallback() {
        let empty = CString::new("").unwrap();
        let explicit = CString::new("file:///explicit.txt").unwrap();

        assert_eq!(
            document_id_from_ptr(std::ptr::null(), "file:///main.txt"),
            Some("file:///main.txt".to_owned())
        );
        assert_eq!(
            document_id_from_ptr(std::ptr::null(), ""),
            Some("untitled://waraq-editor".to_owned())
        );
        assert_eq!(
            document_id_from_ptr(empty.as_ptr(), "file:///main.txt"),
            Some("file:///main.txt".to_owned())
        );
        assert_eq!(
            document_id_from_ptr(explicit.as_ptr(), "file:///main.txt"),
            Some("file:///explicit.txt".to_owned())
        );
    }

    #[test]
    fn document_id_from_ptr_rejects_invalid_utf8() {
        assert_eq!(
            document_id_from_ptr(invalid_utf8_ptr(), "file:///main.txt"),
            None
        );
        assert_eq!(
            error_code(
                document_id_from_ptr_result(invalid_utf8_ptr(), "file:///main.txt").unwrap_err()
            ),
            "invalid_document_id"
        );
    }

    #[test]
    fn required_document_id_rejects_null_empty_and_invalid_utf8() {
        let empty = CString::new("").unwrap();
        let valid = CString::new("file:///main.txt").unwrap();

        assert_eq!(
            error_code(required_document_id_from_ptr(std::ptr::null()).unwrap_err()),
            "null_document_id"
        );
        assert_eq!(
            error_code(required_document_id_from_ptr(empty.as_ptr()).unwrap_err()),
            "invalid_document_id"
        );
        assert_eq!(
            error_code(required_document_id_from_ptr(invalid_utf8_ptr()).unwrap_err()),
            "invalid_utf8"
        );
        assert_eq!(
            required_document_id_from_ptr(valid.as_ptr()).unwrap(),
            "file:///main.txt"
        );
    }

    #[test]
    fn required_string_reports_field_specific_null_and_invalid_utf8() {
        let valid = CString::new("actor-1").unwrap();

        assert_eq!(
            error_code(
                required_string_from_ptr(std::ptr::null(), "actor_id", "null_actor_id")
                    .unwrap_err()
            ),
            "null_actor_id"
        );
        assert_eq!(
            error_code(
                required_string_from_ptr(invalid_utf8_ptr(), "actor_id", "null_actor_id")
                    .unwrap_err()
            ),
            "invalid_utf8"
        );
        assert_eq!(
            required_string_from_ptr(valid.as_ptr(), "actor_id", "null_actor_id").unwrap(),
            "actor-1"
        );
    }

    #[test]
    fn operation_log_parsers_default_empty_inputs_and_reject_bad_json() {
        let empty = CString::new("").unwrap();
        let invalid_json = CString::new("not json").unwrap();

        assert_eq!(
            editor_operation_log_from_ptr(std::ptr::null())
                .unwrap()
                .len(),
            0
        );
        assert_eq!(
            editor_operation_log_from_ptr(empty.as_ptr()).unwrap().len(),
            0
        );
        assert!(editor_operation_log_from_ptr(invalid_json.as_ptr()).is_none());
        assert_eq!(
            editor_operation_log_from_ptr_result(std::ptr::null(), true)
                .unwrap()
                .len(),
            0
        );
        assert_eq!(
            error_code(editor_operation_log_from_ptr_result(std::ptr::null(), false).unwrap_err()),
            "null_operation_log_json"
        );
        assert_eq!(
            editor_operation_log_from_ptr_result(empty.as_ptr(), false)
                .unwrap()
                .len(),
            0
        );
        assert_eq!(
            error_code(
                editor_operation_log_from_ptr_result(invalid_json.as_ptr(), true).unwrap_err()
            ),
            "invalid_operation_log_json"
        );
    }

    #[test]
    fn artifact_and_operation_result_parsers_report_expected_error_codes() {
        let invalid_json = CString::new("not json").unwrap();

        assert!(editor_artifact_from_ptr(std::ptr::null()).is_none());
        assert!(editor_artifact_from_ptr(invalid_json.as_ptr()).is_none());
        assert_eq!(
            error_code(editor_artifact_from_ptr_result(std::ptr::null()).unwrap_err()),
            "null_artifact_json"
        );
        assert_eq!(
            error_code(editor_artifact_from_ptr_result(invalid_json.as_ptr()).unwrap_err()),
            "invalid_artifact_json"
        );
        assert_eq!(
            error_code(editor_operation_from_ptr_result(std::ptr::null()).unwrap_err()),
            "null_operation_json"
        );
        assert_eq!(
            error_code(editor_operation_from_ptr_result(invalid_json.as_ptr()).unwrap_err()),
            "invalid_operation_json"
        );
    }
}
