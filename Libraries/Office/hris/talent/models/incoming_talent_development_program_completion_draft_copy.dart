import 'incoming_talent_development_program_completion.dart';
import 'incoming_talent_development_program_completion_draft.dart';

extension IncomingTalentDevelopmentProgramCompletionDraftCopy
    on IncomingTalentDevelopmentProgramCompletionDraft {
  IncomingTalentDevelopmentProgramCompletionDraft copyWith({
    String? milestoneId,
    String? enrollmentId,
    String? programId,
    String? programTitle,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? reviewerName,
    IncomingTalentDevelopmentProgramCompletionDecision? decision,
    IncomingTalentDevelopmentProgramCredentialLevel? credentialLevel,
    int? score,
    DateTime? completedAt,
    DateTime? renewalDate,
    String? credentialNote,
    String? managerRecommendation,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentProgramCompletionDraft(
      milestoneId: milestoneId ?? this.milestoneId,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      programId: programId ?? this.programId,
      programTitle: programTitle ?? this.programTitle,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      reviewerName: reviewerName ?? this.reviewerName,
      decision: decision ?? this.decision,
      credentialLevel: credentialLevel ?? this.credentialLevel,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
      renewalDate: renewalDate ?? this.renewalDate,
      credentialNote: credentialNote ?? this.credentialNote,
      managerRecommendation:
          managerRecommendation ?? this.managerRecommendation,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
