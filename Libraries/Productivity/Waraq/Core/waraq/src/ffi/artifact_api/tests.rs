use super::contract::ARTIFACT_RESULT_ENVELOPE;
use super::error_codes::{artifact_error_codes, ARTIFACT_ERROR_CODE_CATALOG};
use super::surface::{
    artifact_api_function_catalog, artifact_api_function_names_by_signature,
    artifact_api_legacy_result_gaps, artifact_api_payload_families,
    artifact_api_result_function_pairs, artifact_api_result_only_functions,
    artifact_api_signature_families, ArtifactApiFunctionKind, ArtifactApiSignature,
    ARTIFACT_API_FUNCTIONS,
};
use super::*;
use crate::core::artifact_compaction_harness::REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS;
use crate::core::artifact_conformance::REQUIRED_ARTIFACT_CONFORMANCE_CHECKS;
use crate::core::artifact_contract::ARTIFACT_CONTRACT_VERSION;
use crate::core::artifact_engine_kit::ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION;
use crate::core::artifact_replay_harness::REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS;
use crate::core::edit::EditOp;
use crate::core::editor_artifact::{
    editor_operation, restore_editor_artifact, EditorArtifact, EditorOperation, EditorOperationLog,
    WARAQ_EDITOR_ENGINE_ID,
};
use crate::core::engine_boundary::{
    WARAQ_CANONICAL_ENGINE_IDS, WARAQ_CODE_ENGINE_ID, WARAQ_CODE_LEGACY_ENGINE_ID,
    WARAQ_ENGINE_BOUNDARY_DECISION, WARAQ_FAMILY_ENGINE_REGISTRY_VERSION, WARAQ_LEGACY_ENGINE_IDS,
    WARAQ_MAQAL_ENGINE_ID,
};
use crate::core::operation::OPERATION_ENVELOPE_VERSION;
use crate::ffi::c_api::{
    editor_create_with_content, editor_destroy, editor_free_str, editor_get_text, EditorHandle,
};
use crate::ffi::c_api_extended::editor_set_file_uri;
use std::collections::BTreeSet;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

const MAIN_DOCUMENT_ID: &str = "file:///main.txt";
const OTHER_DOCUMENT_ID: &str = "file:///other.txt";
const ACTOR_ID: &str = "actor-1";
const ARTIFACT_CAPABILITIES_GOLDEN_JSON: &str =
    include_str!("fixtures/editor_artifact_capabilities.json");
const ARTIFACT_CONTRACT_GOLDEN_JSON: &str = include_str!("fixtures/editor_artifact_contract.json");
const ARTIFACT_READINESS_MANIFEST_GOLDEN_JSON: &str =
    include_str!("fixtures/editor_artifact_readiness_manifest.json");
const README: &str = include_str!("../../../README.md");
const C_HEADER: &str = include_str!("../../../waraq_editor_core.h");
const ARTIFACT_HOST_WORKFLOW_EXAMPLE_C: &str =
    include_str!("../../../examples/artifact_host_workflow.c");
const ARTIFACT_API_SYMBOLS_SMOKE_C: &str =
    include_str!("../../../examples/artifact_api_symbols_smoke.c");
const ARTIFACT_HEADER_CPP_SMOKE: &str =
    include_str!("../../../examples/artifact_header_cpp_smoke.cpp");
const ARTIFACT_HOST_WORKFLOW_SMOKE_SH: &str =
    include_str!("../../../examples/smoke_artifact_host_workflow.sh");
const ARTIFACT_API_HUB_SOURCE: &str = include_str!("../artifact_api.rs");
const ARTIFACT_API_CONTRACT_SOURCE: &str = include_str!("contract.rs");
const ARTIFACT_ERROR_CODES_SOURCE: &str = include_str!("error_codes.rs");
const ARTIFACT_LIFECYCLE_SOURCE: &str = include_str!("artifact_lifecycle.rs");
const ARTIFACT_API_NUMERIC_SOURCE: &str = include_str!("numeric.rs");
const ARTIFACT_API_PARSING_SOURCE: &str = include_str!("parsing.rs");
const ARTIFACT_API_RESULT_SOURCE: &str = include_str!("result.rs");
const OPERATION_BUILDERS_SOURCE: &str = include_str!("operation_builders.rs");
const OPERATION_LOG_SOURCE: &str = include_str!("operation_log.rs");
const ARTIFACT_API_SURFACE_SOURCE: &str = include_str!("surface.rs");

fn get_str(ptr: *mut c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    let s = unsafe { CStr::from_ptr(ptr).to_str().unwrap().to_owned() };
    editor_free_str(ptr);
    s
}

fn value_array_contains(value: &serde_json::Value, field: &str, expected: &str) -> bool {
    value[field]
        .as_array()
        .unwrap()
        .iter()
        .any(|item| item.as_str() == Some(expected))
}

fn parse_compact_json(response: &str) -> serde_json::Value {
    assert!(!response.is_empty());
    assert!(
        !response.contains('\n'),
        "expected compact host JSON, got: {response}"
    );
    serde_json::from_str(response).unwrap()
}

fn parse_pretty_object_json(response: &str) -> serde_json::Value {
    assert!(!response.is_empty());
    assert!(
        response.starts_with("{\n"),
        "expected pretty object JSON, got: {response}"
    );
    assert!(
        response.contains("\n  \""),
        "expected indented object JSON, got: {response}"
    );
    assert!(
        response.ends_with("\n}"),
        "expected pretty object JSON without trailing newline, got: {response}"
    );
    serde_json::from_str(response).unwrap()
}

fn assert_compact_json_matches_fixture(response: &str, fixture: &str) -> serde_json::Value {
    let actual = parse_compact_json(response);
    let expected: serde_json::Value = serde_json::from_str(fixture).unwrap();
    assert_eq!(actual, expected);
    actual
}

fn assert_header_declares(function_name: &str) {
    assert!(
        C_HEADER.contains(&format!("{function_name}(")),
        "waraq_editor_core.h must declare advertised artifact API function {function_name}"
    );
}

fn assert_example_calls(function_name: &str) {
    assert!(
        ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains(&format!("{function_name}(")),
        "artifact_host_workflow.c must call {function_name}"
    );
}

fn artifact_capability_function_names(value: &serde_json::Value) -> BTreeSet<String> {
    ["metadata_functions", "legacy_functions", "result_functions"]
        .into_iter()
        .flat_map(|field| value[field].as_array().unwrap())
        .map(|function| function.as_str().unwrap().to_owned())
        .collect()
}

fn artifact_surface_function_names() -> BTreeSet<String> {
    ARTIFACT_API_FUNCTIONS
        .iter()
        .map(|function| function.name.to_owned())
        .collect()
}

fn artifact_surface_function_names_by_kind(kind: ArtifactApiFunctionKind) -> Vec<&'static str> {
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

fn artifact_symbol_smoke_array_names(array_name: &str) -> Vec<String> {
    let marker = format!("{array_name}[] = {{");
    let array_start = ARTIFACT_API_SYMBOLS_SMOKE_C
        .find(&marker)
        .unwrap_or_else(|| panic!("artifact_api_symbols_smoke.c must define {array_name}"))
        + marker.len();
    let array_tail = &ARTIFACT_API_SYMBOLS_SMOKE_C[array_start..];
    let array_end = array_tail
        .find("};")
        .unwrap_or_else(|| panic!("artifact_api_symbols_smoke.c must close {array_name}"));

    array_tail[..array_end]
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(|line| line.trim_end_matches(',').to_owned())
        .collect()
}

fn artifact_surface_function_names_by_signature(signature: ArtifactApiSignature) -> Vec<String> {
    artifact_api_function_names_by_signature(signature)
        .into_iter()
        .map(ToOwned::to_owned)
        .collect()
}

fn artifact_signature_family_function_names(value: &serde_json::Value) -> BTreeSet<String> {
    value["signature_families"]
        .as_array()
        .unwrap()
        .iter()
        .flat_map(|family| family["functions"].as_array().unwrap())
        .map(|function| function.as_str().unwrap().to_owned())
        .collect()
}

fn artifact_payload_family_function_names(value: &serde_json::Value) -> BTreeSet<String> {
    value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .flat_map(|family| family["functions"].as_array().unwrap())
        .map(|function| function.as_str().unwrap().to_owned())
        .collect()
}

fn artifact_function_catalog_names(value: &serde_json::Value) -> BTreeSet<String> {
    value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .map(|function| function["name"].as_str().unwrap().to_owned())
        .collect()
}

fn artifact_error_code_catalog_codes(value: &serde_json::Value) -> Vec<&str> {
    value["error_code_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .map(|description| description["code"].as_str().unwrap())
        .collect()
}

#[derive(Debug)]
struct ResultEnvelopeCase {
    function_name: &'static str,
    response: String,
    expected_ok: bool,
    expected_error_code: Option<&'static str>,
}

fn result_envelope_case(
    function_name: &'static str,
    response: String,
    expected_error_code: &'static str,
) -> ResultEnvelopeCase {
    ResultEnvelopeCase {
        function_name,
        response,
        expected_ok: false,
        expected_error_code: Some(expected_error_code),
    }
}

fn successful_result_envelope_case(
    function_name: &'static str,
    response: String,
) -> ResultEnvelopeCase {
    ResultEnvelopeCase {
        function_name,
        response,
        expected_ok: true,
        expected_error_code: None,
    }
}

fn result_envelope_cases() -> Vec<ResultEnvelopeCase> {
    let document_id = CString::new(MAIN_DOCUMENT_ID).unwrap();
    let actor_id = CString::new(ACTOR_ID).unwrap();
    let operation_id = CString::new("op-1").unwrap();
    let replacement = CString::new("x").unwrap();
    let legacy_engine_id = CString::new(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();

    vec![
        successful_result_envelope_case(
            "editor_artifact_capabilities_result_json",
            get_str(editor_artifact_capabilities_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_contract_result_json",
            get_str(editor_artifact_contract_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_boundary_result_json",
            get_str(editor_artifact_boundary_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_engine_registry_result_json",
            get_str(editor_artifact_engine_registry_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_resolve_engine_id_result_json",
            get_str(editor_artifact_resolve_engine_id_result_json(
                legacy_engine_id.as_ptr(),
            )),
        ),
        successful_result_envelope_case(
            "editor_artifact_engine_contract_result_json",
            get_str(editor_artifact_engine_contract_result_json(
                legacy_engine_id.as_ptr(),
            )),
        ),
        successful_result_envelope_case(
            "editor_artifact_engine_readiness_manifest_result_json",
            get_str(editor_artifact_engine_readiness_manifest_result_json(
                legacy_engine_id.as_ptr(),
            )),
        ),
        result_envelope_case(
            "editor_artifact_capture_result_json",
            get_str(editor_artifact_capture_result_json(
                std::ptr::null(),
                std::ptr::null(),
                std::ptr::null(),
            )),
            "null_handle",
        ),
        result_envelope_case(
            "editor_apply_operation_result_json",
            get_str(editor_apply_operation_result_json(
                std::ptr::null_mut(),
                std::ptr::null(),
            )),
            "null_handle",
        ),
        result_envelope_case(
            "editor_replay_log_result_json",
            get_str(editor_replay_log_result_json(
                std::ptr::null_mut(),
                std::ptr::null(),
            )),
            "null_handle",
        ),
        result_envelope_case(
            "editor_artifact_restore_preflight_result_json",
            get_str(editor_artifact_restore_preflight_result_json(
                std::ptr::null(),
            )),
            "null_artifact_json",
        ),
        result_envelope_case(
            "editor_artifact_compact_result_json",
            get_str(editor_artifact_compact_result_json(std::ptr::null(), 0, 0)),
            "null_artifact_json",
        ),
        result_envelope_case(
            "editor_artifact_maintenance_plan_result_json",
            get_str(editor_artifact_maintenance_plan_result_json(
                std::ptr::null(),
                1,
                0,
            )),
            "null_artifact_json",
        ),
        result_envelope_case(
            "editor_artifact_maintain_result_json",
            get_str(editor_artifact_maintain_result_json(
                std::ptr::null(),
                1,
                0,
                0,
            )),
            "null_artifact_json",
        ),
        result_envelope_case(
            "editor_artifact_validate_result_json",
            get_str(editor_artifact_validate_result_json(std::ptr::null())),
            "null_artifact_json",
        ),
        successful_result_envelope_case(
            "editor_artifact_readiness_manifest_result_json",
            get_str(editor_artifact_readiness_manifest_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_test_profile_result_json",
            get_str(editor_artifact_test_profile_result_json()),
        ),
        successful_result_envelope_case(
            "editor_artifact_lifecycle_profile_result_json",
            get_str(editor_artifact_lifecycle_profile_result_json()),
        ),
        result_envelope_case(
            "editor_operation_insert_result_json",
            get_str(editor_operation_insert_result_json(
                operation_id.as_ptr(),
                document_id.as_ptr(),
                actor_id.as_ptr(),
                1,
                100,
                0,
                std::ptr::null(),
            )),
            "null_text",
        ),
        result_envelope_case(
            "editor_operation_delete_result_json",
            get_str(editor_operation_delete_result_json(
                std::ptr::null(),
                document_id.as_ptr(),
                actor_id.as_ptr(),
                1,
                100,
                0,
                1,
            )),
            "null_operation_id",
        ),
        result_envelope_case(
            "editor_operation_replace_result_json",
            get_str(editor_operation_replace_result_json(
                std::ptr::null(),
                document_id.as_ptr(),
                actor_id.as_ptr(),
                1,
                100,
                0,
                1,
                replacement.as_ptr(),
            )),
            "null_operation_id",
        ),
        successful_result_envelope_case(
            "editor_operation_log_empty_result_json",
            get_str(editor_operation_log_empty_result_json()),
        ),
        result_envelope_case(
            "editor_operation_log_append_result_json",
            get_str(editor_operation_log_append_result_json(
                std::ptr::null(),
                std::ptr::null(),
            )),
            "null_operation_json",
        ),
        result_envelope_case(
            "editor_operation_log_append_for_document_result_json",
            get_str(editor_operation_log_append_for_document_result_json(
                std::ptr::null(),
                std::ptr::null(),
                std::ptr::null(),
            )),
            "null_document_id",
        ),
        result_envelope_case(
            "editor_operation_log_validate_result_json",
            get_str(editor_operation_log_validate_result_json(std::ptr::null())),
            "null_operation_log_json",
        ),
        result_envelope_case(
            "editor_operation_log_validate_for_document_result_json",
            get_str(editor_operation_log_validate_for_document_result_json(
                std::ptr::null(),
                std::ptr::null(),
            )),
            "null_document_id",
        ),
    ]
}

fn exported_function_names(source: &str) -> BTreeSet<String> {
    const MARKER: &str = "pub extern \"C\" fn ";

    source
        .match_indices(MARKER)
        .map(|(offset, _)| {
            let function_start = offset + MARKER.len();
            let function_tail = &source[function_start..];
            let function_end = function_tail
                .char_indices()
                .find_map(|(index, ch)| {
                    if ch.is_ascii_alphanumeric() || ch == '_' {
                        None
                    } else {
                        Some(index)
                    }
                })
                .unwrap_or(function_tail.len());
            function_tail[..function_end].to_owned()
        })
        .collect()
}

fn artifact_source_export_function_names() -> BTreeSet<String> {
    [
        ARTIFACT_API_CONTRACT_SOURCE,
        ARTIFACT_LIFECYCLE_SOURCE,
        OPERATION_BUILDERS_SOURCE,
        OPERATION_LOG_SOURCE,
    ]
    .into_iter()
    .flat_map(exported_function_names)
    .collect()
}

fn artifact_hub_reexport_function_names() -> BTreeSet<String> {
    ARTIFACT_API_HUB_SOURCE
        .split("pub use ")
        .skip(1)
        .filter_map(|pub_use| pub_use.split_once('{'))
        .filter_map(|(_, names)| names.split_once("};"))
        .flat_map(|(names, _)| names.split(','))
        .map(str::trim)
        .filter(|name| !name.is_empty())
        .map(ToOwned::to_owned)
        .collect()
}

fn create_editor_with_uri(content: &str, file_uri: &str) -> *mut EditorHandle {
    let handle = editor_create_with_content(CString::new(content).unwrap().as_ptr());
    editor_set_file_uri(handle, CString::new(file_uri).unwrap().as_ptr());
    handle
}

fn create_main_editor(content: &str) -> *mut EditorHandle {
    create_editor_with_uri(content, MAIN_DOCUMENT_ID)
}

fn make_insert_operation(
    operation_id: &str,
    document_id: &str,
    sequence: u64,
    at: usize,
    text: &str,
) -> EditorOperation {
    editor_operation(
        operation_id,
        document_id,
        ACTOR_ID,
        sequence,
        sequence * 100,
        EditOp::insert(at, text),
    )
}

fn make_insert_log(operations: &[(&str, &str, u64, usize, &str)]) -> EditorOperationLog {
    let mut log = EditorOperationLog::new();
    for (operation_id, document_id, sequence, at, text) in operations {
        log.push(make_insert_operation(
            operation_id,
            document_id,
            *sequence,
            *at,
            text,
        ));
    }
    log
}

fn main_abc_log() -> EditorOperationLog {
    make_insert_log(&[
        ("op-1", MAIN_DOCUMENT_ID, 1, 0, "a"),
        ("op-2", MAIN_DOCUMENT_ID, 2, 1, "b"),
        ("op-3", MAIN_DOCUMENT_ID, 3, 2, "c"),
    ])
}

fn capture_snapshot_artifact_json(handle: *const EditorHandle, document_id: &str) -> String {
    get_str(editor_artifact_capture(
        handle,
        CString::new(document_id).unwrap().as_ptr(),
        std::ptr::null(),
    ))
}

fn capture_artifact_json(
    handle: *const EditorHandle,
    document_id: &str,
    log: &EditorOperationLog,
) -> String {
    get_str(editor_artifact_capture(
        handle,
        CString::new(document_id).unwrap().as_ptr(),
        CString::new(log.to_json().unwrap()).unwrap().as_ptr(),
    ))
}

fn ffi_insert_operation_json(
    operation_id: &str,
    document_id: &str,
    sequence: u64,
    at: u64,
    text: &str,
) -> String {
    get_str(editor_operation_insert_json(
        CString::new(operation_id).unwrap().as_ptr(),
        CString::new(document_id).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        sequence,
        sequence * 100,
        at,
        CString::new(text).unwrap().as_ptr(),
    ))
}

#[test]
fn test_editor_artifact_capabilities_json_matches_golden_fixture() {
    let response = get_str(editor_artifact_capabilities_json());
    assert_compact_json_matches_fixture(&response, ARTIFACT_CAPABILITIES_GOLDEN_JSON);
}

#[test]
fn test_editor_artifact_capabilities_json_lists_supported_contract() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["api_version"], 30);
    assert_eq!(value["crate_version"], env!("CARGO_PKG_VERSION"));
    assert_eq!(value["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["envelope_schema_version"], OPERATION_ENVELOPE_VERSION);
    assert_eq!(value["result_envelope"], ARTIFACT_RESULT_ENVELOPE);
    assert_eq!(
        value["result_envelope_schema"]["id"],
        ARTIFACT_RESULT_ENVELOPE
    );
    assert_eq!(value["result_envelope_schema"]["ok_field"], "ok");
    assert_eq!(value["result_envelope_schema"]["value_field"], "value");
    assert_eq!(value["result_envelope_schema"]["error_field"], "error");
    assert_eq!(value["result_envelope_schema"]["error_code_field"], "code");
    assert_eq!(
        value["result_envelope_schema"]["error_message_field"],
        "message"
    );
    assert_eq!(
        value["result_envelope_schema"]["value_required_on_success"],
        true
    );
    assert_eq!(
        value["result_envelope_schema"]["error_omitted_on_success"],
        true
    );
    assert_eq!(
        value["result_envelope_schema"]["error_required_on_failure"],
        true
    );
    assert_eq!(
        value["result_envelope_schema"]["value_omitted_on_failure"],
        true
    );
    assert_eq!(value["result_envelope_schema"]["stable_error_codes"], true);
    assert_eq!(
        value["result_envelope_schema"]["serialization_error_code"],
        "serialization_failed"
    );
    assert_eq!(value["supports_legacy_null_returns"], true);
    assert_eq!(value["supports_validation_summary"], true);
    assert_eq!(value["supports_operation_builders"], true);
    assert_eq!(value["supports_operation_log_builders"], true);
    assert_eq!(value["supports_operation_log_document_append"], true);
    assert_eq!(value["supports_operation_log_validation"], true);
    assert_eq!(value["supports_operation_log_document_validation"], true);
    assert_eq!(value["supports_artifact_contract_description"], true);
    assert_eq!(value["supports_waraq_boundary_manifest"], true);
    assert_eq!(value["supports_waraq_engine_registry"], true);
    assert_eq!(value["supports_waraq_engine_id_resolution"], true);
    assert_eq!(value["supports_waraq_engine_contract"], true);
    assert_eq!(value["supports_waraq_engine_readiness_manifest"], true);
    assert_eq!(value["supports_artifact_readiness_manifest"], true);
    assert_eq!(value["supports_artifact_test_profile"], true);
    assert_eq!(value["supports_artifact_lifecycle_profile"], true);
    assert_eq!(value["supports_artifact_restore_preflight"], true);
    assert_eq!(value["restore_returns_handle"], true);
    assert_eq!(
        value["artifact_contract"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(
        value["artifact_contract"]["engine_id"],
        WARAQ_EDITOR_ENGINE_ID
    );
    assert_eq!(
        value["artifact_contract"]["primitives"]["operation"],
        "OperationEnvelope<Edit>"
    );
    assert!(value["artifact_contract"]["shared_guarantees"]
        .as_array()
        .unwrap()
        .iter()
        .any(|guarantee| guarantee.as_str().unwrap().contains("compaction")));
    assert!(value["artifact_contract"]["domain_responsibilities"]
        .as_array()
        .unwrap()
        .iter()
        .any(|responsibility| responsibility
            .as_str()
            .unwrap()
            .contains("edit operation model")));
    assert_eq!(
        value["waraq_boundary_manifest"]["decision"],
        WARAQ_ENGINE_BOUNDARY_DECISION
    );
    assert!(value["waraq_boundary_manifest"]["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_CODE_ENGINE_ID
                && engine["legacy_engine_id"] == "code"
        ));
    assert!(value["waraq_boundary_manifest"]["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_MAQAL_ENGINE_ID
                && engine["legacy_engine_id"] == "maqal"
        ));
    assert_eq!(
        value["waraq_engine_registry"]["registry_version"],
        WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
    );
    assert_eq!(
        value["waraq_engine_registry"]["accepted_engine_id_count"],
        WARAQ_CANONICAL_ENGINE_IDS.len() + WARAQ_LEGACY_ENGINE_IDS.len()
    );
    assert_eq!(
        value["waraq_engine_registry"]["canonical_engine_ids"][0],
        WARAQ_CANONICAL_ENGINE_IDS[0]
    );
    assert_eq!(
        value["waraq_engine_registry"]["legacy_engine_ids"][0],
        WARAQ_LEGACY_ENGINE_IDS[0]
    );
    assert!(value["waraq_engine_registry"]["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_CODE_ENGINE_ID
                && engine["legacy_engine_id"] == WARAQ_CODE_LEGACY_ENGINE_ID
        ));
    assert_eq!(
        value["artifact_readiness_manifest"]["manifest_version"],
        ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION
    );
    assert_eq!(
        value["artifact_readiness_manifest"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(
        value["artifact_readiness_manifest"]["engine_id"],
        WARAQ_EDITOR_ENGINE_ID
    );
    assert_eq!(
        value["artifact_readiness_manifest"]["primitives"]["artifact"],
        "OperationArtifact<Snapshot, Edit>"
    );
    assert_eq!(
        value["artifact_readiness_manifest"]["required_shared_check_count"],
        REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
            + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
            + REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len()
    );
    assert_eq!(
        value["artifact_readiness_manifest"]["lifecycle_harness_required"],
        true
    );
    assert!(value["artifact_readiness_manifest"]["required_helpers"]
        .as_array()
        .unwrap()
        .iter()
        .any(|helper| helper.as_str() == Some("LifecycleHarness")));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_capabilities_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_contract_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_boundary_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_engine_registry_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_readiness_manifest_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_test_profile_json"
    ));
    assert!(value_array_contains(
        &value,
        "metadata_functions",
        "editor_artifact_lifecycle_profile_json"
    ));
    assert!(value_array_contains(
        &value,
        "legacy_functions",
        "editor_operation_log_append_for_document_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_capabilities_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_contract_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_boundary_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_engine_registry_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_resolve_engine_id_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_engine_contract_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_engine_readiness_manifest_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_restore_preflight_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_readiness_manifest_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_test_profile_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_artifact_lifecycle_profile_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_functions",
        "editor_operation_log_append_for_document_result_json"
    ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_capabilities_json"
                && pair["source_kind"] == "metadata"
                && pair["result_function"] == "editor_artifact_capabilities_result_json"
                && pair["signature_family"] == "no_args_string"
        ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_engine_registry_json"
                && pair["source_kind"] == "metadata"
                && pair["result_function"] == "editor_artifact_engine_registry_result_json"
                && pair["signature_family"] == "no_args_string"
        ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_contract_json"
                && pair["source_kind"] == "metadata"
                && pair["result_function"] == "editor_artifact_contract_result_json"
                && pair["signature_family"] == "no_args_string"
        ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_boundary_json"
                && pair["source_kind"] == "metadata"
                && pair["result_function"] == "editor_artifact_boundary_result_json"
                && pair["signature_family"] == "no_args_string"
        ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_readiness_manifest_json"
                && pair["source_kind"] == "metadata"
                && pair["result_function"] == "editor_artifact_readiness_manifest_result_json"
                && pair["signature_family"] == "no_args_string"
        ));
    assert!(value["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(|pair| pair["source_function"] == "editor_artifact_capture"
            && pair["source_kind"] == "legacy"
            && pair["result_function"] == "editor_artifact_capture_result_json"
            && pair["signature_family"] == "capture"));
    assert!(value_array_contains(
        &value,
        "result_only_functions",
        "editor_artifact_resolve_engine_id_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_only_functions",
        "editor_artifact_engine_contract_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_only_functions",
        "editor_artifact_engine_readiness_manifest_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_only_functions",
        "editor_artifact_restore_preflight_result_json"
    ));
    assert!(value_array_contains(
        &value,
        "result_only_functions",
        "editor_artifact_validate_result_json"
    ));
    assert!(value["legacy_result_gaps"]
        .as_array()
        .unwrap()
        .iter()
        .any(|gap| gap["legacy_function"] == "editor_artifact_restore"
            && gap["signature_family"] == "restore"
            && gap["reason"]
                .as_str()
                .unwrap()
                .contains("editor_artifact_restore_preflight_result_json")));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "artifact_api_capabilities"
            && value_array_contains(family, "functions", "editor_artifact_capabilities_json")
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_capabilities_result_json"
            )));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "artifact_contract"
            && value_array_contains(family, "functions", "editor_artifact_contract_json")
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_contract_result_json"
            )
            && value_array_contains(family, "functions", "editor_artifact_contract_result_json")));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "waraq_boundary_manifest"
            && value_array_contains(family, "functions", "editor_artifact_boundary_json")
            && value_array_contains(family, "functions", "editor_artifact_boundary_result_json")));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "waraq_engine_registry"
            && value_array_contains(family, "functions", "editor_artifact_engine_registry_json")
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_registry_result_json"
            )));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "waraq_engine_id_resolution"
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_resolve_engine_id_result_json"
            )));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "artifact_readiness_manifest"
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_readiness_manifest_json"
            )
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_readiness_manifest_result_json"
            )
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_readiness_manifest_result_json"
            )));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "artifact"
            && value_array_contains(family, "functions", "editor_artifact_capture")
            && value_array_contains(family, "functions", "editor_artifact_capture_result_json")));
    assert!(value["payload_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |family| family["id"] == "artifact_restore_preflight_summary"
                && family["description"]
                    .as_str()
                    .unwrap()
                    .contains("preflight")
                && value_array_contains(
                    family,
                    "functions",
                    "editor_artifact_restore_preflight_result_json"
                )
        ));
    assert!(value["signature_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "no_args_string"
            && value_array_contains(family, "functions", "editor_artifact_engine_registry_json")
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_registry_result_json"
            )));
    assert!(value["signature_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "artifact_string"
            && family["c_signature"] == "char* (*)(const char*)"
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_resolve_engine_id_result_json"
            )
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_contract_result_json"
            )
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_engine_readiness_manifest_result_json"
            )
            && value_array_contains(
                family,
                "functions",
                "editor_artifact_restore_preflight_result_json"
            )));
    assert!(value["signature_families"]
        .as_array()
        .unwrap()
        .iter()
        .any(|family| family["id"] == "operation_insert"
            && family["c_signature"]
                == "char* (*)(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, const char*)"
            && value_array_contains(
                family,
                "functions",
                "editor_operation_insert_result_json"
            )));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |function| function["name"] == "editor_artifact_engine_registry_json"
                && function["kind"] == "metadata"
                && function["payload_family"] == "waraq_engine_registry"
                && function["signature_family"] == "no_args_string"
                && function["c_signature"] == "char* (*)(void)"
        ));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |function| function["name"] == "editor_artifact_engine_registry_result_json"
                && function["kind"] == "result"
                && function["payload_family"] == "waraq_engine_registry"
                && function["signature_family"] == "no_args_string"
                && function["c_signature"] == "char* (*)(void)"
        ));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |function| function["name"] == "editor_artifact_resolve_engine_id_result_json"
                && function["kind"] == "result"
                && function["payload_family"] == "waraq_engine_id_resolution"
                && function["signature_family"] == "artifact_string"
                && function["c_signature"] == "char* (*)(const char*)"
        ));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |function| function["name"] == "editor_artifact_engine_contract_result_json"
                && function["kind"] == "result"
                && function["payload_family"] == "artifact_contract"
                && function["signature_family"] == "artifact_string"
                && function["c_signature"] == "char* (*)(const char*)"
        ));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(|function| function["name"]
            == "editor_artifact_engine_readiness_manifest_result_json"
            && function["kind"] == "result"
            && function["payload_family"] == "artifact_readiness_manifest"
            && function["signature_family"] == "artifact_string"
            && function["c_signature"] == "char* (*)(const char*)"));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |function| function["name"] == "editor_artifact_restore_preflight_result_json"
                && function["kind"] == "result"
                && function["payload_family"] == "artifact_restore_preflight_summary"
                && function["signature_family"] == "artifact_string"
                && function["c_signature"] == "char* (*)(const char*)"
        ));
    assert!(value["function_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(|function| function["name"] == "editor_operation_insert_result_json"
            && function["kind"] == "result"
            && function["payload_family"] == "operation_envelope"
            && function["signature_family"] == "operation_insert"
            && function["c_signature"]
                == "char* (*)(const char*, const char*, const char*, uint64_t, uint64_t, uint64_t, const char*)"));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "artifact_capabilities_unavailable"
    ));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "artifact_engine_registry_unavailable"
    ));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "operation_document_mismatch"
    ));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "integer_out_of_range"
    ));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "null_engine_id"
    ));
    assert!(value_array_contains(
        &value,
        "error_codes",
        "unknown_waraq_family_engine"
    ));
    assert!(value["error_code_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(|description| description["code"] == "integer_out_of_range"
            && description["category"] == "host_input"
            && description["description"]
                .as_str()
                .unwrap()
                .contains("integer parameter")));
    assert!(value["error_code_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |description| description["code"] == "artifact_engine_registry_unavailable"
                && description["category"] == "engine_identity"
                && description["description"]
                    .as_str()
                    .unwrap()
                    .contains("registry")
        ));
    assert!(value["error_code_catalog"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |description| description["code"] == "unknown_waraq_family_engine"
                && description["category"] == "engine_identity"
                && description["description"]
                    .as_str()
                    .unwrap()
                    .contains("engine_id")
        ));
}

#[test]
fn test_editor_artifact_capabilities_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_capabilities_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["api_version"], 30);
    assert_eq!(value["value"]["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["supports_waraq_boundary_manifest"], true);
    assert_eq!(value["value"]["supports_waraq_engine_registry"], true);
    assert_eq!(value["value"]["supports_waraq_engine_id_resolution"], true);
    assert_eq!(value["value"]["supports_waraq_engine_contract"], true);
    assert_eq!(
        value["value"]["supports_waraq_engine_readiness_manifest"],
        true
    );
    assert_eq!(
        value["value"]["waraq_boundary_manifest"]["decision"],
        WARAQ_ENGINE_BOUNDARY_DECISION
    );
    assert_eq!(
        value["value"]["artifact_readiness_manifest"]["engine_id"],
        WARAQ_EDITOR_ENGINE_ID
    );
    assert_eq!(
        value["value"]["waraq_engine_registry"]["accepted_engine_id_count"],
        WARAQ_CANONICAL_ENGINE_IDS.len() + WARAQ_LEGACY_ENGINE_IDS.len()
    );
    assert!(value_array_contains(
        &value["value"],
        "result_functions",
        "editor_artifact_capabilities_result_json"
    ));
    assert_eq!(value["value"]["supports_artifact_restore_preflight"], true);
    assert!(value["value"]["result_function_pairs"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |pair| pair["source_function"] == "editor_artifact_capabilities_json"
                && pair["result_function"] == "editor_artifact_capabilities_result_json"
        ));
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_boundary_json_exposes_shared_core_boundary() {
    let response = get_str(editor_artifact_boundary_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["decision"], WARAQ_ENGINE_BOUNDARY_DECISION);
    assert!(value["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_CODE_ENGINE_ID
                && engine["legacy_engine_id"] == "code"
                && engine["domain_owns"]
                    .as_str()
                    .unwrap()
                    .contains("language tooling")
        ));
    assert!(value["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_MAQAL_ENGINE_ID
                && engine["legacy_engine_id"] == "maqal"
                && engine["domain_owns"]
                    .as_str()
                    .unwrap()
                    .contains("kernel execution")
        ));
    assert!(value["ownership_matrix"]
        .as_array()
        .unwrap()
        .iter()
        .any(|concern| concern["concern"] == "Operation transport"
            && concern["waraq_core_owns"]
                .as_str()
                .unwrap()
                .contains("OperationEnvelope")));
    assert!(value["required_engine_checklist"]
        .as_array()
        .unwrap()
        .iter()
        .any(|step| step.as_str().unwrap().contains("stable engine id")));
    assert!(value["anti_patterns"]
        .as_array()
        .unwrap()
        .iter()
        .any(|pattern| pattern
            .as_str()
            .unwrap()
            .contains("one universal data structure")));
}

#[test]
fn test_editor_artifact_boundary_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_boundary_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["decision"], WARAQ_ENGINE_BOUNDARY_DECISION);
    assert!(value["value"]["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(|engine| engine["canonical_engine_id"] == WARAQ_MAQAL_ENGINE_ID));
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_engine_registry_json_exposes_family_registry() {
    let response = get_str(editor_artifact_engine_registry_json());
    let value = parse_compact_json(&response);

    assert_eq!(
        value["registry_version"],
        WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
    );
    assert_eq!(value["decision"], WARAQ_ENGINE_BOUNDARY_DECISION);
    assert_eq!(
        value["accepted_engine_id_count"],
        WARAQ_CANONICAL_ENGINE_IDS.len() + WARAQ_LEGACY_ENGINE_IDS.len()
    );
    assert_eq!(
        value["canonical_engine_ids"][0],
        WARAQ_CANONICAL_ENGINE_IDS[0]
    );
    assert_eq!(value["legacy_engine_ids"][0], WARAQ_LEGACY_ENGINE_IDS[0]);
    assert!(value["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(
            |engine| engine["canonical_engine_id"] == WARAQ_CODE_ENGINE_ID
                && engine["legacy_engine_id"] == WARAQ_CODE_LEGACY_ENGINE_ID
        ));
}

#[test]
fn test_editor_artifact_engine_registry_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_engine_registry_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["registry_version"],
        WARAQ_FAMILY_ENGINE_REGISTRY_VERSION
    );
    assert_eq!(
        value["value"]["accepted_engine_id_count"],
        WARAQ_CANONICAL_ENGINE_IDS.len() + WARAQ_LEGACY_ENGINE_IDS.len()
    );
    assert!(value["value"]["family_engines"]
        .as_array()
        .unwrap()
        .iter()
        .any(|engine| engine["canonical_engine_id"] == WARAQ_MAQAL_ENGINE_ID));
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_resolve_engine_id_result_json_resolves_canonical_id() {
    let engine_id = CString::new(WARAQ_CODE_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_resolve_engine_id_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["family"], "Code");
    assert_eq!(value["value"]["crate_name"], "code_engine");
    assert_eq!(value["value"]["canonical_engine_id"], WARAQ_CODE_ENGINE_ID);
    assert_eq!(value["value"]["matched_engine_id"], WARAQ_CODE_ENGINE_ID);
    assert_eq!(value["value"]["status"], "canonical");
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_resolve_engine_id_result_json_canonicalizes_legacy_id() {
    let engine_id = CString::new(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_resolve_engine_id_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["canonical_engine_id"], WARAQ_CODE_ENGINE_ID);
    assert_eq!(
        value["value"]["matched_engine_id"],
        WARAQ_CODE_LEGACY_ENGINE_ID
    );
    assert_eq!(value["value"]["status"], "legacy");
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_resolve_engine_id_result_json_reports_null_and_unknown_ids() {
    let null_response = get_str(editor_artifact_resolve_engine_id_result_json(
        std::ptr::null(),
    ));
    let null_value = parse_compact_json(&null_response);

    assert_eq!(null_value["ok"], false);
    assert_eq!(null_value["error"]["code"], "null_engine_id");
    assert!(null_value.get("value").is_none());

    let engine_id = CString::new("unknown.engine").unwrap();
    let unknown_response = get_str(editor_artifact_resolve_engine_id_result_json(
        engine_id.as_ptr(),
    ));
    let unknown_value = parse_compact_json(&unknown_response);

    assert_eq!(unknown_value["ok"], false);
    assert_eq!(
        unknown_value["error"]["code"],
        "unknown_waraq_family_engine"
    );
    assert!(unknown_value["error"]["message"]
        .as_str()
        .unwrap()
        .contains("unknown.engine"));
    assert!(unknown_value.get("value").is_none());
}

#[test]
fn test_editor_artifact_engine_contract_result_json_exposes_canonical_contract() {
    let engine_id = CString::new(WARAQ_MAQAL_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_engine_contract_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_MAQAL_ENGINE_ID);
    assert_eq!(
        value["value"]["primitives"]["operation"],
        "OperationEnvelope<Edit>"
    );
    assert!(value["value"]["shared_guarantees"]
        .as_array()
        .unwrap()
        .iter()
        .any(|guarantee| guarantee.as_str().unwrap().contains("operation logs")));
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_engine_contract_result_json_canonicalizes_legacy_id() {
    let engine_id = CString::new(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_engine_contract_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["engine_id"], WARAQ_CODE_ENGINE_ID);
    assert!(value["value"]["domain_responsibilities"]
        .as_array()
        .unwrap()
        .iter()
        .any(|responsibility| responsibility.as_str().unwrap().contains("snapshot model")));
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_engine_contract_result_json_reports_null_and_unknown_ids() {
    let null_response = get_str(editor_artifact_engine_contract_result_json(std::ptr::null()));
    let null_value = parse_compact_json(&null_response);

    assert_eq!(null_value["ok"], false);
    assert_eq!(null_value["error"]["code"], "null_engine_id");
    assert!(null_value.get("value").is_none());

    let engine_id = CString::new("unknown.engine").unwrap();
    let unknown_response = get_str(editor_artifact_engine_contract_result_json(
        engine_id.as_ptr(),
    ));
    let unknown_value = parse_compact_json(&unknown_response);

    assert_eq!(unknown_value["ok"], false);
    assert_eq!(
        unknown_value["error"]["code"],
        "unknown_waraq_family_engine"
    );
    assert!(unknown_value["error"]["message"]
        .as_str()
        .unwrap()
        .contains("unknown.engine"));
    assert!(unknown_value.get("value").is_none());
}

#[test]
fn test_editor_artifact_engine_readiness_manifest_result_json_exposes_canonical_manifest() {
    let engine_id = CString::new(WARAQ_MAQAL_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_engine_readiness_manifest_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["manifest_version"],
        ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_MAQAL_ENGINE_ID);
    assert_eq!(
        value["value"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(
        value["value"]["required_shared_check_count"],
        REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
            + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
            + REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len()
    );
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_engine_readiness_manifest_result_json_canonicalizes_legacy_id() {
    let engine_id = CString::new(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();
    let response = get_str(editor_artifact_engine_readiness_manifest_result_json(
        engine_id.as_ptr(),
    ));
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["engine_id"], WARAQ_CODE_ENGINE_ID);
    assert_eq!(
        value["value"]["primitives"]["artifact"],
        "OperationArtifact<Snapshot, Edit>"
    );
    assert_eq!(value["value"]["lifecycle_harness_required"], true);
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_engine_readiness_manifest_result_json_reports_null_and_unknown_ids() {
    let null_response = get_str(editor_artifact_engine_readiness_manifest_result_json(
        std::ptr::null(),
    ));
    let null_value = parse_compact_json(&null_response);

    assert_eq!(null_value["ok"], false);
    assert_eq!(null_value["error"]["code"], "null_engine_id");
    assert!(null_value.get("value").is_none());

    let engine_id = CString::new("unknown.engine").unwrap();
    let unknown_response = get_str(editor_artifact_engine_readiness_manifest_result_json(
        engine_id.as_ptr(),
    ));
    let unknown_value = parse_compact_json(&unknown_response);

    assert_eq!(unknown_value["ok"], false);
    assert_eq!(
        unknown_value["error"]["code"],
        "unknown_waraq_family_engine"
    );
    assert!(unknown_value["error"]["message"]
        .as_str()
        .unwrap()
        .contains("unknown.engine"));
    assert!(unknown_value.get("value").is_none());
}

#[test]
fn test_editor_artifact_contract_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_contract_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(
        value["value"]["primitives"]["operation"],
        "OperationEnvelope<Edit>"
    );
    assert!(value["value"]["shared_guarantees"]
        .as_array()
        .unwrap()
        .iter()
        .any(|guarantee| guarantee.as_str().unwrap().contains("operation logs")));
    assert!(value.get("error").is_none());
}

#[test]
fn test_artifact_capabilities_advertise_result_migration_catalog() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let pairs = value["result_function_pairs"].as_array().unwrap();
    let result_only = value["result_only_functions"].as_array().unwrap();
    let legacy_gaps = value["legacy_result_gaps"].as_array().unwrap();
    let advertised = artifact_capability_function_names(&value);
    let expected_pairs = artifact_api_result_function_pairs();
    let expected_result_only = artifact_api_result_only_functions();
    let expected_gaps = artifact_api_legacy_result_gaps();

    assert_eq!(pairs.len(), expected_pairs.len());
    for (actual, expected) in pairs.iter().zip(expected_pairs) {
        assert_eq!(actual["source_function"], expected.source_function);
        assert_eq!(actual["source_kind"], expected.source_kind);
        assert_eq!(actual["result_function"], expected.result_function);
        assert_eq!(actual["signature_family"], expected.signature_family);
        assert_eq!(actual["c_signature"], expected.c_signature);
        assert!(advertised.contains(expected.source_function));
        assert!(advertised.contains(expected.result_function));
    }

    assert_eq!(
        result_only
            .iter()
            .map(|function| function.as_str().unwrap())
            .collect::<Vec<_>>(),
        expected_result_only
    );
    for function in expected_result_only {
        assert!(advertised.contains(function));
    }

    assert_eq!(legacy_gaps.len(), expected_gaps.len());
    for (actual, expected) in legacy_gaps.iter().zip(expected_gaps) {
        assert_eq!(actual["legacy_function"], expected.legacy_function);
        assert_eq!(actual["signature_family"], expected.signature_family);
        assert_eq!(actual["c_signature"], expected.c_signature);
        assert_eq!(actual["reason"], expected.reason);
        assert!(advertised.contains(expected.legacy_function));
    }

    let paired_sources = pairs
        .iter()
        .map(|pair| pair["source_function"].as_str().unwrap())
        .collect::<BTreeSet<_>>();
    let result_targets = pairs
        .iter()
        .map(|pair| pair["result_function"].as_str().unwrap())
        .chain(
            result_only
                .iter()
                .map(|function| function.as_str().unwrap()),
        )
        .collect::<BTreeSet<_>>();
    let gap_sources = legacy_gaps
        .iter()
        .map(|gap| gap["legacy_function"].as_str().unwrap())
        .collect::<BTreeSet<_>>();

    for function in value["legacy_functions"].as_array().unwrap() {
        let name = function.as_str().unwrap();
        assert!(
            paired_sources.contains(name) || gap_sources.contains(name),
            "legacy function {name} must be paired with a result function or listed as a gap"
        );
    }
    for function in value["result_functions"].as_array().unwrap() {
        let name = function.as_str().unwrap();
        assert!(
            result_targets.contains(name),
            "result function {name} must be paired or listed as result-only"
        );
    }
}

#[test]
fn test_artifact_capabilities_advertise_result_envelope_schema() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let schema = &value["result_envelope_schema"];

    assert_eq!(schema["id"], value["result_envelope"]);
    assert_eq!(schema["ok_field"], "ok");
    assert_eq!(schema["value_field"], "value");
    assert_eq!(schema["error_field"], "error");
    assert_eq!(schema["error_code_field"], "code");
    assert_eq!(schema["error_message_field"], "message");
    assert_eq!(schema["value_required_on_success"], true);
    assert_eq!(schema["error_omitted_on_success"], true);
    assert_eq!(schema["error_required_on_failure"], true);
    assert_eq!(schema["value_omitted_on_failure"], true);
    assert_eq!(schema["stable_error_codes"], true);
    assert!(value_array_contains(
        &value,
        "error_codes",
        schema["serialization_error_code"].as_str().unwrap()
    ));
}

#[test]
fn test_editor_artifact_readiness_manifest_json_matches_golden_fixture() {
    let response = get_str(editor_artifact_readiness_manifest_json());
    assert_compact_json_matches_fixture(&response, ARTIFACT_READINESS_MANIFEST_GOLDEN_JSON);
}

#[test]
fn test_editor_artifact_readiness_manifest_json_exposes_compact_readiness() {
    let response = get_str(editor_artifact_readiness_manifest_json());
    let value = parse_compact_json(&response);

    assert_eq!(
        value["manifest_version"],
        ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION
    );
    assert_eq!(value["contract_version"], ARTIFACT_CONTRACT_VERSION);
    assert_eq!(value["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["primitives"]["operation"], "OperationEnvelope<Edit>");
    assert_eq!(
        value["primitives"]["artifact"],
        "OperationArtifact<Snapshot, Edit>"
    );
    assert_eq!(value["required_helpers"][0], "Conformance");
    assert_eq!(value["required_helpers"][3], "LifecycleHarness");
    assert_eq!(value["helper_count"], 5);
    assert_eq!(
        value["conformance_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len() as u64)
    );
    assert_eq!(
        value["replay_harness_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len() as u64)
    );
    assert_eq!(
        value["compaction_harness_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len() as u64)
    );
    assert_eq!(value["required_shared_check_count"], 22);
    assert_eq!(value["domain_replay_tests_required"], true);
    assert_eq!(value["compaction_harness_required"], true);
    assert_eq!(value["lifecycle_harness_required"], true);
    assert_eq!(value["lifecycle_harness_shared_check_count"], 22);
    assert!(value["shared_guarantees"]
        .as_array()
        .unwrap()
        .iter()
        .any(|guarantee| guarantee.as_str().unwrap().contains("operation envelopes")));
    assert!(value["domain_responsibilities"]
        .as_array()
        .unwrap()
        .iter()
        .any(|responsibility| responsibility.as_str().unwrap().contains("snapshot model")));
}

#[test]
fn test_editor_artifact_readiness_manifest_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_readiness_manifest_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["manifest_version"],
        ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["required_shared_check_count"], 22);
    assert_eq!(value["value"]["lifecycle_harness_required"], true);
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_test_profile_json_exposes_shared_readiness() {
    let response = get_str(editor_artifact_test_profile_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["contract_version"], ARTIFACT_CONTRACT_VERSION);
    assert_eq!(value["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["helper_count"], 5);
    assert_eq!(
        value["conformance_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len() as u64)
    );
    assert_eq!(
        value["replay_harness_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len() as u64)
    );
    assert_eq!(
        value["compaction_harness_check_count"].as_u64(),
        Some(REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len() as u64)
    );
    assert_eq!(value["required_shared_check_count"], 22);
    assert_eq!(value["domain_replay_tests_required"], true);
    assert_eq!(value["compaction_harness_required"], true);
    assert_eq!(value["lifecycle_harness_required"], true);
    assert_eq!(value["lifecycle_harness_shared_check_count"], 22);
}

#[test]
fn test_editor_artifact_test_profile_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_test_profile_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["required_shared_check_count"], 22);
    assert_eq!(value["value"]["lifecycle_harness_shared_check_count"], 22);
    assert!(value.get("error").is_none());
}

#[test]
fn test_editor_artifact_lifecycle_profile_json_exposes_validated_proof() {
    let response = get_str(editor_artifact_lifecycle_profile_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["contract_version"], ARTIFACT_CONTRACT_VERSION);
    assert_eq!(value["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["document_id"], "file:///main.txt");
    assert_eq!(value["profile"]["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["profile"]["required_shared_check_count"], 22);
    assert_eq!(value["expected_shared_check_count"], 22);
    assert_eq!(value["completed_shared_check_count"], 22);
    assert_eq!(value["completed_conformance_check_count"], 10);
    assert_eq!(value["completed_replay_harness_check_count"], 4);
    assert_eq!(value["completed_compaction_harness_check_count"], 8);
}

#[test]
fn test_editor_artifact_lifecycle_profile_result_json_exposes_success_envelope() {
    let response = get_str(editor_artifact_lifecycle_profile_result_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["ok"], true);
    assert_eq!(
        value["value"]["contract_version"],
        ARTIFACT_CONTRACT_VERSION
    );
    assert_eq!(value["value"]["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["document_id"], "file:///main.txt");
    assert_eq!(value["value"]["expected_shared_check_count"], 22);
    assert_eq!(value["value"]["completed_shared_check_count"], 22);
    assert_eq!(
        value["value"]["completed_compaction_harness_check_count"],
        8
    );
    assert!(value.get("error").is_none());
}

#[test]
fn test_artifact_capabilities_advertise_error_code_catalog() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let catalog = value["error_code_catalog"].as_array().unwrap();

    assert_eq!(catalog.len(), ARTIFACT_ERROR_CODE_CATALOG.len());
    assert_eq!(
        value["error_codes"]
            .as_array()
            .unwrap()
            .iter()
            .map(|code| code.as_str().unwrap())
            .collect::<Vec<_>>(),
        artifact_error_codes()
    );
    assert_eq!(
        artifact_error_code_catalog_codes(&value),
        artifact_error_codes()
    );

    let mut unique_codes = BTreeSet::new();
    for (actual, expected) in catalog.iter().zip(ARTIFACT_ERROR_CODE_CATALOG) {
        assert_eq!(actual["code"], expected.code);
        assert_eq!(actual["category"], expected.category);
        assert_eq!(actual["description"], expected.description);
        assert!(
            unique_codes.insert(expected.code),
            "error_code_catalog must not duplicate {}",
            expected.code
        );
    }

    assert!(catalog.iter().any(|description| {
        description["code"] == "artifact_readiness_manifest_unavailable"
            && description["category"] == "artifact_readiness"
            && description["description"]
                .as_str()
                .unwrap()
                .contains("readiness manifest")
    }));
    assert!(catalog.iter().any(|description| {
        description["code"] == "artifact_capabilities_unavailable"
            && description["category"] == "artifact_readiness"
            && description["description"]
                .as_str()
                .unwrap()
                .contains("capabilities")
    }));
}

#[test]
fn test_artifact_error_code_emitters_use_catalog_constants() {
    let parsing_production_source = ARTIFACT_API_PARSING_SOURCE
        .split("\n#[cfg(test)]")
        .next()
        .unwrap();
    let production_sources = [
        ("artifact_lifecycle.rs", ARTIFACT_LIFECYCLE_SOURCE),
        ("contract.rs", ARTIFACT_API_CONTRACT_SOURCE),
        ("numeric.rs", ARTIFACT_API_NUMERIC_SOURCE),
        ("operation_builders.rs", OPERATION_BUILDERS_SOURCE),
        ("operation_log.rs", OPERATION_LOG_SOURCE),
        ("parsing.rs", parsing_production_source),
        ("result.rs", ARTIFACT_API_RESULT_SOURCE),
    ];

    for code in artifact_error_codes() {
        let quoted_code = format!("\"{code}\"");
        for (source_name, source) in production_sources {
            assert!(
                !source.contains(&quoted_code),
                "{source_name} must emit artifact API error code {code} through error_codes::code constants"
            );
        }
    }

    assert!(ARTIFACT_ERROR_CODES_SOURCE.contains("pub(super) mod code"));
    assert!(ARTIFACT_ERROR_CODES_SOURCE.contains("ARTIFACT_ERROR_CODE_CATALOG"));
}

#[test]
fn test_artifact_capabilities_advertise_surface_function_catalog() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let function_catalog = value["function_catalog"].as_array().unwrap();
    let expected_catalog = artifact_api_function_catalog();

    assert_eq!(function_catalog.len(), expected_catalog.len());

    for (actual, expected) in function_catalog.iter().zip(expected_catalog) {
        assert_eq!(actual["name"], expected.name);
        assert_eq!(actual["kind"], expected.kind);
        assert_eq!(actual["payload_family"], expected.payload_family);
        assert_eq!(actual["signature_family"], expected.signature_family);
        assert_eq!(actual["c_signature"], expected.c_signature);
    }

    assert_eq!(
        artifact_function_catalog_names(&value),
        artifact_surface_function_names(),
        "function catalog must cover every artifact surface function exactly once"
    );
}

#[test]
fn test_artifact_capabilities_advertise_surface_signature_families() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let signature_families = value["signature_families"].as_array().unwrap();
    let expected_families = artifact_api_signature_families();

    assert_eq!(signature_families.len(), expected_families.len());

    for (actual, expected) in signature_families.iter().zip(expected_families) {
        assert_eq!(actual["id"], expected.id);
        assert_eq!(actual["c_signature"], expected.c_signature);
        assert_eq!(
            actual["functions"]
                .as_array()
                .unwrap()
                .iter()
                .map(|function| function.as_str().unwrap())
                .collect::<Vec<_>>(),
            expected.functions
        );
    }

    assert_eq!(
        artifact_signature_family_function_names(&value),
        artifact_surface_function_names(),
        "signature families must cover every artifact surface function exactly once"
    );
}

#[test]
fn test_artifact_capabilities_advertise_payload_families() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let payload_families = value["payload_families"].as_array().unwrap();
    let expected_families = artifact_api_payload_families();

    assert_eq!(payload_families.len(), expected_families.len());

    let mut covered = BTreeSet::new();
    for (actual, expected) in payload_families.iter().zip(expected_families) {
        assert_eq!(actual["id"], expected.id);
        assert_eq!(actual["description"], expected.description);
        assert!(
            !expected.functions.is_empty(),
            "payload family {} must advertise at least one function",
            expected.id
        );
        assert_eq!(
            actual["functions"]
                .as_array()
                .unwrap()
                .iter()
                .map(|function| function.as_str().unwrap())
                .collect::<Vec<_>>(),
            expected.functions
        );
        for function in expected.functions {
            assert!(
                covered.insert(function.to_owned()),
                "payload family coverage duplicated {function}"
            );
        }
    }

    assert_eq!(
        covered,
        artifact_surface_function_names(),
        "payload families must cover every artifact surface function exactly once"
    );
    assert_eq!(
        artifact_payload_family_function_names(&value),
        artifact_surface_function_names(),
        "payload family flattening must match the artifact surface"
    );

    for pair in value["result_function_pairs"].as_array().unwrap() {
        let source_name = pair["source_function"].as_str().unwrap();
        let result_name = pair["result_function"].as_str().unwrap();
        let source = ARTIFACT_API_FUNCTIONS
            .iter()
            .find(|function| function.name == source_name)
            .unwrap();
        let result = ARTIFACT_API_FUNCTIONS
            .iter()
            .find(|function| function.name == result_name)
            .unwrap();

        assert_eq!(
            source.payload, result.payload,
            "result pair {source_name} -> {result_name} must preserve payload semantics"
        );
    }
}

#[test]
fn test_c_header_declares_advertised_artifact_api() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    for function in artifact_capability_function_names(&value) {
        assert_header_declares(&function);
    }

    assert_eq!(
        C_HEADER
            .matches("#endif /* GOLLEK_EDITOR_CORE_H */")
            .count(),
        1
    );
    let guard_end = C_HEADER.find("#endif /* GOLLEK_EDITOR_CORE_H */").unwrap();
    assert!(C_HEADER.find("Artifact API").unwrap() < guard_end);
    assert!(C_HEADER.find("Extended API").unwrap() < guard_end);
}

#[test]
fn test_artifact_capabilities_match_rust_ffi_exports() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let advertised = artifact_capability_function_names(&value);
    let exported = artifact_source_export_function_names();
    let surfaced = artifact_surface_function_names();

    assert!(!exported.is_empty());

    let missing: Vec<_> = exported.difference(&advertised).collect();
    assert!(
        missing.is_empty(),
        "artifact exports missing from capabilities JSON: {missing:?}"
    );

    let stale: Vec<_> = advertised.difference(&exported).collect();
    assert!(
        stale.is_empty(),
        "capabilities JSON lists non-exported artifact functions: {stale:?}"
    );

    let missing_from_surface: Vec<_> = exported.difference(&surfaced).collect();
    assert!(
        missing_from_surface.is_empty(),
        "artifact exports missing from surface manifest: {missing_from_surface:?}"
    );

    let stale_surface: Vec<_> = surfaced.difference(&exported).collect();
    assert!(
        stale_surface.is_empty(),
        "surface manifest lists non-exported artifact functions: {stale_surface:?}"
    );
}

#[test]
fn test_artifact_capabilities_are_partitioned_by_surface_manifest() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(
        value["metadata_functions"]
            .as_array()
            .unwrap()
            .iter()
            .map(|function| function.as_str().unwrap())
            .collect::<Vec<_>>(),
        artifact_surface_function_names_by_kind(ArtifactApiFunctionKind::Metadata)
    );
    assert_eq!(
        value["legacy_functions"]
            .as_array()
            .unwrap()
            .iter()
            .map(|function| function.as_str().unwrap())
            .collect::<Vec<_>>(),
        artifact_surface_function_names_by_kind(ArtifactApiFunctionKind::Legacy)
    );
    assert_eq!(
        value["result_functions"]
            .as_array()
            .unwrap()
            .iter()
            .map(|function| function.as_str().unwrap())
            .collect::<Vec<_>>(),
        artifact_surface_function_names_by_kind(ArtifactApiFunctionKind::Result)
    );
}

#[test]
fn test_artifact_api_hub_reexports_all_ffi_exports() {
    let exported = artifact_source_export_function_names();
    let reexported = artifact_hub_reexport_function_names();

    assert!(!exported.is_empty());
    assert!(!reexported.is_empty());

    let missing: Vec<_> = exported.difference(&reexported).collect();
    assert!(
        missing.is_empty(),
        "artifact API hub must reexport artifact FFI functions: {missing:?}"
    );

    let stale: Vec<_> = reexported.difference(&exported).collect();
    assert!(
        stale.is_empty(),
        "artifact API hub reexports non-FFI artifact functions: {stale:?}"
    );
}

#[test]
fn test_artifact_ffi_numbers_are_fixed_width() {
    assert!(
        !ARTIFACT_LIFECYCLE_SOURCE.contains("c_ulong"),
        "artifact lifecycle FFI must use fixed-width u64 parameters"
    );
    assert!(
        !OPERATION_BUILDERS_SOURCE.contains("c_ulong"),
        "artifact operation builders must use fixed-width u64 parameters"
    );
    assert!(C_HEADER.contains("uint64_t retain_tail_operations"));
    assert!(C_HEADER.contains("uint64_t sequence"));
    assert!(C_HEADER.contains("uint64_t timestamp_ms"));
}

#[test]
fn test_artifact_host_workflow_example_covers_canonical_flow() {
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("#include \"../waraq_editor_core.h\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("require_contains"));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"function_catalog\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"signature_families\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"payload_families\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"error_code_catalog\\\"\""));
    assert!(
        ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"editor_artifact_test_profile_json\\\"\"")
    );
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_lifecycle_profile_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_readiness_manifest_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_test_profile_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_lifecycle_profile_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_readiness_manifest_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_capabilities_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_contract_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"editor_artifact_boundary_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_boundary_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_engine_registry_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_engine_registry_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_resolve_engine_id_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_engine_contract_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_engine_readiness_manifest_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_artifact_restore_preflight_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"editor_operation_insert_result_json\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"supports_waraq_engine_id_resolution\\\":true\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"supports_waraq_engine_contract\\\":true\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"supports_waraq_engine_readiness_manifest\\\":true\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"supports_waraq_engine_registry\\\":true\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"manifest_version\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"registry_version\\\":1\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"accepted_engine_id_count\\\":7\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"required_helpers\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"lifecycle_harness_required\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"required_shared_check_count\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"lifecycle_harness_shared_check_count\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"completed_shared_check_count\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"completed_compaction_harness_check_count\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"ok\\\":true\""));
    assert!(
        ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"Shared Core + Specialized Engines\\\"\"")
    );
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"code.engine\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"maqal.engine\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("canonical_engine_id"));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"status\\\":\\\"legacy\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"engine_id\\\":\\\"code.engine\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"shared_guarantees\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"unknown_waraq_family_engine\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C
        .contains("\"\\\"artifact_engine_registry_unavailable\\\"\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"restore_ready\\\":true\""));
    assert!(ARTIFACT_HOST_WORKFLOW_EXAMPLE_C.contains("\"\\\"integer_out_of_range\\\"\""));
    assert_example_calls("editor_artifact_capabilities_json");
    assert_example_calls("editor_artifact_capabilities_result_json");
    assert_example_calls("editor_artifact_contract_json");
    assert_example_calls("editor_artifact_contract_result_json");
    assert_example_calls("editor_artifact_boundary_json");
    assert_example_calls("editor_artifact_boundary_result_json");
    assert_example_calls("editor_artifact_engine_registry_json");
    assert_example_calls("editor_artifact_engine_registry_result_json");
    assert_example_calls("editor_artifact_resolve_engine_id_result_json");
    assert_example_calls("editor_artifact_engine_contract_result_json");
    assert_example_calls("editor_artifact_engine_readiness_manifest_result_json");
    assert_example_calls("editor_artifact_readiness_manifest_json");
    assert_example_calls("editor_artifact_test_profile_json");
    assert_example_calls("editor_artifact_lifecycle_profile_json");
    assert_example_calls("editor_artifact_readiness_manifest_result_json");
    assert_example_calls("editor_artifact_test_profile_result_json");
    assert_example_calls("editor_artifact_lifecycle_profile_result_json");
    assert_example_calls("editor_create_with_content");
    assert_example_calls("editor_set_file_uri");
    assert_example_calls("editor_operation_insert_json");
    assert_example_calls("editor_operation_log_empty_json");
    assert_example_calls("editor_operation_log_append_json");
    assert_example_calls("editor_artifact_capture");
    assert_example_calls("editor_artifact_restore_preflight_result_json");
    assert_example_calls("editor_artifact_restore");
    assert_example_calls("editor_get_text");
    assert_example_calls("editor_free_str");
    assert_example_calls("editor_destroy");
}

#[test]
fn test_artifact_header_cpp_smoke_covers_cpp_linkage() {
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("#include \"../waraq_editor_core.h\""));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("std::unique_ptr"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_version()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_capabilities_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_capabilities_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_contract_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_contract_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_boundary_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_boundary_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_engine_registry_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_engine_registry_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE
        .contains("editor_artifact_resolve_engine_id_result_json(\"code\")"));
    assert!(
        ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_engine_contract_result_json(\"code\")")
    );
    assert!(ARTIFACT_HEADER_CPP_SMOKE
        .contains("editor_artifact_engine_readiness_manifest_result_json(\"code\")"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE
        .contains("editor_artifact_restore_preflight_result_json(nullptr)"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_readiness_manifest_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_test_profile_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_lifecycle_profile_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_readiness_manifest_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_test_profile_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_artifact_lifecycle_profile_result_json()"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_free_str"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("api_version"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("supports_waraq_engine_registry"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("supports_waraq_engine_id_resolution"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("supports_waraq_engine_contract"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("supports_waraq_engine_readiness_manifest"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("function_catalog"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("signature_families"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("payload_families"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("error_code_catalog"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("manifest_version"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("required_helpers"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("lifecycle_harness_required"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("required_shared_check_count"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("lifecycle_harness_shared_check_count"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("completed_shared_check_count"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("completed_compaction_harness_check_count"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("\\\"ok\\\":true"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("\\\"ok\\\":false"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("null_artifact_json"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("editor_operation_insert_result_json"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("integer_out_of_range"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("shared_guarantees"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("Shared Core + Specialized Engines"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("registry_version"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("accepted_engine_id_count"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("code.engine"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("maqal.engine"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("engine_id"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("canonical_engine_id"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("status"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("artifact_engine_registry_unavailable"));
    assert!(ARTIFACT_HEADER_CPP_SMOKE.contains("unknown_waraq_family_engine"));
}

#[test]
fn test_artifact_api_symbols_smoke_references_advertised_api() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();
    let advertised = artifact_capability_function_names(&value);
    let expected_count = ARTIFACT_API_FUNCTIONS.len();

    assert!(ARTIFACT_API_SYMBOLS_SMOKE_C.contains("#include \"../waraq_editor_core.h\""));
    assert!(ARTIFACT_API_SYMBOLS_SMOKE_C
        .contains(&format!("#define ARTIFACT_SYMBOL_COUNT {expected_count}U")));

    for function in &advertised {
        assert!(
            ARTIFACT_API_SYMBOLS_SMOKE_C.contains(function),
            "artifact_api_symbols_smoke.c must reference advertised native symbol {function}"
        );
    }
}

#[test]
fn test_artifact_api_symbols_smoke_groups_match_surface_signatures() {
    let signature_arrays = [
        (ArtifactApiSignature::NoArgsString, "no_args_string_symbols"),
        (ArtifactApiSignature::Capture, "capture_symbols"),
        (ArtifactApiSignature::Restore, "restore_symbols"),
        (ArtifactApiSignature::EditorJson, "editor_json_symbols"),
        (
            ArtifactApiSignature::ArtifactTwoU64,
            "artifact_two_u64_symbols",
        ),
        (
            ArtifactApiSignature::ArtifactThreeU64,
            "artifact_three_u64_symbols",
        ),
        (
            ArtifactApiSignature::ArtifactString,
            "artifact_string_symbols",
        ),
        (ArtifactApiSignature::OperationInsert, "insert_symbols"),
        (ArtifactApiSignature::OperationDelete, "delete_symbols"),
        (ArtifactApiSignature::OperationReplace, "replace_symbols"),
        (ArtifactApiSignature::OperationLogAppend, "append_symbols"),
        (
            ArtifactApiSignature::OperationLogAppendForDocument,
            "append_for_document_symbols",
        ),
        (
            ArtifactApiSignature::OperationLogValidate,
            "validate_log_symbols",
        ),
        (
            ArtifactApiSignature::OperationLogValidateForDocument,
            "validate_log_for_document_symbols",
        ),
    ];

    let mut checked_symbol_count = 0;
    for (signature, array_name) in signature_arrays {
        let actual = artifact_symbol_smoke_array_names(array_name);
        let expected = artifact_surface_function_names_by_signature(signature);
        checked_symbol_count += actual.len();

        assert_eq!(
            actual, expected,
            "artifact_api_symbols_smoke.c array {array_name} must match the surface signature manifest"
        );
    }

    assert_eq!(checked_symbol_count, ARTIFACT_API_FUNCTIONS.len());
}

#[test]
fn test_artifact_host_workflow_smoke_script_builds_native_example() {
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("cargo build --offline"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("libwaraq_core.a"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("artifact_host_workflow.c"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("artifact_api_symbols_smoke.c"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("artifact_header_cpp_smoke.cpp"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("-std=c11"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("-std=c++17"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("-Wall"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("-Wextra"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("-Werror"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("CC_BIN=${CC:-cc}"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("CXX_BIN=${CXX:-c++}"));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("\"$C_OUT\""));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("\"$SYMBOLS_OUT\""));
    assert!(ARTIFACT_HOST_WORKFLOW_SMOKE_SH.contains("\"$CPP_OUT\""));
    assert!(README.contains("sh examples/smoke_artifact_host_workflow.sh"));
    assert!(README.contains("examples/artifact_api_symbols_smoke.c"));
    assert!(README.contains("examples/artifact_header_cpp_smoke.cpp"));
}

#[test]
fn test_result_functions_return_consistent_envelopes() {
    let capabilities = get_str(editor_artifact_capabilities_json());
    let capabilities: serde_json::Value = serde_json::from_str(&capabilities).unwrap();
    let known_error_codes: BTreeSet<_> = capabilities["error_codes"]
        .as_array()
        .unwrap()
        .iter()
        .map(|code| code.as_str().unwrap().to_owned())
        .collect();
    let cases = result_envelope_cases();

    let case_names: Vec<_> = cases.iter().map(|case| case.function_name).collect();
    assert_eq!(
        case_names,
        artifact_surface_function_names_by_kind(ArtifactApiFunctionKind::Result),
        "every manifest result function must have envelope conformance coverage"
    );

    for case in cases {
        let value = parse_compact_json(&case.response);
        let object = value
            .as_object()
            .unwrap_or_else(|| panic!("{} must return a JSON object", case.function_name));

        assert_eq!(
            value["ok"], case.expected_ok,
            "{} returned unexpected ok flag: {}",
            case.function_name, case.response
        );
        assert_eq!(
            object.len(),
            2,
            "{} must return only ok plus value or error",
            case.function_name
        );

        if case.expected_ok {
            assert!(
                object.contains_key("value"),
                "{} success envelope must contain value",
                case.function_name
            );
            assert!(
                !object.contains_key("error"),
                "{} success envelope must omit error",
                case.function_name
            );
        } else {
            assert!(
                object.contains_key("error"),
                "{} error envelope must contain error",
                case.function_name
            );
            assert!(
                !object.contains_key("value"),
                "{} error envelope must omit value",
                case.function_name
            );
            let error = value["error"]
                .as_object()
                .unwrap_or_else(|| panic!("{} error must be a JSON object", case.function_name));
            assert_eq!(
                error.len(),
                2,
                "{} error must contain only code and message",
                case.function_name
            );
            let code = value["error"]["code"]
                .as_str()
                .unwrap_or_else(|| panic!("{} error.code must be a string", case.function_name));
            assert_eq!(Some(code), case.expected_error_code);
            assert!(
                known_error_codes.contains(code),
                "{} returned undocumented error code {code}",
                case.function_name
            );
            assert!(
                !value["error"]["message"].as_str().unwrap_or("").is_empty(),
                "{} error.message must be non-empty",
                case.function_name
            );
        }
    }
}

#[test]
fn test_readme_documents_result_envelope_and_error_codes() {
    let response = get_str(editor_artifact_capabilities_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert!(README.contains("Artifact Result Envelope"));
    assert!(README.contains(ARTIFACT_RESULT_ENVELOPE));
    assert!(README.contains(r#""ok":true"#));
    assert!(README.contains(r#""ok":false"#));
    assert!(README.contains("error.code"));
    assert!(README.contains("error_codes"));
    assert!(README.contains("error_code_catalog"));

    for code in value["error_codes"].as_array().unwrap() {
        let code = code.as_str().unwrap();
        assert!(
            README.contains(code),
            "README Artifact Result Envelope must document error code {code}"
        );
    }
}

#[test]
fn test_readme_documents_artifact_api_maintenance_checklist() {
    assert!(README.contains("Artifact API Maintenance Checklist"));
    assert!(README.contains("function_catalog"));
    assert!(README.contains("signature_families"));
    assert!(README.contains("c_signature"));
    assert!(README.contains("test_artifact_capabilities_match_rust_ffi_exports"));
    assert!(README.contains("test_c_header_declares_advertised_artifact_api"));
    assert!(README.contains("golden fixture tests"));
    assert!(README.contains("README error-code coverage"));
    assert!(README.contains("native signature-family coverage"));
    assert!(README.contains("C and C++ syntax checks"));
    assert!(README.contains("src/ffi/artifact_api/contract.rs"));
    assert!(README.contains("src/ffi/artifact_api/surface.rs"));
    assert!(README.contains("src/ffi/artifact_api/fixtures/"));
    assert!(README.contains("waraq_editor_core.h"));
    assert!(README.contains("examples/artifact_host_workflow.c"));
    assert!(README.contains("examples/artifact_api_symbols_smoke.c"));
    assert!(README.contains("examples/artifact_header_cpp_smoke.cpp"));
    assert!(README.contains("examples/smoke_artifact_host_workflow.sh"));
    assert!(README.contains("cargo check --workspace --offline"));
    assert!(README.contains("cargo test --workspace --offline"));
    assert!(ARTIFACT_API_SURFACE_SOURCE.contains("ARTIFACT_API_FUNCTIONS"));
    assert!(ARTIFACT_API_SURFACE_SOURCE.contains("ArtifactApiSignature"));
    assert!(ARTIFACT_ERROR_CODES_SOURCE.contains("ARTIFACT_ERROR_CODE_CATALOG"));
}

#[test]
fn test_editor_artifact_contract_json_matches_golden_fixture() {
    let response = get_str(editor_artifact_contract_json());
    assert_compact_json_matches_fixture(&response, ARTIFACT_CONTRACT_GOLDEN_JSON);
}

#[test]
fn test_editor_artifact_contract_json_exposes_shared_contract() {
    let response = get_str(editor_artifact_contract_json());
    let value = parse_compact_json(&response);

    assert_eq!(value["contract_version"], ARTIFACT_CONTRACT_VERSION);
    assert_eq!(value["engine_id"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["primitives"]["operation"], "OperationEnvelope<Edit>");
    assert_eq!(value["primitives"]["operation_log"], "OperationLog<Edit>");
    assert_eq!(
        value["primitives"]["artifact"],
        "OperationArtifact<Snapshot, Edit>"
    );
    assert!(value["shared_guarantees"]
        .as_array()
        .unwrap()
        .iter()
        .any(|guarantee| guarantee.as_str().unwrap().contains("operation logs")));
    assert!(value["domain_responsibilities"]
        .as_array()
        .unwrap()
        .iter()
        .any(|responsibility| responsibility
            .as_str()
            .unwrap()
            .contains("stable engine identifier")));
}

#[test]
fn test_legacy_artifact_lifecycle_json_formatting_contract() {
    let h = create_main_editor("hello");

    let artifact_json = capture_snapshot_artifact_json(h, MAIN_DOCUMENT_ID);
    let artifact = parse_pretty_object_json(&artifact_json);
    assert_eq!(artifact["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(artifact["document_id"], MAIN_DOCUMENT_ID);

    let compacted_json = get_str(editor_artifact_compact(
        CString::new(artifact_json.clone()).unwrap().as_ptr(),
        0,
        1234,
    ));
    let compacted = parse_pretty_object_json(&compacted_json);
    assert_eq!(compacted["metadata"]["compaction"]["compacted_at_ms"], 1234);

    let maintained_json = get_str(editor_artifact_maintain(
        CString::new(artifact_json).unwrap().as_ptr(),
        0,
        0,
        4321,
    ));
    let maintained = parse_pretty_object_json(&maintained_json);
    assert_eq!(maintained["engine"], WARAQ_EDITOR_ENGINE_ID);

    editor_destroy(h);
}

#[test]
fn test_legacy_non_artifact_json_stays_compact_contract() {
    let h = create_main_editor("hello");

    let operation_json = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 5, " world");
    let operation = parse_compact_json(&operation_json);
    assert_eq!(operation["operation_id"], "op-1");

    let outcome_json = get_str(editor_apply_operation_json(
        h,
        CString::new(operation_json).unwrap().as_ptr(),
    ));
    let outcome = parse_compact_json(&outcome_json);
    assert_eq!(outcome["applied_text_edits"], 1);

    let artifact_json = capture_snapshot_artifact_json(h, MAIN_DOCUMENT_ID);
    let plan_json = get_str(editor_artifact_maintenance_plan(
        CString::new(artifact_json).unwrap().as_ptr(),
        2,
        1,
    ));
    let plan = parse_compact_json(&plan_json);
    assert_eq!(plan["should_compact"], false);

    editor_destroy(h);
}

#[test]
fn test_result_envelope_omits_unused_side_contract() {
    let success_json = get_str(editor_operation_replace_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        1,
        4,
        CString::new("ey").unwrap().as_ptr(),
    ));
    let success = parse_compact_json(&success_json);
    let success_object = success.as_object().unwrap();
    assert_eq!(success_object.len(), 2);
    assert_eq!(success["ok"], true);
    assert!(success_object.contains_key("value"));
    assert!(!success_object.contains_key("error"));

    let error_json = get_str(editor_operation_delete_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        4,
        1,
    ));
    let error = parse_compact_json(&error_json);
    let error_object = error.as_object().unwrap();
    assert_eq!(error_object.len(), 2);
    assert_eq!(error["ok"], false);
    assert!(error_object.contains_key("error"));
    assert!(!error_object.contains_key("value"));
    assert_eq!(error["error"]["code"], "invalid_range");
    assert!(error["error"]["message"]
        .as_str()
        .unwrap()
        .contains("start"));
}

#[test]
fn test_editor_operation_log_empty_json_builds_empty_log() {
    let response = get_str(editor_operation_log_empty_json());
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["schema_version"], OPERATION_ENVELOPE_VERSION);
    assert_eq!(value["operations"].as_array().unwrap().len(), 0);
}

#[test]
fn test_editor_operation_log_validate_json_reports_empty_summary() {
    let log = get_str(editor_operation_log_empty_json());
    let summary = get_str(editor_operation_log_validate_json(
        CString::new(log).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&summary).unwrap();

    assert_eq!(value["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["document_id"], serde_json::Value::Null);
    assert_eq!(value["operation_count"], 0);
    assert_eq!(value["first_sequence"], serde_json::Value::Null);
    assert_eq!(value["last_sequence"], serde_json::Value::Null);
    assert_eq!(value["next_sequence"], 1);
    assert_eq!(value["last_operation_id"], serde_json::Value::Null);
}

#[test]
fn test_editor_operation_log_append_json_builds_replayable_log() {
    let op1 = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log1 = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op1).unwrap().as_ptr(),
    ));
    let op2 = ffi_insert_operation_json("op-2", MAIN_DOCUMENT_ID, 2, 1, "i");
    let log2 = get_str(editor_operation_log_append_json(
        CString::new(log1).unwrap().as_ptr(),
        CString::new(op2).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&log2).unwrap();
    assert_eq!(value["operations"].as_array().unwrap().len(), 2);

    let h = create_main_editor("");
    let replay = get_str(editor_replay_log_json(
        h,
        CString::new(log2).unwrap().as_ptr(),
    ));
    let outcomes: serde_json::Value = serde_json::from_str(&replay).unwrap();

    assert_eq!(outcomes.as_array().unwrap().len(), 2);
    assert_eq!(get_str(editor_get_text(h)), "hi");
    editor_destroy(h);
}

#[test]
fn test_editor_operation_log_append_for_document_json_guards_empty_log() {
    let op = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_for_document_json(
        std::ptr::null(),
        CString::new(op).unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&log).unwrap();

    assert_eq!(value["operations"].as_array().unwrap().len(), 1);
    assert_eq!(value["operations"][0]["document_id"], MAIN_DOCUMENT_ID);
}

#[test]
fn test_editor_operation_log_append_for_document_result_json_rejects_wrong_new_operation() {
    let op = ffi_insert_operation_json("op-1", OTHER_DOCUMENT_ID, 1, 0, "h");
    let response = get_str(editor_operation_log_append_for_document_result_json(
        std::ptr::null(),
        CString::new(op).unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
}

#[test]
fn test_editor_operation_log_append_for_document_result_json_rejects_existing_wrong_log() {
    let existing = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(existing).unwrap().as_ptr(),
    ));
    let next = ffi_insert_operation_json("op-2", OTHER_DOCUMENT_ID, 2, 1, "i");

    let response = get_str(editor_operation_log_append_for_document_result_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new(next).unwrap().as_ptr(),
        CString::new(OTHER_DOCUMENT_ID).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
}

#[test]
fn test_editor_operation_log_append_for_document_result_json_rejects_empty_document() {
    let op = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let response = get_str(editor_operation_log_append_for_document_result_json(
        std::ptr::null(),
        CString::new(op).unwrap().as_ptr(),
        CString::new("").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_document_id");
}

#[test]
fn test_editor_operation_log_validate_result_json_reports_tail_summary() {
    let op1 = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log1 = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op1).unwrap().as_ptr(),
    ));
    let op2 = ffi_insert_operation_json("op-2", MAIN_DOCUMENT_ID, 2, 1, "i");
    let log2 = get_str(editor_operation_log_append_json(
        CString::new(log1).unwrap().as_ptr(),
        CString::new(op2).unwrap().as_ptr(),
    ));

    let response = get_str(editor_operation_log_validate_result_json(
        CString::new(log2).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["document_id"], MAIN_DOCUMENT_ID);
    assert_eq!(value["value"]["operation_count"], 2);
    assert_eq!(value["value"]["first_sequence"], 1);
    assert_eq!(value["value"]["last_sequence"], 2);
    assert_eq!(value["value"]["next_sequence"], 3);
    assert_eq!(value["value"]["last_operation_id"], "op-2");
}

#[test]
fn test_editor_operation_log_validate_for_document_json_accepts_matching_log() {
    let op1 = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op1).unwrap().as_ptr(),
    ));

    let summary = get_str(editor_operation_log_validate_for_document_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&summary).unwrap();

    assert_eq!(value["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["document_id"], MAIN_DOCUMENT_ID);
    assert_eq!(value["operation_count"], 1);
    assert_eq!(value["next_sequence"], 2);
}

#[test]
fn test_editor_operation_log_validate_for_document_result_json_rejects_wrong_document() {
    let op1 = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op1).unwrap().as_ptr(),
    ));

    let response = get_str(editor_operation_log_validate_for_document_result_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new(OTHER_DOCUMENT_ID).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
}

#[test]
fn test_editor_operation_log_validate_for_document_result_json_rejects_empty_document() {
    let log = get_str(editor_operation_log_empty_json());
    let response = get_str(editor_operation_log_validate_for_document_result_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new("").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_document_id");
}

#[test]
fn test_editor_operation_log_append_result_json_rejects_duplicate_operation() {
    let op = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op.clone()).unwrap().as_ptr(),
    ));

    let response = get_str(editor_operation_log_append_result_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new(op).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "duplicate_operation_id");
}

#[test]
fn test_editor_operation_log_validate_result_json_rejects_duplicate_operation() {
    let log = make_insert_log(&[
        ("op-1", MAIN_DOCUMENT_ID, 1, 0, "h"),
        ("op-1", MAIN_DOCUMENT_ID, 2, 1, "i"),
    ]);
    let response = get_str(editor_operation_log_validate_result_json(
        CString::new(log.to_json().unwrap()).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "duplicate_operation_id");
}

#[test]
fn test_editor_operation_log_append_result_json_rejects_wrong_document() {
    let op1 = ffi_insert_operation_json("op-1", MAIN_DOCUMENT_ID, 1, 0, "h");
    let log = get_str(editor_operation_log_append_json(
        std::ptr::null(),
        CString::new(op1).unwrap().as_ptr(),
    ));
    let op2 = ffi_insert_operation_json("op-2", OTHER_DOCUMENT_ID, 2, 1, "i");

    let response = get_str(editor_operation_log_append_result_json(
        CString::new(log).unwrap().as_ptr(),
        CString::new(op2).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
}

#[test]
fn test_editor_operation_log_validate_result_json_rejects_mixed_document_log() {
    let log = make_insert_log(&[
        ("op-1", MAIN_DOCUMENT_ID, 1, 0, "h"),
        ("op-2", OTHER_DOCUMENT_ID, 2, 1, "i"),
    ]);
    let response = get_str(editor_operation_log_validate_result_json(
        CString::new(log.to_json().unwrap()).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
}

#[test]
fn test_editor_operation_insert_json_builds_applicable_operation() {
    let h = create_main_editor("hello");

    let operation_json = get_str(editor_operation_insert_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        5,
        CString::new(" world").unwrap().as_ptr(),
    ));

    assert!(!operation_json.is_empty());
    let operation: serde_json::Value = serde_json::from_str(&operation_json).unwrap();
    assert_eq!(operation["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(operation["sequence"], 1);
    assert_eq!(operation["edit"]["Insert"]["at"], 5);
    assert_eq!(operation["edit"]["Insert"]["text"], " world");

    let outcome = get_str(editor_apply_operation_json(
        h,
        CString::new(operation_json).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&outcome).unwrap();
    assert_eq!(value["applied_text_edits"], 1);
    assert_eq!(get_str(editor_get_text(h)), "hello world");
    editor_destroy(h);
}

#[test]
fn test_editor_operation_replace_result_json_builds_wrapped_operation() {
    let response = get_str(editor_operation_replace_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        1,
        4,
        CString::new("ey").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["operation_id"], "op-1");
    assert_eq!(value["value"]["edit"]["Replace"]["range"]["start"], 1);
    assert_eq!(value["value"]["edit"]["Replace"]["range"]["end"], 4);
    assert_eq!(value["value"]["edit"]["Replace"]["text"], "ey");
}

#[test]
fn test_editor_operation_delete_result_json_rejects_invalid_range() {
    let response = get_str(editor_operation_delete_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        4,
        1,
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_range");
}

#[test]
fn test_editor_operation_insert_result_json_reports_null_text() {
    let response = get_str(editor_operation_insert_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        1,
        100,
        0,
        std::ptr::null(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "null_text");
}

#[test]
fn test_editor_operation_insert_result_json_reports_invalid_sequence() {
    let response = get_str(editor_operation_insert_result_json(
        CString::new("op-1").unwrap().as_ptr(),
        CString::new(MAIN_DOCUMENT_ID).unwrap().as_ptr(),
        CString::new(ACTOR_ID).unwrap().as_ptr(),
        0,
        100,
        0,
        CString::new("x").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_sequence");
}

#[test]
fn test_editor_artifact_capture_restore_with_tail_log() {
    let h = create_main_editor("hello");
    let log = make_insert_log(&[("op-1", MAIN_DOCUMENT_ID, 1, 5, " world")]);
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    assert!(!artifact_json.is_empty());

    let h2 = editor_artifact_restore(CString::new(artifact_json).unwrap().as_ptr());
    assert!(!h2.is_null());
    let text = get_str(editor_get_text(h2));
    assert_eq!(text, "hello world");

    editor_destroy(h);
    editor_destroy(h2);
}

#[test]
fn test_editor_apply_operation_json() {
    let h = create_main_editor("hello");
    let operation = make_insert_operation("op-1", MAIN_DOCUMENT_ID, 1, 5, " world");
    let operation_json = CString::new(operation.to_json().unwrap()).unwrap();

    let outcome = get_str(editor_apply_operation_json(h, operation_json.as_ptr()));
    let value: serde_json::Value = serde_json::from_str(&outcome).unwrap();
    assert_eq!(value["applied_text_edits"], 1);
    assert_eq!(get_str(editor_get_text(h)), "hello world");

    editor_destroy(h);
}

#[test]
fn test_editor_replay_log_json_rejects_wrong_document() {
    let h = create_main_editor("hello");
    let log = make_insert_log(&[("op-1", OTHER_DOCUMENT_ID, 1, 5, " bad")]);
    let log_json = CString::new(log.to_json().unwrap()).unwrap();

    let ptr = editor_replay_log_json(h, log_json.as_ptr());

    assert!(ptr.is_null());
    assert_eq!(get_str(editor_get_text(h)), "hello");
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_capture_defaults_empty_document_id() {
    let h = editor_create_with_content(CString::new("hello").unwrap().as_ptr());
    let artifact = get_str(editor_artifact_capture(
        h,
        std::ptr::null(),
        std::ptr::null(),
    ));
    let value: serde_json::Value = serde_json::from_str(&artifact).unwrap();

    assert_eq!(value["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["document_id"], "untitled://waraq-editor");
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_compact_retains_tail() {
    let h = create_main_editor("");
    let log = main_abc_log();
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    let compacted_json = get_str(editor_artifact_compact(
        CString::new(artifact_json).unwrap().as_ptr(),
        1,
        1234,
    ));
    let compacted = EditorArtifact::from_json(&compacted_json).unwrap();
    let restored = restore_editor_artifact(&compacted).unwrap();

    assert_eq!(compacted.snapshot.content.as_deref(), Some("ab"));
    assert_eq!(compacted.operation_log.len(), 1);
    assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
    assert_eq!(
        compacted.metadata["compaction"]["compacted_operation_count"],
        2
    );
    assert_eq!(restored.buffer.to_string(), "abc");

    editor_destroy(h);
}

#[test]
fn test_editor_artifact_maintenance_plan_and_maintain() {
    let h = create_main_editor("");
    let log = main_abc_log();
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    let artifact_c = CString::new(artifact_json.clone()).unwrap();
    let plan_json = get_str(editor_artifact_maintenance_plan(artifact_c.as_ptr(), 2, 1));
    let plan: serde_json::Value = serde_json::from_str(&plan_json).unwrap();
    assert_eq!(plan["should_compact"], true);
    assert_eq!(plan["compactable_operation_count"], 2);

    let maintained_json = get_str(editor_artifact_maintain(
        CString::new(artifact_json).unwrap().as_ptr(),
        2,
        1,
        1234,
    ));
    let maintained = EditorArtifact::from_json(&maintained_json).unwrap();
    let restored = restore_editor_artifact(&maintained).unwrap();

    assert_eq!(maintained.snapshot.content.as_deref(), Some("ab"));
    assert_eq!(maintained.operation_log.len(), 1);
    assert_eq!(restored.buffer.to_string(), "abc");

    editor_destroy(h);
}

#[test]
fn test_editor_apply_operation_result_json_reports_wrong_document() {
    let h = create_main_editor("hello");
    let operation = make_insert_operation("op-1", OTHER_DOCUMENT_ID, 1, 5, " bad");
    let operation_json = CString::new(operation.to_json().unwrap()).unwrap();

    let response = get_str(editor_apply_operation_result_json(
        h,
        operation_json.as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "operation_document_mismatch");
    assert_eq!(get_str(editor_get_text(h)), "hello");
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_capture_result_json_reports_bad_log_json() {
    let h = create_main_editor("hello");
    let document_id = CString::new(MAIN_DOCUMENT_ID).unwrap();
    let log_json = CString::new("not json").unwrap();

    let response = get_str(editor_artifact_capture_result_json(
        h,
        document_id.as_ptr(),
        log_json.as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_operation_log_json");
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_compact_result_json_returns_artifact_object() {
    let h = create_main_editor("");
    let log = main_abc_log();
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    let response = get_str(editor_artifact_compact_result_json(
        CString::new(artifact_json).unwrap().as_ptr(),
        1,
        1234,
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["snapshot"]["content"], "ab");
    assert_eq!(
        value["value"]["operation_log"]["operations"]
            .as_array()
            .unwrap()
            .len(),
        1
    );
    assert_eq!(
        value["value"]["operation_log"]["operations"][0]["operation_id"],
        "op-3"
    );
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_restore_preflight_result_json_reports_restore_ready_summary() {
    let h = create_main_editor("hello");
    let log = make_insert_log(&[("op-1", MAIN_DOCUMENT_ID, 1, 5, " world")]);
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    let response = get_str(editor_artifact_restore_preflight_result_json(
        CString::new(artifact_json).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["restore_ready"], true);
    assert_eq!(value["value"]["schema_version"], OPERATION_ENVELOPE_VERSION);
    assert_eq!(value["value"]["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["document_id"], MAIN_DOCUMENT_ID);
    assert_eq!(value["value"]["snapshot_file_uri"], MAIN_DOCUMENT_ID);
    assert_eq!(value["value"]["snapshot_language"], "");
    assert_eq!(value["value"]["has_snapshot_content"], true);
    assert_eq!(value["value"]["has_operation_tail"], true);
    assert_eq!(value["value"]["operation_count"], 1);
    assert_eq!(value["value"]["first_sequence"], 1);
    assert_eq!(value["value"]["last_sequence"], 1);
    assert_eq!(value["value"]["last_operation_id"], "op-1");
    assert!(value.get("error").is_none());
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_restore_preflight_result_json_reports_bad_artifact_json() {
    let response = get_str(editor_artifact_restore_preflight_result_json(
        CString::new("not json").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_artifact_json");
    assert!(value.get("value").is_none());
}

#[test]
fn test_editor_artifact_validate_result_json_reports_summary() {
    let h = create_main_editor("hello");
    let log = make_insert_log(&[("op-1", MAIN_DOCUMENT_ID, 1, 5, " world")]);
    let artifact_json = capture_artifact_json(h, MAIN_DOCUMENT_ID, &log);
    let response = get_str(editor_artifact_validate_result_json(
        CString::new(artifact_json).unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], true);
    assert_eq!(value["value"]["engine"], WARAQ_EDITOR_ENGINE_ID);
    assert_eq!(value["value"]["document_id"], MAIN_DOCUMENT_ID);
    assert_eq!(value["value"]["operation_count"], 1);
    assert_eq!(value["value"]["first_sequence"], 1);
    assert_eq!(value["value"]["last_sequence"], 1);
    assert_eq!(value["value"]["last_operation_id"], "op-1");
    editor_destroy(h);
}

#[test]
fn test_editor_artifact_validate_result_json_reports_bad_artifact_json() {
    let response = get_str(editor_artifact_validate_result_json(
        CString::new("not json").unwrap().as_ptr(),
    ));
    let value: serde_json::Value = serde_json::from_str(&response).unwrap();

    assert_eq!(value["ok"], false);
    assert_eq!(value["error"]["code"], "invalid_artifact_json");
}
