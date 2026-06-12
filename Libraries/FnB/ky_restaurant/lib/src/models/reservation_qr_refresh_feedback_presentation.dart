/// Provides display copy for a reservation QR link refresh feedback notice.
class RestaurantReservationQrRefreshFeedbackPresentation {
  const RestaurantReservationQrRefreshFeedbackPresentation({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  String get semanticsLabel => '$title. $message';
}
