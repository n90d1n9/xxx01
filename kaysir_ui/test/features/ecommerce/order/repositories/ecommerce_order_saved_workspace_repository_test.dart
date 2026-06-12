import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/repositories/order_saved_workspace_repository.dart';

void main() {
  test('repository saves and loads profile-scoped workspaces', () async {
    final store = MemoryOrderSavedWorkspaceStore();
    final repository = OrderSavedWorkspaceRepository(store: store);
    const workspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Channel: Delivery - Status: Ready',
      filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
      sortMode: OrderSortMode.attention,
    );

    await repository.save(const [
      workspace,
    ], profileId: ecommerceDeliveryOrderWorkspaceProfileId);

    final restored = await repository.load(
      profileId: ecommerceDeliveryOrderWorkspaceProfileId,
    );
    final otherProfile = await repository.load(
      profileId: ecommerceMarketplaceOrderWorkspaceProfileId,
    );

    expect(restored, hasLength(1));
    expect(restored.single.id, workspace.id);
    expect(restored.single.label, workspace.label);
    expect(restored.single.sortMode, workspace.sortMode);
    expect(
      ecommerceOrderFiltersEqual(restored.single.filter, workspace.filter),
      isTrue,
    );
    expect(otherProfile, isEmpty);
    expect(store.snapshot?['profiles'], isA<Map<Object?, Object?>>());
  });

  test('repository keeps saved workspaces isolated per profile', () async {
    final store = MemoryOrderSavedWorkspaceStore();
    final repository = OrderSavedWorkspaceRepository(store: store);
    const marketplaceWorkspace = OrderSavedWorkspace(
      id: 'saved_marketplace_ready',
      label: 'Marketplace / Ready',
      description: 'Marketplace ready queue',
      filter: OrderFilter(channelId: 'marketplace_a'),
      sortMode: OrderSortMode.channel,
    );
    const deliveryWorkspace = OrderSavedWorkspace(
      id: 'saved_delivery_ready',
      label: 'Delivery / Ready',
      description: 'Delivery ready queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.attention,
    );

    await repository.save(const [
      marketplaceWorkspace,
    ], profileId: ecommerceMarketplaceOrderWorkspaceProfileId);
    await repository.save(const [
      deliveryWorkspace,
    ], profileId: ecommerceDeliveryOrderWorkspaceProfileId);

    expect(
      (await repository.load(
        profileId: ecommerceMarketplaceOrderWorkspaceProfileId,
      )).single.id,
      marketplaceWorkspace.id,
    );
    expect(
      (await repository.load(
        profileId: ecommerceDeliveryOrderWorkspaceProfileId,
      )).single.id,
      deliveryWorkspace.id,
    );
  });

  test('repository reads legacy snapshots into the default profile', () async {
    final repository = OrderSavedWorkspaceRepository(
      store: MemoryOrderSavedWorkspaceStore(
        initialSnapshot: const {
          'workspaces': [
            'bad',
            {
              'id': 'saved_marketplace',
              'label': 'Marketplace',
              'description': 'Marketplace queue',
              'filter': {'channelId': 'marketplace_a'},
              'sortMode': 'channel',
            },
          ],
        },
      ),
    );

    final restored = await repository.load();
    final scoped = await repository.load(
      profileId: ecommerceMarketplaceOrderWorkspaceProfileId,
    );

    expect(restored, hasLength(1));
    expect(restored.single.id, 'saved_marketplace');
    expect(restored.single.filter.channelId, 'marketplace_a');
    expect(restored.single.sortMode, OrderSortMode.channel);
    expect(scoped, isEmpty);
  });
}
