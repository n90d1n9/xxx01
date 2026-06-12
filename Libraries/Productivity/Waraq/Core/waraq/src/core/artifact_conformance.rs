//! Conformance helpers for engines built on Waraq artifact primitives.
//!
//! These checks are intended for tests, host probes, and examples. They verify
//! the shared transport contract around operation envelopes, operation logs,
//! and snapshot-plus-tail artifacts without taking ownership of domain replay
//! semantics.

use serde::{de::DeserializeOwned, Deserialize, Serialize};

use crate::core::artifact_contract::ARTIFACT_CONTRACT_VERSION;
use crate::core::operation::{
    OperationArtifact, OperationEnvelope, OperationLog, OperationLogError,
};

/// Shared artifact primitive currently being checked by the conformance helper.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactConformancePrimitive {
    /// A single operation envelope carrying a domain edit.
    Operation,
    /// An ordered operation log carrying a replay tail.
    OperationLog,
    /// A snapshot-plus-tail artifact.
    Artifact,
}

/// Individual shared invariant completed by the artifact conformance helper.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactConformanceCheck {
    /// Representative operation envelope passed shared validation.
    OperationValidation,
    /// Operation tail passed shared log validation.
    OperationLogValidation,
    /// Snapshot-plus-tail artifact passed shared validation.
    ArtifactValidation,
    /// Representative operation envelope preserved its JSON shape.
    OperationJsonRoundtrip,
    /// Operation tail preserved its JSON shape.
    OperationLogJsonRoundtrip,
    /// Snapshot-plus-tail artifact preserved its JSON shape.
    ArtifactJsonRoundtrip,
    /// Representative operation envelope rejected a wrong engine id.
    OperationWrongEngineRejection,
    /// Operation tail rejected a wrong engine id.
    OperationLogWrongEngineRejection,
    /// Snapshot-plus-tail artifact rejected a wrong engine id.
    ArtifactWrongEngineRejection,
    /// Artifact rejected an operation targeting a different document id.
    ArtifactWrongDocumentRejection,
}

/// Canonical set and order of checks completed by a successful conformance run.
pub const REQUIRED_ARTIFACT_CONFORMANCE_CHECKS: &[ArtifactConformanceCheck] = &[
    ArtifactConformanceCheck::ArtifactValidation,
    ArtifactConformanceCheck::OperationLogValidation,
    ArtifactConformanceCheck::OperationValidation,
    ArtifactConformanceCheck::OperationJsonRoundtrip,
    ArtifactConformanceCheck::OperationLogJsonRoundtrip,
    ArtifactConformanceCheck::ArtifactJsonRoundtrip,
    ArtifactConformanceCheck::OperationWrongEngineRejection,
    ArtifactConformanceCheck::OperationLogWrongEngineRejection,
    ArtifactConformanceCheck::ArtifactWrongEngineRejection,
    ArtifactConformanceCheck::ArtifactWrongDocumentRejection,
];

/// Summary returned when an artifact satisfies Waraq's shared transport contract.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactConformanceReport {
    /// Shared artifact contract version used for the check.
    pub contract_version: u32,
    /// Engine identifier that every operation and artifact must carry.
    pub engine_id: String,
    /// Document identifier that the artifact and operation tail must target.
    pub document_id: String,
    /// Number of retained operations in the artifact tail.
    pub operation_count: usize,
    /// First operation sequence in the retained tail, when present.
    pub first_sequence: Option<u64>,
    /// Last operation sequence in the retained tail, when present.
    pub last_sequence: Option<u64>,
    /// Last operation id in the retained tail, when present.
    pub last_operation_id: Option<String>,
    /// Exact shared checks completed by the helper.
    pub completed_checks: Vec<ArtifactConformanceCheck>,
    /// True when operation, log, and artifact JSON round-trips were checked.
    pub checked_json_roundtrip: bool,
    /// True when operation, log, and artifact wrong-engine rejection was checked.
    pub checked_wrong_engine_rejection: bool,
    /// True when artifact operation-document mismatch rejection was checked.
    pub checked_wrong_document_rejection: bool,
}

/// Error returned when a candidate artifact violates the shared contract checks.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactConformanceError {
    /// The representative operation failed envelope validation.
    OperationValidation(OperationLogError),
    /// The operation log failed shared log validation.
    OperationLogValidation(OperationLogError),
    /// The artifact failed shared artifact validation.
    ArtifactValidation(OperationLogError),
    /// The artifact has no operation to use for representative mutation checks.
    EmptyOperationLog {
        /// Engine identifier supplied to the conformance check.
        engine_id: String,
        /// Document identifier carried by the artifact.
        document_id: String,
    },
    /// JSON serialization or deserialization failed during a round-trip check.
    JsonRoundtripFailed {
        /// Shared primitive whose JSON round-trip failed.
        primitive: ArtifactConformancePrimitive,
        /// Human-readable serialization error.
        message: String,
    },
    /// JSON round-trip changed the primitive's semantic JSON value.
    JsonRoundtripMismatch {
        /// Shared primitive whose JSON value changed after a round-trip.
        primitive: ArtifactConformancePrimitive,
    },
    /// A primitive accepted a deliberately wrong engine id.
    WrongEngineAccepted {
        /// Shared primitive that failed to reject the wrong engine id.
        primitive: ArtifactConformancePrimitive,
    },
    /// An artifact accepted an operation whose document id differed from the artifact.
    WrongDocumentAccepted {
        /// Operation id that was mutated to target another document.
        operation_id: String,
        /// Deliberately wrong document id that was accepted.
        document_id: String,
    },
}

/// Validate the shared Waraq artifact contract for a domain artifact.
///
/// Domain engines can call this from their own tests after constructing a
/// representative artifact. The helper validates shared envelope/log/artifact
/// invariants, JSON round-trips, wrong-engine rejection, and operation-document
/// mismatch rejection. Domain-specific replay correctness should still be
/// tested by the engine itself.
pub fn validate_artifact_conformance<Snapshot, Edit>(
    expected_engine: &str,
    artifact: &OperationArtifact<Snapshot, Edit>,
) -> Result<ArtifactConformanceReport, ArtifactConformanceError>
where
    Snapshot: Clone + Serialize + DeserializeOwned,
    Edit: Clone + Serialize + DeserializeOwned,
{
    let mut completed_checks = Vec::with_capacity(REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len());

    artifact
        .validate_for_engine(expected_engine)
        .map_err(ArtifactConformanceError::ArtifactValidation)?;
    completed_checks.push(ArtifactConformanceCheck::ArtifactValidation);

    artifact
        .operation_log
        .validate_for_engine(expected_engine)
        .map_err(ArtifactConformanceError::OperationLogValidation)?;
    completed_checks.push(ArtifactConformanceCheck::OperationLogValidation);

    let representative_operation = artifact.operation_log.operations.first().ok_or_else(|| {
        ArtifactConformanceError::EmptyOperationLog {
            engine_id: expected_engine.to_owned(),
            document_id: artifact.document_id.clone(),
        }
    })?;
    representative_operation
        .validate_for_engine(expected_engine)
        .map_err(ArtifactConformanceError::OperationValidation)?;
    completed_checks.push(ArtifactConformanceCheck::OperationValidation);

    assert_json_roundtrip(
        ArtifactConformancePrimitive::Operation,
        representative_operation,
    )?;
    completed_checks.push(ArtifactConformanceCheck::OperationJsonRoundtrip);
    assert_json_roundtrip(
        ArtifactConformancePrimitive::OperationLog,
        &artifact.operation_log,
    )?;
    completed_checks.push(ArtifactConformanceCheck::OperationLogJsonRoundtrip);
    assert_json_roundtrip(ArtifactConformancePrimitive::Artifact, artifact)?;
    completed_checks.push(ArtifactConformanceCheck::ArtifactJsonRoundtrip);

    assert_wrong_engine_rejected(
        expected_engine,
        representative_operation,
        &artifact.operation_log,
        artifact,
    )?;
    completed_checks.extend([
        ArtifactConformanceCheck::OperationWrongEngineRejection,
        ArtifactConformanceCheck::OperationLogWrongEngineRejection,
        ArtifactConformanceCheck::ArtifactWrongEngineRejection,
    ]);
    assert_wrong_document_rejected(expected_engine, artifact)?;
    completed_checks.push(ArtifactConformanceCheck::ArtifactWrongDocumentRejection);

    Ok(ArtifactConformanceReport {
        contract_version: ARTIFACT_CONTRACT_VERSION,
        engine_id: expected_engine.to_owned(),
        document_id: artifact.document_id.clone(),
        operation_count: artifact.operation_log.len(),
        first_sequence: artifact.operation_log.first_sequence(),
        last_sequence: artifact.operation_log.last_sequence(),
        last_operation_id: artifact
            .operation_log
            .last_operation_id()
            .map(ToOwned::to_owned),
        completed_checks,
        checked_json_roundtrip: true,
        checked_wrong_engine_rejection: true,
        checked_wrong_document_rejection: true,
    })
}

fn assert_json_roundtrip<T>(
    primitive: ArtifactConformancePrimitive,
    value: &T,
) -> Result<(), ArtifactConformanceError>
where
    T: Serialize + DeserializeOwned,
{
    let json = serde_json::to_string(value).map_err(|error| {
        ArtifactConformanceError::JsonRoundtripFailed {
            primitive,
            message: error.to_string(),
        }
    })?;
    let restored = serde_json::from_str::<T>(&json).map_err(|error| {
        ArtifactConformanceError::JsonRoundtripFailed {
            primitive,
            message: error.to_string(),
        }
    })?;
    let original_value = serde_json::to_value(value).map_err(|error| {
        ArtifactConformanceError::JsonRoundtripFailed {
            primitive,
            message: error.to_string(),
        }
    })?;
    let restored_value = serde_json::to_value(restored).map_err(|error| {
        ArtifactConformanceError::JsonRoundtripFailed {
            primitive,
            message: error.to_string(),
        }
    })?;

    if original_value != restored_value {
        return Err(ArtifactConformanceError::JsonRoundtripMismatch { primitive });
    }

    Ok(())
}

fn assert_wrong_engine_rejected<Snapshot, Edit>(
    expected_engine: &str,
    representative_operation: &OperationEnvelope<Edit>,
    operation_log: &OperationLog<Edit>,
    artifact: &OperationArtifact<Snapshot, Edit>,
) -> Result<(), ArtifactConformanceError>
where
    Snapshot: Clone,
    Edit: Clone,
{
    let wrong_engine = alternate_value(expected_engine, "wrong-engine");

    let mut wrong_operation = representative_operation.clone();
    wrong_operation.engine = wrong_engine.clone();
    if wrong_operation.validate_for_engine(expected_engine).is_ok() {
        return Err(ArtifactConformanceError::WrongEngineAccepted {
            primitive: ArtifactConformancePrimitive::Operation,
        });
    }

    let mut wrong_log = operation_log.clone();
    wrong_log.operations[0].engine = wrong_engine.clone();
    if wrong_log.validate_for_engine(expected_engine).is_ok() {
        return Err(ArtifactConformanceError::WrongEngineAccepted {
            primitive: ArtifactConformancePrimitive::OperationLog,
        });
    }

    let mut wrong_artifact = artifact.clone();
    wrong_artifact.engine = wrong_engine;
    if wrong_artifact.validate_for_engine(expected_engine).is_ok() {
        return Err(ArtifactConformanceError::WrongEngineAccepted {
            primitive: ArtifactConformancePrimitive::Artifact,
        });
    }

    Ok(())
}

fn assert_wrong_document_rejected<Snapshot, Edit>(
    expected_engine: &str,
    artifact: &OperationArtifact<Snapshot, Edit>,
) -> Result<(), ArtifactConformanceError>
where
    Snapshot: Clone,
    Edit: Clone,
{
    let mut wrong_document_artifact = artifact.clone();
    let wrong_document_id = alternate_value(&artifact.document_id, "wrong-document");
    let operation = &mut wrong_document_artifact.operation_log.operations[0];
    let operation_id = operation.operation_id.clone();
    operation.document_id = wrong_document_id.clone();

    if wrong_document_artifact
        .validate_for_engine(expected_engine)
        .is_ok()
    {
        return Err(ArtifactConformanceError::WrongDocumentAccepted {
            operation_id,
            document_id: wrong_document_id,
        });
    }

    Ok(())
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

    const CONFORMANCE_REPORT_GOLDEN_JSON: &str =
        include_str!("fixtures/artifact_conformance_report.json");

    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct TestSnapshot {
        content: String,
    }

    #[derive(Debug, Clone, Serialize, Deserialize)]
    enum TestEdit {
        Insert { at: usize, text: String },
    }

    fn operation(id: &str, document_id: &str, sequence: u64) -> OperationEnvelope<TestEdit> {
        OperationEnvelope::new(
            "waraq.test",
            id,
            document_id,
            "actor-1",
            sequence,
            sequence * 100,
            TestEdit::Insert {
                at: 0,
                text: "hello".to_owned(),
            },
        )
    }

    fn valid_artifact() -> OperationArtifact<TestSnapshot, TestEdit> {
        let log = OperationLog::from_operations(vec![
            operation("op-1", "doc-1", 1),
            operation("op-2", "doc-1", 2),
        ]);
        OperationArtifact::new(
            "waraq.test",
            "doc-1",
            TestSnapshot {
                content: "snapshot".to_owned(),
            },
            log,
        )
    }

    #[test]
    fn conformance_accepts_valid_artifact_and_reports_summary() {
        let report = validate_artifact_conformance("waraq.test", &valid_artifact()).unwrap();

        assert_eq!(report.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(report.engine_id, "waraq.test");
        assert_eq!(report.document_id, "doc-1");
        assert_eq!(report.operation_count, 2);
        assert_eq!(report.first_sequence, Some(1));
        assert_eq!(report.last_sequence, Some(2));
        assert_eq!(report.last_operation_id.as_deref(), Some("op-2"));
        assert_eq!(
            report.completed_checks,
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
        assert!(report.checked_json_roundtrip);
        assert!(report.checked_wrong_engine_rejection);
        assert!(report.checked_wrong_document_rejection);
    }

    #[test]
    fn conformance_report_matches_golden_fixture() {
        let report = validate_artifact_conformance("waraq.test", &valid_artifact()).unwrap();
        let actual = serde_json::to_value(report).unwrap();
        let expected: serde_json::Value =
            serde_json::from_str(CONFORMANCE_REPORT_GOLDEN_JSON).unwrap();

        assert_eq!(actual, expected);
    }

    #[test]
    fn conformance_requires_representative_operation_tail() {
        let artifact = OperationArtifact::new(
            "waraq.test",
            "doc-1",
            TestSnapshot {
                content: "snapshot".to_owned(),
            },
            OperationLog::<TestEdit>::new(),
        );

        assert_eq!(
            validate_artifact_conformance("waraq.test", &artifact),
            Err(ArtifactConformanceError::EmptyOperationLog {
                engine_id: "waraq.test".to_owned(),
                document_id: "doc-1".to_owned(),
            })
        );
    }

    #[test]
    fn conformance_reports_artifact_validation_errors_before_mutation_checks() {
        let mut artifact = valid_artifact();
        artifact.operation_log.operations[0].document_id = "doc-2".to_owned();

        assert_eq!(
            validate_artifact_conformance("waraq.test", &artifact),
            Err(ArtifactConformanceError::ArtifactValidation(
                OperationLogError::OperationDocumentMismatch {
                    operation_id: "op-1".to_owned(),
                    expected: "doc-1".to_owned(),
                    actual: "doc-2".to_owned(),
                }
            ))
        );
    }
}
