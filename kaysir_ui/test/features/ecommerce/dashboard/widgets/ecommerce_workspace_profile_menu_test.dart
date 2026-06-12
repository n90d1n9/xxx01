import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/repositories/workspace_profile_preferences_repository.dart';
import 'package:kaysir/features/ecommerce/dashboard/states/workspace_provider.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_menu.dart';

void main() {
  testWidgets('ProfileMenu stays quiet with one profile', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productProfilesProvider.overrideWithValue([ProductProfile.standard]),
          productProfileIdProvider.overrideWith(
            (ref) => _profileIdNotifier(ProductProfile.standard.id),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfileMenu())),
      ),
    );

    expect(find.byKey(const ValueKey('profile_menu')), findsNothing);
    expect(find.byType(IconActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileMenu opens profile picker', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productProfilesProvider.overrideWithValue([
            ProductProfile.standard,
            ProductProfile.marketplaceOperations,
          ]),
          productProfileIdProvider.overrideWith(
            (ref) =>
                _profileIdNotifier(ProductProfile.marketplaceOperations.id),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfileMenu())),
      ),
    );

    expect(find.byKey(const ValueKey('profile_menu')), findsOneWidget);
    expect(find.byType(IconActionButton), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile_menu')));
    await tester.pumpAndSettle();

    expect(find.text('Commerce profile'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

ProductProfileIdNotifier _profileIdNotifier(String profileId) {
  return ProductProfileIdNotifier(
    repository: ProfilePreferencesRepository(
      store: MemoryProfilePreferencesStore(),
    ),
    initialProfileId: profileId,
    autoHydrate: false,
  );
}
