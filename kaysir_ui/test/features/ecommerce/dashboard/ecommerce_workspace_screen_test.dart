import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/screen.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/presentation_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/repositories/workspace_profile_preferences_repository.dart';
import 'package:kaysir/features/ecommerce/dashboard/states/workspace_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  testWidgets('Screen follows presentation profile order', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _profilePreferencesRepositoryOverride(),
          presentationProfileProvider.overrideWithValue(
            PresentationProfile.operationsFirst,
          ),
        ],
        child: const MaterialApp(home: Screen()),
      ),
    );

    final operationsTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_operations')),
    );
    final headerTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_header')),
    );

    expect(operationsTop.dy, lessThan(headerTop.dy));
    expect(find.text('Commerce Workspace'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen shows the active product profile', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _profilePreferencesRepositoryOverride(),
          productProfileIdProvider.overrideWith(
            (ref) => _profileIdNotifier('operations_first'),
          ),
        ],
        child: const MaterialApp(home: Screen()),
      ),
    );

    expect(find.text('Profile | Operations first commerce'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen review orders follows active profile route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Routes.routePath,
      routes: [
        GoRoute(
          path: Routes.routePath,
          builder: (context, state) => const Screen(),
        ),
        GoRoute(
          path: Routes.marketplaceOrdersPath,
          builder:
              (context, state) =>
                  const Scaffold(body: Text('Marketplace orders target')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _profilePreferencesRepositoryOverride(),
          productProfileIdProvider.overrideWith(
            (ref) => _profileIdNotifier('marketplace_operations'),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    final reviewOrders = find.text('Review orders');
    await tester.ensureVisible(reviewOrders);
    await tester.pumpAndSettle();
    await tester.tap(reviewOrders);
    await tester.pumpAndSettle();

    expect(find.text('Marketplace orders target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen focuses channel strategy from playbook action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _profilePreferencesRepositoryOverride(),
          productProfilesProvider.overrideWithValue([_channelGapProfile()]),
          productProfileIdProvider.overrideWith(
            (ref) => _profileIdNotifier('lean_marketplace'),
          ),
        ],
        child: const MaterialApp(home: Screen()),
      ),
    );

    final channelSection = find.byKey(
      const ValueKey('section_channelStrategy'),
    );
    final beforeTop = tester.getTopLeft(channelSection).dy;

    await tester.tap(find.text('Review playbook'));
    await tester.pumpAndSettle();

    final afterTop = tester.getTopLeft(channelSection).dy;

    expect(find.text('Review playbook'), findsOneWidget);
    expect(afterTop, lessThan(beforeTop));
    expect(afterTop, lessThan(80));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen switches product profiles from menu', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: Screen()),
      ),
    );

    expect(find.text('Profile | Standard commerce'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile_picker_dialog')), findsOneWidget);
    expect(find.text('Standard commerce'), findsWidgets);
    expect(find.text('Operations first commerce'), findsOneWidget);
    expect(find.text('6 profile presets'), findsOneWidget);
    expect(find.text('Storefront'), findsWidgets);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Ops review'), findsWidgets);

    final operationsOption = find.byKey(
      const ValueKey('profile_option_operations_first'),
    );
    await tester.ensureVisible(operationsOption);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Operations first commerce'));
    await tester.pumpAndSettle();

    final operationsTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_operations')),
    );
    final headerTop = tester.getTopLeft(
      find.byKey(const ValueKey('section_header')),
    );

    expect(find.text('Profile | Operations first commerce'), findsOneWidget);
    expect(operationsTop.dy, lessThan(headerTop.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen can search product profile presets', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: Screen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_search')),
      'subscription',
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 6 profiles'), findsOneWidget);
    expect(find.text('Subscription commerce'), findsOneWidget);
    expect(find.text('Remote payment commerce'), findsNothing);

    final subscriptionLabel = find.text('Subscription commerce');

    await tester.ensureVisible(subscriptionLabel);
    await tester.pumpAndSettle();
    await tester.tap(subscriptionLabel);
    await tester.pumpAndSettle();

    expect(find.text('Profile | Subscription commerce'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen can search profiles by sales channel', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: Screen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_search')),
      'phone',
    );
    await tester.pumpAndSettle();

    expect(find.text('2 of 6 profiles'), findsOneWidget);
    expect(find.text('Remote payment commerce'), findsOneWidget);
    expect(find.text('Subscription commerce'), findsOneWidget);
    expect(find.text('Channel: Phone order'), findsNWidgets(2));
    expect(find.text('Marketplace operations'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Screen can search profiles by coverage requirement', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: Screen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_search')),
      'price lists',
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 6 profiles'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Price lists'), findsOneWidget);
    expect(find.text('Rule: Price lists'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_option_standard')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

dynamic _profilePreferencesRepositoryOverride() {
  return profilePreferencesRepositoryProvider.overrideWithValue(
    _memoryRepository(),
  );
}

ProductProfileIdNotifier _profileIdNotifier(String profileId) {
  return ProductProfileIdNotifier(
    repository: _memoryRepository(),
    initialProfileId: profileId,
    autoHydrate: false,
  );
}

ProfilePreferencesRepository _memoryRepository() {
  return ProfilePreferencesRepository(store: MemoryProfilePreferencesStore());
}

ProductProfile _channelGapProfile() {
  const leanMarketplaceChannel = POSCommerceChannel(
    id: 'lean_marketplace',
    kind: POSCommerceChannelKind.marketplace,
    label: 'Lean marketplace',
    description: 'Marketplace channel without fulfillment handoff mapping.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [],
    capabilities: [POSCommerceChannelCapability.inventoryReservation],
  );

  return ProductProfile.standard.copyWith(
    id: 'lean_marketplace',
    label: 'Lean marketplace commerce',
    description: 'Marketplace profile still missing fulfillment mapping.',
    capabilities: const [ProductCapability.marketplaceOrders],
    salesChannels: const [leanMarketplaceChannel],
    presentationProfile: PresentationProfile.operationsFirst,
  );
}
