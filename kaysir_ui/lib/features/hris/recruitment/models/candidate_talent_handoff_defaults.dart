import 'candidate_development_calibration_models.dart';
import 'candidate_talent_handoff.dart';

class CandidateTalentHandoffDefaults {
  const CandidateTalentHandoffDefaults._();

  static CandidateTalentHandoffType typeFromOutcome(
    CandidateDevelopmentCalibrationOutcome outcome,
  ) {
    return switch (outcome) {
      CandidateDevelopmentCalibrationOutcome.confirmReady =>
        CandidateTalentHandoffType.offerTransition,
      CandidateDevelopmentCalibrationOutcome.continuePlan =>
        CandidateTalentHandoffType.preboarding,
      CandidateDevelopmentCalibrationOutcome.extendTimeline =>
        CandidateTalentHandoffType.deferred,
      CandidateDevelopmentCalibrationOutcome.escalate =>
        CandidateTalentHandoffType.deferred,
    };
  }

  static CandidateTalentHandoffStatus statusFromReview(
    CandidateDevelopmentCalibrationReview review,
  ) {
    if (review.outcome == CandidateDevelopmentCalibrationOutcome.escalate ||
        review.readinessScore < 60) {
      return CandidateTalentHandoffStatus.blocked;
    }
    if (review.outcome == CandidateDevelopmentCalibrationOutcome.confirmReady &&
        review.readinessScore >= 80) {
      return CandidateTalentHandoffStatus.ready;
    }
    return CandidateTalentHandoffStatus.watch;
  }

  static Duration targetOffset(CandidateDevelopmentCalibrationOutcome outcome) {
    return switch (outcome) {
      CandidateDevelopmentCalibrationOutcome.confirmReady => const Duration(
        days: 7,
      ),
      CandidateDevelopmentCalibrationOutcome.continuePlan => const Duration(
        days: 14,
      ),
      CandidateDevelopmentCalibrationOutcome.extendTimeline => const Duration(
        days: 21,
      ),
      CandidateDevelopmentCalibrationOutcome.escalate => const Duration(
        days: 21,
      ),
    };
  }

  static String managerForDepartment(String department) {
    return switch (department.toLowerCase()) {
      'engineering' => 'Engineering Manager',
      'finance' => 'Finance Manager',
      'operations' => 'Operations Manager',
      'people' => 'People Partner Lead',
      _ => '$department Manager',
    };
  }
}
