import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_council_agenda_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageCouncilDecisionDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageCouncilDecisionDraftNotifier,
      IncomingTalentSuccessionCoverageCouncilDecisionDraft
    >((ref) {
      return IncomingTalentSuccessionCoverageCouncilDecisionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionCoverageCouncilDecisionDraftNotifier
    extends
        StateNotifier<IncomingTalentSuccessionCoverageCouncilDecisionDraft> {
  IncomingTalentSuccessionCoverageCouncilDecisionDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentSuccessionCoverageCouncilDecisionDraft.empty(asOfDate),
      );

  void initializeFromAgendaItem(
    IncomingTalentSuccessionCoverageCouncilAgendaItem item,
  ) {
    state = IncomingTalentSuccessionCoverageCouncilDecisionDraft.fromAgendaItem(
      item: item,
      asOfDate: state.asOfDate,
    );
  }

  void setDecisionMakerName(String value) {
    state = state.copyWith(decisionMakerName: value);
  }

  void setExecutiveSponsorName(String value) {
    state = state.copyWith(executiveSponsorName: value);
  }

  void setDecisionDate(DateTime value) {
    state = state.copyWith(decisionDate: value);
  }

  void setOutcome(
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome value,
  ) {
    state = state.copyWith(
      outcome: value,
      followUpDate: defaultCoverageCouncilDecisionFollowUpDate(
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
    state = IncomingTalentSuccessionCoverageCouncilDecisionDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionCoverageCouncilDecisionsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageCouncilDecisionsNotifier,
      List<IncomingTalentSuccessionCoverageCouncilDecision>
    >((ref) {
      return IncomingTalentSuccessionCoverageCouncilDecisionsNotifier();
    });

class IncomingTalentSuccessionCoverageCouncilDecisionsNotifier
    extends
        StateNotifier<List<IncomingTalentSuccessionCoverageCouncilDecision>> {
  IncomingTalentSuccessionCoverageCouncilDecisionsNotifier() : super(const []);

  IncomingTalentSuccessionCoverageCouncilDecision submitDraft(
    IncomingTalentSuccessionCoverageCouncilDecisionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((decision) => decision.agendaItemId == draft.agendaItemId)) {
      throw StateError('Council decision already exists for agenda item');
    }

    final decision = draft.toDecision(id: _nextId(), createdAt: draft.asOfDate);
    state = [decision, ...state];
    return decision;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-coverage-council-${sequence.toString().padLeft(3, '0')}';
  }
}

final decisionReadyCoverageCouncilAgendaItemsProvider =
    Provider<List<IncomingTalentSuccessionCoverageCouncilAgendaItem>>((ref) {
      final decidedAgendaIds =
          ref
              .watch(incomingTalentSuccessionCoverageCouncilDecisionsProvider)
              .map((decision) => decision.agendaItemId)
              .toSet();

      return ref
          .watch(incomingTalentSuccessionCoverageCouncilAgendaItemsProvider)
          .where((item) => !decidedAgendaIds.contains(item.id))
          .toList();
    });

final filteredIncomingTalentSuccessionCoverageCouncilDecisionsProvider =
    Provider<List<IncomingTalentSuccessionCoverageCouncilDecision>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageCouncilDecisionsProvider)
          .where(
            (decision) =>
                (selectedDepartment == talentAllDepartments ||
                    decision.departmentScope == selectedDepartment) &&
                (!attentionOnly || decision.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageCouncilDecisionSummaryProvider = Provider<
  IncomingTalentSuccessionCoverageCouncilDecisionSummary
>((ref) {
  return IncomingTalentSuccessionCoverageCouncilDecisionSummary.fromDecisions(
    ref.watch(filteredIncomingTalentSuccessionCoverageCouncilDecisionsProvider),
  );
});
