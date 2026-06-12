import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_drag_preview.dart';
import 'package:kaysir/features/layout_builder/widgets/layout_drag_preview_overlay.dart';

void main() {
  testWidgets('LayoutDragPreviewOverlay renders rule labels and conflicts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'card',
                    currentBounds: const Rect.fromLTWH(13, 27, 80, 48),
                    ruleBounds: const Rect.fromLTWH(20, 20, 80, 48),
                    ruleLabel: 'Grid c2 r2',
                    hasConflict: false,
                  ),
                  LayoutDragPreviewItem(
                    componentId: 'button',
                    currentBounds: const Rect.fromLTWH(118, 80, 90, 44),
                    ruleBounds: const Rect.fromLTWH(120, 80, 90, 44),
                    ruleLabel: 'Grid c7 r5',
                    hasConflict: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid c2 r2'), findsOneWidget);
    expect(find.text('Grid c7 r5'), findsOneWidget);
    expect(find.text('overlap'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('layout-drag-preview-conflict-meter-button')),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip && widget.message == 'Grid c7 r5 - overlap',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay stays empty without items', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LayoutDragPreviewOverlay(preview: null)),
      ),
    );

    expect(find.byType(LayoutDragPreviewOverlay), findsOneWidget);
    expect(find.textContaining('Grid'), findsNothing);
  });

  testWidgets('LayoutDragPreviewOverlay renders counted conflict labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'crowded-card',
                    currentBounds: const Rect.fromLTWH(40, 44, 96, 48),
                    ruleBounds: const Rect.fromLTWH(40, 40, 96, 48),
                    ruleLabel: 'Grid c3 r3',
                    hasConflict: true,
                    conflictCount: 2,
                    conflictCoverage: 0.625,
                    conflictSourceSummary: 'Action Button, Text Label',
                    conflictBlockers: [
                      LayoutConflictBlocker(
                        bounds: const Rect.fromLTWH(20, 40, 50, 48),
                        label: 'Action Button',
                      ),
                      LayoutConflictBlocker(
                        bounds: const Rect.fromLTWH(70, 40, 40, 48),
                        label: 'Text Label',
                      ),
                    ],
                    conflictPatches: [
                      LayoutConflictPatch(
                        bounds: const Rect.fromLTWH(40, 40, 30, 48),
                        label: 'Action Button',
                      ),
                      LayoutConflictPatch(
                        bounds: const Rect.fromLTWH(70, 40, 40, 48),
                        label: 'Text Label',
                      ),
                    ],
                    conflictResolvedBounds: const Rect.fromLTWH(
                      152,
                      40,
                      96,
                      48,
                    ),
                    conflictResolvedRuleLabel: 'Grid c9 r3',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid c3 r3'), findsOneWidget);
    expect(find.text('2 overlaps'), findsOneWidget);
    expect(find.text('63% blocked'), findsOneWidget);
    expect(find.text('clear right 112px'), findsOneWidget);
    expect(find.text('to Grid c9 r3'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('layout-drag-preview-conflict-meter-crowded-card'),
      ),
      findsOneWidget,
    );
    final firstBlocker = find.byKey(
      const ValueKey('layout-drag-preview-blocker-crowded-card-0'),
    );
    final secondBlocker = find.byKey(
      const ValueKey('layout-drag-preview-blocker-crowded-card-1'),
    );
    expect(firstBlocker, findsOneWidget);
    expect(secondBlocker, findsOneWidget);
    expect(tester.getTopLeft(firstBlocker), const Offset(20, 40));
    expect(tester.getSize(firstBlocker), const Size(50, 48));
    expect(tester.getTopLeft(secondBlocker), const Offset(70, 40));
    expect(tester.getSize(secondBlocker), const Size(40, 48));
    final firstPatch = find.byKey(
      const ValueKey('layout-drag-preview-conflict-patch-crowded-card-0'),
    );
    final secondPatch = find.byKey(
      const ValueKey('layout-drag-preview-conflict-patch-crowded-card-1'),
    );
    expect(firstPatch, findsOneWidget);
    expect(secondPatch, findsOneWidget);
    expect(tester.getTopLeft(firstPatch), const Offset(40, 40));
    expect(tester.getSize(firstPatch), const Size(30, 48));
    expect(tester.getTopLeft(secondPatch), const Offset(70, 40));
    expect(tester.getSize(secondPatch), const Size(40, 48));
    final clearGuide = find.byKey(
      const ValueKey('layout-drag-preview-conflict-resolution-crowded-card'),
    );
    final clearGuideConnector = find.byKey(
      const ValueKey(
        'layout-drag-preview-conflict-resolution-connector-crowded-card',
      ),
    );
    expect(clearGuide, findsOneWidget);
    expect(clearGuideConnector, findsOneWidget);
    expect(tester.getTopLeft(clearGuide), const Offset(152, 40));
    expect(tester.getSize(clearGuide), const Size(96, 48));
    expect(find.text('overlap'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message ==
                'Grid c3 r3 - 2 overlaps, 63% blocked, clear right 112px, to Grid c9 r3, blocked by Action Button, Text Label',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay labels nearby searched clear spots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 200,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'nearby-card',
                    currentBounds: const Rect.fromLTWH(20, 20, 64, 40),
                    ruleBounds: const Rect.fromLTWH(20, 20, 64, 40),
                    ruleLabel: 'Grid c2 r2',
                    hasConflict: true,
                    conflictCount: 1,
                    conflictCoverage: 0.5,
                    conflictSourceSummary: 'Action Button',
                    conflictBlockers: [
                      LayoutConflictBlocker(
                        bounds: const Rect.fromLTWH(20, 20, 64, 40),
                        label: 'Action Button',
                      ),
                    ],
                    conflictPatches: [
                      LayoutConflictPatch(
                        bounds: const Rect.fromLTWH(20, 20, 64, 40),
                        label: 'Action Button',
                      ),
                    ],
                    conflictResolvedBounds: const Rect.fromLTWH(60, 60, 64, 40),
                    conflictResolutionSource:
                        LayoutConflictResolutionSource.nearbySearch,
                    conflictResolvedRuleLabel: 'Grid c4 r4',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('nearby clear right 40px/down 40px'), findsOneWidget);
    expect(find.text('to Grid c4 r4'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('layout-drag-preview-conflict-resolution-nearby-card'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message ==
                'Grid c2 r2 - overlap, 50% blocked, nearby clear right 40px/down 40px, to Grid c4 r4, blocked by Action Button',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay labels unresolved conflicts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 180,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'blocked-card',
                    currentBounds: const Rect.fromLTWH(24, 24, 80, 44),
                    ruleBounds: const Rect.fromLTWH(20, 20, 80, 44),
                    ruleLabel: 'Grid c2 r2',
                    hasConflict: true,
                    conflictCount: 1,
                    conflictSourceSummary: 'Action Button',
                    conflictBlockers: [
                      LayoutConflictBlocker(
                        bounds: const Rect.fromLTWH(20, 20, 80, 44),
                        label: 'Action Button',
                      ),
                    ],
                    conflictPatches: [
                      LayoutConflictPatch(
                        bounds: const Rect.fromLTWH(20, 20, 80, 44),
                        label: 'Action Button',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid c2 r2'), findsOneWidget);
    expect(find.text('overlap'), findsOneWidget);
    expect(find.text('no nearby clear spot'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('layout-drag-preview-conflict-resolution-blocked-card'),
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message ==
                'Grid c2 r2 - overlap, no nearby clear spot, blocked by Action Button',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay labels snap-off previews as guides', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                willApplyRulesOnDrop: false,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'card',
                    currentBounds: const Rect.fromLTWH(13, 27, 80, 48),
                    ruleBounds: const Rect.fromLTWH(20, 20, 80, 48),
                    ruleLabel: 'Grid c2 r2',
                    hasConflict: false,
                  ),
                  LayoutDragPreviewItem(
                    componentId: 'button',
                    currentBounds: const Rect.fromLTWH(118, 80, 90, 44),
                    ruleBounds: const Rect.fromLTWH(120, 80, 90, 44),
                    ruleLabel: 'Grid c7 r5',
                    hasConflict: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Guide'), findsNWidgets(2));
    expect(find.text('Grid c2 r2'), findsOneWidget);
    expect(find.text('Grid c7 r5'), findsOneWidget);
    expect(find.text('guide overlap'), findsOneWidget);
    expect(find.text('Grid c7 r5 - overlap'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message == 'Guide: Grid c7 r5 - guide overlap',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay renders outside canvas warnings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'card',
                    currentBounds: const Rect.fromLTWH(244, 188, 90, 44),
                    ruleBounds: const Rect.fromLTWH(240, 180, 90, 44),
                    ruleLabel: 'Grid c13 r10',
                    hasConflict: true,
                    isOutsideCanvas: true,
                    outsideCanvasEdges: [
                      LayoutCanvasEdge.right,
                      LayoutCanvasEdge.bottom,
                    ],
                    canvasOverflow: [
                      LayoutCanvasOverflow(
                        edge: LayoutCanvasEdge.right,
                        distance: 10,
                      ),
                      LayoutCanvasOverflow(
                        edge: LayoutCanvasEdge.bottom,
                        distance: 4,
                      ),
                    ],
                    canvasCorrectionOffset: const Offset(-10, -4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid c13 r10'), findsOneWidget);
    expect(find.text('overlap'), findsOneWidget);
    expect(find.text('outside right 10px/bottom 4px'), findsOneWidget);
    expect(find.text('shift left 10px/up 4px'), findsOneWidget);
    final correctionGuide = find.byKey(
      const ValueKey('layout-drag-preview-correction-card'),
    );
    expect(correctionGuide, findsOneWidget);
    expect(tester.getTopLeft(correctionGuide), const Offset(230, 176));
    expect(tester.getSize(correctionGuide), const Size(90, 44));
    expect(
      find.byKey(
        const ValueKey('layout-drag-preview-correction-connector-card'),
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip &&
            widget.message ==
                'Grid c13 r10 - overlap, outside right 10px/bottom 4px, shift left 10px/up 4px',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay connects separated correction guides', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: LayoutDragPreviewOverlay(
              preview: LayoutDragPreview(
                mechanism: LayoutMechanism.grid,
                items: [
                  LayoutDragPreviewItem(
                    componentId: 'offscreen-card',
                    currentBounds: const Rect.fromLTWH(340, 96, 80, 44),
                    ruleBounds: const Rect.fromLTWH(340, 96, 80, 44),
                    ruleLabel: 'Grid c18 r5',
                    hasConflict: false,
                    isOutsideCanvas: true,
                    outsideCanvasEdges: const [LayoutCanvasEdge.right],
                    canvasOverflow: [
                      LayoutCanvasOverflow(
                        edge: LayoutCanvasEdge.right,
                        distance: 100,
                      ),
                    ],
                    canvasCorrectionOffset: const Offset(-100, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final correctionGuide = find.byKey(
      const ValueKey('layout-drag-preview-correction-offscreen-card'),
    );
    final correctionConnector = find.byKey(
      const ValueKey('layout-drag-preview-correction-connector-offscreen-card'),
    );

    expect(correctionGuide, findsOneWidget);
    expect(correctionConnector, findsOneWidget);
    expect(tester.getTopLeft(correctionGuide), const Offset(240, 96));
    expect(tester.getSize(correctionGuide), const Size(80, 44));
  });

  testWidgets(
    'LayoutDragPreviewOverlay renders resize-to-fit correction guides',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 100,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'oversized-card',
                      currentBounds: const Rect.fromLTWH(-20, -12, 220, 130),
                      ruleBounds: const Rect.fromLTWH(-20, -12, 220, 130),
                      ruleLabel: 'Grid c1 r1',
                      hasConflict: false,
                      isOutsideCanvas: true,
                      outsideCanvasEdges: [
                        LayoutCanvasEdge.left,
                        LayoutCanvasEdge.top,
                        LayoutCanvasEdge.right,
                        LayoutCanvasEdge.bottom,
                      ],
                      canvasCorrectedBounds: const Rect.fromLTWH(
                        0,
                        0,
                        180,
                        100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Grid c1 r1'), findsOneWidget);
      expect(find.text('outside left/top/right/bottom'), findsOneWidget);
      expect(find.text('resize to fit'), findsOneWidget);

      final correctionGuide = find.byKey(
        const ValueKey('layout-drag-preview-correction-oversized-card'),
      );
      expect(correctionGuide, findsOneWidget);
      expect(tester.getTopLeft(correctionGuide), Offset.zero);
      expect(tester.getSize(correctionGuide), const Size(180, 100));
    },
  );

  testWidgets('LayoutDragPreviewOverlay places top-edge badges below targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 240,
              height: 160,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'top-card',
                      currentBounds: const Rect.fromLTWH(16, 4, 80, 40),
                      ruleBounds: const Rect.fromLTWH(16, 4, 80, 40),
                      ruleLabel: 'Grid c1 r1',
                      hasConflict: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final labelTop = tester.getTopLeft(find.text('Grid c1 r1')).dy;

    expect(labelTop, greaterThan(44));
    expect(
      find.byKey(const ValueKey('layout-drag-preview-connector-top-card')),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay skips connectors for natural badges', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 260,
              height: 220,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'middle-card',
                      currentBounds: const Rect.fromLTWH(48, 120, 96, 44),
                      ruleBounds: const Rect.fromLTWH(48, 120, 96, 44),
                      ruleLabel: 'Grid c3 r6',
                      hasConflict: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grid c3 r6'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('layout-drag-preview-connector-middle-card')),
      findsNothing,
    );
  });

  testWidgets('LayoutDragPreviewOverlay shifts right-edge badges into canvas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180,
              height: 160,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'right-card',
                      currentBounds: const Rect.fromLTWH(144, 80, 30, 40),
                      ruleBounds: const Rect.fromLTWH(144, 80, 30, 40),
                      ruleLabel: 'Grid c12 r3',
                      hasConflict: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(LayoutDragPreviewOverlay)),
      const Size(180, 160),
    );

    final labelFinder = find.text('Grid c12 r3');
    final labelLeft = tester.getTopLeft(labelFinder).dx;
    final labelSize = tester.getSize(labelFinder);
    final labelRight = labelLeft + labelSize.width;

    expect(labelLeft, greaterThanOrEqualTo(0));
    expect(
      labelRight,
      lessThanOrEqualTo(180),
      reason: 'labelLeft=$labelLeft labelSize=$labelSize',
    );
    expect(
      find.byKey(const ValueKey('layout-drag-preview-connector-right-card')),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay shifts left-edge badges into canvas', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180,
              height: 160,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'left-card',
                      currentBounds: const Rect.fromLTWH(-18, 80, 48, 40),
                      ruleBounds: const Rect.fromLTWH(-18, 80, 48, 40),
                      ruleLabel: 'Grid c0 r3',
                      hasConflict: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(LayoutDragPreviewOverlay)),
      const Size(180, 160),
    );

    final labelFinder = find.text('Grid c0 r3');
    final labelLeft = tester.getTopLeft(labelFinder).dx;
    final labelSize = tester.getSize(labelFinder);
    final labelRight = labelLeft + labelSize.width;

    expect(
      labelLeft,
      greaterThanOrEqualTo(0),
      reason: 'labelLeft=$labelLeft labelSize=$labelSize',
    );
    expect(labelRight, lessThanOrEqualTo(180));
    expect(
      find.byKey(const ValueKey('layout-drag-preview-connector-left-card')),
      findsOneWidget,
    );
  });

  testWidgets('LayoutDragPreviewOverlay clamps badges inside short canvases', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 180,
              height: 90,
              child: LayoutDragPreviewOverlay(
                preview: LayoutDragPreview(
                  mechanism: LayoutMechanism.grid,
                  items: [
                    LayoutDragPreviewItem(
                      componentId: 'short-card',
                      currentBounds: const Rect.fromLTWH(20, 4, 80, 78),
                      ruleBounds: const Rect.fromLTWH(20, 4, 80, 78),
                      ruleLabel: 'Grid c2 r1',
                      hasConflict: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(LayoutDragPreviewOverlay)),
      const Size(180, 90),
    );

    final labelFinder = find.text('Grid c2 r1');
    final labelTop = tester.getTopLeft(labelFinder).dy;
    final labelSize = tester.getSize(labelFinder);
    final labelBottom = labelTop + labelSize.height;

    expect(
      labelTop,
      greaterThanOrEqualTo(0),
      reason: 'labelTop=$labelTop labelSize=$labelSize',
    );
    expect(
      labelBottom,
      lessThanOrEqualTo(90),
      reason: 'labelTop=$labelTop labelSize=$labelSize',
    );
    expect(
      find.byKey(const ValueKey('layout-drag-preview-connector-short-card')),
      findsNothing,
    );
  });

  testWidgets(
    'LayoutDragPreviewOverlay measures scaled badges before clamping',
    (tester) async {
      Future<void> pumpScaledOverlay(double scale) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 190,
                        height: 160,
                        child: LayoutDragPreviewOverlay(
                          preview: LayoutDragPreview(
                            mechanism: LayoutMechanism.grid,
                            items: [
                              LayoutDragPreviewItem(
                                componentId: 'scaled-card',
                                currentBounds: const Rect.fromLTWH(
                                  150,
                                  8,
                                  34,
                                  92,
                                ),
                                ruleBounds: const Rect.fromLTWH(150, 8, 34, 92),
                                ruleLabel: 'Grid c12 r1',
                                hasConflict: true,
                                isOutsideCanvas: true,
                                outsideCanvasEdges: const [
                                  LayoutCanvasEdge.right,
                                ],
                                canvasOverflow: [
                                  LayoutCanvasOverflow(
                                    edge: LayoutCanvasEdge.right,
                                    distance: 12,
                                  ),
                                ],
                                canvasCorrectionOffset: const Offset(-12, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }

      await pumpScaledOverlay(1);
      await pumpScaledOverlay(1.7);

      expect(
        tester.getSize(find.byType(LayoutDragPreviewOverlay)),
        const Size(190, 160),
      );

      for (final label in [
        'Grid c12 r1',
        'overlap',
        'outside right 12px',
        'shift left 12px',
      ]) {
        final labelFinder = find.text(label);
        final labelTopLeft = tester.getTopLeft(labelFinder);
        final labelSize = tester.getSize(labelFinder);

        expect(
          labelTopLeft.dx,
          greaterThanOrEqualTo(0),
          reason: '$label left=${labelTopLeft.dx} size=$labelSize',
        );
        expect(
          labelTopLeft.dx + labelSize.width,
          lessThanOrEqualTo(190),
          reason: '$label left=${labelTopLeft.dx} size=$labelSize',
        );
        expect(
          labelTopLeft.dy,
          greaterThanOrEqualTo(0),
          reason: '$label top=${labelTopLeft.dy} size=$labelSize',
        );
        expect(
          labelTopLeft.dy + labelSize.height,
          lessThanOrEqualTo(160),
          reason: '$label top=${labelTopLeft.dy} size=$labelSize',
        );
      }
    },
  );
}
