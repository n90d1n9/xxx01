import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_decision_draft.dart';
import 'incoming_talent_promotion_readiness.dart';

extension IncomingTalentPromotionDecisionDraftCopy
    on IncomingTalentPromotionDecisionDraft {
  IncomingTalentPromotionDecisionDraft copyWith({
    String? readinessId,
    String? careerPathId,
    String? frameworkLevelId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? newRole,
    String? frameworkLevelCode,
    String? ownerName,
    String? approverName,
    IncomingTalentPromotionDecisionOutcome? outcome,
    IncomingTalentPromotionDecisionStatus? status,
    String? compensationBandNote,
    String? implementationNote,
    String? riskControlNote,
    DateTime? effectiveDate,
    DateTime? followUpDate,
    IncomingTalentPromotionReadinessRating? sourceRating,
    IncomingTalentPromotionReadinessStatus? sourceReadinessStatus,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionDecisionDraft(
      readinessId: readinessId ?? this.readinessId,
      careerPathId: careerPathId ?? this.careerPathId,
      frameworkLevelId: frameworkLevelId ?? this.frameworkLevelId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      newRole: newRole ?? this.newRole,
      frameworkLevelCode: frameworkLevelCode ?? this.frameworkLevelCode,
      ownerName: ownerName ?? this.ownerName,
      approverName: approverName ?? this.approverName,
      outcome: outcome ?? this.outcome,
      status: status ?? this.status,
      compensationBandNote: compensationBandNote ?? this.compensationBandNote,
      implementationNote: implementationNote ?? this.implementationNote,
      riskControlNote: riskControlNote ?? this.riskControlNote,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      followUpDate: followUpDate ?? this.followUpDate,
      sourceRating: sourceRating ?? this.sourceRating,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
