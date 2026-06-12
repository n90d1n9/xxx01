import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'product_catalog_preview_data.dart';

/// Section heading for grouped saved product catalog views.
class InventoryProductCatalogSavedViewMenuSectionHeader
    extends StatelessWidget {
  const InventoryProductCatalogSavedViewMenuSectionHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

@Preview(name: 'Inventory product catalog saved view section header')
Widget inventoryProductCatalogSavedViewMenuSectionHeaderPreview() {
  return inventoryProductCatalogPreviewScaffold(
    const InventoryProductCatalogSavedViewMenuSectionHeader(label: 'My views'),
  );
}
