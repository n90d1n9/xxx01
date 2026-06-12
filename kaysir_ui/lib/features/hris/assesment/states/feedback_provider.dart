import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../employee/models/employee.dart';
import '../data/feedback_seed_data.dart';
import 'feedback_state.dart';

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>(
  (ref) {
    return FeedbackNotifier();
  },
);

final feedbackSummaryProvider = Provider<FeedbackSummary>((ref) {
  return FeedbackSummary.fromState(ref.watch(feedbackProvider));
});

final feedbackReadinessSummaryProvider = Provider<FeedbackReadinessSummary>((
  ref,
) {
  return FeedbackReadinessSummary.fromState(ref.watch(feedbackProvider));
});

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier()
    : super(
        FeedbackState(
          employees: buildFeedbackEmployees(),
          categories: buildFeedbackCategories(),
        ),
      );

  void selectEmployee(Employee employee) {
    state = state.copyWith(selectedEmployee: employee);
  }

  void updateRating(String categoryId, double rating) {
    final updatedRatings = {...state.ratings};
    updatedRatings[categoryId] = rating;
    state = state.copyWith(ratings: updatedRatings);
  }

  void updateComments(String comments) {
    state = state.copyWith(comments: comments);
  }

  Future<void> submitFeedback() async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(isSubmitting: false, isSubmitted: true);

    // Reset after showing success
    await Future.delayed(const Duration(seconds: 2));
    state = FeedbackState(
      employees: state.employees,
      categories: state.categories,
    );
  }
}
