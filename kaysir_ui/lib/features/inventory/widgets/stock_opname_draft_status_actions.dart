import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import 'stock_opname_draft_status_preview_data.dart';

/// Action cluster for reviewing or resetting unsaved stock opname edits.
class InventoryStockOpnameDraftStatusActions extends StatelessWidget {
  const InventoryStockOpnameDraftStatusActions({
    super.key,
    required this.reviewActionLabel,
    required this.resetActionLabel,
    this.onReviewFirstIssue,
    this.onReset,
  });

  final String reviewActionLabel;
  final String resetActionLabel;
  final VoidCallback? onReviewFirstIssue;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppActionButton(
          label: reviewActionLabel,
          icon: Icons.find_in_page_rounded,
          variant: AppActionButtonVariant.text,
          compact: true,
          onPressed: onReviewFirstIssue,
        ),
        AppActionButton(
          label: resetActionLabel,
          icon: Icons.refresh_rounded,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          onPressed: onReset,
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory stock opname draft status actions')
Widget inventoryStockOpnameDraftStatusActionsPreview() {
  final details = inventoryStockOpnameDraftStatusPreviewDetails();

  return inventoryStockOpnameDraftStatusPreviewScaffold(
    InventoryStockOpnameDraftStatusActions(
      reviewActionLabel: details.reviewActionLabel,
      resetActionLabel: details.resetActionLabel,
      onReviewFirstIssue: () {},
      onReset: () {},
    ),
  );
}
