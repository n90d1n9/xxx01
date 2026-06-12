//! Compaction harness helpers for Waraq-family domain engines.
//!
//! The maintenance helpers split operation tails consistently. This harness
//! verifies that a domain engine's compaction callback folds that split into
//! its snapshot without changing restored state or losing shared metadata.

use std::fmt::Debug;

use serde::{Deserialize, Serialize};

use crate::core::artifact_maintenance::{
    artifact_compaction_info_from_metadata, ArtifactCompactionInfo, ArtifactMaintenancePolicy,
    ARTIFACT_COMPACTION_METADATA_KEY,
};
use crate::core::operation::{OperationArtifact, OperationLogError, OperationMetadata};

/// Compaction behavior checked by the shared artifact compaction harness.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactCompactionHarnessCheck {
    /// The compacted artifact restores to the same domain state as the source.
    CompactedRestoreEquivalent,
    /// The compacted artifact retained the requested operation tail length.
    RetainedTailLength,
    /// The compacted artifact recorded canonical compaction metadata.
    CompactionMetadata,
    /// The compacted artifact preserved operation-log metadata.
    OperationLogMetadataPreserved,
    /// Maintenance compacted when the policy required it and preserved state.
    MaintainCompactPreservesState,
    /// Maintenance skipped compaction when the policy did not require it.
    MaintainSkipPreservesState,
    /// The compaction callback rejected a deliberately wrong artifact engine id.
    WrongEngineRejection,
    /// The compaction callback rejected an operation targeting another document.
    WrongDocumentRejection,
}

/// Canonical set and order of checks completed by a successful compaction harness.
pub const REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS: &[ArtifactCompactionHarnessCheck] = &[
    ArtifactCompactionHarnessCheck::CompactedRestoreEquivalent,
    ArtifactCompactionHarnessCheck::RetainedTailLength,
    ArtifactCompactionHarnessCheck::CompactionMetadata,
    ArtifactCompactionHarnessCheck::OperationLogMetadataPreserved,
    ArtifactCompactionHarnessCheck::MaintainCompactPreservesState,
    ArtifactCompactionHarnessCheck::MaintainSkipPreservesState,
    ArtifactCompactionHarnessCheck::WrongEngineRejection,
    ArtifactCompactionHarnessCheck::WrongDocumentRejection,
];

/// Summary returned when a domain engine satisfies the compaction harness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactCompactionHarnessReport {
    /// Stable engine identifier used by the checked artifact.
    pub engine_id: String,
    /// Document identifier used by the checked artifact.
    pub document_id: String,
    /// Number of operations in the source artifact tail.
    pub source_operation_count: usize,
    /// Number of source operations folded into the compacted snapshot.
    pub compacted_operation_count: usize,
    /// Number of operations retained in the compacted artifact tail.
    pub retained_operation_count: usize,
    /// Exact compaction checks completed by the helper.
    pub completed_checks: Vec<ArtifactCompactionHarnessCheck>,
}

/// Error returned when a domain engine violates the compaction harness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactCompactionHarnessError {
    /// The representative artifact had no operation prefix to compact.
    InsufficientOperationTail {
        /// Number of operations carried by the artifact.
        operation_count: usize,
        /// Retained tail requested by the harness.
        retain_tail_operations: usize,
    },
    /// The source artifact failed shared transport validation.
    SourceArtifactValidation(OperationLogError),
    /// The valid source artifact failed to restore.
    SourceRestoreFailed {
        /// Human-readable restore error.
        message: String,
    },
    /// The compaction callback failed for a valid artifact.
    CompactionFailed {
        /// Human-readable compaction error.
        message: String,
    },
    /// The compacted artifact failed shared transport validation.
    CompactedArtifactValidation(OperationLogError),
    /// The compacted artifact failed to restore.
    CompactedRestoreFailed {
        /// Human-readable restore error.
        message: String,
    },
    /// Compaction changed the restored domain state.
    CompactedRestoreMismatch {
        /// Debug representation of the restored source state.
        expected: String,
        /// Debug representation of the restored compacted state.
        actual: String,
    },
    /// The compacted artifact retained the wrong number of operations.
    RetainedTailLengthMismatch {
        /// Expected retained tail length.
        expected: usize,
        /// Actual retained tail length.
        actual: usize,
    },
    /// The compacted artifact did not carry compaction metadata.
    MissingCompactionMetadata,
    /// The compaction metadata could not be decoded into the shared shape.
    InvalidCompactionMetadata {
        /// Human-readable decode error.
        message: String,
    },
    /// The compaction metadata did not match the source artifact and policy.
    CompactionMetadataMismatch {
        /// Debug representation of the expected metadata.
        expected: String,
        /// Debug representation of the actual metadata.
        actual: String,
    },
    /// Operation-log metadata changed during compaction.
    OperationLogMetadataMismatch {
        /// Debug representation of the expected metadata.
        expected: String,
        /// Debug representation of the actual metadata.
        actual: String,
    },
    /// The maintenance callback failed for a policy that should compact.
    MaintainCompactFailed {
        /// Human-readable maintenance error.
        message: String,
    },
    /// The maintained artifact failed shared transport validation after required compaction.
    MaintainCompactArtifactValidation(OperationLogError),
    /// Required maintenance compaction failed to restore.
    MaintainCompactRestoreFailed {
        /// Human-readable restore error.
        message: String,
    },
    /// Required maintenance compaction changed the restored domain state.
    MaintainCompactRestoreMismatch {
        /// Debug representation of the restored source state.
        expected: String,
        /// Debug representation of the maintained state.
        actual: String,
    },
    /// Required maintenance compaction retained the wrong number of operations.
    MaintainCompactRetainedTailLengthMismatch {
        /// Expected retained tail length.
        expected: usize,
        /// Actual retained tail length.
        actual: usize,
    },
    /// Required maintenance compaction recorded different metadata than direct compaction.
    MaintainCompactMetadataMismatch {
        /// Debug representation of the expected metadata.
        expected: String,
        /// Debug representation of the actual metadata.
        actual: String,
    },
    /// Required maintenance compaction changed operation-log metadata.
    MaintainCompactOperationLogMetadataMismatch {
        /// Debug representation of the expected metadata.
        expected: String,
        /// Debug representation of the actual metadata.
        actual: String,
    },
    /// The maintenance callback failed for a policy that should not compact.
    MaintainSkipFailed {
        /// Human-readable maintenance error.
        message: String,
    },
    /// Maintenance skip changed the restored domain state.
    MaintainSkipRestoreMismatch {
        /// Debug representation of the restored source state.
        expected: String,
        /// Debug representation of the maintained state.
        actual: String,
    },
    /// Maintenance skip added compaction metadata when no compaction was due.
    MaintainSkipAddedCompactionMetadata,
    /// The compaction callback accepted an artifact with a wrong engine id.
    WrongEngineAccepted {
        /// Deliberately wrong engine id that was accepted.
        engine_id: String,
    },
    /// The compaction callback accepted an operation targeting another document.
    WrongDocumentAccepted {
        /// Operation id whose document id was mutated.
        operation_id: String,
        /// Deliberately wrong document id that was accepted.
        document_id: String,
    },
}

/// Validate compaction behavior for a Waraq-family domain engine.
///
/// Domain engines provide callbacks for restore, compaction, and policy-based
/// maintenance. The helper checks that compaction preserves restored state,
/// retained-tail shape, compaction metadata, operation-log metadata, required
/// compaction behavior, skip behavior, and shared invalid-artifact rejection.
pub fn validate_artifact_compaction_harness<
    Snapshot,
    Edit,
    State,
    DomainError,
    Restore,
    Compact,
    Maintain,
>(
    expected_engine: &str,
    source_artifact: &OperationArtifact<Snapshot, Edit>,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
    restore_artifact: Restore,
    compact_artifact: Compact,
    maintain_artifact: Maintain,
) -> Result<ArtifactCompactionHarnessReport, ArtifactCompactionHarnessError>
where
    Snapshot: Clone,
    Edit: Clone,
    State: Debug + PartialEq,
    DomainError: Debug,
    Restore: Fn(&OperationArtifact<Snapshot, Edit>) -> Result<State, DomainError>,
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
    source_artifact
        .validate_for_engine(expected_engine)
        .map_err(ArtifactCompactionHarnessError::SourceArtifactValidation)?;

    let source_operation_count = source_artifact.operation_log.len();
    let retained_operation_count = retain_tail_operations.min(source_operation_count);
    let compacted_operation_count = source_operation_count.saturating_sub(retained_operation_count);
    if compacted_operation_count == 0 {
        return Err(ArtifactCompactionHarnessError::InsufficientOperationTail {
            operation_count: source_operation_count,
            retain_tail_operations,
        });
    }

    let mut completed_checks =
        Vec::with_capacity(REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len());
    let source_state = restore_artifact(source_artifact).map_err(|error| {
        ArtifactCompactionHarnessError::SourceRestoreFailed {
            message: format!("{error:?}"),
        }
    })?;

    let compacted = compact_artifact(source_artifact, retain_tail_operations, compacted_at_ms)
        .map_err(|error| ArtifactCompactionHarnessError::CompactionFailed {
            message: format!("{error:?}"),
        })?;
    compacted
        .validate_for_engine(expected_engine)
        .map_err(ArtifactCompactionHarnessError::CompactedArtifactValidation)?;

    let compacted_state = restore_artifact(&compacted).map_err(|error| {
        ArtifactCompactionHarnessError::CompactedRestoreFailed {
            message: format!("{error:?}"),
        }
    })?;
    if compacted_state != source_state {
        return Err(ArtifactCompactionHarnessError::CompactedRestoreMismatch {
            expected: format!("{source_state:?}"),
            actual: format!("{compacted_state:?}"),
        });
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::CompactedRestoreEquivalent);

    if compacted.operation_log.len() != retained_operation_count {
        return Err(ArtifactCompactionHarnessError::RetainedTailLengthMismatch {
            expected: retained_operation_count,
            actual: compacted.operation_log.len(),
        });
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::RetainedTailLength);

    let expected_info = expected_compaction_info(
        source_artifact,
        compacted_operation_count,
        retained_operation_count,
        compacted_at_ms,
    );
    let actual_info = compaction_info(&compacted.metadata)?;
    if actual_info != expected_info {
        return Err(ArtifactCompactionHarnessError::CompactionMetadataMismatch {
            expected: format!("{expected_info:?}"),
            actual: format!("{actual_info:?}"),
        });
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::CompactionMetadata);

    if compacted.operation_log.metadata != source_artifact.operation_log.metadata {
        return Err(
            ArtifactCompactionHarnessError::OperationLogMetadataMismatch {
                expected: format!("{:?}", source_artifact.operation_log.metadata),
                actual: format!("{:?}", compacted.operation_log.metadata),
            },
        );
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::OperationLogMetadataPreserved);

    let compact_policy = ArtifactMaintenancePolicy::new(
        source_operation_count.saturating_sub(1),
        retain_tail_operations,
    );
    let maintained_compacted = maintain_artifact(source_artifact, compact_policy, compacted_at_ms)
        .map_err(
            |error| ArtifactCompactionHarnessError::MaintainCompactFailed {
                message: format!("{error:?}"),
            },
        )?;
    maintained_compacted
        .validate_for_engine(expected_engine)
        .map_err(ArtifactCompactionHarnessError::MaintainCompactArtifactValidation)?;

    let maintained_compacted_state = restore_artifact(&maintained_compacted).map_err(|error| {
        ArtifactCompactionHarnessError::MaintainCompactRestoreFailed {
            message: format!("{error:?}"),
        }
    })?;
    if maintained_compacted_state != source_state {
        return Err(
            ArtifactCompactionHarnessError::MaintainCompactRestoreMismatch {
                expected: format!("{source_state:?}"),
                actual: format!("{maintained_compacted_state:?}"),
            },
        );
    }
    if maintained_compacted.operation_log.len() != retained_operation_count {
        return Err(
            ArtifactCompactionHarnessError::MaintainCompactRetainedTailLengthMismatch {
                expected: retained_operation_count,
                actual: maintained_compacted.operation_log.len(),
            },
        );
    }
    let maintained_info = compaction_info(&maintained_compacted.metadata)?;
    if maintained_info != expected_info {
        return Err(
            ArtifactCompactionHarnessError::MaintainCompactMetadataMismatch {
                expected: format!("{expected_info:?}"),
                actual: format!("{maintained_info:?}"),
            },
        );
    }
    if maintained_compacted.operation_log.metadata != source_artifact.operation_log.metadata {
        return Err(
            ArtifactCompactionHarnessError::MaintainCompactOperationLogMetadataMismatch {
                expected: format!("{:?}", source_artifact.operation_log.metadata),
                actual: format!("{:?}", maintained_compacted.operation_log.metadata),
            },
        );
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::MaintainCompactPreservesState);

    let skip_policy = ArtifactMaintenancePolicy::new(
        source_operation_count.saturating_add(1),
        retain_tail_operations,
    );
    let maintained =
        maintain_artifact(source_artifact, skip_policy, compacted_at_ms).map_err(|error| {
            ArtifactCompactionHarnessError::MaintainSkipFailed {
                message: format!("{error:?}"),
            }
        })?;
    let maintained_state = restore_artifact(&maintained).map_err(|error| {
        ArtifactCompactionHarnessError::CompactedRestoreFailed {
            message: format!("{error:?}"),
        }
    })?;
    if maintained_state != source_state {
        return Err(
            ArtifactCompactionHarnessError::MaintainSkipRestoreMismatch {
                expected: format!("{source_state:?}"),
                actual: format!("{maintained_state:?}"),
            },
        );
    }
    if !source_artifact
        .metadata
        .contains_key(ARTIFACT_COMPACTION_METADATA_KEY)
        && maintained
            .metadata
            .contains_key(ARTIFACT_COMPACTION_METADATA_KEY)
    {
        return Err(ArtifactCompactionHarnessError::MaintainSkipAddedCompactionMetadata);
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::MaintainSkipPreservesState);

    let wrong_engine = alternate_value(expected_engine, "wrong-engine");
    let mut wrong_engine_artifact = source_artifact.clone();
    wrong_engine_artifact.engine = wrong_engine.clone();
    if compact_artifact(
        &wrong_engine_artifact,
        retain_tail_operations,
        compacted_at_ms,
    )
    .is_ok()
    {
        return Err(ArtifactCompactionHarnessError::WrongEngineAccepted {
            engine_id: wrong_engine,
        });
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::WrongEngineRejection);

    let wrong_document = alternate_value(&source_artifact.document_id, "wrong-document");
    let mut wrong_document_artifact = source_artifact.clone();
    let operation = &mut wrong_document_artifact.operation_log.operations[0];
    let operation_id = operation.operation_id.clone();
    operation.document_id = wrong_document.clone();
    if compact_artifact(
        &wrong_document_artifact,
        retain_tail_operations,
        compacted_at_ms,
    )
    .is_ok()
    {
        return Err(ArtifactCompactionHarnessError::WrongDocumentAccepted {
            operation_id,
            document_id: wrong_document,
        });
    }
    completed_checks.push(ArtifactCompactionHarnessCheck::WrongDocumentRejection);

    Ok(ArtifactCompactionHarnessReport {
        engine_id: expected_engine.to_owned(),
        document_id: source_artifact.document_id.clone(),
        source_operation_count,
        compacted_operation_count,
        retained_operation_count,
        completed_checks,
    })
}

fn expected_compaction_info<Snapshot, Edit>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    compacted_operation_count: usize,
    retained_operation_count: usize,
    compacted_at_ms: u64,
) -> ArtifactCompactionInfo {
    let compacted_through_operation = compacted_operation_count
        .checked_sub(1)
        .and_then(|index| artifact.operation_log.operations.get(index));

    ArtifactCompactionInfo {
        source_operation_count: artifact.operation_log.len(),
        compacted_operation_count,
        retained_operation_count,
        compacted_through_sequence: compacted_through_operation.map(|operation| operation.sequence),
        compacted_through_operation_id: compacted_through_operation
            .map(|operation| operation.operation_id.clone()),
        compacted_at_ms,
    }
}

fn compaction_info(
    metadata: &OperationMetadata,
) -> Result<ArtifactCompactionInfo, ArtifactCompactionHarnessError> {
    artifact_compaction_info_from_metadata(metadata)
        .map_err(
            |error| ArtifactCompactionHarnessError::InvalidCompactionMetadata {
                message: error.to_string(),
            },
        )?
        .ok_or(ArtifactCompactionHarnessError::MissingCompactionMetadata)
}

fn alternate_value(current: &str, suffix: &str) -> String {
    let candidate = format!("{current}.{suffix}");
    if candidate == current {
        format!("{current}.{suffix}.alt")
    } else {
        candidate
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::artifact_maintenance::{
        maintain_artifact_with_plan, plan_artifact_maintenance, record_artifact_compaction_info,
        split_artifact_operation_tail,
    };
    use crate::core::operation::{OperationArtifact, OperationEnvelope, OperationLog};

    const TEST_ENGINE_ID: &str = "waraq.compaction.test";

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    struct TestSnapshot {
        text: String,
    }

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    enum TestEdit {
        Append(String),
    }

    #[derive(Debug, Clone, PartialEq, Eq)]
    enum TestError {
        OperationLog(OperationLogError),
    }

    impl From<OperationLogError> for TestError {
        fn from(error: OperationLogError) -> Self {
            Self::OperationLog(error)
        }
    }

    fn operation(id: &str, sequence: u64, text: &str) -> OperationEnvelope<TestEdit> {
        OperationEnvelope::new(
            TEST_ENGINE_ID,
            id,
            "doc-1",
            "actor-1",
            sequence,
            sequence * 100,
            TestEdit::Append(text.to_owned()),
        )
    }

    fn artifact() -> OperationArtifact<TestSnapshot, TestEdit> {
        OperationArtifact::new(
            TEST_ENGINE_ID,
            "doc-1",
            TestSnapshot {
                text: String::new(),
            },
            OperationLog::from_operations(vec![
                operation("op-1", 1, "a"),
                operation("op-2", 2, "b"),
                operation("op-3", 3, "c"),
            ])
            .with_metadata_text("source", "test"),
        )
    }

    fn restore(artifact: &OperationArtifact<TestSnapshot, TestEdit>) -> Result<String, TestError> {
        artifact.validate_for_engine(TEST_ENGINE_ID)?;
        let mut text = artifact.snapshot.text.clone();
        for operation in &artifact.operation_log.operations {
            match &operation.edit {
                TestEdit::Append(next) => text.push_str(next),
            }
        }
        Ok(text)
    }

    fn compact(
        artifact: &OperationArtifact<TestSnapshot, TestEdit>,
        retain_tail_operations: usize,
        compacted_at_ms: u64,
    ) -> Result<OperationArtifact<TestSnapshot, TestEdit>, TestError> {
        let split = split_artifact_operation_tail(
            artifact,
            retain_tail_operations,
            compacted_at_ms,
            TEST_ENGINE_ID,
        )?;
        let mut snapshot_artifact = artifact.clone();
        snapshot_artifact.operation_log = OperationLog::from_operations(split.compacted_prefix);
        snapshot_artifact.operation_log.metadata = artifact.operation_log.metadata.clone();
        let snapshot_text = restore(&snapshot_artifact)?;

        let mut tail_log = OperationLog::from_operations(split.retained_tail);
        tail_log.metadata = artifact.operation_log.metadata.clone();
        let mut compacted = OperationArtifact::new(
            TEST_ENGINE_ID,
            artifact.document_id.clone(),
            TestSnapshot {
                text: snapshot_text,
            },
            tail_log,
        );
        compacted.metadata = artifact.metadata.clone();
        record_artifact_compaction_info(&mut compacted, &split.compaction_info);
        Ok(compacted)
    }

    fn maintain(
        artifact: &OperationArtifact<TestSnapshot, TestEdit>,
        policy: ArtifactMaintenancePolicy,
        compacted_at_ms: u64,
    ) -> Result<OperationArtifact<TestSnapshot, TestEdit>, TestError> {
        let plan = plan_artifact_maintenance(artifact, policy, TEST_ENGINE_ID)?;
        Ok(maintain_artifact_with_plan(
            artifact,
            &plan,
            compacted_at_ms,
            compact,
        )?)
    }

    #[test]
    fn compaction_harness_accepts_valid_domain_behavior() {
        let artifact = artifact();

        let report = validate_artifact_compaction_harness(
            TEST_ENGINE_ID,
            &artifact,
            1,
            1234,
            restore,
            compact,
            maintain,
        )
        .unwrap();

        assert_eq!(report.engine_id, TEST_ENGINE_ID);
        assert_eq!(report.document_id, "doc-1");
        assert_eq!(report.source_operation_count, 3);
        assert_eq!(report.compacted_operation_count, 2);
        assert_eq!(report.retained_operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
    }

    #[test]
    fn compaction_harness_detects_changed_restored_state() {
        let artifact = artifact();

        let err = validate_artifact_compaction_harness(
            TEST_ENGINE_ID,
            &artifact,
            1,
            1234,
            restore,
            |artifact, retain, compacted_at| {
                let mut compacted = compact(artifact, retain, compacted_at)?;
                compacted.snapshot.text.push('!');
                Ok(compacted)
            },
            maintain,
        )
        .unwrap_err();

        assert!(matches!(
            err,
            ArtifactCompactionHarnessError::CompactedRestoreMismatch { .. }
        ));
    }

    #[test]
    fn compaction_harness_detects_maintenance_that_skips_required_compaction() {
        let artifact = artifact();

        let err = validate_artifact_compaction_harness(
            TEST_ENGINE_ID,
            &artifact,
            1,
            1234,
            restore,
            compact,
            |artifact, _policy, _compacted_at_ms| Ok(artifact.clone()),
        )
        .unwrap_err();

        assert!(matches!(
            err,
            ArtifactCompactionHarnessError::MaintainCompactRetainedTailLengthMismatch {
                expected: 1,
                actual: 3
            }
        ));
    }
}
