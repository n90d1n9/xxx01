import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/sales_channel_definition.dart';
import '../utils/product_catalog_channel_readiness.dart';

class ProductCatalogChannelReadinessBadges extends StatelessWidget {
  const ProductCatalogChannelReadinessBadges({
    super.key,
    required this.record,
    required this.definitions,
    this.onSelected,
  });

  final InventoryProductCatalogRecord record;
  final List<ProductSalesChannelDefinition> definitions;
  final ValueChanged<ProductCatalogChannelReadinessItem>? onSelected;

  @override
  Widget build(BuildContext context) {
    final items = buildProductCatalogChannelReadiness(
      record: record,
      definitions: definitions,
    );
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 2),
          child: Text(
            'Channels',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final item in items)
          _ProductCatalogChannelReadinessBadge(
            key: ValueKey(
              'product-catalog-channel-readiness-'
              '${record.id}-${item.channel.name}',
            ),
            item: item,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _ProductCatalogChannelReadinessBadge extends StatelessWidget {
  const _ProductCatalogChannelReadinessBadge({
    super.key,
    required this.item,
    this.onSelected,
  });

  final ProductCatalogChannelReadinessItem item;
  final ValueChanged<ProductCatalogChannelReadinessItem>? onSelected;

  @override
  Widget build(BuildContext context) {
    final pill = AppStatusPill(
      label: '${item.title}: ${item.statusLabel}',
      tooltip: _tooltipLabel(item, selectable: onSelected != null),
      icon:
          item.ready ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
      color: _statusColor(item),
      maxWidth: 240,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );

    if (onSelected == null) return pill;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onSelected!(item),
      child: pill,
    );
  }
}

String _tooltipLabel(
  ProductCatalogChannelReadinessItem item, {
  required bool selectable,
}) {
  final summary = '${item.title}: ${item.issueSummaryLabel}';
  if (!selectable) return summary;

  final primaryIssue = item.primaryIssue;
  if (primaryIssue == null) return '$summary. Review channel.';

  return '$summary. Review ${primaryIssue.label}.';
}

Color _statusColor(ProductCatalogChannelReadinessItem item) {
  if (item.ready) return Colors.green.shade700;
  if (item.issueCount > 1) return Colors.red.shade700;
  if (item.issueCount == 1) return Colors.orange.shade700;

  return Colors.blueGrey.shade700;
}
