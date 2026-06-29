import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_stabilization_review_models.dart';
import 'incoming_talent_promotion_implementation_provider.dart';
import 'talent_provider.dart';

final incomingTalentPromotionStabilizationReviewDraftProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationReviewDraftNotifier,
      IncomingTalentPromotionStabilizationReviewDraft
    >((ref) {
      return IncomingTalentPromotionStabilizationReviewDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

/// Owns the editable promotion stabilization review draft.
class IncomingTalentPromotionStabilizationReviewDraftNotifier
    extends StateNotifier<IncomingTalentPromotionStabilizationReviewDraft> {
  IncomingTalentPromotionStabilizationReviewDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentPromotionStabilizationReviewDraft.empty(asOfDate));

  void initializeFromImplementation(
    IncomingTalentPromotionImplementation implementation,
  ) {
    state = IncomingTalentPromotionStabilizationReviewDraft.fromImplementation(
      implementation: implementation,
      asOfDate: state.asOfDate,
    );
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setOutcome(IncomingTalentPromotionStabilizationOutcome value) {
    final reviewDate = state.reviewDate ?? state.asOfDate;
    state = state.copyWith(
      outcome: value,
      followUpDate: defaultIncomingTalentPromotionStabilizationFollowUpDate(
        outcome: value,
        reviewDate: reviewDate,
      ),
    );
  }

  void setStatus(IncomingTalentPromotionStabilizationStatus value) {
    state = state.copyWith(status: value);
  }

  void setReviewDate(DateTime value) {
    final outcome =
        state.outcome ??
        IncomingTalentPromotionStabilizationOutcome.stableInRole;
    state = state.copyWith(
      reviewDate: value,
      followUpDate: defaultIncomingTalentPromotionStabilizationFollowUpDate(
        outcome: outcome,
        reviewDate: value,
      ),
    );
  }

  void setFollowUpDate(DateTime value) {
    state = state.copyWith(followUpDate: value);
  }

  void setConfidenceScore(int value) {
    state = state.copyWith(confidenceScore: value);
  }

  void setManagerFeedback(String value) {
    state = state.copyWith(managerFeedback: value);
  }

  void setEmployeeFeedback(String value) {
    state = state.copyWith(employeeFeedback: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setSupportPlan(String value) {
    state = state.copyWith(supportPlan: value);
  }

  void clear() {
    state = IncomingTalentPromotionStabilizationReviewDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentPromotionStabilizationReviewsProvider =
    StateNotifierProvider<
      IncomingTalentPromotionStabilizationReviewsNotifier,
      List<IncomingTalentPromotionStabilizationReview>
    >((ref) {
      return IncomingTalentPromotionStabilizationReviewsNotifier();
    });

/// Stores post-promotion stabilization reviews and prevents duplicates.
class IncomingTalentPromotionStabilizationReviewsNotifier
    extends StateNotifier<List<IncomingTalentPromotionStabilizationReview>> {
  IncomingTalentPromotionStabilizationReviewsNotifier() : super(const []);

  IncomingTalentPromotionStabilizationReview submitDraft(
    IncomingTalentPromotionStabilizationReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (review) => review.implementationId == draft.implementationId,
    )) {
      throw StateError('Promotion stabilization review already exists');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-promotion-stabilization-review-${sequence.toString().padLeft(3, '0')}';
  }
}

final promotionStabilizationReviewReadyImplementationsProvider =
    Provider<List<IncomingTalentPromotionImplementation>>((ref) {
      final reviewedImplementationIds =
          ref
              .watch(incomingTalentPromotionStabilizationReviewsProvider)
              .map((review) => review.implementationId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentPromotionImplementationsProvider)
          .where(
            (implementation) =>
                implementation.status ==
                    IncomingTalentPromotionImplementationStatus.completed &&
                !reviewedImplementationIds.contains(implementation.id),
          )
          .toList();
    });

final filteredIncomingTalentPromotionStabilizationReviewsProvider =
    Provider<List<IncomingTalentPromotionStabilizationReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentPromotionStabilizationReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentPromotionStabilizationReviewSummaryProvider =
    Provider<IncomingTalentPromotionStabilizationReviewSummary>((ref) {
      return IncomingTalentPromotionStabilizationReviewSummary.fromReviews(
        reviews: ref.watch(
          filteredIncomingTalentPromotionStabilizationReviewsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
