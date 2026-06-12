import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_council_decision_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageCouncilFollowUpDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageCouncilFollowUpDraftNotifier,
      IncomingTalentSuccessionCoverageCouncilFollowUpDraft
    >((ref) {
      return IncomingTalentSuccessionCoverageCouncilFollowUpDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionCoverageCouncilFollowUpDraftNotifier
    extends
        StateNotifier<IncomingTalentSuccessionCoverageCouncilFollowUpDraft> {
  IncomingTalentSuccessionCoverageCouncilFollowUpDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentSuccessionCoverageCouncilFollowUpDraft.empty(asOfDate),
      );

  void initializeFromDecision(
    IncomingTalentSuccessionCoverageCouncilDecision decision,
  ) {
    state = IncomingTalentSuccessionCoverageCouncilFollowUpDraft.fromDecision(
      decision: decision,
      asOfDate: state.asOfDate,
    );
  }

  void setFollowUpOwnerName(String value) {
    state = state.copyWith(followUpOwnerName: value);
  }

  void setFollowUpType(
    IncomingTalentSuccessionCoverageCouncilFollowUpType value,
  ) {
    final actionPlan =
        state.decisionId.isEmpty
            ? state.actionPlan
            : defaultCoverageCouncilFollowUpActionPlan(
              _decisionFromDraft(state),
              value,
            );
    state = state.copyWith(followUpType: value, actionPlan: actionPlan);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setActionPlan(String value) {
    state = state.copyWith(actionPlan: value);
  }

  void setSuccessCriteria(String value) {
    state = state.copyWith(successCriteria: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setEscalationReason(String value) {
    state = state.copyWith(escalationReason: value);
  }

  void clear() {
    state = IncomingTalentSuccessionCoverageCouncilFollowUpDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionCoverageCouncilFollowUpsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageCouncilFollowUpsNotifier,
      List<IncomingTalentSuccessionCoverageCouncilFollowUp>
    >((ref) {
      return IncomingTalentSuccessionCoverageCouncilFollowUpsNotifier();
    });

class IncomingTalentSuccessionCoverageCouncilFollowUpsNotifier
    extends
        StateNotifier<List<IncomingTalentSuccessionCoverageCouncilFollowUp>> {
  IncomingTalentSuccessionCoverageCouncilFollowUpsNotifier() : super(const []);

  IncomingTalentSuccessionCoverageCouncilFollowUp submitDraft(
    IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((followUp) => followUp.decisionId == draft.decisionId)) {
      throw StateError('Follow-up already exists for council decision');
    }

    final followUp = draft.toFollowUp(id: _nextId(), createdAt: draft.asOfDate);
    state = [followUp, ...state];
    return followUp;
  }

  void start(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.inProgress,
    );
  }

  void block(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.blocked,
    );
  }

  void escalate(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.escalated,
    );
  }

  void complete(String id) {
    _setStatus(
      id,
      IncomingTalentSuccessionCoverageCouncilFollowUpStatus.completed,
    );
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionCoverageCouncilFollowUpStatus status,
  ) {
    state =
        state.map((followUp) {
          if (followUp.id != id) return followUp;
          return followUp.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-coverage-council-follow-up-${sequence.toString().padLeft(3, '0')}';
  }
}

final followUpReadyCoverageCouncilDecisionsProvider =
    Provider<List<IncomingTalentSuccessionCoverageCouncilDecision>>((ref) {
      final followedDecisionIds =
          ref
              .watch(incomingTalentSuccessionCoverageCouncilFollowUpsProvider)
              .map((followUp) => followUp.decisionId)
              .toSet();

      return ref
          .watch(incomingTalentSuccessionCoverageCouncilDecisionsProvider)
          .where((decision) => !followedDecisionIds.contains(decision.id))
          .toList();
    });

final filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider =
    Provider<List<IncomingTalentSuccessionCoverageCouncilFollowUp>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageCouncilFollowUpsProvider)
          .where(
            (followUp) =>
                (selectedDepartment == talentAllDepartments ||
                    followUp.departmentScope == selectedDepartment) &&
                (!attentionOnly || followUp.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageCouncilFollowUpSummaryProvider = Provider<
  IncomingTalentSuccessionCoverageCouncilFollowUpSummary
>((ref) {
  return IncomingTalentSuccessionCoverageCouncilFollowUpSummary.fromFollowUps(
    followUps: ref.watch(
      filteredIncomingTalentSuccessionCoverageCouncilFollowUpsProvider,
    ),
    asOfDate: ref.watch(talentAsOfDateProvider),
  );
});

IncomingTalentSuccessionCoverageCouncilDecision _decisionFromDraft(
  IncomingTalentSuccessionCoverageCouncilFollowUpDraft draft,
) {
  return IncomingTalentSuccessionCoverageCouncilDecision(
    id: draft.decisionId,
    agendaItemId: draft.agendaItemId,
    governanceRecordId: draft.governanceRecordId,
    scopeLabel: draft.scopeLabel,
    departmentScope: draft.departmentScope,
    ownerName: draft.councilOwnerName,
    decisionMakerName: 'Talent Council',
    executiveSponsorName: draft.executiveSponsorName,
    lane: IncomingTalentSuccessionCoverageCouncilAgendaLane.monitoring,
    priority: draft.priority!,
    riskLevel: draft.riskLevel!,
    coverageScore: 0,
    decisionDate: draft.decisionDate!,
    outcome: draft.outcome!,
    commitmentSummary: draft.actionPlan,
    minutesNote: draft.successCriteria,
    followUpDate: draft.dueDate ?? draft.asOfDate,
    createdAt: draft.asOfDate,
  );
}
