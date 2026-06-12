/// Provides display copy for the QR scan action selected by a host.
class RestaurantReservationQrSelectedActionPresentation {
  const RestaurantReservationQrSelectedActionPresentation({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  String get semanticsLabel => '$title. $message';
}
