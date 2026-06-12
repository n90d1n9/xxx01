import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';
import 'inventory_product_catalog_table_control_icons.dart';

class InventoryProductCatalogTablePresetButton extends StatelessWidget {
  const InventoryProductCatalogTablePresetButton({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<InventoryProductCatalogTablePreset> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<InventoryProductCatalogTablePreset>(
      tooltip: 'Apply table preset',
      icon: const Icon(Icons.view_agenda_rounded),
      itemBuilder:
          (context) => [
            for (final preset in InventoryProductCatalogTablePreset.values)
              PopupMenuItem(
                key: ValueKey('inventory-product-table-preset-${preset.name}'),
                value: preset,
                child: _TablePresetMenuItem(preset: preset),
              ),
          ],
      onSelected: onSelected,
    );
  }
}

class _TablePresetMenuItem extends StatelessWidget {
  const _TablePresetMenuItem({required this.preset});

  final InventoryProductCatalogTablePreset preset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          inventoryProductCatalogTablePresetIcon(preset),
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
