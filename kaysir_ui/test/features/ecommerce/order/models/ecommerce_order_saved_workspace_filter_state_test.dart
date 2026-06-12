import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_active_filter_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';

void main() {
  test('filter state keeps an explicitly tracked duplicate active', () {
    const filter = OrderFilter(channelId: 'delivery_app');
    const original = OrderSavedWorkspace(
      id: 'saved_delivery',
      label: 'Delivery',
      description: 'Delivery queue',
      filter: filter,
      sortMode: OrderSortMode.newest,
    );
    const duplicate = OrderSavedWorkspace(
      id: 'saved_delivery_copy',
      label: 'Delivery copy',
      description: 'Delivery queue',
      filter: filter,
      sortMode: OrderSortMode.newest,
    );

    final state = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [original, duplicate],
      activeSavedWorkspaceId: duplicate.id,
      filter: filter,
      sortMode: OrderSortMode.newest,
      workspaceContext: _customContext(filter: filter),
      activeFilterSummary: const [_channelSummary],
      canSaveWorkspace: true,
    );

    expect(state.matchingWorkspace, original);
    expect(state.trackedWorkspace, duplicate);
    expect(state.activeWorkspace, duplicate);
    expect(state.isActiveWorkspaceModified, isFalse);
    expect(state.canSaveCurrentWorkspace, isFalse);
  });

  test('filter state explains modified tracked workspaces', () {
    const savedFilter = OrderFilter(channelId: 'delivery_app');
    const activeFilter = OrderFilter(
      channelId: 'delivery_app',
      status: 'ready',
    );
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery',
      label: 'Delivery',
      description: 'Delivery queue',
      filter: savedFilter,
      sortMode: OrderSortMode.newest,
    );

    final state = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [workspace],
      activeSavedWorkspaceId: workspace.id,
      filter: activeFilter,
      sortMode: OrderSortMode.newest,
      workspaceContext: _customContext(filter: activeFilter),
      activeFilterSummary: const [_channelSummary, _statusSummary],
      canSaveWorkspace: true,
    );

    expect(state.matchingWorkspace, isNull);
    expect(state.activeWorkspace, workspace);
    expect(state.isActiveWorkspaceModified, isTrue);
    expect(state.activeWorkspaceChangeSummary, 'Changed: Status');
    expect(state.canSaveCurrentWorkspace, isTrue);
    expect(state.shouldShowSavedWorkspacePanel, isTrue);
  });

  test('filter state only allows saving custom non-duplicate states', () {
    const filter = OrderFilter(channelId: 'delivery_app');
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery',
      label: 'Delivery',
      description: 'Delivery queue',
      filter: filter,
      sortMode: OrderSortMode.newest,
    );

    final unavailableHandler = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [],
      activeSavedWorkspaceId: null,
      filter: filter,
      sortMode: OrderSortMode.newest,
      workspaceContext: _customContext(filter: filter),
      activeFilterSummary: const [_channelSummary],
      canSaveWorkspace: false,
    );
    final presetContext = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [],
      activeSavedWorkspaceId: null,
      filter: filter,
      sortMode: OrderSortMode.newest,
      workspaceContext: OrderWorkspaceContext.fromView(
        ecommerceAllOrdersWorkspaceView,
      ),
      activeFilterSummary: const [_channelSummary],
      canSaveWorkspace: true,
    );
    final duplicateState = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [workspace],
      activeSavedWorkspaceId: null,
      filter: filter,
      sortMode: OrderSortMode.newest,
      workspaceContext: _customContext(filter: filter),
      activeFilterSummary: const [_channelSummary],
      canSaveWorkspace: true,
    );
    final saveable = ecommerceOrderSavedWorkspaceFilterState(
      savedWorkspaces: const [],
      activeSavedWorkspaceId: null,
      filter: filter,
      sortMode: OrderSortMode.newest,
      workspaceContext: _customContext(filter: filter),
      activeFilterSummary: const [_channelSummary],
      canSaveWorkspace: true,
    );

    expect(unavailableHandler.canSaveCurrentWorkspace, isFalse);
    expect(presetContext.canSaveCurrentWorkspace, isFalse);
    expect(duplicateState.canSaveCurrentWorkspace, isFalse);
    expect(saveable.canSaveCurrentWorkspace, isTrue);
  });
}

const _channelSummary = OrderActiveFilterSummaryItem(
  type: OrderActiveFilterSummaryType.channel,
  label: 'Channel',
  value: 'Delivery app',
);

const _statusSummary = OrderActiveFilterSummaryItem(
  type: OrderActiveFilterSummaryType.status,
  label: 'Status',
  value: 'Ready',
);

OrderWorkspaceContext _customContext({required OrderFilter filter}) {
  return OrderWorkspaceContext(
    id: 'custom_workspace',
    label: 'Custom workspace',
    description: 'Manual filters or sorting are active.',
    isPreset: false,
    filter: filter,
    sortMode: OrderSortMode.newest,
  );
}
