import 'reservation_qr_payload.dart';

/// Describes the outcome of resolving a scanned reservation QR link.
enum RestaurantReservationQrScanStatus {
  valid,
  expired,
  invalid;

  String get label => switch (this) {
    RestaurantReservationQrScanStatus.valid => 'QR link ready',
    RestaurantReservationQrScanStatus.expired => 'QR link expired',
    RestaurantReservationQrScanStatus.invalid => 'QR link unavailable',
  };
}

/// Carries a decoded reservation QR scan outcome for services and widgets.
class RestaurantReservationQrScanResult {
  const RestaurantReservationQrScanResult._({
    required this.status,
    required this.scannedAt,
    this.uri,
    this.payload,
    this.detail,
  });

  factory RestaurantReservationQrScanResult.valid({
    required Uri uri,
    required RestaurantReservationQrPayload payload,
    required DateTime scannedAt,
  }) {
    return RestaurantReservationQrScanResult._(
      status: RestaurantReservationQrScanStatus.valid,
      uri: uri,
      payload: payload,
      scannedAt: scannedAt,
    );
  }

  factory RestaurantReservationQrScanResult.expired({
    required Uri uri,
    required RestaurantReservationQrPayload payload,
    required DateTime scannedAt,
  }) {
    return RestaurantReservationQrScanResult._(
      status: RestaurantReservationQrScanStatus.expired,
      uri: uri,
      payload: payload,
      scannedAt: scannedAt,
    );
  }

  factory RestaurantReservationQrScanResult.invalid({
    required DateTime scannedAt,
    Uri? uri,
    String? detail,
  }) {
    return RestaurantReservationQrScanResult._(
      status: RestaurantReservationQrScanStatus.invalid,
      uri: uri,
      scannedAt: scannedAt,
      detail: detail,
    );
  }

  final RestaurantReservationQrScanStatus status;
  final Uri? uri;
  final RestaurantReservationQrPayload? payload;
  final DateTime scannedAt;
  final String? detail;

  bool get isValid => status == RestaurantReservationQrScanStatus.valid;

  bool get isExpired => status == RestaurantReservationQrScanStatus.expired;

  bool get isInvalid => status == RestaurantReservationQrScanStatus.invalid;

  String get detailLabel {
    final payload = this.payload;
    return detail ??
        switch (status) {
          RestaurantReservationQrScanStatus.valid =>
            payload == null
                ? 'Ready to continue.'
                : '${payload.intent.label} is ready to continue.',
          RestaurantReservationQrScanStatus.expired =>
            'Ask the guest to refresh the QR code.',
          RestaurantReservationQrScanStatus.invalid =>
            'The QR link could not be read.',
        };
  }
}
