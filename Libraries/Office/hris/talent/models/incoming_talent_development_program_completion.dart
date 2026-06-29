enum IncomingTalentDevelopmentProgramCompletionDecision {
  credentialed('Credentialed'),
  roleReady('Role ready'),
  extendProgram('Extend program'),
  evidenceArchived('Evidence archived');

  final String label;

  const IncomingTalentDevelopmentProgramCompletionDecision(this.label);
}

enum IncomingTalentDevelopmentProgramCredentialLevel {
  foundational('Foundational'),
  roleReady('Role ready'),
  advanced('Advanced');

  final String label;

  const IncomingTalentDevelopmentProgramCredentialLevel(this.label);
}

class IncomingTalentDevelopmentProgramCompletion {
  final String id;
  final String milestoneId;
  final String enrollmentId;
  final String programId;
  final String programTitle;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final IncomingTalentDevelopmentProgramCompletionDecision decision;
  final IncomingTalentDevelopmentProgramCredentialLevel credentialLevel;
  final int score;
  final DateTime completedAt;
  final DateTime? renewalDate;
  final String credentialNote;
  final String managerRecommendation;
  final DateTime createdAt;

  const IncomingTalentDevelopmentProgramCompletion({
    required this.id,
    required this.milestoneId,
    required this.enrollmentId,
    required this.programId,
    required this.programTitle,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.decision,
    required this.credentialLevel,
    required this.score,
    required this.completedAt,
    required this.renewalDate,
    required this.credentialNote,
    required this.managerRecommendation,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision ==
            IncomingTalentDevelopmentProgramCompletionDecision.extendProgram ||
        score < 70;
  }

  bool get isRoleReady {
    return decision ==
        IncomingTalentDevelopmentProgramCompletionDecision.roleReady;
  }

  double get scoreRatio => score / 100;
}
