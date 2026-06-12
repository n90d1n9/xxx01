import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_decision_draft.dart';
import 'incoming_talent_promotion_decision_policy.dart';

extension IncomingTalentPromotionDecisionDraftSubmission
    on IncomingTalentPromotionDecisionDraft {
  double get completionRatio {
    final completed =
        [
          readinessId.trim().isNotEmpty,
          newRole.trim().isNotEmpty,
          ownerName.trim().isNotEmpty,
          approverName.trim().isNotEmpty,
          outcome != null,
          status != null,
          compensationBandNote.trim().length >= 12,
          implementationNote.trim().length >= 12,
          riskControlNote.trim().length >= 12,
          effectiveDate != null,
          followUpDate != null,
        ].where((item) => item).length;

    return completed / 11;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentPromotionDecisionRequired(
            readinessId,
            'a promotion readiness packet',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionRequired(newRole, 'a new role')
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionRequired(ownerName, 'an owner')
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionRequired(
            approverName,
            'an approver',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionOutcome(outcome)
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionLongText(
            compensationBandNote,
            'compensation note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionLongText(
            implementationNote,
            'implementation note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionLongText(
            riskControlNote,
            'risk control note',
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionEffectiveDate(
            effectiveDate,
            asOfDate,
          )
          case final error?)
        error,
      if (validateIncomingTalentPromotionDecisionFollowUpDate(
            effectiveDate: effectiveDate,
            followUpDate: followUpDate,
          )
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentPromotionDecision toDecision({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentPromotionDecision(
      id: id,
      readinessId: readinessId.trim(),
      careerPathId: careerPathId.trim(),
      frameworkLevelId: frameworkLevelId.trim(),
      candidateId: candidateId.trim(),
      candidateName: candidateName.trim(),
      department: department.trim(),
      currentRole: currentRole.trim(),
      newRole: newRole.trim(),
      frameworkLevelCode: frameworkLevelCode.trim(),
      ownerName: ownerName.trim(),
      approverName: approverName.trim(),
      outcome: outcome!,
      status: status!,
      compensationBandNote: compensationBandNote.trim(),
      implementationNote: implementationNote.trim(),
      riskControlNote: riskControlNote.trim(),
      effectiveDate: effectiveDate!,
      followUpDate: followUpDate!,
      sourceRating: sourceRating!,
      sourceReadinessStatus: sourceReadinessStatus!,
      createdAt: createdAt,
    );
  }
}
