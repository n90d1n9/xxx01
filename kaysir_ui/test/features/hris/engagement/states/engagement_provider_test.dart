import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/engagement/states/engagement_provider.dart';

void main() {
  test('engagement summary aggregates engagement signals', () {
    final container = ProviderContainer(
      overrides: [
        engagementAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(engagementSummaryProvider);

    expect(summary.liveSurveys, 1);
    expect(summary.actionItems, 3);
    expect(summary.highRisks, 1);
    expect(summary.recognitionCount, 3);
    expect(summary.averagePulseScore, 75.25);
  });

  test('attention filter focuses operations on urgent engagement items', () {
    final container = ProviderContainer(
      overrides: [
        engagementAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(engagementDepartmentProvider.notifier).state = 'Operations';
    container.read(engagementAttentionOnlyProvider.notifier).state = true;

    final summary = container.read(engagementSummaryProvider);
    final surveys = container.read(filteredEngagementSurveysProvider);
    final actions = container.read(filteredEngagementActionPlansProvider);

    expect(surveys.map((item) => item.title), ['Operations scheduling check']);
    expect(actions, isEmpty);
    expect(summary.liveSurveys, 0);
    expect(summary.actionItems, 0);
    expect(summary.highRisks, 1);
    expect(summary.recognitionCount, 0);
    expect(summary.averagePulseScore, 63);
  });

  test('engagement risk summary aggregates urgent people signals', () {
    final container = ProviderContainer(
      overrides: [
        engagementAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(engagementRiskSummaryProvider);

    expect(risks.actionRequiredSurveys, 1);
    expect(risks.lowPulseTopics, 1);
    expect(risks.highWellbeingRisks, 1);
    expect(risks.blockedActionPlans, 0);
    expect(risks.dueWithinSevenDays, 4);
    expect(risks.totalRisks, 3);
  });

  test('engagement date override drives generated activity dates', () {
    final container = ProviderContainer(
      overrides: [
        engagementAsOfDateProvider.overrideWithValue(DateTime(2026, 7, 10)),
      ],
    );
    addTearDown(container.dispose);

    final surveys = container.read(engagementSurveysProvider);
    final recognitions = container.read(recognitionMomentsProvider);

    expect(surveys.first.closesAt, DateTime(2026, 7, 15));
    expect(recognitions.first.recognizedAt, DateTime(2026, 7, 9));
  });
}
