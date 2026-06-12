import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile_search.dart';

void main() {
  test('productProfileSearchText indexes profile metadata', () {
    final searchText = productProfileSearchText(
      ProductProfile.marketplaceOperations,
    );

    expect(searchText, contains('marketplace operations'));
    expect(searchText, contains('delivery app'));
    expect(searchText, contains('seller center'));
    expect(searchText, contains('price lists'));
    expect(searchText, contains('review price lists'));
    expect(searchText, contains('marketplace-specific price lists'));
    expect(searchText, contains('marketplace orders'));
    expect(searchText, contains('/commerce/orders/marketplace'));
  });

  test('productProfileSearchResults explains keyword matches', () {
    final result =
        productProfileSearchResults(
          profiles: defaultProductProfiles,
          query: 'seller center',
        ).single;

    expect(result.profile.id, 'marketplace_operations');
    expect(result.primaryMatch?.type, ProductProfileSearchMatchType.profile);
    expect(result.primaryMatch?.label, 'Marketplace operations');
    expect(result.matchSummary, 'Profile: Marketplace operations');
  });

  test('productProfileSearchResults explains order workspace matches', () {
    final results = productProfileSearchResults(
      profiles: defaultProductProfiles,
      query: 'marketplace orders',
    );
    final result = results.first;

    expect(result.profile.id, 'marketplace_operations');
    expect(
      result.primaryMatch?.type,
      ProductProfileSearchMatchType.orderWorkspace,
    );
    expect(result.primaryMatch?.label, 'Marketplace Orders');
    expect(result.primaryMatch?.detail, 'Marketplace fulfillment');
    expect(result.matchSummary, 'Order workspace: Marketplace Orders');
  });

  test('productProfileSearchResultsForMatchTypes narrows matches', () {
    final results = productProfileSearchResults(
      profiles: defaultProductProfiles,
      query: 'price lists',
    );

    final playbookResults = productProfileSearchResultsForMatchTypes(
      results: results,
      matchTypes: const {ProductProfileSearchMatchType.recommendation},
    );
    final ruleResults = productProfileSearchResultsForMatchTypes(
      results: results,
      matchTypes: const {
        ProductProfileSearchMatchType.channelCoverageRequirement,
      },
    );

    expect(playbookResults.map((result) => result.profile.id), [
      'marketplace_operations',
    ]);
    expect(
      playbookResults.single.primaryMatch?.type,
      ProductProfileSearchMatchType.recommendation,
    );
    expect(
      ruleResults.single.primaryMatch?.type,
      [ProductProfileSearchMatchType.channelCoverageRequirement].single,
    );
  });

  test('productProfileSearchResults ranks stronger matches first', () {
    final channelMatch = ProductProfile.standard.copyWith(
      id: 'channel_match',
      label: 'General operations',
      description: 'General commerce operations.',
      searchKeywords: const [],
      salesChannels: const [SalesChannels.wholesale],
    );
    final keywordMatch = ProductProfile.standard.copyWith(
      id: 'keyword_match',
      label: 'Business customer commerce',
      description: 'B2B product profile.',
      searchKeywords: const ['wholesale'],
      salesChannels: const [SalesChannels.webStore],
    );

    final results = productProfileSearchResults(
      profiles: [channelMatch, keywordMatch],
      query: 'wholesale',
    );

    expect(results.map((result) => result.profile.id), [
      'keyword_match',
      'channel_match',
    ]);
    expect(
      results.first.primaryMatch?.type,
      ProductProfileSearchMatchType.profile,
    );
    expect(
      results.first.relevanceScore,
      greaterThan(results.last.relevanceScore),
    );
  });

  test('productProfilesMatching filters by channel terms', () {
    final matches = productProfilesMatching(
      profiles: defaultProductProfiles,
      query: 'phone',
    );

    expect(matches.map((profile) => profile.id), [
      'remote_payment',
      'subscription_commerce',
    ]);
  });

  test('productProfileSearchResults explains channel matches', () {
    final result =
        productProfileSearchResults(
          profiles: defaultProductProfiles,
          query: 'phone',
        ).first;

    expect(result.profile.id, 'remote_payment');
    expect(result.hasMatches, isTrue);
    expect(
      result.primaryMatch?.type,
      ProductProfileSearchMatchType.salesChannel,
    );
    expect(result.primaryMatch?.label, 'Phone order');
    expect(result.primaryMatch?.detail, 'Phone order');
    expect(result.matchSummary, 'Channel: Phone order');
  });

  test('productProfilesMatching filters by recommendation terms', () {
    final matches = productProfilesMatching(
      profiles: defaultProductProfiles,
      query: 'marketplace-specific price lists',
    );

    expect(matches.map((profile) => profile.id), ['marketplace_operations']);
  });

  test('productProfileSearchResults explains recommendation matches', () {
    final result =
        productProfileSearchResults(
          profiles: defaultProductProfiles,
          query: 'review price lists',
        ).single;

    expect(result.profile.id, 'marketplace_operations');
    expect(
      result.primaryMatch?.type,
      ProductProfileSearchMatchType.recommendation,
    );
    expect(result.primaryMatch?.label, 'Add price-list channel coverage');
    expect(result.primaryMatch?.detail, 'Review price lists');
    expect(result.matchSummary, 'Playbook: Add price-list channel coverage');
  });

  test('productProfileSearchResults explains rule matches', () {
    final result =
        productProfileSearchResults(
          profiles: defaultProductProfiles,
          query: 'fulfillment tracking',
        ).first;

    expect(
      result.primaryMatch?.type,
      ProductProfileSearchMatchType.channelCoverageRequirement,
    );
    expect(result.primaryMatch?.label, 'Tracking');
    expect(result.matchSummary, 'Rule: Tracking');
  });

  test('productProfilesMatching normalizes query spacing', () {
    final matches = productProfilesMatching(
      profiles: defaultProductProfiles,
      query: '  REVIEW   PRICE LISTS  ',
    );

    expect(matches.map((profile) => profile.id), ['marketplace_operations']);
  });

  test('productProfileMatchesQuery accepts empty query', () {
    expect(
      productProfileMatchesQuery(
        profile: ProductProfile.standard,
        query: '   ',
      ),
      isTrue,
    );
  });

  test(
    'productProfileSearchResults returns empty-match presets for empty query',
    () {
      final result =
          productProfileSearchResults(
            profiles: defaultProductProfiles,
            query: '   ',
          ).first;

      expect(result.profile.id, 'standard');
      expect(result.matches, isEmpty);
      expect(result.hasMatches, isFalse);
      expect(result.primaryMatch, isNull);
      expect(result.matchSummary, 'Profile preset');
    },
  );

  test('productProfileMatchesQuery rejects missing terms', () {
    expect(
      productProfileMatchesQuery(
        profile: ProductProfile.standard,
        query: 'field service subscription depot',
      ),
      isFalse,
    );
  });
}
