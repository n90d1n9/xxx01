import 'package:flutter/material.dart';

import '../controllers/reservation_panel_controller.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_status_action_confirmation.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_action_queue.dart';
import '../models/restaurant_reservation_arrival_window.dart';
import '../models/restaurant_reservation_communication.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import '../models/restaurant_reservation_zone_load.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'panel_header_badges.dart';
import 'reservation_panel_body.dart';
import 'reservation_qr_panel_binding.dart';
import 'restaurant_panel.dart';

/// Shows reservation arrivals, seating readiness, VIPs, and no-show risk.
class RestaurantReservationPanel extends StatefulWidget {
  const RestaurantReservationPanel({
    super.key,
    required this.reservations,
    this.onStatusChanged,
    this.initialFilter = RestaurantReservationFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
    this.initialSearchQuery = '',
    this.searchQuery,
    this.onSearchQueryChanged,
    this.onIntakeActionSelected,
    this.onCommunicationSelected,
    this.qrPanelBinding,
    this.qrScanEntry,
    this.qrSessionPanel,
    this.focusedReservationId,
    this.actionConfirmationPolicy =
        const RestaurantReservationStatusActionConfirmationPolicy(),
    this.seatingAdvisor = const RestaurantReservationSeatingAdvisor(),
  });

  final List<RestaurantReservation> reservations;
  final void Function(String reservationId, RestaurantReservationStatus status)?
  onStatusChanged;
  final RestaurantReservationFilter initialFilter;
  final RestaurantReservationFilter? selectedFilter;
  final ValueChanged<RestaurantReservationFilter>? onFilterChanged;
  final String initialSearchQuery;
  final String? searchQuery;
  final ValueChanged<String>? onSearchQueryChanged;
  final ValueChanged<RestaurantReservationIntakeAction>? onIntakeActionSelected;
  final ValueChanged<RestaurantReservationCommunicationDraft>?
  onCommunicationSelected;
  final RestaurantReservationQrPanelBinding? qrPanelBinding;
  final Widget? qrScanEntry;
  final Widget? qrSessionPanel;
  final String? focusedReservationId;
  final RestaurantReservationStatusActionConfirmationPolicy
  actionConfirmationPolicy;
  final RestaurantReservationSeatingAdvisor seatingAdvisor;

  @override
  State<RestaurantReservationPanel> createState() =>
      _RestaurantReservationPanelState();
}

class _RestaurantReservationPanelState
    extends State<RestaurantReservationPanel> {
  late final RestaurantReservationPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantReservationPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
      initialSearchQuery: widget.initialSearchQuery,
      searchQuery: widget.searchQuery,
      onSearchQueryChanged: widget.onSearchQueryChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantReservationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateConfiguration(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
      initialSearchQuery: widget.initialSearchQuery,
      searchQuery: widget.searchQuery,
      onSearchQueryChanged: widget.onSearchQueryChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _controller.dataFor(
      widget.reservations,
      focusedReservationId: widget.focusedReservationId,
      seatingAdvisor: widget.seatingAdvisor,
    );

    return RestaurantPanel(
      title: 'Reservations',
      subtitle: 'Arrivals, seating readiness, VIPs, and no-show risk.',
      leading: const Icon(Icons.event_available_outlined),
      headerBadges: RestaurantPanelHeaderBadges.reservation(data.summary),
      child: RestaurantReservationPanelBody(
        data: data,
        onActionBucketSelected: _selectActionBucket,
        onArrivalWindowSelected: _selectArrivalWindow,
        onSeatingBucketSelected: _selectSeatingReadiness,
        onZoneSelected: _selectZoneLoad,
        onFilterChanged: _selectFilter,
        onSearchQueryChanged: _selectSearchQuery,
        onClearSearch: _clearSearch,
        onShowAll: _showAll,
        onIntakeActionSelected: widget.onIntakeActionSelected,
        qrPanelBinding: widget.qrPanelBinding,
        qrScanEntry: widget.qrScanEntry,
        qrSessionPanel: widget.qrSessionPanel,
        onStatusChanged: widget.onStatusChanged,
        onCommunicationSelected: widget.onCommunicationSelected,
        focusedReservationId: widget.focusedReservationId,
        actionConfirmationPolicy: widget.actionConfirmationPolicy,
        seatingAdvisor: widget.seatingAdvisor,
      ),
    );
  }

  void _selectFilter(RestaurantReservationFilter filter) {
    _refreshWhenLocalStateChanges(() => _controller.selectFilter(filter));
  }

  void _selectActionBucket(RestaurantReservationActionBucketKind kind) {
    _refreshWhenLocalStateChanges(() => _controller.selectActionBucket(kind));
  }

  void _selectArrivalWindow(RestaurantReservationArrivalWindowKind kind) {
    _refreshWhenLocalStateChanges(() => _controller.selectArrivalWindow(kind));
  }

  void _selectSeatingReadiness(
    RestaurantReservationSeatingReadiness readiness,
  ) {
    _refreshWhenLocalStateChanges(
      () => _controller.selectSeatingReadiness(readiness),
    );
  }

  void _selectZoneLoad(RestaurantReservationZoneLoad load) {
    _refreshWhenLocalStateChanges(() => _controller.selectZoneLoad(load));
  }

  void _selectSearchQuery(String query) {
    _refreshWhenLocalStateChanges(() => _controller.selectSearchQuery(query));
  }

  void _clearSearch() {
    _refreshWhenLocalStateChanges(_controller.clearSearch);
  }

  void _showAll() {
    _refreshWhenLocalStateChanges(_controller.showAll);
  }

  void _refreshWhenLocalStateChanges(bool Function() update) {
    if (update()) {
      setState(() {});
    }
  }
}
