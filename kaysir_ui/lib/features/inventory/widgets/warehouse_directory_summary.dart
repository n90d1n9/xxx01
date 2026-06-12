import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/warehouse.dart';
import 'warehouse_directory_preview_data.dart';

/// Warehouse identity summary for directory tiles and list previews.
class InventoryWarehouseDirectorySummary extends StatelessWidget {
  const InventoryWarehouseDirectorySummary({
    super.key,
    required this.warehouse,
  });

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final description = (warehouse.description ?? '').trim();

    return AppInfoRow(
      icon: Icons.warehouse_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: warehouse.name,
      subtitle:
          description.isEmpty
              ? '${warehouse.branchLabel} | ${warehouse.location} | No operational notes'
              : '${warehouse.branchLabel} | ${warehouse.location} | $description',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}

@Preview(name: 'Warehouse directory summary')
Widget inventoryWarehouseDirectorySummaryPreview() {
  return inventoryWarehouseDirectoryPreviewScaffold(
    InventoryWarehouseDirectorySummary(
      warehouse: inventoryWarehouseDirectoryPreviewWarehouse(),
    ),
  );
}
