import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_stabilization_action_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityStabilizationOutcomeDraftProvider =
    StateNotifierProvider<
      IncomingTalentMobilityStabilizationOutcomeDraftNotifier,
      IncomingTalentMobilityStabilizationOutcomeDraft
    >((ref) {
      return IncomingTalentMobilityStabilizationOutcomeDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentMobilityStabilizationOutcomeDraftNotifier
    extends StateNotifier<IncomingTalentMobilityStabilizationOutcomeDraft> {
  IncomingTalentMobilityStabilizationOutcomeDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentMobilityStabilizationOutcomeDraft.empty(asOfDate));

  void initializeFromAction(IncomingTalentMobilityStabilizationAction action) {
    state = IncomingTalentMobilityStabilizationOutcomeDraft.fromAction(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setOutcomeDate(DateTime value) {
    state = state.copyWith(
      outcomeDate: value,
      nextReviewDate: value.add(const Duration(days: 30)),
    );
  }

  void setDecision(IncomingTalentMobilityStabilizationOutcomeDecision value) {
    state = state.copyWith(
      decision: value,
      nextCadenceAction:
          defaultIncomingTalentMobilityStabilizationOutcomeNextAction(value),
    );
  }

  void setResidualRisk(IncomingTalentMobilityStabilizationResidualRisk value) {
    state = state.copyWith(residualRisk: value);
  }

  void setHostConfidenceAfter(int value) {
    state = state.copyWith(hostConfidenceAfter: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setLearningSummary(String value) {
    state = state.copyWith(learningSummary: value);
  }

  void setNextCadenceAction(String value) {
    state = state.copyWith(nextCadenceAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentMobilityStabilizationOutcomeDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentMobilityStabilizationOutcomesProvider =
    StateNotifierProvider<
      IncomingTalentMobilityStabilizationOutcomesNotifier,
      List<IncomingTalentMobilityStabilizationOutcome>
    >((ref) {
      return IncomingTalentMobilityStabilizationOutcomesNotifier();
    });

class IncomingTalentMobilityStabilizationOutcomesNotifier
    extends StateNotifier<List<IncomingTalentMobilityStabilizationOutcome>> {
  IncomingTalentMobilityStabilizationOutcomesNotifier() : super(const []);

  IncomingTalentMobilityStabilizationOutcome submitDraft(
    IncomingTalentMobilityStabilizationOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((outcome) => outcome.actionId == draft.actionId)) {
      throw StateError('Outcome already exists for mobility action');
    }

    final outcome = draft.toOutcome(id: _nextId(), createdAt: draft.asOfDate);
    state = [outcome, ...state];
    return outcome;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-stabilization-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadyMobilityStabilizationActionsProvider =
    Provider<List<IncomingTalentMobilityStabilizationAction>>((ref) {
      final closedActionIds =
          ref
              .watch(incomingTalentMobilityStabilizationOutcomesProvider)
              .map((outcome) => outcome.actionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityStabilizationActionsProvider)
          .where(
            (action) =>
                action.status ==
                    IncomingTalentMobilityStabilizationStatus.completed &&
                !closedActionIds.contains(action.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityStabilizationOutcomesProvider =
    Provider<List<IncomingTalentMobilityStabilizationOutcome>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityStabilizationOutcomesProvider)
          .where(
            (outcome) =>
                (selectedDepartment == talentAllDepartments ||
                    outcome.department == selectedDepartment ||
                    outcome.hostDepartment == selectedDepartment) &&
                (!attentionOnly || outcome.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityStabilizationOutcomeSummaryProvider =
    Provider<IncomingTalentMobilityStabilizationOutcomeSummary>((ref) {
      return IncomingTalentMobilityStabilizationOutcomeSummary.fromOutcomes(
        ref.watch(filteredIncomingTalentMobilityStabilizationOutcomesProvider),
      );
    });
