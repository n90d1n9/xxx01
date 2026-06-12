import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/assesment/states/feedback_provider.dart';

void main() {
  test('feedback summary starts with available employees and categories', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final summary = container.read(feedbackSummaryProvider);

    expect(summary.employeeCount, 3);
    expect(summary.categoryCount, 5);
    expect(summary.ratedCount, 0);
    expect(summary.averageRating, 0);
    expect(summary.hasCompleteRatings, isFalse);
  });

  test('feedback summary tracks selected employee ratings and comments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(feedbackProvider.notifier);
    final state = container.read(feedbackProvider);
    notifier.selectEmployee(state.employees.first);
    notifier.updateRating('comm', 4.5);
    notifier.updateRating('teamwork', 3.5);
    notifier.updateComments('Strong collaborator with clear updates.');

    final updatedState = container.read(feedbackProvider);
    final summary = container.read(feedbackSummaryProvider);

    expect(updatedState.selectedEmployee?.name, 'Alex Johnson');
    expect(updatedState.comments, 'Strong collaborator with clear updates.');
    expect(summary.ratedCount, 2);
    expect(summary.averageRating, 4);
    expect(summary.hasCompleteRatings, isFalse);
  });

  test('feedback readiness blocks incomplete submissions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(feedbackProvider.notifier);
    final state = container.read(feedbackProvider);
    notifier.selectEmployee(state.employees.first);
    notifier.updateRating('comm', 4);
    notifier.updateComments('Clear progress and ownership.');

    final readiness = container.read(feedbackReadinessSummaryProvider);

    expect(readiness.hasSelectedEmployee, isTrue);
    expect(readiness.hasComments, isTrue);
    expect(readiness.ratedCount, 1);
    expect(readiness.missingCategoryCount, 4);
    expect(readiness.completionRate, 0.2);
    expect(readiness.canSubmit, isFalse);
  });

  test('feedback readiness allows complete rated feedback', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(feedbackProvider.notifier);
    final state = container.read(feedbackProvider);
    notifier.selectEmployee(state.employees.first);
    for (final category in state.categories) {
      notifier.updateRating(category.id, 4);
    }
    notifier.updateComments('Ready for calibration review.');

    final readiness = container.read(feedbackReadinessSummaryProvider);

    expect(readiness.missingCategoryCount, 0);
    expect(readiness.completionRate, 1);
    expect(readiness.canSubmit, isTrue);
  });
}
