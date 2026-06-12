import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_auto_grid_action_service.dart';
import '../services/layout_rule_geometry_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import 'component_inspector_controls.dart';
import 'layout_rule_controls.dart';
import 'number_field.dart';

/// Edits auto-grid position, cleanup, and conflict actions for a multi-component selection.
class ComponentAutoGridSelectionEditor extends ConsumerWidget {
  final List<ComponentData> components;
  final LayoutConfig config;

  const ComponentAutoGridSelectionEditor({
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
    final metrics = layoutRuleGeometryService.autoGridSelectionMetricsFor(
      visibleComponents,
      config,
    );
    final editableMetrics = layoutRuleGeometryService
        .autoGridSelectionMetricsFor(movableComponents, config);
    final selectedVisibleCount = visibleComponents.length;
    final selectedMovableCount = movableComponents.length;
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final hiddenCount =
        components.where((component) => !component.isVisible).length;
    final visibleConflictCount =
        notifier.visibleAutoGridConflictComponentIds().length;
    final visibleMovableCount =
        layoutState.components
            .where((component) => component.isVisible && !component.isLocked)
            .length;
    final selectedSnapStatus = layoutRuleGeometryService.snapStatusFor(
      movableComponents,
      config,
      config.gridSize,
    );
    final visibleSnapStatus = layoutRuleGeometryService.snapStatusFor(
      layoutState.components,
      config,
      config.gridSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auto Grid selection',
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
                'auto-grid-selection-start-column-${editableMetrics.startColumn}',
              ),
              label: 'Start col',
              value: editableMetrics.startColumn.toDouble(),
              min: 1,
              max: config.autoGridColumnCount.toDouble(),
              onChanged:
                  (value) =>
                      notifier.moveSelectedToAutoGridColumn(value.round()),
            ),
            second: NumberField(
              key: ValueKey(
                'auto-grid-selection-start-row-${editableMetrics.startRow}',
              ),
              label: 'Start row',
              value: editableMetrics.startRow.toDouble(),
              min: 1,
              onChanged:
                  (value) => notifier.moveSelectedToAutoGridRow(value.round()),
            ),
          ),
          const SizedBox(height: 8),
          LayoutRuleNudgeControls(
            columnUnitLabel: 'Auto Grid column',
            rowUnitLabel: 'Auto Grid row',
            canMoveLeft: editableMetrics.startColumn > 1,
            canMoveRight:
                editableMetrics.endColumn < config.autoGridColumnCount,
            canMoveUp: editableMetrics.startRow > 1,
            canMoveDown: true,
            onMoveLeft: () => notifier.nudgeSelectedByAutoGridColumns(-1),
            onMoveRight: () => notifier.nudgeSelectedByAutoGridColumns(1),
            onMoveUp: () => notifier.nudgeSelectedByAutoGridRows(-1),
            onMoveDown: () => notifier.nudgeSelectedByAutoGridRows(1),
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LayoutRuleActionButton(
              icon: Icons.dashboard_customize_outlined,
              label: 'Arrange',
              tooltip: 'Arrange selection into Auto Grid cells',
              onPressed:
                  selectedMovableCount > 0
                      ? () => layoutAutoGridActionService.arrangeSelection(
                        context,
                        ref,
                      )
                      : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.auto_fix_high_outlined,
              label: 'Free cells',
              tooltip: 'Move selection to free Auto Grid cells',
              onPressed:
                  selectedMovableCount > 0
                      ? () => layoutAutoGridActionService
                          .moveSelectionToFreeCells(context, ref)
                      : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.manage_search_outlined,
              label: 'Conflicts',
              tooltip: 'Select Auto Grid conflicts',
              onPressed:
                  selectedVisibleCount > 0
                      ? () => layoutAutoGridActionService
                          .selectConflictPartnersForSelection(context, ref)
                      : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.healing_outlined,
              label: 'Resolve',
              tooltip: 'Resolve visible Auto Grid conflicts',
              onPressed:
                  visibleConflictCount > 0
                      ? () => layoutAutoGridActionService
                          .resolveVisibleConflicts(context, ref)
                      : null,
            ),
            LayoutRuleActionButton(
              icon: Icons.view_module_outlined,
              label: 'Compact',
              tooltip: 'Compact visible Auto Grid components',
              onPressed:
                  visibleMovableCount > 0
                      ? () => layoutAutoGridActionService.compactVisible(
                        context,
                        ref,
                      )
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Renders the auto-grid selection editor with sample selected components.
@Preview(name: 'Component auto-grid selection editor')
Widget componentAutoGridSelectionEditorPreview() {
  final components = [
    ComponentData.create(
      id: 'preview-auto-grid-selection-a',
      type: ComponentType.customButton,
      position: const Offset(110, 110),
      size: const Size(100, 100),
    ),
    ComponentData.create(
      id: 'preview-auto-grid-selection-b',
      type: ComponentType.customButton,
      position: const Offset(220, 110),
      size: const Size(100, 100),
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
              child: ComponentAutoGridSelectionEditor(
                components: components,
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
