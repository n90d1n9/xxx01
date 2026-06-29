import 'incoming_talent_promotion_stabilization_review.dart';
import 'incoming_talent_promotion_stabilization_review_draft.dart';
import 'incoming_talent_promotion_stabilization_review_policy.dart';

/// Submission helpers for converting stabilization drafts into reviews.
extension IncomingTalentPromotionStabilizationReviewDraftSubmission
    on IncomingTalentPromotionStabilizationReviewDraft {
  double get completionRatio {
    final completed =
        [
          implementationId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          outcome != null,
          status != null,
          reviewDate != null,
          confidenceScore >= 1 && confidenceScore <= 5,
          managerFeedback.trim().length >= 12,
          employeeFeedback.trim().length >= 12,
          evidenceSummary.trim().length >= 12,
          supportPlan.trim().length >= 12,
          validateIncomingTalentPromotionStabilizationFollowUpDate(
                status: status,
                reviewDate: reviewDate,
                followUpDate: followUpDate,
              ) ==
              null,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionStabilizationRequired(
            implementationId,
            'a promotion implementation',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationRequired(
            ownerName,
            'an owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationOutcome(outcome)
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationReviewDate(reviewDate)
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationConfidence(
            confidenceScore,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationLongText(
            managerFeedback,
            'manager feedback',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationLongText(
            employeeFeedback,
            'employee feedback',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationLongText(
            supportPlan,
            'support plan',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionStabilizationFollowUpDate(
            status: status,
            reviewDate: reviewDate,
            followUpDate: followUpDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionStabilizationReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionStabilizationReview(
      id: id,
      implementationId: implementationId.trim(),
      decisionId: decisionId.trim(),
      readinessId: readinessId.trim(),
      candidateId: candidateId.trim(),
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      newRole: newRole.trim(),
      frameworkLevelCode: frameworkLevelCode.trim(),
      ownerName: ownerName.trim(),
      reviewerName: reviewerName.trim(),
      outcome: outcome!,
      status: status!,
      reviewDate: reviewDate!,
      followUpDate: followUpDate,
      confidenceScore: confidenceScore,
      managerFeedback: managerFeedback.trim(),
      employeeFeedback: employeeFeedback.trim(),
      evidenceSummary: evidenceSummary.trim(),
      supportPlan: supportPlan.trim(),
      sourceAction: sourceAction!,
      sourceImplementationStatus: sourceImplementationStatus!,
      sourceOutcome: sourceOutcome!,
      sourceReadinessRating: sourceReadinessRating!,
      createdAt: createdAt,
    );
  }
}
