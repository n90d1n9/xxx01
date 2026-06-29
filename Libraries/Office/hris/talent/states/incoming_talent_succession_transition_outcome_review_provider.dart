import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_transition_intervention_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionTransitionOutcomeReviewDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionTransitionOutcomeReviewDraftNotifier,
      IncomingTalentSuccessionTransitionOutcomeReviewDraft
    >((ref) {
      return IncomingTalentSuccessionTransitionOutcomeReviewDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionTransitionOutcomeReviewDraftNotifier
    extends
        StateNotifier<IncomingTalentSuccessionTransitionOutcomeReviewDraft> {
  IncomingTalentSuccessionTransitionOutcomeReviewDraftNotifier(
    DateTime asOfDate,
  ) : super(
        IncomingTalentSuccessionTransitionOutcomeReviewDraft.empty(asOfDate),
      );

  void initializeFromIntervention(
    IncomingTalentSuccessionTransitionIntervention intervention,
  ) {
    state =
        IncomingTalentSuccessionTransitionOutcomeReviewDraft.fromIntervention(
          intervention: intervention,
          asOfDate: state.asOfDate,
        );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(IncomingTalentSuccessionTransitionOutcomeDecision value) {
    state = state.copyWith(decision: value);
  }

  void setResidualRisk(
    IncomingTalentSuccessionTransitionOutcomeResidualRisk value,
  ) {
    state = state.copyWith(residualRisk: value);
  }

  void setStabilizationScore(int value) {
    state = state.copyWith(stabilizationScore: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setLessonsLearned(String value) {
    state = state.copyWith(lessonsLearned: value);
  }

  void setNextTalentAction(String value) {
    state = state.copyWith(nextTalentAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionTransitionOutcomeReviewDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionTransitionOutcomeReviewsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionTransitionOutcomeReviewsNotifier,
      List<IncomingTalentSuccessionTransitionOutcomeReview>
    >((ref) {
      return IncomingTalentSuccessionTransitionOutcomeReviewsNotifier();
    });

class IncomingTalentSuccessionTransitionOutcomeReviewsNotifier
    extends
        StateNotifier<List<IncomingTalentSuccessionTransitionOutcomeReview>> {
  IncomingTalentSuccessionTransitionOutcomeReviewsNotifier() : super(const []);

  IncomingTalentSuccessionTransitionOutcomeReview submitDraft(
    IncomingTalentSuccessionTransitionOutcomeReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((review) => review.interventionId == draft.interventionId)) {
      throw StateError('Outcome review already exists for this intervention');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-transition-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadySuccessionTransitionInterventionsProvider =
    Provider<List<IncomingTalentSuccessionTransitionIntervention>>((ref) {
      final reviewedInterventionIds =
          ref
              .watch(incomingTalentSuccessionTransitionOutcomeReviewsProvider)
              .map((review) => review.interventionId)
              .toSet();

      return ref
          .watch(
            filteredIncomingTalentSuccessionTransitionInterventionsProvider,
          )
          .where(
            (intervention) =>
                intervention.status ==
                    IncomingTalentSuccessionTransitionInterventionStatus
                        .completed &&
                !reviewedInterventionIds.contains(intervention.id),
          )
          .toList();
    });

final filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider =
    Provider<List<IncomingTalentSuccessionTransitionOutcomeReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionTransitionOutcomeReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionTransitionOutcomeReviewSummaryProvider =
    Provider<IncomingTalentSuccessionTransitionOutcomeReviewSummary>((ref) {
      return IncomingTalentSuccessionTransitionOutcomeReviewSummary.fromReviews(
        ref.watch(
          filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
        ),
      );
    });
