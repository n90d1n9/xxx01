import '../models/reservation_qr_action_feedback_presentation.dart';
import 'reservation_qr_action_handler.dart';

/// Builds operator-facing copy for reservation QR action handling results.
class RestaurantReservationQrActionFeedbackPresenter {
  const RestaurantReservationQrActionFeedbackPresenter();

  RestaurantReservationQrActionFeedbackPresentation build(
    RestaurantReservationQrActionHandlingResult result,
  ) {
    return RestaurantReservationQrActionFeedbackPresentation(
      title: _titleFor(result),
      message: _messageFor(result),
    );
  }

  String _titleFor(RestaurantReservationQrActionHandlingResult result) {
    final actionLabel = result.action?.label ?? 'QR action';

    return switch (result.status) {
      RestaurantReservationQrActionHandlingStatus.pending =>
        '$actionLabel in progress',
      RestaurantReservationQrActionHandlingStatus.handled =>
        '$actionLabel handled',
      RestaurantReservationQrActionHandlingStatus.failed =>
        '$actionLabel failed',
      RestaurantReservationQrActionHandlingStatus.unavailable =>
        'Action needs setup',
      RestaurantReservationQrActionHandlingStatus.notAllowed =>
        'Action unavailable',
      RestaurantReservationQrActionHandlingStatus.missingReservationId =>
        'Reservation id missing',
    };
  }

  String _messageFor(RestaurantReservationQrActionHandlingResult result) {
    final detail = result.detail;
    if (detail != null) return detail;

    return switch (result.status) {
      RestaurantReservationQrActionHandlingStatus.pending =>
        'Keep this scan open while the workflow finishes.',
      RestaurantReservationQrActionHandlingStatus.handled =>
        'Reservation workflow updated from QR scan.',
      RestaurantReservationQrActionHandlingStatus.failed =>
        'The QR workflow did not finish.',
      RestaurantReservationQrActionHandlingStatus.unavailable ||
      RestaurantReservationQrActionHandlingStatus.notAllowed ||
      RestaurantReservationQrActionHandlingStatus.missingReservationId =>
        'Review the QR scan and try another action.',
    };
  }
}
