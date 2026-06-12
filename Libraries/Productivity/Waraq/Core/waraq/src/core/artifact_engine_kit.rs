//! Engine-author helpers for Waraq-family artifact implementations.
//!
//! This module bundles the shared artifact contract, test profile, and lifecycle
//! profile validation into a small reusable kit. Domain engines still own their
//! snapshot, edit model, restore/replay behavior, and compaction callbacks.

use std::fmt::Debug;

use serde::{de::DeserializeOwned, Deserialize, Serialize};

use crate::core::artifact_contract::{artifact_contract_description, ArtifactContractDescription};
use crate::core::artifact_lifecycle_harness::{
    validate_artifact_lifecycle_harness, ArtifactLifecycleHarnessError,
    ArtifactLifecycleHarnessReport,
};
use crate::core::artifact_maintenance::ArtifactMaintenancePolicy;
use crate::core::artifact_test_profile::{
    domain_artifact_test_profile_with_compaction, validate_artifact_lifecycle_profile_report,
    validate_domain_artifact_test_profile_report, ArtifactLifecycleProfileError,
    ArtifactLifecycleProfileValidationReport, DomainArtifactTestHelper, DomainArtifactTestProfile,
    DomainArtifactTestProfileError, DomainArtifactTestProfileValidationReport,
};
use crate::core::engine_boundary::resolve_waraq_engine_id;
use crate::core::operation::{OperationArtifact, OperationLog};

/// Current schema version for serialized engine-readiness manifests.
pub const ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION: u32 = 1;

/// Shared artifact readiness bundle for one Waraq-family domain engine.
#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ArtifactEngineKit {
    /// Stable engine identifier owned by the domain engine.
    pub engine_id: String,
    /// Shared artifact contract description scoped to this engine id.
    pub contract: ArtifactContractDescription,
    /// Shared test profile the engine is expected to satisfy.
    pub profile: DomainArtifactTestProfile,
    /// Validated profile summary for readiness tooling.
    pub profile_report: DomainArtifactTestProfileValidationReport,
}

/// Error returned when building an engine kit through Waraq's family registry.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactEngineKitBuildError {
    /// The requested id is not a canonical Waraq-family id or accepted legacy alias.
    UnknownWaraqFamilyEngineId {
        /// Engine id supplied by the caller.
        engine_id: String,
    },
    /// The canonicalized engine id produced an invalid shared test profile.
    Profile(DomainArtifactTestProfileError),
}

impl ArtifactEngineKit {
    /// Build a kit for an engine that supports shared artifact compaction.
    pub fn for_engine(
        engine_id: impl Into<String>,
    ) -> Result<Self, DomainArtifactTestProfileError> {
        Self::for_engine_with_compaction(engine_id, true)
    }

    /// Build a kit for a registered Waraq-family engine.
    ///
    /// Canonical ids such as `code.engine` are used directly. Legacy aliases
    /// such as `code` are accepted for migration and canonicalized before the
    /// shared contract, profile, and readiness manifest are built.
    pub fn for_waraq_family_engine(
        engine_id: impl AsRef<str>,
    ) -> Result<Self, ArtifactEngineKitBuildError> {
        Self::for_waraq_family_engine_with_compaction(engine_id, true)
    }

    /// Build a registry-bound kit for a Waraq-family engine with explicit compaction support.
    pub fn for_waraq_family_engine_with_compaction(
        engine_id: impl AsRef<str>,
        supports_compaction: bool,
    ) -> Result<Self, ArtifactEngineKitBuildError> {
        let requested_engine_id = engine_id.as_ref();
        let resolution = resolve_waraq_engine_id(requested_engine_id).ok_or_else(|| {
            ArtifactEngineKitBuildError::UnknownWaraqFamilyEngineId {
                engine_id: requested_engine_id.to_owned(),
            }
        })?;

        Self::for_engine_with_compaction(resolution.canonical_engine_id, supports_compaction)
            .map_err(ArtifactEngineKitBuildError::Profile)
    }

    /// Build a kit for an engine with explicit compaction support.
    pub fn for_engine_with_compaction(
        engine_id: impl Into<String>,
        supports_compaction: bool,
    ) -> Result<Self, DomainArtifactTestProfileError> {
        let engine_id = engine_id.into();
        let contract = artifact_contract_description(&engine_id);
        let profile = domain_artifact_test_profile_with_compaction(&engine_id, supports_compaction);
        let profile_report = validate_domain_artifact_test_profile_report(&profile)?;

        Ok(Self {
            engine_id,
            contract,
            profile,
            profile_report,
        })
    }

    /// Stable engine identifier owned by the domain engine.
    pub fn engine_id(&self) -> &str {
        &self.engine_id
    }

    /// Number of shared checks this engine must cover.
    pub fn required_shared_check_count(&self) -> usize {
        self.profile_report.required_shared_check_count
    }

    /// Whether this engine profile requires a composed lifecycle harness proof.
    pub fn lifecycle_harness_required(&self) -> bool {
        self.profile_report.lifecycle_harness_required
    }

    /// Build a compact serializable readiness manifest for host tooling.
    pub fn readiness_manifest(&self) -> ArtifactEngineReadinessManifest {
        ArtifactEngineReadinessManifest::from_kit(self)
    }

    /// Validate an existing lifecycle harness report against this engine kit.
    pub fn validate_lifecycle_profile(
        &self,
        report: &ArtifactLifecycleHarnessReport,
    ) -> Result<ArtifactLifecycleProfileValidationReport, ArtifactLifecycleProfileError> {
        validate_artifact_lifecycle_profile_report(&self.profile, report)
    }

    /// Run the composed lifecycle harness and validate the report against the kit profile.
    pub fn validate_lifecycle_harness<
        Snapshot,
        Edit,
        State,
        DomainError,
        Restore,
        Replay,
        Compact,
        Maintain,
    >(
        &self,
        artifact: &OperationArtifact<Snapshot, Edit>,
        expected_restored_state: &State,
        invalid_replay_state: &State,
        invalid_replay_log: &OperationLog<Edit>,
        retain_tail_operations: usize,
        compacted_at_ms: u64,
        restore_artifact: Restore,
        replay_log: Replay,
        compact_artifact: Compact,
        maintain_artifact: Maintain,
    ) -> Result<ArtifactEngineKitLifecycleReport, ArtifactEngineKitLifecycleError>
    where
        Snapshot: Clone + Serialize + DeserializeOwned,
        Edit: Clone + Serialize + DeserializeOwned,
        State: Clone + Debug + PartialEq,
        DomainError: Debug,
        Restore: Fn(&OperationArtifact<Snapshot, Edit>) -> Result<State, DomainError>,
        Replay: Fn(&mut State, &OperationLog<Edit>) -> Result<(), DomainError>,
        Compact: Fn(
            &OperationArtifact<Snapshot, Edit>,
            usize,
            u64,
        ) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>,
        Maintain: Fn(
            &OperationArtifact<Snapshot, Edit>,
            ArtifactMaintenancePolicy,
            u64,
        ) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>,
    {
        let lifecycle = validate_artifact_lifecycle_harness(
            self.engine_id(),
            artifact,
            expected_restored_state,
            invalid_replay_state,
            invalid_replay_log,
            retain_tail_operations,
            compacted_at_ms,
            restore_artifact,
            replay_log,
            compact_artifact,
            maintain_artifact,
        )
        .map_err(ArtifactEngineKitLifecycleError::Harness)?;
        let profile = self
            .validate_lifecycle_profile(&lifecycle)
            .map_err(ArtifactEngineKitLifecycleError::Profile)?;

        Ok(ArtifactEngineKitLifecycleReport {
            engine_id: self.engine_id.clone(),
            document_id: lifecycle.document_id.clone(),
            lifecycle,
            profile,
        })
    }
}

/// Serializable primitive names used by one engine's shared artifact contract.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactEngineReadinessPrimitives {
    /// Operation envelope type used for domain edits.
    pub operation: String,
    /// Ordered operation-log type used for replay and compaction tails.
    pub operation_log: String,
    /// Snapshot-plus-log artifact type used for persistence and transfer.
    pub artifact: String,
}

/// Compact manifest describing one engine's shared Waraq artifact readiness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactEngineReadinessManifest {
    /// Manifest schema version for host tooling and snapshots.
    pub manifest_version: u32,
    /// Shared artifact contract version validated for this engine.
    pub contract_version: u32,
    /// Stable engine identifier owned by the domain engine.
    pub engine_id: String,
    /// Shared artifact primitive names this engine uses.
    pub primitives: ArtifactEngineReadinessPrimitives,
    /// Guarantees supplied by Waraq's shared artifact layer.
    pub shared_guarantees: Vec<String>,
    /// Responsibilities that remain inside the specialized domain engine.
    pub domain_responsibilities: Vec<String>,
    /// Required helper families the engine should implement.
    pub required_helpers: Vec<DomainArtifactTestHelper>,
    /// Number of helper families advertised by the validated profile.
    pub helper_count: usize,
    /// Number of conformance checks required by the validated profile.
    pub conformance_check_count: usize,
    /// Number of replay harness checks required by the validated profile.
    pub replay_harness_check_count: usize,
    /// Number of compaction harness checks required by the validated profile.
    pub compaction_harness_check_count: usize,
    /// Total number of shared checks required by the validated profile.
    pub required_shared_check_count: usize,
    /// True when domain-owned replay tests are part of readiness.
    pub domain_replay_tests_required: bool,
    /// True when the engine must provide compaction harness coverage.
    pub compaction_harness_required: bool,
    /// True when the engine must provide a composed lifecycle proof.
    pub lifecycle_harness_required: bool,
    /// Shared check count expected from a lifecycle harness proof.
    pub lifecycle_harness_shared_check_count: Option<usize>,
}

impl ArtifactEngineReadinessManifest {
    /// Build a host-readable readiness manifest from a validated engine kit.
    pub fn from_kit(kit: &ArtifactEngineKit) -> Self {
        Self {
            manifest_version: ARTIFACT_ENGINE_READINESS_MANIFEST_VERSION,
            contract_version: kit.contract.contract_version,
            engine_id: kit.engine_id.clone(),
            primitives: ArtifactEngineReadinessPrimitives {
                operation: kit.contract.primitives.operation.to_owned(),
                operation_log: kit.contract.primitives.operation_log.to_owned(),
                artifact: kit.contract.primitives.artifact.to_owned(),
            },
            shared_guarantees: kit
                .contract
                .shared_guarantees
                .iter()
                .map(|guarantee| (*guarantee).to_owned())
                .collect(),
            domain_responsibilities: kit
                .contract
                .domain_responsibilities
                .iter()
                .map(|responsibility| (*responsibility).to_owned())
                .collect(),
            required_helpers: kit.profile.helpers.clone(),
            helper_count: kit.profile_report.helper_count,
            conformance_check_count: kit.profile_report.conformance_check_count,
            replay_harness_check_count: kit.profile_report.replay_harness_check_count,
            compaction_harness_check_count: kit.profile_report.compaction_harness_check_count,
            required_shared_check_count: kit.profile_report.required_shared_check_count,
            domain_replay_tests_required: kit.profile_report.domain_replay_tests_required,
            compaction_harness_required: kit.profile_report.compaction_harness_required,
            lifecycle_harness_required: kit.profile_report.lifecycle_harness_required,
            lifecycle_harness_shared_check_count: kit
                .profile_report
                .lifecycle_harness_shared_check_count,
        }
    }
}

/// Report returned when an engine satisfies both lifecycle and profile checks.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactEngineKitLifecycleReport {
    /// Stable engine identifier validated by the kit.
    pub engine_id: String,
    /// Document identifier validated across the lifecycle report.
    pub document_id: String,
    /// Composed lifecycle harness report.
    pub lifecycle: ArtifactLifecycleHarnessReport,
    /// Lifecycle report validated against the engine test profile.
    pub profile: ArtifactLifecycleProfileValidationReport,
}

/// Error returned when engine-kit lifecycle readiness validation fails.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactEngineKitLifecycleError {
    /// The composed lifecycle harness failed before profile validation.
    Harness(ArtifactLifecycleHarnessError),
    /// The lifecycle report did not match the engine test profile.
    Profile(ArtifactLifecycleProfileError),
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::artifact_compaction_harness::REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS;
    use crate::core::artifact_conformance::REQUIRED_ARTIFACT_CONFORMANCE_CHECKS;
    use crate::core::artifact_contract::ARTIFACT_CONTRACT_VERSION;
    use crate::core::artifact_maintenance::{
        compact_artifact_with_replayed_prefix, maintain_artifact_with_plan,
        plan_artifact_maintenance,
    };
    use crate::core::artifact_replay_harness::REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS;
    use crate::core::engine_boundary::{
        WARAQ_CODE_ENGINE_ID, WARAQ_CODE_LEGACY_ENGINE_ID, WARAQ_MAQAL_ENGINE_ID,
    };
    use crate::core::operation::{OperationEnvelope, OperationLogError};

    const TEST_ENGINE_ID: &str = "waraq.engine-kit.test";
    const TEST_DOCUMENT_ID: &str = "doc-1";

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    struct TestSnapshot {
        text: String,
    }

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    enum TestEdit {
        Append(String),
        Reject,
    }

    #[derive(Debug, Clone, PartialEq, Eq)]
    enum TestError {
        OperationLog(OperationLogError),
        Rejected,
    }

    impl From<OperationLogError> for TestError {
        fn from(error: OperationLogError) -> Self {
            Self::OperationLog(error)
        }
    }

    fn operation(id: &str, sequence: u64, edit: TestEdit) -> OperationEnvelope<TestEdit> {
        OperationEnvelope::new(
            TEST_ENGINE_ID,
            id,
            TEST_DOCUMENT_ID,
            "actor-1",
            sequence,
            sequence * 100,
            edit,
        )
    }

    fn artifact() -> OperationArtifact<TestSnapshot, TestEdit> {
        OperationArtifact::new(
            TEST_ENGINE_ID,
            TEST_DOCUMENT_ID,
            TestSnapshot { text: "a".into() },
            OperationLog::from_operations(vec![
                operation("op-1", 1, TestEdit::Append("b".into())),
                operation("op-2", 2, TestEdit::Append("c".into())),
                operation("op-3", 3, TestEdit::Append("d".into())),
            ]),
        )
    }

    fn invalid_log() -> OperationLog<TestEdit> {
        OperationLog::from_operations(vec![operation("op-invalid", 1, TestEdit::Reject)])
    }

    fn restore(artifact: &OperationArtifact<TestSnapshot, TestEdit>) -> Result<String, TestError> {
        artifact.validate_for_engine(TEST_ENGINE_ID)?;
        let mut text = artifact.snapshot.text.clone();
        replay(&mut text, &artifact.operation_log)?;
        Ok(text)
    }

    fn replay(text: &mut String, log: &OperationLog<TestEdit>) -> Result<(), TestError> {
        log.validate_for_engine(TEST_ENGINE_ID)?;
        let mut staged = text.clone();
        for operation in &log.operations {
            match &operation.edit {
                TestEdit::Append(next) => staged.push_str(next),
                TestEdit::Reject => return Err(TestError::Rejected),
            }
        }
        *text = staged;
        Ok(())
    }

    fn compact(
        artifact: &OperationArtifact<TestSnapshot, TestEdit>,
        retain_tail_operations: usize,
        compacted_at_ms: u64,
    ) -> Result<OperationArtifact<TestSnapshot, TestEdit>, TestError> {
        compact_artifact_with_replayed_prefix(
            artifact,
            retain_tail_operations,
            compacted_at_ms,
            TEST_ENGINE_ID,
            |mut snapshot, prefix_log| {
                replay(&mut snapshot.text, &prefix_log)?;
                Ok::<_, TestError>(snapshot)
            },
        )
    }

    fn maintain(
        artifact: &OperationArtifact<TestSnapshot, TestEdit>,
        policy: ArtifactMaintenancePolicy,
        compacted_at_ms: u64,
    ) -> Result<OperationArtifact<TestSnapshot, TestEdit>, TestError> {
        let plan = plan_artifact_maintenance(artifact, policy, TEST_ENGINE_ID)?;
        maintain_artifact_with_plan(artifact, &plan, compacted_at_ms, compact)
    }

    #[test]
    fn artifact_engine_kit_builds_valid_profile() {
        let kit = ArtifactEngineKit::for_engine(TEST_ENGINE_ID).unwrap();

        assert_eq!(kit.engine_id(), TEST_ENGINE_ID);
        assert_eq!(kit.contract.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(kit.contract.engine_id, TEST_ENGINE_ID);
        assert_eq!(kit.profile.engine_id, TEST_ENGINE_ID);
        assert_eq!(kit.profile_report.engine_id, TEST_ENGINE_ID);
        assert_eq!(kit.required_shared_check_count(), 22);
        assert!(kit.lifecycle_harness_required());

        let manifest = kit.readiness_manifest();
        assert_eq!(manifest.manifest_version, 1);
        assert_eq!(manifest.engine_id, TEST_ENGINE_ID);
        assert_eq!(manifest.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(manifest.primitives.operation, "OperationEnvelope<Edit>");
        assert_eq!(manifest.helper_count, 5);
        assert_eq!(manifest.required_helpers, kit.profile.helpers);
        assert_eq!(manifest.required_shared_check_count, 22);
        assert_eq!(manifest.lifecycle_harness_shared_check_count, Some(22));
        assert!(manifest
            .shared_guarantees
            .iter()
            .any(|guarantee| guarantee.contains("operation envelopes")));
        assert!(manifest
            .domain_responsibilities
            .iter()
            .any(|responsibility| responsibility.contains("snapshot model")));
    }

    #[test]
    fn artifact_engine_kit_builds_registered_waraq_family_profile() {
        let kit = ArtifactEngineKit::for_waraq_family_engine(WARAQ_CODE_ENGINE_ID).unwrap();

        assert_eq!(kit.engine_id(), WARAQ_CODE_ENGINE_ID);
        assert_eq!(kit.contract.engine_id, WARAQ_CODE_ENGINE_ID);
        assert_eq!(kit.profile.engine_id, WARAQ_CODE_ENGINE_ID);
        assert_eq!(kit.readiness_manifest().engine_id, WARAQ_CODE_ENGINE_ID);
    }

    #[test]
    fn artifact_engine_kit_canonicalizes_legacy_waraq_family_ids() {
        let kit = ArtifactEngineKit::for_waraq_family_engine(WARAQ_CODE_LEGACY_ENGINE_ID).unwrap();

        assert_eq!(kit.engine_id(), WARAQ_CODE_ENGINE_ID);
        assert_eq!(kit.contract.engine_id, WARAQ_CODE_ENGINE_ID);
        assert_eq!(kit.profile_report.engine_id, WARAQ_CODE_ENGINE_ID);

        let maqal =
            ArtifactEngineKit::for_waraq_family_engine_with_compaction("maqal", false).unwrap();
        assert_eq!(maqal.engine_id(), WARAQ_MAQAL_ENGINE_ID);
        assert!(!maqal.profile_report.compaction_harness_required);
        assert!(!maqal.lifecycle_harness_required());
    }

    #[test]
    fn artifact_engine_kit_rejects_unknown_waraq_family_ids() {
        let err = ArtifactEngineKit::for_waraq_family_engine(TEST_ENGINE_ID).unwrap_err();

        assert_eq!(
            err,
            ArtifactEngineKitBuildError::UnknownWaraqFamilyEngineId {
                engine_id: TEST_ENGINE_ID.to_owned()
            }
        );
    }

    #[test]
    fn artifact_engine_kit_can_model_compaction_free_experimental_engines() {
        let kit =
            ArtifactEngineKit::for_engine_with_compaction("waraq.experimental", false).unwrap();

        assert!(!kit.profile_report.compaction_harness_required);
        assert!(!kit.lifecycle_harness_required());
        assert_eq!(kit.profile_report.compaction_harness_check_count, 0);
        assert_eq!(
            kit.required_shared_check_count(),
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
                + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
        );

        let manifest = ArtifactEngineReadinessManifest::from_kit(&kit);
        assert_eq!(manifest.helper_count, 3);
        assert_eq!(manifest.compaction_harness_check_count, 0);
        assert!(!manifest.compaction_harness_required);
        assert!(!manifest.lifecycle_harness_required);
        assert_eq!(manifest.lifecycle_harness_shared_check_count, None);
    }

    #[test]
    fn artifact_engine_readiness_manifest_serializes_for_tooling() {
        let kit = ArtifactEngineKit::for_engine(TEST_ENGINE_ID).unwrap();
        let manifest = kit.readiness_manifest();
        let value = serde_json::to_value(&manifest).unwrap();

        assert_eq!(value["manifest_version"], 1);
        assert_eq!(value["engine_id"], TEST_ENGINE_ID);
        assert_eq!(
            value["primitives"]["artifact"],
            "OperationArtifact<Snapshot, Edit>"
        );
        assert_eq!(value["required_helpers"][0], "Conformance");
        assert_eq!(value["required_helpers"][3], "LifecycleHarness");
        assert_eq!(value["helper_count"], 5);
        assert_eq!(value["required_shared_check_count"], 22);
        assert_eq!(value["lifecycle_harness_required"], true);

        let roundtrip: ArtifactEngineReadinessManifest = serde_json::from_value(value).unwrap();
        assert_eq!(roundtrip, manifest);
    }

    #[test]
    fn artifact_engine_kit_validates_composed_lifecycle_readiness() {
        let kit = ArtifactEngineKit::for_engine(TEST_ENGINE_ID).unwrap();
        let report = kit
            .validate_lifecycle_harness(
                &artifact(),
                &"abcd".to_owned(),
                &"a".to_owned(),
                &invalid_log(),
                1,
                1234,
                restore,
                replay,
                compact,
                maintain,
            )
            .unwrap();

        assert_eq!(report.engine_id, TEST_ENGINE_ID);
        assert_eq!(report.document_id, TEST_DOCUMENT_ID);
        assert_eq!(report.lifecycle.completed_shared_check_count, 22);
        assert_eq!(report.profile.expected_shared_check_count, 22);
        assert_eq!(report.profile.completed_shared_check_count, 22);
        assert_eq!(
            report.profile.completed_conformance_check_count,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
        );
        assert_eq!(
            report.profile.completed_replay_harness_check_count,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
        );
        assert_eq!(
            report.profile.completed_compaction_harness_check_count,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len()
        );
    }

    #[test]
    fn artifact_engine_kit_rejects_lifecycle_report_for_wrong_engine() {
        let kit = ArtifactEngineKit::for_engine(TEST_ENGINE_ID).unwrap();
        let mut report = kit
            .validate_lifecycle_harness(
                &artifact(),
                &"abcd".to_owned(),
                &"a".to_owned(),
                &invalid_log(),
                1,
                1234,
                restore,
                replay,
                compact,
                maintain,
            )
            .unwrap()
            .lifecycle;

        report.engine_id = "wrong.engine".to_owned();
        let err = kit.validate_lifecycle_profile(&report).unwrap_err();
        assert!(matches!(
            err,
            ArtifactLifecycleProfileError::EngineMismatch { .. }
        ));
    }
}
