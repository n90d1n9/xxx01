import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'incoming_talent_promotion_readiness_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionDecisionDraftProvider = StateNotifierProvider<
  IncomingTalentPromotionDecisionDraftNotifier,
  IncomingTalentPromotionDecisionDraft
>((ref) {
  return IncomingTalentPromotionDecisionDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

/// Owns the editable final promotion decision draft.
class IncomingTalentPromotionDecisionDraftNotifier
    extends StateNotifier<IncomingTalentPromotionDecisionDraft> {
  IncomingTalentPromotionDecisionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentPromotionDecisionDraft.empty(asOfDate));

  void initializeFromReadiness(IncomingTalentPromotionReadiness readiness) {
    state = IncomingTalentPromotionDecisionDraft.fromReadiness(
      readiness: readiness,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setApproverName(String value) {
    state = state.copyWith(approverName: value);
  }

  void setNewRole(String value) {
    state = state.copyWith(newRole: value);
  }

  void setOutcome(IncomingTalentPromotionDecisionOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setStatus(IncomingTalentPromotionDecisionStatus value) {
    state = state.copyWith(status: value);
  }

  void setCompensationBandNote(String value) {
    state = state.copyWith(compensationBandNote: value);
  }

  void setImplementationNote(String value) {
    state = state.copyWith(implementationNote: value);
  }

  void setRiskControlNote(String value) {
    state = state.copyWith(riskControlNote: value);
  }

  void setEffectiveDate(DateTime value) {
    state = state.copyWith(
      effectiveDate: value,
      followUpDate: value.add(const Duration(days: 30)),
    );
  }

  void setFollowUpDate(DateTime value) {
    state = state.copyWith(followUpDate: value);
  }

  void clear() {
    state = IncomingTalentPromotionDecisionDraft.empty(state.asOfDate);
  }
}

final incomingTalentPromotionDecisionsProvider = StateNotifierProvider<
  IncomingTalentPromotionDecisionsNotifier,
  List<IncomingTalentPromotionDecision>
>((ref) {
  return IncomingTalentPromotionDecisionsNotifier();
});

/// Stores final promotion decisions and protects duplicate readiness outcomes.
class IncomingTalentPromotionDecisionsNotifier
    extends StateNotifier<List<IncomingTalentPromotionDecision>> {
  IncomingTalentPromotionDecisionsNotifier() : super(const []);

  IncomingTalentPromotionDecision submitDraft(
    IncomingTalentPromotionDecisionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((decision) => decision.readinessId == draft.readinessId)) {
      throw StateError('Promotion decision already exists for this packet');
    }

    final decision = draft.toDecision(id: _nextId(), createdAt: draft.asOfDate);
    state = [decision, ...state];
    return decision;
  }

  void updateStatus({
    required String id,
    required IncomingTalentPromotionDecisionStatus status,
  }) {
    state = [
      for (final decision in state)
        if (decision.id == id) _copyWithStatus(decision, status) else decision,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-decision-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentPromotionDecision _copyWithStatus(
    IncomingTalentPromotionDecision decision,
    IncomingTalentPromotionDecisionStatus status,
  ) {
    return IncomingTalentPromotionDecision(
      id: decision.id,
      readinessId: decision.readinessId,
      careerPathId: decision.careerPathId,
      frameworkLevelId: decision.frameworkLevelId,
      candidateId: decision.candidateId,
      candidateName: decision.candidateName,
      department: decision.department,
      currentRole: decision.currentRole,
      newRole: decision.newRole,
      frameworkLevelCode: decision.frameworkLevelCode,
      ownerName: decision.ownerName,
      approverName: decision.approverName,
      outcome: decision.outcome,
      status: status,
      compensationBandNote: decision.compensationBandNote,
      implementationNote: decision.implementationNote,
      riskControlNote: decision.riskControlNote,
      effectiveDate: decision.effectiveDate,
      followUpDate: decision.followUpDate,
      sourceRating: decision.sourceRating,
      sourceReadinessStatus: decision.sourceReadinessStatus,
      createdAt: decision.createdAt,
    );
  }
}

final promotionDecisionReadyReadinessProvider = Provider<
  List<IncomingTalentPromotionReadiness>
>((ref) {
  final decidedReadinessIds =
      ref
          .watch(incomingTalentPromotionDecisionsProvider)
          .map((decision) => decision.readinessId)
          .toSet();

  return ref
      .watch(filteredIncomingTalentPromotionReadinessProvider)
      .where(
        (packet) =>
            !decidedReadinessIds.contains(packet.id) &&
            (packet.rating == IncomingTalentPromotionReadinessRating.readyNow ||
                packet.rating ==
                    IncomingTalentPromotionReadinessRating.readySoon) &&
            (packet.status == IncomingTalentPromotionReadinessStatus.endorsed ||
                packet.status ==
                    IncomingTalentPromotionReadinessStatus.calibration),
      )
      .toList();
});

final filteredIncomingTalentPromotionDecisionsProvider =
    Provider<List<IncomingTalentPromotionDecision>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentPromotionDecisionsProvider)
          .where(
            (decision) =>
                (selectedDepartment == talentAllDepartments ||
                    decision.department == selectedDepartment) &&
                (!attentionOnly || decision.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionDecisionSummaryProvider =
    Provider<IncomingTalentPromotionDecisionSummary>((ref) {
      return IncomingTalentPromotionDecisionSummary.fromDecisions(
        decisions: ref.watch(filteredIncomingTalentPromotionDecisionsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
