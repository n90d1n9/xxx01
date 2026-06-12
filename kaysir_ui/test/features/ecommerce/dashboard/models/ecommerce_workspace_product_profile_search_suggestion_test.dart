import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search_suggestion.dart';

void main() {
  test('productProfileSearchSuggestions derives aliases', () {
    final suggestions = productProfileSearchSuggestions(
      profiles: [ProductProfile.standard, ProductProfile.marketplaceOperations],
      limit: 8,
    );

    expect(suggestions.map((suggestion) => suggestion.query), [
      'omnichannel',
      'multi-channel',
      'retail',
      'storefront',
      'kiosk',
      'marketplace seller',
      'price list',
      'settlement',
    ]);
    expect(suggestions.first.label, 'Omnichannel');
    expect(suggestions.first.matchType, ProductProfileSearchMatchType.profile);
  });

  test('productProfileSearchSuggestions includes order workspaces', () {
    final suggestions = productProfileSearchSuggestions(
      profiles: [ProductProfile.standard, ProductProfile.marketplaceOperations],
      limit: 20,
    );

    final marketplaceOrders = suggestions.singleWhere(
      (suggestion) => suggestion.query == 'marketplace orders',
    );

    expect(marketplaceOrders.label, 'Marketplace Orders');
    expect(
      marketplaceOrders.matchType,
      ProductProfileSearchMatchType.orderWorkspace,
    );
  });

  test('productProfileSearchSuggestions de-duplicates terms', () {
    final duplicateProfile = ProductProfile.standard.copyWith(
      id: 'duplicate_terms',
      searchKeywords: const ['Retail', 'retail', '  retail  '],
    );

    final suggestions = productProfileSearchSuggestions(
      profiles: [duplicateProfile],
      limit: 10,
    );

    expect(
      suggestions.where((suggestion) => suggestion.query == 'retail').length,
      1,
    );
  });
}
