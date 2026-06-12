import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/dashboard_action_tracking_provider.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('dashboard action tracking moves actions through lifecycle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(dashboardActionTrackingProvider.notifier);

    expect(
      controller.statusFor(hrisDashboardCriticalActionId),
      DashboardActionStatus.open,
    );

    controller.start(hrisDashboardCriticalActionId);
    expect(
      container.read(
        dashboardActionTrackingProvider,
      )[hrisDashboardCriticalActionId],
      DashboardActionStatus.inProgress,
    );

    controller.complete(hrisDashboardCriticalActionId);
    expect(
      container.read(
        dashboardActionTrackingProvider,
      )[hrisDashboardCriticalActionId],
      DashboardActionStatus.done,
    );

    controller.reopen(hrisDashboardCriticalActionId);
    expect(
      container.read(
        dashboardActionTrackingProvider,
      )[hrisDashboardCriticalActionId],
      DashboardActionStatus.open,
    );
  });

  test('dashboard action tracking can clear stale recommendation statuses', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(dashboardActionTrackingProvider.notifier);

    controller.start(hrisDashboardCriticalActionId);
    controller.complete('stale-action');

    controller.clearResolved([hrisDashboardCriticalActionId]);

    expect(container.read(dashboardActionTrackingProvider).keys, [
      hrisDashboardCriticalActionId,
    ]);
  });

  test('dashboard hide completed actions preference can be toggled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dashboardHideCompletedActionsProvider), isFalse);

    container.read(dashboardHideCompletedActionsProvider.notifier).state = true;

    expect(container.read(dashboardHideCompletedActionsProvider), isTrue);
  });

  test('dashboard action owner focus preference can be changed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dashboardActionOwnerFocusProvider), 'All owners');

    container.read(dashboardActionOwnerFocusProvider.notifier).state =
        hrisDashboardCriticalOwnerLabel;

    expect(
      container.read(dashboardActionOwnerFocusProvider),
      hrisDashboardCriticalOwnerLabel,
    );
  });

  test('dashboard action priority focus preference can be changed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dashboardActionPriorityFocusProvider), isNull);

    container.read(dashboardActionPriorityFocusProvider.notifier).state =
        DashboardActionPriority.high;

    expect(
      container.read(dashboardActionPriorityFocusProvider),
      DashboardActionPriority.high,
    );
  });

  test('dashboard action urgency focus preference can be changed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dashboardActionUrgencyFocusProvider), isNull);

    container.read(dashboardActionUrgencyFocusProvider.notifier).state =
        DashboardActionUrgencyTier.now;

    expect(
      container.read(dashboardActionUrgencyFocusProvider),
      DashboardActionUrgencyTier.now,
    );
  });
}
