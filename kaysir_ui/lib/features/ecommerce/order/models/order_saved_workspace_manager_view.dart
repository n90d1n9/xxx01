import 'order_saved_workspace.dart';

enum OrderSavedWorkspaceManagerScope { all, pinned, notes }

enum OrderSavedWorkspaceManagerSort {
  defaultOrder,
  labelAscending,
  pinnedFirst,
  notesFirst,
}

class OrderSavedWorkspaceManagerView {
  final List<OrderSavedWorkspace> workspaces;
  final List<OrderSavedWorkspace> visibleWorkspaces;
  final OrderSavedWorkspaceManagerScope scope;
  final OrderSavedWorkspaceManagerSort sortMode;
  final String query;
  final int workspaceCount;
  final int pinnedCount;
  final int noteCount;

  const OrderSavedWorkspaceManagerView({
    required this.workspaces,
    required this.visibleWorkspaces,
    required this.scope,
    required this.sortMode,
    required this.query,
    required this.workspaceCount,
    required this.pinnedCount,
    required this.noteCount,
  });

  bool get isEmpty => visibleWorkspaces.isEmpty;
}

OrderSavedWorkspaceManagerView ecommerceOrderSavedWorkspaceManagerView({
  required List<OrderSavedWorkspace> workspaces,
  OrderSavedWorkspaceManagerScope scope = OrderSavedWorkspaceManagerScope.all,
  OrderSavedWorkspaceManagerSort sortMode =
      OrderSavedWorkspaceManagerSort.defaultOrder,
  String query = '',
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final scopedWorkspaces = workspaces
      .where(
        (workspace) =>
            _matchesManagerScope(workspace, scope) &&
            _matchesManagerQuery(workspace, normalizedQuery),
      )
      .toList(growable: false);
  final visibleWorkspaces = _sortManagerWorkspaces(scopedWorkspaces, sortMode);

  return OrderSavedWorkspaceManagerView(
    workspaces: List.unmodifiable(workspaces),
    visibleWorkspaces: List.unmodifiable(visibleWorkspaces),
    scope: scope,
    sortMode: sortMode,
    query: query.trim(),
    workspaceCount: workspaces.length,
    pinnedCount: workspaces.where((workspace) => workspace.isPinned).length,
    noteCount:
        workspaces.where((workspace) => workspace.isDescriptionCustom).length,
  );
}

List<OrderSavedWorkspace> _sortManagerWorkspaces(
  List<OrderSavedWorkspace> workspaces,
  OrderSavedWorkspaceManagerSort sortMode,
) {
  if (sortMode == OrderSavedWorkspaceManagerSort.defaultOrder) {
    return List.unmodifiable(workspaces);
  }

  final indexedWorkspaces = [
    for (var index = 0; index < workspaces.length; index += 1)
      _IndexedWorkspace(index: index, workspace: workspaces[index]),
  ];

  indexedWorkspaces.sort((left, right) {
    final result = switch (sortMode) {
      OrderSavedWorkspaceManagerSort.defaultOrder => 0,
      OrderSavedWorkspaceManagerSort.labelAscending => _compareText(
        left.workspace.label,
        right.workspace.label,
      ),
      OrderSavedWorkspaceManagerSort.pinnedFirst => _compareBoolFirst(
        left.workspace.isPinned,
        right.workspace.isPinned,
      ),
      OrderSavedWorkspaceManagerSort.notesFirst => _compareBoolFirst(
        left.workspace.isDescriptionCustom,
        right.workspace.isDescriptionCustom,
      ),
    };
    if (result != 0) return result;

    return left.index.compareTo(right.index);
  });

  return List.unmodifiable(indexedWorkspaces.map((entry) => entry.workspace));
}

int _compareText(String left, String right) {
  return left.toLowerCase().compareTo(right.toLowerCase());
}

int _compareBoolFirst(bool left, bool right) {
  if (left == right) return 0;

  return left ? -1 : 1;
}

class _IndexedWorkspace {
  final int index;
  final OrderSavedWorkspace workspace;

  const _IndexedWorkspace({required this.index, required this.workspace});
}

bool _matchesManagerQuery(
  OrderSavedWorkspace workspace,
  String normalizedQuery,
) {
  if (normalizedQuery.isEmpty) return true;

  return workspace.label.toLowerCase().contains(normalizedQuery) ||
      workspace.description.toLowerCase().contains(normalizedQuery) ||
      workspace.id.toLowerCase().contains(normalizedQuery);
}

bool _matchesManagerScope(
  OrderSavedWorkspace workspace,
  OrderSavedWorkspaceManagerScope scope,
) {
  return switch (scope) {
    OrderSavedWorkspaceManagerScope.all => true,
    OrderSavedWorkspaceManagerScope.pinned => workspace.isPinned,
    OrderSavedWorkspaceManagerScope.notes => workspace.isDescriptionCustom,
  };
}
