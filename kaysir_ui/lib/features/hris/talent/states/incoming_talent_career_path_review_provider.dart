import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_career_path_models.dart';
import '../models/incoming_talent_career_path_review_models.dart';
import 'incoming_talent_career_path_provider.dart';
import 'talent_provider.dart';

final incomingTalentCareerPathReviewDraftProvider = StateNotifierProvider<
  IncomingTalentCareerPathReviewDraftNotifier,
  IncomingTalentCareerPathReviewDraft
>((ref) {
  return IncomingTalentCareerPathReviewDraftNotifier(
    ref.watch(talentAsOfDateProvider),
  );
});

class IncomingTalentCareerPathReviewDraftNotifier
    extends StateNotifier<IncomingTalentCareerPathReviewDraft> {
  IncomingTalentCareerPathReviewDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentCareerPathReviewDraft.empty(asOfDate));

  void initializeFromCareerPath(IncomingTalentCareerPath careerPath) {
    state = IncomingTalentCareerPathReviewDraft.fromCareerPath(
      careerPath: careerPath,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(IncomingTalentCareerPathReviewDecision value) {
    state = state.copyWith(decision: value);
  }

  void setReviewedLevel(int value) {
    state = state.copyWith(reviewedLevel: value);
  }

  void setEvidenceNote(String value) {
    state = state.copyWith(evidenceNote: value);
  }

  void setBlockerNote(String value) {
    state = state.copyWith(blockerNote: value);
  }

  void setNextAction(String value) {
    state = state.copyWith(nextAction: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentCareerPathReviewDraft.empty(state.asOfDate);
  }
}

final incomingTalentCareerPathReviewsProvider = StateNotifierProvider<
  IncomingTalentCareerPathReviewsNotifier,
  List<IncomingTalentCareerPathReview>
>((ref) {
  return IncomingTalentCareerPathReviewsNotifier();
});

class IncomingTalentCareerPathReviewsNotifier
    extends StateNotifier<List<IncomingTalentCareerPathReview>> {
  IncomingTalentCareerPathReviewsNotifier() : super(const []);

  IncomingTalentCareerPathReview submitDraft(
    IncomingTalentCareerPathReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (review) =>
          review.careerPathId == draft.careerPathId &&
          _isSameDay(review.reviewDate, draft.reviewDate!),
    )) {
      throw StateError('Career path review already exists for this date');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-career-review-${sequence.toString().padLeft(3, '0')}';
  }
}

final careerPathReviewReadyProvider = Provider<List<IncomingTalentCareerPath>>((
  ref,
) {
  return ref
      .watch(filteredIncomingTalentCareerPathsProvider)
      .where(
        (careerPath) =>
            careerPath.status != IncomingTalentCareerPathStatus.achieved,
      )
      .toList();
});

final filteredIncomingTalentCareerPathReviewsProvider =
    Provider<List<IncomingTalentCareerPathReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentCareerPathReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.department == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentCareerPathReviewSummaryProvider =
    Provider<IncomingTalentCareerPathReviewSummary>((ref) {
      return IncomingTalentCareerPathReviewSummary.fromReviews(
        reviews: ref.watch(filteredIncomingTalentCareerPathReviewsProvider),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
