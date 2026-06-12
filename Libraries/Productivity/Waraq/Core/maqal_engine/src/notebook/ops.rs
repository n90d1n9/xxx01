use super::{CellId, CellType, IpynbDocument, NotebookDocument};
use serde::{Deserialize, Serialize};
use waraq_core::{
    compact_artifact_with_replayed_prefix, maintain_artifact_with_plan_outcome,
    plan_artifact_maintenance, ArtifactCompactionInfo, ArtifactMaintenanceOutcome,
    ArtifactMaintenancePlan, ArtifactMaintenancePolicy, OperationArtifact, OperationEnvelope,
    OperationLog, OperationLogError,
};

pub const MAQAL_ENGINE_ID: &str = "maqal";

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum NotebookEdit {
    InsertCell {
        index: usize,
        cell_id: String,
        cell_type: CellType,
        source: String,
    },
    DeleteCell {
        cell_id: String,
    },
    MoveCell {
        cell_id: String,
        to_index: usize,
    },
    SetCellSource {
        cell_id: String,
        source: String,
    },
    ChangeCellType {
        cell_id: String,
        cell_type: CellType,
    },
    ClearCellOutputs {
        cell_id: String,
    },
    ClearAllOutputs,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct NotebookEditOutcome {
    pub changed_cells: Vec<String>,
    pub active_cell: usize,
    pub changed_structure: bool,
    pub changed_source: bool,
    pub changed_type: bool,
    pub changed_outputs: bool,
}

impl NotebookEditOutcome {
    fn structure(cell_id: impl Into<String>, active_cell: usize) -> Self {
        Self {
            changed_cells: vec![cell_id.into()],
            active_cell,
            changed_structure: true,
            changed_source: false,
            changed_type: false,
            changed_outputs: false,
        }
    }

    fn source(cell_id: impl Into<String>, active_cell: usize) -> Self {
        Self {
            changed_cells: vec![cell_id.into()],
            active_cell,
            changed_structure: false,
            changed_source: true,
            changed_type: false,
            changed_outputs: true,
        }
    }

    fn cell_type(cell_id: impl Into<String>, active_cell: usize) -> Self {
        Self {
            changed_cells: vec![cell_id.into()],
            active_cell,
            changed_structure: false,
            changed_source: false,
            changed_type: true,
            changed_outputs: true,
        }
    }

    fn outputs(cell_ids: Vec<String>, active_cell: usize) -> Self {
        Self {
            changed_cells: cell_ids,
            active_cell,
            changed_structure: false,
            changed_source: false,
            changed_type: false,
            changed_outputs: true,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum NotebookEditError {
    OperationLog(OperationLogError),
    CellNotFound {
        cell_id: String,
    },
    InvalidCellIndex {
        index: usize,
        cell_count: usize,
    },
    InvalidMove {
        cell_id: String,
        to_index: usize,
        cell_count: usize,
    },
    CannotDeleteLastCell {
        cell_id: String,
    },
}

impl From<OperationLogError> for NotebookEditError {
    fn from(error: OperationLogError) -> Self {
        Self::OperationLog(error)
    }
}

pub type NotebookOperation = OperationEnvelope<NotebookEdit>;
pub type NotebookOperationLog = OperationLog<NotebookEdit>;

/// Persistable notebook artifact composed from an ipynb snapshot and typed cell edit log.
pub type NotebookArtifact = OperationArtifact<IpynbDocument, NotebookEdit>;

/// Notebook-engine alias for shared artifact compaction metadata.
pub type NotebookArtifactCompactionInfo = ArtifactCompactionInfo;

/// Notebook-engine alias for the shared artifact maintenance policy.
pub type NotebookArtifactMaintenancePolicy = ArtifactMaintenancePolicy;

/// Notebook-engine alias for the shared artifact maintenance plan.
pub type NotebookArtifactMaintenancePlan = ArtifactMaintenancePlan;

/// Notebook-engine alias for the shared artifact maintenance outcome.
pub type NotebookArtifactMaintenanceOutcome =
    ArtifactMaintenanceOutcome<IpynbDocument, NotebookEdit>;

pub fn notebook_operation(
    operation_id: impl Into<String>,
    document_id: impl Into<String>,
    actor_id: impl Into<String>,
    sequence: u64,
    timestamp_ms: u64,
    edit: NotebookEdit,
) -> NotebookOperation {
    OperationEnvelope::new(
        MAQAL_ENGINE_ID,
        operation_id,
        document_id,
        actor_id,
        sequence,
        timestamp_ms,
        edit,
    )
}

pub fn apply_notebook_edit(
    notebook: &mut NotebookDocument,
    edit: &NotebookEdit,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    match edit {
        NotebookEdit::InsertCell {
            index,
            cell_id,
            cell_type,
            source,
        } => insert_cell_at(notebook, *index, cell_id, *cell_type, source),
        NotebookEdit::DeleteCell { cell_id } => delete_cell(notebook, cell_id),
        NotebookEdit::MoveCell { cell_id, to_index } => move_cell(notebook, cell_id, *to_index),
        NotebookEdit::SetCellSource { cell_id, source } => {
            set_cell_source(notebook, cell_id, source)
        }
        NotebookEdit::ChangeCellType { cell_id, cell_type } => {
            change_cell_type(notebook, cell_id, *cell_type)
        }
        NotebookEdit::ClearCellOutputs { cell_id } => clear_cell_outputs(notebook, cell_id),
        NotebookEdit::ClearAllOutputs => {
            let ids = notebook
                .cells()
                .iter()
                .map(|cell| cell.id.0.clone())
                .collect();
            notebook.clear_all_outputs();
            Ok(NotebookEditOutcome::outputs(ids, notebook.active_cell))
        }
    }
}

pub fn apply_notebook_operation(
    notebook: &mut NotebookDocument,
    operation: &NotebookOperation,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    operation.validate_for_engine(MAQAL_ENGINE_ID)?;
    apply_notebook_edit(notebook, &operation.edit)
}

pub fn replay_notebook_log(
    notebook: &mut NotebookDocument,
    log: &NotebookOperationLog,
) -> Result<Vec<NotebookEditOutcome>, NotebookEditError> {
    log.validate_for_engine(MAQAL_ENGINE_ID)?;

    let mut staged = notebook.clone();
    let outcomes = log
        .operations
        .iter()
        .map(|operation| apply_notebook_edit(&mut staged, &operation.edit))
        .collect::<Result<Vec<_>, _>>()?;

    *notebook = staged;
    Ok(outcomes)
}

pub fn notebook_artifact(
    document_id: impl Into<String>,
    notebook: &NotebookDocument,
    operation_log: NotebookOperationLog,
) -> NotebookArtifact {
    OperationArtifact::new(
        MAQAL_ENGINE_ID,
        document_id,
        IpynbDocument::from_notebook(notebook),
        operation_log,
    )
}

pub fn restore_notebook_artifact(
    artifact: &NotebookArtifact,
) -> Result<NotebookDocument, NotebookEditError> {
    artifact.validate_for_engine(MAQAL_ENGINE_ID)?;
    let mut notebook = artifact.snapshot.to_notebook();
    notebook.uri = artifact.document_id.clone();
    replay_notebook_log(&mut notebook, &artifact.operation_log)?;
    Ok(notebook)
}

/// Build a shared Waraq maintenance plan for a notebook artifact operation tail.
pub fn plan_notebook_artifact_maintenance(
    artifact: &NotebookArtifact,
    policy: NotebookArtifactMaintenancePolicy,
) -> Result<NotebookArtifactMaintenancePlan, NotebookEditError> {
    Ok(plan_artifact_maintenance(
        artifact,
        policy,
        MAQAL_ENGINE_ID,
    )?)
}

/// Fold older notebook operations into the snapshot and retain a replayable tail.
pub fn compact_notebook_artifact(
    artifact: &NotebookArtifact,
    retain_tail_operations: usize,
    compacted_at_ms: u64,
) -> Result<NotebookArtifact, NotebookEditError> {
    compact_artifact_with_replayed_prefix(
        artifact,
        retain_tail_operations,
        compacted_at_ms,
        MAQAL_ENGINE_ID,
        |snapshot, prefix_log| {
            let mut snapshot_notebook = snapshot.to_notebook();
            snapshot_notebook.uri = artifact.document_id.clone();
            replay_notebook_log(&mut snapshot_notebook, &prefix_log)?;
            Ok::<_, NotebookEditError>(IpynbDocument::from_notebook(&snapshot_notebook))
        },
    )
}

/// Compact a notebook artifact only when the shared maintenance policy says it is due.
pub fn maintain_notebook_artifact(
    artifact: &NotebookArtifact,
    policy: NotebookArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<NotebookArtifact, NotebookEditError> {
    Ok(maintain_notebook_artifact_with_outcome(artifact, policy, compacted_at_ms)?.artifact)
}

/// Maintain a notebook artifact and report whether compaction happened.
pub fn maintain_notebook_artifact_with_outcome(
    artifact: &NotebookArtifact,
    policy: NotebookArtifactMaintenancePolicy,
    compacted_at_ms: u64,
) -> Result<NotebookArtifactMaintenanceOutcome, NotebookEditError> {
    let plan = plan_notebook_artifact_maintenance(artifact, policy)?;
    maintain_artifact_with_plan_outcome(artifact, &plan, compacted_at_ms, compact_notebook_artifact)
}

pub trait NotebookDocumentOps {
    fn apply_notebook_edit(
        &mut self,
        edit: &NotebookEdit,
    ) -> Result<NotebookEditOutcome, NotebookEditError>;

    fn apply_notebook_operation(
        &mut self,
        operation: &NotebookOperation,
    ) -> Result<NotebookEditOutcome, NotebookEditError>;

    fn replay_notebook_log(
        &mut self,
        log: &NotebookOperationLog,
    ) -> Result<Vec<NotebookEditOutcome>, NotebookEditError>;
}

impl NotebookDocumentOps for NotebookDocument {
    fn apply_notebook_edit(
        &mut self,
        edit: &NotebookEdit,
    ) -> Result<NotebookEditOutcome, NotebookEditError> {
        apply_notebook_edit(self, edit)
    }

    fn apply_notebook_operation(
        &mut self,
        operation: &NotebookOperation,
    ) -> Result<NotebookEditOutcome, NotebookEditError> {
        apply_notebook_operation(self, operation)
    }

    fn replay_notebook_log(
        &mut self,
        log: &NotebookOperationLog,
    ) -> Result<Vec<NotebookEditOutcome>, NotebookEditError> {
        replay_notebook_log(self, log)
    }
}

fn insert_cell_at(
    notebook: &mut NotebookDocument,
    index: usize,
    cell_id: &str,
    cell_type: CellType,
    source: &str,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let cell_count = notebook.cell_count();
    if index > cell_count {
        return Err(NotebookEditError::InvalidCellIndex { index, cell_count });
    }

    if index == 0 {
        notebook.focus_first_cell();
        notebook.insert_cell_above(cell_type);
    } else {
        notebook.focus_cell_at(index - 1);
        notebook.insert_cell_below(cell_type);
    }

    let cell_count = notebook.cell_count();
    let inserted = notebook
        .cells_mut()
        .get_mut(index)
        .ok_or(NotebookEditError::InvalidCellIndex { index, cell_count })?;
    inserted.id = CellId::from_str(cell_id);
    inserted.set_source(source);
    notebook.active_cell = index;
    notebook.mark_dirty();

    Ok(NotebookEditOutcome::structure(
        cell_id,
        notebook.active_cell,
    ))
}

fn delete_cell(
    notebook: &mut NotebookDocument,
    cell_id: &str,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let index = index_of(notebook, cell_id)?;
    notebook.focus_cell_at(index);
    if !notebook.delete_active_cell() {
        return Err(NotebookEditError::CannotDeleteLastCell {
            cell_id: cell_id.to_owned(),
        });
    }

    Ok(NotebookEditOutcome::structure(
        cell_id,
        notebook.active_cell,
    ))
}

fn move_cell(
    notebook: &mut NotebookDocument,
    cell_id: &str,
    to_index: usize,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let cell_count = notebook.cell_count();
    if to_index >= cell_count {
        return Err(NotebookEditError::InvalidMove {
            cell_id: cell_id.to_owned(),
            to_index,
            cell_count,
        });
    }

    let from_index = index_of(notebook, cell_id)?;
    notebook.focus_cell_at(from_index);
    while notebook.active_cell > to_index {
        notebook.move_cell_up();
    }
    while notebook.active_cell < to_index {
        notebook.move_cell_down();
    }

    Ok(NotebookEditOutcome::structure(
        cell_id,
        notebook.active_cell,
    ))
}

fn set_cell_source(
    notebook: &mut NotebookDocument,
    cell_id: &str,
    source: &str,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let index = index_of(notebook, cell_id)?;
    let cell = notebook
        .cell_by_id_mut(&CellId::from_str(cell_id))
        .ok_or_else(|| NotebookEditError::CellNotFound {
            cell_id: cell_id.to_owned(),
        })?;
    cell.set_source(source);
    notebook.mark_dirty();

    Ok(NotebookEditOutcome::source(cell_id, index))
}

fn change_cell_type(
    notebook: &mut NotebookDocument,
    cell_id: &str,
    cell_type: CellType,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let index = index_of(notebook, cell_id)?;
    notebook.focus_cell_at(index);
    notebook.change_cell_type(cell_type);

    Ok(NotebookEditOutcome::cell_type(
        cell_id,
        notebook.active_cell,
    ))
}

fn clear_cell_outputs(
    notebook: &mut NotebookDocument,
    cell_id: &str,
) -> Result<NotebookEditOutcome, NotebookEditError> {
    let index = index_of(notebook, cell_id)?;
    let cell = notebook
        .cell_by_id_mut(&CellId::from_str(cell_id))
        .ok_or_else(|| NotebookEditError::CellNotFound {
            cell_id: cell_id.to_owned(),
        })?;
    cell.clear_outputs();
    notebook.mark_dirty();

    Ok(NotebookEditOutcome::outputs(
        vec![cell_id.to_owned()],
        index,
    ))
}

fn index_of(notebook: &NotebookDocument, cell_id: &str) -> Result<usize, NotebookEditError> {
    notebook
        .index_of(&CellId::from_str(cell_id))
        .ok_or_else(|| NotebookEditError::CellNotFound {
            cell_id: cell_id.to_owned(),
        })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::notebook::output::{CellOutput, StreamOutput};
    use waraq_core::{
        artifact_compaction_info, domain_artifact_test_profile,
        validate_artifact_compaction_harness, validate_artifact_conformance,
        validate_artifact_lifecycle_harness, validate_artifact_lifecycle_profile_report,
        validate_artifact_replay_harness, validate_domain_artifact_test_profile_report,
        ArtifactMaintenanceAction, OperationLogError, ARTIFACT_COMPACTION_METADATA_KEY,
        REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS, REQUIRED_ARTIFACT_CONFORMANCE_CHECKS,
        REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
    };

    #[derive(Debug, Clone, PartialEq, Eq)]
    struct NotebookReplayState {
        uri: String,
        active_cell: usize,
        dirty: bool,
        cells: Vec<(String, CellType, String)>,
    }

    impl NotebookReplayState {
        fn from_notebook(notebook: &NotebookDocument) -> Self {
            Self {
                uri: notebook.uri.clone(),
                active_cell: notebook.active_cell,
                dirty: notebook.dirty,
                cells: notebook
                    .cells()
                    .iter()
                    .map(|cell| (cell.id.0.clone(), cell.cell_type, cell.source()))
                    .collect(),
            }
        }

        fn to_notebook(&self) -> NotebookDocument {
            let mut notebook = NotebookDocument::new("python").with_uri(&self.uri);
            for (index, (cell_id, cell_type, source)) in self.cells.iter().enumerate() {
                if index > 0 {
                    notebook.focus_cell_at(index - 1);
                    notebook.insert_cell_below(*cell_type);
                }
                let cell = &mut notebook.cells_mut()[index];
                cell.id = CellId::from_str(cell_id);
                cell.cell_type = *cell_type;
                cell.set_source(source);
            }
            notebook.active_cell = self
                .active_cell
                .min(notebook.cell_count().saturating_sub(1));
            notebook.dirty = self.dirty;
            notebook
        }
    }

    fn operation(id: &str, sequence: u64, edit: NotebookEdit) -> NotebookOperation {
        notebook_operation(
            id,
            "notebook://main",
            "actor-1",
            sequence,
            sequence * 100,
            edit,
        )
    }

    fn persisted_notebook_state(
        notebook: &NotebookDocument,
    ) -> (String, Vec<(String, CellType, String)>) {
        (
            notebook.uri.clone(),
            notebook
                .cells()
                .iter()
                .map(|cell| (cell.id.0.clone(), cell.cell_type, cell.source()))
                .collect(),
        )
    }

    #[test]
    fn notebook_operation_roundtrips_and_applies() {
        let mut notebook = NotebookDocument::new("python");
        let initial_id = notebook.cells()[0].id.0.clone();
        let operation = operation(
            "op-1",
            1,
            NotebookEdit::SetCellSource {
                cell_id: initial_id.clone(),
                source: "x = 42".into(),
            },
        );

        let json = operation.to_json().unwrap();
        let restored = NotebookOperation::from_json(&json).unwrap();
        let outcome = notebook.apply_notebook_operation(&restored).unwrap();

        assert_eq!(outcome.changed_cells, vec![initial_id]);
        assert!(outcome.changed_source);
        assert_eq!(notebook.cells()[0].source(), "x = 42");
    }

    #[test]
    fn notebook_log_replay_rebuilds_structure() {
        let mut log = NotebookOperationLog::new();
        log.push_checked(
            operation(
                "op-1",
                1,
                NotebookEdit::InsertCell {
                    index: 1,
                    cell_id: "code-1".into(),
                    cell_type: CellType::Code,
                    source: "x = 1".into(),
                },
            ),
            MAQAL_ENGINE_ID,
        )
        .unwrap();
        log.push_checked(
            operation(
                "op-2",
                2,
                NotebookEdit::InsertCell {
                    index: 2,
                    cell_id: "md-1".into(),
                    cell_type: CellType::Markdown,
                    source: "# Notes".into(),
                },
            ),
            MAQAL_ENGINE_ID,
        )
        .unwrap();
        log.push_checked(
            operation(
                "op-3",
                3,
                NotebookEdit::MoveCell {
                    cell_id: "md-1".into(),
                    to_index: 1,
                },
            ),
            MAQAL_ENGINE_ID,
        )
        .unwrap();
        log.push_checked(
            operation(
                "op-4",
                4,
                NotebookEdit::SetCellSource {
                    cell_id: "code-1".into(),
                    source: "x = 2".into(),
                },
            ),
            MAQAL_ENGINE_ID,
        )
        .unwrap();

        let mut notebook = NotebookDocument::new("python");
        let outcomes = replay_notebook_log(&mut notebook, &log).unwrap();

        assert_eq!(outcomes.len(), 4);
        assert_eq!(notebook.cell_count(), 3);
        assert_eq!(notebook.cells()[1].id.0, "md-1");
        assert_eq!(notebook.cells()[1].cell_type, CellType::Markdown);
        assert_eq!(notebook.cells()[1].source(), "# Notes");
        assert_eq!(notebook.cells()[2].id.0, "code-1");
        assert_eq!(notebook.cells()[2].source(), "x = 2");
    }

    #[test]
    fn replay_rejects_wrong_engine_before_mutating_notebook() {
        let mut log = NotebookOperationLog::new();
        log.push(OperationEnvelope::new(
            "code",
            "op-1",
            "notebook://main",
            "actor-1",
            1,
            100,
            NotebookEdit::InsertCell {
                index: 1,
                cell_id: "bad".into(),
                cell_type: CellType::Code,
                source: "bad".into(),
            },
        ));

        let mut notebook = NotebookDocument::new("python");
        let err = replay_notebook_log(&mut notebook, &log).unwrap_err();

        assert_eq!(
            err,
            NotebookEditError::OperationLog(OperationLogError::WrongEngine {
                expected: MAQAL_ENGINE_ID.into(),
                actual: "code".into(),
                operation_id: "op-1".into(),
            })
        );
        assert_eq!(notebook.cell_count(), 1);
        assert_eq!(notebook.cells()[0].source(), "");
    }

    #[test]
    fn deleting_last_cell_is_rejected() {
        let mut notebook = NotebookDocument::new("python");
        notebook.cells_mut()[0].id = CellId::from_str("only");

        let err = notebook
            .apply_notebook_edit(&NotebookEdit::DeleteCell {
                cell_id: "only".into(),
            })
            .unwrap_err();

        assert_eq!(
            err,
            NotebookEditError::CannotDeleteLastCell {
                cell_id: "only".into(),
            }
        );
        assert_eq!(notebook.cell_count(), 1);
    }

    #[test]
    fn clearing_cell_outputs_marks_outputs_changed() {
        let mut notebook = NotebookDocument::new("python");
        notebook.cells_mut()[0].id = CellId::from_str("code-1");
        notebook.cells_mut()[0].add_output(CellOutput::Stream(StreamOutput {
            name: crate::notebook::output::StreamName::Stdout,
            text: "hello\n".into(),
        }));

        let outcome = notebook
            .apply_notebook_edit(&NotebookEdit::ClearCellOutputs {
                cell_id: "code-1".into(),
            })
            .unwrap();

        assert_eq!(outcome.changed_cells, vec!["code-1"]);
        assert!(outcome.changed_outputs);
        assert!(notebook.cells()[0].outputs.outputs.is_empty());
    }

    #[test]
    fn notebook_artifact_roundtrips_and_restores_snapshot_plus_tail_log() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-3",
                    3,
                    NotebookEdit::InsertCell {
                        index: 1,
                        cell_id: "md-1".into(),
                        cell_type: CellType::Markdown,
                        source: "# Notes".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);
        let json = artifact.to_json().unwrap();
        let restored_artifact = NotebookArtifact::from_json(&json).unwrap();
        let restored_notebook = restore_notebook_artifact(&restored_artifact).unwrap();

        assert_eq!(restored_notebook.uri, "notebook://main");
        assert_eq!(restored_notebook.cell_count(), 2);
        assert_eq!(restored_notebook.cells()[0].id.0, "code-1");
        assert_eq!(restored_notebook.cells()[0].source(), "x = 2");
        assert_eq!(restored_notebook.cells()[1].id.0, "md-1");
        assert_eq!(restored_notebook.cells()[1].cell_type, CellType::Markdown);
    }

    #[test]
    fn notebook_artifact_satisfies_shared_conformance_checklist() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);
        let report = validate_artifact_conformance(MAQAL_ENGINE_ID, &artifact).unwrap();

        assert_eq!(report.engine_id, MAQAL_ENGINE_ID);
        assert_eq!(report.document_id, "notebook://main");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
    }

    #[test]
    fn notebook_artifact_declares_shared_test_profile() {
        let profile = domain_artifact_test_profile(MAQAL_ENGINE_ID);

        assert_eq!(profile.engine_id, MAQAL_ENGINE_ID);
        let report = validate_domain_artifact_test_profile_report(&profile).unwrap();
        assert_eq!(report.required_shared_check_count, 22);
        assert_eq!(report.lifecycle_harness_shared_check_count, Some(22));
    }

    #[test]
    fn notebook_artifact_maintenance_plan_uses_shared_policy() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new();
        for sequence in 1..=3 {
            tail_log
                .push_checked(
                    operation(
                        &format!("op-{sequence}"),
                        sequence,
                        NotebookEdit::ClearAllOutputs,
                    ),
                    MAQAL_ENGINE_ID,
                )
                .unwrap();
        }

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);
        let plan = plan_notebook_artifact_maintenance(
            &artifact,
            NotebookArtifactMaintenancePolicy::new(2, 1),
        )
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
    fn compact_notebook_artifact_folds_prefix_and_retains_tail() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new().with_metadata_text("source", "kernel-ui");
        tail_log
            .push_checked(
                operation(
                    "op-1",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::InsertCell {
                        index: 1,
                        cell_id: "md-1".into(),
                        cell_type: CellType::Markdown,
                        source: "# Notes".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-3",
                    3,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 3".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log)
            .with_metadata_text("owner", "notebook-test");
        let compacted = compact_notebook_artifact(&artifact, 1, 1234).unwrap();
        let restored_notebook = restore_notebook_artifact(&compacted).unwrap();
        let compacted_snapshot = compacted.snapshot.to_notebook();

        assert_eq!(compacted_snapshot.cell_count(), 2);
        assert_eq!(compacted_snapshot.cells()[0].id.0, "code-1");
        assert_eq!(compacted_snapshot.cells()[0].source(), "x = 2");
        assert_eq!(compacted_snapshot.cells()[1].id.0, "md-1");
        assert_eq!(compacted_snapshot.cells()[1].cell_type, CellType::Markdown);
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
        assert_eq!(compacted.operation_log.metadata["source"], "kernel-ui");
        assert_eq!(compacted.metadata["owner"], "notebook-test");
        let info = artifact_compaction_info(&compacted).unwrap().unwrap();
        assert_eq!(info.compacted_operation_count, 2);
        assert_eq!(info.compacted_through_operation_id.as_deref(), Some("op-2"));
        assert_eq!(info.compacted_at_ms, 1234);
        assert_eq!(restored_notebook.cell_count(), 2);
        assert_eq!(restored_notebook.cells()[0].source(), "x = 3");
        assert_eq!(restored_notebook.cells()[1].source(), "# Notes");
    }

    #[test]
    fn notebook_artifact_satisfies_shared_compaction_harness() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new().with_metadata_text("source", "kernel-ui");
        tail_log
            .push_checked(
                operation(
                    "op-1",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::InsertCell {
                        index: 1,
                        cell_id: "md-1".into(),
                        cell_type: CellType::Markdown,
                        source: "# Notes".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-3",
                    3,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 3".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);
        let report = validate_artifact_compaction_harness(
            MAQAL_ENGINE_ID,
            &artifact,
            1,
            1234,
            |artifact| {
                restore_notebook_artifact(artifact)
                    .map(|notebook| persisted_notebook_state(&notebook))
            },
            compact_notebook_artifact,
            maintain_notebook_artifact,
        )
        .unwrap();

        assert_eq!(report.engine_id, MAQAL_ENGINE_ID);
        assert_eq!(report.document_id, "notebook://main");
        assert_eq!(report.source_operation_count, 3);
        assert_eq!(report.compacted_operation_count, 2);
        assert_eq!(report.retained_operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
    }

    #[test]
    fn notebook_artifact_satisfies_shared_lifecycle_harness() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new().with_metadata_text("source", "kernel-ui");
        tail_log
            .push_checked(
                operation(
                    "op-1",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::InsertCell {
                        index: 1,
                        cell_id: "md-1".into(),
                        cell_type: CellType::Markdown,
                        source: "# Notes".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-3",
                    3,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 3".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);
        let expected_state =
            persisted_notebook_state(&restore_notebook_artifact(&artifact).unwrap());
        let invalid_state = (
            "notebook://main".into(),
            vec![("code-1".into(), CellType::Code, "x = 1".into())],
        );

        let mut invalid_log = NotebookOperationLog::new();
        invalid_log
            .push_checked(
                operation(
                    "op-invalid-prefix",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        invalid_log
            .push_checked(
                operation(
                    "op-invalid",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "missing-cell".into(),
                        source: "bad".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let report = validate_artifact_lifecycle_harness(
            MAQAL_ENGINE_ID,
            &artifact,
            &expected_state,
            &invalid_state,
            &invalid_log,
            1,
            1234,
            |artifact| {
                restore_notebook_artifact(artifact)
                    .map(|notebook| persisted_notebook_state(&notebook))
            },
            |state, log| {
                let mut notebook = NotebookDocument::new("python").with_uri(&state.0);
                for (index, (cell_id, cell_type, source)) in state.1.iter().enumerate() {
                    if index > 0 {
                        notebook.focus_cell_at(index - 1);
                        notebook.insert_cell_below(*cell_type);
                    }
                    let cell = &mut notebook.cells_mut()[index];
                    cell.id = CellId::from_str(cell_id);
                    cell.cell_type = *cell_type;
                    cell.set_source(source);
                }
                let result = replay_notebook_log(&mut notebook, log).map(|_| ());
                *state = persisted_notebook_state(&notebook);
                result
            },
            compact_notebook_artifact,
            maintain_notebook_artifact,
        )
        .unwrap();

        let validation_report = validate_artifact_lifecycle_profile_report(
            &domain_artifact_test_profile(MAQAL_ENGINE_ID),
            &report,
        )
        .unwrap();
        assert_eq!(validation_report.completed_shared_check_count, 22);
        assert_eq!(validation_report.document_id, "notebook://main");
    }

    #[test]
    fn maintain_notebook_artifact_compacts_only_when_policy_requires_it() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new();
        tail_log
            .push_checked(
                operation(
                    "op-1",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 3".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        tail_log
            .push_checked(
                operation(
                    "op-3",
                    3,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 4".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);

        let unchanged = maintain_notebook_artifact(
            &artifact,
            NotebookArtifactMaintenancePolicy::new(10, 1),
            1234,
        )
        .unwrap();
        let compacted = maintain_notebook_artifact(
            &artifact,
            NotebookArtifactMaintenancePolicy::new(2, 1),
            1234,
        )
        .unwrap();
        let skipped_outcome = maintain_notebook_artifact_with_outcome(
            &artifact,
            NotebookArtifactMaintenancePolicy::new(10, 1),
            1234,
        )
        .unwrap();
        let compacted_outcome = maintain_notebook_artifact_with_outcome(
            &artifact,
            NotebookArtifactMaintenancePolicy::new(2, 1),
            1234,
        )
        .unwrap();
        let compacted_snapshot = compacted.snapshot.to_notebook();

        assert_eq!(unchanged.document_id, artifact.document_id);
        assert_eq!(unchanged.operation_log.len(), artifact.operation_log.len());
        assert_eq!(skipped_outcome.action, ArtifactMaintenanceAction::Preserved);
        assert_eq!(skipped_outcome.artifact.document_id, artifact.document_id);
        assert_eq!(
            skipped_outcome.artifact.operation_log.len(),
            artifact.operation_log.len()
        );
        assert_eq!(skipped_outcome.compaction_info, None);
        assert!(!unchanged
            .metadata
            .contains_key(ARTIFACT_COMPACTION_METADATA_KEY));
        assert_eq!(compacted_snapshot.cells()[0].source(), "x = 3");
        assert_eq!(compacted.operation_log.len(), 1);
        assert_eq!(compacted.operation_log.operations[0].operation_id, "op-3");
        assert_eq!(
            compacted_outcome.action,
            ArtifactMaintenanceAction::Compacted
        );
        assert_eq!(compacted_outcome.plan.compactable_operation_count, 2);
        assert_eq!(compacted_outcome.artifact.operation_log.len(), 1);
        assert_eq!(
            compacted_outcome
                .compaction_info
                .as_ref()
                .and_then(|info| info.compacted_through_operation_id.as_deref()),
            Some("op-2")
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
    fn notebook_artifact_satisfies_shared_replay_harness() {
        let mut snapshot_notebook = NotebookDocument::new("python").with_uri("notebook://main");
        snapshot_notebook.cells_mut()[0].id = CellId::from_str("code-1");
        snapshot_notebook.cells_mut()[0].set_source("x = 1");

        let mut tail_log = NotebookOperationLog::new();
        tail_log
            .push_checked(
                operation(
                    "op-2",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let artifact = notebook_artifact("notebook://main", &snapshot_notebook, tail_log);

        let invalid_state = NotebookReplayState {
            uri: "notebook://main".into(),
            active_cell: 0,
            dirty: false,
            cells: vec![("code-1".into(), CellType::Code, "x = 1".into())],
        };

        let mut invalid_log = NotebookOperationLog::new();
        invalid_log
            .push_checked(
                operation(
                    "op-invalid-prefix",
                    1,
                    NotebookEdit::SetCellSource {
                        cell_id: "code-1".into(),
                        source: "x = 2".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();
        invalid_log
            .push_checked(
                operation(
                    "op-invalid",
                    2,
                    NotebookEdit::SetCellSource {
                        cell_id: "missing-cell".into(),
                        source: "bad".into(),
                    },
                ),
                MAQAL_ENGINE_ID,
            )
            .unwrap();

        let report = validate_artifact_replay_harness(
            MAQAL_ENGINE_ID,
            &artifact,
            &NotebookReplayState {
                uri: "notebook://main".into(),
                active_cell: 0,
                dirty: true,
                cells: vec![("code-1".into(), CellType::Code, "x = 2".into())],
            },
            &invalid_state,
            &invalid_log,
            |artifact| {
                restore_notebook_artifact(artifact)
                    .map(|notebook| NotebookReplayState::from_notebook(&notebook))
            },
            |state, log| {
                let mut notebook = state.to_notebook();
                let result = replay_notebook_log(&mut notebook, log).map(|_| ());
                *state = NotebookReplayState::from_notebook(&notebook);
                result
            },
        )
        .unwrap();

        assert_eq!(report.engine_id, MAQAL_ENGINE_ID);
        assert_eq!(report.document_id, "notebook://main");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
    }

    #[test]
    fn notebook_artifact_rejects_operation_for_another_document() {
        let notebook = NotebookDocument::new("python");
        let mut tail_log = NotebookOperationLog::new();
        tail_log.push(notebook_operation(
            "op-1",
            "notebook://other",
            "actor-1",
            1,
            100,
            NotebookEdit::ClearAllOutputs,
        ));

        let artifact = notebook_artifact("notebook://main", &notebook, tail_log);
        let err = match restore_notebook_artifact(&artifact) {
            Ok(_) => panic!("expected document mismatch error"),
            Err(err) => err,
        };

        assert_eq!(
            err,
            NotebookEditError::OperationLog(OperationLogError::OperationDocumentMismatch {
                operation_id: "op-1".into(),
                expected: "notebook://main".into(),
                actual: "notebook://other".into(),
            })
        );
    }
}
