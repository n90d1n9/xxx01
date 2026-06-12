import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_refresh_feedback_presentation.dart';

/// Builds host-facing feedback after a reservation QR handoff is refreshed.
class RestaurantReservationQrRefreshFeedbackPresenter {
  const RestaurantReservationQrRefreshFeedbackPresenter();

  RestaurantReservationQrRefreshFeedbackPresentation build(
    RestaurantReservationQrLink link,
  ) {
    return RestaurantReservationQrRefreshFeedbackPresentation(
      title: '${link.payload.intent.label} QR refreshed',
      message: _messageFor(link),
    );
  }

  String _messageFor(RestaurantReservationQrLink link) {
    final context = _contextLabel(link);
    if (context == null) {
      return 'New handoff link is live for the guest.';
    }
    return 'New handoff link is live for $context.';
  }

  String? _contextLabel(RestaurantReservationQrLink link) {
    final labels = [
      link.payload.zoneLabel,
      link.payload.tableLabel,
    ].whereType<String>().where((value) => value.trim().isNotEmpty);
    final context = labels.join(' - ');
    return context.isEmpty ? null : context;
  }
}
