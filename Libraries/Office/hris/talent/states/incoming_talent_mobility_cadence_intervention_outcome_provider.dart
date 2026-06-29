import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_mobility_cadence_intervention_provider.dart';
import 'talent_provider.dart';

final incomingTalentMobilityCadenceInterventionOutcomeDraftProvider =
    StateNotifierProvider<
      IncomingTalentMobilityCadenceInterventionOutcomeDraftNotifier,
      IncomingTalentMobilityCadenceInterventionOutcomeDraft
    >((ref) {
      return IncomingTalentMobilityCadenceInterventionOutcomeDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentMobilityCadenceInterventionOutcomeDraftNotifier
    extends
        StateNotifier<IncomingTalentMobilityCadenceInterventionOutcomeDraft> {
  IncomingTalentMobilityCadenceInterventionOutcomeDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentMobilityCadenceInterventionOutcomeDraft.empty(asOfDate),
      );

  void initializeFromIntervention(
    IncomingTalentMobilityCadenceIntervention intervention,
  ) {
    state =
        IncomingTalentMobilityCadenceInterventionOutcomeDraft.fromIntervention(
          intervention: intervention,
          asOfDate: state.asOfDate,
        );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(
      reviewDate: value,
      nextReviewDate: value.add(const Duration(days: 30)),
    );
  }

  void setDecision(
    IncomingTalentMobilityCadenceInterventionOutcomeDecision value,
  ) {
    state = state.copyWith(
      decision: value,
      nextCadenceAction:
          defaultIncomingTalentMobilityCadenceInterventionNextAction(value),
    );
  }

  void setSustainability(
    IncomingTalentMobilityCadenceInterventionSustainability value,
  ) {
    state = state.copyWith(sustainability: value);
  }

  void setResidualRiskAfter(
    IncomingTalentMobilityStabilizationResidualRisk value,
  ) {
    state = state.copyWith(residualRiskAfter: value);
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
    state = IncomingTalentMobilityCadenceInterventionOutcomeDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentMobilityCadenceInterventionOutcomesProvider =
    StateNotifierProvider<
      IncomingTalentMobilityCadenceInterventionOutcomesNotifier,
      List<IncomingTalentMobilityCadenceInterventionOutcome>
    >((ref) {
      return IncomingTalentMobilityCadenceInterventionOutcomesNotifier();
    });

class IncomingTalentMobilityCadenceInterventionOutcomesNotifier
    extends
        StateNotifier<List<IncomingTalentMobilityCadenceInterventionOutcome>> {
  IncomingTalentMobilityCadenceInterventionOutcomesNotifier() : super(const []);

  IncomingTalentMobilityCadenceInterventionOutcome submitDraft(
    IncomingTalentMobilityCadenceInterventionOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((item) => item.interventionId == draft.interventionId)) {
      throw StateError('Outcome already exists for mobility intervention');
    }

    final outcome = draft.toOutcome(id: _nextId(), createdAt: draft.asOfDate);
    state = [outcome, ...state];
    return outcome;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-mobility-intervention-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadyMobilityCadenceInterventionsProvider =
    Provider<List<IncomingTalentMobilityCadenceIntervention>>((ref) {
      final closedInterventionIds =
          ref
              .watch(incomingTalentMobilityCadenceInterventionOutcomesProvider)
              .map((item) => item.interventionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentMobilityCadenceInterventionsProvider)
          .where(
            (intervention) =>
                intervention.status ==
                    IncomingTalentMobilityCadenceInterventionStatus.resolved &&
                !closedInterventionIds.contains(intervention.id),
          )
          .toList();
    });

final filteredIncomingTalentMobilityCadenceInterventionOutcomesProvider =
    Provider<List<IncomingTalentMobilityCadenceInterventionOutcome>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentMobilityCadenceInterventionOutcomesProvider)
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment ||
                    item.hostDepartment == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList();
    });

final incomingTalentMobilityCadenceInterventionOutcomeSummaryProvider = Provider<
  IncomingTalentMobilityCadenceInterventionOutcomeSummary
>((ref) {
  return IncomingTalentMobilityCadenceInterventionOutcomeSummary.fromOutcomes(
    ref.watch(
      filteredIncomingTalentMobilityCadenceInterventionOutcomesProvider,
    ),
  );
});
