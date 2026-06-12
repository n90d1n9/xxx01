import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_audit_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_communication_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_coverage_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_filter_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_publish_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_release_approval_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_release_package_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_workforce_impact_models.dart';
import 'package:kaysir/features/hris/holidays/states/holiday_provider.dart';

void main() {
  test('holiday summary aggregates types and upcoming days', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final summary = container.read(holidaySummaryProvider);

    expect(summary.totalCount, 4);
    expect(summary.nationalCount, 1);
    expect(summary.fixedCount, 1);
    expect(summary.anniversaryCount, 1);
    expect(summary.customCount, 1);
    expect(summary.paidCount, 4);
    expect(summary.recurringCount, 3);
    expect(summary.upcomingCount, 1);
    expect(summary.nextHoliday?.name, 'Quarterly Wellness Day');
  });

  test('holiday type filter focuses records by category', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedHolidayTypeProvider.notifier).state =
        HolidayType.custom;

    final holidays = container.read(filteredHolidayRecordsProvider);

    expect(holidays.map((item) => item.name), ['Quarterly Wellness Day']);
  });

  test('holiday discovery filters by search and quick views', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final counts = container.read(holidayCalendarViewCountsProvider);
    expect(counts.allCount, 4);
    expect(counts.upcomingCount, 1);
    expect(counts.coverageCount, 2);
    expect(counts.policyIssueCount, 1);
    expect(counts.unpaidCustomCount, 0);

    container.read(holidaySearchQueryProvider.notifier).state = 'labor';
    expect(
      container.read(filteredHolidayRecordsProvider).map((item) => item.name),
      ['National Labor Day'],
    );

    container.read(holidaySearchQueryProvider.notifier).state = '';
    container.read(selectedHolidayQuickViewProvider.notifier).state =
        HolidayCalendarQuickView.policyIssues;
    expect(
      container.read(filteredHolidayRecordsProvider).map((item) => item.name),
      ['Quarterly Wellness Day'],
    );

    container
        .read(holidayRecordsProvider.notifier)
        .addHoliday(
          HolidayRecord(
            id: 'team-shutdown',
            name: 'Team Shutdown',
            type: HolidayType.custom,
            date: DateTime(2026, 6, 20),
            scope: 'Fulfillment',
            isPaid: false,
            isRecurring: false,
          ),
        );

    container.read(selectedHolidayQuickViewProvider.notifier).state =
        HolidayCalendarQuickView.unpaidCustom;
    expect(
      container.read(filteredHolidayRecordsProvider).map((item) => item.name),
      ['Team Shutdown'],
    );

    container.read(selectedHolidayTypeProvider.notifier).state =
        HolidayType.national;
    expect(container.read(filteredHolidayRecordsProvider), isEmpty);
  });

  test('holiday notifier supports add update and delete', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    const id = 'custom-founders-day';
    final holiday = HolidayRecord(
      id: id,
      name: 'Founders Day',
      type: HolidayType.anniversary,
      date: DateTime(2026, 7, 1),
      scope: 'All employees',
      isPaid: true,
      isRecurring: true,
    );

    container.read(holidayRecordsProvider.notifier).addHoliday(holiday);
    expect(container.read(holidaySummaryProvider).anniversaryCount, 2);

    container
        .read(holidayRecordsProvider.notifier)
        .updateHoliday(holiday.copyWith(name: 'Founder Day'));
    expect(
      container
          .read(holidayRecordsProvider)
          .singleWhere((item) => item.id == id)
          .name,
      'Founder Day',
    );

    container.read(holidayRecordsProvider.notifier).deleteHoliday(id);
    expect(
      container.read(holidayRecordsProvider).any((item) => item.id == id),
      isFalse,
    );
  });

  test('holiday audit log records calendar mutations', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(holidayAuditSummaryProvider).hasActivity, isFalse);

    const id = 'custom-founders-day';
    final holiday = HolidayRecord(
      id: id,
      name: 'Founders Day',
      type: HolidayType.anniversary,
      date: DateTime(2026, 7, 1),
      scope: 'All employees',
      isPaid: true,
      isRecurring: true,
    );
    final updatedHoliday = holiday.copyWith(
      name: 'Founder Day',
      requiresCoveragePlan: true,
    );

    final notifier = container.read(holidayRecordsProvider.notifier);
    notifier.addHoliday(holiday);
    notifier.updateHoliday(updatedHoliday);
    notifier.deleteHoliday(id);

    final summary = container.read(holidayAuditSummaryProvider);
    final entries = summary.entries;

    expect(summary.totalCount, 3);
    expect(summary.createdCount, 1);
    expect(summary.updatedCount, 1);
    expect(summary.deletedCount, 1);
    expect(summary.releaseSensitiveCount, 2);
    expect(summary.latestEntry?.action, HolidayAuditAction.deleted);
    expect(summary.latestEntry?.holidayName, 'Founder Day');
    expect(summary.latestEntry?.recordedAt, DateTime(2026, 5, 30, 0, 3));
    expect(entries.map((entry) => entry.action), [
      HolidayAuditAction.deleted,
      HolidayAuditAction.updated,
      HolidayAuditAction.created,
    ]);
    expect(entries[1].sensitivity, HolidayAuditSensitivity.releaseSensitive);
    expect(entries[1].details, [
      'Name changed from Founders Day to Founder Day',
      'Coverage planning changed to required',
    ]);
    expect(
      entries.last.summary,
      'Added Anniversary holiday for All employees.',
    );
  });

  test('holiday risk summary highlights coverage-sensitive upcoming days', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final risks = container.read(holidayRiskSummaryProvider);

    expect(risks.upcomingWithinThirtyDays, 1);
    expect(risks.coverageGaps, 1);
    expect(risks.unpaidCustomDays, 0);
    expect(risks.totalRisks, 1);
  });

  test('holiday coverage plan ranks readiness work', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(holidayCoveragePlanProvider);

    expect(plan.items, hasLength(1));
    expect(plan.readinessScore, 70);
    expect(plan.readinessLabel, 'Needs review');
    expect(plan.urgentCount, 1);
    expect(plan.coverageRequiredCount, 1);
    expect(plan.customCount, 1);
    expect(plan.observedShiftCount, 1);
    expect(plan.unpaidCustomCount, 0);
    expect(plan.items.single.holiday.name, 'Quarterly Wellness Day');
    expect(plan.items.single.daysUntil, 14);
    expect(plan.items.single.priority, HolidayCoveragePriority.urgent);
    expect(plan.items.single.action, 'Confirm coverage owners');
  });

  test('holiday policy review flags governance issues', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(holidayRecordsProvider.notifier);
    notifier.addHoliday(
      HolidayRecord(
        id: 'custom-focus-day',
        name: 'Founders Focus Day',
        type: HolidayType.custom,
        date: DateTime(2026, 7, 7),
        scope: 'All offices',
        isPaid: true,
        isRecurring: false,
      ),
    );
    notifier.addHoliday(
      HolidayRecord(
        id: 'regional-pause',
        name: 'Regional Pause',
        type: HolidayType.custom,
        date: DateTime(2026, 6, 13),
        scope: '',
        isPaid: false,
        isRecurring: false,
      ),
    );

    final review = container.read(holidayPolicyReviewProvider);

    expect(review.checkedRules, 7);
    expect(review.criticalCount, 2);
    expect(review.warningCount, 2);
    expect(review.advisoryCount, 1);
    expect(review.policyScore, 10);
    expect(review.policyLabel, 'At risk');
    expect(review.issues.map((issue) => issue.title), [
      'Duplicate observed date',
      'Missing eligibility scope',
      'Custom day needs coverage decision',
      'Unpaid custom day needs rationale',
      'Observed date shifted',
    ]);
  });

  test('holiday communication plan builds announcement briefs', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(holidayCommunicationPlanProvider);
    final brief = plan.briefs.single;

    expect(plan.readinessScore, 82);
    expect(plan.readinessLabel, 'Needs review');
    expect(plan.urgentCount, 0);
    expect(plan.reviewCount, 1);
    expect(plan.scheduledCount, 0);
    expect(plan.audienceCount, 5);
    expect(brief.holiday.name, 'Quarterly Wellness Day');
    expect(brief.daysUntil, 14);
    expect(brief.priority, HolidayCommunicationPriority.review);
    expect(brief.audiences, [
      'Employees',
      'Managers',
      'Operations',
      'People Ops',
      'HR Comms',
    ]);
    expect(
      brief.subject,
      'Holiday notice: Quarterly Wellness Day on Jun 13, 2026',
    );
    expect(
      brief.managerAction,
      'Confirm staffing coverage before Jun 13, 2026.',
    );
    expect(
      brief.payrollAction,
      'Confirm paid custom holiday treatment for payroll.',
    );
  });

  test('holiday publish readiness summarizes release blockers', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final readiness = container.read(holidayPublishReadinessProvider);

    expect(readiness.status, HolidayPublishStatus.blocked);
    expect(readiness.readinessScore, 39);
    expect(readiness.blockedCount, 1);
    expect(readiness.attentionCount, 3);
    expect(readiness.readyCount, 1);
    expect(readiness.nextAction, 'Assign coverage owners before publishing.');
    expect(readiness.isPublishable, isFalse);
    expect(readiness.items.map((item) => item.title), [
      'Calendar inventory',
      'Policy controls',
      'Coverage planning',
      'Communication readiness',
      'Payroll impact',
    ]);
  });

  test('holiday release approval gate tracks approvable sign-offs', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final plan = container.read(holidayReleaseApprovalPlanProvider);
    final calendarStep = plan.steps.first;
    final coverageStep = plan.steps.singleWhere(
      (step) => step.id == 'coverage-planning',
    );

    expect(plan.totalStepCount, 5);
    expect(plan.approvedCount, 0);
    expect(plan.pendingCount, 1);
    expect(plan.waitingCount, 3);
    expect(plan.blockedCount, 1);
    expect(plan.approvableCount, 1);
    expect(plan.approvalScore, 0);
    expect(plan.nextStep?.id, 'coverage-planning');
    expect(plan.nextAction, 'Assign coverage owners before publishing.');
    expect(calendarStep.owner, 'HR Operations');
    expect(calendarStep.status, HolidayReleaseApprovalStatus.pending);
    expect(calendarStep.canApprove, isTrue);
    expect(coverageStep.status, HolidayReleaseApprovalStatus.blocked);
    expect(coverageStep.canApprove, isFalse);

    final approvals = container.read(
      holidayReleaseApprovalDecisionsProvider.notifier,
    );
    approvals.approveStep('calendar-inventory');
    approvals.approveStep('coverage-planning');

    final approvedPlan = container.read(holidayReleaseApprovalPlanProvider);
    expect(approvedPlan.approvedCount, 1);
    expect(approvedPlan.pendingCount, 0);
    expect(approvedPlan.blockedCount, 1);
    expect(approvedPlan.approvalScore, 20);
    expect(
      approvedPlan.steps.first.status,
      HolidayReleaseApprovalStatus.approved,
    );
    expect(approvedPlan.steps.first.canRevoke, isTrue);

    approvals.revokeStep('calendar-inventory');
    expect(container.read(holidayReleaseApprovalPlanProvider).approvedCount, 0);
  });

  test('holiday release package assembles evidence packet', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final package = container.read(holidayReleasePackageProvider);

    expect(package.packageId, 'HOL-2026-004');
    expect(package.status, HolidayReleasePackageStatus.blocked);
    expect(
      package.releaseWindow,
      'Next holiday: Quarterly Wellness Day on Jun 13, 2026.',
    );
    expect(package.nextAction, 'Assign coverage owners before publishing.');
    expect(package.evidenceCount, 7);
    expect(package.blockedCount, 3);
    expect(package.attentionCount, 3);
    expect(package.completeCount, 1);
    expect(package.packageScore, 22);
    expect(package.evidence.map((item) => item.title), [
      'Calendar inventory',
      'Release checklist',
      'Approval gate',
      'Operations coverage',
      'Policy evidence',
      'Communication packet',
      'Change audit',
    ]);
    expect(
      package.evidence.first.status,
      HolidayReleaseEvidenceStatus.complete,
    );
    expect(
      package.evidence.singleWhere((item) => item.id == 'approvals').status,
      HolidayReleaseEvidenceStatus.blocked,
    );
  });

  test('holiday timeline groups upcoming rules by month impact', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final timeline = container.read(holidayTimelineProvider);
    final june = timeline.buckets.first;
    final august = timeline.buckets.last;

    expect(timeline.horizonDays, 180);
    expect(timeline.totalUpcomingCount, 2);
    expect(timeline.coverageHolidayCount, 1);
    expect(timeline.customHolidayCount, 1);
    expect(timeline.observedShiftCount, 1);
    expect(timeline.busiestBucket?.label, 'Jun 2026');
    expect(timeline.buckets.map((bucket) => bucket.label), [
      'Jun 2026',
      'Aug 2026',
    ]);
    expect(june.holidayCount, 1);
    expect(june.daysUntilFirstHoliday, 14);
    expect(june.impactLabel, 'Coverage focus');
    expect(june.hasPlanningPressure, isTrue);
    expect(june.holidays.single.name, 'Quarterly Wellness Day');
    expect(august.impactLabel, 'Standard');
    expect(august.paidCount, 1);
  });

  test('holiday workforce impact groups upcoming scope pressure', () {
    final container = ProviderContainer(
      overrides: [
        holidayAsOfDateProvider.overrideWithValue(DateTime(2026, 5, 30)),
      ],
    );
    addTearDown(container.dispose);

    final impact = container.read(holidayWorkforceImpactProvider);
    final peopleOps = impact.scopes.first;
    final allEmployees = impact.scopes.last;

    expect(impact.horizonDays, 90);
    expect(impact.totalHolidayCount, 2);
    expect(impact.totalEstimatedEmployees, 146);
    expect(impact.totalCoverageRoles, 2);
    expect(impact.highImpactCount, 1);
    expect(impact.customScopeCount, 1);
    expect(impact.nextScope?.scope, 'People Operations');
    expect(impact.scopes.map((scope) => scope.scope), [
      'People Operations',
      'All employees',
    ]);
    expect(peopleOps.level, HolidayWorkforceImpactLevel.high);
    expect(peopleOps.estimatedEmployees, 18);
    expect(peopleOps.coverageRoles, 2);
    expect(peopleOps.daysUntilNext, 14);
    expect(peopleOps.nextHoliday?.name, 'Quarterly Wellness Day');
    expect(peopleOps.items.single.signal, 'Coverage owners needed');
    expect(
      peopleOps.items.single.action,
      'Assign coverage owners for People Operations.',
    );
    expect(allEmployees.level, HolidayWorkforceImpactLevel.low);
    expect(allEmployees.estimatedEmployees, 128);
    expect(allEmployees.nextHoliday?.name, 'Company Anniversary');
  });
}
