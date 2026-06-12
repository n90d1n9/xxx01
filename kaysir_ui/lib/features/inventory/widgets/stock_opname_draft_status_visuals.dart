import 'package:flutter/material.dart';

import 'inventory_stock_opname_draft_status_details.dart';

/// Resolves the banner accent color from the stock opname draft state.
Color inventoryStockOpnameDraftAccentColor(
  ColorScheme colorScheme,
  InventoryStockOpnameDraftStatusDetails details,
) {
  return details.hasInvalidDrafts ? colorScheme.error : colorScheme.tertiary;
}

/// Resolves the subtle banner background from the stock opname draft state.
Color inventoryStockOpnameDraftBackgroundColor(
  ColorScheme colorScheme,
  InventoryStockOpnameDraftStatusDetails details,
) {
  return details.hasInvalidDrafts
      ? colorScheme.errorContainer.withValues(alpha: 0.42)
      : colorScheme.tertiaryContainer.withValues(alpha: 0.42);
}

/// Resolves the icon used for a stock opname draft status badge.
IconData inventoryStockOpnameDraftBadgeIcon(
  InventoryStockOpnameDraftStatusBadgeTone tone,
) {
  switch (tone) {
    case InventoryStockOpnameDraftStatusBadgeTone.edited:
      return Icons.mode_edit_outline_rounded;
    case InventoryStockOpnameDraftStatusBadgeTone.invalid:
      return Icons.error_outline_rounded;
  }
}

/// Resolves the color used for a stock opname draft status badge.
Color inventoryStockOpnameDraftBadgeColor(
  ColorScheme colorScheme,
  InventoryStockOpnameDraftStatusBadgeTone tone,
) {
  switch (tone) {
    case InventoryStockOpnameDraftStatusBadgeTone.edited:
      return colorScheme.tertiary;
    case InventoryStockOpnameDraftStatusBadgeTone.invalid:
      return colorScheme.error;
  }
}
