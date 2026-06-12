import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/order/models/order_active_filter_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';

void main() {
  test('saved workspace derives stable identity and readable copy', () {
    const filter = OrderFilter(
      channelId: 'delivery_app',
      status: 'ready',
      query: 'Amina',
    );
    const sortMode = OrderSortMode.highestValue;
    final summary = ecommerceOrderActiveFilterSummary(
      filter: filter,
      sortMode: sortMode,
      channels: const [SalesChannels.deliveryApp],
      fulfillmentModes: const [
        OrderFulfillmentOption(key: 'delivery', label: 'Delivery'),
      ],
    );

    final workspace = ecommerceOrderSavedWorkspaceFromState(
      filter: filter,
      sortMode: sortMode,
      summaryItems: summary,
    );

    expect(workspace.id, contains('delivery_app'));
    expect(workspace.label, 'Delivery app / Ready');
    expect(workspace.description, contains('Search: Amina'));
    expect(workspace.matches(filter, sortMode), isTrue);
    expect(workspace.toWorkspaceContext().isPreset, isFalse);
  });

  test('saved workspace collection helpers dedupe and remove workspaces', () {
    const filter = OrderFilter(channelId: 'delivery_app');
    const sortMode = OrderSortMode.channel;
    final workspace = ecommerceOrderSavedWorkspaceFromState(
      filter: filter,
      sortMode: sortMode,
      summaryItems: ecommerceOrderActiveFilterSummary(
        filter: filter,
        sortMode: sortMode,
      ),
    );

    final savedOnce = ecommerceOrderSavedWorkspacesWithSaved(
      const [],
      workspace,
    );
    final savedTwice = ecommerceOrderSavedWorkspacesWithSaved(
      savedOnce,
      workspace,
    );

    expect(savedOnce, hasLength(1));
    expect(savedTwice, hasLength(1));
    expect(
      ecommerceOrderSavedWorkspaceForState(
        workspaces: savedTwice,
        filter: filter,
        sortMode: sortMode,
      ),
      workspace,
    );
    expect(
      ecommerceOrderSavedWorkspacesWithout(
        workspaces: savedTwice,
        workspaceId: workspace.id,
      ),
      isEmpty,
    );
  });

  test('saved workspace JSON round trips filter and sort state', () {
    const filter = OrderFilter(
      channelId: 'marketplace_a',
      fulfillmentModeKey: 'delivery',
      status: 'ready',
      timeScope: OrderTimeScope.last7Days,
      paymentScope: OrderPaymentScope.externalSettlement,
      attentionScope: OrderAttentionScope.highPriority,
      query: 'rush',
    );
    const workspace = OrderSavedWorkspace(
      id: 'saved_marketplace_ready',
      label: 'Marketplace / Ready',
      description: 'Channel: Marketplace - Status: Ready',
      isDescriptionCustom: true,
      filter: filter,
      sortMode: OrderSortMode.status,
      isPinned: true,
    );

    final restored = OrderSavedWorkspace.fromJson(workspace.toJson());

    expect(restored.id, workspace.id);
    expect(restored.label, workspace.label);
    expect(restored.description, workspace.description);
    expect(restored.isDescriptionCustom, isTrue);
    expect(restored.sortMode, workspace.sortMode);
    expect(restored.isPinned, isTrue);
    expect(ecommerceOrderFiltersEqual(restored.filter, filter), isTrue);
    expect(restored.toJson(), workspace.toJson());
  });

  test('saved workspace helpers update pins and display pinned first', () {
    const first = OrderSavedWorkspace(
      id: 'saved_first',
      label: 'First',
      description: 'First workspace',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.channel,
    );
    const second = OrderSavedWorkspace(
      id: 'saved_second',
      label: 'Second',
      description: 'Second workspace',
      filter: OrderFilter(channelId: 'marketplace_a'),
      sortMode: OrderSortMode.attention,
    );

    final pinned = ecommerceOrderSavedWorkspacesWithPinned(
      workspaces: const [first, second],
      workspaceId: second.id,
      isPinned: true,
    );
    final display = ecommerceOrderSavedWorkspacesForDisplay(pinned);

    expect(pinned.first.id, first.id);
    expect(pinned.last.isPinned, isTrue);
    expect(display.map((workspace) => workspace.id), [second.id, first.id]);
  });

  test('saved workspace helpers rename labels with trimmed input', () {
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.attention,
    );

    final renamed = ecommerceOrderSavedWorkspacesWithRenamed(
      workspaces: const [workspace],
      workspaceId: workspace.id,
      label: '  Courier rush  ',
    );
    final blankRename = ecommerceOrderSavedWorkspacesWithRenamed(
      workspaces: renamed,
      workspaceId: workspace.id,
      label: '   ',
    );

    expect(renamed.single.label, 'Courier rush');
    expect(blankRename.single.label, 'Courier rush');
  });

  test('saved workspace helpers update descriptions with trimmed input', () {
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.attention,
    );

    final described = ecommerceOrderSavedWorkspacesWithDescription(
      workspaces: const [workspace],
      workspaceId: workspace.id,
      description: '  Morning courier queue  ',
    );
    final blankDescription = ecommerceOrderSavedWorkspacesWithDescription(
      workspaces: described,
      workspaceId: workspace.id,
      description: '   ',
    );
    final autoDescription = ecommerceOrderSavedWorkspacesWithAutoDescription(
      workspaces: described,
      workspaceId: workspace.id,
      summaryItems: ecommerceOrderActiveFilterSummary(
        filter: workspace.filter,
        sortMode: workspace.sortMode,
        channels: const [SalesChannels.deliveryApp],
      ),
    );

    expect(described.single.description, 'Morning courier queue');
    expect(described.single.isDescriptionCustom, isTrue);
    expect(blankDescription.single.description, 'Morning courier queue');
    expect(blankDescription.single.isDescriptionCustom, isTrue);
    expect(autoDescription.single.description, contains('Delivery app'));
    expect(autoDescription.single.isDescriptionCustom, isFalse);
  });

  test('saved workspace helpers duplicate with unique identity and label', () {
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
      isPinned: true,
    );

    final duplicate = ecommerceOrderSavedWorkspaceDuplicate(
      workspaces: const [workspace],
      workspaceId: workspace.id,
    );
    final duplicated = ecommerceOrderSavedWorkspacesWithDuplicated(
      workspaces: const [workspace],
      workspaceId: workspace.id,
    );
    final duplicatedTwice = ecommerceOrderSavedWorkspacesWithDuplicated(
      workspaces: duplicated,
      workspaceId: workspace.id,
    );

    expect(duplicate, isNotNull);
    expect(duplicate!.id, 'saved_delivery_ready_copy');
    expect(duplicate.label, 'Delivery / Ready copy');
    expect(duplicate.description, workspace.description);
    expect(duplicate.isPinned, isFalse);
    expect(duplicate.matches(workspace.filter, workspace.sortMode), isTrue);
    expect(duplicated.map((item) => item.id), [
      workspace.id,
      'saved_delivery_ready_copy',
    ]);
    expect(duplicatedTwice.map((item) => item.id), [
      workspace.id,
      'saved_delivery_ready_copy',
      'saved_delivery_ready_copy_2',
    ]);
    expect(duplicatedTwice.last.label, 'Delivery / Ready copy 2');
    expect(
      ecommerceOrderSavedWorkspacesWithDuplicated(
        workspaces: const [workspace],
        workspaceId: 'missing_workspace',
      ),
      [workspace],
    );
  });

  test('saved workspace helpers update tracked state by identity', () {
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
      isPinned: true,
    );
    const duplicateStateWorkspace = OrderSavedWorkspace(
      id: 'saved_web_ready',
      label: 'Web ready',
      description: 'Web ready queue',
      filter: OrderFilter(channelId: 'web_store', status: 'ready'),
      sortMode: OrderSortMode.status,
    );
    const updatedFilter = OrderFilter(
      channelId: 'delivery_app',
      status: 'packed',
      query: 'Amina',
    );
    final summary = ecommerceOrderActiveFilterSummary(
      filter: updatedFilter,
      sortMode: OrderSortMode.highestValue,
      channels: const [SalesChannels.deliveryApp],
    );

    final updated = ecommerceOrderSavedWorkspaceWithState(
      workspace: workspace,
      filter: updatedFilter,
      sortMode: OrderSortMode.highestValue,
      summaryItems: summary,
    );
    final customUpdated = ecommerceOrderSavedWorkspaceWithState(
      workspace: workspace.copyWith(
        description: 'Morning courier queue',
        isDescriptionCustom: true,
      ),
      filter: updatedFilter,
      sortMode: OrderSortMode.highestValue,
      summaryItems: summary,
    );
    final collection = ecommerceOrderSavedWorkspacesWithState(
      workspaces: const [workspace, duplicateStateWorkspace],
      workspaceId: workspace.id,
      filter: updatedFilter,
      sortMode: OrderSortMode.highestValue,
      summaryItems: summary,
    );
    final duplicateBlocked = ecommerceOrderSavedWorkspacesWithState(
      workspaces: collection,
      workspaceId: workspace.id,
      filter: duplicateStateWorkspace.filter,
      sortMode: duplicateStateWorkspace.sortMode,
      summaryItems: const [],
    );
    final distinctDuplicateBlocked =
        ecommerceOrderSavedWorkspacesWithDistinctUpdated(
          collection,
          duplicateStateWorkspace.copyWith(
            filter: updatedFilter,
            sortMode: OrderSortMode.highestValue,
          ),
        );
    final changedFields = ecommerceOrderSavedWorkspaceChangedFields(
      workspace: workspace,
      filter: updatedFilter,
      sortMode: OrderSortMode.highestValue,
    );

    expect(updated.id, workspace.id);
    expect(updated.label, workspace.label);
    expect(updated.isPinned, isTrue);
    expect(updated.sortMode, OrderSortMode.highestValue);
    expect(updated.description, contains('Search: Amina'));
    expect(updated.isDescriptionCustom, isFalse);
    expect(customUpdated.description, 'Morning courier queue');
    expect(customUpdated.isDescriptionCustom, isTrue);
    expect(customUpdated.filter.status, 'packed');
    expect(collection.first.filter.status, 'packed');
    expect(
      ecommerceOrderSavedWorkspaceById(
        workspaces: collection,
        workspaceId: workspace.id,
      )?.sortMode,
      OrderSortMode.highestValue,
    );
    expect(duplicateBlocked.first.filter.status, 'packed');
    expect(changedFields, [
      OrderActiveFilterSummaryType.status,
      OrderActiveFilterSummaryType.search,
      OrderActiveFilterSummaryType.sort,
    ]);
    expect(
      ecommerceOrderSavedWorkspaceChangeSummary(
        workspace: workspace,
        filter: updatedFilter,
        sortMode: OrderSortMode.highestValue,
      ),
      'Changed: Status, Search, Sort',
    );
    expect(
      ecommerceOrderSavedWorkspaceChangeSummary(
        workspace: workspace,
        filter: updatedFilter.copyWith(timeScope: OrderTimeScope.today),
        sortMode: OrderSortMode.highestValue,
        visibleFieldLimit: 2,
      ),
      'Changed: Status, Time +2 more',
    );
    expect(
      distinctDuplicateBlocked
          .firstWhere((item) => item.id == duplicateStateWorkspace.id)
          .filter
          .channelId,
      'web_store',
    );
  });

  test('saved workspace helpers move within pinned and unpinned groups', () {
    const first = OrderSavedWorkspace(
      id: 'saved_first',
      label: 'First',
      description: 'First workspace',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.channel,
    );
    const second = OrderSavedWorkspace(
      id: 'saved_second',
      label: 'Second',
      description: 'Second workspace',
      filter: OrderFilter(channelId: 'marketplace_a'),
      sortMode: OrderSortMode.attention,
      isPinned: true,
    );
    const third = OrderSavedWorkspace(
      id: 'saved_third',
      label: 'Third',
      description: 'Third workspace',
      filter: OrderFilter(channelId: 'web_store'),
      sortMode: OrderSortMode.newest,
      isPinned: true,
    );
    const fourth = OrderSavedWorkspace(
      id: 'saved_fourth',
      label: 'Fourth',
      description: 'Fourth workspace',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.status,
    );

    final movedPinned = ecommerceOrderSavedWorkspacesWithMoved(
      workspaces: const [first, second, fourth, third],
      workspaceId: third.id,
      direction: OrderSavedWorkspaceMoveDirection.earlier,
    );
    final movedUnpinned = ecommerceOrderSavedWorkspacesWithMoved(
      workspaces: movedPinned,
      workspaceId: first.id,
      direction: OrderSavedWorkspaceMoveDirection.later,
    );

    expect(
      ecommerceOrderSavedWorkspacesForDisplay(
        movedPinned,
      ).map((workspace) => workspace.id),
      [third.id, second.id, first.id, fourth.id],
    );
    expect(
      ecommerceOrderSavedWorkspacesForDisplay(
        movedUnpinned,
      ).map((workspace) => workspace.id),
      [third.id, second.id, fourth.id, first.id],
    );
    expect(
      ecommerceOrderSavedWorkspaceCanMove(
        workspaces: movedUnpinned,
        workspaceId: third.id,
        direction: OrderSavedWorkspaceMoveDirection.earlier,
      ),
      isFalse,
    );
  });
}
