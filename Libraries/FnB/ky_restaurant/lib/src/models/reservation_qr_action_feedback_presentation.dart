/// Provides display copy for a reservation QR action feedback notice.
class RestaurantReservationQrActionFeedbackPresentation {
  const RestaurantReservationQrActionFeedbackPresentation({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  String get semanticsLabel => '$title. $message';
}
