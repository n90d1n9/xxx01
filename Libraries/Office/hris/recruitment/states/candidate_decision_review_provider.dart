import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_decision_review_draft.dart';
import '../models/candidate_decision_review_models.dart';
import '../models/candidate_decision_review_summary.dart';
import 'recruitment_provider.dart';

final candidateDecisionReviewDraftProvider = StateNotifierProvider<
  CandidateDecisionReviewDraftNotifier,
  CandidateDecisionReviewDraft
>((ref) {
  return CandidateDecisionReviewDraftNotifier(
    ref.watch(recruitmentAsOfDateProvider),
  );
});

class CandidateDecisionReviewDraftNotifier
    extends StateNotifier<CandidateDecisionReviewDraft> {
  CandidateDecisionReviewDraftNotifier(DateTime asOfDate)
    : super(CandidateDecisionReviewDraft.empty(asOfDate));

  void initializeFromPacket(CandidateDecisionPacket packet) {
    state = CandidateDecisionReviewDraft.fromPacket(
      packet: packet,
      asOfDate: state.asOfDate,
    );
  }

  void setOutcome(CandidateDecisionOutcome value) {
    state = state.copyWith(outcome: value);
  }

  void setOwnerName(String value) {
    state = state.copyWith(ownerName: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void setNextStep(String value) {
    state = state.copyWith(nextStep: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void clear() {
    state = CandidateDecisionReviewDraft.empty(state.asOfDate);
  }
}

final candidateDecisionReviewsProvider = StateNotifierProvider<
  CandidateDecisionReviewsNotifier,
  List<CandidateDecisionReview>
>((ref) {
  return CandidateDecisionReviewsNotifier();
});

class CandidateDecisionReviewsNotifier
    extends StateNotifier<List<CandidateDecisionReview>> {
  CandidateDecisionReviewsNotifier() : super(const []);

  CandidateDecisionReview submitDraft(CandidateDecisionReviewDraft draft) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'decision-review-${sequence.toString().padLeft(3, '0')}';
  }
}

final candidateDecisionReviewSummaryProvider =
    Provider<CandidateDecisionReviewSummary>((ref) {
      return CandidateDecisionReviewSummary.fromReviews(
        reviews: ref.watch(candidateDecisionReviewsProvider),
        asOfDate: ref.watch(recruitmentAsOfDateProvider),
      );
    });
