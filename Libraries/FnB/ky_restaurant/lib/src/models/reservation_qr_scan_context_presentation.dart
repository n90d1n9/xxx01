/// Identifies the kind of context shown for a resolved QR scan.
enum RestaurantReservationQrScanContextKind {
  status,
  scannedAt,
  intent,
  reservation,
  expiry,
  zone,
  table,
}

/// Describes one compact context label for a resolved QR scan.
class RestaurantReservationQrScanContextItem {
  const RestaurantReservationQrScanContextItem({
    required this.kind,
    required this.label,
  });

  final RestaurantReservationQrScanContextKind kind;
  final String label;
}

/// Carries the compact context labels shown beneath a QR scan result.
class RestaurantReservationQrScanContextPresentation {
  const RestaurantReservationQrScanContextPresentation({required this.items});

  final List<RestaurantReservationQrScanContextItem> items;

  bool get isEmpty => items.isEmpty;

  String get semanticsLabel {
    return items.map((item) => item.label).join('. ');
  }
}
