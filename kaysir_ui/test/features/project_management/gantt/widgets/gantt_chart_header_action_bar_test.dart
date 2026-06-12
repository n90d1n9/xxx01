import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_header_action_bar.dart';

void main() {
  testWidgets('gantt chart header action bar renders full labels', (
    tester,
  ) async {
    var toggleCount = 0;
    var undoCount = 0;
    var settingsCount = 0;
    var dashboardCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartHeaderActionBar(
            controlsExpanded: true,
            canUndoLastEdit: true,
            onToggleControls: () => toggleCount++,
            onUndoLastEdit: () => undoCount++,
            onOpenViewSettings: () => settingsCount++,
            onOpenDashboard: () => dashboardCount++,
          ),
        ),
      ),
    );

    expect(find.text('Hide Controls'), findsOneWidget);
    expect(find.text('Undo Edit'), findsOneWidget);
    expect(find.text('View Settings'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartHeaderActionBar.toggleControlsButtonKey),
    );
    await tester.tap(find.byKey(GanttChartHeaderActionBar.undoEditButtonKey));
    await tester.tap(
      find.byKey(GanttChartHeaderActionBar.viewSettingsButtonKey),
    );
    await tester.tap(find.byKey(GanttChartHeaderActionBar.dashboardButtonKey));

    expect(toggleCount, 1);
    expect(undoCount, 1);
    expect(settingsCount, 1);
    expect(dashboardCount, 1);
  });

  testWidgets('gantt chart header action bar compacts to icon buttons', (
    tester,
  ) async {
    var undoCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartHeaderActionBar(
            compact: true,
            controlsExpanded: false,
            canUndoLastEdit: false,
            onToggleControls: () {},
            onUndoLastEdit: () => undoCount++,
            onOpenViewSettings: () {},
            onOpenDashboard: () {},
          ),
        ),
      ),
    );

    expect(find.text('Show Controls'), findsNothing);
    expect(find.byTooltip('Show Controls'), findsOneWidget);
    expect(find.byTooltip('Undo Edit'), findsOneWidget);

    await tester.tap(find.byKey(GanttChartHeaderActionBar.undoEditButtonKey));

    expect(undoCount, 0);
  });
}
