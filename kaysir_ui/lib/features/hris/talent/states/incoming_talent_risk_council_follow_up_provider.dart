import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'incoming_talent_risk_council_decision_provider.dart';
import 'incoming_talent_risk_council_source_filter_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilFollowUpDraftProvider = StateNotifierProvider<
  IncomingTalentRiskCouncilFollowUpDraftNotifier,
  IncomingTalentRiskCouncilFollowUpDraft
>((ref) {
  return IncomingTalentRiskCouncilFollowUpDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentRiskCouncilFollowUpDraftNotifier
    extends StateNotifier<IncomingTalentRiskCouncilFollowUpDraft> {
  IncomingTalentRiskCouncilFollowUpDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentRiskCouncilFollowUpDraft.empty(asOfDate));

  void initializeFromDecision(IncomingTalentRiskCouncilDecision decision) {
    state = IncomingTalentRiskCouncilFollowUpDraft.fromDecision(
      decision: decision,
      asOfDate: state.asOfDate,
    );
  }

  void setFollowUpOwnerName(String value) {
    state = state.copyWith(followUpOwnerName: value);
  }

  void setFollowUpType(IncomingTalentRiskCouncilFollowUpType value) {
    final actionPlan =
        state.decisionId.isEmpty
            ? state.actionPlan
            : defaultRiskCouncilFollowUpActionPlan(
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
    state = IncomingTalentRiskCouncilFollowUpDraft.empty(state.asOfDate);
  }
}

final incomingTalentRiskCouncilFollowUpsProvider = StateNotifierProvider<
  IncomingTalentRiskCouncilFollowUpsNotifier,
  List<IncomingTalentRiskCouncilFollowUp>
>((ref) {
  return IncomingTalentRiskCouncilFollowUpsNotifier();
});

class IncomingTalentRiskCouncilFollowUpsNotifier
    extends StateNotifier<List<IncomingTalentRiskCouncilFollowUp>> {
  IncomingTalentRiskCouncilFollowUpsNotifier() : super(const []);

  IncomingTalentRiskCouncilFollowUp submitDraft(
    IncomingTalentRiskCouncilFollowUpDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((followUp) => followUp.decisionId == draft.decisionId)) {
      throw StateError('Follow-up already exists for risk council decision');
    }

    final followUp = draft.toFollowUp(id: _nextId(), createdAt: draft.asOfDate);
    state = [followUp, ...state];
    return followUp;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentRiskCouncilFollowUpStatus.inProgress);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentRiskCouncilFollowUpStatus.blocked);
  }

  void escalate(String id) {
    _setStatus(id, IncomingTalentRiskCouncilFollowUpStatus.escalated);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentRiskCouncilFollowUpStatus.completed);
  }

  void _setStatus(String id, IncomingTalentRiskCouncilFollowUpStatus status) {
    state =
        state.map((followUp) {
          if (followUp.id != id) return followUp;
          return followUp.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-risk-council-follow-up-${sequence.toString().padLeft(3, '0')}';
  }
}

final followUpReadyTalentRiskCouncilDecisionsProvider =
    Provider<List<IncomingTalentRiskCouncilDecision>>((ref) {
      final followedDecisionIds =
          ref
              .watch(incomingTalentRiskCouncilFollowUpsProvider)
              .map((followUp) => followUp.decisionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentRiskCouncilDecisionsProvider)
          .where((decision) => !followedDecisionIds.contains(decision.id))
          .toList();
    });

final filteredIncomingTalentRiskCouncilFollowUpsProvider =
    Provider<List<IncomingTalentRiskCouncilFollowUp>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);
      final selectedSource = ref.watch(
        incomingTalentRiskCouncilSourceFilterProvider,
      );

      return ref
          .watch(incomingTalentRiskCouncilFollowUpsProvider)
          .where(
            (followUp) =>
                (selectedDepartment == talentAllDepartments ||
                    followUp.department == selectedDepartment) &&
                (!attentionOnly || followUp.needsAttention) &&
                matchesIncomingTalentRiskCouncilSourceFilter(
                  selectedSource: selectedSource,
                  source: followUp.source,
                ),
          )
          .toList();
    });

final incomingTalentRiskCouncilFollowUpSummaryProvider =
    Provider<IncomingTalentRiskCouncilFollowUpSummary>((ref) {
      return IncomingTalentRiskCouncilFollowUpSummary.fromFollowUps(
        followUps: ref.watch(
          filteredIncomingTalentRiskCouncilFollowUpsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

IncomingTalentRiskCouncilDecision _decisionFromDraft(
  IncomingTalentRiskCouncilFollowUpDraft draft,
) {
  return IncomingTalentRiskCouncilDecision(
    id: draft.decisionId,
    queueItemId: draft.queueItemId,
    candidateId: draft.candidateId,
    candidateName: draft.candidateName,
    role: draft.role,
    department: draft.department,
    category: draft.category ?? IncomingTalentRiskCouncilQueueCategory.followUp,
    sourceSeverity:
        draft.sourceSeverity ?? IncomingTalentRiskCouncilQueueSeverity.watch,
    source: draft.source,
    decisionMakerName: draft.decisionMakerName,
    ownerName: draft.followUpOwnerName,
    decisionDate: draft.decisionDate ?? draft.asOfDate,
    outcome:
        draft.outcome ??
        IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    commitmentSummary: draft.actionPlan,
    minutesNote: draft.successCriteria,
    followUpDate: draft.dueDate ?? draft.asOfDate,
    createdAt: draft.asOfDate,
    signalCount: draft.signalCount,
  );
}
