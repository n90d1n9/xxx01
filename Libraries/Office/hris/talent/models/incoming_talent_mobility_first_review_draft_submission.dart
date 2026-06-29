import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_first_review_draft.dart';

extension IncomingTalentMobilityFirstReviewDraftSubmission
    on IncomingTalentMobilityFirstReviewDraft {
  double get completionRatio {
    final completed =
        [
          checklistId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          outcome != null,
          IncomingTalentMobilityFirstReviewDraft.validateHostConfidenceScore(
                hostConfidenceScore,
              ) ==
              null,
          deliverySignal.trim().length >= 12,
          IncomingTalentMobilityFirstReviewDraft.validateBlockerNote(
                blockerNote,
                outcome,
              ) ==
              null,
          retentionRisk != null,
          nextAction.trim().length >= 12,
          followUpDate != null,
          launchStatus != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityFirstReviewDraft.validateRequired(
            checklistId,
            'a launched mobility checklist',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateReviewDate(
            reviewDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateOutcome(outcome)
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateHostConfidenceScore(
            hostConfidenceScore,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateDeliverySignal(
            deliverySignal,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateBlockerNote(
            blockerNote,
            outcome,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateRetentionRisk(
            retentionRisk,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateLaunchStatus(
            launchStatus,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateNextAction(nextAction)
          case final error?)
        error,
      if (IncomingTalentMobilityFirstReviewDraft.validateFollowUpDate(
            reviewDate,
            followUpDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityFirstReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityFirstReview(
      id: id,
      checklistId: checklistId,
      matchId: matchId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      currentRole: currentRole.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      opportunityTitle: opportunityTitle.trim(),
      hostDepartment: hostDepartment.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      outcome: outcome!,
      hostConfidenceScore: hostConfidenceScore,
      deliverySignal: deliverySignal.trim(),
      blockerNote: blockerNote.trim(),
      retentionRisk: retentionRisk!,
      nextAction: nextAction.trim(),
      followUpDate: followUpDate!,
      launchStatus: launchStatus!,
      createdAt: createdAt,
    );
  }
}
