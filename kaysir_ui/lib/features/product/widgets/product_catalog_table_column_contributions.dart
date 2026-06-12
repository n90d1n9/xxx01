import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/widgets/inventory_product_catalog_table_column_contribution.dart';
import '../models/product_catalog_quality.dart';
import '../models/management_pack.dart';
import '../models/sales_channel_definition.dart';
import '../utils/product_catalog_channel_readiness.dart';

List<InventoryProductCatalogTableColumnContribution>
buildDefaultProductCatalogTableColumnContributions({
  required ProductManagementPack pack,
  required List<ProductSalesChannelDefinition> channelDefinitions,
}) {
  return [
    InventoryProductCatalogTableColumnContribution(
      id: 'product-catalog-quality',
      label: 'Quality',
      tooltip: 'Catalog and pack completeness',
      sectionLabel: 'Readiness',
      priority: 10,
      cellBuilder:
          (context, record) =>
              ProductCatalogQualityTableCell(record: record, pack: pack),
    ),
    InventoryProductCatalogTableColumnContribution(
      id: 'product-channel-fit',
      label: 'Channel fit',
      tooltip: 'Readiness for the active channel strategy',
      sectionLabel: 'Readiness',
      priority: 20,
      cellBuilder:
          (context, record) => ProductCatalogChannelReadinessTableCell(
            record: record,
            definitions: channelDefinitions,
          ),
    ),
  ];
}

class ProductCatalogQualityTableCell extends StatelessWidget {
  const ProductCatalogQualityTableCell({
    super.key,
    required this.record,
    required this.pack,
  });

  final InventoryProductCatalogRecord record;
  final ProductManagementPack pack;

  @override
  Widget build(BuildContext context) {
    final issues = productCatalogQualityIssuesForRecord(record, pack: pack);
    final count = issues.length;

    if (count == 0) {
      return const AppStatusPill(
        label: 'Ready',
        color: Colors.green,
        icon: Icons.check_circle_rounded,
        maxWidth: 104,
      );
    }

    final color = count > 2 ? Colors.red.shade700 : Colors.orange.shade700;

    return AppStatusPill(
      label: '$count ${count == 1 ? 'fix' : 'fixes'}',
      tooltip: issues.map((issue) => issue.label).join(', '),
      color: color,
      icon: Icons.tune_rounded,
      maxWidth: 112,
    );
  }
}

class ProductCatalogChannelReadinessTableCell extends StatelessWidget {
  const ProductCatalogChannelReadinessTableCell({
    super.key,
    required this.record,
    required this.definitions,
  });

  final InventoryProductCatalogRecord record;
  final List<ProductSalesChannelDefinition> definitions;

  @override
  Widget build(BuildContext context) {
    final readiness = buildProductCatalogChannelReadiness(
      record: record,
      definitions: definitions,
    );
    if (readiness.isEmpty) {
      return const AppStatusPill(
        label: 'No channels',
        color: Colors.blueGrey,
        icon: Icons.hub_rounded,
        maxWidth: 132,
      );
    }

    final readyCount = readiness.where((item) => item.ready).length;
    final issueCount = readiness.fold<int>(
      0,
      (total, item) => total + item.issueCount,
    );
    final allReady = readyCount == readiness.length;
    final color =
        allReady
            ? Colors.green.shade700
            : issueCount > readiness.length
            ? Colors.red.shade700
            : Colors.orange.shade700;

    return AppStatusPill(
      label: '$readyCount/${readiness.length} ready',
      tooltip: readiness
          .map((item) => '${item.title}: ${item.statusLabel}')
          .join(', '),
      color: color,
      icon: allReady ? Icons.check_circle_rounded : Icons.warning_rounded,
      maxWidth: 132,
    );
  }
}
