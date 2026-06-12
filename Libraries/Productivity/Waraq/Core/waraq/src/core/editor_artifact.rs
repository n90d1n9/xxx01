// src/core/editor_artifact.rs
//
// Core editor artifact support — persists an editor session snapshot plus a
// typed edit-operation tail that can be replayed safely.

use serde::{Deserialize, Serialize};

use crate::core::artifact_lifecycle_harness::{
    validate_artifact_lifecycle_harness, ArtifactLifecycleHarnessError,
};
use crate::core::artifact_maintenance::{
    compact_artifact_with_replayed_prefix, maintain_artifact_with_plan_outcome,
    plan_artifact_maintenance, ArtifactCompactionInfo, ArtifactMaintenanceOutcome,
    ArtifactMaintenancePlan, ArtifactMaintenancePolicy,
};
use crate::core::artifact_test_profile::{
    domain_artifact_test_profile, validate_artifact_lifecycle_profile_report,
    ArtifactLifecycleProfileError, ArtifactLifecycleProfileValidationReport,
};
use crate::core::edit::EditOp;
use crate::core::operation::{
    OperationArtifact, OperationEnvelope, OperationLog, OperationLogError,
};
use crate::core::session::{capture, restore, Session};
use crate::Editor;

/// Engine identifier used for Waraq core editor operation artifacts.
pub const WARAQ_EDITOR_ENGINE_ID: &str = "waraq.editor";

const EDITOR_ARTIFACT_READINESS_DOCUMENT_ID: &str = "file:///main.txt";
const EDITOR_ARTIFACT_READINESS_ACTOR_ID: &str = "actor-1";
const EDITOR_ARTIFACT_READINESS_RETAIN_TAIL_OPERATIONS: usize = 1;
const EDITOR_ARTIFACT_READINESS_COMPACTED_AT_MS: u64 = 1234;

/// Typed operation envelope for raw Waraq editor edits.
pub type EditorOperation = OperationEnvelope<EditOp>;

/// Ordered operation log for raw Waraq editor edits.
pub type EditorOperationLog = OperationLog<EditOp>;

/// Persistable editor artifact composed from a session snapshot and edit log.
pub type EditorArtifact = OperationArtifact<Session, EditOp>;

/// Editor-specific alias for shared artifact compaction metadata.
pub type EditorArtifactCompactionInfo = ArtifactCompactionInfo;

/// Editor-specific alias for the shared artifact maintenance policy.
pub type EditorArtifactMaintenancePolicy = ArtifactMaintenancePolicy;

/// Editor-specific alias for the shared artifact maintenance plan.
pub type EditorArtifactMaintenancePlan = ArtifactMaintenancePlan;

/// Editor-specific alias for the shared artifact maintenance outcome.
pub type EditorArtifactMaintenanceOutcome = ArtifactMaintenanceOutcome<Session, EditOp>;

/// Result details returned after applying a core editor operation.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct EditorOperationOutcome {
    pub applied_text_edits: usize,
    pub changed_text: bool,
}

impl EditorOperationOutcome {
    fn text() -> Self {
        Self {
            applied_text_edits: 1,
            changed_text: true,
        }
    }
}

/// Validation or replay error for editor operation artifacts.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum EditorArtifactError {
    InvalidOffset {
        offset: usize,
        len_bytes: usize,
    },
    InvalidRange {
        start: usize,
        end: usize,
        len_bytes: usize,
    },
    InvalidUtf8Boundary {
        offset: usize,
    },
    SnapshotDocumentMismatch {
        expected: String,
        actual: String,
    },
    OperationLog(OperationLogError),
}

/// Error returned when Waraq's built-in editor artifact readiness probe fails.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum EditorArtifactReadinessError {
    /// The representative artifact failed the shared lifecycle harness.
    LifecycleHarness(ArtifactLifecycleHarnessError),
    /// The lifecycle harness report did not match the advertised profile.
    LifecycleProfile(ArtifactLifecycleProfileError),
}

impl From<OperationLogError> for EditorArtifactError {
    fn from(error: OperationLogError) -> Self {
        Self::OperationLog(error)
    }
}

/// Create a Waraq core editor operation envelope.
pub fn editor_operation(
    operation_id: impl Into<String>,
    document_id: impl Into<String>,
    actor_id: impl Into<String>,
    sequence: u64,
    timestamp_ms: u64,
    edit: EditOp,
) -> EditorOperation {
    OperationEnvelope::new(
        WARAQ_EDITOR_ENGINE_ID,
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        edit,
    )
}

/// Apply one validated Waraq core editor operation.
pub fn apply_editor_operation(
    editor: &mut Editor,
    operation: &EditorOperation,
) -> Result<EditorOperationOutcome, EditorArtifactError> {
    operation.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)?;
    validate_operation_document_id(editor, operation)?;
    apply_validated_edit(editor, &operation.edit)
}

/// Replay a validated Waraq core editor operation log.
pub fn replay_editor_log(
    editor: &mut Editor,
    log: &EditorOperationLog,
) -> Result<Vec<EditorOperationOutcome>, EditorArtifactError> {
    log.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)?;
    validate_log_document_id(editor, log)?;

    let mut simulated = editor.buffer.to_string();
    let mut ops = Vec::with_capacity(log.operations.len());
    for operation in &log.operations {
        ops.push(validate_and_simulate_edit(&mut simulated, &operation.edit)?);
    }

    Ok(ops
        .into_iter()
        .map(|op| {
            editor.apply(op);
            EditorOperationOutcome::text()
        })
        .collect())
}

/// Capture a Waraq core editor artifact with the provided operation tail.
pub fn editor_artifact(
    document_id: impl Into<String>,
    editor: &Editor,
    operation_log: EditorOperationLog,
) -> EditorArtifact {
    OperationArtifact::new(
        WARAQ_EDITOR_ENGINE_ID,
        document_id,
        capture(editor),
        operation_log,
    )
}

/// Restore an editor from a session snapshot and replay the artifact operation tail.
pub fn restore_editor_artifact(artifact: &EditorArtifact) -> Result<Editor, EditorArtifactError> {
    artifact.validate_for_engine(WARAQ_EDITOR_ENGINE_ID)?;
    validate_snapshot_document_id(artifact)?;

    let mut editor = restore(&artifact.snapshot);
    replay_editor_log(&mut editor, &artifact.operation_log)?;
    Ok(editor)
}

/// Fold older operations into the snapshot and retain a small operation tail.
pub fn compact_editor_artifact(
    artifact: &EditorArtifact,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
) -> Result<EditorArtifact, EditorArtifactError> {
    validate_snapshot_document_id(artifact)?;
    let compacted_artifact = compact_artifact_with_replayed_prefix(
        artifact,
        retain_tail_operations,
        compacted_at_ms,
        WARAQ_EDITOR_ENGINE_ID,
        |snapshot, prefix_log| {
            let mut snapshot_editor = restore(&snapshot);
            replay_editor_log(&mut snapshot_editor, &prefix_log)?;
            Ok::<_, EditorArtifactError>(capture(&snapshot_editor))
        },
    )?;
    validate_snapshot_document_id(&compacted_artifact)?;

    Ok(compacted_artifact)
}

/// Build a non-mutating maintenance plan for an editor artifact.
pub fn plan_editor_artifact_maintenance(
    artifact: &EditorArtifact,
    policy: EditorArtifactMaintenancePolicy,
) -> Result<EditorArtifactMaintenancePlan, EditorArtifactError> {
    let plan = plan_artifact_maintenance(artifact, policy, WARAQ_EDITOR_ENGINE_ID)?;
    validate_snapshot_document_id(artifact)?;
    Ok(plan)
}

/// Compact an artifact only when its maintenance policy says compaction is due.
pub fn maintain_editor_artifact(
    artifact: &EditorArtifact,
    policy: EditorArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<EditorArtifact, EditorArtifactError> {
    Ok(maintain_editor_artifact_with_outcome(artifact, policy, compacted_at_ms)?.artifact)
}

/// Maintain an editor artifact and report whether compaction happened.
pub fn maintain_editor_artifact_with_outcome(
    artifact: &EditorArtifact,
    policy: EditorArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<EditorArtifactMaintenanceOutcome, EditorArtifactError> {
    let plan = plan_editor_artifact_maintenance(artifact, policy)?;
    maintain_artifact_with_plan_outcome(artifact, &plan, compacted_at_ms, compact_editor_artifact)
}

/// Run Waraq's representative editor artifact lifecycle proof and validate it.
pub fn editor_artifact_lifecycle_profile_report(
) -> Result<ArtifactLifecycleProfileValidationReport, EditorArtifactReadinessError> {
    let (artifact, invalid_log) = editor_artifact_readiness_fixture();
    let expected_restored_state = "abc".to_owned();
    let invalid_replay_state = String::new();

    let lifecycle_report = validate_artifact_lifecycle_harness(
        WARAQ_EDITOR_ENGINE_ID,
        &artifact,
        &expected_restored_state,
        &invalid_replay_state,
        &invalid_log,
        EDITOR_ARTIFACT_READINESS_RETAIN_TAIL_OPERATIONS,
        EDITOR_ARTIFACT_READINESS_COMPACTED_AT_MS,
        |artifact| restore_editor_artifact(artifact).map(|editor| editor.buffer.to_string()),
        |text, log| {
            let mut editor = Editor::from_str(text);
            editor.file_uri = EDITOR_ARTIFACT_READINESS_DOCUMENT_ID.to_owned();
            let result = replay_editor_log(&mut editor, log).map(|_| ());
            *text = editor.buffer.to_string();
            result
        },
        compact_editor_artifact,
        maintain_editor_artifact,
    )
    .map_err(EditorArtifactReadinessError::LifecycleHarness)?;

    validate_artifact_lifecycle_profile_report(
        &domain_artifact_test_profile(WARAQ_EDITOR_ENGINE_ID),
        &lifecycle_report,
    )
    .map_err(EditorArtifactReadinessError::LifecycleProfile)
}

fn apply_validated_edit(
    editor: &mut Editor,
    edit: &EditOp,
) -> Result<EditorOperationOutcome, EditorArtifactError> {
    let mut simulated = editor.buffer.to_string();
    let op = validate_and_simulate_edit(&mut simulated, edit)?;
    editor.apply(op);
    Ok(EditorOperationOutcome::text())
}

fn validate_snapshot_document_id(artifact: &EditorArtifact) -> Result<(), EditorArtifactError> {
    let snapshot_file_uri = artifact.snapshot.file_uri.as_str();
    if !snapshot_file_uri.is_empty() && snapshot_file_uri != artifact.document_id {
        return Err(EditorArtifactError::SnapshotDocumentMismatch {
            expected: artifact.document_id.clone(),
            actual: artifact.snapshot.file_uri.clone(),
        });
    }
    Ok(())
}

fn editor_artifact_readiness_fixture() -> (EditorArtifact, EditorOperationLog) {
    let mut snapshot_editor = Editor::from_str("");
    snapshot_editor.file_uri = EDITOR_ARTIFACT_READINESS_DOCUMENT_ID.to_owned();

    let mut log = EditorOperationLog::new().with_metadata_text("source", "readiness");
    log.push(editor_artifact_readiness_insert_op("op-1", 1, 0, "a"));
    log.push(editor_artifact_readiness_insert_op("op-2", 2, 1, "b"));
    log.push(editor_artifact_readiness_insert_op("op-3", 3, 2, "c"));

    let artifact = editor_artifact(EDITOR_ARTIFACT_READINESS_DOCUMENT_ID, &snapshot_editor, log);

    let mut invalid_log = EditorOperationLog::new();
    invalid_log.push(editor_artifact_readiness_insert_op(
        "op-invalid-prefix",
        1,
        0,
        "!",
    ));
    invalid_log.push(editor_artifact_readiness_insert_op(
        "op-invalid",
        2,
        999,
        "bad",
    ));

    (artifact, invalid_log)
}

fn editor_artifact_readiness_insert_op(
    id: &str,
    sequence: u64,
    at: usize,
    text: &str,
) -> EditorOperation {
    editor_operation(
        id,
        EDITOR_ARTIFACT_READINESS_DOCUMENT_ID,
        EDITOR_ARTIFACT_READINESS_ACTOR_ID,
        sequence,
        sequence * 100,
        EditOp::insert(at, text),
    )
}

fn validate_operation_document_id(
    editor: &Editor,
    operation: &EditorOperation,
) -> Result<(), EditorArtifactError> {
    if !editor.file_uri.is_empty() && editor.file_uri != operation.document_id {
        return Err(OperationLogError::OperationDocumentMismatch {
            operation_id: operation.operation_id.clone(),
            expected: editor.file_uri.clone(),
            actual: operation.document_id.clone(),
        }
        .into());
    }
    Ok(())
}

fn validate_log_document_id(
    editor: &Editor,
    log: &EditorOperationLog,
) -> Result<(), EditorArtifactError> {
    if editor.file_uri.is_empty() {
        return Ok(());
    }

    for operation in &log.operations {
        validate_operation_document_id(editor, operation)?;
    }
    Ok(())
}

fn validate_and_simulate_edit(
    current: &mut String,
    edit: &EditOp,
) -> Result<EditOp, EditorArtifactError> {
    match edit {
        EditOp::Insert { at, text } => {
            validate_offset(current, at.0)?;
            current.insert_str(at.0, text);
            Ok(EditOp::insert(at.0, text))
        }
        EditOp::Delete { range } => {
            validate_range(current, range.start.0, range.end.0)?;
            current.replace_range(range.start.0..range.end.0, "");
            Ok(EditOp::delete(range.start.0, range.end.0))
        }
        EditOp::Replace { range, text } => {
            validate_range(current, range.start.0, range.end.0)?;
            current.replace_range(range.start.0..range.end.0, text);
            Ok(EditOp::replace(range.start.0, range.end.0, text))
        }
    }
}

fn validate_offset(text: &str, offset: usize) -> Result<(), EditorArtifactError> {
    if offset > text.len() {
        return Err(EditorArtifactError::InvalidOffset {
            offset,
            len_bytes: text.len(),
        });
    }
    if !text.is_char_boundary(offset) {
        return Err(EditorArtifactError::InvalidUtf8Boundary { offset });
    }
    Ok(())
}

fn validate_range(text: &str, start: usize, end: usize) -> Result<(), EditorArtifactError> {
    if start > end || end > text.len() {
        return Err(EditorArtifactError::InvalidRange {
            start,
            end,
            len_bytes: text.len(),
        });
    }
    validate_offset(text, start)?;
    validate_offset(text, end)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::artifact_compaction_harness::{
        validate_artifact_compaction_harness, REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS,
    };
    use crate::core::artifact_conformance::{
        validate_artifact_conformance, REQUIRED_ARTIFACT_CONFORMANCE_CHECKS,
    };
    use crate::core::artifact_contract::ARTIFACT_CONTRACT_VERSION;
    use crate::core::artifact_lifecycle_harness::validate_artifact_lifecycle_harness;
    use crate::core::artifact_maintenance::{artifact_compaction_info, ArtifactMaintenanceAction};
    use crate::core::artifact_replay_harness::{
        validate_artifact_replay_harness, REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
    };
    use crate::core::artifact_test_profile::{
        domain_artifact_test_profile, validate_artifact_lifecycle_profile_report,
        validate_domain_artifact_test_profile_report,
    };
    use crate::core::types::Range;

    fn insert_op(id: &str, sequence: u64, at: usize, text: &str) -> EditorOperation {
        editor_operation(
            id,
            "file:///main.txt",
            "actor-1",
            sequence,
            sequence * 100,
            EditOp::insert(at, text),
        )
    }

    fn append_insert_log(operation_count: usize) -> (EditorOperationLog, String) {
        let mut log = EditorOperationLog::new();
        let mut expected_text = String::new();

        for sequence in 1..=operation_count {
            let operation_id = format!("op-{sequence:03}");
            let token = format!("{sequence:03}|");
            log.push(insert_op(
                &operation_id,
                sequence as u64,
                expected_text.len(),
                &token,
            ));
            expected_text.push_str(&token);
        }

        (log, expected_text)
    }

    fn appended_text(operation_count: usize) -> String {
        (1..=operation_count)
            .map(|sequence| format!("{sequence:03}|"))
            .collect()
    }

    #[test]
    fn editor_operation_roundtrips_and_applies() {
        let operation = insert_op("op-1", 1, 5, " world");
        let json = operation.to_json().unwrap();
        let restored = EditorOperation::from_json(&json).unwrap();
        let mut editor = Editor::from_str("hello");

        let outcome = apply_editor_operation(&mut editor, &restored).unwrap();

        assert_eq!(editor.buffer.to_string(), "hello world");
        assert_eq!(outcome.applied_text_edits, 1);
        assert!(outcome.changed_text);
    }

    #[test]
    fn editor_log_replay_validates_against_evolving_text_state() {
        let mut log = EditorOperationLog::new();
        log.push(insert_op("op-1", 1, 0, "h"));
        log.push(insert_op("op-2", 2, 1, "i"));
        let mut editor = Editor::from_str("");

        let outcomes = replay_editor_log(&mut editor, &log).unwrap();

        assert_eq!(editor.buffer.to_string(), "hi");
        assert_eq!(outcomes.len(), 2);
    }

    #[test]
    fn editor_log_replay_handles_long_insert_history() {
        let (log, expected_text) = append_insert_log(128);
        let mut editor = Editor::from_str("");
        editor.file_uri = "file:///main.txt".into();

        let outcomes = replay_editor_log(&mut editor, &log).unwrap();

        assert_eq!(editor.buffer.to_string(), expected_text);
        assert_eq!(outcomes.len(), 128);
        assert!(outcomes.iter().all(|outcome| outcome.changed_text));
        assert_eq!(log.first_sequence(), Some(1));
        assert_eq!(log.last_sequence(), Some(128));
        assert_eq!(log.last_operation_id(), Some("op-128"));
    }

    #[test]
    fn editor_log_rejects_invalid_utf8_boundary_without_mutating_editor() {
        let mut log = EditorOperationLog::new();
        log.push(editor_operation(
            "op-1",
            "file:///main.txt",
            "actor-1",
            1,
            100,
            EditOp::Delete {
                range: Range::new(1, 2),
            },
        ));
        let mut editor = Editor::from_str("é");

        let err = replay_editor_log(&mut editor, &log).unwrap_err();

        assert_eq!(err, EditorArtifactError::InvalidUtf8Boundary { offset: 1 });
        assert_eq!(editor.buffer.to_string(), "é");
    }

    #[test]
    fn editor_artifact_roundtrips_and_restores_snapshot_plus_tail_log() {
        let mut snapshot_editor = Editor::from_str("hello");
        snapshot_editor.file_uri = "file:///main.txt".into();
        snapshot_editor.set_language("text");
        snapshot_editor.cursors.move_to(3, false);

        let mut tail_log = EditorOperationLog::new();
        tail_log.push(insert_op("op-2", 2, 5, " world"));

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, tail_log);
        let json = artifact.to_json().unwrap();
        let restored_artifact = EditorArtifact::from_json(&json).unwrap();
        let restored_editor = restore_editor_artifact(&restored_artifact).unwrap();

        assert_eq!(restored_editor.buffer.to_string(), "hello world");
        assert_eq!(restored_editor.file_uri, "file:///main.txt");
        assert_eq!(restored_editor.language, "text");
        assert_eq!(restored_editor.cursors.primary().pos.0, 3);
    }

    #[test]
    fn editor_artifact_satisfies_shared_conformance_helper() {
        let mut snapshot_editor = Editor::from_str("hello");
        snapshot_editor.file_uri = "file:///main.txt".into();

        let mut tail_log = EditorOperationLog::new();
        tail_log.push(insert_op("op-2", 2, 5, " world"));
        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, tail_log);

        let report = validate_artifact_conformance(WARAQ_EDITOR_ENGINE_ID, &artifact).unwrap();

        assert_eq!(report.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(report.engine_id, WARAQ_EDITOR_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.txt");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
        assert!(report.checked_json_roundtrip);
        assert!(report.checked_wrong_engine_rejection);
        assert!(report.checked_wrong_document_rejection);
    }

    #[test]
    fn editor_artifact_declares_shared_test_profile() {
        let profile = domain_artifact_test_profile(WARAQ_EDITOR_ENGINE_ID);

        assert_eq!(profile.engine_id, WARAQ_EDITOR_ENGINE_ID);
        let report = validate_domain_artifact_test_profile_report(&profile).unwrap();
        assert_eq!(report.required_shared_check_count, 22);
        assert_eq!(report.lifecycle_harness_shared_check_count, Some(22));
    }

    #[test]
    fn editor_artifact_satisfies_shared_replay_harness() {
        let mut snapshot_editor = Editor::from_str("hello");
        snapshot_editor.file_uri = "file:///main.txt".into();

        let mut tail_log = EditorOperationLog::new();
        tail_log.push(insert_op("op-2", 2, 5, " world"));
        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, tail_log);

        let mut invalid_log = EditorOperationLog::new();
        invalid_log.push(insert_op("op-invalid-prefix", 1, 5, "!"));
        invalid_log.push(insert_op("op-invalid", 2, 999, "bad"));

        let report = validate_artifact_replay_harness(
            WARAQ_EDITOR_ENGINE_ID,
            &artifact,
            &"hello world".to_owned(),
            &"hello".to_owned(),
            &invalid_log,
            |artifact| restore_editor_artifact(artifact).map(|editor| editor.buffer.to_string()),
            |text, log| {
                let mut editor = Editor::from_str(text);
                editor.file_uri = "file:///main.txt".to_owned();
                let result = replay_editor_log(&mut editor, log).map(|_| ());
                *text = editor.buffer.to_string();
                result
            },
        )
        .unwrap();

        assert_eq!(report.engine_id, WARAQ_EDITOR_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.txt");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
    }

    #[test]
    fn editor_artifact_satisfies_shared_compaction_harness() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();

        let mut log = EditorOperationLog::new().with_metadata_text("source", "keyboard");
        log.push(insert_op("op-1", 1, 0, "a"));
        log.push(insert_op("op-2", 2, 1, "b"));
        log.push(insert_op("op-3", 3, 2, "c"));
        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);

        let report = validate_artifact_compaction_harness(
            WARAQ_EDITOR_ENGINE_ID,
            &artifact,
            1,
            1234,
            |artifact| restore_editor_artifact(artifact).map(|editor| editor.buffer.to_string()),
            compact_editor_artifact,
            maintain_editor_artifact,
        )
        .unwrap();

        assert_eq!(report.engine_id, WARAQ_EDITOR_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.txt");
        assert_eq!(report.source_operation_count, 3);
        assert_eq!(report.compacted_operation_count, 2);
        assert_eq!(report.retained_operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
    }

    #[test]
    fn editor_artifact_satisfies_shared_lifecycle_harness() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();

        let mut log = EditorOperationLog::new().with_metadata_text("source", "keyboard");
        log.push(insert_op("op-1", 1, 0, "a"));
        log.push(insert_op("op-2", 2, 1, "b"));
        log.push(insert_op("op-3", 3, 2, "c"));
        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);

        let mut invalid_log = EditorOperationLog::new();
        invalid_log.push(insert_op("op-invalid-prefix", 1, 0, "!"));
        invalid_log.push(insert_op("op-invalid", 2, 999, "bad"));

        let report = validate_artifact_lifecycle_harness(
            WARAQ_EDITOR_ENGINE_ID,
            &artifact,
            &"abc".to_owned(),
            &String::new(),
            &invalid_log,
            1,
            1234,
            |artifact| restore_editor_artifact(artifact).map(|editor| editor.buffer.to_string()),
            |text, log| {
                let mut editor = Editor::from_str(text);
                editor.file_uri = "file:///main.txt".to_owned();
                let result = replay_editor_log(&mut editor, log).map(|_| ());
                *text = editor.buffer.to_string();
                result
            },
            compact_editor_artifact,
            maintain_editor_artifact,
        )
        .unwrap();

        let validation_report = validate_artifact_lifecycle_profile_report(
            &domain_artifact_test_profile(WARAQ_EDITOR_ENGINE_ID),
            &report,
        )
        .unwrap();
        assert_eq!(validation_report.completed_shared_check_count, 22);
        assert_eq!(validation_report.document_id, "file:///main.txt");
    }

    #[test]
    fn editor_artifact_lifecycle_profile_report_exposes_readiness() {
        let report = editor_artifact_lifecycle_profile_report().unwrap();

        assert_eq!(report.engine_id, WARAQ_EDITOR_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.txt");
        assert_eq!(report.profile.required_shared_check_count, 22);
        assert_eq!(report.expected_shared_check_count, 22);
        assert_eq!(report.completed_shared_check_count, 22);
        assert_eq!(report.completed_conformance_check_count, 10);
        assert_eq!(report.completed_replay_harness_check_count, 4);
        assert_eq!(report.completed_compaction_harness_check_count, 8);
    }

    #[test]
    fn compact_editor_artifact_folds_prefix_and_retains_tail() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();

        let mut log = EditorOperationLog::new().with_metadata_text("source", "keyboard");
        log.push(insert_op("op-1", 1, 0, "a"));
        log.push(insert_op("op-2", 2, 1, "b"));
        log.push(insert_op("op-3", 3, 2, "c"));

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log)
            .with_metadata_text("owner", "core-test");
        let compacted = compact_editor_artifact(&artifact, 1, 1234).unwrap();
        let restored = restore_editor_artifact(&compacted).unwrap();

        assert_eq!(compacted.snapshot.content.as_deref(), Some("ab"));
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
        assert_eq!(compacted.operation_log.metadata["source"], "keyboard");
        assert_eq!(compacted.metadata["owner"], "core-test");
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.compacted_through_operation_id.as_deref(), Some("op-2"));
        assert_eq!(info.compacted_operation_count, 2);
        assert_eq!(restored.buffer.to_string(), "abc");
    }

    #[test]
    fn compact_editor_artifact_handles_long_operation_history() {
        const OPERATION_COUNT: usize = 128;
        const RETAIN_TAIL: usize = 7;
        const COMPACTED_AT_MS: u64 = 987_654;

        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();
        let (log, expected_text) = append_insert_log(OPERATION_COUNT);

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);
        let compacted = compact_editor_artifact(&artifact, RETAIN_TAIL, COMPACTED_AT_MS).unwrap();
        let restored = restore_editor_artifact(&compacted).unwrap();

        let compacted_operation_count = OPERATION_COUNT - RETAIN_TAIL;
        let expected_snapshot = appended_text(compacted_operation_count);
        assert_eq!(
            compacted.snapshot.content.as_deref(),
            Some(expected_snapshot.as_str())
        );
        assert_eq!(compacted.operation_log.len(), RETAIN_TAIL);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-122");
        assert_eq!(
            compacted.operation_log.operations[RETAIN_TAIL - 1].operation_id,
            "op-128"
        );
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.source_operation_count, OPERATION_COUNT);
        assert_eq!(info.compacted_operation_count, compacted_operation_count);
        assert_eq!(info.retained_operation_count, RETAIN_TAIL);
        assert_eq!(
            info.compacted_through_sequence,
            Some(compacted_operation_count as u64)
        );
        assert_eq!(
            info.compacted_through_operation_id.as_deref(),
            Some("op-121")
        );
        assert_eq!(info.compacted_at_ms, COMPACTED_AT_MS);
        assert_eq!(restored.buffer.to_string(), expected_text);
    }

    #[test]
    fn compact_editor_artifact_can_retain_entire_tail() {
        let mut snapshot_editor = Editor::from_str("a");
        snapshot_editor.file_uri = "file:///main.txt".into();
        let mut log = EditorOperationLog::new();
        log.push(insert_op("op-2", 2, 1, "b"));

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);
        let compacted = compact_editor_artifact(&artifact, 10, 1234).unwrap();
        let restored = restore_editor_artifact(&compacted).unwrap();

        assert_eq!(compacted.snapshot.content.as_deref(), Some("a"));
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(
            artifact_compaction_info(&compacted)
                .unwrap()
                .unwrap()
                .compacted_operation_count,
            0
        );
        assert_eq!(restored.buffer.to_string(), "ab");
    }

    #[test]
    fn plan_editor_artifact_maintenance_reports_threshold_decision() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();
        let mut log = EditorOperationLog::new();
        log.push(insert_op("op-1", 1, 0, "a"));
        log.push(insert_op("op-2", 2, 1, "b"));
        log.push(insert_op("op-3", 3, 2, "c"));

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);
        let plan =
            plan_editor_artifact_maintenance(&artifact, EditorArtifactMaintenancePolicy::new(2, 1))
                .unwrap();

        assert!(plan.should_compact);
        assert_eq!(plan.operation_count, 3);
        assert_eq!(plan.compactable_operation_count, 2);
        assert_eq!(plan.first_sequence, Some(1));
        assert_eq!(plan.last_sequence, Some(3));
        assert_eq!(plan.last_operation_id.as_deref(), Some("op-3"));
    }

    #[test]
    fn maintain_editor_artifact_only_compacts_when_threshold_is_exceeded() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.txt".into();
        let mut log = EditorOperationLog::new();
        log.push(insert_op("op-1", 1, 0, "a"));
        log.push(insert_op("op-2", 2, 1, "b"));
        log.push(insert_op("op-3", 3, 2, "c"));

        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, log);
        let unchanged =
            maintain_editor_artifact(&artifact, EditorArtifactMaintenancePolicy::new(10, 1), 1234)
                .unwrap();
        let compacted =
            maintain_editor_artifact(&artifact, EditorArtifactMaintenancePolicy::new(2, 1), 1234)
                .unwrap();
        let skipped_outcome = maintain_editor_artifact_with_outcome(
            &artifact,
            EditorArtifactMaintenancePolicy::new(10, 1),
            1234,
        )
        .unwrap();
        let compacted_outcome = maintain_editor_artifact_with_outcome(
            &artifact,
            EditorArtifactMaintenancePolicy::new(2, 1),
            1234,
        )
        .unwrap();

        assert_eq!(unchanged.operation_log.len(), 3);
        assert_eq!(skipped_outcome.action, ArtifactMaintenanceAction::Preserved);
        assert_eq!(skipped_outcome.artifact.document_id, artifact.document_id);
        assert_eq!(
            skipped_outcome.artifact.operation_log.len(),
            artifact.operation_log.len()
        );
        assert_eq!(skipped_outcome.compaction_info, None);
        assert_eq!(compacted.snapshot.content.as_deref(), Some("ab"));
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(
            compacted_outcome.action,
            ArtifactMaintenanceAction::Compacted
        );
        assert_eq!(compacted_outcome.plan.compactable_operation_count, 2);
        assert_eq!(
            compacted_outcome
                .compaction_info
                .as_ref()
                .and_then(|info| info.compacted_through_operation_id.as_deref()),
            Some("op-2")
        );
        assert_eq!(compacted_outcome.artifact.operation_log.len(), 1);
        assert_eq!(
            restore_editor_artifact(&compacted)
                .unwrap()
                .buffer
                .to_string(),
            "abc"
        );
    }

    #[test]
    fn editor_artifact_rejects_mismatched_snapshot_document() {
        let mut snapshot_editor = Editor::from_str("hello");
        snapshot_editor.file_uri = "file:///other.txt".into();
        let artifact = editor_artifact(
            "file:///main.txt",
            &snapshot_editor,
            EditorOperationLog::new(),
        );

        let err = match restore_editor_artifact(&artifact) {
            Ok(_) => panic!("expected snapshot mismatch error"),
            Err(err) => err,
        };

        assert_eq!(
            err,
            EditorArtifactError::SnapshotDocumentMismatch {
                expected: "file:///main.txt".into(),
                actual: "file:///other.txt".into(),
            }
        );
    }

    #[test]
    fn editor_artifact_rejects_mismatched_operation_document() {
        let mut snapshot_editor = Editor::from_str("hello");
        snapshot_editor.file_uri = "file:///main.txt".into();
        let mut tail_log = EditorOperationLog::new();
        tail_log.push(editor_operation(
            "op-1",
            "file:///other.txt",
            "actor-1",
            1,
            100,
            EditOp::insert(5, " bad"),
        ));
        let artifact = editor_artifact("file:///main.txt", &snapshot_editor, tail_log);

        let err = match restore_editor_artifact(&artifact) {
            Ok(_) => panic!("expected operation document mismatch error"),
            Err(err) => err,
        };

        assert_eq!(
            err,
            EditorArtifactError::OperationLog(OperationLogError::OperationDocumentMismatch {
                operation_id: "op-1".into(),
                expected: "file:///main.txt".into(),
                actual: "file:///other.txt".into(),
            })
        );
    }

    #[test]
    fn editor_log_rejects_operation_for_another_open_editor() {
        let mut editor = Editor::from_str("hello");
        editor.file_uri = "file:///main.txt".into();
        let mut log = EditorOperationLog::new();
        log.push(editor_operation(
            "op-1",
            "file:///other.txt",
            "actor-1",
            1,
            100,
            EditOp::insert(5, " bad"),
        ));

        let err = match replay_editor_log(&mut editor, &log) {
            Ok(_) => panic!("expected operation document mismatch error"),
            Err(err) => err,
        };

        assert_eq!(
            err,
            EditorArtifactError::OperationLog(OperationLogError::OperationDocumentMismatch {
                operation_id: "op-1".into(),
                expected: "file:///main.txt".into(),
                actual: "file:///other.txt".into(),
            })
        );
        assert_eq!(editor.buffer.to_string(), "hello");
    }
}
