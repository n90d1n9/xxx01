import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../models/layout_rule_geometry.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_rule_geometry_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import 'component_inspector_controls.dart';
import 'layout_rule_controls.dart';
import 'number_field.dart';

/// Edits the selected component's auto-grid cell position and span.
class ComponentAutoGridGeometryEditor extends ConsumerWidget {
  final ComponentData component;
  final LayoutConfig config;

  const ComponentAutoGridGeometryEditor({
    super.key,
    required this.component,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = layoutRuleGeometryService.autoGridGeometryFor(
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
          title: 'Auto Grid position',
          resetTooltip: 'Snap to auto grid rules',
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
            key: ValueKey('auto-grid-column-${component.id}-${metrics.column}'),
            label: 'Col',
            value: metrics.column.toDouble(),
            min: 1,
            max: config.autoGridColumnCount.toDouble(),
            onChanged:
                (value) => notifier.moveSelectedToAutoGridColumn(value.round()),
          ),
          second: NumberField(
            key: ValueKey('auto-grid-row-${component.id}-${metrics.row}'),
            label: 'Row',
            value: metrics.row.toDouble(),
            min: 1,
            onChanged:
                (value) => notifier.moveSelectedToAutoGridRow(value.round()),
          ),
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey(
              'auto-grid-column-span-${component.id}-${metrics.columnSpan}',
            ),
            label: 'Col span',
            value: metrics.columnSpan.toDouble(),
            min: 1,
            max: config.autoGridColumnCount.toDouble(),
            onChanged:
                (value) =>
                    notifier.setSelectedAutoGridColumnSpan(value.round()),
          ),
          second: NumberField(
            key: ValueKey(
              'auto-grid-row-span-${component.id}-${metrics.rowSpan}',
            ),
            label: 'Row span',
            value: metrics.rowSpan.toDouble(),
            min: 1,
            onChanged:
                (value) => notifier.setSelectedAutoGridRowSpan(value.round()),
          ),
        ),
        const SizedBox(height: 10),
        _AutoGridGeometrySummary(metrics: metrics, config: config),
        const SizedBox(height: 8),
        LayoutRuleNudgeControls(
          columnUnitLabel: 'Auto Grid column',
          rowUnitLabel: 'Auto Grid row',
          canMoveLeft: !component.isLocked && metrics.column > 1,
          canMoveRight:
              !component.isLocked &&
              metrics.column + metrics.columnSpan - 1 <
                  config.autoGridColumnCount,
          canMoveUp: !component.isLocked && metrics.row > 1,
          canMoveDown: !component.isLocked,
          onMoveLeft: () => notifier.nudgeSelectedByAutoGridColumns(-1),
          onMoveRight: () => notifier.nudgeSelectedByAutoGridColumns(1),
          onMoveUp: () => notifier.nudgeSelectedByAutoGridRows(-1),
          onMoveDown: () => notifier.nudgeSelectedByAutoGridRows(1),
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LayoutRuleActionButton(
              icon: Icons.auto_fix_high_outlined,
              label: 'Free cell',
              tooltip: 'Move selection to free Auto Grid cells',
              onPressed:
                  component.isLocked
                      ? null
                      : () => layoutAutoGridActionService
                          .moveSelectionToFreeCells(context, ref),
            ),
            LayoutRuleActionButton(
              icon: Icons.manage_search_outlined,
              label: 'Conflicts',
              tooltip: 'Select Auto Grid conflicts',
              onPressed:
                  () => layoutAutoGridActionService
                      .selectConflictPartnersForSelection(context, ref),
            ),
            LayoutRuleActionButton(
              icon: Icons.view_module_outlined,
              label: 'Compact',
              tooltip: 'Compact visible Auto Grid components',
              onPressed:
                  () =>
                      layoutAutoGridActionService.compactVisible(context, ref),
            ),
          ],
        ),
      ],
    );
  }
}

/// Summarizes the selected component's resolved auto-grid coordinates and size.
class _AutoGridGeometrySummary extends StatelessWidget {
  final LayoutRuleAutoGridGeometryMetrics metrics;
  final LayoutConfig config;

  const _AutoGridGeometrySummary({required this.metrics, required this.config});

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
          icon: Icons.view_column,
          label: '${config.autoGridColumnCount} cols',
        ),
      ],
    );
  }
}

/// Renders the auto-grid geometry editor with sample values for previews.
@Preview(name: 'Component auto-grid geometry editor')
Widget componentAutoGridGeometryEditorPreview() {
  final component = ComponentData.create(
    id: 'preview-auto-grid-button',
    type: ComponentType.customButton,
    position: const Offset(110, 110),
    size: const Size(100, 100),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentAutoGridGeometryEditor(
                component: component,
                config: const LayoutConfig(
                  layoutMechanism: LayoutMechanism.autoGrid,
                  canvasWidth: 430,
                  canvasHeight: 430,
                  minComponentWidth: 40,
                  minComponentHeight: 40,
                  autoGridColumnCount: 4,
                  autoGridGap: 10,
                  autoGridRowHeight: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
