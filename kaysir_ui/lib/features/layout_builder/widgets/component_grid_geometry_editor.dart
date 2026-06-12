import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_rule_geometry.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_rule_geometry_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import 'component_inspector_controls.dart';
import 'layout_rule_controls.dart';
import 'number_field.dart';

/// Edits the selected component's grid cell position and span.
class ComponentGridGeometryEditor extends ConsumerWidget {
  final ComponentData component;
  final LayoutConfig config;
  final double gridSize;

  const ComponentGridGeometryEditor({
    super.key,
    required this.component,
    required this.config,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = layoutRuleGeometryService.gridGeometryFor(
      component,
      config,
      gridSize,
    );
    final notifier = ref.read(layoutStateProvider.notifier);
    final layoutState = ref.watch(layoutStateProvider);
    final columnCount = layoutRuleGeometryService.gridColumnCountFor(
      config,
      gridSize,
    );
    final rowCount = layoutRuleGeometryService.gridRowCountFor(
      config,
      gridSize,
    );
    final visibleMovableComponents =
        layoutState.components
            .where((component) => component.isVisible && !component.isLocked)
            .toList();
    final selectedSnapStatus = layoutRuleGeometryService.snapStatusFor(
      [component],
      config,
      gridSize,
      includeHidden: true,
    );
    final visibleSnapStatus = layoutRuleGeometryService.snapStatusFor(
      visibleMovableComponents,
      config,
      gridSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComponentInspectorSectionHeader(
          title: 'Grid position',
          resetTooltip: 'Snap to grid rules',
          onReset:
              component.isLocked
                  ? null
                  : () {
                    layoutSelectionGeometryActionService
                        .snapSelectionGeometryToLayoutRules(context, ref);
                  },
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey('grid-column-${component.id}-${metrics.column}'),
            label: 'Col',
            value: metrics.column.toDouble(),
            min: 1,
            max: columnCount.toDouble(),
            onChanged:
                (value) => layoutRuleGeometryService.moveSelectionToGridColumn(
                  notifier,
                  [component],
                  gridSize,
                  value.round(),
                ),
          ),
          second: NumberField(
            key: ValueKey('grid-row-${component.id}-${metrics.row}'),
            label: 'Row',
            value: metrics.row.toDouble(),
            min: 1,
            max: rowCount.toDouble(),
            onChanged:
                (value) => layoutRuleGeometryService.moveSelectionToGridRow(
                  notifier,
                  [component],
                  gridSize,
                  value.round(),
                ),
          ),
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey(
              'grid-column-span-${component.id}-${metrics.columnSpan}',
            ),
            label: 'Col span',
            value: metrics.columnSpan.toDouble(),
            min: 1,
            max: columnCount.toDouble(),
            onChanged:
                (value) => notifier.resizeSelectedComponents(
                  width: layoutRuleGeometryService.gridSpanPixels(
                    value.round(),
                    gridSize,
                  ),
                ),
          ),
          second: NumberField(
            key: ValueKey('grid-row-span-${component.id}-${metrics.rowSpan}'),
            label: 'Row span',
            value: metrics.rowSpan.toDouble(),
            min: 1,
            max: rowCount.toDouble(),
            onChanged:
                (value) => notifier.resizeSelectedComponents(
                  height: layoutRuleGeometryService.gridSpanPixels(
                    value.round(),
                    gridSize,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 10),
        _GridGeometrySummary(metrics: metrics, columnCount: columnCount),
        const SizedBox(height: 8),
        LayoutRuleNudgeControls(
          columnUnitLabel: 'grid column',
          rowUnitLabel: 'grid row',
          canMoveLeft: !component.isLocked && metrics.column > 1,
          canMoveRight:
              !component.isLocked &&
              metrics.column + metrics.columnSpan - 1 < columnCount,
          canMoveUp: !component.isLocked && metrics.row > 1,
          canMoveDown:
              !component.isLocked &&
              metrics.row + metrics.rowSpan - 1 < rowCount,
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
          canSnapSelection: !component.isLocked,
          canSnapVisible: visibleMovableComponents.isNotEmpty,
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
    );
  }
}

/// Summarizes the selected component's resolved grid coordinates and size.
class _GridGeometrySummary extends StatelessWidget {
  final LayoutRuleGridGeometryMetrics metrics;
  final int columnCount;

  const _GridGeometrySummary({
    required this.metrics,
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ComponentInspectorChip(
          icon: Icons.grid_on,
          label: 'C${metrics.column} R${metrics.row}',
        ),
        ComponentInspectorChip(
          icon: Icons.open_in_full,
          label: '${metrics.columnSpan} x ${metrics.rowSpan} cells',
        ),
        ComponentInspectorChip(
          icon: Icons.straighten,
          label:
              '${layoutRuleGeometryService.formatPixels(metrics.pixelWidth)} x ${layoutRuleGeometryService.formatPixels(metrics.pixelHeight)}',
        ),
        ComponentInspectorChip(
          icon: Icons.view_module_outlined,
          label: '$columnCount cols',
        ),
      ],
    );
  }
}

/// Renders the grid geometry editor with sample values for previews.
@Preview(name: 'Component grid geometry editor')
Widget componentGridGeometryEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-grid-button',
    type: ComponentType.customButton,
    position: const Offset(40, 60),
    size: const Size(160, 80),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentGridGeometryEditor(
                component: component,
                config: const LayoutConfig(
                  layoutMechanism: LayoutMechanism.grid,
                  canvasWidth: 640,
                  canvasHeight: 480,
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
