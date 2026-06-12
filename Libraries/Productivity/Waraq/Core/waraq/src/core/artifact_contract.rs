//! Shared artifact contract for Waraq-family domain engines.
//!
//! Waraq owns the stable transport shape for editor-like engines: operation
//! envelopes, ordered logs, snapshot-plus-tail artifacts, validation, replay,
//! and compaction metadata. Domain engines own their edit enum, snapshot model,
//! and domain-specific replay semantics.

use serde::Serialize;

use crate::core::operation::{
    OperationArtifact, OperationEnvelope, OperationLog, OPERATION_ENVELOPE_VERSION,
};

/// Domain-specific operation envelope carried by the Waraq artifact contract.
pub type ArtifactOperation<Edit> = OperationEnvelope<Edit>;

/// Ordered domain operation tail carried by the Waraq artifact contract.
pub type ArtifactOperationLog<Edit> = OperationLog<Edit>;

/// Persisted domain snapshot plus operation tail carried by the Waraq artifact contract.
pub type DomainArtifact<Snapshot, Edit> = OperationArtifact<Snapshot, Edit>;

/// Current shared artifact contract version.
///
/// This follows `OPERATION_ENVELOPE_VERSION` while the operation envelope schema
/// is the only shared contract dimension. Split it into an independent version
/// if future contract guarantees change without changing envelope serialization.
pub const ARTIFACT_CONTRACT_VERSION: u32 = OPERATION_ENVELOPE_VERSION;

/// Stable primitive names that every Waraq-family artifact engine shares.
pub const ARTIFACT_CONTRACT_PRIMITIVES: ArtifactContractPrimitives = ArtifactContractPrimitives {
    operation: "OperationEnvelope<Edit>",
    operation_log: "OperationLog<Edit>",
    artifact: "OperationArtifact<Snapshot, Edit>",
};

/// Guarantees supplied by Waraq's shared artifact primitives.
pub const SHARED_ARTIFACT_GUARANTEES: &[&str] = &[
    "operation envelopes carry schema_version, engine, document_id, actor_id, sequence, timestamp_ms, edit, and metadata",
    "operation logs validate schema version, engine identity, non-empty identity fields, duplicate operation IDs, and monotonic sequence order",
    "artifacts pair one snapshot with one ordered operation tail for the same engine and document",
    "restore implementations must validate the snapshot and operation tail before mutating editor state",
    "compaction folds an operation prefix into the snapshot while preserving a replayable retained tail and compaction metadata",
];

/// Responsibilities that stay inside each specialized domain engine.
pub const DOMAIN_ARTIFACT_RESPONSIBILITIES: &[&str] = &[
    "choose a stable engine identifier",
    "define a serializable edit operation model",
    "define a serializable snapshot model",
    "validate domain-specific edit ranges and object references against evolving state",
    "apply and replay operations without partially mutating state on failure",
];

/// Implementation step for creating a specialized engine on Waraq's contract.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct DomainEngineImplementationStep {
    /// Stable machine-readable step id for docs and tooling.
    pub id: &'static str,
    /// Human-readable guidance for the step.
    pub description: &'static str,
}

/// Canonical implementation sequence for Waraq-family domain engines.
pub const DOMAIN_ENGINE_IMPLEMENTATION_STEPS: &[DomainEngineImplementationStep] = &[
    DomainEngineImplementationStep {
        id: "engine_id",
        description: "declare one stable engine id and use it in every operation, log, artifact, and conformance test",
    },
    DomainEngineImplementationStep {
        id: "domain_model",
        description: "define a serializable edit enum and snapshot model owned by the domain engine",
    },
    DomainEngineImplementationStep {
        id: "artifact_aliases",
        description: "alias OperationEnvelope<Edit>, OperationLog<Edit>, and OperationArtifact<Snapshot, Edit> instead of inventing a parallel log format",
    },
    DomainEngineImplementationStep {
        id: "operation_builders",
        description: "build operations through OperationEnvelope::new with non-empty operation, document, and actor identifiers",
    },
    DomainEngineImplementationStep {
        id: "restore_pipeline",
        description: "restore by validating the artifact, rebuilding state from the snapshot, then replaying the operation tail",
    },
    DomainEngineImplementationStep {
        id: "maintenance_policy",
        description: "use ArtifactMaintenancePolicy, plan_artifact_maintenance, compact_artifact_with_replayed_prefix, maintain_artifact_with_plan, maintain_artifact_with_plan_outcome, and artifact_compaction_info for shared tail-growth, compaction mechanics, typed outcomes, and metadata inspection around domain-specific prefix replay",
    },
    DomainEngineImplementationStep {
        id: "domain_validation",
        description: "validate domain references, ranges, object ids, formulas, cells, or layout constraints against evolving state before mutation",
    },
    DomainEngineImplementationStep {
        id: "conformance_tests",
        description: "test ArtifactEngineKit::for_waraq_family_engine for registered family engines, ArtifactEngineKit::for_engine for generic experiments, kit.readiness_manifest, validate_artifact_conformance, validate_artifact_replay_harness, validate_artifact_compaction_harness, validate_artifact_lifecycle_harness, validate_artifact_lifecycle_profile, validate_artifact_lifecycle_profile_report, validate_domain_artifact_test_profile, validate_domain_artifact_test_profile_report, and domain_artifact_test_profile, asserting REQUIRED_ARTIFACT_CONFORMANCE_CHECKS, REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS, REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS, completed_shared_check_count, and profile drift plus domain replay behavior",
    },
];

/// Host-readable names for the shared artifact primitives.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize)]
pub struct ArtifactContractPrimitives {
    /// Operation envelope type used for domain edits.
    pub operation: &'static str,
    /// Ordered operation-log type used for replay and compaction tails.
    pub operation_log: &'static str,
    /// Snapshot-plus-log artifact type used for persistence and transfer.
    pub artifact: &'static str,
}

/// Host-readable description of the artifact contract for one engine.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ArtifactContractDescription {
    /// Shared contract version, aligned with the operation envelope schema.
    pub contract_version: u32,
    /// Stable engine identifier used in every operation and artifact.
    pub engine_id: String,
    /// Shared primitive names used by this engine.
    pub primitives: ArtifactContractPrimitives,
    /// Guarantees supplied by Waraq's shared artifact layer.
    pub shared_guarantees: &'static [&'static str],
    /// Responsibilities that remain domain-specific.
    pub domain_responsibilities: &'static [&'static str],
}

/// Build a description of the Waraq artifact contract for a domain engine.
pub fn artifact_contract_description(engine_id: impl Into<String>) -> ArtifactContractDescription {
    ArtifactContractDescription {
        contract_version: ARTIFACT_CONTRACT_VERSION,
        engine_id: engine_id.into(),
        primitives: ARTIFACT_CONTRACT_PRIMITIVES,
        shared_guarantees: SHARED_ARTIFACT_GUARANTEES,
        domain_responsibilities: DOMAIN_ARTIFACT_RESPONSIBILITIES,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde::{Deserialize, Serialize};

    const README: &str = include_str!("../../README.md");

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    struct TestSnapshot {
        content: String,
    }

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    enum TestEdit {
        Insert { at: usize, text: String },
    }

    #[test]
    fn contract_description_exposes_shared_artifact_vocabulary() {
        let description = artifact_contract_description("waraq.test");

        assert_eq!(description.contract_version, OPERATION_ENVELOPE_VERSION);
        assert_eq!(description.engine_id, "waraq.test");
        assert_eq!(description.primitives.operation, "OperationEnvelope<Edit>");
        assert!(description
            .shared_guarantees
            .iter()
            .any(|guarantee| guarantee.contains("compaction")));
        assert!(description
            .domain_responsibilities
            .iter()
            .any(|responsibility| responsibility.contains("edit operation model")));
    }

    #[test]
    fn domain_engine_implementation_steps_cover_core_contract() {
        let step_ids: Vec<&str> = DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .map(|step| step.id)
            .collect();

        assert_eq!(
            step_ids,
            vec![
                "engine_id",
                "domain_model",
                "artifact_aliases",
                "operation_builders",
                "restore_pipeline",
                "maintenance_policy",
                "domain_validation",
                "conformance_tests",
            ]
        );
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("OperationEnvelope<Edit>")
            && step.description.contains("OperationLog<Edit>")
            && step
                .description
                .contains("OperationArtifact<Snapshot, Edit>")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("REQUIRED_ARTIFACT_CONFORMANCE_CHECKS")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("ArtifactEngineKit::for_engine")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("ArtifactEngineKit::for_waraq_family_engine")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("kit.readiness_manifest")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_artifact_replay_harness")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_artifact_compaction_harness")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_artifact_lifecycle_harness")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_artifact_lifecycle_profile")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_artifact_lifecycle_profile_report")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_domain_artifact_test_profile")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("validate_domain_artifact_test_profile_report")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("domain_artifact_test_profile")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("ArtifactMaintenancePolicy")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("compact_artifact_with_replayed_prefix")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("maintain_artifact_with_plan")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS.iter().any(|step| step
            .description
            .contains("maintain_artifact_with_plan_outcome")));
        assert!(DOMAIN_ENGINE_IMPLEMENTATION_STEPS
            .iter()
            .any(|step| step.description.contains("artifact_compaction_info")));
    }

    #[test]
    fn contract_aliases_preserve_operation_artifact_serialization() {
        let operation: ArtifactOperation<TestEdit> = OperationEnvelope::new(
            "waraq.test",
            "op-1",
            "doc-1",
            "actor-1",
            1,
            100,
            TestEdit::Insert {
                at: 0,
                text: "hello".to_owned(),
            },
        );
        let log: ArtifactOperationLog<TestEdit> = OperationLog::from_operations(vec![operation]);
        let artifact: DomainArtifact<TestSnapshot, TestEdit> = OperationArtifact::new(
            "waraq.test",
            "doc-1",
            TestSnapshot {
                content: String::new(),
            },
            log,
        );

        let restored =
            DomainArtifact::<TestSnapshot, TestEdit>::from_json(&artifact.to_json().unwrap())
                .unwrap();

        assert_eq!(restored.engine, "waraq.test");
        assert_eq!(restored.document_id, "doc-1");
        assert_eq!(restored.operation_log.len(), 1);
        assert_eq!(restored.operation_log.last_operation_id(), Some("op-1"));
    }

    #[test]
    fn readme_documents_artifact_versioning_policy() {
        assert!(README.contains("Artifact Versioning Policy"));
        assert!(README.contains("OPERATION_ENVELOPE_VERSION"));
        assert!(README.contains("ARTIFACT_CONTRACT_VERSION"));
        assert!(README.contains("ARTIFACT_API_VERSION"));
        assert!(README.contains("src/ffi/artifact_api/surface.rs"));
        assert!(README.contains("src/ffi/artifact_api/fixtures/"));
    }

    #[test]
    fn readme_documents_waraq_family_engine_recipe() {
        assert!(README.contains("Building a Waraq-Family Engine"));
        assert!(README.contains("pub const ENGINE_ID"));
        assert!(README.contains("pub enum DomainEdit"));
        assert!(README.contains("pub struct DomainSnapshot"));
        assert!(README.contains("pub type DomainOperation = OperationEnvelope<DomainEdit>"));
        assert!(README.contains("pub type DomainOperationLog = OperationLog<DomainEdit>"));
        assert!(README
            .contains("pub type DomainArtifact = OperationArtifact<DomainSnapshot, DomainEdit>"));
        assert!(README.contains("ArtifactEngineKit::for_waraq_family_engine(ENGINE_ID)"));
        assert!(README.contains("ArtifactEngineKit::for_waraq_family_engine_with_compaction"));
        assert!(README.contains("ArtifactEngineKit::for_engine(ENGINE_ID)"));
        assert!(README.contains("kit.validate_lifecycle_harness(...)"));
        assert!(README.contains("kit.readiness_manifest()"));
        assert!(README.contains("artifact.validate_for_engine(ENGINE_ID)"));
        assert!(README.contains("domain_artifact_test_profile(ENGINE_ID)"));
        assert!(README.contains("validate_artifact_conformance(ENGINE_ID, &artifact)"));
        assert!(README.contains("validate_artifact_replay_harness(...)"));
        assert!(README.contains("validate_artifact_compaction_harness(...)"));
        assert!(README.contains("validate_artifact_lifecycle_harness(...)"));
        assert!(README.contains("validate_artifact_lifecycle_profile(...)"));
        assert!(README.contains("validate_artifact_lifecycle_profile_report(...)"));
        assert!(README.contains("validate_domain_artifact_test_profile(...)"));
        assert!(README.contains("validate_domain_artifact_test_profile_report"));
        assert!(README.contains("completed_shared_check_count"));
        assert!(README.contains("required_lifecycle_shared_check_count()"));
        assert!(README.contains("ArtifactMaintenancePolicy"));
        assert!(README.contains("artifact_compaction_info"));
        assert!(README.contains("ARTIFACT_COMPACTION_METADATA_KEY"));
        assert!(README.contains("plan_artifact_maintenance"));
        assert!(README.contains("compact_artifact_with_replayed_prefix(...)"));
        assert!(README.contains("maintain_artifact_with_plan(...)"));
        assert!(README.contains("maintain_artifact_with_plan_outcome(...)"));
        assert!(README.contains("REQUIRED_ARTIFACT_CONFORMANCE_CHECKS"));
        assert!(README.contains("REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS"));
        assert!(README.contains("REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS"));
        assert!(README.contains("no partial mutation"));
    }

    #[test]
    fn readme_documents_artifact_host_workflow() {
        assert!(README.contains("Artifact Host Workflow"));
        assert!(README.contains("editor_artifact_capabilities_json"));
        assert!(README.contains("editor_artifact_contract_json"));
        assert!(README.contains("editor_artifact_readiness_manifest_json"));
        assert!(README.contains("editor_artifact_test_profile_json"));
        assert!(README.contains("editor_artifact_lifecycle_profile_json"));
        assert!(README.contains("editor_artifact_readiness_manifest_result_json"));
        assert!(README.contains("editor_operation_insert_json"));
        assert!(README.contains("editor_operation_log_append_json"));
        assert!(README.contains("editor_artifact_capture"));
        assert!(README.contains("editor_artifact_restore"));
        assert!(README.contains("editor_free_str"));
        assert!(README.contains("editor_destroy"));
        assert!(README.contains("uint64_t"));
        assert!(README.contains("integer_out_of_range"));
        assert!(README.contains("examples/artifact_host_workflow.c"));
        assert!(README.contains("examples/artifact_api_symbols_smoke.c"));
        assert!(README.contains("examples/artifact_header_cpp_smoke.cpp"));
        assert!(README.contains("sh examples/smoke_artifact_host_workflow.sh"));
    }

    #[test]
    fn readme_documents_artifact_result_envelope() {
        assert!(README.contains("Artifact Result Envelope"));
        assert!(README.contains("ok_value_error"));
        assert!(README.contains("result_envelope_schema"));
        assert!(README.contains("payload_family"));
        assert!(README.contains("payload_families"));
        assert!(README.contains("result_function_pairs"));
        assert!(README.contains("result_only_functions"));
        assert!(README.contains("legacy_result_gaps"));
        assert!(README.contains("error.code"));
        assert!(README.contains("error_codes"));
        assert!(README.contains("serialization_failed"));
        assert!(README.contains("operation_document_mismatch"));
    }

    #[test]
    fn readme_documents_artifact_api_maintenance_checklist() {
        assert!(README.contains("Artifact API Maintenance Checklist"));
        assert!(README.contains("OPERATION_ENVELOPE_VERSION"));
        assert!(README.contains("ARTIFACT_CONTRACT_VERSION"));
        assert!(README.contains("ARTIFACT_API_VERSION"));
        assert!(README.contains("src/ffi/artifact_api/surface.rs"));
        assert!(README.contains("src/ffi/artifact_api/contract.rs"));
        assert!(README.contains("src/ffi/artifact_api/fixtures/"));
        assert!(README.contains("waraq_editor_core.h"));
        assert!(README.contains("examples/artifact_host_workflow.c"));
        assert!(README.contains("examples/artifact_api_symbols_smoke.c"));
        assert!(README.contains("examples/artifact_header_cpp_smoke.cpp"));
        assert!(README.contains("examples/smoke_artifact_host_workflow.sh"));
        assert!(README.contains("validate_artifact_conformance(...)"));
        assert!(README.contains("validate_artifact_replay_harness(...)"));
        assert!(README.contains("validate_artifact_compaction_harness(...)"));
        assert!(README.contains("validate_artifact_lifecycle_harness(...)"));
        assert!(README.contains("validate_artifact_lifecycle_profile(...)"));
        assert!(README.contains("validate_artifact_lifecycle_profile_report(...)"));
        assert!(README.contains("validate_domain_artifact_test_profile(...)"));
        assert!(README.contains("validate_domain_artifact_test_profile_report"));
        assert!(README.contains("domain_artifact_test_profile(...)"));
        assert!(README.contains("completed_shared_check_count"));
        assert!(README.contains("required_lifecycle_shared_check_count()"));
        assert!(README.contains("plan_artifact_maintenance"));
        assert!(README.contains("artifact_compaction_info(...)"));
        assert!(README.contains("ARTIFACT_COMPACTION_METADATA_KEY"));
        assert!(README.contains("compact_artifact_with_replayed_prefix(...)"));
        assert!(README.contains("maintain_artifact_with_plan(...)"));
        assert!(README.contains("maintain_artifact_with_plan_outcome(...)"));
        assert!(README.contains("REQUIRED_ARTIFACT_CONFORMANCE_CHECKS"));
        assert!(README.contains("REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS"));
        assert!(README.contains("REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS"));
        assert!(README.contains("DOMAIN_ENGINE_IMPLEMENTATION_STEPS"));
        assert!(README.contains("Building a Waraq-Family Engine"));
        assert!(README.contains("src/core/fixtures/artifact_conformance_report.json"));
        assert!(README.contains("cargo test --workspace --offline"));
    }
}
