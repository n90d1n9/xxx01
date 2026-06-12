//! Test-profile metadata for Waraq-family artifact engines.
//!
//! The individual conformance, replay, and compaction helpers each expose their
//! own required checks. This module composes those checklists into one
//! serializable profile so domain engines and tooling can assert the same shared
//! artifact expectations without duplicating checklist wiring.

use serde::{Deserialize, Serialize};

use crate::core::artifact_compaction_harness::{
    ArtifactCompactionHarnessCheck, REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS,
};
use crate::core::artifact_conformance::{
    ArtifactConformanceCheck, REQUIRED_ARTIFACT_CONFORMANCE_CHECKS,
};
use crate::core::artifact_contract::ARTIFACT_CONTRACT_VERSION;
use crate::core::artifact_lifecycle_harness::ArtifactLifecycleHarnessReport;
use crate::core::artifact_replay_harness::{
    ArtifactReplayHarnessCheck, REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS,
};

/// Shared test helper expected for a Waraq-family domain artifact engine.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DomainArtifactTestHelper {
    /// Transport-shape conformance via `validate_artifact_conformance`.
    Conformance,
    /// Domain restore/replay behavior via `validate_artifact_replay_harness`.
    ReplayHarness,
    /// Domain compaction behavior via `validate_artifact_compaction_harness`.
    CompactionHarness,
    /// Composed lifecycle behavior via `validate_artifact_lifecycle_harness`.
    LifecycleHarness,
    /// Domain-owned invalid-reference and range replay tests.
    DomainReplayTests,
}

/// Lifecycle report section checked against a domain artifact test profile.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactLifecycleProfileStage {
    /// Shared transport conformance section.
    Conformance,
    /// Domain restore/replay harness section.
    Replay,
    /// Domain compaction harness section.
    Compaction,
}

/// Error returned when a domain artifact test profile drifts from Waraq's checklist.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum DomainArtifactTestProfileError {
    /// The profile does not declare a usable engine id.
    EngineIdEmpty,
    /// The profile uses a different shared artifact contract version.
    ContractVersionMismatch {
        /// Current Waraq artifact contract version.
        expected: u32,
        /// Version carried by the profile.
        actual: u32,
    },
    /// The profile advertises an unexpected helper sequence.
    HelpersMismatch {
        /// Helper sequence expected by Waraq.
        expected: Vec<DomainArtifactTestHelper>,
        /// Helper sequence carried by the profile.
        actual: Vec<DomainArtifactTestHelper>,
    },
    /// The profile advertises an unexpected conformance checklist.
    ConformanceChecksMismatch {
        /// Checklist expected by Waraq.
        expected: Vec<ArtifactConformanceCheck>,
        /// Checklist carried by the profile.
        actual: Vec<ArtifactConformanceCheck>,
    },
    /// The profile advertises an unexpected replay harness checklist.
    ReplayHarnessChecksMismatch {
        /// Checklist expected by Waraq.
        expected: Vec<ArtifactReplayHarnessCheck>,
        /// Checklist carried by the profile.
        actual: Vec<ArtifactReplayHarnessCheck>,
    },
    /// The profile advertises an unexpected compaction harness checklist.
    CompactionHarnessChecksMismatch {
        /// Checklist expected by Waraq.
        expected: Vec<ArtifactCompactionHarnessCheck>,
        /// Checklist carried by the profile.
        actual: Vec<ArtifactCompactionHarnessCheck>,
    },
    /// The profile changed the domain-owned replay-test requirement.
    DomainReplayTestsRequiredMismatch {
        /// Requirement expected by Waraq.
        expected: bool,
        /// Requirement carried by the profile.
        actual: bool,
    },
    /// The profile changed the lifecycle harness requirement.
    LifecycleHarnessRequiredMismatch {
        /// Requirement expected by Waraq.
        expected: bool,
        /// Requirement carried by the profile.
        actual: bool,
    },
    /// The profile changed the lifecycle shared-check count.
    LifecycleSharedCheckCountMismatch {
        /// Shared-check count expected by Waraq.
        expected: Option<usize>,
        /// Shared-check count carried by the profile.
        actual: Option<usize>,
    },
}

/// Error returned when a lifecycle harness report does not match its profile.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum ArtifactLifecycleProfileError {
    /// The profile itself does not match Waraq's current shared expectations.
    Profile(DomainArtifactTestProfileError),
    /// The report was produced for a different engine id than the profile.
    EngineMismatch {
        /// Engine id expected by the profile.
        expected: String,
        /// Engine id reported by the lifecycle harness.
        actual: String,
    },
    /// The profile does not require lifecycle harness coverage.
    LifecycleHarnessNotRequired {
        /// Engine id carried by the profile.
        engine_id: String,
    },
    /// The report uses a different shared artifact contract version.
    ContractVersionMismatch {
        /// Contract version expected by the profile.
        expected: u32,
        /// Contract version reported by the conformance harness.
        actual: u32,
    },
    /// A nested lifecycle report was produced for a different engine id.
    StageEngineMismatch {
        /// Lifecycle report section with the mismatch.
        stage: ArtifactLifecycleProfileStage,
        /// Engine id expected by the profile.
        expected: String,
        /// Engine id reported by the section.
        actual: String,
    },
    /// A nested lifecycle report was produced for a different document id.
    StageDocumentMismatch {
        /// Lifecycle report section with the mismatch.
        stage: ArtifactLifecycleProfileStage,
        /// Document id expected by the lifecycle report.
        expected: String,
        /// Document id reported by the section.
        actual: String,
    },
    /// The lifecycle report completed a different number of shared checks.
    SharedCheckCountMismatch {
        /// Shared check count expected by the profile.
        expected: usize,
        /// Shared check count reported by the lifecycle harness.
        actual: usize,
    },
    /// The profile's lifecycle count drifted from its own check lists.
    ProfileCheckCountMismatch {
        /// Shared check count configured for lifecycle harness reports.
        lifecycle_expected: usize,
        /// Shared check count derived from the profile check lists.
        checklist_count: usize,
    },
    /// The conformance section completed a different checklist.
    ConformanceChecksMismatch {
        /// Checklist expected by the profile.
        expected: Vec<ArtifactConformanceCheck>,
        /// Checklist reported by the conformance harness.
        actual: Vec<ArtifactConformanceCheck>,
    },
    /// The replay section completed a different checklist.
    ReplayHarnessChecksMismatch {
        /// Checklist expected by the profile.
        expected: Vec<ArtifactReplayHarnessCheck>,
        /// Checklist reported by the replay harness.
        actual: Vec<ArtifactReplayHarnessCheck>,
    },
    /// The compaction section completed a different checklist.
    CompactionHarnessChecksMismatch {
        /// Checklist expected by the profile.
        expected: Vec<ArtifactCompactionHarnessCheck>,
        /// Checklist reported by the compaction harness.
        actual: Vec<ArtifactCompactionHarnessCheck>,
    },
}

/// Serializable checklist of shared artifact tests for one domain engine.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DomainArtifactTestProfile {
    /// Shared artifact contract version expected by the profile.
    pub contract_version: u32,
    /// Stable engine identifier used by the domain engine.
    pub engine_id: String,
    /// Required helper families in the order engines should usually implement them.
    pub helpers: Vec<DomainArtifactTestHelper>,
    /// Required checks completed by `validate_artifact_conformance`.
    pub conformance_checks: Vec<ArtifactConformanceCheck>,
    /// Required checks completed by `validate_artifact_replay_harness`.
    pub replay_harness_checks: Vec<ArtifactReplayHarnessCheck>,
    /// Required checks completed by `validate_artifact_compaction_harness`.
    pub compaction_harness_checks: Vec<ArtifactCompactionHarnessCheck>,
    /// True when the engine should keep domain-owned replay tests beyond Waraq's shared helpers.
    pub domain_replay_tests_required: bool,
    /// True when this profile expects compaction support and compaction harness coverage.
    pub compaction_harness_required: bool,
    /// True when this profile expects one composed lifecycle harness test.
    pub lifecycle_harness_required: bool,
    /// Shared check count a lifecycle harness report should complete.
    pub lifecycle_harness_shared_check_count: Option<usize>,
}

/// Summary returned when a domain artifact test profile matches Waraq's checklist.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DomainArtifactTestProfileValidationReport {
    /// Shared artifact contract version validated for the profile.
    pub contract_version: u32,
    /// Stable engine identifier carried by the profile.
    pub engine_id: String,
    /// Number of helper families advertised by the profile.
    pub helper_count: usize,
    /// Number of conformance checks advertised by the profile.
    pub conformance_check_count: usize,
    /// Number of replay harness checks advertised by the profile.
    pub replay_harness_check_count: usize,
    /// Number of compaction harness checks advertised by the profile.
    pub compaction_harness_check_count: usize,
    /// Total number of shared checks required by the profile.
    pub required_shared_check_count: usize,
    /// True when domain-owned replay tests are required.
    pub domain_replay_tests_required: bool,
    /// True when compaction harness coverage is required.
    pub compaction_harness_required: bool,
    /// True when lifecycle harness coverage is required.
    pub lifecycle_harness_required: bool,
    /// Shared check count expected from lifecycle harness reports.
    pub lifecycle_harness_shared_check_count: Option<usize>,
}

/// Summary returned when a lifecycle harness report matches its domain profile.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ArtifactLifecycleProfileValidationReport {
    /// Shared artifact contract version validated for the lifecycle proof.
    pub contract_version: u32,
    /// Stable engine identifier validated across profile and lifecycle report.
    pub engine_id: String,
    /// Document identifier validated across lifecycle report sections.
    pub document_id: String,
    /// Validated profile summary used as the expected checklist.
    pub profile: DomainArtifactTestProfileValidationReport,
    /// Shared check count expected from the lifecycle report.
    pub expected_shared_check_count: usize,
    /// Shared check count completed by the lifecycle report.
    pub completed_shared_check_count: usize,
    /// Number of conformance checks completed by the lifecycle report.
    pub completed_conformance_check_count: usize,
    /// Number of replay harness checks completed by the lifecycle report.
    pub completed_replay_harness_check_count: usize,
    /// Number of compaction harness checks completed by the lifecycle report.
    pub completed_compaction_harness_check_count: usize,
}

impl DomainArtifactTestProfile {
    /// Total number of shared Waraq checks expected by this profile.
    pub fn required_shared_check_count(&self) -> usize {
        self.conformance_checks.len()
            + self.replay_harness_checks.len()
            + self.compaction_harness_checks.len()
    }

    /// Shared check count expected from a lifecycle harness report, when required.
    pub fn required_lifecycle_shared_check_count(&self) -> Option<usize> {
        self.lifecycle_harness_shared_check_count
    }
}

/// Validate that a domain artifact test profile matches Waraq's shared checklist.
pub fn validate_domain_artifact_test_profile(
    profile: &DomainArtifactTestProfile,
) -> Result<(), DomainArtifactTestProfileError> {
    validate_domain_artifact_test_profile_report(profile).map(|_| ())
}

/// Validate a profile and return its shared coverage summary.
pub fn validate_domain_artifact_test_profile_report(
    profile: &DomainArtifactTestProfile,
) -> Result<DomainArtifactTestProfileValidationReport, DomainArtifactTestProfileError> {
    if profile.engine_id.trim().is_empty() {
        return Err(DomainArtifactTestProfileError::EngineIdEmpty);
    }
    if profile.contract_version != ARTIFACT_CONTRACT_VERSION {
        return Err(DomainArtifactTestProfileError::ContractVersionMismatch {
            expected: ARTIFACT_CONTRACT_VERSION,
            actual: profile.contract_version,
        });
    }

    let supports_compaction = profile.compaction_harness_required;
    let expected_helpers = expected_artifact_test_helpers(supports_compaction);
    if profile.helpers != expected_helpers {
        return Err(DomainArtifactTestProfileError::HelpersMismatch {
            expected: expected_helpers,
            actual: profile.helpers.clone(),
        });
    }

    let expected_conformance_checks = REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.to_vec();
    if profile.conformance_checks != expected_conformance_checks {
        return Err(DomainArtifactTestProfileError::ConformanceChecksMismatch {
            expected: expected_conformance_checks,
            actual: profile.conformance_checks.clone(),
        });
    }

    let expected_replay_checks = REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.to_vec();
    if profile.replay_harness_checks != expected_replay_checks {
        return Err(
            DomainArtifactTestProfileError::ReplayHarnessChecksMismatch {
                expected: expected_replay_checks,
                actual: profile.replay_harness_checks.clone(),
            },
        );
    }

    let expected_compaction_checks = expected_compaction_harness_checks(supports_compaction);
    if profile.compaction_harness_checks != expected_compaction_checks {
        return Err(
            DomainArtifactTestProfileError::CompactionHarnessChecksMismatch {
                expected: expected_compaction_checks,
                actual: profile.compaction_harness_checks.clone(),
            },
        );
    }

    if !profile.domain_replay_tests_required {
        return Err(
            DomainArtifactTestProfileError::DomainReplayTestsRequiredMismatch {
                expected: true,
                actual: profile.domain_replay_tests_required,
            },
        );
    }

    let expected_lifecycle_required = supports_compaction;
    if profile.lifecycle_harness_required != expected_lifecycle_required {
        return Err(
            DomainArtifactTestProfileError::LifecycleHarnessRequiredMismatch {
                expected: expected_lifecycle_required,
                actual: profile.lifecycle_harness_required,
            },
        );
    }

    let expected_lifecycle_count = expected_lifecycle_shared_check_count(supports_compaction);
    if profile.lifecycle_harness_shared_check_count != expected_lifecycle_count {
        return Err(
            DomainArtifactTestProfileError::LifecycleSharedCheckCountMismatch {
                expected: expected_lifecycle_count,
                actual: profile.lifecycle_harness_shared_check_count,
            },
        );
    }

    Ok(DomainArtifactTestProfileValidationReport {
        contract_version: profile.contract_version,
        engine_id: profile.engine_id.clone(),
        helper_count: profile.helpers.len(),
        conformance_check_count: profile.conformance_checks.len(),
        replay_harness_check_count: profile.replay_harness_checks.len(),
        compaction_harness_check_count: profile.compaction_harness_checks.len(),
        required_shared_check_count: profile.required_shared_check_count(),
        domain_replay_tests_required: profile.domain_replay_tests_required,
        compaction_harness_required: profile.compaction_harness_required,
        lifecycle_harness_required: profile.lifecycle_harness_required,
        lifecycle_harness_shared_check_count: profile.lifecycle_harness_shared_check_count,
    })
}

/// Validate that a lifecycle harness report matches a domain test profile.
pub fn validate_artifact_lifecycle_profile(
    profile: &DomainArtifactTestProfile,
    report: &ArtifactLifecycleHarnessReport,
) -> Result<(), ArtifactLifecycleProfileError> {
    validate_artifact_lifecycle_profile_report(profile, report).map(|_| ())
}

/// Validate a lifecycle harness report and return its shared coverage summary.
pub fn validate_artifact_lifecycle_profile_report(
    profile: &DomainArtifactTestProfile,
    report: &ArtifactLifecycleHarnessReport,
) -> Result<ArtifactLifecycleProfileValidationReport, ArtifactLifecycleProfileError> {
    let profile_report = validate_domain_artifact_test_profile_report(profile)
        .map_err(ArtifactLifecycleProfileError::Profile)?;

    if profile.engine_id != report.engine_id {
        return Err(ArtifactLifecycleProfileError::EngineMismatch {
            expected: profile.engine_id.clone(),
            actual: report.engine_id.clone(),
        });
    }

    let Some(expected_count) = profile_report.lifecycle_harness_shared_check_count else {
        return Err(ArtifactLifecycleProfileError::LifecycleHarnessNotRequired {
            engine_id: profile.engine_id.clone(),
        });
    };

    if !profile.lifecycle_harness_required {
        return Err(ArtifactLifecycleProfileError::LifecycleHarnessNotRequired {
            engine_id: profile.engine_id.clone(),
        });
    }

    if profile.contract_version != report.conformance.contract_version {
        return Err(ArtifactLifecycleProfileError::ContractVersionMismatch {
            expected: profile.contract_version,
            actual: report.conformance.contract_version,
        });
    }

    let checklist_count = profile_report.required_shared_check_count;
    if expected_count != checklist_count {
        return Err(ArtifactLifecycleProfileError::ProfileCheckCountMismatch {
            lifecycle_expected: expected_count,
            checklist_count,
        });
    }

    if report.completed_shared_check_count != expected_count {
        return Err(ArtifactLifecycleProfileError::SharedCheckCountMismatch {
            expected: expected_count,
            actual: report.completed_shared_check_count,
        });
    }

    validate_stage_identity(
        ArtifactLifecycleProfileStage::Conformance,
        &profile.engine_id,
        &report.document_id,
        &report.conformance.engine_id,
        &report.conformance.document_id,
    )?;
    validate_stage_identity(
        ArtifactLifecycleProfileStage::Replay,
        &profile.engine_id,
        &report.document_id,
        &report.replay.engine_id,
        &report.replay.document_id,
    )?;
    validate_stage_identity(
        ArtifactLifecycleProfileStage::Compaction,
        &profile.engine_id,
        &report.document_id,
        &report.compaction.engine_id,
        &report.compaction.document_id,
    )?;

    if report.conformance.completed_checks != profile.conformance_checks {
        return Err(ArtifactLifecycleProfileError::ConformanceChecksMismatch {
            expected: profile.conformance_checks.clone(),
            actual: report.conformance.completed_checks.clone(),
        });
    }
    if report.replay.completed_checks != profile.replay_harness_checks {
        return Err(ArtifactLifecycleProfileError::ReplayHarnessChecksMismatch {
            expected: profile.replay_harness_checks.clone(),
            actual: report.replay.completed_checks.clone(),
        });
    }
    if report.compaction.completed_checks != profile.compaction_harness_checks {
        return Err(
            ArtifactLifecycleProfileError::CompactionHarnessChecksMismatch {
                expected: profile.compaction_harness_checks.clone(),
                actual: report.compaction.completed_checks.clone(),
            },
        );
    }

    Ok(ArtifactLifecycleProfileValidationReport {
        contract_version: profile_report.contract_version,
        engine_id: report.engine_id.clone(),
        document_id: report.document_id.clone(),
        expected_shared_check_count: expected_count,
        completed_shared_check_count: report.completed_shared_check_count,
        completed_conformance_check_count: report.conformance.completed_checks.len(),
        completed_replay_harness_check_count: report.replay.completed_checks.len(),
        completed_compaction_harness_check_count: report.compaction.completed_checks.len(),
        profile: profile_report,
    })
}

fn validate_stage_identity(
    stage: ArtifactLifecycleProfileStage,
    expected_engine: &str,
    expected_document: &str,
    actual_engine: &str,
    actual_document: &str,
) -> Result<(), ArtifactLifecycleProfileError> {
    if actual_engine != expected_engine {
        return Err(ArtifactLifecycleProfileError::StageEngineMismatch {
            stage,
            expected: expected_engine.to_owned(),
            actual: actual_engine.to_owned(),
        });
    }
    if actual_document != expected_document {
        return Err(ArtifactLifecycleProfileError::StageDocumentMismatch {
            stage,
            expected: expected_document.to_owned(),
            actual: actual_document.to_owned(),
        });
    }

    Ok(())
}

/// Build the standard shared test profile for a compaction-capable domain engine.
pub fn domain_artifact_test_profile(engine_id: impl Into<String>) -> DomainArtifactTestProfile {
    domain_artifact_test_profile_with_compaction(engine_id, true)
}

/// Build a shared artifact test profile, optionally omitting compaction coverage.
///
/// Use the compaction-free form only for short-lived or read-only artifact
/// experiments. Long-lived docs, sheets, slides, code, and notebook engines
/// should expose compaction and use the default `domain_artifact_test_profile`.
pub fn domain_artifact_test_profile_with_compaction(
    engine_id: impl Into<String>,
    supports_compaction: bool,
) -> DomainArtifactTestProfile {
    DomainArtifactTestProfile {
        contract_version: ARTIFACT_CONTRACT_VERSION,
        engine_id: engine_id.into(),
        helpers: expected_artifact_test_helpers(supports_compaction),
        conformance_checks: REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.to_vec(),
        replay_harness_checks: REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.to_vec(),
        compaction_harness_checks: expected_compaction_harness_checks(supports_compaction),
        domain_replay_tests_required: true,
        compaction_harness_required: supports_compaction,
        lifecycle_harness_required: supports_compaction,
        lifecycle_harness_shared_check_count: expected_lifecycle_shared_check_count(
            supports_compaction,
        ),
    }
}

fn expected_artifact_test_helpers(supports_compaction: bool) -> Vec<DomainArtifactTestHelper> {
    let mut helpers = vec![
        DomainArtifactTestHelper::Conformance,
        DomainArtifactTestHelper::ReplayHarness,
    ];
    if supports_compaction {
        helpers.push(DomainArtifactTestHelper::CompactionHarness);
        helpers.push(DomainArtifactTestHelper::LifecycleHarness);
    }
    helpers.push(DomainArtifactTestHelper::DomainReplayTests);
    helpers
}

fn expected_compaction_harness_checks(
    supports_compaction: bool,
) -> Vec<ArtifactCompactionHarnessCheck> {
    if supports_compaction {
        REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.to_vec()
    } else {
        Vec::new()
    }
}

fn expected_lifecycle_shared_check_count(supports_compaction: bool) -> Option<usize> {
    supports_compaction.then(|| {
        REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
            + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
            + REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len()
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::core::artifact_compaction_harness::ArtifactCompactionHarnessReport;
    use crate::core::artifact_conformance::ArtifactConformanceReport;
    use crate::core::artifact_replay_harness::{
        ArtifactReplayHarnessCheck, ArtifactReplayHarnessReport,
    };

    fn lifecycle_report(engine_id: &str) -> ArtifactLifecycleHarnessReport {
        ArtifactLifecycleHarnessReport {
            engine_id: engine_id.to_owned(),
            document_id: "doc-1".to_owned(),
            conformance: ArtifactConformanceReport {
                contract_version: ARTIFACT_CONTRACT_VERSION,
                engine_id: engine_id.to_owned(),
                document_id: "doc-1".to_owned(),
                operation_count: 3,
                first_sequence: Some(1),
                last_sequence: Some(3),
                last_operation_id: Some("op-3".to_owned()),
                completed_checks: REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.to_vec(),
                checked_json_roundtrip: true,
                checked_wrong_engine_rejection: true,
                checked_wrong_document_rejection: true,
            },
            replay: ArtifactReplayHarnessReport {
                engine_id: engine_id.to_owned(),
                document_id: "doc-1".to_owned(),
                operation_count: 3,
                completed_checks: REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.to_vec(),
            },
            compaction: ArtifactCompactionHarnessReport {
                engine_id: engine_id.to_owned(),
                document_id: "doc-1".to_owned(),
                source_operation_count: 3,
                compacted_operation_count: 2,
                retained_operation_count: 1,
                completed_checks: REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.to_vec(),
            },
            completed_shared_check_count: REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
                + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
                + REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS.len(),
        }
    }

    #[test]
    fn domain_artifact_test_profile_composes_required_shared_checks() {
        let profile = domain_artifact_test_profile("waraq.test");

        assert_eq!(profile.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(profile.engine_id, "waraq.test");
        assert_eq!(
            profile.helpers,
            vec![
                DomainArtifactTestHelper::Conformance,
                DomainArtifactTestHelper::ReplayHarness,
                DomainArtifactTestHelper::CompactionHarness,
                DomainArtifactTestHelper::LifecycleHarness,
                DomainArtifactTestHelper::DomainReplayTests,
            ]
        );
        assert_eq!(
            profile.conformance_checks.as_slice(),
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS
        );
        assert_eq!(
            profile.replay_harness_checks.as_slice(),
            REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS
        );
        assert_eq!(
            profile.compaction_harness_checks.as_slice(),
            REQUIRED_ARTIFACT_COMPACTION_HARNESS_CHECKS
        );
        assert!(profile.domain_replay_tests_required);
        assert!(profile.compaction_harness_required);
        assert!(profile.lifecycle_harness_required);
        assert_eq!(profile.required_shared_check_count(), 22);
        assert_eq!(profile.required_lifecycle_shared_check_count(), Some(22));
        let report = validate_domain_artifact_test_profile_report(&profile).unwrap();
        assert_eq!(report.contract_version, ARTIFACT_CONTRACT_VERSION);
        assert_eq!(report.engine_id, "waraq.test");
        assert_eq!(report.helper_count, 5);
        assert_eq!(report.conformance_check_count, 10);
        assert_eq!(report.replay_harness_check_count, 4);
        assert_eq!(report.compaction_harness_check_count, 8);
        assert_eq!(report.required_shared_check_count, 22);
        assert!(report.domain_replay_tests_required);
        assert!(report.compaction_harness_required);
        assert!(report.lifecycle_harness_required);
        assert_eq!(report.lifecycle_harness_shared_check_count, Some(22));
    }

    #[test]
    fn domain_artifact_test_profile_can_omit_compaction_for_experiments() {
        let profile = domain_artifact_test_profile_with_compaction("waraq.experimental", false);

        assert_eq!(
            profile.helpers,
            vec![
                DomainArtifactTestHelper::Conformance,
                DomainArtifactTestHelper::ReplayHarness,
                DomainArtifactTestHelper::DomainReplayTests,
            ]
        );
        assert!(profile.compaction_harness_checks.is_empty());
        assert!(!profile.compaction_harness_required);
        assert!(!profile.lifecycle_harness_required);
        assert_eq!(profile.required_lifecycle_shared_check_count(), None);
        assert_eq!(
            profile.required_shared_check_count(),
            REQUIRED_ARTIFACT_CONFORMANCE_CHECKS.len()
                + REQUIRED_ARTIFACT_REPLAY_HARNESS_CHECKS.len()
        );
        let report = validate_domain_artifact_test_profile_report(&profile).unwrap();
        assert_eq!(report.helper_count, 3);
        assert_eq!(report.compaction_harness_check_count, 0);
        assert_eq!(report.required_shared_check_count, 14);
        assert!(!report.compaction_harness_required);
        assert!(!report.lifecycle_harness_required);
        assert_eq!(report.lifecycle_harness_shared_check_count, None);
    }

    #[test]
    fn domain_artifact_test_profile_serializes_for_tooling() {
        let value = serde_json::to_value(domain_artifact_test_profile("waraq.test")).unwrap();

        assert_eq!(value["engine_id"], "waraq.test");
        assert_eq!(value["helpers"][0], "Conformance");
        assert_eq!(value["helpers"][2], "CompactionHarness");
        assert_eq!(value["helpers"][3], "LifecycleHarness");
        assert_eq!(value["lifecycle_harness_required"], true);
        assert_eq!(value["lifecycle_harness_shared_check_count"], 22);
        assert_eq!(value["conformance_checks"][0], "ArtifactValidation");
        assert_eq!(value["replay_harness_checks"][0], "ValidRestore");
        assert_eq!(
            value["compaction_harness_checks"][0],
            "CompactedRestoreEquivalent"
        );
    }

    #[test]
    fn domain_artifact_test_profile_validation_report_serializes_for_tooling() {
        let report = validate_domain_artifact_test_profile_report(&domain_artifact_test_profile(
            "waraq.test",
        ))
        .unwrap();
        let value = serde_json::to_value(report).unwrap();

        assert_eq!(value["engine_id"], "waraq.test");
        assert_eq!(value["helper_count"], 5);
        assert_eq!(value["conformance_check_count"], 10);
        assert_eq!(value["replay_harness_check_count"], 4);
        assert_eq!(value["compaction_harness_check_count"], 8);
        assert_eq!(value["required_shared_check_count"], 22);
        assert_eq!(value["lifecycle_harness_shared_check_count"], 22);
    }

    #[test]
    fn domain_artifact_test_profile_validates_lifecycle_report() {
        let profile = domain_artifact_test_profile("waraq.test");
        let report = lifecycle_report("waraq.test");

        let validation_report =
            validate_artifact_lifecycle_profile_report(&profile, &report).unwrap();

        assert_eq!(
            validation_report.contract_version,
            ARTIFACT_CONTRACT_VERSION
        );
        assert_eq!(validation_report.engine_id, "waraq.test");
        assert_eq!(validation_report.document_id, "doc-1");
        assert_eq!(validation_report.expected_shared_check_count, 22);
        assert_eq!(validation_report.completed_shared_check_count, 22);
        assert_eq!(validation_report.completed_conformance_check_count, 10);
        assert_eq!(validation_report.completed_replay_harness_check_count, 4);
        assert_eq!(
            validation_report.completed_compaction_harness_check_count,
            8
        );
        assert_eq!(validation_report.profile.engine_id, "waraq.test");
    }

    #[test]
    fn artifact_lifecycle_profile_validation_report_serializes_for_tooling() {
        let profile = domain_artifact_test_profile("waraq.test");
        let report = lifecycle_report("waraq.test");
        let value = serde_json::to_value(
            validate_artifact_lifecycle_profile_report(&profile, &report).unwrap(),
        )
        .unwrap();

        assert_eq!(value["engine_id"], "waraq.test");
        assert_eq!(value["document_id"], "doc-1");
        assert_eq!(value["expected_shared_check_count"], 22);
        assert_eq!(value["completed_shared_check_count"], 22);
        assert_eq!(value["completed_conformance_check_count"], 10);
        assert_eq!(value["completed_replay_harness_check_count"], 4);
        assert_eq!(value["completed_compaction_harness_check_count"], 8);
        assert_eq!(value["profile"]["required_shared_check_count"], 22);
    }

    #[test]
    fn domain_artifact_test_profile_rejects_empty_engine_id() {
        let mut profile = domain_artifact_test_profile(" ");

        let err = validate_domain_artifact_test_profile(&profile).unwrap_err();

        assert_eq!(err, DomainArtifactTestProfileError::EngineIdEmpty);

        profile.engine_id = "waraq.test".to_owned();
        validate_domain_artifact_test_profile(&profile).unwrap();
    }

    #[test]
    fn domain_artifact_test_profile_rejects_helper_drift() {
        let mut profile = domain_artifact_test_profile("waraq.test");
        profile
            .helpers
            .retain(|helper| *helper != DomainArtifactTestHelper::LifecycleHarness);

        let err = validate_domain_artifact_test_profile(&profile).unwrap_err();

        assert!(matches!(
            err,
            DomainArtifactTestProfileError::HelpersMismatch { .. }
        ));
    }

    #[test]
    fn domain_artifact_test_profile_rejects_lifecycle_count_drift() {
        let mut profile = domain_artifact_test_profile("waraq.test");
        profile.lifecycle_harness_shared_check_count = Some(21);

        let err = validate_domain_artifact_test_profile(&profile).unwrap_err();

        assert!(matches!(
            err,
            DomainArtifactTestProfileError::LifecycleSharedCheckCountMismatch { .. }
        ));
    }

    #[test]
    fn lifecycle_profile_validation_rejects_invalid_profile_first() {
        let mut profile = domain_artifact_test_profile("waraq.test");
        profile.domain_replay_tests_required = false;
        let report = lifecycle_report("waraq.test");

        let err = validate_artifact_lifecycle_profile(&profile, &report).unwrap_err();

        assert!(matches!(
            err,
            ArtifactLifecycleProfileError::Profile(
                DomainArtifactTestProfileError::DomainReplayTestsRequiredMismatch { .. }
            )
        ));
    }

    #[test]
    fn domain_artifact_test_profile_rejects_lifecycle_wrong_engine() {
        let profile = domain_artifact_test_profile("waraq.test");
        let report = lifecycle_report("wrong.engine");

        let err = validate_artifact_lifecycle_profile(&profile, &report).unwrap_err();

        assert!(matches!(
            err,
            ArtifactLifecycleProfileError::EngineMismatch { .. }
        ));
    }

    #[test]
    fn domain_artifact_test_profile_rejects_lifecycle_when_not_required() {
        let profile = domain_artifact_test_profile_with_compaction("waraq.experimental", false);
        let report = lifecycle_report("waraq.experimental");

        let err = validate_artifact_lifecycle_profile(&profile, &report).unwrap_err();

        assert!(matches!(
            err,
            ArtifactLifecycleProfileError::LifecycleHarnessNotRequired { .. }
        ));
    }

    #[test]
    fn domain_artifact_test_profile_rejects_lifecycle_check_drift() {
        let profile = domain_artifact_test_profile("waraq.test");
        let mut report = lifecycle_report("waraq.test");
        report.replay.completed_checks = vec![
            ArtifactReplayHarnessCheck::WrongEngineRejection,
            ArtifactReplayHarnessCheck::ValidRestore,
            ArtifactReplayHarnessCheck::WrongDocumentRejection,
            ArtifactReplayHarnessCheck::InvalidReplayNoPartialMutation,
        ];

        let err = validate_artifact_lifecycle_profile(&profile, &report).unwrap_err();

        assert!(matches!(
            err,
            ArtifactLifecycleProfileError::ReplayHarnessChecksMismatch { .. }
        ));
    }
}
