#include "../waraq_editor_core.h"

#include <stddef.h>

#define COUNT_OF(items) (sizeof(items) / sizeof((items)[0]))
#define ARTIFACT_SYMBOL_COUNT 48U

typedef char* (*artifact_no_args_string_fn)(void);
typedef char* (*artifact_capture_fn)(const EditorHandle*, const char*, const char*);
typedef EditorHandle* (*artifact_restore_fn)(const char*);
typedef char* (*artifact_editor_json_fn)(EditorHandle*, const char*);
typedef char* (*artifact_two_u64_fn)(const char*, uint64_t, uint64_t);
typedef char* (*artifact_three_u64_fn)(const char*, uint64_t, uint64_t, uint64_t);
typedef char* (*artifact_string_fn)(const char*);
typedef char* (*operation_insert_fn)(
    const char*,
    const char*,
    const char*,
    uint64_t,
    uint64_t,
    uint64_t,
    const char*);
typedef char* (*operation_delete_fn)(
    const char*,
    const char*,
    const char*,
    uint64_t,
    uint64_t,
    uint64_t,
    uint64_t);
typedef char* (*operation_replace_fn)(
    const char*,
    const char*,
    const char*,
    uint64_t,
    uint64_t,
    uint64_t,
    uint64_t,
    const char*);
typedef char* (*operation_log_append_fn)(const char*, const char*);
typedef char* (*operation_log_append_for_document_fn)(const char*, const char*, const char*);
typedef char* (*operation_log_validate_fn)(const char*);
typedef char* (*operation_log_validate_for_document_fn)(const char*, const char*);

static artifact_no_args_string_fn no_args_string_symbols[] = {
    editor_artifact_capabilities_json,
    editor_artifact_contract_json,
    editor_artifact_boundary_json,
    editor_artifact_engine_registry_json,
    editor_artifact_readiness_manifest_json,
    editor_artifact_test_profile_json,
    editor_artifact_lifecycle_profile_json,
    editor_operation_log_empty_json,
    editor_artifact_capabilities_result_json,
    editor_artifact_contract_result_json,
    editor_artifact_boundary_result_json,
    editor_artifact_engine_registry_result_json,
    editor_artifact_readiness_manifest_result_json,
    editor_artifact_test_profile_result_json,
    editor_artifact_lifecycle_profile_result_json,
    editor_operation_log_empty_result_json,
};

static artifact_capture_fn capture_symbols[] = {
    editor_artifact_capture,
    editor_artifact_capture_result_json,
};

static artifact_restore_fn restore_symbols[] = {
    editor_artifact_restore,
};

static artifact_editor_json_fn editor_json_symbols[] = {
    editor_apply_operation_json,
    editor_replay_log_json,
    editor_apply_operation_result_json,
    editor_replay_log_result_json,
};

static artifact_two_u64_fn artifact_two_u64_symbols[] = {
    editor_artifact_compact,
    editor_artifact_maintenance_plan,
    editor_artifact_compact_result_json,
    editor_artifact_maintenance_plan_result_json,
};

static artifact_three_u64_fn artifact_three_u64_symbols[] = {
    editor_artifact_maintain,
    editor_artifact_maintain_result_json,
};

static artifact_string_fn artifact_string_symbols[] = {
    editor_artifact_resolve_engine_id_result_json,
    editor_artifact_engine_contract_result_json,
    editor_artifact_engine_readiness_manifest_result_json,
    editor_artifact_restore_preflight_result_json,
    editor_artifact_validate_result_json,
};

static operation_insert_fn insert_symbols[] = {
    editor_operation_insert_json,
    editor_operation_insert_result_json,
};

static operation_delete_fn delete_symbols[] = {
    editor_operation_delete_json,
    editor_operation_delete_result_json,
};

static operation_replace_fn replace_symbols[] = {
    editor_operation_replace_json,
    editor_operation_replace_result_json,
};

static operation_log_append_fn append_symbols[] = {
    editor_operation_log_append_json,
    editor_operation_log_append_result_json,
};

static operation_log_append_for_document_fn append_for_document_symbols[] = {
    editor_operation_log_append_for_document_json,
    editor_operation_log_append_for_document_result_json,
};

static operation_log_validate_fn validate_log_symbols[] = {
    editor_operation_log_validate_json,
    editor_operation_log_validate_result_json,
};

static operation_log_validate_for_document_fn validate_log_for_document_symbols[] = {
    editor_operation_log_validate_for_document_json,
    editor_operation_log_validate_for_document_result_json,
};

#define REQUIRE_ALL(symbols, count)                  \
    do {                                             \
        for (size_t index = 0; index < COUNT_OF(symbols); index++) { \
            if ((symbols)[index] == NULL) {          \
                return 1;                            \
            }                                        \
        }                                            \
        (count) += COUNT_OF(symbols);                \
    } while (0)

int main(void) {
    size_t checked = 0;

    REQUIRE_ALL(no_args_string_symbols, checked);
    REQUIRE_ALL(capture_symbols, checked);
    REQUIRE_ALL(restore_symbols, checked);
    REQUIRE_ALL(editor_json_symbols, checked);
    REQUIRE_ALL(artifact_two_u64_symbols, checked);
    REQUIRE_ALL(artifact_three_u64_symbols, checked);
    REQUIRE_ALL(artifact_string_symbols, checked);
    REQUIRE_ALL(insert_symbols, checked);
    REQUIRE_ALL(delete_symbols, checked);
    REQUIRE_ALL(replace_symbols, checked);
    REQUIRE_ALL(append_symbols, checked);
    REQUIRE_ALL(append_for_document_symbols, checked);
    REQUIRE_ALL(validate_log_symbols, checked);
    REQUIRE_ALL(validate_log_for_document_symbols, checked);

    return checked == ARTIFACT_SYMBOL_COUNT ? 0 : 1;
}
