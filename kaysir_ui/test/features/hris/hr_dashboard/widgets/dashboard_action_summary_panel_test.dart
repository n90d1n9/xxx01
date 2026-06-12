import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_priority_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_summary_panel.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action summary panel renders queue overview', (
    tester,
  ) async {
    await _pumpInteractiveSummaryPanel(
      tester,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
    );

    expect(find.text('Next best actions'), findsOneWidget);
    _expectActionCards();
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Due soon'), findsWidgets);
    expect(find.text('Open'), findsWidgets);
    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
    expect(find.text('Urgency overview'), findsOneWidget);
    expect(find.text('Due now'), findsWidgets);
    expect(find.text('Closed'), findsWidgets);
    expect(find.text('Planned'), findsWidgets);
    expect(find.text('Queue health'), findsOneWidget);
    expect(find.text('In motion'), findsOneWidget);
    expect(find.text('1 due-now action is being worked'), findsOneWidget);
    expect(find.text('Review due now'), findsOneWidget);
    expect(find.text('Hide done'), findsOneWidget);
    expect(find.text('Queue spotlight'), findsOneWidget);
    expect(
      find.text(
        '$hrisDashboardCriticalOwnerLabel owns the critical action in focus',
      ),
      findsOneWidget,
    );
    expect(find.text('Focus priority'), findsOneWidget);
    expect(find.text('Focus owner'), findsOneWidget);
  });

  testWidgets('dashboard action summary panel renders focus controls', (
    tester,
  ) async {
    await _pumpInteractiveSummaryPanel(
      tester,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
    );

    expect(find.text('Priority focus'), findsOneWidget);
    expect(find.text('All priorities (3)'), findsOneWidget);
    expect(find.text('Critical (1)'), findsOneWidget);
    expect(find.text('Urgency focus'), findsOneWidget);
    expect(find.text('$dashboardActionAllUrgencies (3)'), findsOneWidget);
    expect(find.text('Due now (1)'), findsOneWidget);
    expect(find.text('Due soon (1)'), findsNothing);
    expect(find.text('Planned (1)'), findsOneWidget);
    expect(find.text('Closed (1)'), findsOneWidget);
    expect(find.text('Owner focus'), findsOneWidget);
    expect(find.text('All owners (3)'), findsOneWidget);
    expect(find.text('$hrisDashboardCriticalOwnerLabel (1)'), findsOneWidget);
    expect(find.text(hrisDashboardCriticalActionLabel), findsOneWidget);
    expect(find.text(hrisDashboardTimeSensitiveActionLabel), findsOneWidget);
    expect(find.text('Next up'), findsOneWidget);
    expect(find.text(hrisDashboardCriticalOwnerLabel), findsOneWidget);
    expect(find.text(hrisDashboardTimeSensitiveOwnerLabel), findsOneWidget);
    expect(find.text(hrisDashboardScaleMomentumOwnerLabel), findsOneWidget);
    expect(find.text(hrisDashboardCriticalDueLabel), findsOneWidget);
    expect(find.text(hrisDashboardTimeSensitiveDueLabel), findsOneWidget);
    expect(find.text(hrisDashboardScaleMomentumDueLabel), findsOneWidget);
  });

  testWidgets('dashboard action summary panel orders queue recommendations', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
    );

    _expectActionOrder(tester, [
      hrisDashboardCriticalActionTitle,
      hrisDashboardScaleMomentumActionTitle,
      hrisDashboardTimeSensitiveActionTitle,
    ]);
  });

  testWidgets('dashboard action summary panel delegates queue actions', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
      harness: harness,
    );

    await _tapVisible(tester, find.text('Focus priority'), settleAfter: true);
    await _tapVisible(tester, find.text('Focus owner'), settleAfter: true);
    await _tapVisible(tester, find.text('Due now (1)'), settleAfter: true);
    await _tapVisible(tester, find.text('High (1)'), settleAfter: true);
    await _tapVisible(
      tester,
      find.text('$hrisDashboardScaleMomentumOwnerLabel (1)'),
      settleAfter: true,
    );
    await _tapVisible(tester, find.byType(Switch), settleAfter: true);
    await _tapVisible(
      tester,
      find.byTooltip('Mark $hrisDashboardCriticalActionTitle done'),
    );
    await _tapVisible(
      tester,
      find.byTooltip('Reopen $hrisDashboardTimeSensitiveActionTitle'),
    );

    expect(harness.started, isEmpty);
    expect(harness.completed, [hrisDashboardCriticalActionId]);
    expect(harness.reopened, [hrisDashboardTimeSensitiveActionId]);
    expect(harness.hideCompletedChanges, [true]);
    expect(harness.ownerChanges, [
      hrisDashboardCriticalOwnerLabel,
      hrisDashboardScaleMomentumOwnerLabel,
    ]);
    expect(harness.priorityChanges, [
      DashboardActionPriority.critical,
      DashboardActionPriority.high,
    ]);
    expect(harness.urgencyChanges, [DashboardActionUrgencyTier.now]);
  });

  testWidgets('dashboard action summary panel applies focus presets', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(tester, harness: harness);

    expect(find.text('Focus presets'), findsOneWidget);
    expect(find.text('Active work'), findsOneWidget);

    await _tapAndPump(tester, find.byTooltip('Apply Due now preset'));
    await _tapAndPump(tester, find.byTooltip('Apply High priority preset'));
    await _tapAndPump(
      tester,
      find.byTooltip(
        'Apply $hrisDashboardTimeSensitiveOwnerLabel owner preset',
      ),
    );
    await _tapAndPump(tester, find.byTooltip('Apply Active work preset'));

    expect(harness.urgencyChanges, [DashboardActionUrgencyTier.now]);
    expect(harness.priorityChanges, [DashboardActionPriority.high]);
    expect(harness.ownerChanges, [hrisDashboardTimeSensitiveOwnerLabel]);
    expect(harness.hideCompletedChanges, [true]);
  });

  testWidgets('dashboard action summary panel clears focus presets', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      hideCompleted: true,
      selectedOwner: hrisDashboardTimeSensitiveOwnerLabel,
      selectedPriority: DashboardActionPriority.high,
      selectedUrgency: DashboardActionUrgencyTier.soon,
      harness: harness,
    );

    expect(find.byTooltip('Show completed from preset'), findsOneWidget);
    await _tapAndPump(tester, find.byTooltip('Clear all action queue focus'));

    expect(harness.hideCompletedChanges, [false]);
    expect(harness.urgencyChanges, [null]);
    expect(harness.priorityChanges, [null]);
    expect(harness.ownerChanges, [dashboardActionAllOwners]);
  });

  testWidgets('dashboard action summary panel can focus actions by priority', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      selectedPriority: DashboardActionPriority.critical,
      statuses: hrisDashboardCriticalInProgressStatuses,
      harness: harness,
    );

    expect(find.text('Priority focus'), findsOneWidget);
    expect(find.text('$dashboardActionAllPriorities (3)'), findsOneWidget);
    expect(find.text('Critical (1)'), findsOneWidget);
    _expectActionCards(timeSensitive: false, scaleMomentum: false);

    await _tapVisible(tester, find.text('$dashboardActionAllPriorities (3)'));

    expect(harness.priorityChanges, [null]);
  });

  testWidgets('dashboard action summary panel can focus actions by urgency', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      selectedUrgency: DashboardActionUrgencyTier.now,
      harness: harness,
    );

    expect(find.text('Urgency focus'), findsOneWidget);
    expect(find.text('$dashboardActionAllUrgencies (3)'), findsOneWidget);
    expect(find.text('Due now (1)'), findsOneWidget);
    _expectActionCards(timeSensitive: false, scaleMomentum: false);

    await _tapVisible(tester, find.text('$dashboardActionAllUrgencies (3)'));

    expect(harness.urgencyChanges, [null]);
  });

  testWidgets('dashboard action summary panel marks the first visible action', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      selectedPriority: DashboardActionPriority.high,
      onPriorityChanged: (_) {},
    );

    expect(find.text('Next up'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Next up')).dy,
      lessThan(
        tester.getTopLeft(find.text(hrisDashboardTimeSensitiveActionTitle)).dy,
      ),
    );
    _expectActionCards(critical: false, scaleMomentum: false);
  });

  testWidgets('dashboard action summary panel focuses from urgency overview', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(tester, harness: harness);

    await _tapAndPump(tester, find.byTooltip('Focus Due now'));

    expect(harness.urgencyChanges, [DashboardActionUrgencyTier.now]);
  });

  testWidgets('dashboard action summary panel opens action details', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      statuses: hrisDashboardCriticalInProgressStatuses,
    );

    await _tapVisible(
      tester,
      find.byTooltip('View $hrisDashboardCriticalActionTitle details'),
      settleAfter: true,
    );

    expect(find.text('Action detail'), findsOneWidget);
    expect(find.text('Recommended next step'), findsOneWidget);
    expect(
      find.textContaining('Critical risk and total-risk pressure'),
      findsOneWidget,
    );
  });

  testWidgets('dashboard action summary panel summarizes and clears focus', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      hideCompleted: true,
      selectedPriority: DashboardActionPriority.critical,
      selectedUrgency: DashboardActionUrgencyTier.now,
      selectedOwner: hrisDashboardCriticalOwnerLabel,
      statuses: hrisDashboardTimeSensitiveDoneStatuses,
      harness: harness,
    );

    _expectFocusSummary(
      resultLabel: 'Showing 1 of 3 actions',
      hideCompleted: true,
      urgency: DashboardActionUrgencyTier.now,
      priority: DashboardActionPriority.critical,
      ownerLabel: hrisDashboardCriticalOwnerLabel,
    );
    _expectActionCards(timeSensitive: false, scaleMomentum: false);

    await _tapVisible(tester, find.text('Clear focus'));

    expect(harness.hideCompletedChanges, [false]);
    expect(harness.urgencyChanges, [null]);
    expect(harness.priorityChanges, [null]);
    expect(harness.ownerChanges, [dashboardActionAllOwners]);
  });

  testWidgets('dashboard action summary panel clears one focus chip', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      selectedPriority: DashboardActionPriority.critical,
      harness: harness,
    );

    await _tapVisible(
      tester,
      _clearPriorityFocusFinder(DashboardActionPriority.critical),
    );

    expect(harness.priorityChanges, [null]);
  });

  testWidgets('dashboard action summary panel composes priority and owner', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      selectedPriority: DashboardActionPriority.high,
      selectedOwner: hrisDashboardCriticalOwnerLabel,
      onOwnerChanged: (_) {},
      onPriorityChanged: (_) {},
    );

    _expectActionCards(critical: false, scaleMomentum: false);
    expect(find.text('Owner focus'), findsNothing);
  });

  testWidgets('dashboard action summary panel can focus actions by owner', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      selectedOwner: hrisDashboardCriticalOwnerLabel,
      statuses: hrisDashboardCriticalInProgressStatuses,
      onPriorityChanged: (_) {},
      harness: harness,
    );

    expect(find.text('Owner focus'), findsOneWidget);
    expect(find.text('All owners (3)'), findsOneWidget);
    expect(find.text('$hrisDashboardCriticalOwnerLabel (1)'), findsOneWidget);
    _expectActionCards(timeSensitive: false, scaleMomentum: false);

    await _tapVisible(tester, find.text('$dashboardActionAllOwners (3)'));

    expect(harness.ownerChanges, [dashboardActionAllOwners]);
  });

  testWidgets('dashboard action summary panel focuses owner from action chip', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(tester, harness: harness);

    await _tapVisible(
      tester,
      find.byTooltip('Focus $hrisDashboardTimeSensitiveOwnerLabel'),
    );

    expect(harness.ownerChanges, [hrisDashboardTimeSensitiveOwnerLabel]);
  });

  testWidgets(
    'dashboard action summary panel focuses priority from action pill',
    (tester) async {
      final harness = _SummaryPanelHarness();

      await _pumpSummaryPanel(tester, harness: harness);

      await _tapVisible(tester, find.byTooltip('Focus High priority'));

      expect(harness.priorityChanges, [DashboardActionPriority.high]);
    },
  );

  testWidgets(
    'dashboard action summary panel focuses urgency from action chip',
    (tester) async {
      final harness = _SummaryPanelHarness();

      await _pumpSummaryPanel(tester, harness: harness);

      await _tapVisible(tester, find.byTooltip('Focus Due soon urgency'));

      expect(harness.urgencyChanges, [DashboardActionUrgencyTier.soon]);
    },
  );

  testWidgets('dashboard action summary panel marks active action chips', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      selectedOwner: hrisDashboardTimeSensitiveOwnerLabel,
      selectedPriority: DashboardActionPriority.high,
      selectedUrgency: DashboardActionUrgencyTier.soon,
      onOwnerChanged: (_) {},
      onPriorityChanged: (_) {},
      onUrgencyChanged: (_) {},
    );

    _expectActionCards(critical: false, scaleMomentum: false);
    _expectActionFocusChipClears(
      ownerLabel: hrisDashboardTimeSensitiveOwnerLabel,
      priority: DashboardActionPriority.high,
      urgency: DashboardActionUrgencyTier.soon,
    );
  });

  testWidgets('dashboard action summary panel clears active action chips', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      selectedOwner: hrisDashboardTimeSensitiveOwnerLabel,
      selectedPriority: DashboardActionPriority.high,
      selectedUrgency: DashboardActionUrgencyTier.soon,
      harness: harness,
    );

    await _tapActionFocusChipClears(
      tester,
      ownerLabel: hrisDashboardTimeSensitiveOwnerLabel,
      priority: DashboardActionPriority.high,
      urgency: DashboardActionUrgencyTier.soon,
    );

    expect(harness.ownerChanges, [dashboardActionAllOwners]);
    expect(harness.priorityChanges, [null]);
    expect(harness.urgencyChanges, [null]);
  });

  testWidgets('dashboard action summary panel normalizes stale owner focus', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      selectedOwner: 'Former owner',
      onOwnerChanged: (_) {},
      onPriorityChanged: (_) {},
    );

    expect(find.text('All owners (3)'), findsOneWidget);
    _expectActionCards();
  });

  testWidgets('dashboard action summary panel can hide completed actions', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      hideCompleted: true,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
      onHideCompletedChanged: (_) {},
      onOwnerChanged: (_) {},
      onPriorityChanged: (_) {},
    );

    expect(find.text('Hide done'), findsOneWidget);
    _expectActionCards(timeSensitive: false);
    expect(find.text('All priorities (2)'), findsOneWidget);
    expect(find.text('High (1)'), findsNothing);
    expect(find.text('All owners (2)'), findsOneWidget);
    expect(
      find.text('$hrisDashboardTimeSensitiveOwnerLabel (1)'),
      findsNothing,
    );
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('dashboard action summary panel shows a hidden-complete state', (
    tester,
  ) async {
    final harness = _SummaryPanelHarness();

    await _pumpSummaryPanel(
      tester,
      summary: hrisDashboardCriticalActionSummary,
      hideCompleted: true,
      statuses: hrisDashboardCriticalDoneStatuses,
      harness: harness,
    );

    _expectActionCards(
      critical: false,
      timeSensitive: false,
      scaleMomentum: false,
    );
    expect(find.text('All recommended actions are done'), findsOneWidget);
    expect(find.text('Review completed'), findsOneWidget);

    await _tapVisible(tester, find.text('Review completed'));

    expect(harness.hideCompletedChanges, [false]);
  });

  testWidgets('dashboard action summary panel renders empty state', (
    tester,
  ) async {
    await _pumpSummaryPanel(
      tester,
      summary: const DashboardActionSummary(recommendations: []),
    );

    expect(find.text('No recommended actions right now'), findsOneWidget);
  });
}

Future<void> _pumpSummaryPanel(
  WidgetTester tester, {
  DashboardActionSummary? summary,
  Map<String, DashboardActionStatus> statuses = const {},
  bool hideCompleted = false,
  String selectedOwner = dashboardActionAllOwners,
  DashboardActionPriority? selectedPriority,
  DashboardActionUrgencyTier? selectedUrgency,
  _SummaryPanelHarness? harness,
  ValueChanged<bool>? onHideCompletedChanged,
  ValueChanged<String>? onOwnerChanged,
  ValueChanged<DashboardActionPriority?>? onPriorityChanged,
  ValueChanged<DashboardActionUrgencyTier?>? onUrgencyChanged,
  ValueChanged<DashboardActionRecommendation>? onStart,
  ValueChanged<DashboardActionRecommendation>? onComplete,
  ValueChanged<DashboardActionRecommendation>? onReopen,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: DashboardActionSummaryPanel(
              summary: summary ?? hrisDashboardActionSummary,
              statuses: statuses,
              hideCompleted: hideCompleted,
              selectedOwner: selectedOwner,
              selectedPriority: selectedPriority,
              selectedUrgency: selectedUrgency,
              onHideCompletedChanged:
                  onHideCompletedChanged ?? harness?.recordHideCompleted,
              onOwnerChanged: onOwnerChanged ?? harness?.recordOwner,
              onPriorityChanged: onPriorityChanged ?? harness?.recordPriority,
              onUrgencyChanged: onUrgencyChanged ?? harness?.recordUrgency,
              onStart: onStart ?? harness?.recordStart,
              onComplete: onComplete ?? harness?.recordComplete,
              onReopen: onReopen ?? harness?.recordReopen,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SummaryPanelHarness {
  final started = <String>[];
  final completed = <String>[];
  final reopened = <String>[];
  final hideCompletedChanges = <bool>[];
  final ownerChanges = <String>[];
  final priorityChanges = <DashboardActionPriority?>[];
  final urgencyChanges = <DashboardActionUrgencyTier?>[];

  void recordStart(DashboardActionRecommendation action) {
    started.add(action.id);
  }

  void recordComplete(DashboardActionRecommendation action) {
    completed.add(action.id);
  }

  void recordReopen(DashboardActionRecommendation action) {
    reopened.add(action.id);
  }

  void recordHideCompleted(bool value) {
    hideCompletedChanges.add(value);
  }

  void recordOwner(String ownerLabel) {
    ownerChanges.add(ownerLabel);
  }

  void recordPriority(DashboardActionPriority? priority) {
    priorityChanges.add(priority);
  }

  void recordUrgency(DashboardActionUrgencyTier? urgency) {
    urgencyChanges.add(urgency);
  }
}

Future<void> _pumpInteractiveSummaryPanel(
  WidgetTester tester, {
  Map<String, DashboardActionStatus> statuses = const {},
}) {
  return _pumpSummaryPanel(
    tester,
    statuses: statuses,
    onHideCompletedChanged: (_) {},
    onOwnerChanged: (_) {},
    onPriorityChanged: (_) {},
    onUrgencyChanged: (_) {},
  );
}

void _expectActionCards({
  bool critical = true,
  bool timeSensitive = true,
  bool scaleMomentum = true,
}) {
  _expectTextVisibility(hrisDashboardCriticalActionTitle, critical);
  _expectTextVisibility(hrisDashboardTimeSensitiveActionTitle, timeSensitive);
  _expectTextVisibility(hrisDashboardScaleMomentumActionTitle, scaleMomentum);
}

void _expectFocusSummary({
  required String resultLabel,
  bool hideCompleted = false,
  DashboardActionUrgencyTier? urgency,
  DashboardActionPriority? priority,
  String? ownerLabel,
}) {
  expect(find.text('Focus applied'), findsOneWidget);
  expect(find.text(resultLabel), findsOneWidget);
  _expectTextVisibility('Done hidden', hideCompleted);

  if (urgency != null) {
    expect(
      find.text('Urgency: ${dashboardActionUrgencyLabel(urgency)}'),
      findsOneWidget,
    );
  }

  if (priority != null) {
    expect(find.text('Priority: ${priority.label}'), findsOneWidget);
  }

  if (ownerLabel != null) {
    expect(find.text('Owner: $ownerLabel'), findsOneWidget);
  }
}

void _expectActionFocusChipClears({
  String? ownerLabel,
  DashboardActionPriority? priority,
  DashboardActionUrgencyTier? urgency,
}) {
  if (ownerLabel != null) {
    expect(_clearOwnerFocusFinder(ownerLabel), findsOneWidget);
  }

  if (priority != null) {
    expect(_clearPriorityFocusFinder(priority), findsOneWidget);
  }

  if (urgency != null) {
    expect(_clearUrgencyFocusFinder(urgency), findsOneWidget);
  }
}

void _expectTextVisibility(String text, bool visible) {
  expect(find.text(text), visible ? findsOneWidget : findsNothing);
}

void _expectActionOrder(WidgetTester tester, List<String> titles) {
  for (var index = 0; index < titles.length - 1; index += 1) {
    expect(
      tester.getTopLeft(find.text(titles[index])).dy,
      lessThan(tester.getTopLeft(find.text(titles[index + 1])).dy),
    );
  }
}

Finder _clearOwnerFocusFinder(String ownerLabel) {
  return find.byTooltip('Clear $ownerLabel owner focus');
}

Finder _clearPriorityFocusFinder(DashboardActionPriority priority) {
  return find.byTooltip('Clear ${priority.label} priority focus');
}

Finder _clearUrgencyFocusFinder(DashboardActionUrgencyTier urgency) {
  return find.byTooltip(
    'Clear ${dashboardActionUrgencyLabel(urgency)} urgency focus',
  );
}

Future<void> _tapActionFocusChipClears(
  WidgetTester tester, {
  String? ownerLabel,
  DashboardActionPriority? priority,
  DashboardActionUrgencyTier? urgency,
}) async {
  if (ownerLabel != null) {
    await _tapVisible(tester, _clearOwnerFocusFinder(ownerLabel));
  }

  if (priority != null) {
    await _tapAndPump(tester, _clearPriorityFocusFinder(priority));
  }

  if (urgency != null) {
    await _tapAndPump(tester, _clearUrgencyFocusFinder(urgency));
  }
}

Future<void> _tapVisible(
  WidgetTester tester,
  Finder finder, {
  bool settleAfter = false,
}) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  if (settleAfter) {
    await tester.pumpAndSettle();
    return;
  }

  await tester.pump();
}

Future<void> _tapAndPump(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
}
