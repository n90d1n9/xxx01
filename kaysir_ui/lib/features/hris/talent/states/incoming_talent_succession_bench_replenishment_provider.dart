import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_transition_outcome_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionBenchReplenishmentDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionBenchReplenishmentDraftNotifier,
      IncomingTalentSuccessionBenchReplenishmentDraft
    >((ref) {
      return IncomingTalentSuccessionBenchReplenishmentDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentSuccessionBenchReplenishmentDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionBenchReplenishmentDraft> {
  IncomingTalentSuccessionBenchReplenishmentDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentSuccessionBenchReplenishmentDraft.empty(asOfDate));

  void initializeFromOutcomeReview(
    IncomingTalentSuccessionTransitionOutcomeReview review,
  ) {
    state = IncomingTalentSuccessionBenchReplenishmentDraft.fromOutcomeReview(
      review: review,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setPriority(IncomingTalentSuccessionBenchReplenishmentPriority value) {
    state = state.copyWith(priority: value);
  }

  void setTargetReadyDate(DateTime value) {
    state = state.copyWith(targetReadyDate: value);
  }

  void setBenchGap(String value) {
    state = state.copyWith(benchGap: value);
  }

  void setSourcingStrategy(String value) {
    state = state.copyWith(sourcingStrategy: value);
  }

  void setDevelopmentTrack(String value) {
    state = state.copyWith(developmentTrack: value);
  }

  void setReviewCadence(String value) {
    state = state.copyWith(reviewCadence: value);
  }

  void clear() {
    state = IncomingTalentSuccessionBenchReplenishmentDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentSuccessionBenchReplenishmentsProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionBenchReplenishmentsNotifier,
      List<IncomingTalentSuccessionBenchReplenishment>
    >((ref) {
      return IncomingTalentSuccessionBenchReplenishmentsNotifier();
    });

class IncomingTalentSuccessionBenchReplenishmentsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionBenchReplenishment>> {
  IncomingTalentSuccessionBenchReplenishmentsNotifier() : super(const []);

  IncomingTalentSuccessionBenchReplenishment submitDraft(
    IncomingTalentSuccessionBenchReplenishmentDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any((plan) => plan.outcomeReviewId == draft.outcomeReviewId)) {
      throw StateError('Bench replenishment already exists for this outcome');
    }

    final plan = draft.toReplenishment(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [plan, ...state];
    return plan;
  }

  void start(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchReplenishmentStatus.active);
  }

  void complete(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchReplenishmentStatus.completed);
  }

  void block(String id) {
    _setStatus(id, IncomingTalentSuccessionBenchReplenishmentStatus.blocked);
  }

  void _setStatus(
    String id,
    IncomingTalentSuccessionBenchReplenishmentStatus status,
  ) {
    state =
        state.map((plan) {
          if (plan.id != id) return plan;
          return plan.copyWith(status: status);
        }).toList();
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-bench-replenishment-${sequence.toString().padLeft(3, '0')}';
  }
}

final benchReadySuccessionTransitionOutcomeReviewsProvider =
    Provider<List<IncomingTalentSuccessionTransitionOutcomeReview>>((ref) {
      final plannedOutcomeReviewIds =
          ref
              .watch(incomingTalentSuccessionBenchReplenishmentsProvider)
              .map((plan) => plan.outcomeReviewId)
              .toSet();

      return ref
          .watch(
            filteredIncomingTalentSuccessionTransitionOutcomeReviewsProvider,
          )
          .where((review) => !plannedOutcomeReviewIds.contains(review.id))
          .toList();
    });

final filteredIncomingTalentSuccessionBenchReplenishmentsProvider =
    Provider<List<IncomingTalentSuccessionBenchReplenishment>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionBenchReplenishmentsProvider)
          .where(
            (plan) =>
                (selectedDepartment == talentAllDepartments ||
                    plan.department == selectedDepartment) &&
                (!attentionOnly || plan.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionBenchReplenishmentSummaryProvider =
    Provider<IncomingTalentSuccessionBenchReplenishmentSummary>((ref) {
      return IncomingTalentSuccessionBenchReplenishmentSummary.fromPlans(
        plans: ref.watch(
          filteredIncomingTalentSuccessionBenchReplenishmentsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
