import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_nomination_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionPanelDecisionDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionPanelDecisionDraftNotifier,
      IncomingTalentSuccessionPanelDecisionDraft
    >((ref) {
      return IncomingTalentSuccessionPanelDecisionDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionPanelDecisionDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionPanelDecisionDraft> {
  IncomingTalentSuccessionPanelDecisionDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionPanelDecisionDraft.empty(asOfDate));

  void initializeFromNomination(IncomingTalentSuccessionNomination nomination) {
    state = IncomingTalentSuccessionPanelDecisionDraft.fromNomination(
      nomination: nomination,
      asOfDate: state.asOfDate,
    );
  }

  void setPanelLeadName(String value) {
    state = state.copyWith(panelLeadName: value);
  }

  void setFollowUpOwner(String value) {
    state = state.copyWith(followUpOwner: value);
  }

  void setOutcome(IncomingTalentSuccessionPanelOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setDecisionDate(DateTime value) {
    state = state.copyWith(decisionDate: value);
  }

  void setActivationDate(DateTime value) {
    state = state.copyWith(activationDate: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void setDecisionSummary(String value) {
    state = state.copyWith(decisionSummary: value);
  }

  void setConditions(String value) {
    state = state.copyWith(conditions: value);
  }

  void setSponsorCommitment(String value) {
    state = state.copyWith(sponsorCommitment: value);
  }

  void clear() {
    state = IncomingTalentSuccessionPanelDecisionDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionPanelDecisionsProvider = StateNotifierProvider<
  IncomingTalentSuccessionPanelDecisionsNotifier,
  List<IncomingTalentSuccessionPanelDecision>
>((ref) {
  return IncomingTalentSuccessionPanelDecisionsNotifier();
});

class IncomingTalentSuccessionPanelDecisionsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionPanelDecision>> {
  IncomingTalentSuccessionPanelDecisionsNotifier() : super(const []);

  IncomingTalentSuccessionPanelDecision submitDraft(
    IncomingTalentSuccessionPanelDecisionDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((decision) => decision.nominationId == draft.nominationId)) {
      throw StateError('Panel decision already exists for nomination');
    }

    final decision = draft.toDecision(id: _nextId(), createdAt: draft.asOfDate);
    state = [decision, ...state];
    return decision;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-panel-${sequence.toString().padLeft(3, '0')}';
  }
}

final panelReadySuccessionNominationsProvider =
    Provider<List<IncomingTalentSuccessionNomination>>((ref) {
      final decidedNominationIds =
          ref
              .watch(incomingTalentSuccessionPanelDecisionsProvider)
              .map((decision) => decision.nominationId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionNominationsProvider)
          .where(
            (nomination) =>
                !decidedNominationIds.contains(nomination.id) &&
                nomination.status !=
                    IncomingTalentSuccessionNominationStatus.deferred,
          )
          .toList();
    });

final filteredIncomingTalentSuccessionPanelDecisionsProvider =
    Provider<List<IncomingTalentSuccessionPanelDecision>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionPanelDecisionsProvider)
          .where(
            (decision) =>
                (selectedDepartment == talentAllDepartments ||
                    decision.department == selectedDepartment) &&
                (!attentionOnly || decision.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionPanelDecisionSummaryProvider =
    Provider<IncomingTalentSuccessionPanelDecisionSummary>((ref) {
      return IncomingTalentSuccessionPanelDecisionSummary.fromDecisions(
        ref.watch(filteredIncomingTalentSuccessionPanelDecisionsProvider),
      );
    });
