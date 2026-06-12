import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import '../models/product_catalog_table_column_contribution.dart';
import '../models/product_catalog_table_column_ids.dart';
import '../models/management_pack.dart';

List<ProductCatalogTableColumnContribution>
buildDefaultProductCatalogTableColumnModuleContributions() {
  return const [
    ProductCatalogTableColumnContribution(
      id: 'fresh-goods-catalog-columns',
      appliesTo: _appliesToFreshGoodsPack,
      buildColumns: _buildFreshGoodsTableColumns,
    ),
  ];
}

bool _appliesToFreshGoodsPack(
  ProductCatalogTableColumnContributionContext context,
) {
  return context.pack.id == ProductManagementPackId.groceryFreshGoods;
}

Iterable<InventoryProductCatalogTableColumnContribution>
_buildFreshGoodsTableColumns(ProductCatalogTableColumnContributionContext _) {
  return const [
    InventoryProductCatalogTableColumnContribution(
      id: productFreshGoodsFreshnessColumnId,
      label: 'Freshness',
      tooltip: 'Expiry, batch, and freshness queue readiness',
      sectionLabel: 'Fresh goods',
      priority: 15,
      defaultVisible: false,
      cellBuilder: _buildFreshGoodsFreshnessCell,
    ),
  ];
}

Widget _buildFreshGoodsFreshnessCell(
  BuildContext context,
  InventoryProductCatalogRecord record,
) {
  return ProductFreshGoodsFreshnessTableCell(record: record);
}

class ProductFreshGoodsFreshnessTableCell extends StatelessWidget {
  const ProductFreshGoodsFreshnessTableCell({
    super.key,
    required this.record,
    this.today,
    this.dueSoonDays = 3,
  }) : assert(dueSoonDays >= 0);

  final InventoryProductCatalogRecord record;
  final DateTime? today;
  final int dueSoonDays;

  @override
  Widget build(BuildContext context) {
    final signal = productFreshGoodsFreshnessSignalForRecord(
      record,
      today: today,
      dueSoonDays: dueSoonDays,
    );

    return AppStatusPill(
      label: signal.label,
      tooltip: signal.tooltip,
      color: signal.color,
      icon: signal.icon,
      maxWidth: 132,
    );
  }
}

class ProductFreshGoodsFreshnessSignal {
  const ProductFreshGoodsFreshnessSignal({
    required this.label,
    required this.tooltip,
    required this.color,
    required this.icon,
  });

  final String label;
  final String tooltip;
  final Color color;
  final IconData icon;
}

ProductFreshGoodsFreshnessSignal productFreshGoodsFreshnessSignalForRecord(
  InventoryProductCatalogRecord record, {
  DateTime? today,
  int dueSoonDays = 3,
}) {
  assert(dueSoonDays >= 0);

  final attributes = record.product.customAttributes;
  final expiryText = _attributeText(
    attributes,
    ProductManagementFieldId.expiryDate,
  );
  final batchText = _attributeText(
    attributes,
    ProductManagementFieldId.batchNumber,
  );
  final statusText = _attributeText(
    attributes,
    ProductManagementFieldId.freshnessStatus,
  );
  final tooltip = _freshnessTooltip(
    expiryText: expiryText,
    batchText: batchText,
    statusText: statusText,
  );

  final normalizedStatus = statusText.toLowerCase();
  if (normalizedStatus == 'pull') {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Pull stock',
      tooltip: tooltip,
      color: Colors.red.shade700,
      icon: Icons.remove_shopping_cart_rounded,
    );
  }

  if (expiryText.isEmpty) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'No expiry',
      tooltip: tooltip,
      color: Colors.red.shade700,
      icon: Icons.event_busy_rounded,
    );
  }

  final expiryDate = _parseDate(expiryText);
  if (expiryDate == null) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Check date',
      tooltip: tooltip,
      color: Colors.orange.shade700,
      icon: Icons.event_note_rounded,
    );
  }

  final resolvedToday = DateUtils.dateOnly(today ?? DateTime.now());
  final daysUntilExpiry = expiryDate.difference(resolvedToday).inDays;
  if (daysUntilExpiry < 0) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Expired',
      tooltip: tooltip,
      color: Colors.red.shade700,
      icon: Icons.warning_rounded,
    );
  }
  if (daysUntilExpiry == 0) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Expires today',
      tooltip: tooltip,
      color: Colors.deepOrange.shade700,
      icon: Icons.priority_high_rounded,
    );
  }
  if (normalizedStatus == 'discount') {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Discount',
      tooltip: tooltip,
      color: Colors.amber.shade800,
      icon: Icons.local_offer_rounded,
    );
  }
  if (daysUntilExpiry <= dueSoonDays) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Due soon',
      tooltip: tooltip,
      color: Colors.orange.shade700,
      icon: Icons.schedule_rounded,
    );
  }
  if (normalizedStatus == 'monitor') {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Monitor',
      tooltip: tooltip,
      color: Colors.blue.shade700,
      icon: Icons.visibility_rounded,
    );
  }
  if (batchText.isEmpty) {
    return ProductFreshGoodsFreshnessSignal(
      label: 'Add batch',
      tooltip: tooltip,
      color: Colors.teal.shade700,
      icon: Icons.qr_code_2_rounded,
    );
  }

  return ProductFreshGoodsFreshnessSignal(
    label: 'Fresh',
    tooltip: tooltip,
    color: Colors.green.shade700,
    icon: Icons.eco_rounded,
  );
}

String _attributeText(
  Map<String, String> attributes,
  ProductManagementFieldId fieldId,
) {
  return attributes[fieldId.value]?.trim() ?? '';
}

DateTime? _parseDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;

  return DateUtils.dateOnly(parsed);
}

String _freshnessTooltip({
  required String expiryText,
  required String batchText,
  required String statusText,
}) {
  return [
    expiryText.isEmpty ? 'Expiry missing' : 'Expiry: $expiryText',
    batchText.isEmpty ? 'Batch missing' : 'Batch: $batchText',
    if (statusText.isNotEmpty) 'Status: $statusText',
  ].join(', ');
}
