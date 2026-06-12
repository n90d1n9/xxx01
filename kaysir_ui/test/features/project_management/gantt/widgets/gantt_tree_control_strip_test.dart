import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_tree_control_strip.dart';

void main() {
  testWidgets('gantt tree control strip renders mixed collapse state', (
    tester,
  ) async {
    var collapseTapped = false;
    var expandTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTreeControlStrip(
            branchCount: 4,
            collapsedCount: 2,
            onCollapseAll: () => collapseTapped = true,
            onExpandAll: () => expandTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Task tree'), findsOneWidget);
    expect(find.text('2 of 4 collapsed'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.byTooltip('Collapse all visible branches'), findsOneWidget);
    expect(find.byTooltip('Expand all visible branches'), findsOneWidget);

    await tester.tap(find.byKey(GanttTreeControlStrip.collapseAllButtonKey));
    await tester.tap(find.byKey(GanttTreeControlStrip.expandAllButtonKey));

    expect(collapseTapped, isTrue);
    expect(expandTapped, isTrue);
  });

  testWidgets('gantt tree control strip disables redundant tree actions', (
    tester,
  ) async {
    var collapseTapCount = 0;
    var expandTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTreeControlStrip(
            branchCount: 3,
            collapsedCount: 0,
            onCollapseAll: () => collapseTapCount += 1,
            onExpandAll: () => expandTapCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.byTooltip('All visible branches are already expanded'),
      findsOneWidget,
    );
    expect(
      _outlinedButtonFor(GanttTreeControlStrip.collapseAllButtonKey).onPressed,
      isNotNull,
    );
    expect(
      _outlinedButtonFor(GanttTreeControlStrip.expandAllButtonKey).onPressed,
      isNull,
    );

    await tester.tap(find.byKey(GanttTreeControlStrip.expandAllButtonKey));
    await tester.pump();

    expect(collapseTapCount, isZero);
    expect(expandTapCount, isZero);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttTreeControlStrip(
            branchCount: 3,
            collapsedCount: 3,
            onCollapseAll: () => collapseTapCount += 1,
            onExpandAll: () => expandTapCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.byTooltip('All visible branches are already collapsed'),
      findsOneWidget,
    );
    expect(
      _outlinedButtonFor(GanttTreeControlStrip.collapseAllButtonKey).onPressed,
      isNull,
    );
    expect(
      _outlinedButtonFor(GanttTreeControlStrip.expandAllButtonKey).onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(GanttTreeControlStrip.collapseAllButtonKey));
    await tester.pump();

    expect(collapseTapCount, isZero);
    expect(expandTapCount, isZero);
  });

  testWidgets('gantt tree control strip hides when no branches are visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GanttTreeControlStrip(
            branchCount: 0,
            collapsedCount: 0,
            onCollapseAll: null,
            onExpandAll: null,
          ),
        ),
      ),
    );

    expect(find.text('Task tree'), findsNothing);
    expect(
      find.byKey(GanttTreeControlStrip.collapseAllButtonKey),
      findsNothing,
    );
  });
}

OutlinedButton _outlinedButtonFor(Key key) {
  return find
          .descendant(
            of: find.byKey(key),
            matching: find.byType(OutlinedButton),
          )
          .evaluate()
          .single
          .widget
      as OutlinedButton;
}
