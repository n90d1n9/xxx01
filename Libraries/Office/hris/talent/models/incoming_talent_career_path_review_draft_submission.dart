import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_review_draft.dart';
import 'incoming_talent_career_path_review_policy.dart';

extension IncomingTalentCareerPathReviewDraftSubmission
    on IncomingTalentCareerPathReviewDraft {
  double get completionRatio {
    final completed =
        [
          careerPathId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          reviewDate != null,
          decision != null,
          reviewedLevel >= 1 && reviewedLevel <= 5,
          targetLevel >= reviewedLevel && targetLevel <= 5,
          evidenceNote.trim().length >= 12,
          blockerNote.trim().length >= 12,
          nextAction.trim().length >= 12,
          nextReviewDate != null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentCareerPathReviewRequired(
            careerPathId,
            'a career path',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewDate(
            reviewDate,
            asOfDate,
            'review date',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewDecision(decision)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewReviewedLevel(
            reviewedLevel: reviewedLevel,
            targetLevel: targetLevel,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewLongText(
            evidenceNote,
            'evidence note',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewLongText(
            blockerNote,
            'blocker note',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewLongText(
            nextAction,
            'next action',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathReviewDate(
            nextReviewDate,
            asOfDate,
            'next review date',
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCareerPathReview toReview({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCareerPathReview(
      id: id,
      careerPathId: careerPathId,
      portfolioId: portfolioId,
      roadmapId: roadmapId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      targetRole: targetRole.trim(),
      competencyName: competencyName.trim(),
      reviewerName: reviewerName.trim(),
      reviewDate: reviewDate!,
      decision: decision!,
      previousLevel: previousLevel,
      reviewedLevel: reviewedLevel,
      targetLevel: targetLevel,
      evidenceNote: evidenceNote.trim(),
      blockerNote: blockerNote.trim(),
      nextAction: nextAction.trim(),
      nextReviewDate: nextReviewDate!,
      sourceStatus: sourceStatus!,
      sourcePriority: sourcePriority!,
      createdAt: createdAt,
    );
  }
}
