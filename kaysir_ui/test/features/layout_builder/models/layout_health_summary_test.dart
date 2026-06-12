import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/layout_builder/models/component.dart';
import 'package:kaysir/features/layout_builder/models/grid_setting.dart';
import 'package:kaysir/features/layout_builder/models/layout_config.dart';
import 'package:kaysir/features/layout_builder/models/layout_health_summary.dart';

void main() {
  test('summarizes visible layout health issues', () {
    final summary = layoutHealthSummaryFor(
      components: [
        ComponentData.create(
          id: 'misaligned',
          type: ComponentType.customButton,
          position: const Offset(13, 27),
          size: const Size(33, 44),
        ),
        ComponentData.create(
          id: 'locked-outside',
          type: ComponentType.customButton,
          position: const Offset(190, 190),
          size: const Size(40, 40),
        ).copyWith(isLocked: true),
        ComponentData.create(
          id: 'hidden',
          type: ComponentType.customButton,
          position: Offset.zero,
          size: const Size(40, 40),
        ).copyWith(isVisible: false),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 200,
        canvasHeight: 200,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );

    expect(summary.visibleComponentCount, 2);
    expect(summary.editableComponentCount, 1);
    expect(summary.lockedComponentCount, 1);
    expect(summary.hiddenComponentCount, 1);
    expect(summary.offCanvasCount, 1);
    expect(summary.offCanvasComponentIds, ['locked-outside']);
    expect(summary.expandableOffCanvasComponentIds, ['locked-outside']);
    expect(summary.repositionOffCanvasComponentIds, isEmpty);
    expect(summary.hasSelectableOffCanvas, isTrue);
    expect(summary.hasSelectableExpandableOffCanvas, isTrue);
    expect(summary.hasSelectableRepositionOffCanvas, isFalse);
    expect(summary.expandableOffCanvasCount, 1);
    expect(summary.repositionOffCanvasCount, 0);
    expect(summary.repositionableOffCanvasCount, 0);
    expect(summary.hasExpandableOffCanvas, isTrue);
    expect(summary.hasRepositionOffCanvas, isFalse);
    expect(summary.hasRepositionableOffCanvas, isFalse);
    expect(summary.skippedComponentCount, 2);
    expect(summary.lockedRepositionOffCanvasCount, 0);
    expect(summary.hasRepairScopeNotes, isTrue);
    expect(summary.offRulePositionCount, 1);
    expect(summary.offRulePositionComponentIds, ['misaligned']);
    expect(summary.hasSelectableOffRulePositions, isTrue);
    expect(summary.offRuleSizeCount, 1);
    expect(summary.offRuleSizeComponentIds, ['misaligned']);
    expect(summary.hasSelectableOffRuleSizes, isTrue);
    expect(summary.autoGridConflictCount, 0);
    expect(summary.autoGridConflictComponentIds, isEmpty);
    expect(summary.hasSelectableAutoGridConflicts, isFalse);
    expect(summary.hasIssues, isTrue);
    expect(summary.issueCount, 3);
    expect(summary.statusLabel, '3 issues detected');
    expect(summary.canExpandCanvas, isTrue);
    expect(summary.expandedCanvasSize, const Size(320, 320));
    expect(summary.expandedCanvasSizeLabel, '320 x 320');
    expect(summary.repositionOffset, isNull);
    expect(summary.repositionOffsetLabel, isNull);
  });

  test('labels healthy layouts clearly', () {
    final summary = layoutHealthSummaryFor(
      components: [
        ComponentData.create(
          id: 'aligned',
          type: ComponentType.customButton,
          position: const Offset(20, 20),
          size: const Size(40, 40),
        ),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 200,
        canvasHeight: 200,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );

    expect(summary.hasIssues, isFalse);
    expect(summary.issueCount, 0);
    expect(summary.statusLabel, 'Healthy layout');
    expect(summary.skippedComponentCount, 0);
    expect(summary.lockedRepositionOffCanvasCount, 0);
    expect(summary.hasRepairScopeNotes, isFalse);
    expect(summary.canExpandCanvas, isFalse);
    expect(summary.expandedCanvasSize, isNull);
    expect(summary.repositionOffset, isNull);
    expect(summary.repositionOffsetLabel, isNull);
    expect(summary.offCanvasComponentIds, isEmpty);
    expect(summary.expandableOffCanvasComponentIds, isEmpty);
    expect(summary.repositionOffCanvasComponentIds, isEmpty);
    expect(summary.offRulePositionComponentIds, isEmpty);
    expect(summary.offRuleSizeComponentIds, isEmpty);
    expect(summary.autoGridConflictComponentIds, isEmpty);
    expect(summary.hasSelectableOffCanvas, isFalse);
    expect(summary.hasSelectableExpandableOffCanvas, isFalse);
    expect(summary.hasSelectableRepositionOffCanvas, isFalse);
    expect(summary.hasSelectableOffRulePositions, isFalse);
    expect(summary.hasSelectableOffRuleSizes, isFalse);
    expect(summary.hasSelectableAutoGridConflicts, isFalse);
  });

  test('separates negative off-canvas components from expandable overflow', () {
    final summary = layoutHealthSummaryFor(
      components: [
        ComponentData.create(
          id: 'negative',
          type: ComponentType.customButton,
          position: const Offset(-10, 20),
          size: const Size(40, 40),
        ),
        ComponentData.create(
          id: 'right-overflow',
          type: ComponentType.customButton,
          position: const Offset(190, 20),
          size: const Size(40, 40),
        ),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 200,
        canvasHeight: 200,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );

    expect(summary.offCanvasCount, 2);
    expect(summary.offCanvasComponentIds, ['negative', 'right-overflow']);
    expect(summary.expandableOffCanvasComponentIds, ['right-overflow']);
    expect(summary.repositionOffCanvasComponentIds, ['negative']);
    expect(summary.hasSelectableOffCanvas, isTrue);
    expect(summary.hasSelectableExpandableOffCanvas, isTrue);
    expect(summary.hasSelectableRepositionOffCanvas, isTrue);
    expect(summary.expandableOffCanvasCount, 1);
    expect(summary.repositionOffCanvasCount, 1);
    expect(summary.repositionableOffCanvasCount, 1);
    expect(summary.hasExpandableOffCanvas, isTrue);
    expect(summary.hasRepositionOffCanvas, isTrue);
    expect(summary.hasRepositionableOffCanvas, isTrue);
    expect(summary.skippedComponentCount, 0);
    expect(summary.lockedRepositionOffCanvasCount, 0);
    expect(summary.hasRepairScopeNotes, isFalse);
    expect(summary.expandedCanvasSize, const Size(320, 320));
    expect(summary.repositionOffset, const Offset(10, 0));
    expect(summary.repositionOffsetLabel, '+10px, +0px');
  });

  test('tracks Auto Grid conflict component ids', () {
    final summary = layoutHealthSummaryFor(
      components: [
        ComponentData.create(
          id: 'first',
          type: ComponentType.customButton,
          position: const Offset(3, 3),
          size: const Size(120, 80),
        ),
        ComponentData.create(
          id: 'second',
          type: ComponentType.customButton,
          position: const Offset(4, 6),
          size: const Size(120, 80),
        ),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 430,
        canvasHeight: 430,
        minComponentWidth: 40,
        minComponentHeight: 40,
        layoutMechanism: LayoutMechanism.autoGrid,
        autoGridColumnCount: 4,
        autoGridGap: 10,
        autoGridRowHeight: 100,
      ),
    );

    expect(summary.autoGridConflictCount, 2);
    expect(summary.autoGridConflictComponentIds, ['first', 'second']);
    expect(summary.hasSelectableAutoGridConflicts, isTrue);
  });

  test('reports locked left top off-canvas components as repair blockers', () {
    final summary = layoutHealthSummaryFor(
      components: [
        ComponentData.create(
          id: 'editable-inside',
          type: ComponentType.customButton,
          position: const Offset(20, 20),
          size: const Size(40, 40),
        ),
        ComponentData.create(
          id: 'locked-negative',
          type: ComponentType.customButton,
          position: const Offset(-12, -6),
          size: const Size(40, 40),
        ).copyWith(isLocked: true),
      ],
      gridSettings: const GridSettings(gridSize: 20),
      config: const LayoutConfig(
        canvasWidth: 200,
        canvasHeight: 200,
        minComponentWidth: 20,
        minComponentHeight: 20,
        layoutMechanism: LayoutMechanism.grid,
      ),
    );

    expect(summary.repositionOffCanvasCount, 1);
    expect(summary.offCanvasComponentIds, ['locked-negative']);
    expect(summary.expandableOffCanvasComponentIds, isEmpty);
    expect(summary.repositionOffCanvasComponentIds, ['locked-negative']);
    expect(summary.hasSelectableOffCanvas, isTrue);
    expect(summary.hasSelectableExpandableOffCanvas, isFalse);
    expect(summary.hasSelectableRepositionOffCanvas, isTrue);
    expect(summary.repositionableOffCanvasCount, 0);
    expect(summary.lockedRepositionOffCanvasCount, 1);
    expect(summary.hasRepairScopeNotes, isTrue);
    expect(summary.repositionOffset, isNull);
  });
}
