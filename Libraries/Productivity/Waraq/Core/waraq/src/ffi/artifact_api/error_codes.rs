//! Stable artifact API error-code catalog.
//!
//! Result-oriented artifact FFI functions return these machine-readable codes
//! in `error.code`. Capabilities JSON exposes this catalog so hosts can group
//! and describe failures without hard-coding Waraq-specific messages.

use serde::Serialize;

/// Stable artifact API error-code constants used by result-envelope emitters.
pub(super) mod code {
    pub(in crate::ffi::artifact_api) const NULL_HANDLE: &str = "null_handle";
    pub(in crate::ffi::artifact_api) const NULL_ARTIFACT_JSON: &str = "null_artifact_json";
    pub(in crate::ffi::artifact_api) const NULL_OPERATION_ID: &str = "null_operation_id";
    pub(in crate::ffi::artifact_api) const NULL_DOCUMENT_ID: &str = "null_document_id";
    pub(in crate::ffi::artifact_api) const NULL_ACTOR_ID: &str = "null_actor_id";
    pub(in crate::ffi::artifact_api) const NULL_OPERATION_JSON: &str = "null_operation_json";
    pub(in crate::ffi::artifact_api) const NULL_OPERATION_LOG_JSON: &str =
        "null_operation_log_json";
    pub(in crate::ffi::artifact_api) const NULL_TEXT: &str = "null_text";
    pub(in crate::ffi::artifact_api) const NULL_ENGINE_ID: &str = "null_engine_id";
    pub(in crate::ffi::artifact_api) const INVALID_UTF8: &str = "invalid_utf8";
    pub(in crate::ffi::artifact_api) const INTEGER_OUT_OF_RANGE: &str = "integer_out_of_range";
    pub(in crate::ffi::artifact_api) const UNKNOWN_WARAQ_FAMILY_ENGINE: &str =
        "unknown_waraq_family_engine";
    pub(in crate::ffi::artifact_api) const INVALID_DOCUMENT_ID: &str = "invalid_document_id";
    pub(in crate::ffi::artifact_api) const INVALID_ARTIFACT_JSON: &str = "invalid_artifact_json";
    pub(in crate::ffi::artifact_api) const INVALID_OPERATION_JSON: &str = "invalid_operation_json";
    pub(in crate::ffi::artifact_api) const INVALID_OPERATION_LOG_JSON: &str =
        "invalid_operation_log_json";
    pub(in crate::ffi::artifact_api) const SERIALIZATION_FAILED: &str = "serialization_failed";
    pub(in crate::ffi::artifact_api) const ARTIFACT_CAPABILITIES_UNAVAILABLE: &str =
        "artifact_capabilities_unavailable";
    pub(in crate::ffi::artifact_api) const ARTIFACT_ENGINE_REGISTRY_UNAVAILABLE: &str =
        "artifact_engine_registry_unavailable";
    pub(in crate::ffi::artifact_api) const ARTIFACT_READINESS_MANIFEST_UNAVAILABLE: &str =
        "artifact_readiness_manifest_unavailable";
    pub(in crate::ffi::artifact_api) const ARTIFACT_TEST_PROFILE_UNAVAILABLE: &str =
        "artifact_test_profile_unavailable";
    pub(in crate::ffi::artifact_api) const ARTIFACT_LIFECYCLE_PROFILE_UNAVAILABLE: &str =
        "artifact_lifecycle_profile_unavailable";
    pub(in crate::ffi::artifact_api) const INVALID_OFFSET: &str = "invalid_offset";
    pub(in crate::ffi::artifact_api) const INVALID_RANGE: &str = "invalid_range";
    pub(in crate::ffi::artifact_api) const INVALID_UTF8_BOUNDARY: &str = "invalid_utf8_boundary";
    pub(in crate::ffi::artifact_api) const SNAPSHOT_DOCUMENT_MISMATCH: &str =
        "snapshot_document_mismatch";
    pub(in crate::ffi::artifact_api) const UNSUPPORTED_SCHEMA_VERSION: &str =
        "unsupported_schema_version";
    pub(in crate::ffi::artifact_api) const WRONG_ENGINE: &str = "wrong_engine";
    pub(in crate::ffi::artifact_api) const EMPTY_OPERATION_ID: &str = "empty_operation_id";
    pub(in crate::ffi::artifact_api) const EMPTY_DOCUMENT_ID: &str = "empty_document_id";
    pub(in crate::ffi::artifact_api) const EMPTY_ARTIFACT_DOCUMENT_ID: &str =
        "empty_artifact_document_id";
    pub(in crate::ffi::artifact_api) const EMPTY_ACTOR_ID: &str = "empty_actor_id";
    pub(in crate::ffi::artifact_api) const INVALID_SEQUENCE: &str = "invalid_sequence";
    pub(in crate::ffi::artifact_api) const DUPLICATE_OPERATION_ID: &str = "duplicate_operation_id";
    pub(in crate::ffi::artifact_api) const NON_MONOTONIC_SEQUENCE: &str = "non_monotonic_sequence";
    pub(in crate::ffi::artifact_api) const OPERATION_DOCUMENT_MISMATCH: &str =
        "operation_document_mismatch";
}

/// Host-readable description of one stable artifact API error code.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiErrorCodeDescription {
    /// Stable machine-readable error code returned in result envelopes.
    pub code: &'static str,
    /// Stable grouping for host telemetry, logs, and UI handling.
    pub category: &'static str,
    /// Short human-readable meaning of the error code.
    pub description: &'static str,
}

/// Canonical artifact API error-code catalog in capabilities order.
pub(in crate::ffi::artifact_api) const ARTIFACT_ERROR_CODE_CATALOG:
    &[ArtifactApiErrorCodeDescription] = &[
    ArtifactApiErrorCodeDescription {
        code: code::NULL_HANDLE,
        category: "host_input",
        description: "A required EditorHandle pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_ARTIFACT_JSON,
        category: "host_input",
        description: "A required artifact JSON pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_OPERATION_ID,
        category: "host_input",
        description: "A required operation_id pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_DOCUMENT_ID,
        category: "host_input",
        description: "A required document_id pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_ACTOR_ID,
        category: "host_input",
        description: "A required actor_id pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_OPERATION_JSON,
        category: "host_input",
        description: "A required operation JSON pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_OPERATION_LOG_JSON,
        category: "host_input",
        description: "A required operation-log JSON pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_TEXT,
        category: "host_input",
        description: "A required text pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NULL_ENGINE_ID,
        category: "host_input",
        description: "A required engine_id pointer was null.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_UTF8,
        category: "host_input",
        description: "A host string pointer did not contain valid UTF-8.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INTEGER_OUT_OF_RANGE,
        category: "host_input",
        description: "A host integer parameter could not fit the engine index type.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_DOCUMENT_ID,
        category: "document_validation",
        description: "A document_id was empty or otherwise invalid for the requested operation.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::UNKNOWN_WARAQ_FAMILY_ENGINE,
        category: "engine_identity",
        description: "An engine_id was not a registered Waraq-family canonical id or legacy alias.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_ARTIFACT_JSON,
        category: "host_json",
        description: "Artifact JSON could not be parsed or did not match the artifact schema.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_OPERATION_JSON,
        category: "host_json",
        description: "Operation JSON could not be parsed or did not match the operation schema.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_OPERATION_LOG_JSON,
        category: "host_json",
        description: "Operation-log JSON could not be parsed or did not match the log schema.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::SERIALIZATION_FAILED,
        category: "serialization",
        description: "The engine could not serialize an artifact API response.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::ARTIFACT_CAPABILITIES_UNAVAILABLE,
        category: "artifact_readiness",
        description: "The engine could not build its artifact API capabilities.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::ARTIFACT_ENGINE_REGISTRY_UNAVAILABLE,
        category: "engine_identity",
        description: "The Waraq-family engine registry could not be validated.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::ARTIFACT_READINESS_MANIFEST_UNAVAILABLE,
        category: "artifact_readiness",
        description: "The engine could not build its artifact readiness manifest.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::ARTIFACT_TEST_PROFILE_UNAVAILABLE,
        category: "artifact_readiness",
        description: "The engine could not validate its artifact test profile readiness report.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::ARTIFACT_LIFECYCLE_PROFILE_UNAVAILABLE,
        category: "artifact_readiness",
        description: "The engine could not validate its artifact lifecycle readiness proof.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_OFFSET,
        category: "document_validation",
        description: "An edit offset was outside the document byte length.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_RANGE,
        category: "document_validation",
        description: "An edit byte range was invalid for the current document.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_UTF8_BOUNDARY,
        category: "document_validation",
        description: "An edit offset or range did not fall on a UTF-8 character boundary.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::SNAPSHOT_DOCUMENT_MISMATCH,
        category: "artifact_validation",
        description: "An artifact snapshot document_id did not match the expected document.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::UNSUPPORTED_SCHEMA_VERSION,
        category: "operation_log_validation",
        description: "An operation envelope used an unsupported schema_version.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::WRONG_ENGINE,
        category: "operation_log_validation",
        description: "An operation targeted a different engine identifier.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::EMPTY_OPERATION_ID,
        category: "operation_log_validation",
        description: "An operation envelope contained an empty operation_id.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::EMPTY_DOCUMENT_ID,
        category: "operation_log_validation",
        description: "An operation envelope contained an empty document_id.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::EMPTY_ARTIFACT_DOCUMENT_ID,
        category: "artifact_validation",
        description: "An artifact contained an empty document_id.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::EMPTY_ACTOR_ID,
        category: "operation_log_validation",
        description: "An operation envelope contained an empty actor_id.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::INVALID_SEQUENCE,
        category: "operation_log_validation",
        description: "An operation sequence number was not valid.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::DUPLICATE_OPERATION_ID,
        category: "operation_log_validation",
        description: "An operation log contained the same operation_id more than once.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::NON_MONOTONIC_SEQUENCE,
        category: "operation_log_validation",
        description: "Operation sequence numbers were not strictly increasing.",
    },
    ArtifactApiErrorCodeDescription {
        code: code::OPERATION_DOCUMENT_MISMATCH,
        category: "operation_log_validation",
        description: "An operation targeted a different document_id than its log or artifact.",
    },
];

/// Return stable error-code names in catalog order.
pub(super) fn artifact_error_codes() -> Vec<&'static str> {
    ARTIFACT_ERROR_CODE_CATALOG
        .iter()
        .map(|description| description.code)
        .collect()
}
