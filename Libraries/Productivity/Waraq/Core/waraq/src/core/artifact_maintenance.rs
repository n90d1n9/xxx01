//! Shared maintenance helpers for snapshot-plus-operation-tail artifacts.
//!
//! Domain engines own how a compacted prefix is folded into their snapshot.
//! Waraq owns the reusable policy math, retained-tail split, and compaction
//! metadata shape so every engine reports maintenance decisions consistently.

use serde::{Deserialize, Serialize};

use crate::core::operation::{
    OperationArtifact, OperationEnvelope, OperationLog, OperationLogError, OperationMetadata,
};

/// Canonical artifact metadata key used to store shared compaction information.
pub const ARTIFACT_COMPACTION_METADATA_KEY: &str = "compaction";

/// Summary recorded when an artifact operation prefix is compacted.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactCompactionInfo {
    /// Number of operations in the original artifact tail.
    pub source_operation_count: usize,
    /// Number of prefix operations folded into the new snapshot.
    pub compacted_operation_count: usize,
    /// Number of operations retained in the replay tail.
    pub retained_operation_count: usize,
    /// Last sequence folded into the snapshot, when a prefix was compacted.
    pub compacted_through_sequence: Option<u64>,
    /// Last operation id folded into the snapshot, when a prefix was compacted.
    pub compacted_through_operation_id: Option<String>,
    /// Host-supplied timestamp for the compaction event.
    pub compacted_at_ms: u64,
}

/// Policy used to decide when an artifact operation tail should be compacted.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactMaintenancePolicy {
    /// Maximum tail length allowed before compaction is recommended.
    pub max_tail_operations: usize,
    /// Number of newest operations to keep replayable after compaction.
    pub retain_tail_operations: usize,
}

impl ArtifactMaintenancePolicy {
    /// Create a maintenance policy from a maximum tail size and retained tail.
    pub fn new(max_tail_operations: usize, retain_tail_operations: usize) -> Self {
        Self {
            max_tail_operations,
            retain_tail_operations,
        }
    }
}

/// Non-mutating maintenance decision for an artifact.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactMaintenancePlan {
    /// Number of operations currently in the artifact tail.
    pub operation_count: usize,
    /// Policy threshold used to decide whether compaction is due.
    pub max_tail_operations: usize,
    /// Effective retained tail after clamping to the current operation count.
    pub retain_tail_operations: usize,
    /// Number of operations that could be folded into the snapshot.
    pub compactable_operation_count: usize,
    /// True when the artifact tail exceeds the threshold and has a foldable prefix.
    pub should_compact: bool,
    /// First sequence in the current operation tail.
    pub first_sequence: Option<u64>,
    /// Last sequence in the current operation tail.
    pub last_sequence: Option<u64>,
    /// Last operation id in the current operation tail.
    pub last_operation_id: Option<String>,
}

/// Action taken by a policy-based artifact maintenance call.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactMaintenanceAction {
    /// The artifact already satisfied the policy and was returned unchanged.
    Preserved,
    /// The artifact tail exceeded the policy and an older prefix was compacted.
    Compacted,
}

/// Typed result returned by artifact maintenance helpers.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ArtifactMaintenanceOutcome<Snapshot, Edit> {
    /// Maintained artifact returned to the caller.
    pub artifact: OperationArtifact<Snapshot, Edit>,
    /// Maintenance plan that drove the outcome.
    pub plan: ArtifactMaintenancePlan,
    /// Whether maintenance preserved or compacted the artifact.
    pub action: ArtifactMaintenanceAction,
    /// Shared compaction metadata expected for a compaction action.
    pub compaction_info: Option<ArtifactCompactionInfo>,
}

/// Operation-tail split used by domain-specific compaction implementations.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct ArtifactOperationTailSplit<Edit> {
    /// Prefix operations that should be replayed into a new snapshot.
    pub compacted_prefix: Vec<OperationEnvelope<Edit>>,
    /// Newest operations that should remain in the replay tail.
    pub retained_tail: Vec<OperationEnvelope<Edit>>,
    /// Shared metadata describing the split.
    pub compaction_info: ArtifactCompactionInfo,
}

/// Build a non-mutating maintenance plan for any Waraq-family artifact.
pub fn plan_artifact_maintenance<Snapshot, Edit>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    policy: ArtifactMaintenancePolicy,
    expected_engine: &str,
) -> Result<ArtifactMaintenancePlan, OperationLogError> {
    artifact.validate_for_engine(expected_engine)?;

    let operation_count = artifact.operation_log.len();
    let retain_tail_operations = policy.retain_tail_operations.min(operation_count);
    let compactable_operation_count = operation_count.saturating_sub(retain_tail_operations);
    let should_compact =
        operation_count > policy.max_tail_operations && compactable_operation_count > 0;

    Ok(ArtifactMaintenancePlan {
        operation_count,
        max_tail_operations: policy.max_tail_operations,
        retain_tail_operations,
        compactable_operation_count,
        should_compact,
        first_sequence: artifact.operation_log.first_sequence(),
        last_sequence: artifact.operation_log.last_sequence(),
        last_operation_id: artifact
            .operation_log
            .last_operation_id()
            .map(ToOwned::to_owned),
    })
}

/// Split an artifact tail into a compacted prefix and retained replay tail.
pub fn split_artifact_operation_tail<Snapshot, Edit>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
    expected_engine: &str,
) -> Result<ArtifactOperationTailSplit<Edit>, OperationLogError>
where
    Edit: Clone,
{
    artifact.validate_for_engine(expected_engine)?;

    let source_operation_count = artifact.operation_log.len();
    let retained_operation_count = retain_tail_operations.min(source_operation_count);
    let compacted_operation_count = source_operation_count.saturating_sub(retained_operation_count);

    let compacted_prefix = artifact.operation_log.operations[..compacted_operation_count].to_vec();
    let retained_tail = artifact.operation_log.operations[compacted_operation_count..].to_vec();

    let compacted_through_sequence = compacted_prefix.last().map(|operation| operation.sequence);
    let compacted_through_operation_id = compacted_prefix
        .last()
        .map(|operation| operation.operation_id.clone());

    Ok(ArtifactOperationTailSplit {
        compacted_prefix,
        retained_tail,
        compaction_info: ArtifactCompactionInfo {
            source_operation_count,
            compacted_operation_count,
            retained_operation_count,
            compacted_through_sequence,
            compacted_through_operation_id,
            compacted_at_ms,
        },
    })
}

/// Record shared compaction metadata on an artifact.
pub fn record_artifact_compaction_info<Snapshot, Edit>(
    artifact: &mut OperationArtifact<Snapshot, Edit>,
    info: &ArtifactCompactionInfo,
) {
    artifact.metadata.insert(
        ARTIFACT_COMPACTION_METADATA_KEY.into(),
        serde_json::to_value(info).unwrap_or_default(),
    );
}

/// Decode shared compaction metadata from a metadata map, when present.
pub fn artifact_compaction_info_from_metadata(
    metadata: &OperationMetadata,
) -> Result<Option<ArtifactCompactionInfo>, serde_json::Error> {
    metadata
        .get(ARTIFACT_COMPACTION_METADATA_KEY)
        .map(|value| serde_json::from_value(value.clone()))
        .transpose()
}

/// Decode shared compaction metadata recorded on an artifact, when present.
pub fn artifact_compaction_info<Snapshot, Edit>(
    artifact: &OperationArtifact<Snapshot, Edit>,
) -> Result<Option<ArtifactCompactionInfo>, serde_json::Error> {
    artifact_compaction_info_from_metadata(&artifact.metadata)
}

/// Compact an artifact by replaying its foldable prefix into a new snapshot.
///
/// Waraq owns the mechanical artifact work: splitting the operation tail,
/// preserving operation-log metadata, copying artifact metadata, recording the
/// shared compaction info, and validating the resulting transport shape. The
/// domain engine owns `replay_prefix_into_snapshot`, because only the engine
/// knows how a prefix log mutates its snapshot model.
pub fn compact_artifact_with_replayed_prefix<Snapshot, Edit, DomainError, ReplayPrefix>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
    expected_engine: &str,
    replay_prefix_into_snapshot: ReplayPrefix,
) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>
where
    Snapshot: Clone,
    Edit: Clone,
    DomainError: From<OperationLogError>,
    ReplayPrefix: FnOnce(Snapshot, OperationLog<Edit>) -> Result<Snapshot, DomainError>,
{
    let split = split_artifact_operation_tail(
        artifact,
        retain_tail_operations,
        compacted_at_ms,
        expected_engine,
    )?;

    let mut prefix_log = OperationLog::from_operations(split.compacted_prefix);
    prefix_log.metadata = artifact.operation_log.metadata.clone();
    let compacted_snapshot = replay_prefix_into_snapshot(artifact.snapshot.clone(), prefix_log)?;

    let mut tail_log = OperationLog::from_operations(split.retained_tail);
    tail_log.metadata = artifact.operation_log.metadata.clone();

    let mut compacted_artifact = OperationArtifact::new(
        expected_engine,
        artifact.document_id.clone(),
        compacted_snapshot,
        tail_log,
    );
    compacted_artifact.metadata = artifact.metadata.clone();
    record_artifact_compaction_info(&mut compacted_artifact, &split.compaction_info);
    compacted_artifact.validate_for_engine(expected_engine)?;

    Ok(compacted_artifact)
}

/// Apply an already validated artifact maintenance plan.
///
/// Domain engines often add validation around `plan_artifact_maintenance`, such
/// as checking that a snapshot document id matches the artifact document id.
/// This helper intentionally accepts the finished plan so engines can keep that
/// domain validation local while sharing the final maintenance branch.
pub fn maintain_artifact_with_plan<Snapshot, Edit, DomainError, Compact>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    plan: &ArtifactMaintenancePlan,
    compacted_at_ms: u64,
    compact_artifact: Compact,
) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>
where
    Snapshot: Clone,
    Edit: Clone,
    Compact: FnOnce(
        &OperationArtifact<Snapshot, Edit>,
        usize,
        u64,
    ) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>,
{
    maintain_artifact_with_plan_outcome(artifact, plan, compacted_at_ms, compact_artifact)
        .map(|outcome| outcome.artifact)
}

/// Apply an already validated artifact maintenance plan and report the action.
pub fn maintain_artifact_with_plan_outcome<Snapshot, Edit, DomainError, Compact>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    plan: &ArtifactMaintenancePlan,
    compacted_at_ms: u64,
    compact_artifact: Compact,
) -> Result<ArtifactMaintenanceOutcome<Snapshot, Edit>, DomainError>
where
    Snapshot: Clone,
    Edit: Clone,
    Compact: FnOnce(
        &OperationArtifact<Snapshot, Edit>,
        usize,
        u64,
    ) -> Result<OperationArtifact<Snapshot, Edit>, DomainError>,
{
    if plan.should_compact {
        let compaction_info =
            maintenance_compaction_info_from_plan(artifact, plan, compacted_at_ms);
        let artifact = compact_artifact(artifact, plan.retain_tail_operations, compacted_at_ms)?;
        Ok(ArtifactMaintenanceOutcome {
            artifact,
            plan: plan.clone(),
            action: ArtifactMaintenanceAction::Compacted,
            compaction_info,
        })
    } else {
        Ok(ArtifactMaintenanceOutcome {
            artifact: artifact.clone(),
            plan: plan.clone(),
            action: ArtifactMaintenanceAction::Preserved,
            compaction_info: None,
        })
    }
}

fn maintenance_compaction_info_from_plan<Snapshot, Edit>(
    artifact: &OperationArtifact<Snapshot, Edit>,
    plan: &ArtifactMaintenancePlan,
    compacted_at_ms: u64,
) -> Option<ArtifactCompactionInfo> {
    if !plan.should_compact {
        return None;
    }

    let compacted_through_operation = plan
        .compactable_operation_count
        .checked_sub(1)
        .and_then(|index| artifact.operation_log.operations.get(index));

    Some(ArtifactCompactionInfo {
        source_operation_count: plan.operation_count,
        compacted_operation_count: plan.compactable_operation_count,
        retained_operation_count: plan.retain_tail_operations,
        compacted_through_sequence: compacted_through_operation.map(|operation| operation.sequence),
        compacted_through_operation_id: compacted_through_operation
            .map(|operation| operation.operation_id.clone()),
        compacted_at_ms,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::operation::{OperationArtifact, OperationEnvelope, OperationLog};

    const TEST_ENGINE_ID: &str = "waraq.maintenance.test";

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    struct TestSnapshot {
        value: String,
    }

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    enum TestEdit {
        Append(String),
    }

    fn operation(id: &str, sequence: u64) -> OperationEnvelope<TestEdit> {
        OperationEnvelope::new(
            TEST_ENGINE_ID,
            id,
            "doc-1",
            "actor-1",
            sequence,
            sequence * 100,
            TestEdit::Append(id.to_owned()),
        )
    }

    fn artifact(operation_count: u64) -> OperationArtifact<TestSnapshot, TestEdit> {
        let operations = (1..=operation_count)
            .map(|sequence| operation(&format!("op-{sequence}"), sequence))
            .collect();
        OperationArtifact::new(
            TEST_ENGINE_ID,
            "doc-1",
            TestSnapshot {
                value: String::new(),
            },
            OperationLog::from_operations(operations),
        )
    }

    #[test]
    fn maintenance_plan_reports_threshold_decision() {
        let artifact = artifact(4);
        let plan = plan_artifact_maintenance(
            &artifact,
            ArtifactMaintenancePolicy::new(3, 1),
            TEST_ENGINE_ID,
        )
        .unwrap();

        assert_eq!(plan.operation_count, 4);
        assert_eq!(plan.max_tail_operations, 3);
        assert_eq!(plan.retain_tail_operations, 1);
        assert_eq!(plan.compactable_operation_count, 3);
        assert!(plan.should_compact);
        assert_eq!(plan.first_sequence, Some(1));
        assert_eq!(plan.last_sequence, Some(4));
        assert_eq!(plan.last_operation_id.as_deref(), Some("op-4"));
    }

    #[test]
    fn maintenance_plan_clamps_retained_tail_to_operation_count() {
        let artifact = artifact(2);
        let plan = plan_artifact_maintenance(
            &artifact,
            ArtifactMaintenancePolicy::new(1, 10),
            TEST_ENGINE_ID,
        )
        .unwrap();

        assert_eq!(plan.operation_count, 2);
        assert_eq!(plan.retain_tail_operations, 2);
        assert_eq!(plan.compactable_operation_count, 0);
        assert!(!plan.should_compact);
    }

    #[test]
    fn operation_tail_split_returns_prefix_tail_and_metadata() {
        let artifact = artifact(5);
        let split = split_artifact_operation_tail(&artifact, 2, 1234, TEST_ENGINE_ID).unwrap();

        assert_eq!(split.compacted_prefix.len(), 3);
        assert_eq!(split.retained_tail.len(), 2);
        assert_eq!(split.compacted_prefix[0].operation_id, "op-1");
        assert_eq!(split.compacted_prefix[2].operation_id, "op-3");
        assert_eq!(split.retained_tail[0].operation_id, "op-4");
        assert_eq!(split.retained_tail[1].operation_id, "op-5");
        assert_eq!(split.compaction_info.source_operation_count, 5);
        assert_eq!(split.compaction_info.compacted_operation_count, 3);
        assert_eq!(split.compaction_info.retained_operation_count, 2);
        assert_eq!(split.compaction_info.compacted_through_sequence, Some(3));
        assert_eq!(
            split
                .compaction_info
                .compacted_through_operation_id
                .as_deref(),
            Some("op-3")
        );
        assert_eq!(split.compaction_info.compacted_at_ms, 1234);
    }

    #[test]
    fn compaction_metadata_records_shared_shape() {
        let mut artifact = artifact(2);
        let split = split_artifact_operation_tail(&artifact, 1, 5678, TEST_ENGINE_ID).unwrap();

        record_artifact_compaction_info(&mut artifact, &split.compaction_info);

        assert!(artifact
            .metadata
            .contains_key(ARTIFACT_COMPACTION_METADATA_KEY));
        let info = artifact_compaction_info(&artifact).unwrap().unwrap();

        assert_eq!(info.compacted_operation_count, 1);
        assert_eq!(info.compacted_through_operation_id.as_deref(), Some("op-1"));
        assert_eq!(info.compacted_at_ms, 5678);
    }

    #[test]
    fn compaction_metadata_reader_reports_missing_and_invalid_shapes() {
        let mut artifact = artifact(1);

        assert_eq!(artifact_compaction_info(&artifact).unwrap(), None);

        artifact.metadata.insert(
            ARTIFACT_COMPACTION_METADATA_KEY.into(),
            serde_json::json!({"source_operation_count": "invalid"}),
        );

        assert!(artifact_compaction_info(&artifact).is_err());
    }

    #[test]
    fn compact_artifact_with_replayed_prefix_preserves_shared_shape() {
        let artifact = artifact(5)
            .with_metadata_text("owner", "maintenance-test")
            .with_metadata_text("kind", "append-log");
        let artifact = OperationArtifact {
            operation_log: artifact
                .operation_log
                .with_metadata_text("source", "keyboard"),
            ..artifact
        };

        let compacted = compact_artifact_with_replayed_prefix(
            &artifact,
            2,
            9012,
            TEST_ENGINE_ID,
            |mut snapshot, prefix_log| {
                prefix_log.validate_for_engine(TEST_ENGINE_ID)?;
                for operation in prefix_log.operations {
                    match operation.edit {
                        TestEdit::Append(text) => snapshot.value.push_str(&text),
                    }
                }
                Ok::<_, OperationLogError>(snapshot)
            },
        )
        .unwrap();

        assert_eq!(compacted.engine, TEST_ENGINE_ID);
        assert_eq!(compacted.document_id, "doc-1");
        assert_eq!(compacted.snapshot.value, "op-1op-2op-3");
        assert_eq!(compacted.operation_log.len(), 2);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-4");
        assert_eq!(compacted.operation_log.operations[1].operation_id, "op-5");
        assert_eq!(compacted.operation_log.metadata["source"], "keyboard");
        assert_eq!(compacted.metadata["owner"], "maintenance-test");
        assert_eq!(compacted.metadata["kind"], "append-log");
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.source_operation_count, 5);
        assert_eq!(info.compacted_operation_count, 3);
        assert_eq!(info.retained_operation_count, 2);
        assert_eq!(info.compacted_through_operation_id.as_deref(), Some("op-3"));
        assert_eq!(info.compacted_at_ms, 9012);
    }

    #[test]
    fn maintain_artifact_with_plan_compacts_only_when_plan_requires_it() {
        let artifact = artifact(4);
        let skipped_plan = ArtifactMaintenancePlan {
            operation_count: 4,
            max_tail_operations: 10,
            retain_tail_operations: 1,
            compactable_operation_count: 3,
            should_compact: false,
            first_sequence: Some(1),
            last_sequence: Some(4),
            last_operation_id: Some("op-4".into()),
        };

        let unchanged = maintain_artifact_with_plan(
            &artifact,
            &skipped_plan,
            1234,
            |_, _, _| -> Result<_, OperationLogError> { panic!("compact should be skipped") },
        )
        .unwrap();

        assert_eq!(unchanged, artifact);

        let skipped_outcome = maintain_artifact_with_plan_outcome(
            &artifact,
            &skipped_plan,
            1234,
            |_, _, _| -> Result<_, OperationLogError> { panic!("compact should be skipped") },
        )
        .unwrap();

        assert_eq!(skipped_outcome.artifact, artifact);
        assert_eq!(skipped_outcome.plan, skipped_plan);
        assert_eq!(skipped_outcome.action, ArtifactMaintenanceAction::Preserved);
        assert_eq!(skipped_outcome.compaction_info, None);

        let compact_plan = ArtifactMaintenancePlan {
            operation_count: 4,
            max_tail_operations: 2,
            retain_tail_operations: 2,
            compactable_operation_count: 2,
            should_compact: true,
            first_sequence: Some(1),
            last_sequence: Some(4),
            last_operation_id: Some("op-4".into()),
        };
        let compacted = maintain_artifact_with_plan(
            &artifact,
            &compact_plan,
            5678,
            |artifact, retain_tail_operations, compacted_at_ms| {
                compact_artifact_with_replayed_prefix(
                    artifact,
                    retain_tail_operations,
                    compacted_at_ms,
                    TEST_ENGINE_ID,
                    |mut snapshot, prefix_log| {
                        for operation in prefix_log.operations {
                            match operation.edit {
                                TestEdit::Append(text) => snapshot.value.push_str(&text),
                            }
                        }
                        Ok::<_, OperationLogError>(snapshot)
                    },
                )
            },
        )
        .unwrap();

        assert_eq!(compacted.snapshot.value, "op-1op-2");
        assert_eq!(compacted.operation_log.len(), 2);
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.retained_operation_count, 2);
        assert_eq!(info.compacted_at_ms, 5678);

        let compacted_outcome = maintain_artifact_with_plan_outcome(
            &artifact,
            &compact_plan,
            5678,
            |artifact, retain_tail_operations, compacted_at_ms| {
                compact_artifact_with_replayed_prefix(
                    artifact,
                    retain_tail_operations,
                    compacted_at_ms,
                    TEST_ENGINE_ID,
                    |mut snapshot, prefix_log| {
                        for operation in prefix_log.operations {
                            match operation.edit {
                                TestEdit::Append(text) => snapshot.value.push_str(&text),
                            }
                        }
                        Ok::<_, OperationLogError>(snapshot)
                    },
                )
            },
        )
        .unwrap();

        assert_eq!(
            compacted_outcome.action,
            ArtifactMaintenanceAction::Compacted
        );
        assert_eq!(compacted_outcome.plan, compact_plan);
        assert_eq!(
            compacted_outcome
                .compaction_info
                .as_ref()
                .map(|info| info.compacted_through_operation_id.as_deref()),
            Some(Some("op-2"))
        );
        assert_eq!(
            compacted_outcome
                .compaction_info
                .as_ref()
                .map(|info| info.retained_operation_count),
            Some(2)
        );
    }

    #[test]
    fn maintenance_rejects_wrong_engine_artifact() {
        let mut artifact = artifact(1);
        artifact.engine = "other".into();

        let err = plan_artifact_maintenance(
            &artifact,
            ArtifactMaintenancePolicy::new(1, 0),
            TEST_ENGINE_ID,
        )
        .unwrap_err();

        assert_eq!(
            err,
            OperationLogError::WrongEngine {
                expected: TEST_ENGINE_ID.into(),
                actual: "other".into(),
                operation_id: "<artifact>".into(),
            }
        );
    }
}
