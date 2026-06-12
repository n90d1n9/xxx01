use serde::{Deserialize, Serialize};
use waraq_core::{
    compact_artifact_with_replayed_prefix, maintain_artifact_with_plan_outcome,
    plan_artifact_maintenance, ArtifactCompactionInfo, ArtifactMaintenanceOutcome,
    ArtifactMaintenancePlan, ArtifactMaintenancePolicy, EditOp, Editor, OperationArtifact,
    OperationEnvelope, OperationLog, OperationLogError, Range,
};

pub const CODE_ENGINE_ID: &str = "code";

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum CodeTextEdit {
    InsertText {
        at: usize,
        text: String,
    },
    DeleteRange {
        start: usize,
        end: usize,
    },
    ReplaceRange {
        start: usize,
        end: usize,
        text: String,
    },
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum CodeEdit {
    InsertText {
        at: usize,
        text: String,
    },
    DeleteRange {
        start: usize,
        end: usize,
    },
    ReplaceRange {
        start: usize,
        end: usize,
        text: String,
    },
    ApplyBatch {
        edits: Vec<CodeTextEdit>,
    },
    SetLanguage {
        language: String,
    },
    SetFileUri {
        file_uri: String,
    },
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CodeEditOutcome {
    pub applied_text_edits: usize,
    pub changed_text: bool,
    pub changed_language: bool,
    pub changed_file_uri: bool,
}

impl CodeEditOutcome {
    fn text(applied_text_edits: usize) -> Self {
        Self {
            applied_text_edits,
            changed_text: applied_text_edits > 0,
            changed_language: false,
            changed_file_uri: false,
        }
    }

    fn language() -> Self {
        Self {
            applied_text_edits: 0,
            changed_text: false,
            changed_language: true,
            changed_file_uri: false,
        }
    }

    fn file_uri() -> Self {
        Self {
            applied_text_edits: 0,
            changed_text: false,
            changed_language: false,
            changed_file_uri: true,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum CodeEditError {
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
    OperationLog(OperationLogError),
}

impl From<OperationLogError> for CodeEditError {
    fn from(error: OperationLogError) -> Self {
        Self::OperationLog(error)
    }
}

pub type CodeOperation = OperationEnvelope<CodeEdit>;
pub type CodeOperationLog = OperationLog<CodeEdit>;

/// Persistable code editor artifact composed from a text snapshot and typed edit log.
pub type CodeArtifact = OperationArtifact<CodeSnapshot, CodeEdit>;

/// Code-engine alias for shared artifact compaction metadata.
pub type CodeArtifactCompactionInfo = ArtifactCompactionInfo;

/// Code-engine alias for the shared artifact maintenance policy.
pub type CodeArtifactMaintenancePolicy = ArtifactMaintenancePolicy;

/// Code-engine alias for the shared artifact maintenance plan.
pub type CodeArtifactMaintenancePlan = ArtifactMaintenancePlan;

/// Code-engine alias for the shared artifact maintenance outcome.
pub type CodeArtifactMaintenanceOutcome = ArtifactMaintenanceOutcome<CodeSnapshot, CodeEdit>;

/// Serializable code editor snapshot used as the stable base for operation replay.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CodeSnapshot {
    pub text: String,
    pub language: String,
    pub file_uri: String,
}

impl CodeSnapshot {
    pub fn from_editor(editor: &Editor) -> Self {
        Self {
            text: editor.buffer.to_string(),
            language: editor.language.clone(),
            file_uri: editor.file_uri.clone(),
        }
    }

    pub fn to_editor(&self) -> Editor {
        let mut editor = Editor::from_str(&self.text);
        editor.file_uri = self.file_uri.clone();
        if !self.language.is_empty() {
            editor.set_language(&self.language);
        }
        editor
    }
}

pub fn code_operation(
    operation_id: impl Into<String>,
    document_id: impl Into<String>,
    actor_id: impl Into<String>,
    sequence: u64,
    timestamp_ms: u64,
    edit: CodeEdit,
) -> CodeOperation {
    OperationEnvelope::new(
        CODE_ENGINE_ID,
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        edit,
    )
}

pub fn apply_code_edit(
    editor: &mut Editor,
    edit: &CodeEdit,
) -> Result<CodeEditOutcome, CodeEditError> {
    match edit {
        CodeEdit::InsertText { at, text } => {
            let current = editor.buffer.to_string();
            validate_offset(&current, *at)?;
            editor.apply(EditOp::insert(*at, text));
            Ok(CodeEditOutcome::text(1))
        }
        CodeEdit::DeleteRange { start, end } => {
            let current = editor.buffer.to_string();
            validate_range(&current, *start, *end)?;
            editor.apply(EditOp::delete(*start, *end));
            Ok(CodeEditOutcome::text(1))
        }
        CodeEdit::ReplaceRange { start, end, text } => {
            let current = editor.buffer.to_string();
            validate_range(&current, *start, *end)?;
            editor.apply(EditOp::replace(*start, *end, text));
            Ok(CodeEditOutcome::text(1))
        }
        CodeEdit::ApplyBatch { edits } => {
            let mut simulated = editor.buffer.to_string();
            let mut ops = Vec::with_capacity(edits.len());
            for edit in edits {
                ops.push(validate_and_simulate_text_edit(&mut simulated, edit)?);
            }
            editor.apply_batch(ops);
            Ok(CodeEditOutcome::text(edits.len()))
        }
        CodeEdit::SetLanguage { language } => {
            editor.set_language(language);
            Ok(CodeEditOutcome::language())
        }
        CodeEdit::SetFileUri { file_uri } => {
            editor.file_uri = file_uri.clone();
            Ok(CodeEditOutcome::file_uri())
        }
    }
}

pub fn apply_code_operation(
    editor: &mut Editor,
    operation: &CodeOperation,
) -> Result<CodeEditOutcome, CodeEditError> {
    operation.validate_for_engine(CODE_ENGINE_ID)?;
    apply_code_edit(editor, &operation.edit)
}

pub fn replay_code_log(
    editor: &mut Editor,
    log: &CodeOperationLog,
) -> Result<Vec<CodeEditOutcome>, CodeEditError> {
    log.validate_for_engine(CODE_ENGINE_ID)?;

    let mut simulated_text = editor.buffer.to_string();
    let mut steps = Vec::with_capacity(log.operations.len());
    for operation in &log.operations {
        steps.push(plan_code_replay_step(&mut simulated_text, &operation.edit)?);
    }

    let mut outcomes = Vec::with_capacity(steps.len());
    for step in steps {
        outcomes.push(apply_code_replay_step(editor, step));
    }
    Ok(outcomes)
}

pub fn code_artifact(
    document_id: impl Into<String>,
    editor: &Editor,
    operation_log: CodeOperationLog,
) -> CodeArtifact {
    OperationArtifact::new(
        CODE_ENGINE_ID,
        document_id,
        CodeSnapshot::from_editor(editor),
        operation_log,
    )
}

pub fn restore_code_artifact(artifact: &CodeArtifact) -> Result<Editor, CodeEditError> {
    artifact.validate_for_engine(CODE_ENGINE_ID)?;
    let mut editor = artifact.snapshot.to_editor();
    replay_code_log(&mut editor, &artifact.operation_log)?;
    Ok(editor)
}

/// Build a shared Waraq maintenance plan for a code artifact operation tail.
pub fn plan_code_artifact_maintenance(
    artifact: &CodeArtifact,
    policy: CodeArtifactMaintenancePolicy,
) -> Result<CodeArtifactMaintenancePlan, CodeEditError> {
    Ok(plan_artifact_maintenance(artifact, policy, CODE_ENGINE_ID)?)
}

/// Fold older code operations into the snapshot and retain a replayable tail.
pub fn compact_code_artifact(
    artifact: &CodeArtifact,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
) -> Result<CodeArtifact, CodeEditError> {
    compact_artifact_with_replayed_prefix(
        artifact,
        retain_tail_operations,
        compacted_at_ms,
        CODE_ENGINE_ID,
        |snapshot, prefix_log| {
            let mut snapshot_editor = snapshot.to_editor();
            replay_code_log(&mut snapshot_editor, &prefix_log)?;
            Ok::<_, CodeEditError>(CodeSnapshot::from_editor(&snapshot_editor))
        },
    )
}

/// Compact a code artifact only when the shared maintenance policy says it is due.
pub fn maintain_code_artifact(
    artifact: &CodeArtifact,
    policy: CodeArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<CodeArtifact, CodeEditError> {
    Ok(maintain_code_artifact_with_outcome(artifact, policy, compacted_at_ms)?.artifact)
}

/// Maintain a code artifact and report whether compaction happened.
pub fn maintain_code_artifact_with_outcome(
    artifact: &CodeArtifact,
    policy: CodeArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<CodeArtifactMaintenanceOutcome, CodeEditError> {
    let plan = plan_code_artifact_maintenance(artifact, policy)?;
    maintain_artifact_with_plan_outcome(artifact, &plan, compacted_at_ms, compact_code_artifact)
}

pub trait CodeEditorOps {
    fn apply_code_edit(&mut self, edit: &CodeEdit) -> Result<CodeEditOutcome, CodeEditError>;
    fn apply_code_operation(
        &mut self,
        operation: &CodeOperation,
    ) -> Result<CodeEditOutcome, CodeEditError>;
    fn replay_code_log(
        &mut self,
        log: &CodeOperationLog,
    ) -> Result<Vec<CodeEditOutcome>, CodeEditError>;
}

impl CodeEditorOps for Editor {
    fn apply_code_edit(&mut self, edit: &CodeEdit) -> Result<CodeEditOutcome, CodeEditError> {
        apply_code_edit(self, edit)
    }

    fn apply_code_operation(
        &mut self,
        operation: &CodeOperation,
    ) -> Result<CodeEditOutcome, CodeEditError> {
        apply_code_operation(self, operation)
    }

    fn replay_code_log(
        &mut self,
        log: &CodeOperationLog,
    ) -> Result<Vec<CodeEditOutcome>, CodeEditError> {
        replay_code_log(self, log)
    }
}

#[derive(Debug, Clone)]
enum CodeReplayAction {
    Text(EditOp),
    TextBatch(Vec<EditOp>),
    SetLanguage(String),
    SetFileUri(String),
}

#[derive(Debug, Clone)]
struct CodeReplayStep {
    action: CodeReplayAction,
    outcome: CodeEditOutcome,
}

fn plan_code_replay_step(
    simulated_text: &mut String,
    edit: &CodeEdit,
) -> Result<CodeReplayStep, CodeEditError> {
    match edit {
        CodeEdit::InsertText { at, text } => {
            validate_offset(simulated_text, *at)?;
            simulated_text.insert_str(*at, text);
            Ok(CodeReplayStep {
                action: CodeReplayAction::Text(EditOp::insert(*at, text)),
                outcome: CodeEditOutcome::text(1),
            })
        }
        CodeEdit::DeleteRange { start, end } => {
            validate_range(simulated_text, *start, *end)?;
            simulated_text.replace_range(*start..*end, "");
            Ok(CodeReplayStep {
                action: CodeReplayAction::Text(EditOp::delete(*start, *end)),
                outcome: CodeEditOutcome::text(1),
            })
        }
        CodeEdit::ReplaceRange { start, end, text } => {
            validate_range(simulated_text, *start, *end)?;
            simulated_text.replace_range(*start..*end, text);
            Ok(CodeReplayStep {
                action: CodeReplayAction::Text(EditOp::replace(*start, *end, text)),
                outcome: CodeEditOutcome::text(1),
            })
        }
        CodeEdit::ApplyBatch { edits } => {
            let mut ops = Vec::with_capacity(edits.len());
            for edit in edits {
                ops.push(validate_and_simulate_text_edit(simulated_text, edit)?);
            }
            Ok(CodeReplayStep {
                action: CodeReplayAction::TextBatch(ops),
                outcome: CodeEditOutcome::text(edits.len()),
            })
        }
        CodeEdit::SetLanguage { language } => Ok(CodeReplayStep {
            action: CodeReplayAction::SetLanguage(language.clone()),
            outcome: CodeEditOutcome::language(),
        }),
        CodeEdit::SetFileUri { file_uri } => Ok(CodeReplayStep {
            action: CodeReplayAction::SetFileUri(file_uri.clone()),
            outcome: CodeEditOutcome::file_uri(),
        }),
    }
}

fn apply_code_replay_step(editor: &mut Editor, step: CodeReplayStep) -> CodeEditOutcome {
    match step.action {
        CodeReplayAction::Text(op) => {
            editor.apply(op);
        }
        CodeReplayAction::TextBatch(ops) => {
            editor.apply_batch(ops);
        }
        CodeReplayAction::SetLanguage(language) => {
            editor.set_language(&language);
        }
        CodeReplayAction::SetFileUri(file_uri) => {
            editor.file_uri = file_uri;
        }
    }
    step.outcome
}

fn validate_and_simulate_text_edit(
    current: &mut String,
    edit: &CodeTextEdit,
) -> Result<EditOp, CodeEditError> {
    match edit {
        CodeTextEdit::InsertText { at, text } => {
            validate_offset(current, *at)?;
            current.insert_str(*at, text);
            Ok(EditOp::insert(*at, text))
        }
        CodeTextEdit::DeleteRange { start, end } => {
            validate_range(current, *start, *end)?;
            current.replace_range(*start..*end, "");
            Ok(EditOp::Delete {
                range: Range::new(*start, *end),
            })
        }
        CodeTextEdit::ReplaceRange { start, end, text } => {
            validate_range(current, *start, *end)?;
            current.replace_range(*start..*end, text);
            Ok(EditOp::Replace {
                range: Range::new(*start, *end),
                text: text.clone(),
            })
        }
    }
}

fn validate_offset(text: &str, offset: usize) -> Result<(), CodeEditError> {
    if offset > text.len() {
        return Err(CodeEditError::InvalidOffset {
            offset,
            len_bytes: text.len(),
        });
    }
    if !text.is_char_boundary(offset) {
        return Err(CodeEditError::InvalidUtf8Boundary { offset });
    }
    Ok(())
}

fn validate_range(text: &str, start: usize, end: usize) -> Result<(), CodeEditError> {
    if start > end || end > text.len() {
        return Err(CodeEditError::InvalidRange {
            start,
            end,
            len_bytes: text.len(),
        });
    }
    validate_offset(text, start)?;
    validate_offset(text, end)?;
    Ok(())
}

impl From<&CodeTextEdit> for CodeEdit {
    fn from(edit: &CodeTextEdit) -> Self {
        match edit {
            CodeTextEdit::InsertText { at, text } => CodeEdit::InsertText {
                at: *at,
                text: text.clone(),
            },
            CodeTextEdit::DeleteRange { start, end } => CodeEdit::DeleteRange {
                start: *start,
                end: *end,
            },
            CodeTextEdit::ReplaceRange { start, end, text } => CodeEdit::ReplaceRange {
                start: *start,
                end: *end,
                text: text.clone(),
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use waraq_core::{
        artifact_compaction_info, domain_artifact_test_profile,
        validate_artifact_compaction_harness, validate_artifact_conformance,
        validate_artifact_lifecycle_harness, validate_artifact_lifecycle_profile_report,
        validate_artifact_replay_harness, validate_domain_artifact_test_profile_report,
        ArtifactMaintenanceAction, OperationLogError, REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS,
        REQUIRED_ARTIFACT_CONFORMANCE_CHECKS, REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
    };

    #[derive(Debug, Clone, PartialEq, Eq)]
    struct CodeReplayState {
        text: String,
        language: String,
        file_uri: String,
    }

    impl CodeReplayState {
        fn from_editor(editor: &Editor) -> Self {
            Self {
                text: editor.buffer.to_string(),
                language: editor.language.clone(),
                file_uri: editor.file_uri.clone(),
            }
        }

        fn to_editor(&self) -> Editor {
            let mut editor = Editor::from_str(&self.text);
            editor.file_uri = self.file_uri.clone();
            if !self.language.is_empty() {
                editor.set_language(&self.language);
            }
            editor
        }
    }

    fn insert_op(id: &str, sequence: u64, at: usize, text: &str) -> CodeOperation {
        code_operation(
            id,
            "file:///main.rs",
            "actor-1",
            sequence,
            sequence * 100,
            CodeEdit::InsertText {
                at,
                text: text.into(),
            },
        )
    }

    #[test]
    fn code_operation_roundtrips_and_applies() {
        let operation = insert_op("op-1", 1, 0, "fn main() {}");
        let json = operation.to_json().unwrap();
        let restored = CodeOperation::from_json(&json).unwrap();

        let mut editor = Editor::new();
        let outcome = editor.apply_code_operation(&restored).unwrap();

        assert_eq!(outcome, CodeEditOutcome::text(1));
        assert_eq!(editor.buffer.to_string(), "fn main() {}");
    }

    #[test]
    fn code_log_replay_rebuilds_editor_state() {
        let mut log = CodeOperationLog::new();
        log.push_checked(insert_op("op-1", 1, 0, "let x = 1;\n"), CODE_ENGINE_ID)
            .unwrap();
        log.push_checked(
            code_operation(
                "op-2",
                "file:///main.rs",
                "actor-1",
                2,
                200,
                CodeEdit::ReplaceRange {
                    start: 8,
                    end: 9,
                    text: "2".into(),
                },
            ),
            CODE_ENGINE_ID,
        )
        .unwrap();
        log.push_checked(
            code_operation(
                "op-3",
                "file:///main.rs",
                "actor-1",
                3,
                300,
                CodeEdit::SetLanguage {
                    language: "rust".into(),
                },
            ),
            CODE_ENGINE_ID,
        )
        .unwrap();

        let mut editor = Editor::new();
        let outcomes = replay_code_log(&mut editor, &log).unwrap();

        assert_eq!(outcomes.len(), 3);
        assert_eq!(editor.buffer.to_string(), "let x = 2;\n");
        assert_eq!(editor.language, "rust");
    }

    #[test]
    fn replay_rejects_wrong_engine_before_mutating_editor() {
        let mut log = CodeOperationLog::new();
        log.push(OperationEnvelope::new(
            "sheet",
            "op-1",
            "file:///main.rs",
            "actor-1",
            1,
            100,
            CodeEdit::InsertText {
                at: 0,
                text: "bad".into(),
            },
        ));

        let mut editor = Editor::from_str("original");
        let err = replay_code_log(&mut editor, &log).unwrap_err();

        assert_eq!(
            err,
            CodeEditError::OperationLog(OperationLogError::WrongEngine {
                expected: CODE_ENGINE_ID.into(),
                actual: "sheet".into(),
                operation_id: "op-1".into(),
            })
        );
        assert_eq!(editor.buffer.to_string(), "original");
    }

    #[test]
    fn replay_rejects_invalid_tail_without_partial_mutation() {
        let mut log = CodeOperationLog::new();
        log.push_checked(insert_op("op-1", 1, 11, "!"), CODE_ENGINE_ID)
            .unwrap();
        log.push_checked(
            code_operation(
                "op-2",
                "file:///main.rs",
                "actor-1",
                2,
                200,
                CodeEdit::ReplaceRange {
                    start: 999,
                    end: 1000,
                    text: "bad".into(),
                },
            ),
            CODE_ENGINE_ID,
        )
        .unwrap();

        let mut editor = Editor::from_str("let x = 1;\n");
        editor.file_uri = "file:///main.rs".into();

        let err = replay_code_log(&mut editor, &log).unwrap_err();

        assert_eq!(
            err,
            CodeEditError::InvalidRange {
                start: 999,
                end: 1000,
                len_bytes: 12,
            }
        );
        assert_eq!(editor.buffer.to_string(), "let x = 1;\n");
    }

    #[test]
    fn batch_validates_against_evolving_text_state() {
        let mut editor = Editor::new();
        let outcome = editor
            .apply_code_edit(&CodeEdit::ApplyBatch {
                edits: vec![
                    CodeTextEdit::InsertText {
                        at: 0,
                        text: "ab".into(),
                    },
                    CodeTextEdit::ReplaceRange {
                        start: 1,
                        end: 2,
                        text: "c".into(),
                    },
                ],
            })
            .unwrap();

        assert_eq!(outcome, CodeEditOutcome::text(2));
        assert_eq!(editor.buffer.to_string(), "ac");
    }

    #[test]
    fn text_edit_rejects_invalid_utf8_boundary() {
        let mut editor = Editor::from_str("é");
        let err = editor
            .apply_code_edit(&CodeEdit::DeleteRange { start: 1, end: 2 })
            .unwrap_err();

        assert_eq!(err, CodeEditError::InvalidUtf8Boundary { offset: 1 });
        assert_eq!(editor.buffer.to_string(), "é");
    }

    #[test]
    fn code_artifact_roundtrips_and_restores_snapshot_plus_tail_log() {
        let mut snapshot_editor = Editor::from_str("let x = 1;\n");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new();
        tail_log
            .push_checked(
                code_operation(
                    "op-2",
                    "file:///main.rs",
                    "actor-1",
                    2,
                    200,
                    CodeEdit::ReplaceRange {
                        start: 8,
                        end: 9,
                        text: "2".into(),
                    },
                ),
                CODE_ENGINE_ID,
            )
            .unwrap();

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);
        let json = artifact.to_json().unwrap();
        let restored_artifact = CodeArtifact::from_json(&json).unwrap();
        let restored_editor = restore_code_artifact(&restored_artifact).unwrap();

        assert_eq!(restored_editor.buffer.to_string(), "let x = 2;\n");
        assert_eq!(restored_editor.language, "rust");
        assert_eq!(restored_editor.file_uri, "file:///main.rs");
    }

    #[test]
    fn code_artifact_satisfies_shared_conformance_checklist() {
        let mut snapshot_editor = Editor::from_str("let x = 1;\n");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new();
        tail_log
            .push_checked(
                code_operation(
                    "op-2",
                    "file:///main.rs",
                    "actor-1",
                    2,
                    200,
                    CodeEdit::ReplaceRange {
                        start: 8,
                        end: 9,
                        text: "2".into(),
                    },
                ),
                CODE_ENGINE_ID,
            )
            .unwrap();

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);
        let report = validate_artifact_conformance(CODE_ENGINE_ID, &artifact).unwrap();

        assert_eq!(report.engine_id, CODE_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.rs");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
    }

    #[test]
    fn code_artifact_declares_shared_test_profile() {
        let profile = domain_artifact_test_profile(CODE_ENGINE_ID);

        assert_eq!(profile.engine_id, CODE_ENGINE_ID);
        let report = validate_domain_artifact_test_profile_report(&profile).unwrap();
        assert_eq!(report.required_shared_check_count, 22);
        assert_eq!(report.lifecycle_harness_shared_check_count, Some(22));
    }

    #[test]
    fn code_artifact_maintenance_plan_uses_shared_policy() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new();
        tail_log
            .push_checked(insert_op("op-1", 1, 0, "a"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-2", 2, 1, "b"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-3", 3, 2, "c"), CODE_ENGINE_ID)
            .unwrap();

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);
        let plan =
            plan_code_artifact_maintenance(&artifact, CodeArtifactMaintenancePolicy::new(2, 1))
                .unwrap();

        assert_eq!(plan.operation_count, 3);
        assert_eq!(plan.max_tail_operations, 2);
        assert_eq!(plan.retain_tail_operations, 1);
        assert_eq!(plan.compactable_operation_count, 2);
        assert!(plan.should_compact);
        assert_eq!(plan.first_sequence, Some(1));
        assert_eq!(plan.last_sequence, Some(3));
        assert_eq!(plan.last_operation_id.as_deref(), Some("op-3"));
    }

    #[test]
    fn compact_code_artifact_folds_prefix_and_retains_tail() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new().with_metadata_text("source", "keyboard");
        tail_log
            .push_checked(insert_op("op-1", 1, 0, "a"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-2", 2, 1, "b"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-3", 3, 2, "c"), CODE_ENGINE_ID)
            .unwrap();

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log)
            .with_metadata_text("owner", "code-test");
        let compacted = compact_code_artifact(&artifact, 1, 1234).unwrap();
        let restored_editor = restore_code_artifact(&compacted).unwrap();

        assert_eq!(compacted.snapshot.text, "ab");
        assert_eq!(compacted.snapshot.language, "rust");
        assert_eq!(compacted.snapshot.file_uri, "file:///main.rs");
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
        assert_eq!(compacted.operation_log.metadata["source"], "keyboard");
        assert_eq!(compacted.metadata["owner"], "code-test");
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.compacted_operation_count, 2);
        assert_eq!(info.compacted_through_operation_id.as_deref(), Some("op-2"));
        assert_eq!(info.compacted_at_ms, 1234);
        assert_eq!(restored_editor.buffer.to_string(), "abc");
        assert_eq!(restored_editor.language, "rust");
        assert_eq!(restored_editor.file_uri, "file:///main.rs");
    }

    #[test]
    fn code_artifact_satisfies_shared_compaction_harness() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new().with_metadata_text("source", "keyboard");
        tail_log
            .push_checked(insert_op("op-1", 1, 0, "a"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-2", 2, 1, "b"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-3", 3, 2, "c"), CODE_ENGINE_ID)
            .unwrap();
        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);

        let report = validate_artifact_compaction_harness(
            CODE_ENGINE_ID,
            &artifact,
            1,
            1234,
            |artifact| {
                restore_code_artifact(artifact).map(|editor| CodeReplayState::from_editor(&editor))
            },
            compact_code_artifact,
            maintain_code_artifact,
        )
        .unwrap();

        assert_eq!(report.engine_id, CODE_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.rs");
        assert_eq!(report.source_operation_count, 3);
        assert_eq!(report.compacted_operation_count, 2);
        assert_eq!(report.retained_operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
    }

    #[test]
    fn code_artifact_satisfies_shared_lifecycle_harness() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new().with_metadata_text("source", "keyboard");
        tail_log
            .push_checked(insert_op("op-1", 1, 0, "a"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-2", 2, 1, "b"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-3", 3, 2, "c"), CODE_ENGINE_ID)
            .unwrap();
        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);

        let mut invalid_log = CodeOperationLog::new();
        invalid_log
            .push_checked(insert_op("op-invalid-prefix", 1, 0, "!"), CODE_ENGINE_ID)
            .unwrap();
        invalid_log
            .push_checked(
                code_operation(
                    "op-invalid",
                    "file:///main.rs",
                    "actor-1",
                    2,
                    200,
                    CodeEdit::InsertText {
                        at: 999,
                        text: "bad".into(),
                    },
                ),
                CODE_ENGINE_ID,
            )
            .unwrap();

        let report = validate_artifact_lifecycle_harness(
            CODE_ENGINE_ID,
            &artifact,
            &CodeReplayState {
                text: "abc".into(),
                language: "rust".into(),
                file_uri: "file:///main.rs".into(),
            },
            &CodeReplayState {
                text: String::new(),
                language: "rust".into(),
                file_uri: "file:///main.rs".into(),
            },
            &invalid_log,
            1,
            1234,
            |artifact| {
                restore_code_artifact(artifact).map(|editor| CodeReplayState::from_editor(&editor))
            },
            |state, log| {
                let mut editor = state.to_editor();
                let result = replay_code_log(&mut editor, log).map(|_| ());
                *state = CodeReplayState::from_editor(&editor);
                result
            },
            compact_code_artifact,
            maintain_code_artifact,
        )
        .unwrap();

        let validation_report = validate_artifact_lifecycle_profile_report(
            &domain_artifact_test_profile(CODE_ENGINE_ID),
            &report,
        )
        .unwrap();
        assert_eq!(validation_report.completed_shared_check_count, 22);
        assert_eq!(validation_report.document_id, "file:///main.rs");
    }

    #[test]
    fn maintain_code_artifact_compacts_only_when_policy_requires_it() {
        let mut snapshot_editor = Editor::from_str("");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new();
        tail_log
            .push_checked(insert_op("op-1", 1, 0, "a"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-2", 2, 1, "b"), CODE_ENGINE_ID)
            .unwrap();
        tail_log
            .push_checked(insert_op("op-3", 3, 2, "c"), CODE_ENGINE_ID)
            .unwrap();

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);

        let unchanged =
            maintain_code_artifact(&artifact, CodeArtifactMaintenancePolicy::new(10, 1), 1234)
                .unwrap();
        let compacted =
            maintain_code_artifact(&artifact, CodeArtifactMaintenancePolicy::new(2, 1), 1234)
                .unwrap();
        let skipped_outcome = maintain_code_artifact_with_outcome(
            &artifact,
            CodeArtifactMaintenancePolicy::new(10, 1),
            1234,
        )
        .unwrap();
        let compacted_outcome = maintain_code_artifact_with_outcome(
            &artifact,
            CodeArtifactMaintenancePolicy::new(2, 1),
            1234,
        )
        .unwrap();

        assert_eq!(unchanged, artifact);
        assert_eq!(skipped_outcome.action, ArtifactMaintenanceAction::Preserved);
        assert_eq!(skipped_outcome.artifact, artifact);
        assert_eq!(skipped_outcome.compaction_info, None);
        assert_eq!(compacted.snapshot.text, "ab");
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
        assert_eq!(
            compacted_outcome.action,
            ArtifactMaintenanceAction::Compacted
        );
        assert_eq!(compacted_outcome.plan.compactable_operation_count, 2);
        assert_eq!(compacted_outcome.artifact.snapshot.text, "ab");
        assert_eq!(
            compacted_outcome
                .compaction_info
                .as_ref()
                .map(|info| info.retained_operation_count),
            Some(1)
        );
        assert_eq!(
            artifact_compaction_info(&compacted)
                .unwrap()
                .unwrap()
                .retained_operation_count,
            1
        );
    }

    #[test]
    fn code_artifact_satisfies_shared_replay_harness() {
        let mut snapshot_editor = Editor::from_str("let x = 1;\n");
        snapshot_editor.set_language("rust");
        snapshot_editor.file_uri = "file:///main.rs".into();

        let mut tail_log = CodeOperationLog::new();
        tail_log
            .push_checked(
                code_operation(
                    "op-2",
                    "file:///main.rs",
                    "actor-1",
                    2,
                    200,
                    CodeEdit::ReplaceRange {
                        start: 8,
                        end: 9,
                        text: "2".into(),
                    },
                ),
                CODE_ENGINE_ID,
            )
            .unwrap();
        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);

        let mut invalid_log = CodeOperationLog::new();
        invalid_log
            .push_checked(insert_op("op-invalid-prefix", 1, 11, "!"), CODE_ENGINE_ID)
            .unwrap();
        invalid_log
            .push_checked(
                code_operation(
                    "op-invalid",
                    "file:///main.rs",
                    "actor-1",
                    2,
                    200,
                    CodeEdit::InsertText {
                        at: 999,
                        text: "bad".into(),
                    },
                ),
                CODE_ENGINE_ID,
            )
            .unwrap();

        let report = validate_artifact_replay_harness(
            CODE_ENGINE_ID,
            &artifact,
            &CodeReplayState {
                text: "let x = 2;\n".into(),
                language: "rust".into(),
                file_uri: "file:///main.rs".into(),
            },
            &CodeReplayState {
                text: "let x = 1;\n".into(),
                language: "rust".into(),
                file_uri: "file:///main.rs".into(),
            },
            &invalid_log,
            |artifact| {
                restore_code_artifact(artifact).map(|editor| CodeReplayState::from_editor(&editor))
            },
            |state, log| {
                let mut editor = state.to_editor();
                let result = replay_code_log(&mut editor, log).map(|_| ());
                *state = CodeReplayState::from_editor(&editor);
                result
            },
        )
        .unwrap();

        assert_eq!(report.engine_id, CODE_ENGINE_ID);
        assert_eq!(report.document_id, "file:///main.rs");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
    }

    #[test]
    fn code_artifact_rejects_operation_for_another_document() {
        let snapshot_editor = Editor::from_str("let x = 1;\n");
        let mut tail_log = CodeOperationLog::new();
        tail_log.push(code_operation(
            "op-2",
            "file:///other.rs",
            "actor-1",
            2,
            200,
            CodeEdit::InsertText {
                at: 0,
                text: "bad".into(),
            },
        ));

        let artifact = code_artifact("file:///main.rs", &snapshot_editor, tail_log);
        let err = match restore_code_artifact(&artifact) {
            Ok(_) => panic!("expected document mismatch error"),
            Err(err) => err,
        };

        assert_eq!(
            err,
            CodeEditError::OperationLog(OperationLogError::OperationDocumentMismatch {
                operation_id: "op-2".into(),
                expected: "file:///main.rs".into(),
                actual: "file:///other.rs".into(),
            })
        );
    }
}
