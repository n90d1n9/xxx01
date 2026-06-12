import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_succession_models.dart';
import 'incoming_talent_succession_coverage_dashboard_provider.dart';
import 'talent_provider.dart';

final incomingTalentSuccessionCoverageReviewDraftProvider =
    StateNotifierProvider<
      IncomingTalentSuccessionCoverageReviewDraftNotifier,
      IncomingTalentSuccessionCoverageReviewDraft
    >((ref) {
      return IncomingTalentSuccessionCoverageReviewDraftNotifier(
        asOfDate: ref.watch(talentAsOfDateProvider),
        dashboard: ref.watch(incomingTalentSuccessionCoverageDashboardProvider),
        departmentScope: ref.watch(talentDepartmentProvider),
        attentionOnly: ref.watch(talentNeedsAttentionProvider),
      );
    });

class IncomingTalentSuccessionCoverageReviewDraftNotifier
    extends StateNotifier<IncomingTalentSuccessionCoverageReviewDraft> {
  IncomingTalentSuccessionCoverageReviewDraftNotifier({
    required DateTime asOfDate,
    required IncomingTalentSuccessionCoverageDashboard dashboard,
    required String departmentScope,
    required bool attentionOnly,
  }) : _dashboard = dashboard,
       _departmentScope = departmentScope,
       _attentionOnly = attentionOnly,
       super(
         IncomingTalentSuccessionCoverageReviewDraft.fromDashboard(
           dashboard: dashboard,
           asOfDate: asOfDate,
           scopeLabel: _scopeLabel(departmentScope, attentionOnly),
           departmentScope: departmentScope,
           attentionOnly: attentionOnly,
         ),
       );

  final IncomingTalentSuccessionCoverageDashboard _dashboard;
  final String _departmentScope;
  final bool _attentionOnly;

  void refreshSnapshot() {
    state = IncomingTalentSuccessionCoverageReviewDraft.fromDashboard(
      dashboard: _dashboard,
      asOfDate: state.asOfDate,
      scopeLabel: _scopeLabel(_departmentScope, _attentionOnly),
      departmentScope: _departmentScope,
      attentionOnly: _attentionOnly,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setReviewDate(DateTime value) {
    state = state.copyWith(reviewDate: value);
  }

  void setDecision(IncomingTalentSuccessionCoverageReviewDecision value) {
    state = state.copyWith(
      decision: value,
      executiveCommitment: defaultCoverageReviewCommitment(value),
      nextReviewDate: nextCoverageReviewDateForDecision(value, state.asOfDate),
    );
  }

  void setReviewSummary(String value) {
    state = state.copyWith(reviewSummary: value);
  }

  void setExecutiveCommitment(String value) {
    state = state.copyWith(executiveCommitment: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void clear() {
    state = IncomingTalentSuccessionCoverageReviewDraft.empty(state.asOfDate);
  }
}

final incomingTalentSuccessionCoverageReviewsProvider = StateNotifierProvider<
  IncomingTalentSuccessionCoverageReviewsNotifier,
  List<IncomingTalentSuccessionCoverageReview>
>((ref) {
  return IncomingTalentSuccessionCoverageReviewsNotifier();
});

class IncomingTalentSuccessionCoverageReviewsNotifier
    extends StateNotifier<List<IncomingTalentSuccessionCoverageReview>> {
  IncomingTalentSuccessionCoverageReviewsNotifier() : super(const []);

  IncomingTalentSuccessionCoverageReview submitDraft(
    IncomingTalentSuccessionCoverageReviewDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (review) =>
          review.departmentScope == draft.departmentScope &&
          review.attentionOnly == draft.attentionOnly &&
          _sameDay(review.reviewDate, draft.reviewDate!),
    )) {
      throw StateError('Coverage review already exists for this scope and day');
    }

    final review = draft.toReview(id: _nextId(), createdAt: draft.asOfDate);
    state = [review, ...state];
    return review;
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-succession-coverage-review-${sequence.toString().padLeft(3, '0')}';
  }
}

final filteredIncomingTalentSuccessionCoverageReviewsProvider =
    Provider<List<IncomingTalentSuccessionCoverageReview>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentSuccessionCoverageReviewsProvider)
          .where(
            (review) =>
                (selectedDepartment == talentAllDepartments ||
                    review.departmentScope == selectedDepartment) &&
                (!attentionOnly || review.needsAttention),
          )
          .toList();
    });

final incomingTalentSuccessionCoverageReviewSummaryProvider =
    Provider<IncomingTalentSuccessionCoverageReviewSummary>((ref) {
      return IncomingTalentSuccessionCoverageReviewSummary.fromReviews(
        reviews: ref.watch(
          filteredIncomingTalentSuccessionCoverageReviewsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

String _scopeLabel(String departmentScope, bool attentionOnly) {
  final base =
      departmentScope == talentAllDepartments
          ? 'All departments'
          : departmentScope;
  return attentionOnly ? '$base - attention only' : base;
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
