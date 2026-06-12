import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_state.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('manager state defaults to the complete default-order view', () {
    final state = OrderSavedWorkspaceManagerState.initial;
    final view = state.viewFor(savedWorkspaceManagerFixtures);

    expect(state.isDefault, true);
    expect(state.hasQuery, false);
    expect(view.scope, OrderSavedWorkspaceManagerScope.all);
    expect(view.sortMode, OrderSavedWorkspaceManagerSort.defaultOrder);
    expect(view.visibleWorkspaces, savedWorkspaceManagerFixtures);
  });

  test('manager state derives scoped sorted views from current controls', () {
    final state = OrderSavedWorkspaceManagerState.initial
        .withQuery('  pickup  ')
        .withScope(OrderSavedWorkspaceManagerScope.pinned)
        .withSortMode(OrderSavedWorkspaceManagerSort.labelAscending);

    final view = state.viewFor(savedWorkspaceManagerFixtures);

    expect(state.query, 'pickup');
    expect(state.normalizedQuery, 'pickup');
    expect(state.hasQuery, true);
    expect(state.isDefault, false);
    expect(view.query, 'pickup');
    expect(view.scope, OrderSavedWorkspaceManagerScope.pinned);
    expect(view.sortMode, OrderSavedWorkspaceManagerSort.labelAscending);
    expect(view.visibleWorkspaces, [savedWorkspacePinnedPickupPriority]);
  });

  test('manager state transitions preserve value semantics', () {
    final state = OrderSavedWorkspaceManagerState.initial
        .withQuery('morning')
        .withScope(OrderSavedWorkspaceManagerScope.notes)
        .withSortMode(OrderSavedWorkspaceManagerSort.notesFirst);

    expect(
      state,
      const OrderSavedWorkspaceManagerState(
        query: 'morning',
        scope: OrderSavedWorkspaceManagerScope.notes,
        sortMode: OrderSavedWorkspaceManagerSort.notesFirst,
      ),
    );
    expect(state.clearQuery().query, isEmpty);
    expect(state.clearQuery().scope, OrderSavedWorkspaceManagerScope.notes);
    expect(
      state.clearQuery().sortMode,
      OrderSavedWorkspaceManagerSort.notesFirst,
    );
  });
}
