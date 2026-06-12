#include "../waraq_editor_core.h"

#include <stdio.h>
#include <string.h>

static int require_pointer(const void* pointer, const char* label) {
    if (pointer != NULL) {
        return 1;
    }
    fprintf(stderr, "%s returned NULL\n", label);
    return 0;
}

static int require_contains(const char* text, const char* expected, const char* label) {
    if (text != NULL && strstr(text, expected) != NULL) {
        return 1;
    }
    fprintf(stderr, "%s did not contain %s\n", label, expected);
    return 0;
}

int main(void) {
    int status = 1;
    char* caps = NULL;
    char* caps_result = NULL;
    char* contract = NULL;
    char* contract_result = NULL;
    char* boundary = NULL;
    char* boundary_result = NULL;
    char* engine_registry = NULL;
    char* engine_registry_result = NULL;
    char* engine_resolution = NULL;
    char* engine_resolution_error = NULL;
    char* engine_contract = NULL;
    char* engine_readiness = NULL;
    char* readiness = NULL;
    char* profile = NULL;
    char* lifecycle = NULL;
    char* readiness_result = NULL;
    char* profile_result = NULL;
    char* lifecycle_result = NULL;
    char* op = NULL;
    char* log0 = NULL;
    char* log1 = NULL;
    char* artifact = NULL;
    char* restore_preflight = NULL;
    char* restored_text = NULL;
    EditorHandle* editor = NULL;
    EditorHandle* restored = NULL;

    caps = editor_artifact_capabilities_json();
    if (!require_pointer(caps, "editor_artifact_capabilities_json")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"function_catalog\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"signature_families\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"payload_families\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"error_code_catalog\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_test_profile_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_lifecycle_profile_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_readiness_manifest_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_test_profile_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_lifecycle_profile_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_readiness_manifest_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_capabilities_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_contract_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_boundary_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_boundary_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_engine_registry_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_engine_registry_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_resolve_engine_id_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_engine_contract_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_engine_readiness_manifest_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_artifact_restore_preflight_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"editor_operation_insert_result_json\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"integer_out_of_range\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"unknown_waraq_family_engine\"", "capabilities")) {
        goto cleanup;
    }
    if (!require_contains(caps, "\"artifact_engine_registry_unavailable\"", "capabilities")) {
        goto cleanup;
    }

    caps_result = editor_artifact_capabilities_result_json();
    if (!require_pointer(caps_result, "editor_artifact_capabilities_result_json")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"ok\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"api_version\"", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"editor_artifact_capabilities_result_json\"", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_artifact_restore_preflight\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_waraq_boundary_manifest\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_waraq_engine_registry\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_waraq_engine_id_resolution\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_waraq_engine_contract\":true", "capabilities_result")) {
        goto cleanup;
    }
    if (!require_contains(caps_result, "\"supports_waraq_engine_readiness_manifest\":true", "capabilities_result")) {
        goto cleanup;
    }

    contract = editor_artifact_contract_json();
    if (!require_pointer(contract, "editor_artifact_contract_json")) {
        goto cleanup;
    }
    if (!require_contains(contract, "\"shared_guarantees\"", "contract")) {
        goto cleanup;
    }

    contract_result = editor_artifact_contract_result_json();
    if (!require_pointer(contract_result, "editor_artifact_contract_result_json")) {
        goto cleanup;
    }
    if (!require_contains(contract_result, "\"ok\":true", "contract_result")) {
        goto cleanup;
    }
    if (!require_contains(contract_result, "\"shared_guarantees\"", "contract_result")) {
        goto cleanup;
    }

    boundary = editor_artifact_boundary_json();
    if (!require_pointer(boundary, "editor_artifact_boundary_json")) {
        goto cleanup;
    }
    if (!require_contains(boundary, "\"Shared Core + Specialized Engines\"", "boundary")) {
        goto cleanup;
    }
    if (!require_contains(boundary, "\"code.engine\"", "boundary")) {
        goto cleanup;
    }

    boundary_result = editor_artifact_boundary_result_json();
    if (!require_pointer(boundary_result, "editor_artifact_boundary_result_json")) {
        goto cleanup;
    }
    if (!require_contains(boundary_result, "\"ok\":true", "boundary_result")) {
        goto cleanup;
    }
    if (!require_contains(boundary_result, "\"maqal.engine\"", "boundary_result")) {
        goto cleanup;
    }

    engine_registry = editor_artifact_engine_registry_json();
    if (!require_pointer(engine_registry, "editor_artifact_engine_registry_json")) {
        goto cleanup;
    }
    if (!require_contains(engine_registry, "\"registry_version\":1", "engine_registry")) {
        goto cleanup;
    }
    if (!require_contains(engine_registry, "\"canonical_engine_ids\":[\"sheet.engine\"", "engine_registry")) {
        goto cleanup;
    }
    if (!require_contains(engine_registry, "\"legacy_engine_ids\":[\"code\",\"maqal\"]", "engine_registry")) {
        goto cleanup;
    }

    engine_registry_result = editor_artifact_engine_registry_result_json();
    if (!require_pointer(engine_registry_result, "editor_artifact_engine_registry_result_json")) {
        goto cleanup;
    }
    if (!require_contains(engine_registry_result, "\"ok\":true", "engine_registry_result")) {
        goto cleanup;
    }
    if (!require_contains(engine_registry_result, "\"accepted_engine_id_count\":7", "engine_registry_result")) {
        goto cleanup;
    }

    engine_resolution = editor_artifact_resolve_engine_id_result_json("code");
    if (!require_pointer(engine_resolution, "editor_artifact_resolve_engine_id_result_json")) {
        goto cleanup;
    }
    if (!require_contains(engine_resolution, "\"ok\":true", "engine_resolution")) {
        goto cleanup;
    }
    if (!require_contains(engine_resolution, "\"canonical_engine_id\":\"code.engine\"", "engine_resolution")) {
        goto cleanup;
    }
    if (!require_contains(engine_resolution, "\"status\":\"legacy\"", "engine_resolution")) {
        goto cleanup;
    }

    engine_resolution_error = editor_artifact_resolve_engine_id_result_json("unknown.engine");
    if (!require_pointer(engine_resolution_error, "editor_artifact_resolve_engine_id_result_json error")) {
        goto cleanup;
    }
    if (!require_contains(engine_resolution_error, "\"ok\":false", "engine_resolution_error")) {
        goto cleanup;
    }
    if (!require_contains(engine_resolution_error, "\"unknown_waraq_family_engine\"", "engine_resolution_error")) {
        goto cleanup;
    }

    engine_contract = editor_artifact_engine_contract_result_json("code");
    if (!require_pointer(engine_contract, "editor_artifact_engine_contract_result_json")) {
        goto cleanup;
    }
    if (!require_contains(engine_contract, "\"ok\":true", "engine_contract")) {
        goto cleanup;
    }
    if (!require_contains(engine_contract, "\"engine_id\":\"code.engine\"", "engine_contract")) {
        goto cleanup;
    }
    if (!require_contains(engine_contract, "\"shared_guarantees\"", "engine_contract")) {
        goto cleanup;
    }

    engine_readiness = editor_artifact_engine_readiness_manifest_result_json("code");
    if (!require_pointer(engine_readiness, "editor_artifact_engine_readiness_manifest_result_json")) {
        goto cleanup;
    }
    if (!require_contains(engine_readiness, "\"ok\":true", "engine_readiness")) {
        goto cleanup;
    }
    if (!require_contains(engine_readiness, "\"engine_id\":\"code.engine\"", "engine_readiness")) {
        goto cleanup;
    }
    if (!require_contains(engine_readiness, "\"required_shared_check_count\"", "engine_readiness")) {
        goto cleanup;
    }

    readiness = editor_artifact_readiness_manifest_json();
    if (!require_pointer(readiness, "editor_artifact_readiness_manifest_json")) {
        goto cleanup;
    }
    if (!require_contains(readiness, "\"manifest_version\"", "readiness")) {
        goto cleanup;
    }
    if (!require_contains(readiness, "\"required_helpers\"", "readiness")) {
        goto cleanup;
    }
    if (!require_contains(readiness, "\"lifecycle_harness_required\"", "readiness")) {
        goto cleanup;
    }

    profile = editor_artifact_test_profile_json();
    if (!require_pointer(profile, "editor_artifact_test_profile_json")) {
        goto cleanup;
    }
    if (!require_contains(profile, "\"required_shared_check_count\"", "profile")) {
        goto cleanup;
    }
    if (!require_contains(profile, "\"lifecycle_harness_shared_check_count\"", "profile")) {
        goto cleanup;
    }

    lifecycle = editor_artifact_lifecycle_profile_json();
    if (!require_pointer(lifecycle, "editor_artifact_lifecycle_profile_json")) {
        goto cleanup;
    }
    if (!require_contains(lifecycle, "\"completed_shared_check_count\"", "lifecycle")) {
        goto cleanup;
    }
    if (!require_contains(lifecycle, "\"completed_compaction_harness_check_count\"", "lifecycle")) {
        goto cleanup;
    }

    readiness_result = editor_artifact_readiness_manifest_result_json();
    if (!require_pointer(readiness_result, "editor_artifact_readiness_manifest_result_json")) {
        goto cleanup;
    }
    if (!require_contains(readiness_result, "\"ok\":true", "readiness_result")) {
        goto cleanup;
    }
    if (!require_contains(readiness_result, "\"manifest_version\"", "readiness_result")) {
        goto cleanup;
    }

    profile_result = editor_artifact_test_profile_result_json();
    if (!require_pointer(profile_result, "editor_artifact_test_profile_result_json")) {
        goto cleanup;
    }
    if (!require_contains(profile_result, "\"ok\":true", "profile_result")) {
        goto cleanup;
    }
    if (!require_contains(profile_result, "\"required_shared_check_count\"", "profile_result")) {
        goto cleanup;
    }

    lifecycle_result = editor_artifact_lifecycle_profile_result_json();
    if (!require_pointer(lifecycle_result, "editor_artifact_lifecycle_profile_result_json")) {
        goto cleanup;
    }
    if (!require_contains(lifecycle_result, "\"ok\":true", "lifecycle_result")) {
        goto cleanup;
    }
    if (!require_contains(lifecycle_result, "\"completed_shared_check_count\"", "lifecycle_result")) {
        goto cleanup;
    }

    editor = editor_create_with_content("hello");
    if (!require_pointer(editor, "editor_create_with_content")) {
        goto cleanup;
    }
    editor_set_file_uri(editor, "file:///main.txt");

    op = editor_operation_insert_json(
        "op-1",
        "file:///main.txt",
        "actor-1",
        1,
        100,
        5,
        " world"
    );
    if (!require_pointer(op, "editor_operation_insert_json")) {
        goto cleanup;
    }

    log0 = editor_operation_log_empty_json();
    if (!require_pointer(log0, "editor_operation_log_empty_json")) {
        goto cleanup;
    }

    log1 = editor_operation_log_append_json(log0, op);
    if (!require_pointer(log1, "editor_operation_log_append_json")) {
        goto cleanup;
    }

    artifact = editor_artifact_capture(editor, "file:///main.txt", log1);
    if (!require_pointer(artifact, "editor_artifact_capture")) {
        goto cleanup;
    }

    restore_preflight = editor_artifact_restore_preflight_result_json(artifact);
    if (!require_pointer(restore_preflight, "editor_artifact_restore_preflight_result_json")) {
        goto cleanup;
    }
    if (!require_contains(restore_preflight, "\"ok\":true", "restore_preflight")) {
        goto cleanup;
    }
    if (!require_contains(restore_preflight, "\"restore_ready\":true", "restore_preflight")) {
        goto cleanup;
    }
    if (!require_contains(restore_preflight, "\"operation_count\":1", "restore_preflight")) {
        goto cleanup;
    }

    restored = editor_artifact_restore(artifact);
    if (!require_pointer(restored, "editor_artifact_restore")) {
        goto cleanup;
    }

    restored_text = editor_get_text(restored);
    if (!require_pointer(restored_text, "editor_get_text")) {
        goto cleanup;
    }

    if (strcmp(restored_text, "hello world") != 0) {
        fprintf(stderr, "restored text mismatch: %s\n", restored_text);
        goto cleanup;
    }

    status = 0;

cleanup:
    editor_free_str(restored_text);
    if (restored != NULL) {
        editor_destroy(restored);
    }
    editor_free_str(restore_preflight);
    editor_free_str(artifact);
    editor_free_str(log1);
    editor_free_str(log0);
    editor_free_str(op);
    if (editor != NULL) {
        editor_destroy(editor);
    }
    editor_free_str(contract);
    editor_free_str(contract_result);
    editor_free_str(boundary);
    editor_free_str(boundary_result);
    editor_free_str(engine_registry);
    editor_free_str(engine_registry_result);
    editor_free_str(engine_resolution);
    editor_free_str(engine_resolution_error);
    editor_free_str(engine_contract);
    editor_free_str(engine_readiness);
    editor_free_str(readiness);
    editor_free_str(profile);
    editor_free_str(lifecycle);
    editor_free_str(readiness_result);
    editor_free_str(profile_result);
    editor_free_str(lifecycle_result);
    editor_free_str(caps_result);
    editor_free_str(caps);
    return status;
}
