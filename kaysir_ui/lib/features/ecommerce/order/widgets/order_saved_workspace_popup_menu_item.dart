import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_menu_item.dart';
import 'order_saved_workspace_action_presentation.dart';

PopupMenuItem<OrderSavedWorkspaceAction> orderSavedWorkspacePopupMenuItem({
  required String keyPrefix,
  required OrderSavedWorkspace workspace,
  required OrderSavedWorkspaceAction action,
  bool enabled = true,
  Color? deleteColor,
  IconData duplicateIcon = Icons.copy_all_outlined,
  IconData deleteIcon = Icons.delete_outline_rounded,
  String deleteLabel = 'Delete',
  bool isDeleteDestructive = false,
}) {
  final presentation = orderSavedWorkspaceActionPresentation(
    action: action,
    workspace: workspace,
    deleteColor: deleteColor,
    duplicateIcon: duplicateIcon,
    deleteIcon: deleteIcon,
    deleteLabel: deleteLabel,
    isDeleteDestructive: isDeleteDestructive,
  );

  return PopupMenuItem<OrderSavedWorkspaceAction>(
    key: ValueKey('${keyPrefix}_${action.keySuffix}_${workspace.id}'),
    value: action,
    enabled: enabled,
    child: OrderSavedWorkspaceActionMenuItem(
      icon: presentation.icon,
      label: presentation.label,
      color: presentation.color,
      isDestructive: presentation.isDestructive,
    ),
  );
}
