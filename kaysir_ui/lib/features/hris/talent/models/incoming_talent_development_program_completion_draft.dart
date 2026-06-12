import 'incoming_talent_development_program_completion.dart';
import 'incoming_talent_development_program_milestone.dart';

class IncomingTalentDevelopmentProgramCompletionDraft {
  final String milestoneId;
  final String enrollmentId;
  final String programId;
  final String programTitle;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final IncomingTalentDevelopmentProgramCompletionDecision? decision;
  final IncomingTalentDevelopmentProgramCredentialLevel? credentialLevel;
  final int score;
  final DateTime? completedAt;
  final DateTime? renewalDate;
  final String credentialNote;
  final String managerRecommendation;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentProgramCompletionDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentProgramCompletionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentProgramCompletionDraft(
      milestoneId: '',
      enrollmentId: '',
      programId: '',
      programTitle: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      reviewerName: '',
      decision: null,
      credentialLevel: null,
      score: 0,
      completedAt: asOfDate,
      renewalDate: null,
      credentialNote: '',
      managerRecommendation: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentProgramCompletionDraft.fromMilestone({
    required IncomingTalentDevelopmentProgramMilestone milestone,
    required DateTime asOfDate,
  }) {
    final decision =
        milestone.score >= 85
            ? IncomingTalentDevelopmentProgramCompletionDecision.roleReady
            : IncomingTalentDevelopmentProgramCompletionDecision.credentialed;
    final credentialLevel =
        milestone.score >= 90
            ? IncomingTalentDevelopmentProgramCredentialLevel.advanced
            : milestone.score >= 75
            ? IncomingTalentDevelopmentProgramCredentialLevel.roleReady
            : IncomingTalentDevelopmentProgramCredentialLevel.foundational;

    return IncomingTalentDevelopmentProgramCompletionDraft(
      milestoneId: milestone.id,
      enrollmentId: milestone.enrollmentId,
      programId: milestone.programId,
      programTitle: milestone.programTitle,
      candidateId: milestone.candidateId,
      candidateName: milestone.candidateName,
      role: milestone.role,
      department: milestone.department,
      reviewerName: milestone.reviewerName,
      decision: decision,
      credentialLevel: credentialLevel,
      score: milestone.score,
      completedAt: milestone.reviewedAt ?? asOfDate,
      renewalDate: asOfDate.add(const Duration(days: 365)),
      credentialNote:
          '${milestone.title} accepted with ${milestone.score}% evidence score.',
      managerRecommendation:
          milestone.score >= 85
              ? 'Apply this credential to role readiness and growth calibration.'
              : 'Archive evidence and continue the next development milestone.',
      asOfDate: asOfDate,
    );
  }
}
