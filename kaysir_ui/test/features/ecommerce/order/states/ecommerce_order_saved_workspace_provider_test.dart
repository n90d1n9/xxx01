import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/models/order_active_filter_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/states/order_saved_workspace_provider.dart';

void main() {
  test('notifier saves and deletes persisted workspaces', () async {
    final store = MemoryOrderSavedWorkspaceStore();
    final repository = OrderSavedWorkspaceRepository(store: store);
    final notifier = OrderSavedWorkspacesNotifier(
      repository: repository,
      profileId: ecommerceDeliveryOrderWorkspaceProfileId,
      autoHydrate: false,
    );
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
    );
    const secondWorkspace = OrderSavedWorkspace(
      id: 'saved_delivery_today',
      label: 'Delivery / Today',
      description: 'Delivery today queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.newest,
    );

    await notifier.saveWorkspace(workspace);
    await notifier.saveWorkspace(secondWorkspace);
    await notifier.flush();

    expect(notifier.state, hasLength(2));
    final profiles = store.snapshot?['profiles'] as Map<Object?, Object?>?;
    expect(
      profiles?[ecommerceDeliveryOrderWorkspaceProfileId],
      isA<List<Object?>>(),
    );

    await notifier.moveWorkspace(
      secondWorkspace.id,
      OrderSavedWorkspaceMoveDirection.earlier,
    );
    await notifier.flush();

    expect(notifier.state.map((workspace) => workspace.id), [
      secondWorkspace.id,
      workspace.id,
    ]);

    await notifier.pinWorkspace(workspace.id, true);
    await notifier.flush();

    final pinnedProfiles =
        store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final pinnedSnapshots =
        pinnedProfiles?[ecommerceDeliveryOrderWorkspaceProfileId]
            as List<Object?>;
    final pinnedSnapshot = pinnedSnapshots
        .cast<Map<Object?, Object?>>()
        .firstWhere((snapshot) => snapshot['id'] == workspace.id);

    expect(
      notifier.state.firstWhere((item) => item.id == workspace.id).isPinned,
      isTrue,
    );
    expect(pinnedSnapshot['isPinned'], isTrue);

    await notifier.renameWorkspace(workspace.id, 'Courier rush');
    await notifier.flush();

    final renamedProfiles =
        store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final renamedSnapshots =
        renamedProfiles?[ecommerceDeliveryOrderWorkspaceProfileId]
            as List<Object?>;
    final renamedSnapshot = renamedSnapshots
        .cast<Map<Object?, Object?>>()
        .firstWhere((snapshot) => snapshot['id'] == workspace.id);

    expect(
      notifier.state.firstWhere((item) => item.id == workspace.id).label,
      'Courier rush',
    );
    expect(renamedSnapshot['label'], 'Courier rush');

    await notifier.updateWorkspace(
      workspace.copyWith(
        label: 'Courier rush',
        filter: const OrderFilter(channelId: 'delivery_app', status: 'packed'),
        sortMode: OrderSortMode.status,
      ),
    );
    await notifier.flush();

    final updatedProfiles =
        store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final updatedSnapshots =
        updatedProfiles?[ecommerceDeliveryOrderWorkspaceProfileId]
            as List<Object?>;
    final updatedSnapshot = updatedSnapshots
        .cast<Map<Object?, Object?>>()
        .firstWhere((snapshot) => snapshot['id'] == workspace.id);

    expect(
      notifier.state
          .firstWhere((item) => item.id == workspace.id)
          .filter
          .status,
      'packed',
    );
    expect(updatedSnapshot['sortMode'], OrderSortMode.status.name);

    await notifier.updateWorkspace(
      secondWorkspace.copyWith(
        filter: const OrderFilter(channelId: 'delivery_app', status: 'packed'),
        sortMode: OrderSortMode.status,
      ),
    );
    await notifier.flush();

    final duplicateBlockedWorkspace = notifier.state.firstWhere(
      (item) => item.id == secondWorkspace.id,
    );
    expect(
      duplicateBlockedWorkspace.filter.status,
      ecommerceOrderAllStatusesFilter,
    );
    expect(duplicateBlockedWorkspace.sortMode, OrderSortMode.newest);

    await notifier.deleteWorkspace(workspace.id);
    await notifier.flush();

    final remainingProfiles =
        store.snapshot?['profiles'] as Map<Object?, Object?>?;

    expect(notifier.state.map((item) => item.id), [secondWorkspace.id]);
    expect(
      remainingProfiles?[ecommerceDeliveryOrderWorkspaceProfileId],
      isA<List<Object?>>(),
    );
  });

  test('notifier duplicates and persists explicit workspace copies', () async {
    final store = MemoryOrderSavedWorkspaceStore();
    final repository = OrderSavedWorkspaceRepository(store: store);
    final notifier = OrderSavedWorkspacesNotifier(
      repository: repository,
      profileId: ecommerceDeliveryOrderWorkspaceProfileId,
      autoHydrate: false,
    );
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
      isPinned: true,
    );

    await notifier.saveWorkspace(workspace);
    await notifier.duplicateWorkspace(workspace.id);
    await notifier.flush();

    final profiles = store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final snapshots =
        profiles?[ecommerceDeliveryOrderWorkspaceProfileId] as List<Object?>;
    final duplicateSnapshot = snapshots
        .cast<Map<Object?, Object?>>()
        .firstWhere(
          (snapshot) => snapshot['id'] == 'saved_delivery_ready_copy',
        );

    expect(notifier.state, hasLength(2));
    expect(notifier.state.last.id, 'saved_delivery_ready_copy');
    expect(notifier.state.last.label, 'Delivery / Ready copy');
    expect(notifier.state.last.isPinned, isFalse);
    expect(
      notifier.state.last.matches(workspace.filter, workspace.sortMode),
      isTrue,
    );
    expect(duplicateSnapshot['label'], 'Delivery / Ready copy');
    expect(duplicateSnapshot['isPinned'], isFalse);
  });

  test('notifier updates and persists workspace descriptions', () async {
    final store = MemoryOrderSavedWorkspaceStore();
    final repository = OrderSavedWorkspaceRepository(store: store);
    final notifier = OrderSavedWorkspacesNotifier(
      repository: repository,
      profileId: ecommerceDeliveryOrderWorkspaceProfileId,
      autoHydrate: false,
    );
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
    );

    await notifier.saveWorkspace(workspace);
    await notifier.updateWorkspaceDescription(
      workspace.id,
      '  Morning courier queue  ',
    );
    await notifier.flush();

    final profiles = store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final snapshots =
        profiles?[ecommerceDeliveryOrderWorkspaceProfileId] as List<Object?>;
    final snapshot = snapshots.cast<Map<Object?, Object?>>().single;

    expect(notifier.state.single.description, 'Morning courier queue');
    expect(notifier.state.single.isDescriptionCustom, isTrue);
    expect(snapshot['description'], 'Morning courier queue');
    expect(snapshot['isDescriptionCustom'], isTrue);

    await notifier.updateWorkspaceDescription(workspace.id, '   ');
    await notifier.flush();

    expect(notifier.state.single.description, 'Morning courier queue');
    expect(notifier.state.single.isDescriptionCustom, isTrue);

    await notifier.resetWorkspaceDescription(workspace.id, const [
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.channel,
        label: 'Channel',
        value: 'Delivery app',
      ),
      OrderActiveFilterSummaryItem(
        type: OrderActiveFilterSummaryType.status,
        label: 'Status',
        value: 'Ready',
      ),
    ]);
    await notifier.flush();

    final resetProfiles = store.snapshot?['profiles'] as Map<Object?, Object?>?;
    final resetSnapshots =
        resetProfiles?[ecommerceDeliveryOrderWorkspaceProfileId]
            as List<Object?>;
    final resetSnapshot = resetSnapshots.cast<Map<Object?, Object?>>().single;

    expect(
      notifier.state.single.description,
      'Channel: Delivery app • Status: Ready',
    );
    expect(notifier.state.single.isDescriptionCustom, isFalse);
    expect(
      resetSnapshot['description'],
      'Channel: Delivery app • Status: Ready',
    );
    expect(resetSnapshot['isDescriptionCustom'], isFalse);
  });

  test(
    'provider hydrates persisted workspaces from repository override',
    () async {
      const workspace = OrderSavedWorkspace(
        id: 'saved_marketplace',
        label: 'Marketplace',
        description: 'Marketplace queue',
        filter: OrderFilter(channelId: 'marketplace_a'),
        sortMode: OrderSortMode.channel,
      );
      final store = MemoryOrderSavedWorkspaceStore(
        initialSnapshot:
            OrderSavedWorkspaceSnapshot.empty
                .withProfileWorkspaces(
                  profileId: ecommerceMarketplaceOrderWorkspaceProfileId,
                  workspaces: const [workspace],
                )
                .toJson(),
      );
      final container = ProviderContainer(
        overrides: [
          ecommerceOrderSavedWorkspaceRepositoryProvider.overrideWithValue(
            OrderSavedWorkspaceRepository(store: store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(
            ecommerceOrderSavedWorkspacesProvider(
              ecommerceMarketplaceOrderWorkspaceProfileId,
            ).notifier,
          )
          .hydrate();

      expect(
        container.read(
          ecommerceOrderSavedWorkspacesProvider(
            ecommerceMarketplaceOrderWorkspaceProfileId,
          ),
        ),
        hasLength(1),
      );
      expect(
        container
            .read(
              ecommerceOrderSavedWorkspacesProvider(
                ecommerceMarketplaceOrderWorkspaceProfileId,
              ),
            )
            .single
            .id,
        workspace.id,
      );
      expect(
        container.read(
          ecommerceOrderSavedWorkspacesProvider(
            ecommerceDeliveryOrderWorkspaceProfileId,
          ),
        ),
        isEmpty,
      );
    },
  );
}
