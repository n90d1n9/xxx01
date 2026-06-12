use serde::{de::DeserializeOwned, Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

pub const OPERATION_ENVELOPE_VERSION: u32 = 1;

pub type OperationMetadata = BTreeMap<String, serde_json::Value>;

fn default_schema_version() -> u32 {
    OPERATION_ENVELOPE_VERSION
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum OperationLogError {
    UnsupportedSchemaVersion {
        expected: u32,
        actual: u32,
    },
    WrongEngine {
        expected: String,
        actual: String,
        operation_id: String,
    },
    EmptyOperationId {
        sequence: u64,
    },
    EmptyDocumentId {
        operation_id: String,
    },
    EmptyArtifactDocumentId,
    EmptyActorId {
        operation_id: String,
    },
    InvalidSequence {
        operation_id: String,
        sequence: u64,
    },
    DuplicateOperationId {
        operation_id: String,
    },
    NonMonotonicSequence {
        operation_id: String,
        previous: u64,
        actual: u64,
    },
    OperationDocumentMismatch {
        operation_id: String,
        expected: String,
        actual: String,
    },
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OperationEnvelope<T> {
    #[serde(default = "default_schema_version")]
    pub schema_version: u32,
    pub operation_id: String,
    pub engine: String,
    pub document_id: String,
    pub actor_id: String,
    pub sequence: u64,
    pub timestamp_ms: u64,
    pub edit: T,
    #[serde(default, skip_serializing_if = "OperationMetadata::is_empty")]
    pub metadata: OperationMetadata,
}

impl<T> OperationEnvelope<T> {
    pub fn new(
        engine: impl Into<String>,
        operation_id: impl Into<String>,
        document_id: impl Into<String>,
        actor_id: impl Into<String>,
        sequence: u64,
        timestamp_ms: u64,
        edit: T,
    ) -> Self {
        Self {
            schema_version: OPERATION_ENVELOPE_VERSION,
            operation_id: operation_id.into(),
            engine: engine.into(),
            document_id: document_id.into(),
            actor_id: actor_id.into(),
            sequence,
            timestamp_ms,
            edit,
            metadata: OperationMetadata::new(),
        }
    }

    pub fn with_metadata_value(mut self, key: impl Into<String>, value: serde_json::Value) -> Self {
        self.metadata.insert(key.into(), value);
        self
    }

    pub fn with_metadata_text(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.metadata
            .insert(key.into(), serde_json::Value::String(value.into()));
        self
    }

    pub fn validate_for_engine(&self, expected_engine: &str) -> Result<(), OperationLogError> {
        if self.schema_version != OPERATION_ENVELOPE_VERSION {
            return Err(OperationLogError::UnsupportedSchemaVersion {
                expected: OPERATION_ENVELOPE_VERSION,
                actual: self.schema_version,
            });
        }
        if self.engine != expected_engine {
            return Err(OperationLogError::WrongEngine {
                expected: expected_engine.to_owned(),
                actual: self.engine.clone(),
                operation_id: self.operation_id.clone(),
            });
        }
        if self.operation_id.is_empty() {
            return Err(OperationLogError::EmptyOperationId {
                sequence: self.sequence,
            });
        }
        if self.document_id.is_empty() {
            return Err(OperationLogError::EmptyDocumentId {
                operation_id: self.operation_id.clone(),
            });
        }
        if self.actor_id.is_empty() {
            return Err(OperationLogError::EmptyActorId {
                operation_id: self.operation_id.clone(),
            });
        }
        if self.sequence == 0 {
            return Err(OperationLogError::InvalidSequence {
                operation_id: self.operation_id.clone(),
                sequence: self.sequence,
            });
        }
        Ok(())
    }
}

impl<T> OperationEnvelope<T>
where
    T: Serialize,
{
    pub fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(self)
    }
}

impl<T> OperationEnvelope<T>
where
    T: DeserializeOwned,
{
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OperationLog<T> {
    #[serde(default = "default_schema_version")]
    pub schema_version: u32,
    pub operations: Vec<OperationEnvelope<T>>,
    #[serde(default, skip_serializing_if = "OperationMetadata::is_empty")]
    pub metadata: OperationMetadata,
}

impl<T> Default for OperationLog<T> {
    fn default() -> Self {
        Self::new()
    }
}

impl<T> OperationLog<T> {
    pub fn new() -> Self {
        Self {
            schema_version: OPERATION_ENVELOPE_VERSION,
            operations: Vec::new(),
            metadata: OperationMetadata::new(),
        }
    }

    pub fn from_operations(operations: Vec<OperationEnvelope<T>>) -> Self {
        Self {
            schema_version: OPERATION_ENVELOPE_VERSION,
            operations,
            metadata: OperationMetadata::new(),
        }
    }

    pub fn with_metadata_value(mut self, key: impl Into<String>, value: serde_json::Value) -> Self {
        self.metadata.insert(key.into(), value);
        self
    }

    pub fn with_metadata_text(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.metadata
            .insert(key.into(), serde_json::Value::String(value.into()));
        self
    }

    pub fn push(&mut self, operation: OperationEnvelope<T>) {
        self.operations.push(operation);
    }

    pub fn push_checked(
        &mut self,
        operation: OperationEnvelope<T>,
        expected_engine: &str,
    ) -> Result<(), OperationLogError> {
        operation.validate_for_engine(expected_engine)?;
        if self
            .operations
            .iter()
            .any(|existing| existing.operation_id == operation.operation_id)
        {
            return Err(OperationLogError::DuplicateOperationId {
                operation_id: operation.operation_id,
            });
        }
        if let Some(previous) = self.operations.last() {
            if operation.sequence <= previous.sequence {
                return Err(OperationLogError::NonMonotonicSequence {
                    operation_id: operation.operation_id,
                    previous: previous.sequence,
                    actual: operation.sequence,
                });
            }
        }
        self.operations.push(operation);
        Ok(())
    }

    pub fn len(&self) -> usize {
        self.operations.len()
    }

    pub fn is_empty(&self) -> bool {
        self.operations.is_empty()
    }

    pub fn next_sequence(&self) -> u64 {
        self.operations
            .iter()
            .map(|operation| operation.sequence)
            .max()
            .unwrap_or(0)
            + 1
    }

    pub fn first_sequence(&self) -> Option<u64> {
        self.operations.first().map(|operation| operation.sequence)
    }

    pub fn last_sequence(&self) -> Option<u64> {
        self.operations.last().map(|operation| operation.sequence)
    }

    pub fn last_operation_id(&self) -> Option<&str> {
        self.operations
            .last()
            .map(|operation| operation.operation_id.as_str())
    }

    pub fn validate_for_engine(&self, expected_engine: &str) -> Result<(), OperationLogError> {
        if self.schema_version != OPERATION_ENVELOPE_VERSION {
            return Err(OperationLogError::UnsupportedSchemaVersion {
                expected: OPERATION_ENVELOPE_VERSION,
                actual: self.schema_version,
            });
        }

        let mut seen_operation_ids = BTreeSet::new();
        let mut previous_sequence = None;

        for operation in &self.operations {
            operation.validate_for_engine(expected_engine)?;

            if !seen_operation_ids.insert(operation.operation_id.as_str()) {
                return Err(OperationLogError::DuplicateOperationId {
                    operation_id: operation.operation_id.clone(),
                });
            }

            if let Some(previous) = previous_sequence {
                if operation.sequence <= previous {
                    return Err(OperationLogError::NonMonotonicSequence {
                        operation_id: operation.operation_id.clone(),
                        previous,
                        actual: operation.sequence,
                    });
                }
            }

            previous_sequence = Some(operation.sequence);
        }

        Ok(())
    }
}

impl<T> OperationLog<T>
where
    T: Serialize,
{
    pub fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(self)
    }
}

impl<T> OperationLog<T>
where
    T: DeserializeOwned,
{
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }
}

/// Serializable document state plus the ordered operation tail needed to rebuild it.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct OperationArtifact<S, T> {
    #[serde(default = "default_schema_version")]
    pub schema_version: u32,
    pub engine: String,
    pub document_id: String,
    pub snapshot: S,
    pub operation_log: OperationLog<T>,
    #[serde(default, skip_serializing_if = "OperationMetadata::is_empty")]
    pub metadata: OperationMetadata,
}

impl<S, T> OperationArtifact<S, T> {
    pub fn new(
        engine: impl Into<String>,
        document_id: impl Into<String>,
        snapshot: S,
        operation_log: OperationLog<T>,
    ) -> Self {
        Self {
            schema_version: OPERATION_ENVELOPE_VERSION,
            engine: engine.into(),
            document_id: document_id.into(),
            snapshot,
            operation_log,
            metadata: OperationMetadata::new(),
        }
    }

    pub fn with_metadata_value(mut self, key: impl Into<String>, value: serde_json::Value) -> Self {
        self.metadata.insert(key.into(), value);
        self
    }

    pub fn with_metadata_text(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.metadata
            .insert(key.into(), serde_json::Value::String(value.into()));
        self
    }

    pub fn validate_for_engine(&self, expected_engine: &str) -> Result<(), OperationLogError> {
        if self.schema_version != OPERATION_ENVELOPE_VERSION {
            return Err(OperationLogError::UnsupportedSchemaVersion {
                expected: OPERATION_ENVELOPE_VERSION,
                actual: self.schema_version,
            });
        }
        if self.engine != expected_engine {
            return Err(OperationLogError::WrongEngine {
                expected: expected_engine.to_owned(),
                actual: self.engine.clone(),
                operation_id: "<artifact>".into(),
            });
        }
        if self.document_id.is_empty() {
            return Err(OperationLogError::EmptyArtifactDocumentId);
        }

        self.operation_log.validate_for_engine(expected_engine)?;
        for operation in &self.operation_log.operations {
            if operation.document_id != self.document_id {
                return Err(OperationLogError::OperationDocumentMismatch {
                    operation_id: operation.operation_id.clone(),
                    expected: self.document_id.clone(),
                    actual: operation.document_id.clone(),
                });
            }
        }

        Ok(())
    }
}

impl<S, T> OperationArtifact<S, T>
where
    S: Serialize,
    T: Serialize,
{
    pub fn to_json(&self) -> Result<String, serde_json::Error> {
        serde_json::to_string(self)
    }
}

impl<S, T> OperationArtifact<S, T>
where
    S: DeserializeOwned,
    T: DeserializeOwned,
{
    pub fn from_json(json: &str) -> Result<Self, serde_json::Error> {
        serde_json::from_str(json)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
    enum TestEdit {
        Insert { text: String },
    }

    #[test]
    fn operation_envelope_roundtrips_with_metadata() {
        let operation = OperationEnvelope::new(
            "docs",
            "op-1",
            "doc-1",
            "actor-1",
            7,
            42_000,
            TestEdit::Insert {
                text: "hello".into(),
            },
        )
        .with_metadata_text("source", "keyboard")
        .with_metadata_value("client_version", serde_json::json!(3));

        let json = operation.to_json().unwrap();
        let restored: OperationEnvelope<TestEdit> = OperationEnvelope::from_json(&json).unwrap();

        assert_eq!(restored, operation);
        assert_eq!(restored.schema_version, OPERATION_ENVELOPE_VERSION);
    }

    #[test]
    fn operation_log_tracks_order_and_next_sequence() {
        let mut log = OperationLog::new().with_metadata_text("source", "unit-test");
        assert!(log.is_empty());
        assert_eq!(log.next_sequence(), 1);

        log.push(OperationEnvelope::new(
            "docs",
            "op-1",
            "doc-1",
            "actor-1",
            3,
            100,
            TestEdit::Insert { text: "a".into() },
        ));
        log.push(OperationEnvelope::new(
            "docs",
            "op-2",
            "doc-1",
            "actor-1",
            4,
            200,
            TestEdit::Insert { text: "b".into() },
        ));

        let json = log.to_json().unwrap();
        let restored: OperationLog<TestEdit> = OperationLog::from_json(&json).unwrap();

        assert_eq!(restored.len(), 2);
        assert_eq!(restored.metadata["source"], "unit-test");
        assert_eq!(restored.first_sequence(), Some(3));
        assert_eq!(restored.last_sequence(), Some(4));
        assert_eq!(restored.last_operation_id(), Some("op-2"));
        assert_eq!(restored.next_sequence(), 5);
        assert_eq!(restored.operations[0].operation_id, "op-1");
        assert_eq!(restored.operations[1].operation_id, "op-2");
    }

    #[test]
    fn operation_log_from_operations_keeps_order() {
        let log = OperationLog::from_operations(vec![
            OperationEnvelope::new(
                "docs",
                "op-1",
                "doc-1",
                "actor-1",
                10,
                100,
                TestEdit::Insert { text: "a".into() },
            ),
            OperationEnvelope::new(
                "docs",
                "op-2",
                "doc-1",
                "actor-1",
                11,
                200,
                TestEdit::Insert { text: "b".into() },
            ),
        ])
        .with_metadata_value("batch", serde_json::json!(7));

        assert_eq!(log.len(), 2);
        assert_eq!(log.first_sequence(), Some(10));
        assert_eq!(log.last_sequence(), Some(11));
        assert_eq!(log.metadata["batch"], 7);
        assert_eq!(log.validate_for_engine("docs"), Ok(()));
    }

    #[test]
    fn operation_log_validates_engine_ids_and_sequence_order() {
        let mut log = OperationLog::new();
        log.push(OperationEnvelope::new(
            "docs",
            "op-1",
            "doc-1",
            "actor-1",
            1,
            100,
            TestEdit::Insert { text: "a".into() },
        ));
        log.push(OperationEnvelope::new(
            "sheets",
            "op-2",
            "doc-1",
            "actor-1",
            2,
            200,
            TestEdit::Insert { text: "b".into() },
        ));

        assert_eq!(
            log.validate_for_engine("docs"),
            Err(OperationLogError::WrongEngine {
                expected: "docs".into(),
                actual: "sheets".into(),
                operation_id: "op-2".into(),
            })
        );

        log.operations[1].engine = "docs".into();
        log.operations[1].sequence = 1;

        assert_eq!(
            log.validate_for_engine("docs"),
            Err(OperationLogError::NonMonotonicSequence {
                operation_id: "op-2".into(),
                previous: 1,
                actual: 1,
            })
        );
    }

    #[test]
    fn push_checked_rejects_duplicates_without_mutating_log() {
        let mut log = OperationLog::new();
        log.push_checked(
            OperationEnvelope::new(
                "docs",
                "op-1",
                "doc-1",
                "actor-1",
                1,
                100,
                TestEdit::Insert { text: "a".into() },
            ),
            "docs",
        )
        .unwrap();

        let err = log
            .push_checked(
                OperationEnvelope::new(
                    "docs",
                    "op-1",
                    "doc-1",
                    "actor-1",
                    2,
                    200,
                    TestEdit::Insert { text: "b".into() },
                ),
                "docs",
            )
            .unwrap_err();

        assert_eq!(
            err,
            OperationLogError::DuplicateOperationId {
                operation_id: "op-1".into(),
            }
        );
        assert_eq!(log.len(), 1);
    }

    #[test]
    fn operation_artifact_validates_snapshot_log_boundary() {
        let mut log = OperationLog::new();
        log.push_checked(
            OperationEnvelope::new(
                "docs",
                "op-1",
                "doc-1",
                "actor-1",
                1,
                100,
                TestEdit::Insert { text: "a".into() },
            ),
            "docs",
        )
        .unwrap();

        let artifact = OperationArtifact::new("docs", "doc-1", "snapshot".to_owned(), log);
        let json = artifact.to_json().unwrap();
        let restored: OperationArtifact<String, TestEdit> =
            OperationArtifact::from_json(&json).unwrap();

        assert_eq!(restored, artifact);
        assert_eq!(restored.validate_for_engine("docs"), Ok(()));
    }

    #[test]
    fn operation_artifact_rejects_mismatched_operation_document() {
        let mut log = OperationLog::new();
        log.push(OperationEnvelope::new(
            "docs",
            "op-1",
            "other-doc",
            "actor-1",
            1,
            100,
            TestEdit::Insert { text: "a".into() },
        ));

        let artifact = OperationArtifact::new("docs", "doc-1", "snapshot".to_owned(), log);

        assert_eq!(
            artifact.validate_for_engine("docs"),
            Err(OperationLogError::OperationDocumentMismatch {
                operation_id: "op-1".into(),
                expected: "doc-1".into(),
                actual: "other-doc".into(),
            })
        );
    }
}
