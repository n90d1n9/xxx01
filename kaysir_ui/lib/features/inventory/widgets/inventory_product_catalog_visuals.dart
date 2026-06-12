import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import '../utils/inventory_formatters.dart';

class InventoryProductCatalogStatusVisuals {
  const InventoryProductCatalogStatusVisuals({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

InventoryProductCatalogStatusVisuals inventoryProductCatalogStatusVisuals(
  InventoryProductCatalogStatus status,
) {
  switch (status) {
    case InventoryProductCatalogStatus.untracked:
      return InventoryProductCatalogStatusVisuals(
        icon: Icons.visibility_off_rounded,
        color: Colors.blueGrey.shade700,
      );
    case InventoryProductCatalogStatus.outOfStock:
      return InventoryProductCatalogStatusVisuals(
        icon: Icons.remove_shopping_cart_rounded,
        color: Colors.red.shade700,
      );
    case InventoryProductCatalogStatus.lowStock:
      return InventoryProductCatalogStatusVisuals(
        icon: Icons.warning_amber_rounded,
        color: Colors.orange.shade700,
      );
    case InventoryProductCatalogStatus.inStock:
      return InventoryProductCatalogStatusVisuals(
        icon: Icons.check_circle_rounded,
        color: Colors.green.shade700,
      );
  }
}

String inventoryProductCatalogRepairTargetButtonLabel(
  InventoryProductCatalogRepairTarget target,
  int count,
) {
  final issueLabel = switch (target) {
    InventoryProductCatalogRepairTarget.anyQualityIssue =>
      count == 1 ? 'Quality issue' : 'Quality issues',
    InventoryProductCatalogRepairTarget.missingSku =>
      count == 1 ? 'Missing SKU' : 'Missing SKUs',
    InventoryProductCatalogRepairTarget.missingCategory =>
      count == 1 ? 'Missing category' : 'Missing categories',
    InventoryProductCatalogRepairTarget.missingDescription =>
      count == 1 ? 'Missing description' : 'Missing descriptions',
    InventoryProductCatalogRepairTarget.missingPrice =>
      count == 1 ? 'Missing price' : 'Missing prices',
    InventoryProductCatalogRepairTarget.missingScanCode =>
      count == 1 ? 'Missing scan code' : 'Missing scan codes',
  };

  return '$issueLabel (${formatInventoryNumber(count)})';
}

IconData inventoryProductCatalogRepairTargetIcon(
  InventoryProductCatalogRepairTarget target,
) {
  return switch (target) {
    InventoryProductCatalogRepairTarget.anyQualityIssue =>
      Icons.auto_fix_high_rounded,
    InventoryProductCatalogRepairTarget.missingSku => Icons.tag_rounded,
    InventoryProductCatalogRepairTarget.missingCategory =>
      Icons.category_rounded,
    InventoryProductCatalogRepairTarget.missingDescription =>
      Icons.notes_rounded,
    InventoryProductCatalogRepairTarget.missingPrice => Icons.sell_rounded,
    InventoryProductCatalogRepairTarget.missingScanCode =>
      Icons.qr_code_scanner_rounded,
  };
}
