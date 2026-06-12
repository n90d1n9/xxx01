import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_details_action_bar.dart';
import 'order_saved_workspace_details_content.dart';
import 'order_saved_workspace_details_dialog_presentation.dart';
import 'order_saved_workspace_details_surface_header.dart';
import 'order_saved_workspace_details_surface_presentation.dart';

class OrderSavedWorkspaceDetailsSurfaceFrame extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final EdgeInsets padding;
  final double contentMaxWidth;
  final bool showDragHandle;
  final bool showDivider;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsSurfaceFrame({
    super.key,
    required this.workspace,
    required this.padding,
    required this.contentMaxWidth,
    this.showDragHandle = false,
    this.showDivider = false,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation =
        OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(workspace);
    final showActions = actionEntries.isNotEmpty && onActionSelected != null;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDragHandle) ...[
            const _OrderSavedWorkspaceDetailsDragHandle(),
            const SizedBox(height: POSUiTokens.gap),
          ],
          OrderSavedWorkspaceDetailsSurfaceHeader(
            title: presentation.title,
            titleStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: POSUiTokens.gap),
          if (showDivider) ...[
            Divider(color: theme.dividerColor),
            const SizedBox(height: POSUiTokens.gap),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: OrderSavedWorkspaceDetailsContent(
                workspace: workspace,
                maxWidth: contentMaxWidth,
              ),
            ),
          ),
          if (showActions) ...[
            const SizedBox(height: POSUiTokens.gap),
            Divider(color: theme.dividerColor),
            const SizedBox(height: POSUiTokens.gap),
            _OrderSavedWorkspaceDetailsStickyActions(
              workspace: workspace,
              actionEntries: actionEntries,
              onActionSelected: onActionSelected!,
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderSavedWorkspaceDetailsStickyActions extends StatelessWidget {
  static const double maxHeight = 132;

  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected onActionSelected;

  const _OrderSavedWorkspaceDetailsStickyActions({
    required this.workspace,
    required this.actionEntries,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('order_saved_workspace_details_sticky_actions'),
      constraints: const BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: OrderSavedWorkspaceDetailsActionBar(
          workspace: workspace,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
      ),
    );
  }
}

class _OrderSavedWorkspaceDetailsDragHandle extends StatelessWidget {
  const _OrderSavedWorkspaceDetailsDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const ValueKey('order_saved_workspace_details_drag_handle'),
        width: OrderSavedWorkspaceDetailsSurfacePresentation.sheetHandleWidth,
        height: OrderSavedWorkspaceDetailsSurfacePresentation.sheetHandleHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
