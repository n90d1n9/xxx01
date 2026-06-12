import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../models/management_pack.dart';
import '../models/product.dart';
import '../models/product_catalog_quality.dart';
import '../models/product_catalog_quality_panel_layout.dart';
import '../models/product_catalog_quality_panel_state.dart';
import 'product_catalog_quality_visuals.dart';

/// Dashboard panel for catalog completion and quality review actions.
class ProductCatalogQualityPanel extends StatelessWidget {
  const ProductCatalogQualityPanel({
    super.key,
    required this.summary,
    required this.onIssueSelected,
  });

  final ProductCatalogQualitySummary summary;
  final ValueChanged<ProductCatalogQualityIssue> onIssueSelected;

  @override
  Widget build(BuildContext context) {
    final viewState = ProductCatalogQualityPanelViewState.fromSummary(summary);

    return AppContentPanel(
      title: viewState.title,
      subtitle: viewState.subtitle,
      leadingIcon: Icons.verified_outlined,
      trailing: AppStatusPill(
        label: viewState.completionLabel,
        color: ProductCatalogQualityVisuals.scoreColor(
          viewState.completePercent,
        ),
        icon: Icons.insights_rounded,
        maxWidth: 150,
      ),
      child:
          viewState.isEmpty
              ? Text(viewState.emptyLabel)
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: viewState.progressValue,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: ProductCatalogQualityVisuals.scoreColor(
                        viewState.completePercent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final layout = ProductCatalogQualityPanelLayout.forWidth(
                        constraints.maxWidth,
                      );

                      return Wrap(
                        spacing: layout.gap,
                        runSpacing: layout.gap,
                        children: [
                          for (final issue in viewState.issues)
                            SizedBox(
                              width: layout.tileWidth,
                              child: _CatalogQualityIssueTile(
                                key: ValueKey(
                                  'product-catalog-quality-${issue.id}',
                                ),
                                issue: issue,
                                onSelected: () => onIssueSelected(issue),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
    );
  }
}

@Preview(name: 'Product catalog quality panel')
Widget productCatalogQualityPanelPreview() {
  final records = buildInventoryProductCatalogRecords(
    products: [
      Product(
        id: 'preview-ready',
        name: 'Ready retail pack',
        sku: 'RT-001',
        category: 'Retail',
        description: 'Complete listing for retail channel',
        barcode: '8990001',
        price: 18,
        customAttributes: const {
          'expiry_date': '2026-08-01',
          'batch_number': 'B-204',
        },
      ),
      Product(
        id: 'preview-draft',
        name: 'Draft baby spinach',
        sku: 'SP-001',
        category: 'Fresh',
        description: 'Fresh greens without scan and batch data',
        price: 14,
      ),
    ],
    stockRecords: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductCatalogQualityPanel(
          summary: summarizeProductCatalogQuality(
            records,
            pack: groceryFreshGoodsProductManagementPack,
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Responsive review tile for one catalog quality issue type.
class _CatalogQualityIssueTile extends StatelessWidget {
  const _CatalogQualityIssueTile({
    super.key,
    required this.issue,
    required this.onSelected,
  });

  final ProductCatalogQualityIssue issue;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = ProductCatalogQualityVisuals.issueColor(issue);

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            issue.isActive
                ? accent.withValues(alpha: 0.06)
                : colorScheme.surface,
        border: Border.all(
          color:
              issue.isActive
                  ? accent.withValues(alpha: 0.24)
                  : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ProductCatalogQualityVisuals.issueIcon(issue.type),
                  size: 18,
                  color: accent,
                ),
                const Spacer(),
                AppStatusPill(
                  label: issue.count.toString(),
                  color: accent,
                  maxWidth: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              issue.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            AppActionButton(
              label: issue.isActive ? 'Review' : 'Clear',
              icon:
                  issue.isActive
                      ? Icons.manage_search_rounded
                      : Icons.check_rounded,
              variant: AppActionButtonVariant.secondary,
              onPressed: issue.isActive ? onSelected : null,
            ),
          ],
        ),
      ),
    );
  }
}
