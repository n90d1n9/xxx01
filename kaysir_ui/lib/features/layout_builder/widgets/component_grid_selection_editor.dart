import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_rule_geometry_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import 'component_inspector_controls.dart';
import 'layout_rule_controls.dart';
import 'number_field.dart';

/// Edits grid-rule position and cleanup actions for a multi-component selection.
class ComponentGridSelectionEditor extends ConsumerWidget {
  final List<ComponentData> components;
  final LayoutConfig config;
  final double gridSize;

  const ComponentGridSelectionEditor({
    super.key,
    required this.components,
    required this.config,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final layoutState = ref.watch(layoutStateProvider);
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    final movableComponents =
        visibleComponents.where((component) => !component.isLocked).toList();
    final metrics = layoutRuleGeometryService.gridSelectionMetricsFor(
      visibleComponents,
      config,
      gridSize,
    );
    final editableMetrics = layoutRuleGeometryService.gridSelectionMetricsFor(
      movableComponents,
      config,
      gridSize,
    );
    final selectedVisibleCount = visibleComponents.length;
    final selectedMovableCount = movableComponents.length;
    final visibleMovableComponents =
        layoutState.components
            .where((component) => component.isVisible && !component.isLocked)
            .toList();
    final visibleMovableCount = visibleMovableComponents.length;
    final selectedSnapStatus = layoutRuleGeometryService.snapStatusFor(
      movableComponents,
      config,
      gridSize,
    );
    final visibleSnapStatus = layoutRuleGeometryService.snapStatusFor(
      visibleMovableComponents,
      config,
      gridSize,
    );
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final hiddenCount =
        components.where((component) => !component.isVisible).length;
    final columnCount = layoutRuleGeometryService.gridColumnCountFor(
      config,
      gridSize,
    );
    final rowCount = layoutRuleGeometryService.gridRowCountFor(
      config,
      gridSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grid selection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (metrics != null) ...[
              ComponentInspectorChip(
                icon: Icons.grid_on,
                label: layoutRuleGeometryService.cellRangeLabel(metrics),
              ),
              ComponentInspectorChip(
                icon: Icons.open_in_full,
                label: '${metrics.columnSpan} x ${metrics.rowSpan} cells',
              ),
            ],
            ComponentInspectorChip(
              icon: Icons.visibility_outlined,
              label: '$selectedVisibleCount visible',
            ),
            if (selectedMovableCount > 0)
              ComponentInspectorChip(
                icon: Icons.open_with_outlined,
                label: '$selectedMovableCount movable',
              ),
            if (lockedCount > 0)
              ComponentInspectorChip(
                icon: Icons.lock,
                label: '$lockedCount locked',
              ),
            if (hiddenCount > 0)
              ComponentInspectorChip(
                icon: Icons.visibility_off_outlined,
                label: '$hiddenCount hidden',
              ),
          ],
        ),
        if (editableMetrics != null) ...[
          const SizedBox(height: 8),
          ComponentInspectorFieldPair(
            first: NumberField(
              key: ValueKey(
                'grid-selection-start-column-${editableMetrics.startColumn}',
              ),
              label: 'Start col',
              value: editableMetrics.startColumn.toDouble(),
              min: 1,
              max: columnCount.toDouble(),
              onChanged:
                  (value) =>
                      layoutRuleGeometryService.moveSelectionToGridColumn(
                        notifier,
                        components,
                        gridSize,
                        value.round(),
                      ),
            ),
            second: NumberField(
              key: ValueKey(
                'grid-selection-start-row-${editableMetrics.startRow}',
              ),
              label: 'Start row',
              value: editableMetrics.startRow.toDouble(),
              min: 1,
              max: rowCount.toDouble(),
              onChanged:
                  (value) => layoutRuleGeometryService.moveSelectionToGridRow(
                    notifier,
                    components,
                    gridSize,
                    value.round(),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutRuleNudgeControls(
            columnUnitLabel: 'grid column',
            rowUnitLabel: 'grid row',
            canMoveLeft: editableMetrics.startColumn > 1,
            canMoveRight: editableMetrics.endColumn < columnCount,
            canMoveUp: editableMetrics.startRow > 1,
            canMoveDown: editableMetrics.endRow < rowCount,
            onMoveLeft:
                () => notifier.nudgeSelectedComponent(
                  Offset(-layoutRuleGeometryService.gridTrackSize(gridSize), 0),
                ),
            onMoveRight:
                () => notifier.nudgeSelectedComponent(
                  Offset(layoutRuleGeometryService.gridTrackSize(gridSize), 0),
                ),
            onMoveUp:
                () => notifier.nudgeSelectedComponent(
                  Offset(0, -layoutRuleGeometryService.gridTrackSize(gridSize)),
                ),
            onMoveDown:
                () => notifier.nudgeSelectedComponent(
                  Offset(0, layoutRuleGeometryService.gridTrackSize(gridSize)),
                ),
          ),
          const SizedBox(height: 8),
          LayoutRuleCleanupActions(
            canSnapSelection: selectedMovableCount > 0,
            canSnapVisible: visibleMovableCount > 0,
            selectedStatus: selectedSnapStatus,
            visibleStatus: visibleSnapStatus,
            onSnapSelection:
                () => layoutSelectionGeometryActionService
                    .snapSelectionToLayoutRules(context, ref),
            onSnapSelectionSize:
                () => layoutSelectionGeometryActionService
                    .snapSelectionSizeToLayoutRules(context, ref),
            onSnapVisible:
                () => layoutSelectionGeometryActionService
                    .snapVisibleComponentsToLayoutRules(context, ref),
            onSnapVisibleSize:
                () => layoutSelectionGeometryActionService
                    .snapVisibleComponentSizesToLayoutRules(context, ref),
          ),
        ],
      ],
    );
  }
}

/// Renders the grid selection editor with sample selected components.
@Preview(name: 'Component grid selection editor')
Widget componentGridSelectionEditorPreview() {
  final components = [
    ComponentData.create(
      id: 'preview-grid-selection-a',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(40, 40),
    ),
    ComponentData.create(
      id: 'preview-grid-selection-b',
      type: ComponentType.customButton,
      position: const Offset(80, 20),
      size: const Size(40, 40),
    ),
  ];

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentGridSelectionEditor(
                components: components,
                config: const LayoutConfig(
                  layoutMechanism: LayoutMechanism.grid,
                  canvasWidth: 240,
                  canvasHeight: 160,
                ),
                gridSize: 20,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
