import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_stock_opname_session.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_stock_opname_line_tone.dart';
import 'stock_opname_line_preview_data.dart';

/// Product identity block for a stock opname worksheet row.
///
/// The widget keeps product, SKU, system count, and tone-aware badge styling in
/// one small unit so the editable row can focus on layout and input wiring.
class InventoryStockOpnameLineIdentity extends StatelessWidget {
  const InventoryStockOpnameLineIdentity({
    super.key,
    required this.line,
    this.tone,
  });

  final InventoryStockOpnameLine line;
  final InventoryStockOpnameLineTone? tone;

  @override
  Widget build(BuildContext context) {
    final resolvedTone = tone ?? inventoryStockOpnameLineTone(context, line);

    return AppInfoRow(
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: resolvedTone.iconBackgroundColor,
      iconForegroundColor: resolvedTone.accentColor,
      title: line.productName,
      subtitle:
          '${line.skuLabel} | System ${formatInventoryNumber(line.systemQuantity)} units',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}

@Preview(name: 'Inventory stock opname line identity')
Widget inventoryStockOpnameLineIdentityPreview() {
  return inventoryStockOpnameLinePreviewScaffold(
    InventoryStockOpnameLineIdentity(line: inventoryStockOpnamePreviewLine()),
  );
}
