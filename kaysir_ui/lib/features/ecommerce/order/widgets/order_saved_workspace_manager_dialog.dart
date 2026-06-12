import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_saved_workspace_manager_state.dart';
import 'order_saved_workspace_manager_callbacks.dart';
import 'order_saved_workspace_manager_list.dart';
import 'order_saved_workspace_manager_toolbar.dart';

Future<void> showOrderSavedWorkspaceManagerDialog({
  required BuildContext context,
  required List<OrderSavedWorkspace> workspaces,
  required String? activeWorkspaceId,
  ValueChanged<OrderSavedWorkspace>? onSelected,
  ValueChanged<OrderSavedWorkspace>? onDeleted,
  ValueChanged<OrderSavedWorkspace>? onDuplicated,
  void Function(OrderSavedWorkspace workspace, bool isPinned)? onPinnedChanged,
  void Function(OrderSavedWorkspace workspace, String label)? onRenamed,
  void Function(OrderSavedWorkspace workspace, String description)?
  onDescriptionChanged,
  ValueChanged<OrderSavedWorkspace>? onDescriptionReset,
  void Function(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  )?
  onMoved,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => OrderSavedWorkspaceManagerDialog(
          workspaces: workspaces,
          activeWorkspaceId: activeWorkspaceId,
          callbacks: OrderSavedWorkspaceManagerCallbacks(
            onSelected: onSelected,
            onDeleted: onDeleted,
            onDuplicated: onDuplicated,
            onPinnedChanged: onPinnedChanged,
            onRenamed: onRenamed,
            onDescriptionChanged: onDescriptionChanged,
            onDescriptionReset: onDescriptionReset,
            onMoved: onMoved,
          ),
        ),
  );
}

class OrderSavedWorkspaceManagerDialog extends StatefulWidget {
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;
  final OrderSavedWorkspaceManagerCallbacks callbacks;

  const OrderSavedWorkspaceManagerDialog({
    super.key,
    required this.workspaces,
    required this.activeWorkspaceId,
    this.callbacks = OrderSavedWorkspaceManagerCallbacks.empty,
  });

  @override
  State<OrderSavedWorkspaceManagerDialog> createState() =>
      _OrderSavedWorkspaceManagerDialogState();
}

class _OrderSavedWorkspaceManagerDialogState
    extends State<OrderSavedWorkspaceManagerDialog> {
  late final TextEditingController _searchController;
  OrderSavedWorkspaceManagerState _managerState =
      OrderSavedWorkspaceManagerState.initial;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final managerView = _managerState.viewFor(widget.workspaces);

    return AlertDialog(
      key: const ValueKey('order_saved_workspace_manager_dialog'),
      title: const Text('Manage saved workspaces'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrderSavedWorkspaceManagerToolbar(
              managerView: managerView,
              searchController: _searchController,
              scope: _managerState.scope,
              sortMode: _managerState.sortMode,
              onQueryChanged:
                  (query) =>
                      _updateManagerState(_managerState.withQuery(query)),
              onScopeChanged:
                  (scope) =>
                      _updateManagerState(_managerState.withScope(scope)),
              onSortChanged:
                  (sortMode) =>
                      _updateManagerState(_managerState.withSortMode(sortMode)),
            ),
            const SizedBox(height: POSUiTokens.gapLarge),
            OrderSavedWorkspaceManagerList(
              managerView: managerView,
              workspaces: widget.workspaces,
              activeWorkspaceId: widget.activeWorkspaceId,
              callbacks: widget.callbacks,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('order_saved_workspace_manager_close'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _updateManagerState(OrderSavedWorkspaceManagerState value) {
    if (value == _managerState) return;

    setState(() => _managerState = value);
  }
}
