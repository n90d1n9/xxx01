import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/service_center/states/service_center_provider.dart';

void main() {
  test('service center summary aggregates support signals', () {
    final container = ProviderContainer(
      overrides: [
        serviceCenterAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30, 9),
        ),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(serviceCenterSummaryProvider);

    expect(summary.openCases, 4);
    expect(summary.slaRisks, 2);
    expect(summary.documentBacklog, 3);
    expect(summary.policies, 4);
    expect(summary.helpfulRate, closeTo(984 / 1212, 0.0001));
  });

  test('SLA view focuses payroll support risks', () {
    final container = ProviderContainer(
      overrides: [
        serviceCenterAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30, 9),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(serviceCenterCategoryProvider.notifier).state = 'Payroll';
    container.read(serviceCenterUrgentOnlyProvider.notifier).state = true;

    final summary = container.read(serviceCenterSummaryProvider);
    final cases = container.read(filteredServiceDeskCasesProvider);
    final documents = container.read(filteredDocumentRequestsProvider);
    final policies = container.read(filteredPolicyArticlesProvider);
    final announcements = container.read(filteredServiceAnnouncementsProvider);

    expect(cases.map((item) => item.subject), ['Overtime allowance mismatch']);
    expect(documents.where((item) => item.isPending).length, 3);
    expect(policies.map((item) => item.title), [
      'Payroll correction request guide',
    ]);
    expect(announcements.map((item) => item.title), [
      'Payroll cutoff reminder',
    ]);
    expect(summary.openCases, 1);
    expect(summary.slaRisks, 1);
    expect(summary.documentBacklog, 3);
    expect(summary.policies, 1);
    expect(summary.helpfulRate, closeTo(241 / 318, 0.0001));
  });

  test('service center risk summary aggregates urgent support signals', () {
    final container = ProviderContainer(
      overrides: [
        serviceCenterAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30, 9),
        ),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(serviceCenterRiskSummaryProvider);

    expect(risks.urgentCases, 1);
    expect(risks.slaRiskCases, 2);
    expect(risks.dueSoonDocuments, 3);
    expect(risks.lowHelpfulnessPolicies, 2);
    expect(risks.warningAnnouncements, 1);
    expect(risks.dueWithinTwentyFourHours, 7);
    expect(risks.totalRisks, 9);
  });

  test('service center date override drives generated support dates', () {
    final container = ProviderContainer(
      overrides: [
        serviceCenterAsOfDateProvider.overrideWithValue(
          DateTime(2026, 7, 10, 9),
        ),
      ],
    );
    addTearDown(container.dispose);

    final cases = container.read(serviceDeskCasesProvider);
    final documents = container.read(documentRequestsProvider);
    final announcements = container.read(serviceAnnouncementsProvider);

    expect(cases.first.dueAt, DateTime(2026, 7, 10, 14));
    expect(documents.first.neededBy, DateTime(2026, 7, 11, 9));
    expect(announcements.first.publishAt, DateTime(2026, 7, 10, 12));
  });
}
