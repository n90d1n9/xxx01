import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/layout_health_summary.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_health_summary_panel.dart';

void main() {
  testWidgets('shows health quick actions and selected states', (tester) async {
    var didSnap = false;
    var didConvert = false;
    var didReposition = false;
    var didSelectOffCanvas = false;
    var didSelectOverflow = false;
    var didSelectLeftTop = false;
    var didSelectPosition = false;
    var didSelectSize = false;
    var didSelectConflicts = false;
    Size? selectedCanvasSize;

    Future<void> tapVisible(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.pump();
      await tester.tap(find.text(label));
      await tester.pump();
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LayoutHealthSummaryPanel(
              summary: const LayoutHealthSummary(
                visibleComponentCount: 5,
                editableComponentCount: 4,
                lockedComponentCount: 1,
                hiddenComponentCount: 2,
                offCanvasCount: 2,
                expandableOffCanvasCount: 1,
                repositionOffCanvasCount: 1,
                repositionableOffCanvasCount: 1,
                offRulePositionCount: 3,
                offRuleSizeCount: 2,
                autoGridConflictCount: 1,
                offCanvasComponentIds: ['left-top', 'right-bottom'],
                expandableOffCanvasComponentIds: ['right-bottom'],
                repositionOffCanvasComponentIds: ['left-top'],
                offRulePositionComponentIds: ['left-top', 'right-bottom'],
                offRuleSizeComponentIds: ['left-top'],
                autoGridConflictComponentIds: ['right-bottom'],
                expandedCanvasSize: Size(1280, 820),
                repositionOffset: Offset(24, 12),
              ),
              snapSelected: true,
              onUseSnap: () => didSnap = true,
              onUseConvert: () => didConvert = true,
              onCanvasSizeSelected: (size) => selectedCanvasSize = size,
              onRepositionInsideCanvas: () => didReposition = true,
              onSelectOffCanvas: () => didSelectOffCanvas = true,
              onSelectExpandableOffCanvas: () => didSelectOverflow = true,
              onSelectRepositionOffCanvas: () => didSelectLeftTop = true,
              onSelectOffRulePositions: () => didSelectPosition = true,
              onSelectOffRuleSizes: () => didSelectSize = true,
              onSelectAutoGridConflicts: () => didSelectConflicts = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Layout health'), findsOneWidget);
    expect(find.text('8 issues detected'), findsOneWidget);
    expect(find.text('1 right/bottom overflow'), findsOneWidget);
    expect(find.text('1 left/top outside'), findsOneWidget);
    expect(find.text('Snap selected'), findsOneWidget);
    expect(find.text('Use Convert'), findsOneWidget);
    expect(find.text('Select Position'), findsOneWidget);
    expect(find.text('Select Size'), findsOneWidget);
    expect(find.text('Select Conflicts'), findsOneWidget);
    expect(find.text('Select Left/Top'), findsOneWidget);
    expect(find.text('Select Overflow'), findsOneWidget);
    expect(find.text('Select Off Canvas'), findsOneWidget);
    expect(find.text('Reposition +24px, +12px'), findsOneWidget);
    expect(find.text('Expand Canvas to 1280 x 820'), findsOneWidget);
    expect(
      find.text(
        'Quick fixes affect 4 editable components. Skips 1 locked component and 2 hidden components.',
      ),
      findsOneWidget,
    );

    await tapVisible('Snap selected');

    expect(didSnap, isFalse);

    await tapVisible('Use Convert');
    await tapVisible('Select Position');
    await tapVisible('Select Size');
    await tapVisible('Select Conflicts');
    await tapVisible('Select Left/Top');
    await tapVisible('Select Overflow');
    await tapVisible('Select Off Canvas');
    await tapVisible('Reposition +24px, +12px');
    await tapVisible('Expand Canvas to 1280 x 820');

    expect(didConvert, isTrue);
    expect(didSelectPosition, isTrue);
    expect(didSelectSize, isTrue);
    expect(didSelectConflicts, isTrue);
    expect(didSelectLeftTop, isTrue);
    expect(didSelectOverflow, isTrue);
    expect(didSelectOffCanvas, isTrue);
    expect(didReposition, isTrue);
    expect(selectedCanvasSize, const Size(1280, 820));
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides reposition action when outside components are locked', (
    tester,
  ) async {
    var didSelectOffCanvas = false;
    var didSelectLeftTop = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LayoutHealthSummaryPanel(
            summary: const LayoutHealthSummary(
              visibleComponentCount: 2,
              editableComponentCount: 1,
              lockedComponentCount: 1,
              hiddenComponentCount: 0,
              offCanvasCount: 1,
              repositionOffCanvasCount: 1,
              repositionableOffCanvasCount: 0,
              offRulePositionCount: 0,
              offRuleSizeCount: 0,
              autoGridConflictCount: 0,
              offCanvasComponentIds: ['locked'],
              repositionOffCanvasComponentIds: ['locked'],
            ),
            onRepositionInsideCanvas: () {},
            onSelectOffCanvas: () => didSelectOffCanvas = true,
            onSelectRepositionOffCanvas: () => didSelectLeftTop = true,
          ),
        ),
      ),
    );

    expect(find.text('1 left/top outside'), findsOneWidget);
    expect(find.textContaining('Reposition'), findsNothing);
    expect(find.text('Select Left/Top'), findsOneWidget);
    expect(find.text('Select Overflow'), findsNothing);
    expect(find.text('Select Off Canvas'), findsOneWidget);
    expect(
      find.text(
        'Quick fixes affect 1 editable component. Skips 1 locked component. 1 locked left/top outside component needs unlocking.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Select Left/Top'));
    await tester.pump();
    await tester.tap(find.text('Select Off Canvas'));
    await tester.pump();

    expect(didSelectLeftTop, isTrue);
    expect(didSelectOffCanvas, isTrue);
    expect(tester.takeException(), isNull);
  });
}
