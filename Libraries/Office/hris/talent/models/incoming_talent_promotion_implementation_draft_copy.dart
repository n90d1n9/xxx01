import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_implementation.dart';
import 'incoming_talent_promotion_implementation_draft.dart';
import 'incoming_talent_promotion_readiness.dart';

extension IncomingTalentPromotionImplementationDraftCopy
    on IncomingTalentPromotionImplementationDraft {
  IncomingTalentPromotionImplementationDraft copyWith({
    String? decisionId,
    String? readinessId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? newRole,
    String? frameworkLevelCode,
    String? ownerName,
    String? approverName,
    IncomingTalentPromotionImplementationAction? action,
    IncomingTalentPromotionImplementationStatus? status,
    String? systemOfRecord,
    String? implementationStep,
    String? evidenceNote,
    String? blockerNote,
    DateTime? dueDate,
    DateTime? completedDate,
    IncomingTalentPromotionDecisionOutcome? sourceOutcome,
    IncomingTalentPromotionDecisionStatus? sourceDecisionStatus,
    IncomingTalentPromotionReadinessRating? sourceReadinessRating,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionImplementationDraft(
      decisionId: decisionId ?? this.decisionId,
      readinessId: readinessId ?? this.readinessId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      newRole: newRole ?? this.newRole,
      frameworkLevelCode: frameworkLevelCode ?? this.frameworkLevelCode,
      ownerName: ownerName ?? this.ownerName,
      approverName: approverName ?? this.approverName,
      action: action ?? this.action,
      status: status ?? this.status,
      systemOfRecord: systemOfRecord ?? this.systemOfRecord,
      implementationStep: implementationStep ?? this.implementationStep,
      evidenceNote: evidenceNote ?? this.evidenceNote,
      blockerNote: blockerNote ?? this.blockerNote,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      sourceOutcome: sourceOutcome ?? this.sourceOutcome,
      sourceDecisionStatus: sourceDecisionStatus ?? this.sourceDecisionStatus,
      sourceReadinessRating:
          sourceReadinessRating ?? this.sourceReadinessRating,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
