import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';

class OrderSavedWorkspaceStatusPresentation {
  final OrderSavedWorkspace workspace;

  const OrderSavedWorkspaceStatusPresentation({required this.workspace});

  IconData get leadingIcon => pinBadge.icon;

  bool get showNoteMarker => workspace.isDescriptionCustom;

  OrderSavedWorkspaceStatusBadgePresentation get pinBadge {
    return OrderSavedWorkspaceStatusBadgePresentation(
      icon:
          workspace.isPinned
              ? Icons.push_pin_rounded
              : Icons.bookmark_border_rounded,
      label: workspace.isPinned ? 'Pinned' : 'Unpinned',
    );
  }

  OrderSavedWorkspaceStatusBadgePresentation get summaryBadge {
    return OrderSavedWorkspaceStatusBadgePresentation(
      icon:
          workspace.isDescriptionCustom
              ? Icons.sticky_note_2_outlined
              : Icons.auto_awesome_outlined,
      label: workspace.isDescriptionCustom ? 'Custom note' : 'Auto summary',
    );
  }

  List<OrderSavedWorkspaceStatusBadgePresentation> get detailBadges {
    return [pinBadge, summaryBadge];
  }

  List<String> rowBadges({required bool isActive}) {
    return [
      if (isActive) 'Active',
      if (workspace.isPinned) pinBadge.label,
      if (workspace.isDescriptionCustom) summaryBadge.label,
    ];
  }
}

class OrderSavedWorkspaceStatusBadgePresentation {
  final IconData icon;
  final String label;

  const OrderSavedWorkspaceStatusBadgePresentation({
    required this.icon,
    required this.label,
  });
}
