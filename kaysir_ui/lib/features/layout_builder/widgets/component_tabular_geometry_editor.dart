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

/// Edits the selected component's tabular column position and span.
class ComponentTabularGeometryEditor extends ConsumerWidget {
  final ComponentData component;
  final LayoutConfig config;

  const ComponentTabularGeometryEditor({
    super.key,
    required this.component,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = layoutRuleGeometryService.tabularGeometryFor(
      component,
      config,
    );
    final notifier = ref.read(layoutStateProvider.notifier);
    final layoutState = ref.watch(layoutStateProvider);
    final visibleMovableComponents =
        layoutState.components
            .where((component) => component.isVisible && !component.isLocked)
            .toList();
    final selectedSnapStatus = layoutRuleGeometryService.snapStatusFor(
      [component],
      config,
      config.gridSize,
      includeHidden: true,
    );
    final visibleSnapStatus = layoutRuleGeometryService.snapStatusFor(
      visibleMovableComponents,
      config,
      config.gridSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComponentInspectorSectionHeader(
          title: 'Tabular position',
          resetTooltip: 'Snap to tabular rules',
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
            key: ValueKey('tabular-column-${component.id}-${metrics.column}'),
            label: 'Col',
            value: metrics.column.toDouble(),
            min: 1,
            max: config.tabularColumnCount.toDouble(),
            onChanged:
                (value) => notifier.moveSelectedToTabularColumn(value.round()),
          ),
          second: NumberField(
            key: ValueKey('tabular-row-${component.id}-${metrics.row}'),
            label: 'Row',
            value: metrics.row.toDouble(),
            min: 1,
            onChanged:
                (value) => notifier.moveSelectedToTabularRow(value.round()),
          ),
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey(
              'tabular-column-span-${component.id}-${metrics.columnSpan}',
            ),
            label: 'Col span',
            value: metrics.columnSpan.toDouble(),
            min: 1,
            max: config.tabularColumnCount.toDouble(),
            onChanged:
                (value) => notifier.setSelectedTabularColumnSpan(value.round()),
          ),
          second: NumberField(
            key: ValueKey(
              'tabular-row-span-${component.id}-${metrics.rowSpan}',
            ),
            label: 'Row span',
            value: metrics.rowSpan.toDouble(),
            min: 1,
            onChanged:
                (value) => notifier.setSelectedTabularRowSpan(value.round()),
          ),
        ),
        const SizedBox(height: 10),
        _TabularGeometrySummary(metrics: metrics, config: config),
        const SizedBox(height: 8),
        LayoutRuleNudgeControls(
          columnUnitLabel: 'tabular column',
          rowUnitLabel: 'tabular row',
          canMoveLeft: !component.isLocked && metrics.column > 1,
          canMoveRight:
              !component.isLocked &&
              metrics.column + metrics.columnSpan - 1 <
                  config.tabularColumnCount,
          canMoveUp: !component.isLocked && metrics.row > 1,
          canMoveDown: !component.isLocked,
          onMoveLeft: () => notifier.nudgeSelectedByTabularColumns(-1),
          onMoveRight: () => notifier.nudgeSelectedByTabularColumns(1),
          onMoveUp: () => notifier.nudgeSelectedByTabularRows(-1),
          onMoveDown: () => notifier.nudgeSelectedByTabularRows(1),
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

/// Summarizes the selected component's resolved tabular coordinates and size.
class _TabularGeometrySummary extends StatelessWidget {
  final LayoutRuleTabularGeometryMetrics metrics;
  final LayoutConfig config;

  const _TabularGeometrySummary({required this.metrics, required this.config});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ComponentInspectorChip(
          icon: Icons.view_column_outlined,
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
          icon: Icons.table_rows_outlined,
          label: '${config.tabularColumnCount} cols',
        ),
      ],
    );
  }
}

/// Renders the tabular geometry editor with sample values for previews.
@Preview(name: 'Component tabular geometry editor')
Widget componentTabularGeometryEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-tabular-button',
    type: ComponentType.customButton,
    position: const Offset(110, 80),
    size: const Size(100, 80),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentTabularGeometryEditor(
                component: component,
                config: const LayoutConfig(
                  layoutMechanism: LayoutMechanism.tabularColumns,
                  canvasWidth: 430,
                  canvasHeight: 430,
                  minComponentWidth: 40,
                  minComponentHeight: 40,
                  tabularColumnCount: 4,
                  tabularColumnGap: 10,
                  tabularRowHeight: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
