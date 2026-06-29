import 'incoming_talent_mobility_stabilization_action.dart';
import 'incoming_talent_mobility_stabilization_action_draft.dart';

extension IncomingTalentMobilityStabilizationActionDraftSubmission
    on IncomingTalentMobilityStabilizationActionDraft {
  double get completionRatio {
    final completed =
        [
          reviewId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          actionType != null,
          status != null,
          dueDate != null,
          actionSummary.trim().length >= 12,
          successMeasure.trim().length >= 12,
          IncomingTalentMobilityStabilizationActionDraft.validateBlockerNote(
                blockerNote,
                status,
              ) ==
              null,
          reviewOutcome != null,
          retentionRisk != null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityStabilizationActionDraft.validateRequired(
            reviewId,
            'a mobility first review',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateRequired(
            ownerName,
            'an action owner',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateActionType(
            actionType,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateStatus(status)
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateDueDate(
            dueDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateActionSummary(
            actionSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateSuccessMeasure(
            successMeasure,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityStabilizationActionDraft.validateBlockerNote(
            blockerNote,
            status,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityStabilizationAction toAction({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityStabilizationAction(
      id: id,
      reviewId: reviewId,
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
      reviewOutcome: reviewOutcome!,
      retentionRisk: retentionRisk!,
      hostConfidenceScore: hostConfidenceScore,
      actionType: actionType!,
      status: status!,
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      actionSummary: actionSummary.trim(),
      successMeasure: successMeasure.trim(),
      blockerNote: blockerNote.trim(),
      createdAt: createdAt,
    );
  }
}
