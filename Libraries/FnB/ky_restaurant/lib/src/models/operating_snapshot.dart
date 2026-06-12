import 'package:ky_fnb_core/ky_fnb_core.dart' show FnbKitchenStationSummary;

import 'core_aliases.dart';
import 'menu_signal.dart';
import 'metric.dart';
import 'restaurant_reservation.dart';
import 'service_zone.dart';
import 'shift_task.dart';

const Object _unsetMenu = Object();

/// Aggregates the live restaurant data shown across the workspace.
class RestaurantOperatingSnapshot {
  const RestaurantOperatingSnapshot({
    required this.locationName,
    required this.serviceDateLabel,
    required this.openHoursLabel,
    required this.managerName,
    required this.activeCovers,
    required this.pendingOrders,
    required this.seatUtilizationPercent,
    required this.averageTicketMinutes,
    required this.revenueTodayLabel,
    required this.metrics,
    required this.zones,
    required this.stations,
    required this.menuSignals,
    required this.tasks,
    this.menu,
    this.recipes = const [],
    this.reservations = const [],
  });

  final String locationName;
  final String serviceDateLabel;
  final String openHoursLabel;
  final String managerName;
  final int activeCovers;
  final int pendingOrders;
  final int seatUtilizationPercent;
  final int averageTicketMinutes;
  final String revenueTodayLabel;
  final List<RestaurantMetric> metrics;
  final List<RestaurantServiceZone> zones;
  final List<RestaurantKitchenStation> stations;
  final List<RestaurantMenuSignal> menuSignals;
  final List<RestaurantShiftTask> tasks;
  final RestaurantMenu? menu;
  final List<RestaurantRecipe> recipes;
  final List<RestaurantReservation> reservations;

  RestaurantMenuSignal get topMenuSignal {
    return menuSignals.reduce((a, b) => a.orders >= b.orders ? a : b);
  }

  int get blockedOrCriticalZones {
    return zones
        .where(
          (zone) =>
              zone.status == RestaurantServiceStatus.blocked ||
              zone.status == RestaurantServiceStatus.critical,
        )
        .length;
  }

  int get delayedStations {
    return FnbKitchenStationSummary.fromStations(stations).pressureCount;
  }

  RestaurantOperatingSnapshot copyWith({
    String? locationName,
    String? serviceDateLabel,
    String? openHoursLabel,
    String? managerName,
    int? activeCovers,
    int? pendingOrders,
    int? seatUtilizationPercent,
    int? averageTicketMinutes,
    String? revenueTodayLabel,
    List<RestaurantMetric>? metrics,
    List<RestaurantServiceZone>? zones,
    List<RestaurantKitchenStation>? stations,
    List<RestaurantMenuSignal>? menuSignals,
    List<RestaurantShiftTask>? tasks,
    Object? menu = _unsetMenu,
    List<RestaurantRecipe>? recipes,
    List<RestaurantReservation>? reservations,
  }) {
    return RestaurantOperatingSnapshot(
      locationName: locationName ?? this.locationName,
      serviceDateLabel: serviceDateLabel ?? this.serviceDateLabel,
      openHoursLabel: openHoursLabel ?? this.openHoursLabel,
      managerName: managerName ?? this.managerName,
      activeCovers: activeCovers ?? this.activeCovers,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      seatUtilizationPercent:
          seatUtilizationPercent ?? this.seatUtilizationPercent,
      averageTicketMinutes: averageTicketMinutes ?? this.averageTicketMinutes,
      revenueTodayLabel: revenueTodayLabel ?? this.revenueTodayLabel,
      metrics: metrics ?? this.metrics,
      zones: zones ?? this.zones,
      stations: stations ?? this.stations,
      menuSignals: menuSignals ?? this.menuSignals,
      tasks: tasks ?? this.tasks,
      menu: identical(menu, _unsetMenu) ? this.menu : menu as RestaurantMenu?,
      recipes: recipes ?? this.recipes,
      reservations: reservations ?? this.reservations,
    );
  }
}
