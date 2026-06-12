import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../inventory/models/inventory_product_catalog.dart';
import 'workspace_preview_fixtures.dart';

/// Focused list of products requiring stock or tracking attention.
class ProductWorkspaceAttentionPanel extends StatelessWidget {
  const ProductWorkspaceAttentionPanel({
    super.key,
    required this.records,
    required this.onReviewCatalog,
    this.visibleLimit = 4,
  });

  final List<InventoryProductCatalogRecord> records;
  final VoidCallback onReviewCatalog;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    final attentionRecords =
        records
            .where((record) => record.needsAttention)
            .take(visibleLimit)
            .toList();

    return AppContentPanel(
      title: 'Product attention',
      subtitle:
          attentionRecords.isEmpty
              ? 'No product stock attention needed'
              : '${attentionRecords.length} high-priority products shown',
      leadingIcon: Icons.warning_amber_rounded,
      trailing: AppActionButton(
        label: 'Review catalog',
        icon: Icons.manage_search_rounded,
        variant: AppActionButtonVariant.secondary,
        onPressed: onReviewCatalog,
      ),
      child:
          attentionRecords.isEmpty
              ? const Text('All tracked products are currently healthy.')
              : Column(
                children: [
                  for (
                    var index = 0;
                    index < attentionRecords.length;
                    index += 1
                  ) ...[
                    _AttentionProductRow(record: attentionRecords[index]),
                    if (index != attentionRecords.length - 1)
                      const Divider(height: 18),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Product workspace attention')
Widget workspaceAttentionPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceAttentionPanel(
          records: previewProductWorkspaceOverview.records,
          onReviewCatalog: () {},
        ),
      ),
    ),
  );
}

/// Single product row inside the workspace attention panel.
class _AttentionProductRow extends StatelessWidget {
  const _AttentionProductRow({required this.record});

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status);

    return Row(
      children: [
        Icon(Icons.inventory_2_rounded, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                '${record.skuLabel} | ${record.categoryLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        AppStatusPill(
          label: inventoryProductCatalogStatusLabel(record.status),
          color: color,
          icon: Icons.flag_rounded,
          maxWidth: 140,
        ),
      ],
    );
  }
}

Color _statusColor(InventoryProductCatalogStatus status) {
  switch (status) {
    case InventoryProductCatalogStatus.untracked:
      return Colors.blueGrey.shade700;
    case InventoryProductCatalogStatus.outOfStock:
      return Colors.red.shade700;
    case InventoryProductCatalogStatus.lowStock:
      return Colors.orange.shade700;
    case InventoryProductCatalogStatus.inStock:
      return Colors.green.shade700;
  }
}
