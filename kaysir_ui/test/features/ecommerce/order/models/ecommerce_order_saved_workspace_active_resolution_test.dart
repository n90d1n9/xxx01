import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';

void main() {
  test(
    'active resolution prefers an explicitly tracked matching duplicate',
    () {
      const filter = OrderFilter(channelId: 'delivery_app');
      const base = OrderSavedWorkspace(
        id: 'saved_delivery_base',
        label: 'Delivery base',
        description: 'Delivery queue',
        filter: filter,
        sortMode: OrderSortMode.newest,
      );
      const duplicate = OrderSavedWorkspace(
        id: 'saved_delivery_base_copy',
        label: 'Delivery base copy',
        description: 'Delivery queue',
        filter: filter,
        sortMode: OrderSortMode.newest,
      );

      final resolution = ecommerceOrderSavedWorkspaceActiveResolution(
        workspaces: const [base, duplicate],
        trackedWorkspaceId: duplicate.id,
        filter: filter,
        sortMode: OrderSortMode.newest,
      );

      expect(resolution.matchingWorkspace, base);
      expect(resolution.trackedWorkspace, duplicate);
      expect(resolution.activeWorkspace, duplicate);
      expect(resolution.activeWorkspaceId, duplicate.id);
    },
  );

  test('active resolution reanchors to another matching workspace', () {
    const baseFilter = OrderFilter(channelId: 'delivery_app');
    const rushFilter = OrderFilter(channelId: 'delivery_app', query: 'rush');
    const base = OrderSavedWorkspace(
      id: 'saved_delivery_base',
      label: 'Delivery base',
      description: 'Delivery queue',
      filter: baseFilter,
      sortMode: OrderSortMode.newest,
    );
    const rush = OrderSavedWorkspace(
      id: 'saved_delivery_rush',
      label: 'Delivery rush',
      description: 'Delivery rush queue',
      filter: rushFilter,
      sortMode: OrderSortMode.newest,
    );

    final resolution = ecommerceOrderSavedWorkspaceActiveResolution(
      workspaces: const [base, rush],
      trackedWorkspaceId: base.id,
      filter: rushFilter,
      sortMode: OrderSortMode.newest,
    );

    expect(resolution.trackedWorkspace, base);
    expect(resolution.matchingWorkspace, rush);
    expect(resolution.activeWorkspace, rush);
    expect(resolution.activeWorkspaceId, rush.id);
  });

  test(
    'active resolution keeps modified tracked workspace without a match',
    () {
      const baseFilter = OrderFilter(channelId: 'delivery_app');
      const modifiedFilter = OrderFilter(
        channelId: 'delivery_app',
        query: 'late',
      );
      const base = OrderSavedWorkspace(
        id: 'saved_delivery_base',
        label: 'Delivery base',
        description: 'Delivery queue',
        filter: baseFilter,
        sortMode: OrderSortMode.newest,
      );

      final resolution = ecommerceOrderSavedWorkspaceActiveResolution(
        workspaces: const [base],
        trackedWorkspaceId: base.id,
        filter: modifiedFilter,
        sortMode: OrderSortMode.newest,
      );

      expect(resolution.matchingWorkspace, isNull);
      expect(resolution.trackedWorkspace, base);
      expect(resolution.activeWorkspace, base);
      expect(
        resolution.matchesTrackedWorkspace(
          filter: modifiedFilter,
          sortMode: OrderSortMode.newest,
        ),
        isFalse,
      );
    },
  );

  test('active resolution falls back to matching workspace only', () {
    const filter = OrderFilter(channelId: 'delivery_app');
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery',
      label: 'Delivery',
      description: 'Delivery queue',
      filter: filter,
      sortMode: OrderSortMode.newest,
    );

    final resolution = ecommerceOrderSavedWorkspaceActiveResolution(
      workspaces: const [workspace],
      trackedWorkspaceId: 'missing_workspace',
      filter: filter,
      sortMode: OrderSortMode.newest,
    );

    expect(resolution.trackedWorkspace, isNull);
    expect(resolution.matchingWorkspace, workspace);
    expect(resolution.activeWorkspace, workspace);
  });
}
