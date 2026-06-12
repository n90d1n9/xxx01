import '../models/reservation_qr_scan_context_presentation.dart';
import '../models/reservation_qr_scan_result.dart';

/// Builds host-facing context labels for a resolved reservation QR scan.
class RestaurantReservationQrScanContextPresenter {
  const RestaurantReservationQrScanContextPresenter();

  RestaurantReservationQrScanContextPresentation build(
    RestaurantReservationQrScanResult result,
  ) {
    final payload = result.payload;

    return RestaurantReservationQrScanContextPresentation(
      items: [
        RestaurantReservationQrScanContextItem(
          kind: RestaurantReservationQrScanContextKind.status,
          label: result.status.label,
        ),
        RestaurantReservationQrScanContextItem(
          kind: RestaurantReservationQrScanContextKind.scannedAt,
          label: 'Scanned ${_timeLabel(result.scannedAt)}',
        ),
        if (payload != null) ...[
          RestaurantReservationQrScanContextItem(
            kind: RestaurantReservationQrScanContextKind.intent,
            label: payload.intent.label,
          ),
          if (_hasText(payload.reservationId))
            RestaurantReservationQrScanContextItem(
              kind: RestaurantReservationQrScanContextKind.reservation,
              label: 'Reservation ${payload.reservationId!.trim()}',
            ),
          RestaurantReservationQrScanContextItem(
            kind: RestaurantReservationQrScanContextKind.expiry,
            label: 'Expires ${_timeLabel(payload.expiresAt)}',
          ),
          if (_hasText(payload.zoneLabel))
            RestaurantReservationQrScanContextItem(
              kind: RestaurantReservationQrScanContextKind.zone,
              label: payload.zoneLabel!.trim(),
            ),
          if (_hasText(payload.tableLabel))
            RestaurantReservationQrScanContextItem(
              kind: RestaurantReservationQrScanContextKind.table,
              label: payload.tableLabel!.trim(),
            ),
        ],
      ],
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return value.isUtc ? '$hour:$minute UTC' : '$hour:$minute';
  }
}
