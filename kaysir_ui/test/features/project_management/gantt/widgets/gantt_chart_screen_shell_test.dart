import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_screen_actions.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_screen_shell.dart';

void main() {
  testWidgets('gantt chart screen shell stacks workspace and floating layers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GanttChartScreenShell(
          workspace: const SizedBox(
            key: ValueKey('gantt-workspace'),
            child: Text('Workspace'),
          ),
          foregroundLayers: const [
            Positioned(
              key: ValueKey('hidden-layer'),
              left: 0,
              bottom: 0,
              child: SizedBox(width: 24, height: 24),
            ),
            Positioned.fill(
              key: ValueKey('inspector-layer'),
              child: IgnorePointer(child: SizedBox.expand()),
            ),
          ],
          actions: GanttChartScreenActions.disabled,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('gantt-workspace')), findsOneWidget);
    expect(find.byKey(const ValueKey('hidden-layer')), findsOneWidget);
    expect(find.byKey(const ValueKey('inspector-layer')), findsOneWidget);
  });

  testWidgets('gantt chart screen shell forwards keyboard shortcuts', (
    tester,
  ) async {
    var dismissCount = 0;
    var searchCount = 0;
    var toggleControlsCount = 0;
    var settingsCount = 0;
    var clearFiltersCount = 0;
    var undoCount = 0;
    var previousTaskCount = 0;
    var nextTaskCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: GanttChartScreenShell(
          workspace: const SizedBox.expand(),
          actions: GanttChartScreenActions(
            onDismiss: () => dismissCount++,
            onSearch: () => searchCount++,
            onToggleControls: () => toggleControlsCount++,
            onOpenSettings: () => settingsCount++,
            onClearFilters: () => clearFiltersCount++,
            onUndo: () => undoCount++,
            onPreviousTask: () => previousTaskCount++,
            onNextTask: () => nextTaskCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyF,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.backslash,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.comma,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyZ,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.arrowLeft,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.arrowRight,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyL,
      shift: true,
    );

    expect(dismissCount, 1);
    expect(searchCount, 1);
    expect(toggleControlsCount, 1);
    expect(settingsCount, 1);
    expect(clearFiltersCount, 1);
    expect(undoCount, 1);
    expect(previousTaskCount, 1);
    expect(nextTaskCount, 1);
  });
}

Future<void> _pressShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey modifier,
  required LogicalKeyboardKey trigger,
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(modifier);
  if (shift) {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyEvent(trigger);
  if (shift) {
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyUpEvent(modifier);
}
