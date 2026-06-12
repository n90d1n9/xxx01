import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/compensation/states/compensation_provider.dart';

void main() {
  test('compensation summary aggregates pay and benefits signals', () {
    final container = ProviderContainer(
      overrides: [
        compensationAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(compensationSummaryProvider);

    expect(summary.reviewItems, 3);
    expect(summary.pendingApprovals, 1);
    expect(summary.benefitIssues, 1);
    expect(summary.allowanceWatch, 2);
    expect(summary.incentivePending, 3);
  });

  test('attention filter focuses operations compensation exceptions', () {
    final container = ProviderContainer(
      overrides: [
        compensationAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(compensationDepartmentProvider.notifier).state =
        'Operations';
    container.read(compensationAttentionOnlyProvider.notifier).state = true;

    final summary = container.read(compensationSummaryProvider);
    final reviews = container.read(filteredCompensationReviewsProvider);
    final benefits = container.read(filteredBenefitEnrollmentsProvider);

    expect(reviews.map((item) => item.employeeName), ['Rizky Pratama']);
    expect(benefits.map((item) => item.employeeName), [
      'Casey Johnson',
      'Rizky Pratama',
    ]);
    expect(summary.reviewItems, 1);
    expect(summary.pendingApprovals, 0);
    expect(summary.benefitIssues, 1);
    expect(summary.allowanceWatch, 1);
    expect(summary.incentivePending, 1);
  });

  test('compensation risk summary aggregates urgent reward signals', () {
    final container = ProviderContainer(
      overrides: [
        compensationAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(compensationRiskSummaryProvider);

    expect(risks.blockedReviews, 1);
    expect(risks.lowMarketPercentileReviews, 1);
    expect(risks.benefitIssues, 1);
    expect(risks.budgetExceptions, 2);
    expect(risks.pendingIncentiveApprovals, 2);
    expect(risks.dueWithinFourteenDays, 6);
    expect(risks.totalRisks, 7);
  });

  test('compensation date override drives generated deadlines', () {
    final container = ProviderContainer(
      overrides: [
        compensationAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final reviews = container.read(compensationReviewsProvider);
    final benefits = container.read(benefitEnrollmentsProvider);
    final incentives = container.read(incentivePayoutsProvider);

    expect(reviews.first.effectiveDate, DateTime(2026, 8, 11));
    expect(benefits.first.deadline, DateTime(2026, 7, 14));
    expect(incentives.first.payoutDate, DateTime(2026, 7, 22));
  });
}
