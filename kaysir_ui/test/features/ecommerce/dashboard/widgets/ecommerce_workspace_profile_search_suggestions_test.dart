import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search_suggestion.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_search_suggestions.dart';

void main() {
  testWidgets('ProfileSearchSuggestions selects a chip', (tester) async {
    String? selectedQuery;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileSearchSuggestions(
            suggestions: const [
              ProductProfileSearchSuggestion(
                label: 'Seller center',
                query: 'seller center',
                matchType: ProductProfileSearchMatchType.profile,
              ),
            ],
            onSuggestionSelected: (query) => selectedQuery = query,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_search_suggestion_seller center')),
      findsOneWidget,
    );
    expect(find.text('Seller center'), findsOneWidget);
    expect(find.byType(EcommerceWorkspaceActionChip), findsOneWidget);
    expect(
      tester
          .widget<EcommerceWorkspaceActionChip>(
            find.byType(EcommerceWorkspaceActionChip),
          )
          .icon,
      Icons.view_quilt_outlined,
    );

    await tester.tap(find.text('Seller center'));
    await tester.pump();

    expect(selectedQuery, 'seller center');
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileSearchSuggestions uses order workspace icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileSearchSuggestions(
            suggestions: const [
              ProductProfileSearchSuggestion(
                label: 'Marketplace Orders',
                query: 'marketplace orders',
                matchType: ProductProfileSearchMatchType.orderWorkspace,
              ),
            ],
            onSuggestionSelected: (_) {},
          ),
        ),
      ),
    );

    final chip = tester.widget<EcommerceWorkspaceActionChip>(
      find.byType(EcommerceWorkspaceActionChip),
    );
    expect(chip.icon, Icons.receipt_long_outlined);
    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
