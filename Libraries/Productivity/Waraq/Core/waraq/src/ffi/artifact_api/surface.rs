//! Canonical artifact FFI surface manifest.
//!
//! This module records the host-visible artifact function names and their
//! capability bucket in one place. Capabilities JSON and drift tests read from
//! this manifest so native declarations, smokes, and docs stay aligned.

use serde::Serialize;

/// Capability bucket used to advertise an artifact FFI function to hosts.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum ArtifactApiFunctionKind {
    /// Runtime metadata and contract discovery functions.
    Metadata,
    /// Legacy functions that return null on failure.
    Legacy,
    /// Result-envelope functions that return `{ ok, value, error }` JSON.
    Result,
}

impl ArtifactApiFunctionKind {
    /// Stable host-readable identifier for this capability bucket.
    pub(super) const fn id(self) -> &'static str {
        match self {
            Self::Metadata => "metadata",
            Self::Legacy => "legacy",
            Self::Result => "result",
        }
    }
}

/// Callable C ABI shape used by a host-visible artifact FFI function.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum ArtifactApiSignature {
    /// `char* function(void)`.
    NoArgsString,
    /// `char* function(const EditorHandle*, const char*, const char*)`.
    Capture,
    /// `EditorHandle* function(const char*)`.
    Restore,
    /// `char* function(EditorHandle*, const char*)`.
    EditorJson,
    /// `char* function(const char*, uint64_t, uint64_t)`.
    ArtifactTwoU64,
    /// `char* function(const char*, uint64_t, uint64_t, uint64_t)`.
    ArtifactThreeU64,
    /// `char* function(const char*)`.
    ArtifactString,
    /// `char* function(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, const char*)`.
    OperationInsert,
    /// `char* function(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, uint64_t)`.
    OperationDelete,
    /// `char* function(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, uint64_t, const char*)`.
    OperationReplace,
    /// `char* function(const char*, const char*)`.
    OperationLogAppend,
    /// `char* function(const char*, const char*, const char*)`.
    OperationLogAppendForDocument,
    /// `char* function(const char*)`.
    OperationLogValidate,
    /// `char* function(const char*, const char*)`.
    OperationLogValidateForDocument,
}

impl ArtifactApiSignature {
    /// Stable host-readable identifier for this native ABI signature family.
    pub(super) const fn id(self) -> &'static str {
        match self {
            Self::NoArgsString => "no_args_string",
            Self::Capture => "capture",
            Self::Restore => "restore",
            Self::EditorJson => "editor_json",
            Self::ArtifactTwoU64 => "artifact_two_u64",
            Self::ArtifactThreeU64 => "artifact_three_u64",
            Self::ArtifactString => "artifact_string",
            Self::OperationInsert => "operation_insert",
            Self::OperationDelete => "operation_delete",
            Self::OperationReplace => "operation_replace",
            Self::OperationLogAppend => "operation_log_append",
            Self::OperationLogAppendForDocument => "operation_log_append_for_document",
            Self::OperationLogValidate => "operation_log_validate",
            Self::OperationLogValidateForDocument => "operation_log_validate_for_document",
        }
    }

    /// C function-pointer signature text that bindings can use for validation.
    pub(super) const fn c_signature(self) -> &'static str {
        match self {
            Self::NoArgsString => "char* (*)(void)",
            Self::Capture => "char* (*)(const EditorHandle*, const char*, const char*)",
            Self::Restore => "EditorHandle* (*)(const char*)",
            Self::EditorJson => "char* (*)(EditorHandle*, const char*)",
            Self::ArtifactTwoU64 => "char* (*)(const char*, uint64_t, uint64_t)",
            Self::ArtifactThreeU64 => "char* (*)(const char*, uint64_t, uint64_t, uint64_t)",
            Self::ArtifactString => "char* (*)(const char*)",
            Self::OperationInsert => {
                "char* (*)(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, const char*)"
            }
            Self::OperationDelete => {
                "char* (*)(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, uint64_t)"
            }
            Self::OperationReplace => {
                "char* (*)(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, uint64_t, const char*)"
            }
            Self::OperationLogAppend => "char* (*)(const char*, const char*)",
            Self::OperationLogAppendForDocument => {
                "char* (*)(const char*, const char*, const char*)"
            }
            Self::OperationLogValidate => "char* (*)(const char*)",
            Self::OperationLogValidateForDocument => "char* (*)(const char*, const char*)",
        }
    }
}

/// Semantic payload shape returned by a host-visible artifact FFI function.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum ArtifactApiPayloadKind {
    /// Artifact API capability discovery payload.
    Capabilities,
    /// Shared artifact contract description payload.
    ArtifactContract,
    /// Shared Waraq core/domain boundary manifest payload.
    WaraqBoundaryManifest,
    /// Waraq-family engine registry payload.
    WaraqEngineRegistry,
    /// Waraq family engine-id resolution payload.
    WaraqEngineIdResolution,
    /// Compact shared artifact readiness manifest payload.
    ArtifactReadinessManifest,
    /// Shared artifact test-profile readiness report payload.
    ArtifactTestProfile,
    /// Representative artifact lifecycle readiness proof payload.
    ArtifactLifecycleProfile,
    /// Raw editor handle returned by a handle-producing legacy call.
    EditorHandle,
    /// Serialized `OperationArtifact` payload.
    Artifact,
    /// Summary returned after applying one operation to an editor.
    ApplySummary,
    /// Summary returned after replaying an operation log.
    ReplaySummary,
    /// Maintenance decision payload for artifact compaction.
    MaintenancePlan,
    /// Summary returned after validating an artifact payload.
    ArtifactValidationSummary,
    /// Summary returned after preflighting an artifact restore.
    ArtifactRestorePreflightSummary,
    /// Serialized operation envelope payload.
    OperationEnvelope,
    /// Serialized operation log payload.
    OperationLog,
    /// Summary returned after validating an operation log.
    OperationLogValidationSummary,
}

impl ArtifactApiPayloadKind {
    /// Stable host-readable payload-family identifier.
    pub(super) const fn id(self) -> &'static str {
        match self {
            Self::Capabilities => "artifact_api_capabilities",
            Self::ArtifactContract => "artifact_contract",
            Self::WaraqBoundaryManifest => "waraq_boundary_manifest",
            Self::WaraqEngineRegistry => "waraq_engine_registry",
            Self::WaraqEngineIdResolution => "waraq_engine_id_resolution",
            Self::ArtifactReadinessManifest => "artifact_readiness_manifest",
            Self::ArtifactTestProfile => "artifact_test_profile",
            Self::ArtifactLifecycleProfile => "artifact_lifecycle_profile",
            Self::EditorHandle => "editor_handle",
            Self::Artifact => "artifact",
            Self::ApplySummary => "apply_summary",
            Self::ReplaySummary => "replay_summary",
            Self::MaintenancePlan => "maintenance_plan",
            Self::ArtifactValidationSummary => "artifact_validation_summary",
            Self::ArtifactRestorePreflightSummary => "artifact_restore_preflight_summary",
            Self::OperationEnvelope => "operation_envelope",
            Self::OperationLog => "operation_log",
            Self::OperationLogValidationSummary => "operation_log_validation_summary",
        }
    }

    /// Short host-readable description of the payload shape.
    pub(super) const fn description(self) -> &'static str {
        match self {
            Self::Capabilities => "Artifact API capability discovery object.",
            Self::ArtifactContract => "Shared Waraq artifact contract description object.",
            Self::WaraqBoundaryManifest => "Shared Waraq core/domain boundary manifest.",
            Self::WaraqEngineRegistry => "Waraq-family canonical and legacy engine registry.",
            Self::WaraqEngineIdResolution => {
                "Resolved Waraq-family canonical or legacy engine identity."
            }
            Self::ArtifactReadinessManifest => "Compact shared artifact readiness manifest.",
            Self::ArtifactTestProfile => "Validated shared artifact test-profile readiness report.",
            Self::ArtifactLifecycleProfile => {
                "Validated representative artifact lifecycle readiness proof."
            }
            Self::EditorHandle => "Opaque EditorHandle pointer returned by a legacy restore call.",
            Self::Artifact => "Serialized OperationArtifact object.",
            Self::ApplySummary => "Operation application summary object.",
            Self::ReplaySummary => "Operation-log replay summary object.",
            Self::MaintenancePlan => "Artifact maintenance and compaction decision object.",
            Self::ArtifactValidationSummary => "Artifact validation summary object.",
            Self::ArtifactRestorePreflightSummary => {
                "Restore preflight summary object for host open flows."
            }
            Self::OperationEnvelope => "Serialized operation envelope object.",
            Self::OperationLog => "Serialized operation log object.",
            Self::OperationLogValidationSummary => "Operation-log validation summary object.",
        }
    }
}

/// Host-readable function group for one native ABI signature family.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiSignatureFamily {
    /// Stable signature family identifier.
    pub id: &'static str,
    /// C function-pointer signature text.
    pub c_signature: &'static str,
    /// Exported artifact functions that use this signature family.
    pub functions: Vec<&'static str>,
}

/// Host-readable description of one artifact FFI function.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiFunctionDescription {
    /// Exported C symbol name.
    pub name: &'static str,
    /// Capability bucket: `metadata`, `legacy`, or `result`.
    pub kind: &'static str,
    /// Semantic payload family returned directly or as a result success value.
    pub payload_family: &'static str,
    /// Stable native ABI signature-family identifier.
    pub signature_family: &'static str,
    /// C function-pointer signature text.
    pub c_signature: &'static str,
}

/// Host-readable group of functions returning the same semantic payload shape.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiPayloadFamily {
    /// Stable payload-family identifier.
    pub id: &'static str,
    /// Short host-readable description of the payload shape.
    pub description: &'static str,
    /// Exported artifact functions returning this payload directly or as a
    /// result-envelope success value.
    pub functions: Vec<&'static str>,
}

/// Host-readable mapping from a nullable source function to its result variant.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiResultFunctionPair {
    /// Existing metadata or legacy function that hosts may be migrating from.
    pub source_function: &'static str,
    /// Capability bucket of the source function: `metadata` or `legacy`.
    pub source_kind: &'static str,
    /// Preferred result-envelope function.
    pub result_function: &'static str,
    /// Stable native ABI signature-family identifier shared by both functions.
    pub signature_family: &'static str,
    /// C function-pointer signature text shared by both functions.
    pub c_signature: &'static str,
}

/// Host-readable description of a legacy function without a result variant.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub(super) struct ArtifactApiLegacyResultGap {
    /// Legacy exported C symbol name.
    pub legacy_function: &'static str,
    /// Stable native ABI signature-family identifier.
    pub signature_family: &'static str,
    /// C function-pointer signature text.
    pub c_signature: &'static str,
    /// Why this legacy call does not currently have a result-envelope variant.
    pub reason: &'static str,
}

/// One host-visible artifact FFI function in the canonical surface manifest.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) struct ArtifactApiFunction {
    /// Exported C symbol name.
    pub name: &'static str,
    /// Capabilities JSON bucket that should advertise this function.
    pub kind: ArtifactApiFunctionKind,
    /// Exact C ABI signature family expected by native hosts.
    pub signature: ArtifactApiSignature,
    /// Semantic payload shape returned directly or as a result success value.
    pub payload: ArtifactApiPayloadKind,
}

impl ArtifactApiFunction {
    const fn metadata(
        name: &'static str,
        signature: ArtifactApiSignature,
        payload: ArtifactApiPayloadKind,
    ) -> Self {
        Self {
            name,
            kind: ArtifactApiFunctionKind::Metadata,
            signature,
            payload,
        }
    }

    const fn legacy(
        name: &'static str,
        signature: ArtifactApiSignature,
        payload: ArtifactApiPayloadKind,
    ) -> Self {
        Self {
            name,
            kind: ArtifactApiFunctionKind::Legacy,
            signature,
            payload,
        }
    }

    const fn result(
        name: &'static str,
        signature: ArtifactApiSignature,
        payload: ArtifactApiPayloadKind,
    ) -> Self {
        Self {
            name,
            kind: ArtifactApiFunctionKind::Result,
            signature,
            payload,
        }
    }
}

/// Canonical list of host-visible artifact FFI functions.
pub(super) const ARTIFACT_API_FUNCTIONS: &[ArtifactApiFunction] = &[
    ArtifactApiFunction::metadata(
        "editor_artifact_capabilities_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::Capabilities,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_contract_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactContract,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_boundary_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::WaraqBoundaryManifest,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_engine_registry_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::WaraqEngineRegistry,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_readiness_manifest_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactReadinessManifest,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_test_profile_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactTestProfile,
    ),
    ArtifactApiFunction::metadata(
        "editor_artifact_lifecycle_profile_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactLifecycleProfile,
    ),
    ArtifactApiFunction::legacy(
        "editor_artifact_capture",
        ArtifactApiSignature::Capture,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::legacy(
        "editor_artifact_restore",
        ArtifactApiSignature::Restore,
        ArtifactApiPayloadKind::EditorHandle,
    ),
    ArtifactApiFunction::legacy(
        "editor_apply_operation_json",
        ArtifactApiSignature::EditorJson,
        ArtifactApiPayloadKind::ApplySummary,
    ),
    ArtifactApiFunction::legacy(
        "editor_replay_log_json",
        ArtifactApiSignature::EditorJson,
        ArtifactApiPayloadKind::ReplaySummary,
    ),
    ArtifactApiFunction::legacy(
        "editor_artifact_compact",
        ArtifactApiSignature::ArtifactTwoU64,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::legacy(
        "editor_artifact_maintenance_plan",
        ArtifactApiSignature::ArtifactTwoU64,
        ArtifactApiPayloadKind::MaintenancePlan,
    ),
    ArtifactApiFunction::legacy(
        "editor_artifact_maintain",
        ArtifactApiSignature::ArtifactThreeU64,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_insert_json",
        ArtifactApiSignature::OperationInsert,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_delete_json",
        ArtifactApiSignature::OperationDelete,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_replace_json",
        ArtifactApiSignature::OperationReplace,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_log_empty_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_log_append_json",
        ArtifactApiSignature::OperationLogAppend,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_log_append_for_document_json",
        ArtifactApiSignature::OperationLogAppendForDocument,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_log_validate_json",
        ArtifactApiSignature::OperationLogValidate,
        ArtifactApiPayloadKind::OperationLogValidationSummary,
    ),
    ArtifactApiFunction::legacy(
        "editor_operation_log_validate_for_document_json",
        ArtifactApiSignature::OperationLogValidateForDocument,
        ArtifactApiPayloadKind::OperationLogValidationSummary,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_capabilities_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::Capabilities,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_contract_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactContract,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_boundary_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::WaraqBoundaryManifest,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_engine_registry_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::WaraqEngineRegistry,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_resolve_engine_id_result_json",
        ArtifactApiSignature::ArtifactString,
        ArtifactApiPayloadKind::WaraqEngineIdResolution,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_engine_contract_result_json",
        ArtifactApiSignature::ArtifactString,
        ArtifactApiPayloadKind::ArtifactContract,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_engine_readiness_manifest_result_json",
        ArtifactApiSignature::ArtifactString,
        ArtifactApiPayloadKind::ArtifactReadinessManifest,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_capture_result_json",
        ArtifactApiSignature::Capture,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::result(
        "editor_apply_operation_result_json",
        ArtifactApiSignature::EditorJson,
        ArtifactApiPayloadKind::ApplySummary,
    ),
    ArtifactApiFunction::result(
        "editor_replay_log_result_json",
        ArtifactApiSignature::EditorJson,
        ArtifactApiPayloadKind::ReplaySummary,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_restore_preflight_result_json",
        ArtifactApiSignature::ArtifactString,
        ArtifactApiPayloadKind::ArtifactRestorePreflightSummary,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_compact_result_json",
        ArtifactApiSignature::ArtifactTwoU64,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_maintenance_plan_result_json",
        ArtifactApiSignature::ArtifactTwoU64,
        ArtifactApiPayloadKind::MaintenancePlan,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_maintain_result_json",
        ArtifactApiSignature::ArtifactThreeU64,
        ArtifactApiPayloadKind::Artifact,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_validate_result_json",
        ArtifactApiSignature::ArtifactString,
        ArtifactApiPayloadKind::ArtifactValidationSummary,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_readiness_manifest_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactReadinessManifest,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_test_profile_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactTestProfile,
    ),
    ArtifactApiFunction::result(
        "editor_artifact_lifecycle_profile_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::ArtifactLifecycleProfile,
    ),
    ArtifactApiFunction::result(
        "editor_operation_insert_result_json",
        ArtifactApiSignature::OperationInsert,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::result(
        "editor_operation_delete_result_json",
        ArtifactApiSignature::OperationDelete,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::result(
        "editor_operation_replace_result_json",
        ArtifactApiSignature::OperationReplace,
        ArtifactApiPayloadKind::OperationEnvelope,
    ),
    ArtifactApiFunction::result(
        "editor_operation_log_empty_result_json",
        ArtifactApiSignature::NoArgsString,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::result(
        "editor_operation_log_append_result_json",
        ArtifactApiSignature::OperationLogAppend,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::result(
        "editor_operation_log_append_for_document_result_json",
        ArtifactApiSignature::OperationLogAppendForDocument,
        ArtifactApiPayloadKind::OperationLog,
    ),
    ArtifactApiFunction::result(
        "editor_operation_log_validate_result_json",
        ArtifactApiSignature::OperationLogValidate,
        ArtifactApiPayloadKind::OperationLogValidationSummary,
    ),
    ArtifactApiFunction::result(
        "editor_operation_log_validate_for_document_result_json",
        ArtifactApiSignature::OperationLogValidateForDocument,
        ArtifactApiPayloadKind::OperationLogValidationSummary,
    ),
];

const ARTIFACT_API_SIGNATURES: &[ArtifactApiSignature] = &[
    ArtifactApiSignature::NoArgsString,
    ArtifactApiSignature::Capture,
    ArtifactApiSignature::Restore,
    ArtifactApiSignature::EditorJson,
    ArtifactApiSignature::ArtifactTwoU64,
    ArtifactApiSignature::ArtifactThreeU64,
    ArtifactApiSignature::ArtifactString,
    ArtifactApiSignature::OperationInsert,
    ArtifactApiSignature::OperationDelete,
    ArtifactApiSignature::OperationReplace,
    ArtifactApiSignature::OperationLogAppend,
    ArtifactApiSignature::OperationLogAppendForDocument,
    ArtifactApiSignature::OperationLogValidate,
    ArtifactApiSignature::OperationLogValidateForDocument,
];

const ARTIFACT_API_PAYLOADS: &[ArtifactApiPayloadKind] = &[
    ArtifactApiPayloadKind::Capabilities,
    ArtifactApiPayloadKind::ArtifactContract,
    ArtifactApiPayloadKind::WaraqBoundaryManifest,
    ArtifactApiPayloadKind::WaraqEngineRegistry,
    ArtifactApiPayloadKind::WaraqEngineIdResolution,
    ArtifactApiPayloadKind::ArtifactReadinessManifest,
    ArtifactApiPayloadKind::ArtifactTestProfile,
    ArtifactApiPayloadKind::ArtifactLifecycleProfile,
    ArtifactApiPayloadKind::EditorHandle,
    ArtifactApiPayloadKind::Artifact,
    ArtifactApiPayloadKind::ApplySummary,
    ArtifactApiPayloadKind::ReplaySummary,
    ArtifactApiPayloadKind::MaintenancePlan,
    ArtifactApiPayloadKind::ArtifactValidationSummary,
    ArtifactApiPayloadKind::ArtifactRestorePreflightSummary,
    ArtifactApiPayloadKind::OperationEnvelope,
    ArtifactApiPayloadKind::OperationLog,
    ArtifactApiPayloadKind::OperationLogValidationSummary,
];

const ARTIFACT_API_RESULT_PAIRS: &[(
    &'static str,
    ArtifactApiFunctionKind,
    &'static str,
    ArtifactApiSignature,
)] = &[
    (
        "editor_artifact_capabilities_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_capabilities_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_contract_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_contract_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_boundary_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_boundary_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_engine_registry_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_engine_registry_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_readiness_manifest_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_readiness_manifest_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_test_profile_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_test_profile_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_lifecycle_profile_json",
        ArtifactApiFunctionKind::Metadata,
        "editor_artifact_lifecycle_profile_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_artifact_capture",
        ArtifactApiFunctionKind::Legacy,
        "editor_artifact_capture_result_json",
        ArtifactApiSignature::Capture,
    ),
    (
        "editor_apply_operation_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_apply_operation_result_json",
        ArtifactApiSignature::EditorJson,
    ),
    (
        "editor_replay_log_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_replay_log_result_json",
        ArtifactApiSignature::EditorJson,
    ),
    (
        "editor_artifact_compact",
        ArtifactApiFunctionKind::Legacy,
        "editor_artifact_compact_result_json",
        ArtifactApiSignature::ArtifactTwoU64,
    ),
    (
        "editor_artifact_maintenance_plan",
        ArtifactApiFunctionKind::Legacy,
        "editor_artifact_maintenance_plan_result_json",
        ArtifactApiSignature::ArtifactTwoU64,
    ),
    (
        "editor_artifact_maintain",
        ArtifactApiFunctionKind::Legacy,
        "editor_artifact_maintain_result_json",
        ArtifactApiSignature::ArtifactThreeU64,
    ),
    (
        "editor_operation_insert_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_insert_result_json",
        ArtifactApiSignature::OperationInsert,
    ),
    (
        "editor_operation_delete_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_delete_result_json",
        ArtifactApiSignature::OperationDelete,
    ),
    (
        "editor_operation_replace_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_replace_result_json",
        ArtifactApiSignature::OperationReplace,
    ),
    (
        "editor_operation_log_empty_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_log_empty_result_json",
        ArtifactApiSignature::NoArgsString,
    ),
    (
        "editor_operation_log_append_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_log_append_result_json",
        ArtifactApiSignature::OperationLogAppend,
    ),
    (
        "editor_operation_log_append_for_document_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_log_append_for_document_result_json",
        ArtifactApiSignature::OperationLogAppendForDocument,
    ),
    (
        "editor_operation_log_validate_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_log_validate_result_json",
        ArtifactApiSignature::OperationLogValidate,
    ),
    (
        "editor_operation_log_validate_for_document_json",
        ArtifactApiFunctionKind::Legacy,
        "editor_operation_log_validate_for_document_result_json",
        ArtifactApiSignature::OperationLogValidateForDocument,
    ),
];

const ARTIFACT_API_RESULT_ONLY_FUNCTIONS: &[&str] = &[
    "editor_artifact_resolve_engine_id_result_json",
    "editor_artifact_engine_contract_result_json",
    "editor_artifact_engine_readiness_manifest_result_json",
    "editor_artifact_restore_preflight_result_json",
    "editor_artifact_validate_result_json",
];

const ARTIFACT_API_LEGACY_RESULT_GAPS: &[(&'static str, ArtifactApiSignature, &'static str)] = &[
    (
        "editor_artifact_restore",
        ArtifactApiSignature::Restore,
        "returns an EditorHandle*; hosts should call editor_artifact_restore_preflight_result_json for result-envelope diagnostics before this handle-returning call",
    ),
];

/// Return function names in manifest order for one capabilities bucket.
pub(super) fn artifact_api_function_names(kind: ArtifactApiFunctionKind) -> Vec<&'static str> {
    ARTIFACT_API_FUNCTIONS
        .iter()
        .filter_map(|function| {
            if function.kind == kind {
                Some(function.name)
            } else {
                None
            }
        })
        .collect()
}

/// Return function names in manifest order for one native ABI signature family.
pub(super) fn artifact_api_function_names_by_signature(
    signature: ArtifactApiSignature,
) -> Vec<&'static str> {
    ARTIFACT_API_FUNCTIONS
        .iter()
        .filter_map(|function| {
            if function.signature == signature {
                Some(function.name)
            } else {
                None
            }
        })
        .collect()
}

/// Return function names in manifest order for one semantic payload family.
pub(super) fn artifact_api_function_names_by_payload(
    payload: ArtifactApiPayloadKind,
) -> Vec<&'static str> {
    ARTIFACT_API_FUNCTIONS
        .iter()
        .filter_map(|function| {
            if function.payload == payload {
                Some(function.name)
            } else {
                None
            }
        })
        .collect()
}

/// Return host-readable ABI signature families in manifest order.
pub(super) fn artifact_api_signature_families() -> Vec<ArtifactApiSignatureFamily> {
    ARTIFACT_API_SIGNATURES
        .iter()
        .map(|signature| ArtifactApiSignatureFamily {
            id: signature.id(),
            c_signature: signature.c_signature(),
            functions: artifact_api_function_names_by_signature(*signature),
        })
        .collect()
}

/// Return host-readable semantic payload families in manifest order.
pub(super) fn artifact_api_payload_families() -> Vec<ArtifactApiPayloadFamily> {
    ARTIFACT_API_PAYLOADS
        .iter()
        .map(|payload| ArtifactApiPayloadFamily {
            id: payload.id(),
            description: payload.description(),
            functions: artifact_api_function_names_by_payload(*payload),
        })
        .collect()
}

/// Return a host-readable catalog entry for every artifact FFI function.
pub(super) fn artifact_api_function_catalog() -> Vec<ArtifactApiFunctionDescription> {
    ARTIFACT_API_FUNCTIONS
        .iter()
        .map(|function| ArtifactApiFunctionDescription {
            name: function.name,
            kind: function.kind.id(),
            payload_family: function.payload.id(),
            signature_family: function.signature.id(),
            c_signature: function.signature.c_signature(),
        })
        .collect()
}

/// Return nullable source functions paired with preferred result variants.
pub(super) fn artifact_api_result_function_pairs() -> Vec<ArtifactApiResultFunctionPair> {
    ARTIFACT_API_RESULT_PAIRS
        .iter()
        .map(
            |(source_function, source_kind, result_function, signature)| {
                ArtifactApiResultFunctionPair {
                    source_function,
                    source_kind: source_kind.id(),
                    result_function,
                    signature_family: signature.id(),
                    c_signature: signature.c_signature(),
                }
            },
        )
        .collect()
}

/// Return result-envelope functions that do not replace a nullable source call.
pub(super) fn artifact_api_result_only_functions() -> Vec<&'static str> {
    ARTIFACT_API_RESULT_ONLY_FUNCTIONS.to_vec()
}

/// Return legacy functions that intentionally do not have result variants.
pub(super) fn artifact_api_legacy_result_gaps() -> Vec<ArtifactApiLegacyResultGap> {
    ARTIFACT_API_LEGACY_RESULT_GAPS
        .iter()
        .map(
            |(legacy_function, signature, reason)| ArtifactApiLegacyResultGap {
                legacy_function,
                signature_family: signature.id(),
                c_signature: signature.c_signature(),
                reason,
            },
        )
        .collect()
}
