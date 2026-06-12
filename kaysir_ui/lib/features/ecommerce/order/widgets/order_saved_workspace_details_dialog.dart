import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_details_action_bar.dart';
import 'order_saved_workspace_details_content.dart';
import 'order_saved_workspace_details_dialog_presentation.dart';
import 'order_saved_workspace_details_surface_header.dart';

Future<void> showOrderSavedWorkspaceDetailsDialog({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  List<OrderSavedWorkspaceActionEntry> actionEntries = const [],
  OrderSavedWorkspaceDetailsActionSelected? onActionSelected,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => OrderSavedWorkspaceDetailsDialog(
          workspace: workspace,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
  );
}

class OrderSavedWorkspaceDetailsDialog extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsDialog({
    super.key,
    required this.workspace,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final presentation =
        OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(workspace);

    return AlertDialog(
      key: const ValueKey('order_saved_workspace_details_dialog'),
      title: OrderSavedWorkspaceDetailsSurfaceHeader(
        title: presentation.title,
        showCloseButton: false,
      ),
      content: SingleChildScrollView(
        child: OrderSavedWorkspaceDetailsContent(workspace: workspace),
      ),
      actions: [
        OrderSavedWorkspaceDetailsDialogActions(
          workspace: workspace,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
        TextButton(
          key: const ValueKey('order_saved_workspace_details_close'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class OrderSavedWorkspaceDetailsDialogActions extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsDialogActions({
    super.key,
    required this.workspace,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (actionEntries.isEmpty || onActionSelected == null) {
      return const SizedBox.shrink();
    }
    final width =
        (MediaQuery.sizeOf(context).width - 96).clamp(220.0, 420.0).toDouble();

    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: OrderSavedWorkspaceDetailsActionBar(
          workspace: workspace,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
      ),
    );
  }
}
