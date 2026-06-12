import 'package:flutter/material.dart';

import '../models/inventory_product_catalog_table_preferences.dart';

class InventoryProductCatalogTableOptionalColumnButton extends StatelessWidget {
  const InventoryProductCatalogTableOptionalColumnButton({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  final InventoryProductCatalogTablePreferences preferences;
  final ValueChanged<InventoryProductCatalogTableOptionalColumn> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<InventoryProductCatalogTableOptionalColumn>(
      tooltip: 'Choose table columns',
      icon: const Icon(Icons.view_column_rounded),
      itemBuilder:
          (context) => [
            for (final column
                in InventoryProductCatalogTableOptionalColumn.values)
              CheckedPopupMenuItem(
                key: ValueKey('inventory-product-table-column-${column.name}'),
                value: column,
                checked: preferences.isVisible(column),
                child: Text(column.label),
              ),
          ],
      onSelected: onChanged,
    );
  }
}
