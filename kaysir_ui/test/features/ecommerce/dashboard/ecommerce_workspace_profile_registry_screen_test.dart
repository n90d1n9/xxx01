import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/ecommerce/dashboard/profile_registry_screen.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/repositories/workspace_profile_preferences_repository.dart';
import 'package:kaysir/features/ecommerce/dashboard/states/workspace_provider.dart';

void main() {
  testWidgets('ProfileRegistryScreen searches and selects profiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: ProfileRegistryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile_registry_screen')),
      findsOneWidget,
    );
    expect(find.text('Profile Registry'), findsOneWidget);
    expect(find.text('Product profiles'), findsOneWidget);
    expect(find.text('6 profile presets'), findsOneWidget);
    expect(find.text('6 profiles'), findsOneWidget);
    expect(find.text('7 capabilities'), findsOneWidget);
    expect(find.text('25 keywords'), findsOneWidget);
    expect(find.text('Standard commerce'), findsWidgets);
    expect(find.text('Profile matrix'), findsOneWidget);
    expect(find.text('6 profiles compared'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('profile_comparison_row_marketplace_operations'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile_registry_search')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile_search_suggestions')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('profile_search_suggestion_retail')),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 6 profiles'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile_search_suggestions')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('profile_registry_search')),
      'seller center',
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 6 profiles'), findsOneWidget);
    expect(find.text('1 of 6 compared'), findsOneWidget);
    final marketplaceOption = find.byKey(
      const ValueKey('profile_option_marketplace_operations'),
    );
    expect(marketplaceOption, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('profile_comparison_row_marketplace_operations'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile_comparison_row_standard')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('profile_search_match')), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('profile_option_details_marketplace_operations'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product_profile_details_dialog')),
      findsOneWidget,
    );
    expect(find.text('Profile details'), findsOneWidget);
    expect(find.text('Price lists'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('product_profile_use_marketplace_operations')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileRegistryScreen uses wide layout on desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [_profilePreferencesRepositoryOverride()],
        child: const MaterialApp(home: ProfileRegistryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final controlTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('profile_registry_control_panel')),
    );
    final resultTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('profile_result_count')),
    );

    expect(resultTopLeft.dx, greaterThan(controlTopLeft.dx));
    expect((resultTopLeft.dy - controlTopLeft.dy).abs(), lessThan(8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileRegistryScreen opens linked order workspace', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Routes.profileRegistryPath,
      routes: [
        GoRoute(
          path: Routes.profileRegistryPath,
          builder: (context, state) => const ProfileRegistryScreen(),
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
        overrides: [_profilePreferencesRepositoryOverride()],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_registry_search')),
      'seller center',
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey('profile_option_details_marketplace_operations'),
      ),
    );
    await tester.pumpAndSettle();

    final openOrderWorkspace = find.byKey(
      const ValueKey('order_workspace_open_marketplace_operations'),
    );
    await tester.ensureVisible(openOrderWorkspace);
    await tester.pumpAndSettle();
    await tester.tap(openOrderWorkspace);
    await tester.pumpAndSettle();

    expect(find.text('Marketplace orders target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

dynamic _profilePreferencesRepositoryOverride() {
  return profilePreferencesRepositoryProvider.overrideWithValue(
    _memoryRepository(),
  );
}

ProfilePreferencesRepository _memoryRepository() {
  return ProfilePreferencesRepository(store: MemoryProfilePreferencesStore());
}
