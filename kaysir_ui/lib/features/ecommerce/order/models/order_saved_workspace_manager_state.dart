import 'order_saved_workspace.dart';
import 'order_saved_workspace_manager_view.dart';

class OrderSavedWorkspaceManagerState {
  final String query;
  final OrderSavedWorkspaceManagerScope scope;
  final OrderSavedWorkspaceManagerSort sortMode;

  const OrderSavedWorkspaceManagerState({
    this.query = '',
    this.scope = OrderSavedWorkspaceManagerScope.all,
    this.sortMode = OrderSavedWorkspaceManagerSort.defaultOrder,
  });

  static const initial = OrderSavedWorkspaceManagerState();

  String get normalizedQuery => query.trim();

  bool get hasQuery => normalizedQuery.isNotEmpty;

  bool get isDefault =>
      !hasQuery &&
      scope == OrderSavedWorkspaceManagerScope.all &&
      sortMode == OrderSavedWorkspaceManagerSort.defaultOrder;

  OrderSavedWorkspaceManagerState copyWith({
    String? query,
    OrderSavedWorkspaceManagerScope? scope,
    OrderSavedWorkspaceManagerSort? sortMode,
  }) {
    return OrderSavedWorkspaceManagerState(
      query: query ?? this.query,
      scope: scope ?? this.scope,
      sortMode: sortMode ?? this.sortMode,
    );
  }

  OrderSavedWorkspaceManagerState withQuery(String value) {
    return copyWith(query: value.trim());
  }

  OrderSavedWorkspaceManagerState withScope(
    OrderSavedWorkspaceManagerScope value,
  ) {
    return copyWith(scope: value);
  }

  OrderSavedWorkspaceManagerState withSortMode(
    OrderSavedWorkspaceManagerSort value,
  ) {
    return copyWith(sortMode: value);
  }

  OrderSavedWorkspaceManagerState clearQuery() {
    return copyWith(query: '');
  }

  OrderSavedWorkspaceManagerView viewFor(List<OrderSavedWorkspace> workspaces) {
    return ecommerceOrderSavedWorkspaceManagerView(
      workspaces: workspaces,
      scope: scope,
      sortMode: sortMode,
      query: normalizedQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OrderSavedWorkspaceManagerState &&
            runtimeType == other.runtimeType &&
            query == other.query &&
            scope == other.scope &&
            sortMode == other.sortMode;
  }

  @override
  int get hashCode => Object.hash(query, scope, sortMode);
}
