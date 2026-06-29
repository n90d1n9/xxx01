enum CandidateTalentHandoffType {
  offerTransition('Offer transition'),
  preboarding('Preboarding'),
  talentBench('Talent bench'),
  deferred('Deferred');

  final String label;

  const CandidateTalentHandoffType(this.label);
}

enum CandidateTalentHandoffStatus {
  ready('Ready'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const CandidateTalentHandoffStatus(this.label);
}

enum CandidateTalentHandoffRisk {
  low('Low risk'),
  medium('Medium risk'),
  high('High risk');

  final String label;

  const CandidateTalentHandoffRisk(this.label);
}

class CandidateTalentHandoff {
  final String id;
  final String calibrationReviewId;
  final String objectiveId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateTalentHandoffType type;
  final CandidateTalentHandoffStatus status;
  final int readinessScore;
  final String ownerName;
  final String receivingManagerName;
  final DateTime targetStartDate;
  final DateTime firstCheckpointDate;
  final String talentFocus;
  final String handoffNote;
  final DateTime createdAt;

  const CandidateTalentHandoff({
    required this.id,
    required this.calibrationReviewId,
    required this.objectiveId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.type,
    required this.status,
    required this.readinessScore,
    required this.ownerName,
    required this.receivingManagerName,
    required this.targetStartDate,
    required this.firstCheckpointDate,
    required this.talentFocus,
    required this.handoffNote,
    required this.createdAt,
  });

  CandidateTalentHandoffRisk get risk {
    if (status == CandidateTalentHandoffStatus.blocked || readinessScore < 60) {
      return CandidateTalentHandoffRisk.high;
    }
    if (status == CandidateTalentHandoffStatus.watch || readinessScore < 80) {
      return CandidateTalentHandoffRisk.medium;
    }
    return CandidateTalentHandoffRisk.low;
  }

  bool get needsAttention => risk != CandidateTalentHandoffRisk.low;
}
