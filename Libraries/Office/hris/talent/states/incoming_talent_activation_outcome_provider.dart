import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_activation_checkpoint_models.dart';
import '../models/incoming_talent_activation_follow_up_models.dart';
import '../models/incoming_talent_activation_models.dart';
import '../models/incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_activation_checkpoint_provider.dart';
import 'incoming_talent_activation_follow_up_provider.dart';
import 'incoming_talent_activation_provider.dart';
import 'talent_provider.dart';

final incomingTalentActivationOutcomeDraftProvider = StateNotifierProvider<
  IncomingTalentActivationOutcomeDraftNotifier,
  IncomingTalentActivationOutcomeDraft
>((ref) {
  return IncomingTalentActivationOutcomeDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentActivationOutcomeDraftNotifier
    extends StateNotifier<IncomingTalentActivationOutcomeDraft> {
  IncomingTalentActivationOutcomeDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentActivationOutcomeDraft.empty(asOfDate));

  void initializeFromPlan({
    required IncomingTalentActivationPlan plan,
    required List<IncomingTalentActivationCheckpoint> checkpoints,
    required List<IncomingTalentActivationFollowUpAction> followUps,
  }) {
    state = IncomingTalentActivationOutcomeDraft.fromPlan(
      plan: plan,
      checkpoints: checkpoints,
      followUps: followUps,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(IncomingTalentActivationOutcomeDecision value) {
    state = state.copyWith(decision: value);
  }

  void setRetentionRisk(IncomingTalentActivationRetentionRisk value) {
    state = state.copyWith(retentionRisk: value);
  }

  void setReadinessScore(int value) {
    state = state.copyWith(readinessScore: value);
  }

  void setNextDevelopmentTrack(String value) {
    state = state.copyWith(nextDevelopmentTrack: value);
  }

  void setEvidenceNote(String value) {
    state = state.copyWith(evidenceNote: value);
  }

  void setDecisionNote(String value) {
    state = state.copyWith(decisionNote: value);
  }

  void clear() {
    state = IncomingTalentActivationOutcomeDraft.empty(state.asOfDate);
  }
}

final incomingTalentActivationOutcomeReviewsProvider = StateNotifierProvider<
  IncomingTalentActivationOutcomeReviewsNotifier,
  List<IncomingTalentActivationOutcomeReview>
>((ref) {
  return IncomingTalentActivationOutcomeReviewsNotifier();
});

class IncomingTalentActivationOutcomeReviewsNotifier
    extends StateNotifier<List<IncomingTalentActivationOutcomeReview>> {
  IncomingTalentActivationOutcomeReviewsNotifier() : super(const []);

  IncomingTalentActivationOutcomeReview submitDraft(
    IncomingTalentActivationOutcomeDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (review) => review.activationPlanId == draft.activationPlanId,
    )) {
      throw StateError(
        'Outcome review already exists for this activation plan',
      );
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-outcome-${sequence.toString().padLeft(3, '0')}';
  }
}

final outcomeReadyActivationPlansProvider =
    Provider<List<IncomingTalentActivationPlan>>((ref) {
      final reviewedPlanIds =
          ref
              .watch(incomingTalentActivationOutcomeReviewsProvider)
              .map((review) => review.activationPlanId)
              .toSet();
      return ref
          .watch(filteredIncomingTalentActivationPlansProvider)
          .where((plan) => !reviewedPlanIds.contains(plan.id))
          .toList();
    });

final filteredIncomingTalentActivationOutcomeReviewsProvider =
    Provider<List<IncomingTalentActivationOutcomeReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentActivationOutcomeReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentActivationOutcomeSummaryProvider =
    Provider<IncomingTalentActivationOutcomeSummary>((ref) {
      return IncomingTalentActivationOutcomeSummary.fromReviews(
        ref.watch(filteredIncomingTalentActivationOutcomeReviewsProvider),
      );
    });

final incomingTalentActivationOutcomeEvidenceProvider =
    Provider<IncomingTalentActivationOutcomeEvidence>((ref) {
      return IncomingTalentActivationOutcomeEvidence(
        checkpoints: ref.watch(incomingTalentActivationCheckpointsProvider),
        followUps: ref.watch(incomingTalentActivationFollowUpActionsProvider),
      );
    });

class IncomingTalentActivationOutcomeEvidence {
  final List<IncomingTalentActivationCheckpoint> checkpoints;
  final List<IncomingTalentActivationFollowUpAction> followUps;

  const IncomingTalentActivationOutcomeEvidence({
    required this.checkpoints,
    required this.followUps,
  });
}
