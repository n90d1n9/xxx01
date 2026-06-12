import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_results_panel.dart';

void main() {
  testWidgets('ProfileSearchResultsPanel filters and selects profiles', (
    tester,
  ) async {
    String? selectedProfileId;
    String? detailsProfileId;
    final profiles = [
      ProductProfile.standard,
      ProductProfile.marketplaceOperations,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileSearchResultsPanel(
            results: productProfileSearchResults(
              profiles: profiles,
              query: 'price lists',
            ),
            totalProfileCount: profiles.length,
            activeProfileId: ProductProfile.standard.id,
            query: 'price lists',
            onProfileSelected: (profileId) => selectedProfileId = profileId,
            onProfileDetailsRequested:
                (profileId) => detailsProfileId = profileId,
          ),
        ),
      ),
    );

    expect(find.text('1 of 2 profiles'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Orders: Marketplace'), findsOneWidget);
    expect(find.text('Rule: Price lists'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_search_match')), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('profile_option_details_marketplace_operations'),
      ),
    );
    await tester.pump();

    expect(detailsProfileId, 'marketplace_operations');
    expect(selectedProfileId, isNull);

    await tester.tap(find.text('Marketplace operations'));
    await tester.pump();

    expect(selectedProfileId, 'marketplace_operations');
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileSearchResultsPanel explains empty search results', (
    tester,
  ) async {
    final profiles = [
      ProductProfile.standard,
      ProductProfile.marketplaceOperations,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileSearchResultsPanel(
            results: productProfileSearchResults(
              profiles: profiles,
              query: 'wholesale warehouse',
            ),
            totalProfileCount: profiles.length,
            activeProfileId: ProductProfile.standard.id,
            query: 'wholesale warehouse',
            onProfileSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('0 of 2 profiles'), findsOneWidget);
    expect(
      find.text('No profiles match "wholesale warehouse".'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('profile_empty_search')), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
