import 'incoming_talent_career_path_support_action.dart';
import 'incoming_talent_career_path_support_action_draft.dart';
import 'incoming_talent_career_path_support_action_policy.dart';

extension IncomingTalentCareerPathSupportActionDraftSubmission
    on IncomingTalentCareerPathSupportActionDraft {
  double get completionRatio {
    final completed =
        [
          reviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionType != null,
          priority != null,
          status != null,
          dueDate != null,
          actionPlan.trim().length >= 12,
          successCriteria.trim().length >= 12,
          escalationNote.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentCareerPathSupportActionRequired(
            reviewId,
            'a career path review',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionRequired(
            ownerName,
            'an owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionType(actionType)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionPriority(priority)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionDueDate(
            dueDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionLongText(
            actionPlan,
            'action plan',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionLongText(
            successCriteria,
            'success criteria',
          )
          case final error?)
        error,
      if (validateIncomingTalentCareerPathSupportActionLongText(
            escalationNote,
            'escalation note',
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentCareerPathSupportAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentCareerPathSupportAction(
      id: id,
      reviewId: reviewId,
      careerPathId: careerPathId,
      portfolioId: portfolioId,
      roadmapId: roadmapId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      competencyName: competencyName.trim(),
      ownerName: ownerName.trim(),
      actionType: actionType!,
      priority: priority!,
      status: status!,
      dueDate: dueDate!,
      actionPlan: actionPlan.trim(),
      successCriteria: successCriteria.trim(),
      escalationNote: escalationNote.trim(),
      sourceDecision: sourceDecision!,
      reviewedLevel: reviewedLevel,
      targetLevel: targetLevel,
      sourceLevelGap: sourceLevelGap,
      createdAt: createdAt,
    );
  }
}
