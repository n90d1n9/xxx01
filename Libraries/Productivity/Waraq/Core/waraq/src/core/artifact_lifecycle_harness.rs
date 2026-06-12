//! Lifecycle harness helpers for Waraq-family domain engines.
//!
//! The conformance, replay, and compaction harnesses remain the source of
//! truth for individual artifact guarantees. This module composes them into one
//! convenience helper for engines that want a single representative lifecycle
//! proof in their test suite.

use std::fmt::Debug;

use serde::{de::DeserializeOwned, Deserialize, Serialize};

use crate::core::artifact_compaction_harness::{
    validate_artifact_compaction_harness, ArtifactCompactionHarnessError,
    ArtifactCompactionHarnessReport,
};
use crate::core::artifact_conformance::{
    validate_artifact_conformance, ArtifactConformanceError, ArtifactConformanceReport,
};
use crate::core::artifact_maintenance::ArtifactMaintenancePolicy;
use crate::core::artifact_replay_harness::{
    validate_artifact_replay_harness, ArtifactReplayHarnessError, ArtifactReplayHarnessReport,
};
use crate::core::operation::{OperationArtifact, OperationLog};

/// Summary returned when a domain engine satisfies the composed lifecycle harness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactLifecycleHarnessReport {
    /// Stable engine identifier used by the checked artifact.
    pub engine_id: String,
    /// Document identifier used by the checked artifact.
    pub document_id: String,
    /// Shared transport conformance report.
    pub conformance: ArtifactConformanceReport,
    /// Domain restore/replay behavior report.
    pub replay: ArtifactReplayHarnessReport,
    /// Domain compaction and maintenance behavior report.
    pub compaction: ArtifactCompactionHarnessReport,
    /// Total number of shared checks completed by the composed harnesses.
    pub completed_shared_check_count: usize,
}

/// Error returned when any lifecycle harness stage fails.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactLifecycleHarnessError {
    /// The artifact failed the shared transport conformance harness.
    Conformance(ArtifactConformanceError),
    /// The artifact failed the domain replay harness.
    Replay(ArtifactReplayHarnessError),
    /// The artifact failed the domain compaction harness.
    Compaction(ArtifactCompactionHarnessError),
}

/// Validate the full shared artifact lifecycle for a Waraq-family engine.
///
/// This is a convenience wrapper around `validate_artifact_conformance`,
/// `validate_artifact_replay_harness`, and
/// `validate_artifact_compaction_harness`. Domain engines still own their
/// snapshot, edit model, restore/replay semantics, and compaction callbacks.
pub fn validate_artifact_lifecycle_harness<
    Snapshot,
    Edit,
    State,
    DomainError,
    Restore,
    Replay,
    Compact,
    Maintain,
>(
    expected_engine: &str,
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
) -> Result<ArtifactLifecycleHarnessReport, ArtifactLifecycleHarnessError>
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
    let conformance = validate_artifact_conformance(expected_engine, artifact)
        .map_err(ArtifactLifecycleHarnessError::Conformance)?;
    let replay = validate_artifact_replay_harness(
        expected_engine,
        artifact,
        expected_restored_state,
        invalid_replay_state,
        invalid_replay_log,
        &restore_artifact,
        replay_log,
    )
    .map_err(ArtifactLifecycleHarnessError::Replay)?;
    let compaction = validate_artifact_compaction_harness(
        expected_engine,
        artifact,
        retain_tail_operations,
        compacted_at_ms,
        restore_artifact,
        compact_artifact,
        maintain_artifact,
    )
    .map_err(ArtifactLifecycleHarnessError::Compaction)?;

    let completed_shared_check_count = conformance.completed_checks.len()
        + replay.completed_checks.len()
        + compaction.completed_checks.len();

    Ok(ArtifactLifecycleHarnessReport {
        engine_id: expected_engine.to_owned(),
        document_id: artifact.document_id.clone(),
        conformance,
        replay,
        compaction,
        completed_shared_check_count,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::artifact_compaction_harness::REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS;
    use crate::core::artifact_conformance::REQUIRED_ARTIFACT_CONFORMANCE_CHECKS;
    use crate::core::artifact_maintenance::{
        compact_artifact_with_replayed_prefix, maintain_artifact_with_plan,
        plan_artifact_maintenance,
    };
    use crate::core::artifact_replay_harness::REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS;
    use crate::core::operation::{OperationEnvelope, OperationLogError};

    const TEST_ENGINE_ID: &str = "waraq.lifecycle.test";

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
            "doc-1",
            "actor-1",
            sequence,
            sequence * 100,
            edit,
        )
    }

    fn artifact() -> OperationArtifact<TestSnapshot, TestEdit> {
        OperationArtifact::new(
            TEST_ENGINE_ID,
            "doc-1",
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
    fn lifecycle_harness_accepts_valid_domain_behavior() {
        let report = validate_artifact_lifecycle_harness(
            TEST_ENGINE_ID,
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
        assert_eq!(report.document_id, "doc-1");
        assert_eq!(
            report.conformance.completed_checks,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
        assert_eq!(
            report.replay.completed_checks,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
        assert_eq!(
            report.compaction.completed_checks,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
        assert_eq!(report.completed_shared_check_count, 22);
    }

    #[test]
    fn lifecycle_harness_reports_the_failed_stage() {
        let mut bad_artifact = artifact();
        bad_artifact.engine = "wrong".into();

        let err = validate_artifact_lifecycle_harness(
            TEST_ENGINE_ID,
            &bad_artifact,
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
        .unwrap_err();

        assert!(matches!(err, ArtifactLifecycleHarnessError::Conformance(_)));
    }
}
