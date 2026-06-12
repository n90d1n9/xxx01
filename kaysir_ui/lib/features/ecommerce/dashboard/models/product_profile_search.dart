import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'channel_requirement.dart';
import 'order_workspace_bridge.dart';
import 'product_profile.dart';

enum ProductProfileSearchMatchType {
  profile,
  orderWorkspace,
  salesChannel,
  capability,
  channelCoverageRequirement,
  recommendation,
}

extension ProductProfileSearchMatchTypeLabel on ProductProfileSearchMatchType {
  String get label {
    return switch (this) {
      ProductProfileSearchMatchType.profile => 'Profile',
      ProductProfileSearchMatchType.orderWorkspace => 'Order workspace',
      ProductProfileSearchMatchType.salesChannel => 'Channel',
      ProductProfileSearchMatchType.capability => 'Capability',
      ProductProfileSearchMatchType.channelCoverageRequirement => 'Rule',
      ProductProfileSearchMatchType.recommendation => 'Playbook',
    };
  }
}

class ProductProfileSearchMatch {
  final ProductProfileSearchMatchType type;
  final String label;
  final String detail;
  final int relevanceScore;

  const ProductProfileSearchMatch({
    required this.type,
    required this.label,
    required this.detail,
    this.relevanceScore = 0,
  });

  String get categoryLabel => type.label;
}

class ProductProfileSearchResult {
  final ProductProfile profile;
  final List<ProductProfileSearchMatch> matches;
  final int relevanceScore;

  const ProductProfileSearchResult({
    required this.profile,
    this.matches = const [],
    this.relevanceScore = 0,
  });

  bool get hasMatches => matches.isNotEmpty;

  ProductProfileSearchMatch? get primaryMatch {
    if (matches.isEmpty) return null;
    return matches.first;
  }

  String get matchSummary {
    final match = primaryMatch;
    if (match == null) return 'Profile preset';
    return '${match.categoryLabel}: ${match.label}';
  }
}

List<ProductProfile> productProfilesMatching({
  required Iterable<ProductProfile> profiles,
  required String query,
}) {
  return List.unmodifiable(
    productProfileSearchResults(
      profiles: profiles,
      query: query,
    ).map((result) => result.profile),
  );
}

List<ProductProfileSearchResult> productProfileSearchResults({
  required Iterable<ProductProfile> profiles,
  required String query,
}) {
  final profileList = profiles.toList(growable: false);
  final normalizedQuery = normalizeProductProfileSearch(query);

  if (normalizedQuery.isEmpty) {
    return List.unmodifiable(
      profileList.map(
        (profile) => ProductProfileSearchResult(profile: profile),
      ),
    );
  }

  final results = <ProductProfileSearchResult>[];
  for (final profile in profileList) {
    final matches = _searchMatchesFor(
      profile: profile,
      normalizedQuery: normalizedQuery,
    );
    if (matches.isEmpty) continue;

    results.add(
      ProductProfileSearchResult(
        profile: profile,
        matches: matches,
        relevanceScore: _resultRelevanceScore(matches),
      ),
    );
  }

  return List.unmodifiable(_sortSearchResults(results));
}

List<ProductProfileSearchResult> productProfileSearchResultsForMatchTypes({
  required Iterable<ProductProfileSearchResult> results,
  required Set<ProductProfileSearchMatchType> matchTypes,
}) {
  if (matchTypes.isEmpty) return List.unmodifiable(results);

  final filteredResults = <ProductProfileSearchResult>[];
  for (final result in results) {
    final matches = result.matches
        .where((match) => matchTypes.contains(match.type))
        .toList(growable: false);
    if (matches.isEmpty) continue;

    filteredResults.add(
      ProductProfileSearchResult(
        profile: result.profile,
        matches: matches,
        relevanceScore: _resultRelevanceScore(matches),
      ),
    );
  }

  return List.unmodifiable(_sortSearchResults(filteredResults));
}

ProductProfileSearchResult productProfileSearchResult({
  required ProductProfile profile,
  required String query,
}) {
  final normalizedQuery = normalizeProductProfileSearch(query);

  if (normalizedQuery.isEmpty) {
    return ProductProfileSearchResult(profile: profile);
  }

  final matches = _searchMatchesFor(
    profile: profile,
    normalizedQuery: normalizedQuery,
  );

  return ProductProfileSearchResult(
    profile: profile,
    matches: matches,
    relevanceScore: _resultRelevanceScore(matches),
  );
}

bool productProfileMatchesQuery({
  required ProductProfile profile,
  required String query,
}) {
  return productProfileSearchResult(
        profile: profile,
        query: query,
      ).hasMatches ||
      normalizeProductProfileSearch(query).isEmpty;
}

String productProfileSearchText(ProductProfile profile) {
  final capabilityTerms = profile.capabilities.expand(
    (capability) => [capability.name, capability.label],
  );
  final orderWorkspaceTerms = _orderWorkspaceTerms(
    orderWorkspaceBridgeForProfile(productProfile: profile),
  );
  final channelTerms = profile.salesChannels.expand(
    (channel) => [
      channel.id,
      channel.kind.name,
      channel.kind.label,
      channel.label,
      channel.description,
      channel.fulfillmentSummary,
      channel.traitSummary,
      ...channel.traits,
      ...channel.fulfillmentModes.expand((mode) => [mode.name, mode.label]),
    ],
  );
  final requirementTerms = profile.channelCoverageRequirements.expand((
    requirement,
  ) {
    final recommendation = requirement.recommendation;

    return [
      requirement.id,
      requirement.label,
      requirement.coveredDetail,
      requirement.missingDetail,
      requirement.optionalDetail,
      requirement.channelCapability.name,
      requirement.channelCapability.label,
      requirement.type.name,
      if (recommendation != null) ...[
        recommendation.title,
        recommendation.detail,
        recommendation.actionLabel,
      ],
    ];
  });

  return normalizeProductProfileSearch(
    [
      profile.id,
      profile.label,
      profile.description,
      ...profile.searchKeywords,
      ...orderWorkspaceTerms,
      ...channelTerms,
      ...capabilityTerms,
      ...requirementTerms,
    ].join(' '),
  );
}

String normalizeProductProfileSearch(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

List<ProductProfileSearchMatch> _searchMatchesFor({
  required ProductProfile profile,
  required String normalizedQuery,
}) {
  final matches = <ProductProfileSearchMatch>[];

  _addMatch(
    matches,
    normalizedQuery: normalizedQuery,
    type: ProductProfileSearchMatchType.profile,
    label: profile.label,
    detail: 'Profile metadata',
    terms: [
      profile.id,
      profile.label,
      profile.description,
      ...profile.searchKeywords,
    ],
  );

  final orderWorkspaceBridge = orderWorkspaceBridgeForProfile(
    productProfile: profile,
  );
  _addMatch(
    matches,
    normalizedQuery: normalizedQuery,
    type: ProductProfileSearchMatchType.orderWorkspace,
    label: orderWorkspaceBridge.route.title,
    detail: orderWorkspaceBridge.route.subtitle,
    terms: _orderWorkspaceTerms(orderWorkspaceBridge),
  );

  for (final channel in profile.salesChannels) {
    _addMatch(
      matches,
      normalizedQuery: normalizedQuery,
      type: ProductProfileSearchMatchType.salesChannel,
      label: channel.label,
      detail: channel.kind.label,
      terms: _channelTerms(channel),
    );
  }

  for (final capability in profile.capabilities) {
    _addMatch(
      matches,
      normalizedQuery: normalizedQuery,
      type: ProductProfileSearchMatchType.capability,
      label: capability.label,
      detail: 'Product capability',
      terms: [capability.name, capability.label],
    );
  }

  for (final requirement in profile.channelCoverageRequirements) {
    _addMatch(
      matches,
      normalizedQuery: normalizedQuery,
      type: ProductProfileSearchMatchType.channelCoverageRequirement,
      label: requirement.label,
      detail: requirement.channelCapability.label,
      terms: _requirementTerms(requirement),
    );

    final recommendation = requirement.recommendation;
    if (recommendation == null) continue;

    _addMatch(
      matches,
      normalizedQuery: normalizedQuery,
      type: ProductProfileSearchMatchType.recommendation,
      label: recommendation.title,
      detail: recommendation.actionLabel,
      terms: [
        recommendation.title,
        recommendation.detail,
        recommendation.actionLabel,
      ],
    );
  }

  matches.sort(_compareSearchMatches);

  return List.unmodifiable(matches);
}

void _addMatch(
  List<ProductProfileSearchMatch> matches, {
  required String normalizedQuery,
  required ProductProfileSearchMatchType type,
  required String label,
  required String detail,
  required Iterable<String> terms,
}) {
  final normalizedTerms = terms
      .map(normalizeProductProfileSearch)
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
  final searchText = normalizedTerms.join(' ');
  if (!searchText.contains(normalizedQuery)) return;

  matches.add(
    ProductProfileSearchMatch(
      type: type,
      label: label,
      detail: detail,
      relevanceScore: _matchRelevanceScore(
        type: type,
        normalizedQuery: normalizedQuery,
        normalizedTerms: normalizedTerms,
      ),
    ),
  );
}

int _resultRelevanceScore(List<ProductProfileSearchMatch> matches) {
  if (matches.isEmpty) return 0;

  return (matches.first.relevanceScore * 100) + matches.length;
}

List<ProductProfileSearchResult> _sortSearchResults(
  List<ProductProfileSearchResult> results,
) {
  final indexedResults = <_IndexedSearchResult>[
    for (var index = 0; index < results.length; index++)
      _IndexedSearchResult(index: index, result: results[index]),
  ];

  indexedResults.sort((a, b) {
    final relevance = b.result.relevanceScore.compareTo(
      a.result.relevanceScore,
    );
    if (relevance != 0) return relevance;

    return a.index.compareTo(b.index);
  });

  return indexedResults.map((entry) => entry.result).toList(growable: false);
}

int _compareSearchMatches(
  ProductProfileSearchMatch a,
  ProductProfileSearchMatch b,
) {
  final relevance = b.relevanceScore.compareTo(a.relevanceScore);
  if (relevance != 0) return relevance;

  return _matchTypeSortOrder(a.type).compareTo(_matchTypeSortOrder(b.type));
}

int _matchRelevanceScore({
  required ProductProfileSearchMatchType type,
  required String normalizedQuery,
  required Iterable<String> normalizedTerms,
}) {
  return _termFitScore(
        normalizedQuery: normalizedQuery,
        normalizedTerms: normalizedTerms,
      ) +
      _matchTypeWeight(type);
}

int _termFitScore({
  required String normalizedQuery,
  required Iterable<String> normalizedTerms,
}) {
  if (normalizedTerms.any((term) => term == normalizedQuery)) return 1000;
  if (normalizedTerms.any((term) => term.startsWith(normalizedQuery))) {
    return 800;
  }

  return 600;
}

int _matchTypeWeight(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.profile => 500,
    ProductProfileSearchMatchType.orderWorkspace => 430,
    ProductProfileSearchMatchType.salesChannel => 400,
    ProductProfileSearchMatchType.channelCoverageRequirement => 320,
    ProductProfileSearchMatchType.recommendation => 300,
    ProductProfileSearchMatchType.capability => 250,
  };
}

int _matchTypeSortOrder(ProductProfileSearchMatchType type) {
  return switch (type) {
    ProductProfileSearchMatchType.profile => 0,
    ProductProfileSearchMatchType.orderWorkspace => 1,
    ProductProfileSearchMatchType.salesChannel => 2,
    ProductProfileSearchMatchType.channelCoverageRequirement => 3,
    ProductProfileSearchMatchType.recommendation => 4,
    ProductProfileSearchMatchType.capability => 5,
  };
}

class _IndexedSearchResult {
  final int index;
  final ProductProfileSearchResult result;

  const _IndexedSearchResult({required this.index, required this.result});
}

Iterable<String> _channelTerms(POSCommerceChannel channel) {
  return [
    channel.id,
    channel.kind.name,
    channel.kind.label,
    channel.label,
    channel.description,
    channel.fulfillmentSummary,
    channel.traitSummary,
    ...channel.traits,
    ...channel.fulfillmentModes.expand((mode) => [mode.name, mode.label]),
  ];
}

Iterable<String> _orderWorkspaceTerms(OrderWorkspaceBridge bridge) {
  return [
    bridge.route.name,
    bridge.route.title,
    bridge.route.subtitle,
    bridge.route.description,
    bridge.route.icon,
    bridge.route.path,
    bridge.routeShortTitle,
    bridge.compactLabel,
    bridge.requestedProfileId,
    bridge.resolvedProfileId,
    bridge.displayProfileId,
    bridge.workspaceViewCountLabel,
    bridge.route.profile.title,
    bridge.route.profile.description,
    ...bridge.route.profile.workspaceViews.expand(
      (view) => [view.id, view.label, view.description],
    ),
  ];
}

Iterable<String> _requirementTerms(ChannelCoverageRequirement requirement) {
  return [
    requirement.id,
    requirement.label,
    requirement.coveredDetail,
    requirement.missingDetail,
    requirement.optionalDetail,
    requirement.channelCapability.name,
    requirement.channelCapability.label,
    requirement.type.name,
  ];
}
