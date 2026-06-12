import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_canvas_placement_action_service.dart';
import '../services/layout_selection_geometry_action_service.dart';
import '../services/layout_selection_geometry_metrics_service.dart';
import 'component_inspector_controls.dart';
import 'number_field.dart';

/// Edits generic geometry and arrangement actions for a multi-component selection.
class ComponentSelectionGeometryEditor extends ConsumerWidget {
  final List<ComponentData> components;
  final LayoutConfig config;

  const ComponentSelectionGeometryEditor({
    super.key,
    required this.components,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = layoutSelectionGeometryMetricsService.geometryFor(
      components,
    );
    if (metrics == null) return const SizedBox.shrink();

    final notifier = ref.read(layoutStateProvider.notifier);
    final selectedComponent = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponent),
    );
    final referenceComponent =
        selectedComponent != null &&
                components.any(
                  (component) => component.id == selectedComponent.id,
                )
            ? selectedComponent
            : components.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComponentInspectorSectionHeader(
          title: 'Selection position',
          resetTooltip: 'Move selected components to origin',
          onReset:
              metrics.canMoveToOrigin
                  ? () => layoutCanvasPlacementActionService
                      .moveSelectionToOrigin(context, ref)
                  : null,
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey('selection-x-${metrics.bounds.left.round()}'),
            label: 'X',
            value: metrics.bounds.left,
            onChanged: (value) {
              notifier.moveSelectedComponents(
                Offset(value - metrics.bounds.left, 0),
              );
            },
          ),
          second: NumberField(
            key: ValueKey('selection-y-${metrics.bounds.top.round()}'),
            label: 'Y',
            value: metrics.bounds.top,
            onChanged: (value) {
              notifier.moveSelectedComponents(
                Offset(0, value - metrics.bounds.top),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ComponentInspectorSectionHeader(
          title: 'Selection size',
          resetTooltip: 'Reset selected components to default sizes',
          onReset:
              metrics.canResetDefaultSizes
                  ? notifier.resetSelectedComponentsToDefaultSize
                  : null,
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey(
              'selection-width-${metrics.sharedWidth?.round() ?? referenceComponent.size.width.round()}',
            ),
            label: 'W',
            value: metrics.sharedWidth ?? referenceComponent.size.width,
            min: config.minComponentWidth,
            step: config.gridSize,
            onChanged:
                (value) => notifier.resizeSelectedComponents(width: value),
          ),
          second: NumberField(
            key: ValueKey(
              'selection-height-${metrics.sharedHeight?.round() ?? referenceComponent.size.height.round()}',
            ),
            label: 'H',
            value: metrics.sharedHeight ?? referenceComponent.size.height,
            min: config.minComponentHeight,
            step: config.gridSize,
            onChanged:
                (value) => notifier.resizeSelectedComponents(height: value),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GeometryActionButton(
              icon: Icons.swap_horiz,
              label: 'Match W',
              onPressed:
                  () => layoutSelectionGeometryActionService.matchSelectionSize(
                    context,
                    ref,
                    matchHeight: false,
                  ),
            ),
            _GeometryActionButton(
              icon: Icons.swap_vert,
              label: 'Match H',
              onPressed:
                  () => layoutSelectionGeometryActionService.matchSelectionSize(
                    context,
                    ref,
                    matchWidth: false,
                  ),
            ),
            _GeometryActionButton(
              icon: Icons.aspect_ratio,
              label: 'Match size',
              onPressed:
                  () => layoutSelectionGeometryActionService.matchSelectionSize(
                    context,
                    ref,
                  ),
            ),
            _GeometryActionButton(
              icon: Icons.restart_alt,
              label: 'Reset',
              onPressed:
                  metrics.canResetDefaultSizes
                      ? notifier.resetSelectedComponentsToDefaultSize
                      : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Stack selection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GeometryActionButton(
              icon: Icons.view_column,
              label: 'Stack row',
              onPressed:
                  () => layoutSelectionGeometryActionService.stackSelection(
                    context,
                    ref,
                    ComponentDistribution.horizontal,
                  ),
            ),
            _GeometryActionButton(
              icon: Icons.view_stream,
              label: 'Stack column',
              onPressed:
                  () => layoutSelectionGeometryActionService.stackSelection(
                    context,
                    ref,
                    ComponentDistribution.vertical,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Selection spacing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ComponentInspectorFieldPair(
          first: NumberField(
            key: ValueKey('selection-h-gap-${metrics.horizontalGap.round()}'),
            label: 'H',
            value: metrics.horizontalGap,
            min: 0,
            step: config.gridSize,
            onChanged:
                (value) => layoutSelectionGeometryActionService.spaceSelection(
                  context,
                  ref,
                  ComponentDistribution.horizontal,
                  value,
                ),
          ),
          second: NumberField(
            key: ValueKey('selection-v-gap-${metrics.verticalGap.round()}'),
            label: 'V',
            value: metrics.verticalGap,
            min: 0,
            step: config.gridSize,
            onChanged:
                (value) => layoutSelectionGeometryActionService.spaceSelection(
                  context,
                  ref,
                  ComponentDistribution.vertical,
                  value,
                ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Align and distribute',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GeometryToolButton(
              icon: Icons.format_align_left,
              tooltip: 'Align left',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.left,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.align_horizontal_center,
              tooltip: 'Align center',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.center,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.format_align_right,
              tooltip: 'Align right',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.right,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.vertical_align_top,
              tooltip: 'Align top',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.top,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.vertical_align_center,
              tooltip: 'Align middle',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.middle,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.vertical_align_bottom,
              tooltip: 'Align bottom',
              onPressed:
                  () => layoutSelectionGeometryActionService.alignSelection(
                    context,
                    ref,
                    ComponentAlignment.bottom,
                  ),
            ),
            _GeometryToolButton(
              icon: Icons.horizontal_distribute,
              tooltip: 'Center selection horizontally on canvas',
              onPressed:
                  () => layoutCanvasPlacementActionService
                      .centerSelectionOnCanvas(context, ref, vertical: false),
            ),
            _GeometryToolButton(
              icon: Icons.vertical_distribute,
              tooltip: 'Center selection vertically on canvas',
              onPressed:
                  () => layoutCanvasPlacementActionService
                      .centerSelectionOnCanvas(context, ref, horizontal: false),
            ),
            _GeometryToolButton(
              icon: Icons.center_focus_weak,
              tooltip: 'Center selection on canvas',
              onPressed:
                  () => layoutCanvasPlacementActionService
                      .centerSelectionOnCanvas(context, ref),
            ),
            _GeometryToolButton(
              icon: Icons.more_horiz,
              tooltip: 'Distribute horizontally',
              onPressed:
                  components.length < 3
                      ? null
                      : () => layoutSelectionGeometryActionService
                          .distributeSelection(
                            context,
                            ref,
                            ComponentDistribution.horizontal,
                          ),
            ),
            _GeometryToolButton(
              icon: Icons.more_vert,
              tooltip: 'Distribute vertically',
              onPressed:
                  components.length < 3
                      ? null
                      : () => layoutSelectionGeometryActionService
                          .distributeSelection(
                            context,
                            ref,
                            ComponentDistribution.vertical,
                          ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Displays a labeled action button for selection geometry commands.
class _GeometryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _GeometryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

/// Displays an icon-only button for compact selection geometry commands.
class _GeometryToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _GeometryToolButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

/// Renders the selection geometry editor with sample selected components.
@Preview(name: 'Component selection geometry editor')
Widget componentSelectionGeometryEditorPreview() {
  final components = [
    ComponentData.create(
      id: 'preview-selection-geometry-a',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(120, 56),
    ),
    ComponentData.create(
      id: 'preview-selection-geometry-b',
      type: ComponentType.customButton,
      position: const Offset(180, 20),
      size: const Size(120, 56),
    ),
    ComponentData.create(
      id: 'preview-selection-geometry-c',
      type: ComponentType.customButton,
      position: const Offset(340, 20),
      size: const Size(120, 56),
    ),
  ];

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ComponentSelectionGeometryEditor(
                components: components,
                config: const LayoutConfig(
                  canvasWidth: 520,
                  canvasHeight: 320,
                  minComponentWidth: 40,
                  minComponentHeight: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
