import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/management_pack.dart';
import '../models/product.dart';
import '../models/product_catalog_quality_badge_strip_state.dart';
import '../models/product_catalog_quality.dart';
import 'product_catalog_quality_visuals.dart';

/// Row-level catalog quality status and quick-fix badges.
class ProductCatalogQualityBadges extends StatelessWidget {
  const ProductCatalogQualityBadges({
    super.key,
    required this.record,
    this.onIssueSelected,
    this.maxVisibleIssues = 3,
    this.pack,
  });

  final InventoryProductCatalogRecord record;
  final ValueChanged<ProductCatalogQualityIssue>? onIssueSelected;
  final int maxVisibleIssues;
  final ProductManagementPack? pack;

  @override
  Widget build(BuildContext context) {
    final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
      record: record,
      maxVisibleIssues: maxVisibleIssues,
      pack: pack,
    );
    if (viewState.isReady) {
      return AppStatusPill(
        label: viewState.readyLabel,
        color: ProductCatalogQualityVisuals.scoreColor(100),
        icon: Icons.check_circle_rounded,
        maxWidth: 160,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: viewState.summaryLabel,
          color: Colors.orange.shade700,
          icon: Icons.tune_rounded,
          maxWidth: 150,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        for (final issue in viewState.visibleIssues)
          _ProductCatalogQualityIssueBadge(
            key: ValueKey(
              'product-catalog-quality-badge-${record.id}-${issue.id}',
            ),
            issue: issue,
            productName: record.productName,
            onSelected:
                onIssueSelected == null ? null : () => onIssueSelected!(issue),
          ),
        if (viewState.hasHiddenIssues)
          AppStatusPill(
            label: viewState.hiddenLabel,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            maxWidth: 96,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
      ],
    );
  }
}

@Preview(name: 'Product catalog quality badges')
Widget productCatalogQualityBadgesPreview() {
  final record =
      buildInventoryProductCatalogRecords(
        products: [
          Product(
            id: 'preview-fresh-goods',
            name: 'Draft baby spinach',
            sku: 'SP-001',
            category: 'Fresh',
            description: 'Fresh greens without scan and batch data',
            price: 14,
          ),
        ],
        stockRecords: const [],
      ).single;

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductCatalogQualityBadges(
          record: record,
          pack: groceryFreshGoodsProductManagementPack,
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Compact actionable badge for a single catalog quality issue.
class _ProductCatalogQualityIssueBadge extends StatelessWidget {
  const _ProductCatalogQualityIssueBadge({
    super.key,
    required this.issue,
    required this.productName,
    this.onSelected,
  });

  final ProductCatalogQualityIssue issue;
  final String productName;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = ProductCatalogQualityVisuals.issueTypeColor(issue.type);
    final pill = AppStatusPill(
      label: ProductCatalogQualityVisuals.quickFixLabel(issue),
      color: color,
      icon: ProductCatalogQualityVisuals.issueIcon(issue.type),
      maxWidth: 170,
      tooltip:
          onSelected == null ? null : 'Fix ${issue.label} for $productName',
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );

    if (onSelected == null) return pill;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onSelected,
      child: pill,
    );
  }
}
