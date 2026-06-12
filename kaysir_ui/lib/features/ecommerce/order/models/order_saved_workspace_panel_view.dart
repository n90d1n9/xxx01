import 'order_saved_workspace.dart';

enum OrderSavedWorkspacePanelBadgeType { saved, pinned, notes }

class OrderSavedWorkspacePanelBadge {
  final OrderSavedWorkspacePanelBadgeType type;
  final String label;

  const OrderSavedWorkspacePanelBadge({
    required this.type,
    required this.label,
  });
}

class OrderSavedWorkspacePanelView {
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;
  final String? activeWorkspaceLabel;
  final int workspaceCount;
  final int pinnedWorkspaceCount;
  final int customNoteWorkspaceCount;

  const OrderSavedWorkspacePanelView({
    required this.workspaces,
    required this.activeWorkspaceId,
    required this.activeWorkspaceLabel,
    required this.workspaceCount,
    required this.pinnedWorkspaceCount,
    required this.customNoteWorkspaceCount,
  });

  bool get hasWorkspaces => workspaceCount > 0;

  List<OrderSavedWorkspacePanelBadge> visibleBadgesForWidth(
    double availableWidth,
  ) {
    final effectiveWidth = availableWidth.isFinite ? availableWidth : 900.0;

    return [
      if (workspaceCount > 0 && effectiveWidth >= 360)
        OrderSavedWorkspacePanelBadge(
          type: OrderSavedWorkspacePanelBadgeType.saved,
          label: '$workspaceCount saved',
        ),
      if (pinnedWorkspaceCount > 0 && effectiveWidth >= 520)
        OrderSavedWorkspacePanelBadge(
          type: OrderSavedWorkspacePanelBadgeType.pinned,
          label: '$pinnedWorkspaceCount pinned',
        ),
      if (customNoteWorkspaceCount > 0 && effectiveWidth >= 640)
        OrderSavedWorkspacePanelBadge(
          type: OrderSavedWorkspacePanelBadgeType.notes,
          label:
              customNoteWorkspaceCount == 1
                  ? '1 note'
                  : '$customNoteWorkspaceCount notes',
        ),
    ];
  }
}

OrderSavedWorkspacePanelView ecommerceOrderSavedWorkspacePanelView({
  required List<OrderSavedWorkspace> workspaces,
  required String? activeWorkspaceId,
}) {
  return OrderSavedWorkspacePanelView(
    workspaces: List.unmodifiable(workspaces),
    activeWorkspaceId: activeWorkspaceId,
    activeWorkspaceLabel: _savedWorkspaceLabelById(
      workspaces: workspaces,
      workspaceId: activeWorkspaceId,
    ),
    workspaceCount: workspaces.length,
    pinnedWorkspaceCount:
        workspaces.where((workspace) => workspace.isPinned).length,
    customNoteWorkspaceCount:
        workspaces.where((workspace) => workspace.isDescriptionCustom).length,
  );
}

String? _savedWorkspaceLabelById({
  required List<OrderSavedWorkspace> workspaces,
  required String? workspaceId,
}) {
  if (workspaceId == null) return null;

  for (final workspace in workspaces) {
    if (workspace.id == workspaceId) return workspace.label;
  }

  return null;
}
