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

/// Edits tabular-rule position and cleanup actions for a multi-component selection.
class ComponentTabularSelectionEditor extends ConsumerWidget {
  final List<ComponentData> components;
  final LayoutConfig config;

  const ComponentTabularSelectionEditor({
    super.key,
    required this.components,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final layoutState = ref.watch(layoutStateProvider);
    final visibleComponents =
        components.where((component) => component.isVisible).toList();
    final movableComponents =
        visibleComponents.where((component) => !component.isLocked).toList();
    final metrics = layoutRuleGeometryService.tabularSelectionMetricsFor(
      visibleComponents,
      config,
    );
    final editableMetrics = layoutRuleGeometryService
        .tabularSelectionMetricsFor(movableComponents, config);
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
      config.gridSize,
    );
    final visibleSnapStatus = layoutRuleGeometryService.snapStatusFor(
      visibleMovableComponents,
      config,
      config.gridSize,
    );
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final hiddenCount =
        components.where((component) => !component.isVisible).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tabular selection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (metrics != null) ...[
              ComponentInspectorChip(
                icon: Icons.view_column_outlined,
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
                'tabular-selection-start-column-${editableMetrics.startColumn}',
              ),
              label: 'Start col',
              value: editableMetrics.startColumn.toDouble(),
              min: 1,
              max: config.tabularColumnCount.toDouble(),
              onChanged:
                  (value) =>
                      notifier.moveSelectedToTabularColumn(value.round()),
            ),
            second: NumberField(
              key: ValueKey(
                'tabular-selection-start-row-${editableMetrics.startRow}',
              ),
              label: 'Start row',
              value: editableMetrics.startRow.toDouble(),
              min: 1,
              onChanged:
                  (value) => notifier.moveSelectedToTabularRow(value.round()),
            ),
          ),
          const SizedBox(height: 8),
          LayoutRuleNudgeControls(
            columnUnitLabel: 'tabular column',
            rowUnitLabel: 'tabular row',
            canMoveLeft: editableMetrics.startColumn > 1,
            canMoveRight: editableMetrics.endColumn < config.tabularColumnCount,
            canMoveUp: editableMetrics.startRow > 1,
            canMoveDown: true,
            onMoveLeft: () => notifier.nudgeSelectedByTabularColumns(-1),
            onMoveRight: () => notifier.nudgeSelectedByTabularColumns(1),
            onMoveUp: () => notifier.nudgeSelectedByTabularRows(-1),
            onMoveDown: () => notifier.nudgeSelectedByTabularRows(1),
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

/// Renders the tabular selection editor with sample selected components.
@Preview(name: 'Component tabular selection editor')
Widget componentTabularSelectionEditorPreview() {
  final components = [
    ComponentData.create(
      id: 'preview-tabular-selection-a',
      type: ComponentType.customButton,
      position: const Offset(110, 40),
      size: const Size(100, 40),
    ),
    ComponentData.create(
      id: 'preview-tabular-selection-b',
      type: ComponentType.customButton,
      position: const Offset(220, 40),
      size: const Size(100, 40),
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
              child: ComponentTabularSelectionEditor(
                components: components,
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
