import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_view_mode.dart';

class InventoryProductCatalogPresentationBadge extends StatelessWidget {
  const InventoryProductCatalogPresentationBadge({
    super.key,
    required this.presentationState,
    this.maxWidth = 150,
  });

  final InventoryProductCatalogPresentationState presentationState;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preset = presentationState.matchingPreset;
    final custom = preset == null;
    final color = custom ? colorScheme.tertiary : colorScheme.primary;

    return AppStatusPill(
      label: _presentationLabel(presentationState),
      tooltip: _presentationTooltip(presentationState),
      icon:
          preset == null
              ? inventoryProductCatalogPresentationModeIcon(
                presentationState.viewMode,
              )
              : inventoryProductCatalogPresentationPresetIcon(preset),
      color: color,
      maxWidth: maxWidth,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    );
  }
}

IconData inventoryProductCatalogPresentationPresetIcon(
  InventoryProductCatalogPresentationPreset preset,
) {
  switch (preset) {
    case InventoryProductCatalogPresentationPreset.cards:
      return Icons.view_agenda_rounded;
    case InventoryProductCatalogPresentationPreset.operationsTable:
      return Icons.table_rows_rounded;
    case InventoryProductCatalogPresentationPreset.stockControl:
      return Icons.inventory_rounded;
    case InventoryProductCatalogPresentationPreset.pricing:
      return Icons.sell_rounded;
    case InventoryProductCatalogPresentationPreset.channelSignals:
      return Icons.hub_rounded;
  }
}

IconData inventoryProductCatalogPresentationModeIcon(
  InventoryProductCatalogViewMode viewMode,
) {
  switch (viewMode) {
    case InventoryProductCatalogViewMode.cards:
      return Icons.view_agenda_rounded;
    case InventoryProductCatalogViewMode.table:
      return Icons.table_rows_rounded;
  }
}

String _presentationLabel(InventoryProductCatalogPresentationState state) {
  final preset = state.matchingPreset;
  if (preset != null) return 'View: ${preset.label}';

  switch (state.viewMode) {
    case InventoryProductCatalogViewMode.cards:
      return 'Custom view';
    case InventoryProductCatalogViewMode.table:
      return 'Custom table';
  }
}

String _presentationTooltip(InventoryProductCatalogPresentationState state) {
  final preset = state.matchingPreset;
  if (preset != null) return preset.description;

  switch (state.viewMode) {
    case InventoryProductCatalogViewMode.cards:
      return 'Custom catalog presentation';
    case InventoryProductCatalogViewMode.table:
      return 'Custom table columns, density, or sorting';
  }
}
