import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_focus_preset.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_focus_preset_strip.dart';

void main() {
  testWidgets('action focus preset strip renders only controllable presets', (
    tester,
  ) async {
    final urgencyChanges = <DashboardActionUrgencyTier?>[];
    final ownerChanges = <String>[];

    await _pumpPresetStrip(
      tester,
      presets: _presets(),
      onUrgencyChanged: urgencyChanges.add,
      onOwnerChanged: ownerChanges.add,
    );

    expect(find.text('Focus presets'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('Top owner'), findsOneWidget);
    expect(find.text('Clear queue'), findsOneWidget);
    expect(find.text('High priority'), findsNothing);
    expect(find.text('Active work'), findsNothing);

    await _tapPreset(tester, 'Apply Due now preset');
    await _tapPreset(tester, 'Apply People Ops owner preset');
    await _tapPreset(tester, 'Clear all action queue focus');

    expect(urgencyChanges, [DashboardActionUrgencyTier.now, null]);
    expect(ownerChanges, ['People Ops', dashboardActionAllOwners]);
  });

  testWidgets('action focus preset strip clears selected presets', (
    tester,
  ) async {
    final hideCompletedChanges = <bool>[];
    final urgencyChanges = <DashboardActionUrgencyTier?>[];
    final priorityChanges = <DashboardActionPriority?>[];
    final ownerChanges = <String>[];

    await _pumpPresetStrip(
      tester,
      presets: _selectedPresets(),
      onHideCompletedChanged: hideCompletedChanges.add,
      onUrgencyChanged: urgencyChanges.add,
      onPriorityChanged: priorityChanges.add,
      onOwnerChanged: ownerChanges.add,
    );

    await _tapPreset(tester, 'Clear Due now preset');
    await _tapPreset(tester, 'Clear High priority preset');
    await _tapPreset(tester, 'Clear People Ops owner preset');
    await _tapPreset(tester, 'Show completed from preset');

    expect(urgencyChanges, [null]);
    expect(priorityChanges, [null]);
    expect(ownerChanges, [dashboardActionAllOwners]);
    expect(hideCompletedChanges, [false]);
  });

  testWidgets('action focus preset strip disables empty presets', (
    tester,
  ) async {
    final urgencyChanges = <DashboardActionUrgencyTier?>[];

    await _pumpPresetStrip(
      tester,
      presets: [
        _preset(
          kind: DashboardActionFocusPresetKind.dueNow,
          label: 'Due now',
          metricLabel: '0 actions',
          actionCount: 0,
          urgency: DashboardActionUrgencyTier.now,
        ),
      ],
      onUrgencyChanged: urgencyChanges.add,
    );

    expect(find.byTooltip('No due now actions'), findsOneWidget);

    await tester.tap(find.text('Due now'));
    await tester.pump();

    expect(urgencyChanges, isEmpty);
  });
}

Future<void> _pumpPresetStrip(
  WidgetTester tester, {
  required List<DashboardActionFocusPreset> presets,
  ValueChanged<bool>? onHideCompletedChanged,
  ValueChanged<String>? onOwnerChanged,
  ValueChanged<DashboardActionPriority?>? onPriorityChanged,
  ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 720,
          child: DashboardActionFocusPresetStrip(
            presets: presets,
            onHideCompletedChanged: onHideCompletedChanged,
            onOwnerChanged: onOwnerChanged,
            onPriorityChanged: onPriorityChanged,
            onUrgencyChanged: onUrgencyChanged,
          ),
        ),
      ),
    ),
  );
}

Future<void> _tapPreset(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip));
  await tester.pump();
}

List<DashboardActionFocusPreset> _presets() {
  return [
    _preset(
      kind: DashboardActionFocusPresetKind.dueNow,
      label: 'Due now',
      metricLabel: '1 action',
      actionCount: 1,
      urgency: DashboardActionUrgencyTier.now,
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.highPriority,
      label: 'High priority',
      metricLabel: '1 action',
      actionCount: 1,
      priority: DashboardActionPriority.high,
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.topOwner,
      label: 'Top owner',
      helper: 'People Ops',
      metricLabel: '2 actions',
      actionCount: 2,
      ownerLabel: 'People Ops',
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.activeWork,
      label: 'Active work',
      metricLabel: '3 active',
      actionCount: 3,
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.clearQueue,
      label: 'Clear queue',
      metricLabel: 'Reset',
      actionCount: 3,
    ),
  ];
}

List<DashboardActionFocusPreset> _selectedPresets() {
  return [
    _preset(
      kind: DashboardActionFocusPresetKind.dueNow,
      label: 'Due now',
      metricLabel: '1 action',
      actionCount: 1,
      selected: true,
      urgency: DashboardActionUrgencyTier.now,
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.highPriority,
      label: 'High priority',
      metricLabel: '1 action',
      actionCount: 1,
      selected: true,
      priority: DashboardActionPriority.high,
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.topOwner,
      label: 'Top owner',
      helper: 'People Ops',
      metricLabel: '2 actions',
      actionCount: 2,
      selected: true,
      ownerLabel: 'People Ops',
    ),
    _preset(
      kind: DashboardActionFocusPresetKind.activeWork,
      label: 'Active work',
      metricLabel: '3 active',
      actionCount: 3,
      selected: true,
    ),
  ];
}

DashboardActionFocusPreset _preset({
  required DashboardActionFocusPresetKind kind,
  required String label,
  required String metricLabel,
  required int actionCount,
  String helper = '',
  bool selected = false,
  DashboardActionUrgencyTier? urgency,
  DashboardActionPriority? priority,
  String? ownerLabel,
}) {
  return DashboardActionFocusPreset(
    kind: kind,
    label: label,
    helper: helper,
    metricLabel: metricLabel,
    actionCount: actionCount,
    selected: selected,
    urgency: urgency,
    priority: priority,
    ownerLabel: ownerLabel,
  );
}
