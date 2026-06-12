import 'package:kaysir/core/features/feature_routes.dart';

import 'route_shell_metadata.dart';

/// Searchable representation of one navigable route in the workspace shell.
class RouteSearchEntry {
  const RouteSearchEntry({
    required this.route,
    required this.title,
    required this.path,
    this.section,
    this.isOverview = false,
  });

  final FeatureRoutes route;
  final String title;
  final String path;

  /// Parent breadcrumb that disambiguates routes with similar labels.
  final String? section;
  final bool isOverview;

  /// Primary label shown in route search results.
  String get displayTitle => isOverview ? '$title Overview' : title;

  /// Secondary label shown below the title in search results.
  String get subtitle {
    final routeSubtitle = route.subtitle?.trim();
    final fallbackDetail =
        routeSubtitle != null && routeSubtitle.isNotEmpty
            ? routeSubtitle
            : path;
    final segments = [
      if (section != null) section!,
      if (isOverview) 'Overview',
      fallbackDetail,
    ];

    return segments.join(' | ');
  }

  /// Lowercase text used by the filter for fast in-memory matching.
  String get searchText =>
      '$displayTitle $title ${route.name ?? ''} ${section ?? ''} ${route.subtitle ?? ''} '
              '${route.description ?? ''} $path'
          .toLowerCase();

  String get _normalizedTitle => displayTitle.toLowerCase();
  String get _normalizedName => (route.name ?? '').toLowerCase();
  String get _normalizedSection => (section ?? '').toLowerCase();
  String get _normalizedSubtitle => (route.subtitle ?? '').toLowerCase();
  String get _normalizedDescription => (route.description ?? '').toLowerCase();
  String get _normalizedPath => path.toLowerCase();
}

/// Builds a stable, de-duplicated search index from registered feature routes.
List<RouteSearchEntry> buildRouteSearchEntries(List<FeatureRoutes> features) {
  final entries = <RouteSearchEntry>[];
  final seenPaths = <String>{};

  void visit(Iterable<FeatureRoutes> routes, List<String> ancestors) {
    for (final route in routes) {
      final path = route.path?.trim();
      final title = routeShellLabel(route).trim();
      final section = _sectionFromAncestors(ancestors);
      final isVisible = routeShellIsVisible(route);
      final canOpen = routeShellCanOpen(route);

      if (isVisible && canOpen && path != null && seenPaths.add(path)) {
        entries.add(
          RouteSearchEntry(
            route: route,
            title: title.isEmpty ? path : title,
            path: path,
            section: section,
            isOverview: routeShellVisibleChildren(route).isNotEmpty,
          ),
        );
      }

      if (route.items.isNotEmpty) {
        visit(route.items, [...ancestors, if (title.isNotEmpty) title]);
      }
    }
  }

  visit(features, const []);
  entries.sort((a, b) {
    final sectionCompare = (a.section ?? '').compareTo(b.section ?? '');
    if (sectionCompare != 0) return sectionCompare;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });

  return List.unmodifiable(entries);
}

String? _sectionFromAncestors(List<String> ancestors) {
  final segments = ancestors
      .map((ancestor) => ancestor.trim())
      .where((ancestor) => ancestor.isNotEmpty)
      .toList(growable: false);
  if (segments.isEmpty) return null;
  return segments.join(' / ');
}

/// Filters a route search index using title, section, subtitle, description, and path.
List<RouteSearchEntry> filterRouteSearchEntries(
  List<RouteSearchEntry> entries,
  String query,
) {
  final terms = _queryTerms(query);
  if (terms.isEmpty) return entries;

  final rankedEntries = <_RankedRouteSearchEntry>[];
  for (var index = 0; index < entries.length; index += 1) {
    final entry = entries[index];
    final score = _scoreEntry(entry, terms);
    if (score == null) continue;
    rankedEntries.add(
      _RankedRouteSearchEntry(entry: entry, score: score, index: index),
    );
  }

  rankedEntries.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;
    return a.index.compareTo(b.index);
  });

  return List.unmodifiable(rankedEntries.map((ranked) => ranked.entry));
}

List<String> _queryTerms(String query) {
  return query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);
}

int? _scoreEntry(RouteSearchEntry entry, List<String> terms) {
  var total = 0;

  for (final term in terms) {
    final score = _scoreTerm(entry, term);
    if (score == 0) return null;
    total += score;
  }

  return total;
}

int _scoreTerm(RouteSearchEntry entry, String term) {
  final titleScore = _scoreField(
    entry._normalizedTitle,
    term,
    exact: 1200,
    prefix: 1000,
    wordPrefix: 900,
    contains: 760,
  );
  if (titleScore > 0) return titleScore;

  final nameScore = _scoreField(
    entry._normalizedName,
    term,
    exact: 1000,
    prefix: 860,
    wordPrefix: 760,
    contains: 640,
  );
  if (nameScore > 0) return nameScore;

  final pathScore = _scoreField(
    entry._normalizedPath,
    term,
    exact: 840,
    prefix: 720,
    wordPrefix: 680,
    contains: 560,
  );
  if (pathScore > 0) return pathScore;

  final sectionScore = _scoreField(
    entry._normalizedSection,
    term,
    exact: 640,
    prefix: 560,
    wordPrefix: 500,
    contains: 420,
  );
  if (sectionScore > 0) return sectionScore;

  final subtitleScore = _scoreField(
    entry._normalizedSubtitle,
    term,
    exact: 520,
    prefix: 460,
    wordPrefix: 420,
    contains: 340,
  );
  if (subtitleScore > 0) return subtitleScore;

  return _scoreField(
    entry._normalizedDescription,
    term,
    exact: 280,
    prefix: 240,
    wordPrefix: 220,
    contains: 160,
  );
}

int _scoreField(
  String value,
  String term, {
  required int exact,
  required int prefix,
  required int wordPrefix,
  required int contains,
}) {
  if (value.isEmpty) return 0;
  if (value == term) return exact;
  if (value.startsWith(term)) return prefix;
  if (_hasWordPrefix(value, term)) return wordPrefix;
  if (value.contains(term)) return contains;
  return 0;
}

bool _hasWordPrefix(String value, String term) {
  return value
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .any((word) => word.startsWith(term));
}

class _RankedRouteSearchEntry {
  const _RankedRouteSearchEntry({
    required this.entry,
    required this.score,
    required this.index,
  });

  final RouteSearchEntry entry;
  final int score;
  final int index;
}
