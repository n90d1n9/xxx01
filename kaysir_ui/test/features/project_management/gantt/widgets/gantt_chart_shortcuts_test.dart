import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_shortcuts.dart';

void main() {
  testWidgets('gantt chart shortcuts invoke chart actions', (tester) async {
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
        home: GanttChartShortcuts(
          onDismissPressed: () => dismissCount++,
          onSearchPressed: () => searchCount++,
          onToggleControlsPressed: () => toggleControlsCount++,
          onOpenSettingsPressed: () => settingsCount++,
          onClearFiltersPressed: () => clearFiltersCount++,
          onUndoPressed: () => undoCount++,
          onPreviousTaskPressed: () => previousTaskCount++,
          onNextTaskPressed: () => nextTaskCount++,
          child: const SizedBox.expand(),
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
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.keyF,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.backslash,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.backslash,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.comma,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.comma,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyZ,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.keyZ,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.arrowLeft,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.arrowLeft,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.arrowRight,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.arrowRight,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyL,
      shift: true,
    );
    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.metaLeft,
      trigger: LogicalKeyboardKey.keyL,
      shift: true,
    );

    expect(dismissCount, 1);
    expect(searchCount, 2);
    expect(toggleControlsCount, 2);
    expect(settingsCount, 2);
    expect(clearFiltersCount, 2);
    expect(undoCount, 2);
    expect(previousTaskCount, 2);
    expect(nextTaskCount, 2);
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
