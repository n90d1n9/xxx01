import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/inventory_product_catalog.dart';

class InventoryProductCatalogWorkspaceHeader extends StatelessWidget {
  const InventoryProductCatalogWorkspaceHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.onAddProduct,
  });

  final String eyebrow;
  final String title;
  final InventoryProductCatalogSummary summary;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final cluster = AppTextCluster(
      eyebrow: eyebrow,
      title: title,
      subtitle:
          '${summary.productCount} products, '
          '${summary.trackedProductCount} tracked, '
          '${summary.attentionProductCount} needing attention',
      titleStyle: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
    );
    final action = Tooltip(
      message: 'Add product',
      child: FilledButton.icon(
        onPressed: onAddProduct,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New product'),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cluster,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cluster),
            const SizedBox(width: 16),
            action,
          ],
        );
      },
    );
  }
}
