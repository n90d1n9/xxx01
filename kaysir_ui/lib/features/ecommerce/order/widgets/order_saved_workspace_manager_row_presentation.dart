import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_status_presentation.dart';

class OrderSavedWorkspaceManagerRowPresentation {
  final OrderSavedWorkspace workspace;
  final bool isActive;
  final bool canSelect;

  const OrderSavedWorkspaceManagerRowPresentation({
    required this.workspace,
    required this.isActive,
    required this.canSelect,
  });

  IconData get leadingIcon {
    return _status.leadingIcon;
  }

  bool get showNoteMarker => _status.showNoteMarker;

  List<String> get badges {
    return _status.rowBadges(isActive: isActive);
  }

  bool get canApply => canSelect && !isActive;

  IconData get applyIcon {
    return isActive ? Icons.check_circle_rounded : Icons.play_arrow_rounded;
  }

  String get applyLabel {
    return isActive ? 'Active' : 'Apply';
  }

  OrderSavedWorkspaceStatusPresentation get _status {
    return OrderSavedWorkspaceStatusPresentation(workspace: workspace);
  }

  OrderSavedWorkspaceManagerRowColors colorsFor(ThemeData theme) {
    return OrderSavedWorkspaceManagerRowColors(
      background:
          isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
      border:
          isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.28)
              : theme.dividerColor,
      leading:
          isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
      title:
          isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
      description:
          isActive
              ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75)
              : theme.colorScheme.onSurfaceVariant,
    );
  }
}

class OrderSavedWorkspaceManagerRowColors {
  final Color background;
  final Color border;
  final Color leading;
  final Color title;
  final Color description;

  const OrderSavedWorkspaceManagerRowColors({
    required this.background,
    required this.border,
    required this.leading,
    required this.title,
    required this.description,
  });
}
