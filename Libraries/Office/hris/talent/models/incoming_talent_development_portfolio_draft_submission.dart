import 'incoming_talent_development_portfolio.dart';
import 'incoming_talent_development_portfolio_draft.dart';
import 'incoming_talent_development_portfolio_policy.dart';

extension IncomingTalentDevelopmentPortfolioDraftSubmission
    on IncomingTalentDevelopmentPortfolioDraft {
  double get completionRatio {
    final completed =
        [
          roadmapId.trim().isNotEmpty,
          portfolioOwnerName.trim().isNotEmpty,
          mentorName.trim().isNotEmpty,
          competencyFocus.trim().length >= 3,
          growthGoal.trim().length >= 12,
          learningPath.trim().length >= 12,
          evidencePlan.trim().length >= 12,
          stage != null,
          priority != null,
          reviewCadence != null,
          startDate != null,
          nextReviewDate != null,
          targetCompletionDate != null,
        ].where((item) => item).length;

    return completed / 13;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentDevelopmentPortfolioRequired(
            roadmapId,
            'a development roadmap',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioRequired(
            portfolioOwnerName,
            'a portfolio owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioRequired(
            mentorName,
            'a mentor',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioFocus(competencyFocus)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioLongText(
            growthGoal,
            'growth goal',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioLongText(
            learningPath,
            'learning path',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioLongText(
            evidencePlan,
            'evidence plan',
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioStage(stage)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioPriority(priority)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioCadence(reviewCadence)
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioStartDate(
            startDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioNextReviewDate(
            startDate,
            nextReviewDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentDevelopmentPortfolioTargetDate(
            startDate,
            targetCompletionDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentPortfolio toPortfolio({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentPortfolio(
      id: id,
      roadmapId: roadmapId,
      outcomeReviewId: outcomeReviewId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      portfolioOwnerName: portfolioOwnerName.trim(),
      mentorName: mentorName.trim(),
      competencyFocus: competencyFocus.trim(),
      growthGoal: growthGoal.trim(),
      learningPath: learningPath.trim(),
      evidencePlan: evidencePlan.trim(),
      stage: stage!,
      priority: priority!,
      reviewCadence: reviewCadence!,
      startDate: startDate!,
      nextReviewDate: nextReviewDate!,
      targetCompletionDate: targetCompletionDate!,
      sourceRoadmapStatus: sourceRoadmapStatus!,
      sourceRetentionRisk: sourceRetentionRisk!,
      sourceReadinessScore: sourceReadinessScore,
      createdAt: createdAt,
    );
  }
}

String? validateIncomingTalentDevelopmentPortfolioFocus(String? value) {
  final requiredError = validateIncomingTalentDevelopmentPortfolioRequired(
    value,
    'a competency focus',
  );
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 3) return 'Competency focus is too short';
  return null;
}
