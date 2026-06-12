import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_cadence_intervention_draft.dart';

extension IncomingTalentMobilityCadenceInterventionDraftSubmission
    on IncomingTalentMobilityCadenceInterventionDraft {
  double get completionRatio {
    final blockerComplete =
        status != IncomingTalentMobilityCadenceInterventionStatus.blocked ||
        blockerNote.trim().length >= 12;
    final completed =
        [
          checkInId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          interventionType != null,
          priority != null,
          status != null,
          dueDate != null,
          interventionSummary.trim().length >= 12,
          successMeasure.trim().length >= 12,
          blockerComplete,
        ].where((item) => item).length;

    return completed / 9;
  }

  List<String> get validationErrors {
    return [
      if (IncomingTalentMobilityCadenceInterventionDraft.validateRequired(
            checkInId,
            'a mobility cadence check-in',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateRequired(
            ownerName,
            'an intervention owner',
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateInterventionType(
            interventionType,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validatePriority(
            priority,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateStatus(status)
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateDueDate(
            dueDate,
            asOfDate,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateInterventionSummary(
            interventionSummary,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateSuccessMeasure(
            successMeasure,
          )
          case final error?)
        error,
      if (IncomingTalentMobilityCadenceInterventionDraft.validateBlockerNote(
            blockerNote,
            status,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityCadenceIntervention toIntervention({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityCadenceIntervention(
      id: id,
      checkInId: checkInId,
      outcomeId: outcomeId,
      actionId: actionId,
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
      cadenceStatus: cadenceStatus!,
      residualRisk: residualRisk!,
      hostConfidenceScore: hostConfidenceScore,
      interventionType: interventionType!,
      priority: priority!,
      status: status!,
      ownerName: ownerName.trim(),
      dueDate: dueDate!,
      interventionSummary: interventionSummary.trim(),
      successMeasure: successMeasure.trim(),
      blockerNote: blockerNote.trim(),
      createdAt: createdAt,
    );
  }
}
