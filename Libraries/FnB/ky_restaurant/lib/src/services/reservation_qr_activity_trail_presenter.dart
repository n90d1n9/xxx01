import '../models/reservation_qr_activity_trail_presentation.dart';
import '../models/reservation_qr_session_activity.dart';

/// Builds display rows for the reservation QR session activity trail.
class RestaurantReservationQrActivityTrailPresenter {
  const RestaurantReservationQrActivityTrailPresenter();

  List<RestaurantReservationQrActivityTrailItemPresentation> buildVisible({
    required List<RestaurantReservationQrSessionActivity> activities,
    required int maxVisible,
  }) {
    return activities.take(maxVisible).map(buildItem).toList(growable: false);
  }

  RestaurantReservationQrActivityTrailItemPresentation buildItem(
    RestaurantReservationQrSessionActivity activity,
  ) {
    return RestaurantReservationQrActivityTrailItemPresentation(
      kind: activity.kind,
      tone: activity.tone,
      label: activity.label,
      detail: activity.detail,
      timeLabel: _timeLabel(activity.occurredAt),
    );
  }

  String _timeLabel(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
