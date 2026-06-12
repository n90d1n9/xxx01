import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_rule_controls.dart';

void main() {
  testWidgets('nudge controls invoke only enabled directions', (tester) async {
    var leftCount = 0;
    var rightCount = 0;
    var upCount = 0;
    var downCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutRuleNudgeControls(
            columnUnitLabel: 'grid column',
            rowUnitLabel: 'grid row',
            canMoveLeft: true,
            canMoveRight: false,
            canMoveUp: false,
            canMoveDown: true,
            onMoveLeft: () => leftCount++,
            onMoveRight: () => rightCount++,
            onMoveUp: () => upCount++,
            onMoveDown: () => downCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Move left one grid column'));
    await tester.tap(find.byTooltip('Move down one grid row'));
    await tester.pump();

    expect(leftCount, 1);
    expect(downCount, 1);
    expect(rightCount, 0);
    expect(upCount, 0);

    final rightButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byTooltip('Move right one grid column'),
        matching: find.byType(IconButton),
      ),
    );
    final upButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byTooltip('Move up one grid row'),
        matching: find.byType(IconButton),
      ),
    );

    expect(rightButton.onPressed, isNull);
    expect(upButton.onPressed, isNull);
  });

  testWidgets('cleanup actions show status and disable unavailable groups', (
    tester,
  ) async {
    var snapSelectionCount = 0;
    var sizeSelectionCount = 0;
    var snapVisibleCount = 0;
    var sizeVisibleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutRuleCleanupActions(
            canSnapSelection: true,
            canSnapVisible: false,
            selectedStatus: const LayoutRuleSnapStatus(
              positionCount: 2,
              sizeCount: 1,
            ),
            visibleStatus: const LayoutRuleSnapStatus(
              positionCount: 0,
              sizeCount: 0,
            ),
            onSnapSelection: () => snapSelectionCount++,
            onSnapSelectionSize: () => sizeSelectionCount++,
            onSnapVisible: () => snapVisibleCount++,
            onSnapVisibleSize: () => sizeVisibleCount++,
          ),
        ),
      ),
    );

    expect(find.text('Sel 2 pos'), findsOneWidget);
    expect(find.text('Sel 1 size'), findsOneWidget);
    expect(find.text('All aligned'), findsOneWidget);

    await tester.tap(find.text('Snap sel'));
    await tester.tap(find.text('Size sel'));
    await tester.pump();

    expect(snapSelectionCount, 1);
    expect(sizeSelectionCount, 1);
    expect(snapVisibleCount, 0);
    expect(sizeVisibleCount, 0);

    final snapAllButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Snap all'),
    );
    final sizeAllButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Size all'),
    );

    expect(snapAllButton.onPressed, isNull);
    expect(sizeAllButton.onPressed, isNull);
  });

  test('snap status reports aligned when both counts are zero', () {
    const aligned = LayoutRuleSnapStatus(positionCount: 0, sizeCount: 0);
    const dirty = LayoutRuleSnapStatus(positionCount: 1, sizeCount: 0);

    expect(aligned.isAligned, isTrue);
    expect(dirty.isAligned, isFalse);
  });
}
