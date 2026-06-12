import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/sales_channel_readiness.dart';

/// Selection callback for a concrete sales-channel readiness issue.
typedef ProductSalesChannelReadinessIssueSelection =
    void Function(
      ProductSalesChannelReadiness readiness,
      ProductSalesChannelReadinessIssue issue,
    );

/// Inline issue chips that summarize why a sales channel is not ready.
class ProductSalesChannelIssueBreakdown extends StatelessWidget {
  const ProductSalesChannelIssueBreakdown({
    super.key,
    required this.readiness,
    required this.accentColor,
    this.maxVisibleIssues = 2,
    this.onIssueSelected,
  });

  final ProductSalesChannelReadiness readiness;
  final Color accentColor;
  final int maxVisibleIssues;
  final ProductSalesChannelReadinessIssueSelection? onIssueSelected;

  @override
  Widget build(BuildContext context) {
    final issues = readiness.topIssues(limit: maxVisibleIssues);
    final hiddenCount = readiness.hiddenIssueCount(
      visibleLimit: maxVisibleIssues,
    );

    if (issues.isEmpty) {
      return AppStatusPill(
        label: readiness.issueSummaryLabel,
        color: Colors.green.shade700,
        icon: Icons.check_circle_rounded,
        maxWidth: 180,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final issue in issues)
          _ProductSalesChannelIssuePill(
            key: ValueKey(
              'product-channel-issue-'
              '${readiness.channel.name}-${issue.blocker.name}',
            ),
            issue: issue,
            color: accentColor,
            onSelected:
                onIssueSelected == null
                    ? null
                    : () => onIssueSelected!(readiness, issue),
          ),
        if (hiddenCount > 0)
          AppStatusPill(
            label: '+$hiddenCount more',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            maxWidth: 120,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
      ],
    );
  }
}

@Preview(name: 'Sales channel issue breakdown')
Widget productSalesChannelIssueBreakdownPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelIssueBreakdown(
          readiness: _previewReadiness,
          accentColor: Colors.orange.shade700,
          onIssueSelected: (_, _) {},
        ),
      ),
    ),
  );
}

/// Selectable pill for one readiness issue type.
class _ProductSalesChannelIssuePill extends StatelessWidget {
  const _ProductSalesChannelIssuePill({
    super.key,
    required this.issue,
    required this.color,
    this.onSelected,
  });

  final ProductSalesChannelReadinessIssue issue;
  final Color color;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final pill = AppStatusPill(
      label: issue.countLabel,
      color: color,
      icon: Icons.tune_rounded,
      maxWidth: 170,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      tooltip:
          onSelected == null ? null : 'Review ${issue.countLabel} products',
    );

    if (onSelected == null) return pill;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onSelected,
      child: pill,
    );
  }
}

const _previewReadiness = ProductSalesChannelReadiness(
  channel: ProductSalesChannel.posCheckout,
  title: 'POS Checkout',
  subtitle: 'Priced products with sellable stock',
  readyCount: 12,
  totalCount: 18,
  reviewFilter: InventoryProductCatalogFilter.attention,
  issues: [
    ProductSalesChannelReadinessIssue(
      blocker: ProductSalesChannelBlocker.stockNotSellable,
      label: 'stock not sellable',
      count: 4,
      reviewFilter: InventoryProductCatalogFilter.attention,
    ),
    ProductSalesChannelReadinessIssue(
      blocker: ProductSalesChannelBlocker.missingPrice,
      label: 'missing price',
      count: 2,
      reviewFilter: InventoryProductCatalogFilter.attention,
    ),
  ],
);
