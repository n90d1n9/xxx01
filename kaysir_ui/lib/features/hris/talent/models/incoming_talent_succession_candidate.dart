enum IncomingTalentSuccessionReadiness {
  readyNow('Ready now'),
  readySoon('Ready soon'),
  developing('Developing'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionReadiness(this.label);
}

enum IncomingTalentSuccessionRisk {
  low('Low risk'),
  medium('Medium risk'),
  high('High risk');

  final String label;

  const IncomingTalentSuccessionRisk(this.label);
}

/// Candidate summary used to rank and explain succession slate readiness.
class IncomingTalentSuccessionCandidate {
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String promotionTrack;
  final IncomingTalentSuccessionReadiness readiness;
  final IncomingTalentSuccessionRisk risk;
  final int readinessScore;
  final int confidenceScore;
  final int openInterventionCount;
  final String latestCalibrationDecisionLabel;
  final String evidenceSummary;
  final String nextAction;
  final DateTime? latestEvidenceDate;

  const IncomingTalentSuccessionCandidate({
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.promotionTrack,
    required this.readiness,
    required this.risk,
    required this.readinessScore,
    required this.confidenceScore,
    required this.openInterventionCount,
    required this.latestCalibrationDecisionLabel,
    required this.evidenceSummary,
    required this.nextAction,
    required this.latestEvidenceDate,
  });

  bool get needsAttention {
    return readiness == IncomingTalentSuccessionReadiness.blocked ||
        readiness == IncomingTalentSuccessionReadiness.developing ||
        risk != IncomingTalentSuccessionRisk.low ||
        openInterventionCount > 0;
  }

  bool get isSuccessionReady {
    return readiness == IncomingTalentSuccessionReadiness.readyNow ||
        readiness == IncomingTalentSuccessionReadiness.readySoon;
  }

  double get readinessRatio => readinessScore / 100;
}
