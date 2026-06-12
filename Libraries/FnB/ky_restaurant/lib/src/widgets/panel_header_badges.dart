import 'package:flutter/material.dart';

import '../models/restaurant_floor_summary.dart';
import '../models/restaurant_kitchen_summary.dart';
import '../models/restaurant_menu_summary.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_reservation_summary.dart';
import '../models/restaurant_task_summary.dart';
import 'restaurant_briefing_styles.dart';
import 'restaurant_panel_header.dart';

/// Builds reusable operating panel header badge sets from summary models.
class RestaurantPanelHeaderBadges {
  const RestaurantPanelHeaderBadges._();

  static List<Widget> floor(RestaurantFloorSummary summary) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.grid_view_rounded,
        label: '${summary.zoneCount} zones',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.event_seat_outlined,
        label: '${summary.occupiedTables} tables used',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.warning_amber_rounded,
        label: '${summary.attentionCount} watch',
        status: summary.attentionCount > 0
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
      ),
    ];
  }

  static List<Widget> service(RestaurantOperatingSnapshot snapshot) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.groups_2_outlined,
        label: '${snapshot.activeCovers} covers live',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.receipt_long_outlined,
        label: '${snapshot.pendingOrders} pending',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.schedule_outlined,
        label: '${snapshot.averageTicketMinutes}m average',
      ),
    ];
  }

  static List<Widget> briefing(List<RestaurantBriefingItem> items) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.format_list_numbered_rounded,
        label: '${items.length} moves',
      ),
      if (items.isNotEmpty)
        RestaurantPanelHeaderBadge(
          icon: restaurantBriefingCategoryIcon(items.first.category),
          label: items.first.category.label,
          status: items.first.status,
        ),
    ];
  }

  static List<Widget> kitchen(RestaurantKitchenSummary summary) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.room_service_outlined,
        label: '${summary.stationCount} stations',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.local_fire_department_outlined,
        label: '${summary.averageFireMinutes}m fire',
        status: summary.delayedCount > 0
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.warning_amber_rounded,
        label: '${summary.pressureCount} warm',
      ),
    ];
  }

  static List<Widget> menu(RestaurantMenuSummary summary) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.restaurant_menu_outlined,
        label: '${summary.totalCount} items',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.trending_up_rounded,
        label: '${summary.highMarginCount} margin',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.warning_amber_rounded,
        label: '${summary.riskCount} risk',
        status: summary.riskCount > 0
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
      ),
    ];
  }

  static List<Widget> reservation(RestaurantReservationSummary summary) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.event_available_outlined,
        label: '${summary.reservationCount} bookings',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.groups_2_outlined,
        label: '${summary.expectedCovers} covers',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.warning_amber_rounded,
        label: '${summary.lateCount} late',
        status: summary.lateCount > 0
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
      ),
    ];
  }

  static List<Widget> task(RestaurantTaskSummary summary) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.checklist_rounded,
        label: '${summary.totalCount} tasks',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.pending_actions_outlined,
        label: '${summary.openCount} open',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.warning_amber_rounded,
        label: '${summary.attentionCount} watch',
        status: summary.attentionCount > 0
            ? RestaurantServiceStatus.busy
            : RestaurantServiceStatus.calm,
      ),
    ];
  }

  static List<Widget> activity({
    required int totalCount,
    required int visibleCount,
  }) {
    return [
      RestaurantPanelHeaderBadge(
        icon: Icons.history_rounded,
        label: '$totalCount logged',
      ),
      RestaurantPanelHeaderBadge(
        icon: Icons.visibility_outlined,
        label: '$visibleCount visible',
      ),
    ];
  }
}
