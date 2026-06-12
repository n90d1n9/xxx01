/// Provides display copy for a selectable reservation QR scan action.
class RestaurantReservationQrScanActionPresentation {
  const RestaurantReservationQrScanActionPresentation({
    required this.label,
    required this.detail,
  });

  final String label;
  final String detail;

  String get tooltipLabel => '$label. $detail';
}
