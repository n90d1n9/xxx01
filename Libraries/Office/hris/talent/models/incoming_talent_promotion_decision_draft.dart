import 'incoming_talent_promotion_decision.dart';
import 'incoming_talent_promotion_readiness.dart';

/// Editable draft for final promotion panel decisions.
class IncomingTalentPromotionDecisionDraft {
  final String readinessId;
  final String careerPathId;
  final String frameworkLevelId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String newRole;
  final String frameworkLevelCode;
  final String ownerName;
  final String approverName;
  final IncomingTalentPromotionDecisionOutcome? outcome;
  final IncomingTalentPromotionDecisionStatus? status;
  final String compensationBandNote;
  final String implementationNote;
  final String riskControlNote;
  final DateTime? effectiveDate;
  final DateTime? followUpDate;
  final IncomingTalentPromotionReadinessRating? sourceRating;
  final IncomingTalentPromotionReadinessStatus? sourceReadinessStatus;
  final DateTime asOfDate;

  const IncomingTalentPromotionDecisionDraft({
    required this.readinessId,
    required this.careerPathId,
    required this.frameworkLevelId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.newRole,
    required this.frameworkLevelCode,
    required this.ownerName,
    required this.approverName,
    required this.outcome,
    required this.status,
    required this.compensationBandNote,
    required this.implementationNote,
    required this.riskControlNote,
    required this.effectiveDate,
    required this.followUpDate,
    required this.sourceRating,
    required this.sourceReadinessStatus,
    required this.asOfDate,
  });

  factory IncomingTalentPromotionDecisionDraft.empty(DateTime asOfDate) {
    return IncomingTalentPromotionDecisionDraft(
      readinessId: '',
      careerPathId: '',
      frameworkLevelId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      newRole: '',
      frameworkLevelCode: '',
      ownerName: '',
      approverName: '',
      outcome: null,
      status: IncomingTalentPromotionDecisionStatus.draft,
      compensationBandNote: '',
      implementationNote: '',
      riskControlNote: '',
      effectiveDate: asOfDate.add(const Duration(days: 30)),
      followUpDate: asOfDate.add(const Duration(days: 60)),
      sourceRating: null,
      sourceReadinessStatus: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentPromotionDecisionDraft.fromReadiness({
    required IncomingTalentPromotionReadiness readiness,
    required DateTime asOfDate,
  }) {
    final outcome = _outcomeFor(readiness.rating);
    final status = _statusFor(outcome);
    final effectiveDate = asOfDate.add(_effectiveOffsetFor(outcome));

    return IncomingTalentPromotionDecisionDraft(
      readinessId: readiness.id,
      careerPathId: readiness.careerPathId,
      frameworkLevelId: readiness.frameworkLevelId,
      candidateId: readiness.candidateId,
      candidateName: readiness.candidateName,
      department: readiness.department,
      currentRole: readiness.currentRole,
      newRole: readiness.targetRole,
      frameworkLevelCode: readiness.frameworkLevelCode,
      ownerName: readiness.assessorName,
      approverName: '${readiness.department} people panel',
      outcome: outcome,
      status: status,
      compensationBandNote: _compensationNoteFor(outcome, readiness),
      implementationNote: _implementationNoteFor(outcome, readiness),
      riskControlNote: _riskControlNoteFor(outcome, readiness),
      effectiveDate: effectiveDate,
      followUpDate: effectiveDate.add(_followUpOffsetFor(outcome)),
      sourceRating: readiness.rating,
      sourceReadinessStatus: readiness.status,
      asOfDate: asOfDate,
    );
  }
}

IncomingTalentPromotionDecisionOutcome _outcomeFor(
  IncomingTalentPromotionReadinessRating rating,
) {
  return switch (rating) {
    IncomingTalentPromotionReadinessRating.readyNow =>
      IncomingTalentPromotionDecisionOutcome.promoteNow,
    IncomingTalentPromotionReadinessRating.readySoon =>
      IncomingTalentPromotionDecisionOutcome.promoteWithTrial,
    IncomingTalentPromotionReadinessRating.developing =>
      IncomingTalentPromotionDecisionOutcome.deferPromotion,
    IncomingTalentPromotionReadinessRating.blocked =>
      IncomingTalentPromotionDecisionOutcome.retainInRole,
  };
}

IncomingTalentPromotionDecisionStatus _statusFor(
  IncomingTalentPromotionDecisionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow ||
    IncomingTalentPromotionDecisionOutcome
        .compensationReview => IncomingTalentPromotionDecisionStatus.approved,
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial =>
      IncomingTalentPromotionDecisionStatus.routed,
    IncomingTalentPromotionDecisionOutcome.deferPromotion ||
    IncomingTalentPromotionDecisionOutcome
        .retainInRole => IncomingTalentPromotionDecisionStatus.deferred,
  };
}

Duration _effectiveOffsetFor(IncomingTalentPromotionDecisionOutcome outcome) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow => const Duration(
      days: 30,
    ),
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial ||
    IncomingTalentPromotionDecisionOutcome
        .compensationReview => const Duration(days: 45),
    IncomingTalentPromotionDecisionOutcome.deferPromotion ||
    IncomingTalentPromotionDecisionOutcome
        .retainInRole => const Duration(days: 60),
  };
}

Duration _followUpOffsetFor(IncomingTalentPromotionDecisionOutcome outcome) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow ||
    IncomingTalentPromotionDecisionOutcome
        .compensationReview => const Duration(days: 30),
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial => const Duration(
      days: 45,
    ),
    IncomingTalentPromotionDecisionOutcome.deferPromotion ||
    IncomingTalentPromotionDecisionOutcome
        .retainInRole => const Duration(days: 60),
  };
}

String _compensationNoteFor(
  IncomingTalentPromotionDecisionOutcome outcome,
  IncomingTalentPromotionReadiness readiness,
) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow =>
      'Route ${readiness.frameworkLevelCode} title and compensation band for approval.',
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial =>
      'Prepare trial assignment band guidance before final promotion.',
    IncomingTalentPromotionDecisionOutcome.compensationReview =>
      'Review compensation band without changing role title yet.',
    IncomingTalentPromotionDecisionOutcome.deferPromotion ||
    IncomingTalentPromotionDecisionOutcome.retainInRole =>
      'Hold compensation movement until readiness evidence improves.',
  };
}

String _implementationNoteFor(
  IncomingTalentPromotionDecisionOutcome outcome,
  IncomingTalentPromotionReadiness readiness,
) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow =>
      'Prepare promotion letter, manager communication, and HRIS title update.',
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial =>
      'Create trial scope, success measures, and manager check-in cadence.',
    IncomingTalentPromotionDecisionOutcome.compensationReview =>
      'Coordinate compensation review with manager and HR business partner.',
    IncomingTalentPromotionDecisionOutcome.deferPromotion =>
      'Extend development plan using ${readiness.gapSummary}',
    IncomingTalentPromotionDecisionOutcome.retainInRole =>
      'Keep current role while resolving blockers and updating development plan.',
  };
}

String _riskControlNoteFor(
  IncomingTalentPromotionDecisionOutcome outcome,
  IncomingTalentPromotionReadiness readiness,
) {
  return switch (outcome) {
    IncomingTalentPromotionDecisionOutcome.promoteNow =>
      'Confirm backfill, onboarding expectations, and manager transition risk.',
    IncomingTalentPromotionDecisionOutcome.promoteWithTrial =>
      'Confirm trial expectations and avoid title promise until evidence closes.',
    IncomingTalentPromotionDecisionOutcome.compensationReview =>
      'Confirm compensation movement aligns with role scope and budget guardrails.',
    IncomingTalentPromotionDecisionOutcome.deferPromotion =>
      'Document evidence gaps and avoid promotion until panel criteria are met.',
    IncomingTalentPromotionDecisionOutcome.retainInRole =>
      'Resolve blockers before reopening promotion discussion.',
  };
}
