import 'product_profile.dart';
import 'product_profile_search.dart';
import 'order_workspace_bridge.dart';

class ProductProfileSearchSuggestion {
  final String label;
  final String query;
  final ProductProfileSearchMatchType matchType;

  const ProductProfileSearchSuggestion({
    required this.label,
    required this.query,
    required this.matchType,
  });
}

List<ProductProfileSearchSuggestion> productProfileSearchSuggestions({
  required Iterable<ProductProfile> profiles,
  int limit = 8,
}) {
  assert(limit >= 0);
  if (limit == 0) return const [];

  final suggestions = <ProductProfileSearchSuggestion>[];
  final seenQueries = <String>{};

  void addSuggestion({
    required String query,
    required ProductProfileSearchMatchType matchType,
  }) {
    final normalizedQuery = normalizeProductProfileSearch(query);
    if (normalizedQuery.isEmpty || !seenQueries.add(normalizedQuery)) return;

    suggestions.add(
      ProductProfileSearchSuggestion(
        label: _suggestionLabel(normalizedQuery),
        query: normalizedQuery,
        matchType: matchType,
      ),
    );
  }

  final profileList = profiles.toList(growable: false);

  for (final profile in profileList) {
    for (final keyword in profile.searchKeywords) {
      addSuggestion(
        query: keyword,
        matchType: ProductProfileSearchMatchType.profile,
      );
      if (suggestions.length >= limit) return List.unmodifiable(suggestions);
    }
  }

  for (final profile in profileList) {
    for (final channel in profile.salesChannels) {
      addSuggestion(
        query: channel.label,
        matchType: ProductProfileSearchMatchType.salesChannel,
      );
      if (suggestions.length >= limit) return List.unmodifiable(suggestions);
    }
  }

  for (final profile in profileList) {
    final bridge = orderWorkspaceBridgeForProfile(productProfile: profile);
    addSuggestion(
      query: bridge.route.title,
      matchType: ProductProfileSearchMatchType.orderWorkspace,
    );
    if (suggestions.length >= limit) return List.unmodifiable(suggestions);
  }

  for (final profile in profileList) {
    for (final requirement in profile.channelCoverageRequirements) {
      addSuggestion(
        query: requirement.label,
        matchType: ProductProfileSearchMatchType.channelCoverageRequirement,
      );
      if (suggestions.length >= limit) return List.unmodifiable(suggestions);
    }
  }

  return List.unmodifiable(suggestions);
}

String _suggestionLabel(String normalizedQuery) {
  final words = normalizedQuery.split(' ');
  return words
      .map(
        (word) =>
            word.isEmpty
                ? word
                : '${word.substring(0, 1).toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
