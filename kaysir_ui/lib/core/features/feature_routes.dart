export 'package:ky_core/core/features/feature_routes.dart';

import 'package:ky_core/core/features/feature_routes.dart';

extension FeatureRoutesNaming on FeatureRoutes {
  /// User-facing label or explicit route name used by router integrations.
  String? get routeName => _nonBlank(name) ?? _nonBlank(title);

  /// Stable GoRouter name derived from an explicit name or route path.
  String? get goRouteName {
    final explicitName = routeName;
    if (explicitName == null) return null;
    if (_isExplicitRouteName(explicitName)) return explicitName;

    final routePath = _nonBlank(path);
    if (routePath == null) return _routeNameFromLabel(explicitName);

    return _routeNameFromPath(routePath);
  }

  /// Whether this feature route owns a concrete widget/page render target.
  bool get hasRouteTarget =>
      pageBuilder != null || builder != null || child != null;
}

String? _nonBlank(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool _isExplicitRouteName(String value) {
  return RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(value);
}

String _routeNameFromPath(String path) {
  final segments =
      path
          .split('/')
          .where((segment) => segment.isNotEmpty)
          .map(
            (segment) =>
                segment.startsWith(':') ? 'by${segment.substring(1)}' : segment,
          )
          .toList();

  if (segments.isEmpty) return 'root';

  return _routeNameFromWords(segments);
}

String _routeNameFromLabel(String label) {
  return _routeNameFromWords(
    label.split(RegExp(r'[^A-Za-z0-9]+')).where((word) => word.isNotEmpty),
  );
}

String _routeNameFromWords(Iterable<String> words) {
  final normalized =
      words
          .map((word) => word.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''))
          .where((word) => word.isNotEmpty)
          .toList();
  if (normalized.isEmpty) return 'route';

  final first = normalized.first.toLowerCase();
  final rest = normalized.skip(1).map(_capitalized);
  return [first, ...rest].join();
}

String _capitalized(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
