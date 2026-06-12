import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_screen_state.dart';

void main() {
  test('screen state resolves query state before profile defaults', () {
    const queryState = OrderWorkspaceQueryState(
      filter: OrderFilter(channelId: 'marketplace_a', status: 'ready'),
      sortMode: OrderSortMode.status,
    );

    final state = OrderWorkspaceScreenState.resolve(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      workspaceQueryState: queryState,
    );

    expect(state.filter.channelId, 'marketplace_a');
    expect(state.filter.status, 'ready');
    expect(state.sortMode, OrderSortMode.status);
    expect(state.activeSavedWorkspaceId, isNull);
    expect(
      state.entryContext.profile.id,
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
  });

  test('screen state applies workspace views and creates locations', () {
    final state = OrderWorkspaceScreenState.resolve(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      launchContext: const OrderWorkspaceLaunchContext(
        sourceProfileId: 'marketplace_ops',
        sourceProfileLabel: 'Marketplace operations',
        orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
        reason: OrderWorkspaceLaunchReason.commerceWorkspace,
      ),
    );
    final view = ecommerceMarketplaceOrderWorkspaceProfile.workspaceViews
        .firstWhere((view) => view.id == 'marketplace_priority');

    final applied = state.withWorkspaceView(view);
    final location = state.locationForWorkspaceView(view);

    expect(state.changesWorkspaceView(view), isTrue);
    expect(applied.filter, view.filter);
    expect(applied.sortMode, view.sortMode);
    expect(applied.activeSavedWorkspaceId, isNull);
    expect(location, contains('marketplace_priority'));
    expect(location, contains(ecommerceMarketplaceOrderWorkspaceProfileId));
  });

  test('screen state applies and clears saved workspace activity', () {
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery',
      label: 'Delivery',
      description: 'Delivery queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.channel,
    );
    const otherWorkspace = OrderSavedWorkspace(
      id: 'saved_marketplace',
      label: 'Marketplace',
      description: 'Marketplace queue',
      filter: OrderFilter(channelId: 'marketplace_a'),
      sortMode: OrderSortMode.channel,
    );
    final state = OrderWorkspaceScreenState.resolve(
      profile: ecommerceAllCommerceOrderWorkspaceProfile,
    );

    final applied = state.withSavedWorkspace(workspace);
    final retained = applied.withDeletedSavedWorkspace(otherWorkspace);
    final cleared = applied.withDeletedSavedWorkspace(workspace);

    expect(state.changesSavedWorkspace(workspace), isTrue);
    expect(applied.filter, workspace.filter);
    expect(applied.sortMode, workspace.sortMode);
    expect(applied.activeSavedWorkspaceId, workspace.id);
    expect(retained.activeSavedWorkspaceId, workspace.id);
    expect(cleared.activeSavedWorkspaceId, isNull);
  });

  test('screen state reanchors active workspace after control changes', () {
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
    final state = OrderWorkspaceScreenState.resolve(
      profile: ecommerceAllCommerceOrderWorkspaceProfile,
    ).withSavedWorkspace(base);

    final reanchored = state.withFilterFromWorkspaceControls(
      filter: rushFilter,
      savedWorkspaces: const [base, rush],
    );

    expect(reanchored.filter, rushFilter);
    expect(reanchored.activeSavedWorkspaceId, rush.id);
  });

  test('screen input comparison detects meaningful changes', () {
    const firstQuery = OrderWorkspaceQueryState(
      filter: OrderFilter(query: 'rush'),
      sortMode: OrderSortMode.newest,
    );
    const sameQuery = OrderWorkspaceQueryState(
      filter: OrderFilter(query: 'rush'),
      sortMode: OrderSortMode.newest,
    );
    const changedQuery = OrderWorkspaceQueryState(
      filter: OrderFilter(query: 'late'),
      sortMode: OrderSortMode.newest,
    );

    expect(
      ecommerceOrderWorkspaceScreenInputsChanged(
        previousProfile: ecommerceAllCommerceOrderWorkspaceProfile,
        nextProfile: ecommerceAllCommerceOrderWorkspaceProfile,
        previousLaunchContext: null,
        nextLaunchContext: null,
        previousQueryState: firstQuery,
        nextQueryState: sameQuery,
        previousRouteResolution: null,
        nextRouteResolution: null,
      ),
      isFalse,
    );
    expect(
      ecommerceOrderWorkspaceScreenInputsChanged(
        previousProfile: ecommerceAllCommerceOrderWorkspaceProfile,
        nextProfile: ecommerceAllCommerceOrderWorkspaceProfile,
        previousLaunchContext: null,
        nextLaunchContext: null,
        previousQueryState: firstQuery,
        nextQueryState: changedQuery,
        previousRouteResolution: null,
        nextRouteResolution: null,
      ),
      isTrue,
    );
    expect(
      ecommerceOrderWorkspaceScreenInputsChanged(
        previousProfile: ecommerceAllCommerceOrderWorkspaceProfile,
        nextProfile: ecommerceMarketplaceOrderWorkspaceProfile,
        previousLaunchContext: null,
        nextLaunchContext: null,
        previousQueryState: null,
        nextQueryState: null,
        previousRouteResolution: null,
        nextRouteResolution: null,
      ),
      isTrue,
    );
  });
}
