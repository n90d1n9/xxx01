import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/component.dart';
import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import '../provider/responsive_preview_provider.dart';
import 'component_auto_grid_selection_editor.dart';
import 'component_grid_selection_editor.dart';
import 'component_selection_geometry_editor.dart';
import 'component_selection_management_panels.dart';
import 'component_selection_responsive_override_editor.dart';
import 'component_single_property_editor.dart';
import 'component_tabular_selection_editor.dart';
import 'layout_diagnostics_panel.dart';

/// Edits properties for the current layout-builder component selection.
class ComponentPropertyEditor extends ConsumerWidget {
  const ComponentPropertyEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponents = ref.watch(
      layoutStateProvider.select((state) => state.selectedComponents),
    );

    if (selectedComponents.isEmpty) {
      return const SizedBox(
        width: 320,
        child: Center(child: Text('No component selected')),
      );
    }

    if (selectedComponents.length > 1) {
      return _MultiSelectionPropertyEditor(components: selectedComponents);
    }

    final selectedComponent = selectedComponents.single;
    final previewState = ref.watch(responsivePreviewProvider);
    final layoutConfig = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );
    final gridSettings = ref.watch(
      layoutStateProvider.select((state) => state.gridSettings),
    );

    return SizedBox(
      width: 320,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 2,
        child: ComponentSinglePropertyEditor(
          component: selectedComponent,
          previewState: previewState,
          config: layoutConfig,
          gridSize: gridSettings.gridSize,
        ),
      ),
    );
  }
}

class _MultiSelectionPropertyEditor extends ConsumerWidget {
  final List<ComponentData> components;

  const _MultiSelectionPropertyEditor({required this.components});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(layoutStateProvider.notifier);
    final layoutConfig = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );
    final gridSettings = ref.watch(
      layoutStateProvider.select((state) => state.gridSettings),
    );
    final previewState = ref.watch(responsivePreviewProvider);
    final selectedIds = components.map((component) => component.id).toSet();

    return SizedBox(
      width: 320,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 2,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Icon(Icons.select_all_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${components.length} components selected',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear selection',
                  icon: const Icon(Icons.close),
                  onPressed: notifier.clearSelection,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ComponentSelectionSummaryCard(components: components),
            SelectionDiagnosticsCard(componentIds: selectedIds),
            const SizedBox(height: 16),
            ComponentSelectionGeometryEditor(
              components: components,
              config: layoutConfig,
            ),
            if (layoutConfig.layoutMechanism == LayoutMechanism.grid) ...[
              const SizedBox(height: 16),
              ComponentGridSelectionEditor(
                components: components,
                config: layoutConfig,
                gridSize: gridSettings.gridSize,
              ),
            ],
            if (layoutConfig.layoutMechanism ==
                LayoutMechanism.tabularColumns) ...[
              const SizedBox(height: 16),
              ComponentTabularSelectionEditor(
                components: components,
                config: layoutConfig,
              ),
            ],
            if (layoutConfig.layoutMechanism == LayoutMechanism.autoGrid) ...[
              const SizedBox(height: 16),
              ComponentAutoGridSelectionEditor(
                components: components,
                config: layoutConfig,
              ),
            ],
            const SizedBox(height: 16),
            ComponentSelectionResponsiveOverrideEditor(
              components: components,
              previewState: previewState,
            ),
            const SizedBox(height: 16),
            ComponentSelectionBulkActionsEditor(components: components),
            const SizedBox(height: 16),
            ComponentSelectionLayersList(components: components),
          ],
        ),
      ),
    );
  }
}
