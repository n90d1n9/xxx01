import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../provider/layout_state_provider.dart';
import '../services/layout_selection_geometry_metrics_service.dart';
import 'component_inspector_controls.dart';
import 'dialog_utils.dart';

/// Summarizes the selected components with bounds and visibility state.
class ComponentSelectionSummaryCard extends StatelessWidget {
  final List<ComponentData> components;

  const ComponentSelectionSummaryCard({super.key, required this.components});

  @override
  Widget build(BuildContext context) {
    final metrics = layoutSelectionGeometryMetricsService.geometryFor(
      components,
    );
    final bounds = metrics?.bounds ?? Rect.zero;
    final hiddenCount =
        components.where((component) => !component.isVisible).length;
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${bounds.left.round()}, ${bounds.top.round()} - ${bounds.width.round()}x${bounds.height.round()}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ComponentInspectorChip(
                  icon: Icons.layers_outlined,
                  label: '${components.length} layers',
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
          ],
        ),
      ),
    );
  }
}

/// Runs broad selection operations such as duplicate, group, lock, hide, and delete.
class ComponentSelectionBulkActionsEditor extends ConsumerWidget {
  final List<ComponentData> components;

  const ComponentSelectionBulkActionsEditor({
    super.key,
    required this.components,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final hiddenCount =
        components.where((component) => !component.isVisible).length;
    final lockedCount =
        components.where((component) => component.isLocked).length;
    final shouldShow = hiddenCount > 0;
    final shouldLock = lockedCount < components.length;
    final groupIds =
        components
            .map((component) => component.properties.parentId)
            .whereType<String>()
            .toSet();
    final isSingleGroupSelection =
        groupIds.length == 1 &&
        components.length > 1 &&
        components.every(
          (component) => component.properties.parentId == groupIds.first,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bulk actions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SelectionManagementButton(
              icon: Icons.control_point_duplicate,
              label: 'Duplicate',
              onPressed: notifier.duplicateSelectedComponent,
            ),
            _SelectionManagementButton(
              icon: Icons.bookmark_add_outlined,
              label: 'Save preset',
              onPressed:
                  () => showSaveSelectionPresetDialog(context, ref, components),
            ),
            _SelectionManagementButton(
              icon:
                  isSingleGroupSelection
                      ? Icons.call_split_outlined
                      : Icons.group_work_outlined,
              label: isSingleGroupSelection ? 'Ungroup' : 'Group',
              onPressed:
                  isSingleGroupSelection
                      ? notifier.ungroupSelectedComponents
                      : notifier.groupSelectedComponents,
            ),
            _SelectionManagementButton(
              icon: shouldLock ? Icons.lock : Icons.lock_open_outlined,
              label: shouldLock ? 'Lock all' : 'Unlock all',
              onPressed: notifier.toggleSelectedComponentLock,
            ),
            _SelectionManagementButton(
              icon:
                  shouldShow
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
              label: shouldShow ? 'Show all' : 'Hide all',
              onPressed: notifier.toggleSelectedComponentVisibility,
            ),
            _SelectionManagementButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onPressed: notifier.removeSelectedComponent,
            ),
          ],
        ),
      ],
    );
  }
}

/// Lists selected component layers with compact geometry hints.
class ComponentSelectionLayersList extends StatelessWidget {
  final List<ComponentData> components;
  final int maxVisibleCount;

  const ComponentSelectionLayersList({
    super.key,
    required this.components,
    this.maxVisibleCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleComponents = components.take(maxVisibleCount);
    final overflowCount = components.length - maxVisibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected layers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final component in visibleComponents)
          _SelectedLayerRow(component: component),
        if (overflowCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+$overflowCount more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Displays one labeled selection management action.
class _SelectionManagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SelectionManagementButton({
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

/// Displays one selected layer row.
class _SelectedLayerRow extends StatelessWidget {
  final ComponentData component;

  const _SelectedLayerRow({required this.component});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(component.type.icon, size: 20),
      title: Text(
        _componentDisplayName(component),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${component.position.dx.round()}, ${component.position.dy.round()} - ${component.size.width.round()}x${component.size.height.round()}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Renders the selection summary card with sample component bounds.
@Preview(name: 'Component selection summary card')
Widget componentSelectionSummaryCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ComponentSelectionSummaryCard(
              components: _previewSelectionComponents(),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Renders the selection bulk actions with sample selected components.
@Preview(name: 'Component selection bulk actions')
Widget componentSelectionBulkActionsEditorPreview() {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ComponentSelectionBulkActionsEditor(
                components: _previewSelectionComponents(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Renders the selected layers list with sample selected components.
@Preview(name: 'Component selection layers list')
Widget componentSelectionLayersListPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ComponentSelectionLayersList(
              components: _previewSelectionComponents(),
            ),
          ),
        ),
      ),
    ),
  );
}

List<ComponentData> _previewSelectionComponents() {
  return [
    ComponentData.create(
      id: 'preview-selection-layer-a',
      type: ComponentType.customButton,
      position: const Offset(20, 20),
      size: const Size(160, 56),
    ),
    ComponentData.create(
      id: 'preview-selection-layer-b',
      type: ComponentType.textLabel,
      position: const Offset(220, 20),
      size: const Size(180, 48),
    ).copyWith(isLocked: true),
    ComponentData.create(
      id: 'preview-selection-layer-c',
      type: ComponentType.imageHolder,
      position: const Offset(20, 96),
      size: const Size(180, 120),
    ).copyWith(isVisible: false),
  ];
}

String _componentDisplayName(ComponentData component) {
  final attributes = component.properties.attributes;
  final customName =
      attributes['name'] ?? attributes['label'] ?? attributes['text'];

  if (customName is String && customName.trim().isNotEmpty) {
    return customName.trim();
  }

  return component.type.label;
}
