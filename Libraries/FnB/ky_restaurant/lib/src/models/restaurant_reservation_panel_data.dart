import 'focused_visible_items.dart';
import 'reservation_contact_coverage.dart';
import 'reservation_seating_queue.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_action_queue.dart';
import 'restaurant_reservation_arrival_window.dart';
import 'restaurant_reservation_filter.dart';
import 'restaurant_reservation_priority_queue.dart';
import 'restaurant_reservation_summary.dart';
import 'restaurant_reservation_zone_load.dart';
import '../services/restaurant_reservation_seating_advisor.dart';

/// Derives searchable reservation presentation state and operating queues.
class RestaurantReservationPanelData {
  const RestaurantReservationPanelData._({
    required this.reservations,
    required this.selectedFilter,
    required this.searchQuery,
    required this.visibleReservations,
    required this.summary,
    required this.actionQueueSummary,
    required this.arrivalWindows,
    required this.zoneLoads,
    required this.priorityQueue,
    required this.contactCoverageSummary,
    required this.seatingQueueSummary,
  });

  factory RestaurantReservationPanelData.fromReservations({
    required Iterable<RestaurantReservation> reservations,
    required RestaurantReservationFilter selectedFilter,
    String searchQuery = '',
    String? focusedReservationId,
    RestaurantReservationSeatingAdvisor seatingAdvisor =
        const RestaurantReservationSeatingAdvisor(),
  }) {
    final items = reservations.toList(growable: false);
    final sortedItems = List<RestaurantReservation>.of(items)
      ..sort(
        (a, b) => a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow),
      );
    final searchedReservations = sortedItems
        .where(selectedFilter.includes)
        .where((reservation) => matchesSearch(reservation, searchQuery))
        .toList(growable: false);
    final visibleReservations = restaurantVisibleItemsWithFocus(
      visibleItems: searchedReservations,
      sourceItems: sortedItems,
      focusedId: focusedReservationId,
      idOf: (reservation) => reservation.id,
    );

    return RestaurantReservationPanelData._(
      reservations: items,
      selectedFilter: selectedFilter,
      searchQuery: searchQuery,
      visibleReservations: visibleReservations,
      summary: RestaurantReservationSummary.fromReservations(items),
      actionQueueSummary:
          RestaurantReservationActionQueueSummary.fromReservations(items),
      arrivalWindows: RestaurantReservationArrivalWindow.windowsFor(items),
      zoneLoads: RestaurantReservationZoneLoad.loadsFor(items),
      priorityQueue: RestaurantReservationPriorityQueue.fromReservations(
        visibleReservations,
      ),
      contactCoverageSummary:
          RestaurantReservationContactCoverageSummary.fromReservations(items),
      seatingQueueSummary:
          RestaurantReservationSeatingQueueSummary.fromReservations(
            items,
            advisor: seatingAdvisor,
          ),
    );
  }

  final List<RestaurantReservation> reservations;
  final RestaurantReservationFilter selectedFilter;
  final String searchQuery;
  final List<RestaurantReservation> visibleReservations;
  final RestaurantReservationSummary summary;
  final RestaurantReservationActionQueueSummary actionQueueSummary;
  final List<RestaurantReservationArrivalWindow> arrivalWindows;
  final List<RestaurantReservationZoneLoad> zoneLoads;
  final RestaurantReservationPriorityQueue priorityQueue;
  final RestaurantReservationContactCoverageSummary contactCoverageSummary;
  final RestaurantReservationSeatingQueueSummary seatingQueueSummary;

  bool get hasReservations => reservations.isNotEmpty;

  bool get hasSearch => searchQuery.trim().isNotEmpty;

  bool get hasVisibleReservations => visibleReservations.isNotEmpty;

  RestaurantReservationActionBucketKind? get selectedActionBucketKind {
    return actionBucketForFilter(selectedFilter);
  }

  RestaurantReservationArrivalWindowKind? get selectedArrivalWindowKind {
    return arrivalWindowForFilter(selectedFilter);
  }

  static RestaurantReservationActionBucketKind? actionBucketForFilter(
    RestaurantReservationFilter filter,
  ) {
    return switch (filter) {
      RestaurantReservationFilter.late =>
        RestaurantReservationActionBucketKind.recoverLate,
      RestaurantReservationFilter.arrived =>
        RestaurantReservationActionBucketKind.seatArrivals,
      RestaurantReservationFilter.seated =>
        RestaurantReservationActionBucketKind.closeSeated,
      RestaurantReservationFilter.all ||
      RestaurantReservationFilter.upcoming ||
      RestaurantReservationFilter.inHouse ||
      RestaurantReservationFilter.vip ||
      RestaurantReservationFilter.closed => null,
    };
  }

  static RestaurantReservationArrivalWindowKind? arrivalWindowForFilter(
    RestaurantReservationFilter filter,
  ) {
    return switch (filter) {
      RestaurantReservationFilter.late =>
        RestaurantReservationArrivalWindowKind.late,
      RestaurantReservationFilter.inHouse =>
        RestaurantReservationArrivalWindowKind.inHouse,
      RestaurantReservationFilter.closed =>
        RestaurantReservationArrivalWindowKind.closed,
      RestaurantReservationFilter.all ||
      RestaurantReservationFilter.upcoming ||
      RestaurantReservationFilter.arrived ||
      RestaurantReservationFilter.seated ||
      RestaurantReservationFilter.vip => null,
    };
  }

  static bool matchesSearch(RestaurantReservation reservation, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    bool containsQuery(String value) {
      return value.toLowerCase().contains(normalizedQuery);
    }

    return containsQuery(reservation.guestName) ||
        containsQuery(reservation.zoneLabel) ||
        containsQuery(reservation.tableLabel ?? '') ||
        containsQuery(reservation.phoneNumber ?? '') ||
        containsQuery(reservation.emailAddress ?? '') ||
        containsQuery(reservation.status.label) ||
        containsQuery(reservation.source.label) ||
        containsQuery(reservation.notes ?? '');
  }
}
