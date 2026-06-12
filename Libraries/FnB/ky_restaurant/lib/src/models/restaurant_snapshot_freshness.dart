import 'restaurant_models.dart';

/// Classifies how current a restaurant operating snapshot appears to be.
enum RestaurantSnapshotFreshnessStatus {
  unknown,
  fresh,
  aging,
  stale,
  refreshing;

  String get label => switch (this) {
    RestaurantSnapshotFreshnessStatus.unknown => 'Unknown',
    RestaurantSnapshotFreshnessStatus.fresh => 'Fresh',
    RestaurantSnapshotFreshnessStatus.aging => 'Aging',
    RestaurantSnapshotFreshnessStatus.stale => 'Stale',
    RestaurantSnapshotFreshnessStatus.refreshing => 'Refreshing',
  };
}

/// Describes snapshot recency and its corresponding operating status.
class RestaurantSnapshotFreshness {
  const RestaurantSnapshotFreshness({
    required this.status,
    required this.detail,
    this.age,
  });

  factory RestaurantSnapshotFreshness.evaluate({
    required DateTime? updatedAt,
    required DateTime now,
    bool isRefreshing = false,
    Duration agingAfter = const Duration(minutes: 5),
    Duration staleAfter = const Duration(minutes: 15),
  }) {
    if (isRefreshing) {
      return const RestaurantSnapshotFreshness(
        status: RestaurantSnapshotFreshnessStatus.refreshing,
        detail: 'Updating from source',
      );
    }

    if (updatedAt == null) {
      return const RestaurantSnapshotFreshness(
        status: RestaurantSnapshotFreshnessStatus.unknown,
        detail: 'Snapshot timestamp unavailable',
      );
    }

    final age = now.difference(updatedAt);
    final normalizedAge = age.isNegative ? Duration.zero : age;
    final status = normalizedAge >= staleAfter
        ? RestaurantSnapshotFreshnessStatus.stale
        : normalizedAge >= agingAfter
        ? RestaurantSnapshotFreshnessStatus.aging
        : RestaurantSnapshotFreshnessStatus.fresh;

    return RestaurantSnapshotFreshness(
      status: status,
      detail: _updatedDetail(normalizedAge),
      age: normalizedAge,
    );
  }

  final RestaurantSnapshotFreshnessStatus status;
  final String detail;
  final Duration? age;

  RestaurantServiceStatus get serviceStatus => switch (status) {
    RestaurantSnapshotFreshnessStatus.unknown => RestaurantServiceStatus.busy,
    RestaurantSnapshotFreshnessStatus.fresh => RestaurantServiceStatus.calm,
    RestaurantSnapshotFreshnessStatus.aging => RestaurantServiceStatus.busy,
    RestaurantSnapshotFreshnessStatus.stale => RestaurantServiceStatus.critical,
    RestaurantSnapshotFreshnessStatus.refreshing =>
      RestaurantServiceStatus.busy,
  };
}

String _durationLabel(Duration value) {
  if (value.inMinutes < 1) return 'just now';
  if (value.inHours < 1) return '${value.inMinutes}m';
  if (value.inDays < 1) return '${value.inHours}h';
  return '${value.inDays}d';
}

String _updatedDetail(Duration value) {
  final label = _durationLabel(value);
  return label == 'just now' ? 'Updated just now' : 'Updated $label ago';
}
