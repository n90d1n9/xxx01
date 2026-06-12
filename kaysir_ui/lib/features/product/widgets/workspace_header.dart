import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../../inventory/models/inventory_product_catalog.dart';
import 'workspace_preview_fixtures.dart';

/// Responsive command header for the product workspace landing surface.
class ProductWorkspaceHeader extends StatelessWidget {
  const ProductWorkspaceHeader({
    super.key,
    required this.summary,
    required this.onOpenCatalog,
    this.eyebrow = 'Product Operations',
    this.title = 'Catalog command center',
    this.description,
  });

  final InventoryProductCatalogSummary summary;
  final VoidCallback onOpenCatalog;
  final String eyebrow;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cluster = AppTextCluster(
          eyebrow: eyebrow,
          title: title,
          subtitle: [
            if (description?.trim().isNotEmpty ?? false) description!.trim(),
            '${summary.productCount} products, '
                '${summary.trackedProductCount} tracked, '
                '${summary.attentionProductCount} needing attention',
          ].join(' | '),
          titleStyle: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        );
        final action = AppActionButton(
          label: 'Open catalog',
          icon: Icons.inventory_2_rounded,
          onPressed: onOpenCatalog,
        );

        if (constraints.maxWidth < 620) {
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

@Preview(name: 'Product workspace header')
Widget workspaceHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceHeader(
          summary: previewProductWorkspaceSummary,
          description: 'Fresh goods operations with channel-ready catalog data',
          onOpenCatalog: () {},
        ),
      ),
    ),
  );
}
