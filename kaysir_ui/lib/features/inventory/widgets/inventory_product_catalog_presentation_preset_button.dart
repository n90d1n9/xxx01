import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_presentation_state.dart';
import 'inventory_product_catalog_presentation_badge.dart';

class InventoryProductCatalogPresentationPresetButton extends StatelessWidget {
  const InventoryProductCatalogPresentationPresetButton({
    super.key,
    required this.presentationState,
    required this.onPresetSelected,
    this.tooltip = 'Apply catalog view preset',
    this.size = 34,
    this.iconSize = 18,
  });

  final InventoryProductCatalogPresentationState presentationState;
  final ValueChanged<InventoryProductCatalogPresentationPreset>
  onPresetSelected;
  final String tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<InventoryProductCatalogPresentationPreset>(
      tooltip: tooltip,
      initialValue: presentationState.matchingPreset,
      padding: EdgeInsets.zero,
      itemBuilder:
          (context) => [
            for (final preset
                in InventoryProductCatalogPresentationPreset.values)
              PopupMenuItem(
                key: ValueKey(
                  'inventory-product-catalog-presentation-preset-${preset.key}',
                ),
                value: preset,
                child: _CatalogPresentationPresetMenuItem(preset: preset),
              ),
          ],
      onSelected: onPresetSelected,
      child: SizedBox.square(
        dimension: size,
        child: Icon(Icons.space_dashboard_rounded, size: iconSize),
      ),
    );
  }
}

class _CatalogPresentationPresetMenuItem extends StatelessWidget {
  const _CatalogPresentationPresetMenuItem({required this.preset});

  final InventoryProductCatalogPresentationPreset preset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          inventoryProductCatalogPresentationPresetIcon(preset),
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                preset.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                preset.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
