import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_focus_preset.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_view.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('action focus presets summarize queue shortcuts', () {
    final queue = DashboardActionQueueView.fromSummary(
      summary: hrisDashboardActionSummary,
      statuses: const {},
      hideCompleted: false,
      selectedOwner: dashboardActionAllOwners,
      selectedPriority: null,
    );

    final presets = buildDashboardActionFocusPresets(queue);

    expect(presets.map((preset) => preset.kind), [
      DashboardActionFocusPresetKind.dueNow,
      DashboardActionFocusPresetKind.highPriority,
      DashboardActionFocusPresetKind.topOwner,
      DashboardActionFocusPresetKind.activeWork,
    ]);
    expect(presets[0].metricLabel, '1 action');
    expect(presets[1].metricLabel, '1 action');
    expect(presets[2].helper, hrisDashboardTimeSensitiveOwnerLabel);
    expect(presets[3].metricLabel, '3 active');
    expect(presets.any((preset) => preset.selected), isFalse);
  });

  test('action focus presets mark selected queue shortcuts', () {
    final queue = DashboardActionQueueView.fromSummary(
      summary: hrisDashboardActionSummary,
      statuses: hrisDashboardScaleMomentumDoneStatuses,
      hideCompleted: true,
      selectedOwner: hrisDashboardTimeSensitiveOwnerLabel,
      selectedPriority: DashboardActionPriority.high,
      selectedUrgency: DashboardActionUrgencyTier.soon,
    );

    final presets = buildDashboardActionFocusPresets(queue);
    final selectedKinds = presets
        .where((preset) => preset.selected)
        .map((preset) => preset.kind);

    expect(selectedKinds, [
      DashboardActionFocusPresetKind.highPriority,
      DashboardActionFocusPresetKind.topOwner,
      DashboardActionFocusPresetKind.activeWork,
    ]);
    expect(presets.last.kind, DashboardActionFocusPresetKind.clearQueue);
    expect(presets.last.metricLabel, 'Reset');
  });
}
