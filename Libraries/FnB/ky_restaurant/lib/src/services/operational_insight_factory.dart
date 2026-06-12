import '../models/restaurant_models.dart';
import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_operational_insight.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_view.dart';

/// Creates operational insight models from prioritized restaurant entities.
class RestaurantOperationalInsightFactory {
  const RestaurantOperationalInsightFactory();

  RestaurantOperationalInsight reservationRisk(
    RestaurantReservation reservation,
  ) {
    final late = reservation.status == RestaurantReservationStatus.late;

    return RestaurantOperationalInsight(
      id: 'reservation-risk-${reservation.id}',
      kind: RestaurantOperationalInsightKind.reservationRisk,
      title: late
          ? 'Recover ${reservation.guestName}'
          : 'Prepare ${reservation.guestName}',
      valueLabel: late
          ? '${reservation.arrivalMinutesFromNow.abs()}m late'
          : 'VIP ${reservation.arrivalMinutesFromNow}m',
      detail: '${reservation.partyLabel}, ${reservation.seatingLabel}',
      status: late
          ? RestaurantServiceStatus.critical
          : RestaurantServiceStatus.busy,
      targetView: RestaurantWorkspaceView.reservations,
      targetFilters: RestaurantWorkspacePanelFilters(
        reservations: late
            ? RestaurantReservationFilter.late
            : RestaurantReservationFilter.vip,
        activity: RestaurantActivityFilter.reservations,
      ),
    );
  }

  RestaurantOperationalInsight menuRisk(RestaurantMenuSignal signal) {
    return RestaurantOperationalInsight(
      id: 'menu-risk-${signal.id}',
      kind: RestaurantOperationalInsightKind.menuRisk,
      title: 'Protect ${signal.name}',
      valueLabel: '${signal.soldOutRiskPercent}% risk',
      detail: '${signal.orders} orders, ${signal.prepMinutes}m prep',
      status: _riskStatus(signal.soldOutRiskPercent),
      targetView: RestaurantWorkspaceView.menu,
      targetFilters: const RestaurantWorkspacePanelFilters(
        menu: RestaurantMenuFilter.risk,
        activity: RestaurantActivityFilter.menu,
        menuSort: RestaurantMenuSort.risk,
      ),
    );
  }

  RestaurantOperationalInsight marginLeader(RestaurantMenuSignal signal) {
    return RestaurantOperationalInsight(
      id: 'margin-leader-${signal.id}',
      kind: RestaurantOperationalInsightKind.marginLeader,
      title: 'Push ${signal.name}',
      valueLabel: '${signal.grossMarginPercent}% margin',
      detail: '${signal.orders} orders, ${signal.soldOutRiskPercent}% risk',
      status: signal.soldOutRiskPercent >= 50
          ? RestaurantServiceStatus.busy
          : RestaurantServiceStatus.calm,
      targetView: RestaurantWorkspaceView.menu,
      targetFilters: const RestaurantWorkspacePanelFilters(
        menu: RestaurantMenuFilter.margin,
        menuSort: RestaurantMenuSort.margin,
      ),
    );
  }

  RestaurantOperationalInsight quickPrep(RestaurantMenuSignal signal) {
    return RestaurantOperationalInsight(
      id: 'quick-prep-${signal.id}',
      kind: RestaurantOperationalInsightKind.quickPrep,
      title: 'Fast win ${signal.name}',
      valueLabel: '${signal.prepMinutes}m prep',
      detail: '${signal.orders} orders, ${signal.grossMarginPercent}% margin',
      status: signal.prepMinutes <= 8
          ? RestaurantServiceStatus.calm
          : RestaurantServiceStatus.busy,
      targetView: RestaurantWorkspaceView.menu,
      targetFilters: const RestaurantWorkspacePanelFilters(
        menu: RestaurantMenuFilter.quick,
        menuSort: RestaurantMenuSort.prep,
      ),
    );
  }

  RestaurantOperationalInsight kitchenBottleneck(
    RestaurantKitchenStation station,
  ) {
    return kitchenPressure(
      RestaurantKitchenPressureSignal(status: station.status, station: station),
    );
  }

  RestaurantOperationalInsight kitchenPressure(
    RestaurantKitchenPressureSignal signal,
  ) {
    final station = signal.station;

    return RestaurantOperationalInsight(
      id: 'kitchen-bottleneck-${station?.id ?? 'clear'}',
      kind: RestaurantOperationalInsightKind.kitchenBottleneck,
      title: signal.titleLabel,
      valueLabel: station?.fireTimeLabel ?? signal.status.label,
      detail: station == null
          ? signal.messageLabel
          : '${signal.actionLabel}, ${station.ticketLabel}',
      status: signal.status,
      targetView: RestaurantWorkspaceView.kitchen,
      targetFilters: const RestaurantWorkspacePanelFilters(
        kitchen: RestaurantKitchenFilter.pressure,
        activity: RestaurantActivityFilter.kitchen,
      ),
    );
  }
}

RestaurantServiceStatus _riskStatus(int riskPercent) {
  if (riskPercent >= 70) return RestaurantServiceStatus.critical;
  if (riskPercent >= 50) return RestaurantServiceStatus.busy;
  return RestaurantServiceStatus.calm;
}
