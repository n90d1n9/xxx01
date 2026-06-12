/// Common business model keys used by omni-channel activity modules.
class OmniChannelActivityBusinessModelKey {
  const OmniChannelActivityBusinessModelKey._();

  static const pointOfSales = 'point_of_sales';
  static const ecommerce = 'ecommerce';
  static const marketplace = 'marketplace';
  static const delivery = 'delivery';
  static const kiosk = 'kiosk';
  static const wholesale = 'wholesale';
}

/// Describes one product module that contributes omni-channel activity.
class OmniChannelActivityModuleManifest {
  final String id;
  final String label;
  final String description;
  final List<String> activitySourceIds;
  final List<String> actionContributorIds;
  final List<String> triageDimensionKeys;
  final List<String> businessModelKeys;
  final String routePath;

  OmniChannelActivityModuleManifest({
    required this.id,
    required this.label,
    this.description = '',
    Iterable<String> activitySourceIds = const [],
    Iterable<String> actionContributorIds = const [],
    Iterable<String> triageDimensionKeys = const [],
    Iterable<String> businessModelKeys = const [],
    this.routePath = '',
  }) : activitySourceIds = List.unmodifiable(
         activitySourceIds.map((id) => id.trim()).where((id) => id.isNotEmpty),
       ),
       actionContributorIds = List.unmodifiable(
         actionContributorIds
             .map((id) => id.trim())
             .where((id) => id.isNotEmpty),
       ),
       triageDimensionKeys = List.unmodifiable(
         triageDimensionKeys
             .map((key) => key.trim())
             .where((key) => key.isNotEmpty),
       ),
       businessModelKeys = List.unmodifiable(
         businessModelKeys
             .map((key) => key.trim())
             .where((key) => key.isNotEmpty),
       );

  bool get hasActivitySources => activitySourceIds.isNotEmpty;

  bool get hasActionContributors => actionContributorIds.isNotEmpty;

  bool get hasTriageDimensions => triageDimensionKeys.isNotEmpty;

  bool get hasContributions {
    return hasActivitySources || hasActionContributors || hasTriageDimensions;
  }

  int get declaredContributionCount {
    return activitySourceIds.length +
        actionContributorIds.length +
        triageDimensionKeys.length;
  }

  String get businessModelLabel {
    if (businessModelKeys.isEmpty) return 'General module';

    return businessModelKeys.map(_businessModelLabel).join(' / ');
  }
}

String _businessModelLabel(String key) {
  return key
      .split(RegExp(r'[_\-\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        if (word.length == 1) return word.toUpperCase();

        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ');
}
