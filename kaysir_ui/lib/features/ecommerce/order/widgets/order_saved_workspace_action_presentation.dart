import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';

class OrderSavedWorkspaceActionPresentation {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isDestructive;

  const OrderSavedWorkspaceActionPresentation({
    required this.icon,
    required this.label,
    this.color,
    this.isDestructive = false,
  });
}

OrderSavedWorkspaceActionPresentation orderSavedWorkspaceActionPresentation({
  required OrderSavedWorkspaceAction action,
  required OrderSavedWorkspace workspace,
  Color? deleteColor,
  IconData duplicateIcon = Icons.copy_all_outlined,
  IconData deleteIcon = Icons.delete_outline_rounded,
  String deleteLabel = 'Delete',
  bool isDeleteDestructive = false,
}) {
  return switch (action) {
    OrderSavedWorkspaceAction.details =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.info_outline_rounded,
        label: 'Details',
      ),
    OrderSavedWorkspaceAction.editNote =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.sticky_note_2_outlined,
        label: 'Edit note',
      ),
    OrderSavedWorkspaceAction.resetNote =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.auto_awesome_outlined,
        label: 'Use auto summary',
      ),
    OrderSavedWorkspaceAction.moveEarlier =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.chevron_left_rounded,
        label: 'Move earlier',
      ),
    OrderSavedWorkspaceAction.moveLater =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.chevron_right_rounded,
        label: 'Move later',
      ),
    OrderSavedWorkspaceAction.duplicate =>
      OrderSavedWorkspaceActionPresentation(
        icon: duplicateIcon,
        label: 'Duplicate',
      ),
    OrderSavedWorkspaceAction.rename =>
      const OrderSavedWorkspaceActionPresentation(
        icon: Icons.edit_outlined,
        label: 'Rename',
      ),
    OrderSavedWorkspaceAction.togglePin =>
      OrderSavedWorkspaceActionPresentation(
        icon:
            workspace.isPinned
                ? Icons.push_pin_rounded
                : Icons.push_pin_outlined,
        label: workspace.isPinned ? 'Unpin' : 'Pin',
      ),
    OrderSavedWorkspaceAction.delete => OrderSavedWorkspaceActionPresentation(
      icon: deleteIcon,
      label: deleteLabel,
      color: deleteColor,
      isDestructive: isDeleteDestructive,
    ),
  };
}
