import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_opname_draft_status.dart';
import 'inventory_stock_opname_draft_status_details.dart';
import 'stock_opname_draft_status_actions.dart';
import 'stock_opname_draft_status_content.dart';
import 'stock_opname_draft_status_preview_data.dart';
import 'stock_opname_draft_status_visuals.dart';

/// Inline stock opname status banner for unsaved count-sheet drafts.
class InventoryStockOpnameDraftStatusBanner extends StatelessWidget {
  const InventoryStockOpnameDraftStatusBanner({
    super.key,
    required this.status,
    this.onReviewFirstIssue,
    this.onReset,
  });

  final InventoryStockOpnameDraftStatus status;
  final VoidCallback? onReviewFirstIssue;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    if (!status.hasUnsavedChanges) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final details = inventoryStockOpnameDraftStatusDetails(status);
    final accentColor = inventoryStockOpnameDraftAccentColor(
      colorScheme,
      details,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: inventoryStockOpnameDraftBackgroundColor(colorScheme, details),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 760;
            final content = InventoryStockOpnameDraftStatusContent(
              title: details.title,
              subtitle: details.subtitle,
              accentColor: accentColor,
              badges: details.badges,
            );
            final actions = InventoryStockOpnameDraftStatusActions(
              reviewActionLabel: details.reviewActionLabel,
              resetActionLabel: details.resetActionLabel,
              onReviewFirstIssue: onReviewFirstIssue,
              onReset: onReset,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: actions),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Inventory stock opname draft status banner')
Widget inventoryStockOpnameDraftStatusBannerPreview() {
  return inventoryStockOpnameDraftStatusPreviewScaffold(
    InventoryStockOpnameDraftStatusBanner(
      status: inventoryStockOpnameDraftStatusPreviewStatus(),
    ),
  );
}
