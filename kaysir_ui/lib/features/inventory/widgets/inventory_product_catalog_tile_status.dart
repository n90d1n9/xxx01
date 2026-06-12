import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_visuals.dart';

class InventoryProductCatalogTileStatus extends StatelessWidget {
  const InventoryProductCatalogTileStatus({super.key, required this.record});

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    final statusVisuals = inventoryProductCatalogStatusVisuals(record.status);

    return AppStatusPill(
      label: inventoryProductCatalogStatusLabel(record.status),
      icon: statusVisuals.icon,
      color: statusVisuals.color,
      maxWidth: 130,
    );
  }
}
