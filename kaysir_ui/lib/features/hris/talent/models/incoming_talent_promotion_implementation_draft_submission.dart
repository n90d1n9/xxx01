import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_implementation_draft.dart';
import 'incoming_talent_promotion_implementation_policy.dart';

extension IncomingTalentPromotionImplementationDraftSubmission
    on IncomingTalentPromotionImplementationDraft {
  double get completionRatio {
    final completed =
        [
          decisionId.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          approverName.trim().isNotEmpty,
          action != null,
          status != null,
          systemOfRecord.trim().isNotEmpty,
          implementationStep.trim().length >= 12,
          evidenceNote.trim().length >= 12,
          blockerNote.trim().length >= 12,
          dueDate != null,
          status != IncomingTalentPromotionImplementationStatus.completed ||
              completedDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionImplementationRequired(
            decisionId,
            'a promotion decision',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationRequired(
            ownerName,
            'an owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationRequired(
            approverName,
            'an approver',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationAction(action)
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationRequired(
            systemOfRecord,
            'a system of record',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationLongText(
            implementationStep,
            'implementation step',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationLongText(
            evidenceNote,
            'evidence note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationLongText(
            blockerNote,
            'blocker note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationDueDate(
            dueDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionImplementationCompletedDate(
            status: status,
            completedDate: completedDate,
            asOfDate: asOfDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionImplementation toImplementation({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionImplementation(
      id: id,
      decisionId: decisionId.trim(),
      readinessId: readinessId.trim(),
      candidateId: candidateId.trim(),
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      newRole: newRole.trim(),
      frameworkLevelCode: frameworkLevelCode.trim(),
      ownerName: ownerName.trim(),
      approverName: approverName.trim(),
      action: action!,
      status: status!,
      systemOfRecord: systemOfRecord.trim(),
      implementationStep: implementationStep.trim(),
      evidenceNote: evidenceNote.trim(),
      blockerNote: blockerNote.trim(),
      dueDate: dueDate!,
      completedDate: completedDate,
      sourceOutcome: sourceOutcome!,
      sourceDecisionStatus: sourceDecisionStatus!,
      sourceReadinessRating: sourceReadinessRating!,
      createdAt: createdAt,
    );
  }
}
