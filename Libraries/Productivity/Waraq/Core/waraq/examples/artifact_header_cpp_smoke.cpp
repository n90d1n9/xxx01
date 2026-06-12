#include "../waraq_editor_core.h"

#include <cstring>
#include <iostream>
#include <memory>

namespace {

using WaraqString = std::unique_ptr<char, decltype(&editor_free_str)>;

bool contains(const char* text, const char* expected) {
    return text != nullptr && std::strstr(text, expected) != nullptr;
}

bool require_contains(const WaraqString& value, const char* expected, const char* label) {
    if (contains(value.get(), expected)) {
        return true;
    }
    std::cerr << label << " did not contain " << expected << '\n';
    return false;
}

}  // namespace

int main() {
    WaraqString version(editor_version(), editor_free_str);
    WaraqString capabilities(editor_artifact_capabilities_json(), editor_free_str);
    WaraqString capabilities_result(editor_artifact_capabilities_result_json(), editor_free_str);
    WaraqString contract(editor_artifact_contract_json(), editor_free_str);
    WaraqString contract_result(editor_artifact_contract_result_json(), editor_free_str);
    WaraqString boundary(editor_artifact_boundary_json(), editor_free_str);
    WaraqString boundary_result(editor_artifact_boundary_result_json(), editor_free_str);
    WaraqString engine_registry(editor_artifact_engine_registry_json(), editor_free_str);
    WaraqString engine_registry_result(
        editor_artifact_engine_registry_result_json(),
        editor_free_str);
    WaraqString engine_resolution(
        editor_artifact_resolve_engine_id_result_json("code"),
        editor_free_str);
    WaraqString engine_resolution_error(
        editor_artifact_resolve_engine_id_result_json("unknown.engine"),
        editor_free_str);
    WaraqString engine_contract(
        editor_artifact_engine_contract_result_json("code"),
        editor_free_str);
    WaraqString engine_readiness(
        editor_artifact_engine_readiness_manifest_result_json("code"),
        editor_free_str);
    WaraqString restore_preflight_error(
        editor_artifact_restore_preflight_result_json(nullptr),
        editor_free_str);
    WaraqString readiness(editor_artifact_readiness_manifest_json(), editor_free_str);
    WaraqString profile(editor_artifact_test_profile_json(), editor_free_str);
    WaraqString lifecycle(editor_artifact_lifecycle_profile_json(), editor_free_str);
    WaraqString readiness_result(editor_artifact_readiness_manifest_result_json(), editor_free_str);
    WaraqString profile_result(editor_artifact_test_profile_result_json(), editor_free_str);
    WaraqString lifecycle_result(editor_artifact_lifecycle_profile_result_json(), editor_free_str);

    if (version == nullptr || std::strlen(version.get()) == 0) {
        std::cerr << "editor_version returned an empty value\n";
        return 1;
    }
    if (!require_contains(capabilities, "\"api_version\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"function_catalog\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"signature_families\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"payload_families\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"error_code_catalog\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_test_profile_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_lifecycle_profile_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_readiness_manifest_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_test_profile_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_lifecycle_profile_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_readiness_manifest_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_capabilities_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_contract_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_boundary_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_boundary_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_engine_registry_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_engine_registry_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_resolve_engine_id_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_engine_contract_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_engine_readiness_manifest_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_artifact_restore_preflight_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"editor_operation_insert_result_json\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"integer_out_of_range\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"unknown_waraq_family_engine\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities, "\"artifact_engine_registry_unavailable\"", "capabilities")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"ok\":true", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"api_version\"", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"editor_artifact_capabilities_result_json\"", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"supports_waraq_engine_registry\":true", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"supports_waraq_engine_id_resolution\":true", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"supports_waraq_engine_contract\":true", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(capabilities_result, "\"supports_waraq_engine_readiness_manifest\":true", "capabilities_result")) {
        return 1;
    }
    if (!require_contains(contract, "\"shared_guarantees\"", "contract")) {
        return 1;
    }
    if (!require_contains(contract_result, "\"ok\":true", "contract_result")) {
        return 1;
    }
    if (!require_contains(contract_result, "\"shared_guarantees\"", "contract_result")) {
        return 1;
    }
    if (!require_contains(boundary, "\"Shared Core + Specialized Engines\"", "boundary")) {
        return 1;
    }
    if (!require_contains(boundary, "\"code.engine\"", "boundary")) {
        return 1;
    }
    if (!require_contains(boundary_result, "\"ok\":true", "boundary_result")) {
        return 1;
    }
    if (!require_contains(boundary_result, "\"maqal.engine\"", "boundary_result")) {
        return 1;
    }
    if (!require_contains(engine_registry, "\"registry_version\":1", "engine_registry")) {
        return 1;
    }
    if (!require_contains(engine_registry, "\"canonical_engine_ids\":[\"sheet.engine\"", "engine_registry")) {
        return 1;
    }
    if (!require_contains(engine_registry_result, "\"ok\":true", "engine_registry_result")) {
        return 1;
    }
    if (!require_contains(engine_registry_result, "\"accepted_engine_id_count\":7", "engine_registry_result")) {
        return 1;
    }
    if (!require_contains(engine_resolution, "\"ok\":true", "engine_resolution")) {
        return 1;
    }
    if (!require_contains(engine_resolution, "\"canonical_engine_id\":\"code.engine\"", "engine_resolution")) {
        return 1;
    }
    if (!require_contains(engine_resolution, "\"status\":\"legacy\"", "engine_resolution")) {
        return 1;
    }
    if (!require_contains(engine_resolution_error, "\"ok\":false", "engine_resolution_error")) {
        return 1;
    }
    if (!require_contains(engine_resolution_error, "\"unknown_waraq_family_engine\"", "engine_resolution_error")) {
        return 1;
    }
    if (!require_contains(engine_contract, "\"ok\":true", "engine_contract")) {
        return 1;
    }
    if (!require_contains(engine_contract, "\"engine_id\":\"code.engine\"", "engine_contract")) {
        return 1;
    }
    if (!require_contains(engine_contract, "\"shared_guarantees\"", "engine_contract")) {
        return 1;
    }
    if (!require_contains(engine_readiness, "\"ok\":true", "engine_readiness")) {
        return 1;
    }
    if (!require_contains(engine_readiness, "\"engine_id\":\"code.engine\"", "engine_readiness")) {
        return 1;
    }
    if (!require_contains(engine_readiness, "\"required_shared_check_count\"", "engine_readiness")) {
        return 1;
    }
    if (!require_contains(restore_preflight_error, "\"ok\":false", "restore_preflight_error")) {
        return 1;
    }
    if (!require_contains(restore_preflight_error, "\"null_artifact_json\"", "restore_preflight_error")) {
        return 1;
    }
    if (!require_contains(readiness, "\"manifest_version\"", "readiness")) {
        return 1;
    }
    if (!require_contains(readiness, "\"required_helpers\"", "readiness")) {
        return 1;
    }
    if (!require_contains(readiness, "\"lifecycle_harness_required\"", "readiness")) {
        return 1;
    }
    if (!require_contains(profile, "\"required_shared_check_count\"", "profile")) {
        return 1;
    }
    if (!require_contains(profile, "\"lifecycle_harness_shared_check_count\"", "profile")) {
        return 1;
    }
    if (!require_contains(lifecycle, "\"completed_shared_check_count\"", "lifecycle")) {
        return 1;
    }
    if (!require_contains(lifecycle, "\"completed_compaction_harness_check_count\"", "lifecycle")) {
        return 1;
    }
    if (!require_contains(readiness_result, "\"ok\":true", "readiness_result")) {
        return 1;
    }
    if (!require_contains(readiness_result, "\"manifest_version\"", "readiness_result")) {
        return 1;
    }
    if (!require_contains(profile_result, "\"ok\":true", "profile_result")) {
        return 1;
    }
    if (!require_contains(profile_result, "\"required_shared_check_count\"", "profile_result")) {
        return 1;
    }
    if (!require_contains(lifecycle_result, "\"ok\":true", "lifecycle_result")) {
        return 1;
    }
    if (!require_contains(lifecycle_result, "\"completed_shared_check_count\"", "lifecycle_result")) {
        return 1;
    }

    return 0;
}
