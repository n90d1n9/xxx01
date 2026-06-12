import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route_resolution.dart';
import 'package:kaysir/features/ecommerce/order/order_screen.dart';
import 'package:kaysir/features/ecommerce/order/states/order_saved_workspace_provider.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_provider.dart';

void main() {
  testWidgets('OrdersScreen surfaces omni-channel activity insight', (
    tester,
  ) async {
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'ecommerce-review',
            kind: OmniChannelActivityKind.order,
            sourceId: 'ecommerce',
            sourceLabel: 'Ecommerce',
            occurredAt: DateTime(2026, 6, 9, 11),
            title: 'Marketplace pickup needs review',
            detail: 'Confirm handoff capacity before accepting pickup.',
            severity: OmniChannelActivitySeverity.review,
            channelId: 'marketplace',
            orderId: 'ECOM-9',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _savedWorkspaceRepositoryOverride(),
          omniChannelActivityInsightProvider.overrideWithValue(insight),
        ],
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );

    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Omni-channel activity needs review'), findsOneWidget);
    expect(
      find.text('Confirm handoff capacity before accepting pickup.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen applies specialized workspace profile', (
    tester,
  ) async {
    String? openedLocation;
    final copiedLocations = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedLocations.add(arguments['text']! as String);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [_savedWorkspaceRepositoryOverride()],
        child: MaterialApp(
          home: OrdersScreen(
            profile: ecommerceMarketplaceOrderWorkspaceProfile,
            launchContext: const OrderWorkspaceLaunchContext(
              sourceProfileId: 'marketplace_operations',
              sourceProfileLabel: 'Marketplace operations',
              orderWorkspaceProfileId: 'marketplace_ops',
              workspaceViewId: 'marketplace_priority',
              workspaceViewLabel: 'Policy priority',
              reason: OrderWorkspaceLaunchReason.commerceWorkspace,
            ),
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('order_workspace_breadcrumbs')),
      findsOneWidget,
    );
    expect(find.text('Commerce'), findsOneWidget);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Opened from Marketplace operations'), findsOneWidget);
    expect(
      find.text('Commerce workspace - marketplace_ops - Policy priority'),
      findsOneWidget,
    );
    expect(find.text('Marketplace all'), findsWidgets);
    expect(find.text('Policy priority'), findsWidgets);
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Policy priority')).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Marketplace all')).selected,
      isFalse,
    );
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Web store'), findsNothing);
    expect(find.text('Delivery app'), findsNothing);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);

    expect(
      find.byKey(const ValueKey('order_workspace_navigation_header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_workspace_link_actions')),
      findsOneWidget,
    );

    await tester.tap(_breadcrumb('orders'));
    await tester.pump();
    expect(openedLocation, Routes.ordersPath);

    await tester.tap(_breadcrumb('profile'));
    await tester.pump();
    expect(openedLocation, Routes.marketplaceOrdersPath);

    final openCurrentLocationButton = find.byKey(
      const ValueKey('order_workspace_open_current_location'),
    );
    await tester.ensureVisible(openCurrentLocationButton);
    await tester.pump();
    await tester.tap(openCurrentLocationButton);
    await tester.pump();

    var workspaceLocation = Uri.parse(openedLocation!);
    expect(workspaceLocation.path, Routes.marketplaceOrdersPath);
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceLaunchContext
          .workspaceViewIdQueryKey],
      'marketplace_priority',
    );

    await tester.tap(
      find.byKey(const ValueKey('order_workspace_copy_current_location')),
    );
    await tester.pump();

    expect(copiedLocations, hasLength(1));
    workspaceLocation = Uri.parse(copiedLocations.single);
    expect(workspaceLocation.path, Routes.marketplaceOrdersPath);
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceLaunchContext
          .workspaceViewIdQueryKey],
      'marketplace_priority',
    );
    expect(find.text('Workspace link copied'), findsOneWidget);

    await tester.ensureVisible(_choiceChip('Marketplace all'));
    await tester.pump();
    await tester.tap(_choiceChip('Marketplace all'));
    await tester.pump();

    workspaceLocation = Uri.parse(openedLocation!);
    expect(workspaceLocation.path, Routes.marketplaceOrdersPath);
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceLaunchContext
          .orderWorkspaceProfileIdQueryKey],
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceLaunchContext
          .workspaceViewIdQueryKey],
      'marketplace_all',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen explains stale launched workspace views', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_savedWorkspaceRepositoryOverride()],
        child: const MaterialApp(
          home: OrdersScreen(
            profile: ecommerceMarketplaceOrderWorkspaceProfile,
            launchContext: OrderWorkspaceLaunchContext(
              sourceProfileId: 'marketplace_operations',
              sourceProfileLabel: 'Marketplace operations',
              orderWorkspaceProfileId: 'marketplace_ops',
              workspaceViewId: 'legacy_priority',
              workspaceViewLabel: 'Legacy priority',
              reason: OrderWorkspaceLaunchReason.commerceWorkspace,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Marketplace all'), findsWidgets);
    expect(
      find.text('Commerce workspace - marketplace_ops - Marketplace all'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Requested Legacy priority is unavailable. Opened Marketplace all.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Marketplace all')).selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Policy priority')).selected,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen applies custom workspace query state', (
    tester,
  ) async {
    String? openedLocation;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [_savedWorkspaceRepositoryOverride()],
        child: MaterialApp(
          home: OrdersScreen(
            profile: ecommerceMarketplaceOrderWorkspaceProfile,
            workspaceQueryState: const OrderWorkspaceQueryState(
              filter: OrderFilter(
                channelId: 'marketplace_a',
                status: 'ready',
                query: 'rush',
              ),
              sortMode: OrderSortMode.status,
            ),
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(find.text('Custom workspace'), findsWidgets);
    expect(find.text('Marketplace all'), findsWidgets);
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Marketplace all')).selected,
      isFalse,
    );

    await tester.tap(
      find.byKey(const ValueKey('order_workspace_open_current_location')),
    );
    await tester.pump();

    final workspaceLocation = Uri.parse(openedLocation!);
    expect(workspaceLocation.path, Routes.marketplaceOrdersPath);
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceQueryState
          .channelIdQueryKey],
      'marketplace_a',
    );
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceQueryState
          .statusQueryKey],
      'ready',
    );
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceQueryState
          .searchQueryKey],
      'rush',
    );
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceQueryState
          .sortModeQueryKey],
      'status',
    );

    final saveWorkspaceButton = find.byKey(
      const ValueKey('order_save_current_workspace'),
    );
    await tester.ensureVisible(saveWorkspaceButton);
    await tester.pump();
    await tester.tap(saveWorkspaceButton);
    await tester.pump();

    expect(find.text('Saved workspaces'), findsOneWidget);
    expect(find.text('Marketplace A / Ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen reanchors modified saved workspace matches', (
    tester,
  ) async {
    const baseShortcut = OrderSavedWorkspace(
      id: 'saved_delivery_base',
      label: 'Delivery base',
      description: 'Delivery app queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.newest,
    );
    const rushShortcut = OrderSavedWorkspace(
      id: 'saved_delivery_rush',
      label: 'Delivery rush',
      description: 'Delivery app rush queue',
      filter: OrderFilter(channelId: 'delivery_app', query: 'rush'),
      sortMode: OrderSortMode.newest,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _savedWorkspaceRepositoryOverride(
            workspaces: const [baseShortcut, rushShortcut],
          ),
        ],
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(_savedWorkspaceChip(baseShortcut.id));
    await tester.pump();
    await tester.tap(_savedWorkspaceChip(baseShortcut.id));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('order_search_field')),
      'rush',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_saved_workspace_modified_notice')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('order_search_field')),
      'late',
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery rush modified'), findsOneWidget);
    expect(find.text('Delivery base modified'), findsNothing);
    expect(find.text('Changed: Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen keeps explicit duplicated workspace active', (
    tester,
  ) async {
    const baseShortcut = OrderSavedWorkspace(
      id: 'saved_delivery_base',
      label: 'Delivery base',
      description: 'Delivery app queue',
      filter: OrderFilter(channelId: 'delivery_app'),
      sortMode: OrderSortMode.newest,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _savedWorkspaceRepositoryOverride(workspaces: const [baseShortcut]),
        ],
        child: const MaterialApp(home: OrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(_savedWorkspaceChip(baseShortcut.id));
    await tester.pump();
    await _openSavedWorkspaceActions(tester, baseShortcut.id);
    await tester.tap(_duplicateSavedWorkspaceButton(baseShortcut.id));
    await tester.pumpAndSettle();

    expect(find.text('Delivery base copy'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_search_field')),
      'late',
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery base copy modified'), findsOneWidget);
    expect(find.text('Delivery base modified'), findsNothing);
    expect(find.text('Changed: Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen explains mismatched launched order profiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_savedWorkspaceRepositoryOverride()],
        child: const MaterialApp(
          home: OrdersScreen(
            profile: ecommerceDeliveryOrderWorkspaceProfile,
            launchContext: OrderWorkspaceLaunchContext(
              sourceProfileId: 'wholesale',
              sourceProfileLabel: 'Wholesale profile',
              orderWorkspaceProfileId: 'wholesale_ops',
              workspaceViewId: 'delivery_ready',
              workspaceViewLabel: 'Courier ready',
              reason: OrderWorkspaceLaunchReason.commerceWorkspace,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Delivery Orders'), findsOneWidget);
    expect(
      find.text('Commerce workspace - delivery_ops - Courier ready'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Requested order profile wholesale_ops is unavailable here. Opened Delivery Orders.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<ChoiceChip>(_choiceChip('Courier ready')).selected,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrdersScreen explains upgraded generic order links', (
    tester,
  ) async {
    String? openedCanonicalRoute;
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'marketplace_operations',
      sourceProfileLabel: 'Marketplace operations',
      orderWorkspaceProfileId: 'marketplace_ops',
      workspaceViewId: 'marketplace_all',
      workspaceViewLabel: 'Marketplace all',
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );
    final routeResolution = ecommerceOrderWorkspaceRouteResolutionForLaunch(
      path: Routes.ordersPath,
      launchContext: launchContext,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [_savedWorkspaceRepositoryOverride()],
        child: MaterialApp(
          home: OrdersScreen(
            profile: routeResolution.route.profile,
            launchContext: launchContext,
            routeResolution: routeResolution,
            onOpenCanonicalRoute: (location) => openedCanonicalRoute = location,
          ),
        ),
      ),
    );

    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(
      find.text('Commerce workspace - marketplace_ops - Marketplace all'),
      findsOneWidget,
    );
    expect(
      find.text('Upgraded generic orders path to Marketplace Orders.'),
      findsOneWidget,
    );
    expect(find.text('Open canonical route'), findsOneWidget);

    await tester.tap(find.text('Open canonical route'));
    await tester.pump();

    expect(openedCanonicalRoute, routeResolution.canonicalLaunchLocation);
    expect(tester.takeException(), isNull);
  });
}

Finder _choiceChip(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip));
}

Finder _breadcrumb(String id) {
  return find.byKey(ValueKey('order_workspace_breadcrumb_$id'));
}

Finder _savedWorkspaceChip(String id) {
  return find.byKey(ValueKey('order_saved_workspace_$id'));
}

Future<void> _openSavedWorkspaceActions(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey('order_saved_workspace_actions_$id')));
  await tester.pumpAndSettle();
}

Finder _duplicateSavedWorkspaceButton(String id) {
  return find.byKey(ValueKey('order_saved_workspace_duplicate_$id'));
}

dynamic _savedWorkspaceRepositoryOverride({
  List<OrderSavedWorkspace> workspaces = const [],
  String profileId = ecommerceAllCommerceOrderWorkspaceProfileId,
}) {
  return ecommerceOrderSavedWorkspaceRepositoryProvider.overrideWithValue(
    OrderSavedWorkspaceRepository(
      store: MemoryOrderSavedWorkspaceStore(
        initialSnapshot:
            workspaces.isEmpty
                ? null
                : OrderSavedWorkspaceSnapshot.empty
                    .withProfileWorkspaces(
                      profileId: profileId,
                      workspaces: workspaces,
                    )
                    .toJson(),
      ),
    ),
  );
}
