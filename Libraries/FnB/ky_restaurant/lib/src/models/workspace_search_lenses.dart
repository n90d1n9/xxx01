import 'workspace_active_lens.dart';

/// Builds active workspace lenses from menu and reservation search queries.
class RestaurantWorkspaceSearchLensSet {
  const RestaurantWorkspaceSearchLensSet({
    required this.menuSearchQuery,
    required this.reservationSearchQuery,
    this.reservationZoneLabels = const [],
  });

  final String menuSearchQuery;
  final String reservationSearchQuery;
  final Iterable<String> reservationZoneLabels;

  String get normalizedMenuSearchQuery => menuSearchQuery.trim();

  String get normalizedReservationSearchQuery => reservationSearchQuery.trim();

  List<RestaurantWorkspaceActiveLens> get activeLenses {
    return [
      if (normalizedMenuSearchQuery.isNotEmpty)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menuSearch,
          label: 'Menu search: $normalizedMenuSearchQuery',
        ),
      if (normalizedReservationSearchQuery.isNotEmpty)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.reservationSearch,
          label: _reservationSearchLensLabel,
        ),
    ];
  }

  List<String> get labels {
    return activeLenses.map((lens) => lens.label).toList(growable: false);
  }

  String get _reservationSearchLensLabel {
    final normalizedQuery = _normalizedLensValue(
      normalizedReservationSearchQuery,
    );
    for (final zoneLabel in reservationZoneLabels) {
      final trimmedZone = zoneLabel.trim();
      if (trimmedZone.isEmpty) continue;
      if (_normalizedLensValue(trimmedZone) == normalizedQuery) {
        return 'Zone: $trimmedZone';
      }
    }
    return 'Reservation search: $normalizedReservationSearchQuery';
  }
}

String _normalizedLensValue(String value) {
  return value.trim().toLowerCase();
}
