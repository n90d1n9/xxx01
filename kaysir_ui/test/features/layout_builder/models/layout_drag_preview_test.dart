import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_drag_preview.dart';

void main() {
  group('layoutDragPreviewFor', () {
    test('snaps grid placement independently from the current position', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(13, 27),
            size: const Size(50, 60),
          ),
        ],
        selectedComponentIds: const {},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20, snapToGrid: false),
      );

      expect(preview, isNotNull);
      final resolvedPreview = preview!;
      expect(resolvedPreview.willApplyRulesOnDrop, isFalse);
      final item = resolvedPreview.items.single;
      expect(item.currentBounds, const Rect.fromLTWH(13, 27, 50, 60));
      expect(item.ruleBounds, const Rect.fromLTWH(20, 20, 50, 60));
      expect(item.ruleLabel, 'Grid c2 r2');
      expect(item.isRuleAligned, isFalse);
    });

    test('reports tabular column, row, and span for selected drags', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(145, 80),
            size: const Size(230, 50),
          ),
          _component(
            'second',
            position: const Offset(8, 49),
            size: const Size(90, 50),
          ),
          _component('locked', position: Offset.zero, isLocked: true),
          _component('hidden', position: Offset.zero, isVisible: false),
        ],
        selectedComponentIds: const {'dragged', 'second', 'locked', 'hidden'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          canvasWidth: 500,
          tabularColumnCount: 4,
          tabularColumnGap: 20,
          tabularRowHeight: 50,
          layoutMechanism: LayoutMechanism.tabularColumns,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final resolvedPreview = preview!;
      expect(resolvedPreview.willApplyRulesOnDrop, isTrue);
      expect(resolvedPreview.items.map((item) => item.componentId), [
        'dragged',
        'second',
      ]);
      expect(
        resolvedPreview.items.first.ruleBounds,
        const Rect.fromLTWH(130, 100, 230, 50),
      );
      expect(resolvedPreview.items.first.ruleLabel, 'Tabular c2 r3 2x1');
      expect(resolvedPreview.items.last.ruleLabel, 'Tabular c1 r2 1x1');
    });

    test('marks rule placement conflicts against non-selected components', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(20, 20),
            size: const Size(100, 100),
          ),
          _component(
            'neighbor',
            position: const Offset(20, 20),
            size: const Size(50, 100),
          ),
          _component(
            'second-neighbor',
            position: const Offset(45, 20),
            size: const Size(50, 100),
            type: ComponentType.textLabel,
          ),
        ],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.hasConflict, isTrue);
      expect(item.conflictCount, 2);
      expect(item.conflictCoverage, closeTo(0.75, 0.001));
      expect(item.conflictSourceSummary, 'Action Button, Text Label');
      expect(item.conflictBlockers, hasLength(2));
      expect(item.conflictBlockers.first.label, 'Action Button');
      expect(
        item.conflictBlockers.first.bounds,
        const Rect.fromLTWH(20, 20, 50, 100),
      );
      expect(item.conflictBlockers.last.label, 'Text Label');
      expect(
        item.conflictBlockers.last.bounds,
        const Rect.fromLTWH(45, 20, 50, 100),
      );
      expect(item.conflictPatches, hasLength(2));
      expect(item.conflictPatches.first.label, 'Action Button');
      expect(
        item.conflictPatches.first.bounds,
        const Rect.fromLTWH(20, 20, 50, 100),
      );
      expect(item.conflictPatches.last.label, 'Text Label');
      expect(
        item.conflictPatches.last.bounds,
        const Rect.fromLTWH(45, 20, 50, 100),
      );
      expect(item.hasConflictResolution, isTrue);
      expect(item.conflictResolutionOffset, const Offset(80, 0));
      expect(
        item.conflictResolvedBounds,
        const Rect.fromLTWH(100, 20, 100, 100),
      );
      expect(item.usesNearbyConflictResolution, isFalse);
      expect(
        item.conflictResolution?.source,
        LayoutConflictResolutionSource.direct,
      );
      expect(item.conflictResolvedRuleLabel, 'Grid c6 r2');
    });

    test('clips conflict patches to the preview target', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(20, 20),
            size: const Size(100, 100),
          ),
          _component(
            'partial-neighbor',
            position: const Offset(0, 0),
            size: const Size(50, 60),
          ),
        ],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.conflictCoverage, closeTo(0.12, 0.001));
      expect(
        item.conflictBlockers.single.bounds,
        const Rect.fromLTWH(0, 0, 50, 60),
      );
      expect(
        item.conflictPatches.single.bounds,
        const Rect.fromLTWH(20, 20, 30, 40),
      );
      expect(
        item.conflictResolvedBounds,
        const Rect.fromLTWH(60, 20, 100, 100),
      );
      expect(item.usesNearbyConflictResolution, isFalse);
      expect(
        item.conflictResolution?.source,
        LayoutConflictResolutionSource.direct,
      );
      expect(item.conflictResolvedRuleLabel, 'Grid c4 r2');
    });

    test(
      'searches nearby rule slots when immediate clear spots are blocked',
      () {
        final preview = layoutDragPreviewFor(
          components: [
            _component(
              'dragged',
              position: const Offset(20, 20),
              size: const Size(40, 40),
            ),
            _component(
              'center-blocker',
              position: const Offset(20, 20),
              size: const Size(40, 40),
            ),
            _component(
              'right-blocker',
              position: const Offset(60, 20),
              size: const Size(40, 40),
            ),
            _component(
              'bottom-blocker',
              position: const Offset(20, 60),
              size: const Size(40, 40),
            ),
          ],
          selectedComponentIds: const {'dragged'},
          activeComponentId: 'dragged',
          config: const LayoutConfig(
            canvasWidth: 180,
            canvasHeight: 140,
            layoutMechanism: LayoutMechanism.grid,
            minComponentWidth: 20,
            minComponentHeight: 20,
          ),
          gridSettings: const GridSettings(gridSize: 20),
        );

        expect(preview, isNotNull);
        final item = preview!.items.single;
        expect(item.hasConflict, isTrue);
        expect(
          item.conflictResolvedBounds,
          const Rect.fromLTWH(60, 60, 40, 40),
        );
        expect(item.conflictResolutionOffset, const Offset(40, 40));
        expect(item.usesNearbyConflictResolution, isTrue);
        expect(
          item.conflictResolution?.source,
          LayoutConflictResolutionSource.nearbySearch,
        );
        expect(item.conflictResolvedRuleLabel, 'Grid c4 r4');
      },
    );

    test(
      'reports unresolved conflicts when no canvas-safe clear spot exists',
      () {
        final preview = layoutDragPreviewFor(
          components: [
            _component(
              'dragged',
              position: const Offset(20, 20),
              size: const Size(40, 40),
            ),
            _component(
              'corner-blocker',
              position: const Offset(20, 20),
              size: const Size(40, 40),
            ),
          ],
          selectedComponentIds: const {'dragged'},
          activeComponentId: 'dragged',
          config: const LayoutConfig(
            canvasWidth: 60,
            canvasHeight: 60,
            layoutMechanism: LayoutMechanism.grid,
            minComponentWidth: 20,
            minComponentHeight: 20,
          ),
          gridSettings: const GridSettings(gridSize: 20),
        );

        expect(preview, isNotNull);
        final item = preview!.items.single;
        expect(item.hasConflict, isTrue);
        expect(item.hasConflictResolution, isFalse);
        expect(item.hasUnresolvedConflict, isTrue);
        expect(item.conflictResolution, isNull);
        expect(item.conflictResolvedBounds, isNull);
        expect(item.conflictResolvedRuleLabel, isEmpty);
      },
    );

    test('marks rule placement outside the canvas', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(117, 117),
            size: const Size(50, 50),
          ),
        ],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          canvasWidth: 140,
          canvasHeight: 140,
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.ruleBounds, const Rect.fromLTWH(120, 120, 50, 50));
      expect(item.isOutsideCanvas, isTrue);
      expect(item.outsideCanvasEdges, [
        LayoutCanvasEdge.right,
        LayoutCanvasEdge.bottom,
      ]);
      expect(
        item.canvasOverflow.map((overflow) => overflow.distance).toList(),
        [30, 30],
      );
      expect(item.canvasCorrectionOffset, const Offset(-30, -30));
      expect(item.hasCanvasCorrection, isTrue);
      expect(item.correctedRuleBounds, const Rect.fromLTWH(90, 90, 50, 50));
    });

    test('marks top and left canvas edge overflow', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(-17, -17),
            size: const Size(50, 50),
          ),
        ],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          canvasWidth: 140,
          canvasHeight: 140,
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.ruleBounds, const Rect.fromLTWH(-20, -20, 50, 50));
      expect(item.outsideCanvasEdges, [
        LayoutCanvasEdge.left,
        LayoutCanvasEdge.top,
      ]);
      expect(
        item.canvasOverflow.map((overflow) => overflow.distance).toList(),
        [20, 20],
      );
      expect(item.canvasCorrectionOffset, const Offset(20, 20));
    });

    test('reports resize-to-fit bounds for oversized placements', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'oversized',
            position: const Offset(-17, -9),
            size: const Size(190, 160),
          ),
        ],
        selectedComponentIds: const {'oversized'},
        activeComponentId: 'oversized',
        config: const LayoutConfig(
          canvasWidth: 140,
          canvasHeight: 120,
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.ruleBounds, const Rect.fromLTWH(-20, 0, 190, 160));
      expect(item.canvasCorrectionOffset, const Offset(0, -40));
      expect(item.hasCanvasCorrection, isTrue);
      expect(item.canvasCorrectedBounds, const Rect.fromLTWH(0, 0, 140, 120));
      expect(item.correctedRuleBounds, const Rect.fromLTWH(0, 0, 140, 120));
    });

    test('reports Auto Grid column, row, and span labels', () {
      final preview = layoutDragPreviewFor(
        components: [
          _component(
            'dragged',
            position: const Offset(119, 72),
            size: const Size(100, 60),
          ),
        ],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(
          canvasWidth: 430,
          autoGridColumnCount: 4,
          autoGridGap: 10,
          autoGridRowHeight: 60,
          layoutMechanism: LayoutMechanism.autoGrid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.ruleBounds, const Rect.fromLTWH(110, 70, 100, 60));
      expect(item.ruleLabel, 'Auto Grid c2 r2 1x1');
    });

    test('returns no preview for freeform layouts', () {
      final preview = layoutDragPreviewFor(
        components: [_component('dragged', position: Offset.zero)],
        selectedComponentIds: const {'dragged'},
        activeComponentId: 'dragged',
        config: const LayoutConfig(layoutMechanism: LayoutMechanism.freeform),
        gridSettings: const GridSettings(),
      );

      expect(preview, isNull);
    });
  });

  group('layoutDropPreviewFor', () {
    test('normalizes incoming component ids and detects rule conflicts', () {
      final preview = layoutDropPreviewFor(
        existingComponents: [
          _component(
            'existing',
            position: const Offset(20, 20),
            size: const Size(80, 60),
          ),
        ],
        dropComponents: [
          _component(
            'existing',
            position: const Offset(13, 27),
            size: const Size(50, 60),
          ),
        ],
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      final item = preview!.items.single;
      expect(item.componentId, 'drop-preview-0');
      expect(item.ruleBounds, const Rect.fromLTWH(20, 20, 50, 60));
      expect(item.hasConflict, isTrue);
    });

    test('previews multi-component drops as one selected draft group', () {
      final preview = layoutDropPreviewFor(
        existingComponents: const [],
        dropComponents: [
          _component(
            'source-a',
            position: const Offset(13, 27),
            size: const Size(50, 60),
          ),
          _component(
            'source-b',
            position: const Offset(65, 27),
            size: const Size(50, 60),
          ),
        ],
        config: const LayoutConfig(
          layoutMechanism: LayoutMechanism.grid,
          minComponentWidth: 20,
          minComponentHeight: 20,
        ),
        gridSettings: const GridSettings(gridSize: 20),
      );

      expect(preview, isNotNull);
      expect(preview!.items.map((item) => item.componentId), [
        'drop-preview-0',
        'drop-preview-1',
      ]);
      expect(
        preview.items.first.ruleBounds,
        const Rect.fromLTWH(20, 20, 50, 60),
      );
      expect(
        preview.items.last.ruleBounds,
        const Rect.fromLTWH(60, 20, 50, 60),
      );
      expect(preview.items.every((item) => item.hasConflict), isFalse);
    });
  });
}

ComponentData _component(
  String id, {
  required Offset position,
  ComponentType type = ComponentType.customButton,
  Size size = const Size(40, 40),
  bool isLocked = false,
  bool isVisible = true,
}) {
  return ComponentData.create(
    id: id,
    type: type,
    position: position,
    size: size,
  ).copyWith(isLocked: isLocked, isVisible: isVisible);
}
