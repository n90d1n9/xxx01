import 'incoming_talent_promotion_readiness.dart';
import 'incoming_talent_promotion_readiness_draft.dart';
import 'incoming_talent_promotion_readiness_policy.dart';

extension IncomingTalentPromotionReadinessDraftSubmission
    on IncomingTalentPromotionReadinessDraft {
  double get completionRatio {
    final completed =
        [
          careerPathId.trim().isNotEmpty,
          frameworkLevelId.trim().isNotEmpty,
          assessorName.trim().isNotEmpty,
          rating != null,
          status != null,
          evidenceSummary.trim().length >= 12,
          gapSummary.trim().length >= 12,
          panelRecommendation.trim().length >= 12,
          reviewDate != null,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionReadinessRequired(
            careerPathId,
            'a career path',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessRequired(
            frameworkLevelId,
            'a framework level',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessRequired(
            assessorName,
            'an assessor',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessRating(rating)
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessLongText(
            gapSummary,
            'gap summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessLongText(
            panelRecommendation,
            'panel recommendation',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessDate(reviewDate, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentPromotionReadinessNextReviewDate(
            reviewDate: reviewDate,
            nextReviewDate: nextReviewDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionReadiness toReadiness({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionReadiness(
      id: id,
      careerPathId: careerPathId.trim(),
      frameworkLevelId: frameworkLevelId.trim(),
      candidateId: candidateId.trim(),
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      targetRole: targetRole.trim(),
      frameworkFamilyName: frameworkFamilyName.trim(),
      frameworkLevelCode: frameworkLevelCode.trim(),
      frameworkScope: frameworkScope!,
      frameworkReviewCadence: frameworkReviewCadence!,
      assessorName: assessorName.trim(),
      rating: rating!,
      status: status!,
      competencyName: competencyName.trim(),
      evidenceSummary: evidenceSummary.trim(),
      gapSummary: gapSummary.trim(),
      panelRecommendation: panelRecommendation.trim(),
      reviewDate: reviewDate!,
      nextReviewDate: nextReviewDate!,
      sourceCareerPathStatus: sourceCareerPathStatus!,
      sourceCareerPathPriority: sourceCareerPathPriority!,
      createdAt: createdAt,
    );
  }
}
