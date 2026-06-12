import '../models/reservation_qr_scan_result.dart';
import 'reservation_qr_link_builder.dart';

/// Supplies the current time when resolving scanned reservation QR links.
typedef RestaurantReservationQrScanClock = DateTime Function();

/// Resolves scanned reservation QR links into valid, expired, or invalid results.
class RestaurantReservationQrScanResolver {
  RestaurantReservationQrScanResolver({
    RestaurantReservationQrLinkBuilder? linkBuilder,
    RestaurantReservationQrScanClock? clock,
  }) : linkBuilder = linkBuilder ?? const RestaurantReservationQrLinkBuilder(),
       clock = clock ?? DateTime.now;

  final RestaurantReservationQrLinkBuilder linkBuilder;
  final RestaurantReservationQrScanClock clock;

  RestaurantReservationQrScanResult resolveUri(Uri uri) {
    return _resolveUri(uri, scannedAt: clock());
  }

  RestaurantReservationQrScanResult resolveValue(String value) {
    final scannedAt = clock();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return RestaurantReservationQrScanResult.invalid(
        scannedAt: scannedAt,
        detail: 'Reservation QR link is required.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return RestaurantReservationQrScanResult.invalid(
        scannedAt: scannedAt,
        detail: 'Reservation QR link is invalid.',
      );
    }

    return _resolveUri(uri, scannedAt: scannedAt);
  }

  RestaurantReservationQrScanResult _resolveUri(
    Uri uri, {
    required DateTime scannedAt,
  }) {
    try {
      final payload = linkBuilder.decodeUri(uri);
      if (payload.isExpiredAt(scannedAt)) {
        return RestaurantReservationQrScanResult.expired(
          uri: uri,
          payload: payload,
          scannedAt: scannedAt,
        );
      }

      return RestaurantReservationQrScanResult.valid(
        uri: uri,
        payload: payload,
        scannedAt: scannedAt,
      );
    } on FormatException catch (error) {
      return RestaurantReservationQrScanResult.invalid(
        uri: uri,
        scannedAt: scannedAt,
        detail: error.message,
      );
    }
  }
}
