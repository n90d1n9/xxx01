import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_view.dart';
import 'workspace_search_lenses.dart';

export 'workspace_search_lenses.dart';

enum RestaurantWorkspaceCommandSignalKind {
  view,
  filters,
  menuSearch,
  reservationSearch,
  refresh,
}

class RestaurantWorkspaceCommandSignal {
  const RestaurantWorkspaceCommandSignal({
    required this.kind,
    required this.label,
    required this.value,
  });

  final RestaurantWorkspaceCommandSignalKind kind;
  final String label;
  final String value;
}

class RestaurantWorkspaceCommandSummary {
  const RestaurantWorkspaceCommandSummary({
    required this.selectedView,
    required this.activeFilterCount,
    required this.activeLenses,
    required this.activeLensLabels,
    required this.menuSearchQuery,
    required this.reservationSearchQuery,
    required this.isRefreshing,
    required this.signals,
  });

  factory RestaurantWorkspaceCommandSummary.fromWorkspace({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
    bool isRefreshing = false,
    Iterable<String> reservationZoneLabels = const [],
  }) {
    final activeFilterCount = filters.activeFilterCount;
    final searchLensSet = RestaurantWorkspaceSearchLensSet(
      menuSearchQuery: filters.menuSearchQuery,
      reservationSearchQuery: filters.reservationSearchQuery,
      reservationZoneLabels: reservationZoneLabels,
    );
    final menuSearchQuery = searchLensSet.normalizedMenuSearchQuery;
    final reservationSearchQuery =
        searchLensSet.normalizedReservationSearchQuery;
    final activeLenses = [
      ...filters.activeLenses,
      ...searchLensSet.activeLenses,
    ];
    final activeLensLabels = activeLenses
        .map((lens) => lens.label)
        .toList(growable: false);

    return RestaurantWorkspaceCommandSummary(
      selectedView: selectedView,
      activeFilterCount: activeFilterCount,
      activeLenses: activeLenses,
      activeLensLabels: activeLensLabels,
      menuSearchQuery: menuSearchQuery,
      reservationSearchQuery: reservationSearchQuery,
      isRefreshing: isRefreshing,
      signals: [
        RestaurantWorkspaceCommandSignal(
          kind: RestaurantWorkspaceCommandSignalKind.view,
          label: 'View',
          value: selectedView.title,
        ),
        RestaurantWorkspaceCommandSignal(
          kind: RestaurantWorkspaceCommandSignalKind.filters,
          label: 'Lenses',
          value: activeLenses.isEmpty
              ? 'Default'
              : _activeLensLabel(activeLenses.length),
        ),
        RestaurantWorkspaceCommandSignal(
          kind: RestaurantWorkspaceCommandSignalKind.refresh,
          label: 'Refresh',
          value: isRefreshing ? 'Refreshing' : 'Ready',
        ),
      ],
    );
  }

  final RestaurantWorkspaceView selectedView;
  final int activeFilterCount;
  final List<RestaurantWorkspaceActiveLens> activeLenses;
  final List<String> activeLensLabels;
  final String menuSearchQuery;
  final String reservationSearchQuery;
  final bool isRefreshing;
  final List<RestaurantWorkspaceCommandSignal> signals;

  bool get hasActiveState {
    return activeLenses.isNotEmpty ||
        menuSearchQuery.isNotEmpty ||
        reservationSearchQuery.isNotEmpty;
  }

  String get activeStateLabel {
    if (!hasActiveState) return 'Default operating lens';
    if (activeLenses.isNotEmpty) return _activeLensLabel(activeLenses.length);

    final parts = [
      if (menuSearchQuery.isNotEmpty) 'menu search',
      if (reservationSearchQuery.isNotEmpty) 'reservation search',
    ];
    return parts.join(', ');
  }

  String get activeLensDetailLabel {
    if (activeLensLabels.isEmpty) return 'Default lenses';
    return activeLensLabels.join(', ');
  }
}

String _activeLensLabel(int count) {
  return count == 1 ? '1 active lens' : '$count active lenses';
}
