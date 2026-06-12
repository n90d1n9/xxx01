import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_accessibility.dart';
import 'order_saved_workspace_chip.dart';

class OrderSavedWorkspaceChipStrip extends StatefulWidget {
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;
  final ValueChanged<OrderSavedWorkspace>? onSelected;
  final ValueChanged<OrderSavedWorkspace>? onDeleted;
  final ValueChanged<OrderSavedWorkspace>? onDuplicated;
  final void Function(OrderSavedWorkspace workspace, bool isPinned)?
  onPinnedChanged;
  final void Function(OrderSavedWorkspace workspace, String label)? onRenamed;
  final void Function(OrderSavedWorkspace workspace, String description)?
  onDescriptionChanged;
  final ValueChanged<OrderSavedWorkspace>? onDescriptionReset;
  final void Function(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  )?
  onMoved;

  const OrderSavedWorkspaceChipStrip({
    super.key,
    required this.workspaces,
    required this.activeWorkspaceId,
    required this.onSelected,
    required this.onDeleted,
    required this.onDuplicated,
    required this.onPinnedChanged,
    required this.onRenamed,
    required this.onDescriptionChanged,
    required this.onDescriptionReset,
    required this.onMoved,
  });

  @override
  State<OrderSavedWorkspaceChipStrip> createState() =>
      _OrderSavedWorkspaceChipStripState();
}

class _OrderSavedWorkspaceChipStripState
    extends State<OrderSavedWorkspaceChipStrip> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: orderSavedWorkspaceStripSemanticsLabel(widget.workspaces),
      child: Scrollbar(
        controller: _scrollController,
        interactive: true,
        radius: const Radius.circular(POSUiTokens.radius),
        thickness: 3,
        thumbVisibility: widget.workspaces.length > 2,
        child: SingleChildScrollView(
          key: const ValueKey('order_saved_workspace_chip_strip_scroll'),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              for (final workspace in widget.workspaces)
                Padding(
                  padding: const EdgeInsets.only(right: POSUiTokens.gap),
                  child: OrderSavedWorkspaceChip(
                    workspace: workspace,
                    selected: workspace.id == widget.activeWorkspaceId,
                    onSelected:
                        widget.onSelected == null
                            ? null
                            : () => widget.onSelected!(workspace),
                    onDeleted:
                        widget.onDeleted == null
                            ? null
                            : () => widget.onDeleted!(workspace),
                    onDuplicated:
                        widget.onDuplicated == null
                            ? null
                            : () => widget.onDuplicated!(workspace),
                    onPinnedChanged:
                        widget.onPinnedChanged == null
                            ? null
                            : (isPinned) =>
                                widget.onPinnedChanged!(workspace, isPinned),
                    onRenamed:
                        widget.onRenamed == null
                            ? null
                            : (label) => widget.onRenamed!(workspace, label),
                    onDescriptionChanged:
                        widget.onDescriptionChanged == null
                            ? null
                            : (description) => widget.onDescriptionChanged!(
                              workspace,
                              description,
                            ),
                    onDescriptionReset:
                        widget.onDescriptionReset == null
                            ? null
                            : () => widget.onDescriptionReset!(workspace),
                    onMoved:
                        widget.onMoved == null
                            ? null
                            : (direction) =>
                                widget.onMoved!(workspace, direction),
                    canMoveEarlier: ecommerceOrderSavedWorkspaceCanMove(
                      workspaces: widget.workspaces,
                      workspaceId: workspace.id,
                      direction: OrderSavedWorkspaceMoveDirection.earlier,
                    ),
                    canMoveLater: ecommerceOrderSavedWorkspaceCanMove(
                      workspaces: widget.workspaces,
                      workspaceId: workspace.id,
                      direction: OrderSavedWorkspaceMoveDirection.later,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
