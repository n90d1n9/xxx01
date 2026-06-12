import 'incoming_talent_development_program_completion.dart';
import 'incoming_talent_development_program_completion_draft.dart';
import 'incoming_talent_development_program_completion_policy.dart';

extension IncomingTalentDevelopmentProgramCompletionDraftSubmission
    on IncomingTalentDevelopmentProgramCompletionDraft {
  double get completionRatio {
    final completed =
        [
          milestoneId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          decision != null,
          credentialLevel != null,
          score >= 0 && score <= 100,
          completedAt != null,
          validateIncomingTalentProgramCompletionRenewalDate(
                renewalDate: renewalDate,
                completedAt: completedAt,
              ) ==
              null,
          credentialNote.trim().length >= 12,
          managerRecommendation.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentProgramCompletionRequired(
            milestoneId,
            'an accepted milestone',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionDecision(decision)
          case final error?)
        error,
      if (validateIncomingTalentProgramCredentialLevel(credentialLevel)
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionScore(score) case final error?)
        error,
      if (validateIncomingTalentProgramCompletionDate(completedAt, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionRenewalDate(
            renewalDate: renewalDate,
            completedAt: completedAt,
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionLongText(
            credentialNote,
            'credential note',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramCompletionLongText(
            managerRecommendation,
            'manager recommendation',
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentProgramCompletion toCompletion({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentProgramCompletion(
      id: id,
      milestoneId: milestoneId,
      enrollmentId: enrollmentId,
      programId: programId,
      programTitle: programTitle.trim(),
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      reviewerName: reviewerName.trim(),
      decision: decision!,
      credentialLevel: credentialLevel!,
      score: score,
      completedAt: completedAt!,
      renewalDate: renewalDate,
      credentialNote: credentialNote.trim(),
      managerRecommendation: managerRecommendation.trim(),
      createdAt: createdAt,
    );
  }
}
