import 'package:flutter/material.dart';

import '../models/reservation_intake_action.dart';
import '../models/restaurant_reservation_action_queue.dart';
import '../models/restaurant_reservation_arrival_window.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_reservation_panel_data.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import '../models/restaurant_reservation_zone_load.dart';
import 'reservation_contact_coverage_strip.dart';
import 'reservation_qr_handoff_section.dart';
import 'reservation_qr_panel_binding.dart';
import 'reservation_seating_queue_strip.dart';
import 'restaurant_reservation_action_queue.dart';
import 'restaurant_reservation_arrival_queue.dart';
import 'restaurant_reservation_filter_bar.dart';
import 'restaurant_reservation_summary_strip.dart';
import 'restaurant_reservation_zone_load_grid.dart';
import 'restaurant_search_field.dart';

/// Displays reservation summary, intake, queue, zone, filter, and search controls.
class RestaurantReservationControlsSection extends StatelessWidget {
  const RestaurantReservationControlsSection({
    super.key,
    required this.data,
    required this.onActionBucketSelected,
    required this.onArrivalWindowSelected,
    required this.onSeatingBucketSelected,
    required this.onZoneSelected,
    required this.onFilterChanged,
    required this.onSearchQueryChanged,
    this.onIntakeActionSelected,
    this.qrPanelBinding,
    this.qrScanEntry,
    this.qrSessionPanel,
  });

  final RestaurantReservationPanelData data;
  final ValueChanged<RestaurantReservationActionBucketKind>
  onActionBucketSelected;
  final ValueChanged<RestaurantReservationArrivalWindowKind>
  onArrivalWindowSelected;
  final ValueChanged<RestaurantReservationSeatingReadiness>
  onSeatingBucketSelected;
  final ValueChanged<RestaurantReservationZoneLoad> onZoneSelected;
  final ValueChanged<RestaurantReservationFilter> onFilterChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<RestaurantReservationIntakeAction>? onIntakeActionSelected;
  final RestaurantReservationQrPanelBinding? qrPanelBinding;
  final Widget? qrScanEntry;
  final Widget? qrSessionPanel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantReservationSummaryStrip(summary: data.summary),
        const SizedBox(height: 14),
        RestaurantReservationContactCoverageStrip(
          summary: data.contactCoverageSummary,
        ),
        const SizedBox(height: 14),
        RestaurantReservationQrHandoffSection(
          onIntakeActionSelected: onIntakeActionSelected,
          binding: qrPanelBinding,
          scanEntry: qrScanEntry,
          sessionPanel: qrSessionPanel,
        ),
        const SizedBox(height: 14),
        RestaurantReservationActionQueue(
          summary: data.actionQueueSummary,
          selectedBucketKind: data.selectedActionBucketKind,
          onBucketSelected: onActionBucketSelected,
        ),
        const SizedBox(height: 14),
        RestaurantReservationSeatingQueueStrip(
          summary: data.seatingQueueSummary,
          onBucketSelected: onSeatingBucketSelected,
        ),
        const SizedBox(height: 14),
        RestaurantReservationArrivalQueue(
          windows: data.arrivalWindows,
          selectedWindowKind: data.selectedArrivalWindowKind,
          onWindowSelected: onArrivalWindowSelected,
        ),
        const SizedBox(height: 14),
        RestaurantReservationZoneLoadGrid(
          loads: data.zoneLoads,
          selectedZoneLabel: data.searchQuery,
          onZoneSelected: onZoneSelected,
        ),
        const SizedBox(height: 14),
        RestaurantReservationFilterBar(
          reservations: data.reservations,
          selectedFilter: data.selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 12),
        RestaurantSearchField(
          value: data.searchQuery,
          hintText: 'Search reservations',
          onChanged: onSearchQueryChanged,
        ),
      ],
    );
  }
}
