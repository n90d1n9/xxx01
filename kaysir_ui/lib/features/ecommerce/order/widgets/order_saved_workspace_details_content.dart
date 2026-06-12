import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_auto_summary_preview.dart';
import 'order_saved_workspace_detail_line.dart';
import 'order_saved_workspace_details_dialog_presentation.dart';
import 'order_saved_workspace_details_filter_grid.dart';
import 'order_saved_workspace_details_header.dart';

class OrderSavedWorkspaceDetailsContent extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final double maxWidth;

  const OrderSavedWorkspaceDetailsContent({
    super.key,
    required this.workspace,
    this.maxWidth = 460,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation =
        OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(workspace);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderSavedWorkspaceDetailsHeader(workspace: workspace),
          const SizedBox(height: POSUiTokens.gapLarge),
          Text(
            presentation.filterSectionTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: POSUiTokens.gap),
          OrderSavedWorkspaceDetailsFilterGrid(workspace: workspace),
          const SizedBox(height: POSUiTokens.gapLarge),
          if (presentation.showAutoSummaryPreview) ...[
            OrderSavedWorkspaceAutoSummaryPreview(workspace: workspace),
            const SizedBox(height: POSUiTokens.gapLarge),
          ],
          OrderSavedWorkspaceDetailLine(
            label: presentation.shortcutLine.label,
            value: presentation.shortcutLine.value,
          ),
        ],
      ),
    );
  }
}
