import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search_suggestion.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/active_profile_summary.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_picker_content.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_match_type_filter_bar.dart';

void main() {
  testWidgets(
    'ProfilePickerContent selects suggestions through search controller',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      String? query;
      final profiles = [
        ProductProfile.standard,
        ProductProfile.marketplaceOperations,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 520,
              width: 640,
              child: ProfilePickerContent(
                searchController: controller,
                activeProfile: ProductProfile.standard,
                profiles: profiles,
                query: '',
                selectedMatchTypes: const {},
                results: productProfileSearchResults(
                  profiles: profiles,
                  query: '',
                ),
                suggestions: const [
                  ProductProfileSearchSuggestion(
                    label: 'Retail',
                    query: 'retail',
                    matchType: ProductProfileSearchMatchType.profile,
                  ),
                ],
                onQueryChanged: (value) => query = value,
                onMatchTypesChanged: (_) {},
                onProfileSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActiveProfileSummary), findsOneWidget);
      expect(find.text('Active profile'), findsOneWidget);
      expect(find.text('Standard commerce'), findsWidgets);
      expect(find.text('2 profile presets'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('profile_search_suggestions')),
        findsOneWidget,
      );
      expect(find.text('Retail'), findsOneWidget);

      await tester.tap(find.text('Retail'));
      await tester.pump();

      expect(controller.text, 'retail');
      expect(query, 'retail');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ProfilePickerContent renders filters and query results', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'price lists');
    addTearDown(controller.dispose);

    Set<ProductProfileSearchMatchType>? matchTypes;
    String? selectedProfileId;
    String? detailsProfileId;
    final profiles = [
      ProductProfile.standard,
      ProductProfile.marketplaceOperations,
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 520,
            width: 640,
            child: ProfilePickerContent(
              searchController: controller,
              activeProfile: ProductProfile.standard,
              profiles: profiles,
              query: 'price lists',
              selectedMatchTypes: const {},
              results: productProfileSearchResults(
                profiles: profiles,
                query: 'price lists',
              ),
              suggestions: const [],
              onQueryChanged: (_) {},
              onMatchTypesChanged: (value) => matchTypes = value,
              onProfileSelected: (profileId) => selectedProfileId = profileId,
              onProfileDetailsRequested:
                  (profileId) => detailsProfileId = profileId,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ProfileSearchMatchTypeFilterBar), findsOneWidget);
    expect(find.text('1 of 2 profiles'), findsOneWidget);
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Rule: Price lists'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile_search_suggestions')),
      findsNothing,
    );

    final recommendationFilter = find.byKey(
      const ValueKey('profile_search_match_filter_recommendation'),
    );
    await tester.ensureVisible(recommendationFilter);
    await tester.pumpAndSettle();
    await tester.tap(recommendationFilter);
    await tester.pump();

    expect(matchTypes, contains(ProductProfileSearchMatchType.recommendation));

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
}
