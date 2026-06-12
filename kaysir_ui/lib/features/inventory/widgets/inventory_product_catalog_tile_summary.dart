import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_product_catalog.dart';

class InventoryProductCatalogTileSummary extends StatelessWidget {
  const InventoryProductCatalogTileSummary({super.key, required this.record});

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: record.productName,
      subtitle:
          '${record.skuLabel} | ${record.categoryLabel} | '
          '${record.descriptionLabel}',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}
