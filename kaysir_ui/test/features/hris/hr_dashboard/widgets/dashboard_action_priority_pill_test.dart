import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_priority_pill.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_style.dart';

void main() {
  testWidgets('dashboard action priority pill focuses an unselected priority', (
    tester,
  ) async {
    final selectedPriorities = <DashboardActionPriority>[];

    await _pumpPriorityPill(
      tester,
      priority: DashboardActionPriority.high,
      onSelected: selectedPriorities.add,
    );

    await tester.tap(find.byTooltip('Focus High priority'));
    await tester.pump();

    expect(selectedPriorities, [DashboardActionPriority.high]);
  });

  testWidgets('dashboard action priority pill clears a selected priority', (
    tester,
  ) async {
    var clearCount = 0;

    await _pumpPriorityPill(
      tester,
      priority: DashboardActionPriority.critical,
      selected: true,
      onClearSelected: () => clearCount++,
    );

    await tester.tap(find.byTooltip('Clear Critical priority focus'));
    await tester.pump();

    expect(clearCount, 1);
  });

  testWidgets(
    'dashboard action priority pill keeps active focus inert without clear',
    (tester) async {
      final selectedPriorities = <DashboardActionPriority>[];

      await _pumpPriorityPill(
        tester,
        priority: DashboardActionPriority.medium,
        selected: true,
        onSelected: selectedPriorities.add,
      );

      expect(find.byTooltip('Medium priority focus active'), findsOneWidget);

      await tester.tap(find.byTooltip('Medium priority focus active'));
      await tester.pump();

      expect(selectedPriorities, isEmpty);
    },
  );

  testWidgets('dashboard action priority pill can render read-only', (
    tester,
  ) async {
    await _pumpPriorityPill(tester, priority: DashboardActionPriority.low);

    expect(find.text('Low'), findsOneWidget);
    expect(find.byTooltip('Focus Low priority'), findsNothing);
  });
}

Future<void> _pumpPriorityPill(
  WidgetTester tester, {
  required DashboardActionPriority priority,
  bool selected = false,
  ValueChanged<DashboardActionPriority>? onSelected,
  VoidCallback? onClearSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: DashboardActionPriorityPill(
            priority: priority,
            color: dashboardActionPriorityColor(priority),
            selected: selected,
            onSelected: onSelected,
            onClearSelected: onClearSelected,
          ),
        ),
      ),
    ),
  );
}
