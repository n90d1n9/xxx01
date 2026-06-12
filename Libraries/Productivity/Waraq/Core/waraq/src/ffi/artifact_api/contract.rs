//! Host-readable artifact API contract exposed through capabilities JSON.
//!
//! This module centralizes version, function-list, and error-code metadata so
//! embedders can discover the Waraq artifact FFI behavior at runtime.

use super::error_codes::{
    artifact_error_codes, code, ArtifactApiErrorCodeDescription, ARTIFACT_ERROR_CODE_CATALOG,
};
use super::parsing::required_string_from_ptr;
pub(super) use super::result::ARTIFACT_RESULT_ENVELOPE;
use super::result::{
    artifact_json_to_c_string, artifact_result_envelope_description, artifact_result_err,
    artifact_result_ok, ArtifactApiError, ArtifactApiResultEnvelopeDescription,
};
use super::surface::{
    artifact_api_function_catalog, artifact_api_function_names, artifact_api_legacy_result_gaps,
    artifact_api_payload_families, artifact_api_result_function_pairs,
    artifact_api_result_only_functions, artifact_api_signature_families,
    ArtifactApiFunctionDescription, ArtifactApiFunctionKind, ArtifactApiLegacyResultGap,
    ArtifactApiPayloadFamily, ArtifactApiResultFunctionPair, ArtifactApiSignatureFamily,
};
use crate::core::artifact_contract::{artifact_contract_description, ArtifactContractDescription};
use crate::core::artifact_engine_kit::{
    ArtifactEngineKit, ArtifactEngineKitBuildError, ArtifactEngineReadinessManifest,
};
use crate::core::artifact_test_profile::{
    domain_artifact_test_profile, validate_domain_artifact_test_profile_report,
    DomainArtifactTestProfileError, DomainArtifactTestProfileValidationReport,
};
use crate::core::editor_artifact::{
    editor_artifact_lifecycle_profile_report, EditorArtifactReadinessError, WARAQ_EDITOR_ENGINE_ID,
};
use crate::core::engine_boundary::{
    resolve_waraq_engine_id, validate_waraq_family_engine_registry, waraq_family_engine_registry,
    waraq_shared_core_boundary, WaraqEngineIdResolution, WaraqFamilyEngineRegistry,
    WaraqFamilyEngineRegistryError, WaraqSharedCoreBoundary,
};
use crate::core::operation::OPERATION_ENVELOPE_VERSION;
use serde::Serialize;
use std::os::raw::c_char;

/// Host-visible artifact FFI surface version.
///
/// Bump this when artifact capabilities, callable FFI functions, result-envelope
/// shape, or stable error-code names change.
pub(super) const ARTIFACT_API_VERSION: u32 = 30;

/// Host-readable description of the editor artifact FFI contract.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
struct ArtifactApiCapabilities {
    api_version: u32,
    crate_version: &'static str,
    engine: &'static str,
    envelope_schema_version: u32,
    result_envelope: &'static str,
    result_envelope_schema: ArtifactApiResultEnvelopeDescription,
    supports_legacy_null_returns: bool,
    supports_validation_summary: bool,
    supports_operation_builders: bool,
    supports_operation_log_builders: bool,
    supports_operation_log_document_append: bool,
    supports_operation_log_validation: bool,
    supports_operation_log_document_validation: bool,
    supports_artifact_contract_description: bool,
    supports_waraq_boundary_manifest: bool,
    supports_waraq_engine_registry: bool,
    supports_waraq_engine_id_resolution: bool,
    supports_waraq_engine_contract: bool,
    supports_waraq_engine_readiness_manifest: bool,
    supports_artifact_readiness_manifest: bool,
    supports_artifact_test_profile: bool,
    supports_artifact_lifecycle_profile: bool,
    supports_artifact_restore_preflight: bool,
    restore_returns_handle: bool,
    artifact_contract: ArtifactContractDescription,
    waraq_boundary_manifest: WaraqSharedCoreBoundary,
    waraq_engine_registry: WaraqFamilyEngineRegistry,
    artifact_readiness_manifest: ArtifactEngineReadinessManifest,
    metadata_functions: Vec<&'static str>,
    legacy_functions: Vec<&'static str>,
    result_functions: Vec<&'static str>,
    result_function_pairs: Vec<ArtifactApiResultFunctionPair>,
    result_only_functions: Vec<&'static str>,
    legacy_result_gaps: Vec<ArtifactApiLegacyResultGap>,
    payload_families: Vec<ArtifactApiPayloadFamily>,
    function_catalog: Vec<ArtifactApiFunctionDescription>,
    signature_families: Vec<ArtifactApiSignatureFamily>,
    error_codes: Vec<&'static str>,
    error_code_catalog: &'static [ArtifactApiErrorCodeDescription],
}

/// Return the shared Waraq editor artifact contract as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_contract_json() -> *mut c_char {
    let contract = artifact_contract_description(WARAQ_EDITOR_ENGINE_ID);
    artifact_json_to_c_string(&contract)
}

/// Return the shared Waraq editor artifact contract in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_contract_result_json() -> *mut c_char {
    artifact_result_ok(artifact_contract_description(WARAQ_EDITOR_ENGINE_ID))
}

/// Return the Waraq shared-core boundary manifest as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_boundary_json() -> *mut c_char {
    let boundary = waraq_shared_core_boundary();
    artifact_json_to_c_string(&boundary)
}

/// Return the Waraq shared-core boundary manifest in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_boundary_result_json() -> *mut c_char {
    artifact_result_ok(waraq_shared_core_boundary())
}

/// Return the Waraq-family engine registry as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_engine_registry_json() -> *mut c_char {
    match validated_waraq_family_engine_registry() {
        Ok(registry) => artifact_json_to_c_string(&registry),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return the Waraq-family engine registry in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_engine_registry_result_json() -> *mut c_char {
    match validated_waraq_family_engine_registry() {
        Ok(registry) => artifact_result_ok(registry),
        Err(error) => artifact_result_err(error),
    }
}

/// Resolve a Waraq-family canonical or legacy engine id in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_resolve_engine_id_result_json(
    engine_id: *const c_char,
) -> *mut c_char {
    match resolve_engine_id_from_ptr(engine_id) {
        Ok(resolution) => artifact_result_ok(resolution),
        Err(error) => artifact_result_err(error),
    }
}

/// Return a registered Waraq-family engine artifact contract in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_engine_contract_result_json(
    engine_id: *const c_char,
) -> *mut c_char {
    match engine_contract_from_ptr(engine_id) {
        Ok(contract) => artifact_result_ok(contract),
        Err(error) => artifact_result_err(error),
    }
}

/// Return a registered Waraq-family engine readiness manifest in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_engine_readiness_manifest_result_json(
    engine_id: *const c_char,
) -> *mut c_char {
    match engine_readiness_manifest_from_ptr(engine_id) {
        Ok(manifest) => artifact_result_ok(manifest),
        Err(error) => artifact_result_err(error),
    }
}

/// Return the compact Waraq editor artifact readiness manifest as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_readiness_manifest_json() -> *mut c_char {
    match editor_artifact_readiness_manifest() {
        Ok(manifest) => artifact_json_to_c_string(&manifest),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return the Waraq editor artifact readiness manifest in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_readiness_manifest_result_json() -> *mut c_char {
    match editor_artifact_readiness_manifest() {
        Ok(manifest) => artifact_result_ok(manifest),
        Err(error) => artifact_result_err(artifact_readiness_manifest_error(error)),
    }
}

/// Return the validated shared artifact test-profile report as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_test_profile_json() -> *mut c_char {
    match editor_artifact_test_profile_report() {
        Ok(report) => artifact_json_to_c_string(&report),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return the validated shared artifact test-profile report in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_test_profile_result_json() -> *mut c_char {
    match editor_artifact_test_profile_report() {
        Ok(report) => artifact_result_ok(report),
        Err(error) => artifact_result_err(artifact_test_profile_error(error)),
    }
}

/// Return Waraq editor's validated representative lifecycle proof as compact JSON.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_lifecycle_profile_json() -> *mut c_char {
    match editor_artifact_lifecycle_profile_report() {
        Ok(report) => artifact_json_to_c_string(&report),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return Waraq editor's representative lifecycle proof in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_lifecycle_profile_result_json() -> *mut c_char {
    match editor_artifact_lifecycle_profile_report() {
        Ok(report) => artifact_result_ok(report),
        Err(error) => artifact_result_err(artifact_lifecycle_profile_error(error)),
    }
}

/// Return a JSON description of supported Waraq editor artifact FFI capabilities.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_capabilities_json() -> *mut c_char {
    match editor_artifact_capabilities() {
        Ok(capabilities) => artifact_json_to_c_string(&capabilities),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Return supported Waraq editor artifact FFI capabilities in a result envelope.
/// CALLER MUST call editor_free_str.
#[no_mangle]
pub extern "C" fn editor_artifact_capabilities_result_json() -> *mut c_char {
    match editor_artifact_capabilities() {
        Ok(capabilities) => artifact_result_ok(capabilities),
        Err(error) => artifact_result_err(artifact_capabilities_error(error)),
    }
}

fn editor_artifact_capabilities() -> Result<ArtifactApiCapabilities, DomainArtifactTestProfileError>
{
    let artifact_kit = match ArtifactEngineKit::for_engine(WARAQ_EDITOR_ENGINE_ID) {
        Ok(kit) => kit,
        Err(error) => return Err(error),
    };

    Ok(ArtifactApiCapabilities {
        api_version: ARTIFACT_API_VERSION,
        crate_version: env!("CARGO_PKG_VERSION"),
        engine: WARAQ_EDITOR_ENGINE_ID,
        envelope_schema_version: OPERATION_ENVELOPE_VERSION,
        result_envelope: ARTIFACT_RESULT_ENVELOPE,
        result_envelope_schema: artifact_result_envelope_description(),
        supports_legacy_null_returns: true,
        supports_validation_summary: true,
        supports_operation_builders: true,
        supports_operation_log_builders: true,
        supports_operation_log_document_append: true,
        supports_operation_log_validation: true,
        supports_operation_log_document_validation: true,
        supports_artifact_contract_description: true,
        supports_waraq_boundary_manifest: true,
        supports_waraq_engine_registry: true,
        supports_waraq_engine_id_resolution: true,
        supports_waraq_engine_contract: true,
        supports_waraq_engine_readiness_manifest: true,
        supports_artifact_readiness_manifest: true,
        supports_artifact_test_profile: true,
        supports_artifact_lifecycle_profile: true,
        supports_artifact_restore_preflight: true,
        restore_returns_handle: true,
        artifact_contract: artifact_kit.contract.clone(),
        waraq_boundary_manifest: waraq_shared_core_boundary(),
        waraq_engine_registry: waraq_family_engine_registry(),
        artifact_readiness_manifest: artifact_kit.readiness_manifest(),
        metadata_functions: artifact_api_function_names(ArtifactApiFunctionKind::Metadata),
        legacy_functions: artifact_api_function_names(ArtifactApiFunctionKind::Legacy),
        result_functions: artifact_api_function_names(ArtifactApiFunctionKind::Result),
        result_function_pairs: artifact_api_result_function_pairs(),
        result_only_functions: artifact_api_result_only_functions(),
        legacy_result_gaps: artifact_api_legacy_result_gaps(),
        payload_families: artifact_api_payload_families(),
        function_catalog: artifact_api_function_catalog(),
        signature_families: artifact_api_signature_families(),
        error_codes: artifact_error_codes(),
        error_code_catalog: ARTIFACT_ERROR_CODE_CATALOG,
    })
}

fn resolve_engine_id_from_ptr(
    engine_id: *const c_char,
) -> Result<WaraqEngineIdResolution, ArtifactApiError> {
    let engine_id = required_string_from_ptr(engine_id, "engine_id", code::NULL_ENGINE_ID)?;

    resolve_waraq_engine_id(&engine_id).ok_or_else(|| {
        ArtifactApiError::new(
            code::UNKNOWN_WARAQ_FAMILY_ENGINE,
            format!("engine_id {engine_id} is not a registered Waraq-family engine id"),
        )
    })
}

fn validated_waraq_family_engine_registry() -> Result<WaraqFamilyEngineRegistry, ArtifactApiError> {
    validate_waraq_family_engine_registry().map_err(artifact_engine_registry_error)?;
    Ok(waraq_family_engine_registry())
}

fn engine_contract_from_ptr(
    engine_id: *const c_char,
) -> Result<ArtifactContractDescription, ArtifactApiError> {
    let resolution = resolve_engine_id_from_ptr(engine_id)?;

    Ok(artifact_contract_description(
        resolution.canonical_engine_id,
    ))
}

fn engine_readiness_manifest_from_ptr(
    engine_id: *const c_char,
) -> Result<ArtifactEngineReadinessManifest, ArtifactApiError> {
    let engine_id = required_string_from_ptr(engine_id, "engine_id", code::NULL_ENGINE_ID)?;
    let kit = ArtifactEngineKit::for_waraq_family_engine(&engine_id)
        .map_err(artifact_engine_kit_error)?;

    Ok(kit.readiness_manifest())
}

fn editor_artifact_readiness_manifest(
) -> Result<ArtifactEngineReadinessManifest, DomainArtifactTestProfileError> {
    ArtifactEngineKit::for_engine(WARAQ_EDITOR_ENGINE_ID).map(|kit| kit.readiness_manifest())
}

fn editor_artifact_test_profile_report(
) -> Result<DomainArtifactTestProfileValidationReport, DomainArtifactTestProfileError> {
    let profile = domain_artifact_test_profile(WARAQ_EDITOR_ENGINE_ID);
    validate_domain_artifact_test_profile_report(&profile)
}

fn artifact_test_profile_error(error: DomainArtifactTestProfileError) -> ArtifactApiError {
    ArtifactApiError::new(
        code::ARTIFACT_TEST_PROFILE_UNAVAILABLE,
        format!("failed to validate artifact test profile: {error:?}"),
    )
}

fn artifact_capabilities_error(error: DomainArtifactTestProfileError) -> ArtifactApiError {
    ArtifactApiError::new(
        code::ARTIFACT_CAPABILITIES_UNAVAILABLE,
        format!("failed to build artifact API capabilities: {error:?}"),
    )
}

fn artifact_engine_registry_error(error: WaraqFamilyEngineRegistryError) -> ArtifactApiError {
    ArtifactApiError::new(
        code::ARTIFACT_ENGINE_REGISTRY_UNAVAILABLE,
        format!("failed to validate Waraq-family engine registry: {error:?}"),
    )
}

fn artifact_engine_kit_error(error: ArtifactEngineKitBuildError) -> ArtifactApiError {
    match error {
        ArtifactEngineKitBuildError::UnknownWaraqFamilyEngineId { engine_id } => {
            ArtifactApiError::new(
                code::UNKNOWN_WARAQ_FAMILY_ENGINE,
                format!("engine_id {engine_id} is not a registered Waraq-family engine id"),
            )
        }
        ArtifactEngineKitBuildError::Profile(error) => artifact_readiness_manifest_error(error),
    }
}

fn artifact_readiness_manifest_error(error: DomainArtifactTestProfileError) -> ArtifactApiError {
    ArtifactApiError::new(
        code::ARTIFACT_READINESS_MANIFEST_UNAVAILABLE,
        format!("failed to validate artifact readiness manifest: {error:?}"),
    )
}

fn artifact_lifecycle_profile_error(error: EditorArtifactReadinessError) -> ArtifactApiError {
    ArtifactApiError::new(
        code::ARTIFACT_LIFECYCLE_PROFILE_UNAVAILABLE,
        format!("failed to validate artifact lifecycle profile: {error:?}"),
    )
}
