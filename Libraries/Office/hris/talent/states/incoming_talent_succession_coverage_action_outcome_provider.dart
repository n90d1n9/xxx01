import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageActionOutcomeDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageActionOutcomeDraftNotifier,
      IncomingTalentSuccessionCoverageActionOutcomeDraft
    >((ref) {
      return IncomingTalentSuccessionCoverageActionOutcomeDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionCoverageActionOutcomeDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionCoverageActionOutcomeDraft> {
  IncomingTalentSuccessionCoverageActionOutcomeDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionCoverageActionOutcomeDraft.empty(asOfDate));

  void initializeFromAction(IncomingTalentSuccessionCoverageAction action) {
    state = IncomingTalentSuccessionCoverageActionOutcomeDraft.fromAction(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(
    IncomingTalentSuccessionCoverageActionOutcomeDecision value,
  ) {
    state = state.copyWith(decision: value);
  }

  void setResidualRisk(
    IncomingTalentSuccessionCoverageActionResidualRisk value,
  ) {
    state = state.copyWith(residualRisk: value);
  }

  void setCoverageScoreAfter(int value) {
    state = state.copyWith(coverageScoreAfter: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setLearningSummary(String value) {
    state = state.copyWith(learningSummary: value);
  }

  void setNextCoverageAction(String value) {
    state = state.copyWith(nextCoverageAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionCoverageActionOutcomeDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionCoverageActionOutcomesProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageActionOutcomesNotifier,
      List<IncomingTalentSuccessionCoverageActionOutcome>
    >((ref) {
      return IncomingTalentSuccessionCoverageActionOutcomesNotifier();
    });

class IncomingTalentSuccessionCoverageActionOutcomesNotifier
    extends StateNotifier<List<IncomingTalentSuccessionCoverageActionOutcome>> {
  IncomingTalentSuccessionCoverageActionOutcomesNotifier() : super(const []);

  IncomingTalentSuccessionCoverageActionOutcome submitDraft(
    IncomingTalentSuccessionCoverageActionOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((outcome) => outcome.actionId == draft.actionId)) {
      throw StateError('Outcome already exists for this coverage action');
    }

    final outcome = draft.toOutcome(id: _nextId(), createdAt: draft.asOfDate);
    state = [outcome, ...state];
    return outcome;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-coverage-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadySuccessionCoverageActionsProvider =
    Provider<List<IncomingTalentSuccessionCoverageAction>>((ref) {
      final reviewedActionIds =
          ref
              .watch(incomingTalentSuccessionCoverageActionOutcomesProvider)
              .map((outcome) => outcome.actionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentSuccessionCoverageActionsProvider)
          .where(
            (action) =>
                action.status ==
                    IncomingTalentSuccessionCoverageActionStatus.resolved &&
                !reviewedActionIds.contains(action.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionCoverageActionOutcomesProvider =
    Provider<List<IncomingTalentSuccessionCoverageActionOutcome>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageActionOutcomesProvider)
          .where(
            (outcome) =>
                (selectedDepartment == talentAllDepartments ||
                    outcome.departmentScope == selectedDepartment) &&
                (!attentionOnly || outcome.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageActionOutcomeSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageActionOutcomeSummary>((ref) {
      return IncomingTalentSuccessionCoverageActionOutcomeSummary.fromOutcomes(
        ref.watch(
          filteredIncomingTalentSuccessionCoverageActionOutcomesProvider,
        ),
      );
    });
