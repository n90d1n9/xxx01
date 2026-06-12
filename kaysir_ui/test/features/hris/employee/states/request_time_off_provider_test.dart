import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';

void main() {
  test('request time off review summarizes default draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final review = container.read(requestTimeOffReviewProvider);

    expect(review.draft.type, 'Vacation');
    expect(review.durationDays, 3);
    expect(review.balance.remainingDays, 8);
    expect(review.remainingAfterRequest, 5);
    expect(review.canSubmit, isFalse);
    expect(review.guidance, 'Add a short reason before submitting.');
  });

  test('request time off review becomes submittable with valid reason', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(requestTimeOffDraftProvider.notifier)
        .setReason('Family trip');

    final review = container.read(requestTimeOffReviewProvider);

    expect(review.canSubmit, isTrue);
    expect(review.guidance, 'Ready for manager review.');
  });

  test('request time off review blocks requests above balance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(requestTimeOffDraftProvider.notifier);
    notifier.setType('Personal');
    notifier.setReason('Personal appointment');
    notifier.setEndDate(DateTime(2026, 6, 11));

    final review = container.read(requestTimeOffReviewProvider);

    expect(review.durationDays, 6);
    expect(review.balance.remainingDays, 4);
    expect(review.remainingAfterRequest, -2);
    expect(review.canSubmit, isFalse);
    expect(
      review.guidance,
      'This request exceeds the available Personal balance.',
    );
  });

  test('request time off draft keeps end date aligned with start date', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(requestTimeOffDraftProvider.notifier)
        .setStartDate(DateTime(2026, 8, 10));

    final draft = container.read(requestTimeOffDraftProvider);

    expect(draft.startDate, DateTime(2026, 8, 10));
    expect(draft.endDate, DateTime(2026, 8, 10));
    expect(draft.durationDays, 1);
  });
}
