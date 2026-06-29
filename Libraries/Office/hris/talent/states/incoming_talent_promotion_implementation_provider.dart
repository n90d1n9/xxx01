import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import 'incoming_talent_promotion_decision_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionImplementationDraftProvider =
    StateNotifierProvider<
      IncomingTalentPromotionImplementationDraftNotifier,
      IncomingTalentPromotionImplementationDraft
    >((ref) {
      return IncomingTalentPromotionImplementationDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

/// Owns the editable promotion implementation draft.
class IncomingTalentPromotionImplementationDraftNotifier
    extends StateNotifier<IncomingTalentPromotionImplementationDraft> {
  IncomingTalentPromotionImplementationDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentPromotionImplementationDraft.empty(asOfDate));

  void initializeFromDecision(IncomingTalentPromotionDecision decision) {
    state = IncomingTalentPromotionImplementationDraft.fromDecision(
      decision: decision,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setApproverName(String value) {
    state = state.copyWith(approverName: value);
  }

  void setAction(IncomingTalentPromotionImplementationAction value) {
    state = state.copyWith(action: value);
  }

  void setStatus(IncomingTalentPromotionImplementationStatus value) {
    state = state.copyWith(status: value);
  }

  void setSystemOfRecord(String value) {
    state = state.copyWith(systemOfRecord: value);
  }

  void setImplementationStep(String value) {
    state = state.copyWith(implementationStep: value);
  }

  void setEvidenceNote(String value) {
    state = state.copyWith(evidenceNote: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setCompletedDate(DateTime value) {
    state = state.copyWith(completedDate: value);
  }

  void clear() {
    state = IncomingTalentPromotionImplementationDraft.empty(state.asOfDate);
  }
}

final incomingTalentPromotionImplementationsProvider = StateNotifierProvider<
  IncomingTalentPromotionImplementationsNotifier,
  List<IncomingTalentPromotionImplementation>
>((ref) {
  return IncomingTalentPromotionImplementationsNotifier();
});

/// Stores promotion implementation work and prevents duplicate work packets.
class IncomingTalentPromotionImplementationsNotifier
    extends StateNotifier<List<IncomingTalentPromotionImplementation>> {
  IncomingTalentPromotionImplementationsNotifier() : super(const []);

  IncomingTalentPromotionImplementation submitDraft(
    IncomingTalentPromotionImplementationDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.decisionId == draft.decisionId)) {
      throw StateError('Promotion implementation already exists');
    }

    final implementation = draft.toImplementation(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [implementation, ...state];
    return implementation;
  }

  void updateStatus({
    required String id,
    required IncomingTalentPromotionImplementationStatus status,
  }) {
    state = [
      for (final implementation in state)
        if (implementation.id == id)
          _copyWithStatus(implementation, status)
        else
          implementation,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-implementation-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentPromotionImplementation _copyWithStatus(
    IncomingTalentPromotionImplementation implementation,
    IncomingTalentPromotionImplementationStatus status,
  ) {
    return IncomingTalentPromotionImplementation(
      id: implementation.id,
      decisionId: implementation.decisionId,
      readinessId: implementation.readinessId,
      candidateId: implementation.candidateId,
      candidateName: implementation.candidateName,
      department: implementation.department,
      currentRole: implementation.currentRole,
      newRole: implementation.newRole,
      frameworkLevelCode: implementation.frameworkLevelCode,
      ownerName: implementation.ownerName,
      approverName: implementation.approverName,
      action: implementation.action,
      status: status,
      systemOfRecord: implementation.systemOfRecord,
      implementationStep: implementation.implementationStep,
      evidenceNote: implementation.evidenceNote,
      blockerNote: implementation.blockerNote,
      dueDate: implementation.dueDate,
      completedDate: implementation.completedDate,
      sourceOutcome: implementation.sourceOutcome,
      sourceDecisionStatus: implementation.sourceDecisionStatus,
      sourceReadinessRating: implementation.sourceReadinessRating,
      createdAt: implementation.createdAt,
    );
  }
}

final promotionImplementationReadyDecisionsProvider =
    Provider<List<IncomingTalentPromotionDecision>>((ref) {
      final implementedDecisionIds =
          ref
              .watch(incomingTalentPromotionImplementationsProvider)
              .map((implementation) => implementation.decisionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentPromotionDecisionsProvider)
          .where(
            (decision) =>
                !implementedDecisionIds.contains(decision.id) &&
                (decision.status ==
                        IncomingTalentPromotionDecisionStatus.approved ||
                    decision.status ==
                        IncomingTalentPromotionDecisionStatus.routed ||
                    decision.status ==
                        IncomingTalentPromotionDecisionStatus.deferred),
          )
          .toList();
    });

final filteredIncomingTalentPromotionImplementationsProvider =
    Provider<List<IncomingTalentPromotionImplementation>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentPromotionImplementationsProvider)
          .where(
            (implementation) =>
                (selectedDepartment == talentAllDepartments ||
                    implementation.department == selectedDepartment) &&
                (!attentionOnly || implementation.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionImplementationSummaryProvider =
    Provider<IncomingTalentPromotionImplementationSummary>((ref) {
      return IncomingTalentPromotionImplementationSummary.fromImplementations(
        implementations: ref.watch(
          filteredIncomingTalentPromotionImplementationsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
