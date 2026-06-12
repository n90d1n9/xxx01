import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace_manager_view.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test('manager view computes counts independently from visible rows', () {
    final view = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerFixtures,
      query: '  delivery  ',
    );

    expect(view.query, 'delivery');
    expect(view.workspaceCount, 3);
    expect(view.pinnedCount, 1);
    expect(view.noteCount, 1);
    expect(view.visibleWorkspaces, [savedWorkspaceDeliveryToday]);
    expect(view.isEmpty, isFalse);
  });

  test('manager view filters by scope', () {
    final pinnedView = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerFixtures,
      scope: OrderSavedWorkspaceManagerScope.pinned,
    );
    final notesView = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerFixtures,
      scope: OrderSavedWorkspaceManagerScope.notes,
    );

    expect(pinnedView.visibleWorkspaces, [savedWorkspacePinnedPickupPriority]);
    expect(notesView.visibleWorkspaces, [savedWorkspaceDeliveryToday]);
  });

  test('manager view searches label, description, and id', () {
    expect(_visibleIds('MORNING'), [savedWorkspaceDeliveryToday.id]);
    expect(_visibleIds('exceptions'), [savedWorkspacePinnedPickupPriority.id]);
    expect(_visibleIds('saved_web'), [savedWorkspaceWebOverdue.id]);
    expect(_visibleIds('missing'), isEmpty);
  });

  test('manager view sorts visible workspaces without changing counts', () {
    final labelView = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerUnsortedFixtures,
      sortMode: OrderSavedWorkspaceManagerSort.labelAscending,
    );
    final pinnedView = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerFixtures,
      sortMode: OrderSavedWorkspaceManagerSort.pinnedFirst,
    );
    final notesView = ecommerceOrderSavedWorkspaceManagerView(
      workspaces: savedWorkspaceManagerFixtures,
      sortMode: OrderSavedWorkspaceManagerSort.notesFirst,
    );

    expect(labelView.visibleWorkspaces.map((workspace) => workspace.id), [
      savedWorkspaceDeliveryToday.id,
      savedWorkspacePinnedPickupPriority.id,
      savedWorkspaceWebOverdue.id,
    ]);
    expect(pinnedView.visibleWorkspaces.map((workspace) => workspace.id), [
      savedWorkspacePinnedPickupPriority.id,
      savedWorkspaceDeliveryToday.id,
      savedWorkspaceWebOverdue.id,
    ]);
    expect(notesView.visibleWorkspaces.map((workspace) => workspace.id), [
      savedWorkspaceDeliveryToday.id,
      savedWorkspacePinnedPickupPriority.id,
      savedWorkspaceWebOverdue.id,
    ]);
    expect(labelView.workspaceCount, 3);
    expect(pinnedView.pinnedCount, 1);
    expect(notesView.noteCount, 1);
  });
}

List<String> _visibleIds(String query) {
  return ecommerceOrderSavedWorkspaceManagerView(
    workspaces: savedWorkspaceManagerFixtures,
    query: query,
  ).visibleWorkspaces.map((workspace) => workspace.id).toList(growable: false);
}
