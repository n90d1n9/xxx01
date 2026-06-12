import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';

void main() {
  test('recruitment summary aggregates hiring signals', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(recruitmentSummaryProvider);

    expect(summary.openRequisitions, 4);
    expect(summary.activeCandidates, 4);
    expect(summary.interviewsToday, 2);
    expect(summary.pendingOffers, 2);
    expect(summary.sourceHireRate, closeTo(11 / 157, 0.0001));
  });

  test('priority filter focuses operations recruiting work', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(recruitmentDepartmentProvider.notifier).state = 'Operations';
    container.read(recruitmentPriorityOnlyProvider.notifier).state = true;

    final summary = container.read(recruitmentSummaryProvider);
    final candidates = container.read(filteredCandidateProfilesProvider);
    final sources = container.read(filteredSourceMetricsProvider);

    expect(candidates.map((item) => item.name), ['Galih Santoso']);
    expect(sources.map((item) => item.name), ['LinkedIn', 'Job board']);
    expect(summary.openRequisitions, 1);
    expect(summary.activeCandidates, 1);
    expect(summary.interviewsToday, 1);
    expect(summary.pendingOffers, 1);
    expect(summary.sourceHireRate, closeTo(4 / 100, 0.0001));
  });

  test('pipeline risk summary highlights urgent recruiting work', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(recruitmentPipelineRiskProvider);

    expect(risks.highPriorityRequisitions, 2);
    expect(risks.candidateFollowUps, 1);
    expect(risks.feedbackDue, 1);
    expect(risks.expiringOffers, 2);
    expect(risks.sourcesToWatch, 2);
    expect(risks.totalRisks, 8);
  });

  test('recruitment date override drives today interview selection', () {
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final interviews = container.read(interviewSlotsProvider);
    final summary = container.read(recruitmentSummaryProvider);

    expect(interviews.first.scheduledAt, DateTime(2026, 7, 10, 10, 30));
    expect(summary.interviewsToday, 2);
  });
}
