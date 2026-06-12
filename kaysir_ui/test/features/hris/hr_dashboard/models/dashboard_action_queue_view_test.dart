import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_view.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test(
    'dashboard action queue view composes status, priority, and owner focus',
    () {
      final view = DashboardActionQueueView.fromSummary(
        summary: hrisDashboardActionSummary,
        statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
        hideCompleted: true,
        selectedOwner: hrisDashboardCriticalOwnerLabel,
        selectedPriority: DashboardActionPriority.critical,
      );

      expect(view.queueRecommendations.map((item) => item.id), [
        hrisDashboardCriticalActionId,
        hrisDashboardScaleMomentumActionId,
      ]);
      expect(view.urgencySummaries.map((summary) => summary.tier), [
        DashboardActionUrgencyTier.now,
        DashboardActionUrgencyTier.planned,
      ]);
      expect(view.prioritySummaries.map((summary) => summary.priority), [
        DashboardActionPriority.critical,
        DashboardActionPriority.medium,
      ]);
      expect(view.ownerSummaries.map((summary) => summary.ownerLabel), [
        hrisDashboardCriticalOwnerLabel,
      ]);
      expect(view.visibleRecommendations.map((item) => item.id), [
        hrisDashboardCriticalActionId,
      ]);
      expect(
        view.statusFor(view.visibleRecommendations.first),
        DashboardActionStatus.inProgress,
      );
      expect(view.progress.openCount, 1);
      expect(view.progress.inProgressCount, 1);
      expect(view.progress.doneCount, 1);
      expect(view.health.label, 'In motion');
      expect(view.health.headline, '1 due-now action is being worked');
      expect(view.focus.activeLabels, [
        'Done hidden',
        'Priority: Critical',
        'Owner: $hrisDashboardCriticalOwnerLabel',
      ]);
      expect(
        view.insight.headline,
        '$hrisDashboardCriticalOwnerLabel owns the critical action in focus',
      );
    },
  );

  test('dashboard action queue view normalizes unavailable focus values', () {
    final view = DashboardActionQueueView.fromSummary(
      summary: hrisDashboardActionSummary,
      statuses: const {},
      hideCompleted: false,
      selectedOwner: 'Former owner',
      selectedPriority: DashboardActionPriority.low,
    );

    expect(view.selectedOwner, dashboardActionAllOwners);
    expect(view.selectedPriority, isNull);
    expect(view.selectedUrgency, isNull);
    expect(view.focus.hasActiveFocus, isFalse);
    expect(view.visibleRecommendations.map((item) => item.id), [
      hrisDashboardTimeSensitiveActionId,
      hrisDashboardCriticalActionId,
      hrisDashboardScaleMomentumActionId,
    ]);
  });

  test(
    'dashboard action queue view scopes owner choices by priority focus',
    () {
      final view = DashboardActionQueueView.fromSummary(
        summary: hrisDashboardActionSummary,
        statuses: const {},
        hideCompleted: false,
        selectedOwner: hrisDashboardCriticalOwnerLabel,
        selectedPriority: DashboardActionPriority.high,
      );

      expect(view.selectedPriority, DashboardActionPriority.high);
      expect(view.selectedOwner, dashboardActionAllOwners);
      expect(view.canShowOwnerFilter, isFalse);
      expect(view.visibleRecommendations.map((item) => item.id), [
        hrisDashboardTimeSensitiveActionId,
      ]);
    },
  );

  test('dashboard action queue view can focus actions by urgency', () {
    final view = DashboardActionQueueView.fromSummary(
      summary: hrisDashboardActionSummary,
      statuses: const {},
      hideCompleted: false,
      selectedOwner: dashboardActionAllOwners,
      selectedPriority: null,
      selectedUrgency: DashboardActionUrgencyTier.now,
    );

    expect(view.selectedUrgency, DashboardActionUrgencyTier.now);
    expect(view.urgencyRecommendations.map((item) => item.id), [
      hrisDashboardCriticalActionId,
    ]);
    expect(view.prioritySummaries.map((summary) => summary.priority), [
      DashboardActionPriority.critical,
    ]);
    expect(view.visibleRecommendations.map((item) => item.id), [
      hrisDashboardCriticalActionId,
    ]);
    expect(view.focus.activeLabels, ['Urgency: Due now']);
  });

  test(
    'dashboard action queue view exposes empty state when all actions are hidden',
    () {
      final view = DashboardActionQueueView.fromSummary(
        summary: hrisDashboardCriticalActionSummary,
        statuses: hrisDashboardCriticalDoneStatuses,
        hideCompleted: true,
        selectedOwner: dashboardActionAllOwners,
        selectedPriority: null,
      );

      expect(view.hasNoVisibleRecommendations, isTrue);
      expect(view.visibleRecommendations, isEmpty);
      expect(view.focus.resultLabel, 'Showing 0 of 1 actions');
      expect(view.insight.headline, 'No actions in focus');
    },
  );
}
