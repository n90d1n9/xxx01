import '../models/reservation_qr_payload.dart';
import '../models/reservation_qr_presentation.dart';
import '../models/reservation_qr_scan_result.dart';

/// Builds reusable display labels for reservation QR links and scan outcomes.
class RestaurantReservationQrPresentationBuilder {
  const RestaurantReservationQrPresentationBuilder();

  RestaurantReservationQrPayloadPresentation buildPayload(
    RestaurantReservationQrPayload payload,
  ) {
    final expiryLabel = _expiryLabel(payload.expiresAt);
    final locationLabel = _locationLabel(payload);

    return RestaurantReservationQrPayloadPresentation(
      title: payload.intent.label,
      subtitle: locationLabel == null
          ? expiryLabel
          : '$locationLabel - $expiryLabel',
      expiryLabel: expiryLabel,
      metadata: [
        RestaurantReservationQrMetadataItem(
          kind: RestaurantReservationQrMetadataKind.intent,
          label: payload.intent.label,
        ),
        RestaurantReservationQrMetadataItem(
          kind: RestaurantReservationQrMetadataKind.expiry,
          label: expiryLabel,
        ),
        if (payload.zoneLabel != null)
          RestaurantReservationQrMetadataItem(
            kind: RestaurantReservationQrMetadataKind.zone,
            label: payload.zoneLabel!,
          ),
        if (payload.tableLabel != null)
          RestaurantReservationQrMetadataItem(
            kind: RestaurantReservationQrMetadataKind.table,
            label: payload.tableLabel!,
          ),
      ],
    );
  }

  RestaurantReservationQrScanPresentation buildScan(
    RestaurantReservationQrScanResult result,
  ) {
    final payload = result.payload;

    return RestaurantReservationQrScanPresentation(
      statusLabel: result.status.label,
      detailLabel: result.detailLabel,
      payload: payload == null ? null : buildPayload(payload),
    );
  }

  String? _locationLabel(RestaurantReservationQrPayload payload) {
    final label = [
      payload.zoneLabel,
      payload.tableLabel,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' - ');

    return label.isEmpty ? null : label;
  }

  String _expiryLabel(DateTime expiresAt) {
    final hour = expiresAt.hour.toString().padLeft(2, '0');
    final minute = expiresAt.minute.toString().padLeft(2, '0');
    return expiresAt.isUtc
        ? 'Expires $hour:$minute UTC'
        : 'Expires $hour:$minute';
  }
}
