/// Identifies the kind of metadata shown for a reservation QR payload.
enum RestaurantReservationQrMetadataKind { intent, expiry, zone, table }

/// Describes one compact metadata label for reservation QR presentation.
class RestaurantReservationQrMetadataItem {
  const RestaurantReservationQrMetadataItem({
    required this.kind,
    required this.label,
  });

  final RestaurantReservationQrMetadataKind kind;
  final String label;
}

/// Carries reusable labels for a generated reservation QR payload.
class RestaurantReservationQrPayloadPresentation {
  const RestaurantReservationQrPayloadPresentation({
    required this.title,
    required this.subtitle,
    required this.expiryLabel,
    required this.metadata,
  });

  final String title;
  final String subtitle;
  final String expiryLabel;
  final List<RestaurantReservationQrMetadataItem> metadata;
}

/// Carries reusable labels for a resolved reservation QR scan outcome.
class RestaurantReservationQrScanPresentation {
  const RestaurantReservationQrScanPresentation({
    required this.statusLabel,
    required this.detailLabel,
    required this.payload,
  });

  final String statusLabel;
  final String detailLabel;
  final RestaurantReservationQrPayloadPresentation? payload;
}
