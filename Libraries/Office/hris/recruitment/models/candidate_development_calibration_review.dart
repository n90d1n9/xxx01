import 'candidate_development_calibration_profile.dart';

enum CandidateDevelopmentCalibrationOutcome {
  confirmReady('Confirm ready'),
  continuePlan('Continue plan'),
  extendTimeline('Extend timeline'),
  escalate('Escalate');

  final String label;

  const CandidateDevelopmentCalibrationOutcome(this.label);
}

class CandidateDevelopmentCalibrationReview {
  final String id;
  final String objectiveId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateDevelopmentCalibrationStatus status;
  final CandidateDevelopmentCalibrationOutcome outcome;
  final int readinessScore;
  final String ownerName;
  final DateTime reviewDate;
  final String note;
  final String nextAction;
  final DateTime createdAt;

  const CandidateDevelopmentCalibrationReview({
    required this.id,
    required this.objectiveId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.status,
    required this.outcome,
    required this.readinessScore,
    required this.ownerName,
    required this.reviewDate,
    required this.note,
    required this.nextAction,
    required this.createdAt,
  });
}
