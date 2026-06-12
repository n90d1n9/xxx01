import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_session.dart';

/// Visual colors that communicate a stock opname row's reconciliation state.
class InventoryStockOpnameLineTone {
  const InventoryStockOpnameLineTone({
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
  });

  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
}

/// Resolves subtle row colors for matched, overage, and shortage count lines.
InventoryStockOpnameLineTone inventoryStockOpnameLineTone(
  BuildContext context,
  InventoryStockOpnameLine line,
) {
  final accent = _inventoryStockOpnameLineAccentColor(context, line);

  return InventoryStockOpnameLineTone(
    accentColor: accent,
    backgroundColor: accent.withValues(alpha: 0.06),
    borderColor: accent.withValues(alpha: 0.24),
    iconBackgroundColor: accent.withValues(alpha: 0.12),
  );
}

Color _inventoryStockOpnameLineAccentColor(
  BuildContext context,
  InventoryStockOpnameLine line,
) {
  if (line.discrepancy < 0) return Theme.of(context).colorScheme.error;
  if (line.discrepancy > 0) return Colors.orange.shade700;
  return Colors.green.shade700;
}
