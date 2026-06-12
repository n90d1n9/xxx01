//! Replay harness helpers for Waraq-family domain engines.
//!
//! The artifact conformance helper checks shared transport shape. This module
//! checks the next layer: a domain engine's restore and replay callbacks reject
//! invalid artifacts and avoid partial mutation on failed replay.

use std::fmt::Debug;

use serde::{Deserialize, Serialize};

use crate::core::operation::{OperationArtifact, OperationLog, OperationLogError};

/// Replay behavior checked by the shared artifact replay harness.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactReplayHarnessCheck {
    /// A valid artifact restored to the expected domain state.
    ValidRestore,
    /// A deliberately wrong artifact engine id was rejected.
    WrongEngineRejection,
    /// A deliberately wrong operation document id was rejected.
    WrongDocumentRejection,
    /// A domain-invalid replay failed without changing the supplied state.
    InvalidReplayNoPartialMutation,
}

/// Canonical set and order of checks completed by a successful replay harness.
pub const REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS: &[ArtifactReplayHarnessCheck] = &[
    ArtifactReplayHarnessCheck::ValidRestore,
    ArtifactReplayHarnessCheck::WrongEngineRejection,
    ArtifactReplayHarnessCheck::WrongDocumentRejection,
    ArtifactReplayHarnessCheck::InvalidReplayNoPartialMutation,
];

/// Summary returned when a domain engine satisfies the replay harness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactReplayHarnessReport {
    /// Stable engine identifier used by the checked artifact.
    pub engine_id: String,
    /// Document identifier used by the checked artifact.
    pub document_id: String,
    /// Number of operations in the valid replay tail.
    pub operation_count: usize,
    /// Exact replay checks completed by the helper.
    pub completed_checks: Vec<ArtifactReplayHarnessCheck>,
}

/// Error returned when a domain engine violates the replay harness.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactReplayHarnessError {
    /// The representative artifact had no operation to mutate for negative checks.
    EmptyOperationLog {
        /// Engine identifier supplied to the replay harness.
        engine_id: String,
        /// Document identifier carried by the artifact.
        document_id: String,
    },
    /// The domain-invalid replay log failed shared transport validation first.
    InvalidReplayLogTransportValidation(OperationLogError),
    /// The valid artifact failed to restore.
    ValidRestoreFailed {
        /// Human-readable restore error.
        message: String,
    },
    /// The valid artifact restored but produced the wrong domain state.
    ValidRestoreMismatch {
        /// Debug representation of the expected state.
        expected: String,
        /// Debug representation of the actual state.
        actual: String,
    },
    /// The restore callback accepted an artifact with a wrong engine id.
    WrongEngineAccepted {
        /// Deliberately wrong engine id that was accepted.
        engine_id: String,
    },
    /// The restore callback accepted an operation targeting another document.
    WrongDocumentAccepted {
        /// Operation id whose document id was mutated.
        operation_id: String,
        /// Deliberately wrong document id that was accepted.
        document_id: String,
    },
    /// The domain-invalid replay log unexpectedly succeeded.
    InvalidReplayAccepted,
    /// The domain-invalid replay failed but still changed the supplied state.
    InvalidReplayMutatedState {
        /// Debug representation of the state before replay.
        before: String,
        /// Debug representation of the state after replay.
        after: String,
    },
}

/// Validate core replay behavior for a Waraq-family domain engine.
///
/// Domain engines provide a valid artifact, an expected restored state, a
/// domain-invalid replay log, and callbacks for their restore/replay behavior.
/// The helper verifies valid restore, wrong-engine rejection, wrong-document
/// rejection, and failed replay without partial mutation.
pub fn validate_artifact_replay_harness<Snapshot, Edit, State, Error, Restore, Replay>(
    expected_engine: &str,
    valid_artifact: &OperationArtifact<Snapshot, Edit>,
    expected_restored_state: &State,
    invalid_replay_state: &State,
    invalid_replay_log: &OperationLog<Edit>,
    restore_artifact: Restore,
    replay_log: Replay,
) -> Result<ArtifactReplayHarnessReport, ArtifactReplayHarnessError>
where
    Snapshot: Clone,
    Edit: Clone,
    State: Clone + Debug + PartialEq,
    Error: Debug,
    Restore: Fn(&OperationArtifact<Snapshot, Edit>) -> Result<State, Error>,
    Replay: Fn(&mut State, &OperationLog<Edit>) -> Result<(), Error>,
{
    let mut completed_checks = Vec::with_capacity(REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len());
    if valid_artifact.operation_log.operations.is_empty() {
        return Err(ArtifactReplayHarnessError::EmptyOperationLog {
            engine_id: expected_engine.to_owned(),
            document_id: valid_artifact.document_id.clone(),
        });
    }

    invalid_replay_log
        .validate_for_engine(expected_engine)
        .map_err(ArtifactReplayHarnessError::InvalidReplayLogTransportValidation)?;

    let restored = restore_artifact(valid_artifact).map_err(|error| {
        ArtifactReplayHarnessError::ValidRestoreFailed {
            message: format!("{error:?}"),
        }
    })?;
    if &restored != expected_restored_state {
        return Err(ArtifactReplayHarnessError::ValidRestoreMismatch {
            expected: format!("{expected_restored_state:?}"),
            actual: format!("{restored:?}"),
        });
    }
    completed_checks.push(ArtifactReplayHarnessCheck::ValidRestore);

    let wrong_engine = alternate_value(expected_engine, "wrong-engine");
    let mut wrong_engine_artifact = valid_artifact.clone();
    wrong_engine_artifact.engine = wrong_engine.clone();
    if restore_artifact(&wrong_engine_artifact).is_ok() {
        return Err(ArtifactReplayHarnessError::WrongEngineAccepted {
            engine_id: wrong_engine,
        });
    }
    completed_checks.push(ArtifactReplayHarnessCheck::WrongEngineRejection);

    let wrong_document = alternate_value(&valid_artifact.document_id, "wrong-document");
    let mut wrong_document_artifact = valid_artifact.clone();
    let operation = &mut wrong_document_artifact.operation_log.operations[0];
    let operation_id = operation.operation_id.clone();
    operation.document_id = wrong_document.clone();
    if restore_artifact(&wrong_document_artifact).is_ok() {
        return Err(ArtifactReplayHarnessError::WrongDocumentAccepted {
            operation_id,
            document_id: wrong_document,
        });
    }
    completed_checks.push(ArtifactReplayHarnessCheck::WrongDocumentRejection);

    let before = invalid_replay_state.clone();
    let mut replay_state = invalid_replay_state.clone();
    if replay_log(&mut replay_state, invalid_replay_log).is_ok() {
        return Err(ArtifactReplayHarnessError::InvalidReplayAccepted);
    }
    if replay_state != before {
        return Err(ArtifactReplayHarnessError::InvalidReplayMutatedState {
            before: format!("{before:?}"),
            after: format!("{replay_state:?}"),
        });
    }
    completed_checks.push(ArtifactReplayHarnessCheck::InvalidReplayNoPartialMutation);

    Ok(ArtifactReplayHarnessReport {
        engine_id: expected_engine.to_owned(),
        document_id: valid_artifact.document_id.clone(),
        operation_count: valid_artifact.operation_log.len(),
        completed_checks,
    })
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
    use crate::core::operation::{OperationArtifact, OperationEnvelope, OperationLog};

    const TEST_ENGINE_ID: &str = "waraq.replay.test";

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    struct TestState {
        value: i32,
    }

    #[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
    enum TestEdit {
        Add(i32),
        Reject,
        MutateThenReject,
    }

    #[derive(Debug, Clone, PartialEq, Eq)]
    enum TestReplayError {
        OperationLog(OperationLogError),
        Rejected,
    }

    impl From<OperationLogError> for TestReplayError {
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

    fn valid_artifact() -> OperationArtifact<TestState, TestEdit> {
        OperationArtifact::new(
            TEST_ENGINE_ID,
            "doc-1",
            TestState { value: 1 },
            OperationLog::from_operations(vec![operation("op-1", 1, TestEdit::Add(2))]),
        )
    }

    fn invalid_log(edit: TestEdit) -> OperationLog<TestEdit> {
        OperationLog::from_operations(vec![operation("op-invalid", 1, edit)])
    }

    fn restore_artifact(
        artifact: &OperationArtifact<TestState, TestEdit>,
    ) -> Result<TestState, TestReplayError> {
        artifact.validate_for_engine(TEST_ENGINE_ID)?;
        let mut state = artifact.snapshot.clone();
        replay_log(&mut state, &artifact.operation_log)?;
        Ok(state)
    }

    fn replay_log(
        state: &mut TestState,
        log: &OperationLog<TestEdit>,
    ) -> Result<(), TestReplayError> {
        log.validate_for_engine(TEST_ENGINE_ID)?;
        for operation in &log.operations {
            match operation.edit {
                TestEdit::Add(value) => state.value += value,
                TestEdit::Reject => return Err(TestReplayError::Rejected),
                TestEdit::MutateThenReject => {
                    state.value += 1;
                    return Err(TestReplayError::Rejected);
                }
            }
        }
        Ok(())
    }

    #[test]
    fn replay_harness_accepts_valid_domain_behavior() {
        let report = validate_artifact_replay_harness(
            TEST_ENGINE_ID,
            &valid_artifact(),
            &TestState { value: 3 },
            &TestState { value: 10 },
            &invalid_log(TestEdit::Reject),
            restore_artifact,
            replay_log,
        )
        .unwrap();

        assert_eq!(report.engine_id, TEST_ENGINE_ID);
        assert_eq!(report.document_id, "doc-1");
        assert_eq!(report.operation_count, 1);
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
    }

    #[test]
    fn replay_harness_detects_partial_mutation_after_failed_replay() {
        assert_eq!(
            validate_artifact_replay_harness(
                TEST_ENGINE_ID,
                &valid_artifact(),
                &TestState { value: 3 },
                &TestState { value: 10 },
                &invalid_log(TestEdit::MutateThenReject),
                restore_artifact,
                replay_log,
            ),
            Err(ArtifactReplayHarnessError::InvalidReplayMutatedState {
                before: "TestState { value: 10 }".to_owned(),
                after: "TestState { value: 11 }".to_owned(),
            })
        );
    }
}
