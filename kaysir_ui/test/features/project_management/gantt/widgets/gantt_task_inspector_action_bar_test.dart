import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_action_bar.dart';

void main() {
  testWidgets('gantt task inspector action bar triggers visible actions', (
    tester,
  ) async {
    var undoCount = 0;
    var openCount = 0;
    var clearCount = 0;

    await tester.pumpWidget(
      _actionBarHarness(
        GanttTaskInspectorActionBar(
          projectName: 'Warehouse Automation',
          onUndoLastEdit: () => undoCount++,
          onOpenProject: () => openCount++,
          onClearSelection: () => clearCount++,
        ),
      ),
    );

    expect(find.text('Undo Last Edit'), findsOneWidget);
    expect(find.text('Open Project'), findsOneWidget);
    expect(find.text('Clear Selection'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttTaskInspectorActionBar.undoLastEditButtonKey),
    );
    await tester.tap(
      find.byKey(GanttTaskInspectorActionBar.openProjectButtonKey),
    );
    await tester.tap(
      find.byKey(GanttTaskInspectorActionBar.clearSelectionButtonKey),
    );

    expect(undoCount, 1);
    expect(openCount, 1);
    expect(clearCount, 1);
  });

  testWidgets('gantt task inspector action bar hides unavailable actions', (
    tester,
  ) async {
    var clearCount = 0;

    await tester.pumpWidget(
      _actionBarHarness(
        GanttTaskInspectorActionBar(onClearSelection: () => clearCount++),
      ),
    );

    expect(find.text('Undo Last Edit'), findsNothing);
    expect(find.text('Open Project'), findsNothing);
    expect(find.text('Clear Selection'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttTaskInspectorActionBar.clearSelectionButtonKey),
    );

    expect(clearCount, 1);
  });
}

Widget _actionBarHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}
