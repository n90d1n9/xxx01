import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'incoming_talent_risk_council_queue_provider.dart';
import 'incoming_talent_risk_council_source_filter_provider.dart';
import 'talent_provider.dart';

final incomingTalentRiskCouncilDecisionDraftProvider = StateNotifierProvider<
  IncomingTalentRiskCouncilDecisionDraftNotifier,
  IncomingTalentRiskCouncilDecisionDraft
>((ref) {
  return IncomingTalentRiskCouncilDecisionDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentRiskCouncilDecisionDraftNotifier
    extends StateNotifier<IncomingTalentRiskCouncilDecisionDraft> {
  IncomingTalentRiskCouncilDecisionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentRiskCouncilDecisionDraft.empty(asOfDate));

  void initializeFromQueueItem(IncomingTalentRiskCouncilQueueItem item) {
    state = IncomingTalentRiskCouncilDecisionDraft.fromQueueItem(
      item: item,
      asOfDate: state.asOfDate,
    );
  }

  void setDecisionMakerName(String value) {
    state = state.copyWith(decisionMakerName: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDecisionDate(DateTime value) {
    state = state.copyWith(decisionDate: value);
  }

  void setOutcome(IncomingTalentRiskCouncilDecisionOutcome value) {
    state = state.copyWith(
      outcome: value,
      followUpDate: defaultRiskCouncilDecisionFollowUpDate(
        outcome: value,
        asOfDate: state.asOfDate,
      ),
    );
  }

  void setCommitmentSummary(String value) {
    state = state.copyWith(commitmentSummary: value);
  }

  void setMinutesNote(String value) {
    state = state.copyWith(minutesNote: value);
  }

  void setFollowUpDate(DateTime value) {
    state = state.copyWith(followUpDate: value);
  }

  void clear() {
    state = IncomingTalentRiskCouncilDecisionDraft.empty(state.asOfDate);
  }
}

final incomingTalentRiskCouncilDecisionsProvider = StateNotifierProvider<
  IncomingTalentRiskCouncilDecisionsNotifier,
  List<IncomingTalentRiskCouncilDecision>
>((ref) {
  return IncomingTalentRiskCouncilDecisionsNotifier();
});

class IncomingTalentRiskCouncilDecisionsNotifier
    extends StateNotifier<List<IncomingTalentRiskCouncilDecision>> {
  IncomingTalentRiskCouncilDecisionsNotifier() : super(const []);

  IncomingTalentRiskCouncilDecision submitDraft(
    IncomingTalentRiskCouncilDecisionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((decision) => decision.queueItemId == draft.queueItemId)) {
      throw StateError('Risk council decision already exists for queue item');
    }

    final decision = draft.toDecision(id: _nextId(), createdAt: draft.asOfDate);
    state = [decision, ...state];
    return decision;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-risk-council-decision-${sequence.toString().padLeft(3, '0')}';
  }
}

final decisionReadyTalentRiskCouncilQueueItemsProvider =
    Provider<List<IncomingTalentRiskCouncilQueueItem>>((ref) {
      final decidedQueueItemIds =
          ref
              .watch(incomingTalentRiskCouncilDecisionsProvider)
              .map((decision) => decision.queueItemId)
              .toSet();

      return ref
          .watch(incomingTalentRiskCouncilQueueItemsProvider)
          .where((item) => !decidedQueueItemIds.contains(item.id))
          .toList();
    });

final filteredIncomingTalentRiskCouncilDecisionsProvider =
    Provider<List<IncomingTalentRiskCouncilDecision>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);
      final selectedSource = ref.watch(
        incomingTalentRiskCouncilSourceFilterProvider,
      );

      return ref
          .watch(incomingTalentRiskCouncilDecisionsProvider)
          .where(
            (decision) =>
                (selectedDepartment == talentAllDepartments ||
                    decision.department == selectedDepartment) &&
                (!attentionOnly || decision.needsAttention) &&
                matchesIncomingTalentRiskCouncilSourceFilter(
                  selectedSource: selectedSource,
                  source: decision.source,
                ),
          )
          .toList();
    });

final incomingTalentRiskCouncilDecisionSummaryProvider =
    Provider<IncomingTalentRiskCouncilDecisionSummary>((ref) {
      return IncomingTalentRiskCouncilDecisionSummary.fromDecisions(
        ref.watch(filteredIncomingTalentRiskCouncilDecisionsProvider),
      );
    });
