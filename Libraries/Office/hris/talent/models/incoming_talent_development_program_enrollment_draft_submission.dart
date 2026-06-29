import 'incoming_talent_development_program_enrollment.dart';
import 'incoming_talent_development_program_enrollment_draft.dart';
import 'incoming_talent_development_program_enrollment_policy.dart';

extension IncomingTalentDevelopmentProgramEnrollmentDraftSubmission
    on IncomingTalentDevelopmentProgramEnrollmentDraft {
  double get completionRatio {
    final completed =
        [
          programId.trim().isNotEmpty,
          portfolioId.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          milestone.trim().length >= 12,
          evidencePlan.trim().length >= 12,
          status != null,
          progressScore >= 0 && progressScore <= 100,
          enrolledAt != null,
          nextReviewDate != null,
          targetCompletionDate != null,
          sourcePortfolioStage != null,
          sourcePortfolioPriority != null,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentProgramEnrollmentRequired(
            programId,
            'a development program',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentRequired(
            portfolioId,
            'an IDP portfolio',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentRequired(
            mentorName,
            'a mentor',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentLongText(
            milestone,
            'milestone',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentLongText(
            evidencePlan,
            'evidence plan',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentProgress(progressScore)
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentStartDate(enrolledAt, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentNextReviewDate(
            enrolledAt,
            nextReviewDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramEnrollmentTargetDate(
            enrolledAt,
            targetCompletionDate,
          )
          case final error?)
        error,
      if (sourcePortfolioStage == null) 'Select source portfolio stage',
      if (sourcePortfolioPriority == null) 'Select source portfolio priority',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentProgramEnrollment toEnrollment({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentProgramEnrollment(
      id: id,
      programId: programId,
      programTitle: programTitle.trim(),
      portfolioId: portfolioId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      mentorName: mentorName.trim(),
      milestone: milestone.trim(),
      evidencePlan: evidencePlan.trim(),
      status: status!,
      progressScore: progressScore,
      enrolledAt: enrolledAt!,
      nextReviewDate: nextReviewDate!,
      targetCompletionDate: targetCompletionDate!,
      sourcePortfolioStage: sourcePortfolioStage!,
      sourcePortfolioPriority: sourcePortfolioPriority!,
      createdAt: createdAt,
    );
  }
}
