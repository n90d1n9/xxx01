import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_intervention_models.dart';
import '../models/incoming_talent_development_intervention_outcome_models.dart';
import 'incoming_talent_development_intervention_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentInterventionOutcomeDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomeDraftNotifier,
      IncomingTalentDevelopmentInterventionOutcomeDraft
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentInterventionOutcomeDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentInterventionOutcomeDraft> {
  IncomingTalentDevelopmentInterventionOutcomeDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentInterventionOutcomeDraft.empty(asOfDate));

  void initializeFromIntervention(
    IncomingTalentDevelopmentInterventionAction action,
  ) {
    state = IncomingTalentDevelopmentInterventionOutcomeDraft.fromIntervention(
      action: action,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    final decision = state.decision;
    state = state.copyWith(
      reviewDate: value,
      nextReviewDate:
          decision == null
              ? value.add(const Duration(days: 30))
              : defaultIncomingTalentDevelopmentInterventionNextReviewDate(
                decision: decision,
                reviewDate: value,
              ),
    );
  }

  void setDecision(IncomingTalentDevelopmentInterventionOutcomeDecision value) {
    final reviewDate = state.reviewDate ?? state.asOfDate;
    state = state.copyWith(
      decision: value,
      nextAction: defaultIncomingTalentDevelopmentInterventionNextAction(value),
      nextReviewDate:
          defaultIncomingTalentDevelopmentInterventionNextReviewDate(
            decision: value,
            reviewDate: reviewDate,
          ),
    );
  }

  void setConfidenceAfter(int value) {
    state = state.copyWith(confidenceAfter: value);
  }

  void setRemainingReleaseRiskCount(int value) {
    state = state.copyWith(remainingReleaseRiskCount: value < 0 ? 0 : value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setLearningSummary(String value) {
    state = state.copyWith(learningSummary: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentInterventionOutcomeDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentDevelopmentInterventionOutcomesProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentInterventionOutcomesNotifier,
      List<IncomingTalentDevelopmentInterventionOutcome>
    >((ref) {
      return IncomingTalentDevelopmentInterventionOutcomesNotifier();
    });

class IncomingTalentDevelopmentInterventionOutcomesNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentInterventionOutcome>> {
  IncomingTalentDevelopmentInterventionOutcomesNotifier() : super(const []);

  IncomingTalentDevelopmentInterventionOutcome submitDraft(
    IncomingTalentDevelopmentInterventionOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (outcome) => outcome.interventionId == draft.interventionId,
    )) {
      throw StateError(
        'Outcome already exists for this development intervention',
      );
    }

    final outcome = draft.toOutcome(id: _nextId(), createdAt: draft.asOfDate);
    state = [outcome, ...state];
    return outcome;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-intervention-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadyDevelopmentInterventionsProvider =
    Provider<List<IncomingTalentDevelopmentInterventionAction>>((ref) {
      final reviewedInterventionIds =
          ref
              .watch(incomingTalentDevelopmentInterventionOutcomesProvider)
              .map((outcome) => outcome.interventionId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentDevelopmentInterventionsProvider)
          .where(
            (action) =>
                action.status ==
                    IncomingTalentDevelopmentInterventionStatus.resolved &&
                !reviewedInterventionIds.contains(action.id),
          )
          .toList();
    });

final filteredIncomingTalentDevelopmentInterventionOutcomesProvider =
    Provider<List<IncomingTalentDevelopmentInterventionOutcome>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentInterventionOutcomesProvider)
          .where(
            (outcome) =>
                (selectedDepartment == talentAllDepartments ||
                    outcome.department == selectedDepartment) &&
                (!attentionOnly || outcome.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentInterventionOutcomeSummaryProvider =
    Provider<IncomingTalentDevelopmentInterventionOutcomeSummary>((ref) {
      return IncomingTalentDevelopmentInterventionOutcomeSummary.fromOutcomes(
        ref.watch(
          filteredIncomingTalentDevelopmentInterventionOutcomesProvider,
        ),
      );
    });
