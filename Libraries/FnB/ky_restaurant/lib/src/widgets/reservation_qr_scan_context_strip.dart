import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_context_presentation.dart';
import '../models/reservation_qr_scan_result.dart';
import '../services/reservation_qr_scan_context_presenter.dart';
import 'restaurant_signal_chip.dart';

/// Shows compact context chips for a resolved reservation QR scan.
class RestaurantReservationQrScanContextStrip extends StatelessWidget {
  const RestaurantReservationQrScanContextStrip({
    super.key,
    required this.result,
    this.presenter = const RestaurantReservationQrScanContextPresenter(),
    this.statusForegroundColor,
    this.statusBackgroundColor,
    this.statusBorderColor,
  });

  final RestaurantReservationQrScanResult result;
  final RestaurantReservationQrScanContextPresenter presenter;
  final Color? statusForegroundColor;
  final Color? statusBackgroundColor;
  final Color? statusBorderColor;

  @override
  Widget build(BuildContext context) {
    final presentation = presenter.build(result);
    if (presentation.isEmpty) return const SizedBox.shrink();

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: presentation.semanticsLabel,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in presentation.items)
            RestaurantSignalChip(
              label: item.label,
              icon: _iconFor(item.kind, result.status),
              foregroundColor:
                  item.kind == RestaurantReservationQrScanContextKind.status
                  ? statusForegroundColor
                  : null,
              backgroundColor:
                  item.kind == RestaurantReservationQrScanContextKind.status
                  ? statusBackgroundColor
                  : null,
              borderColor:
                  item.kind == RestaurantReservationQrScanContextKind.status
                  ? statusBorderColor
                  : null,
            ),
        ],
      ),
    );
  }
}

IconData _iconFor(
  RestaurantReservationQrScanContextKind kind,
  RestaurantReservationQrScanStatus status,
) {
  return switch (kind) {
    RestaurantReservationQrScanContextKind.status => _iconForStatus(status),
    RestaurantReservationQrScanContextKind.scannedAt => Icons.schedule_outlined,
    RestaurantReservationQrScanContextKind.intent =>
      Icons.qr_code_scanner_rounded,
    RestaurantReservationQrScanContextKind.reservation =>
      Icons.confirmation_number_outlined,
    RestaurantReservationQrScanContextKind.expiry =>
      Icons.history_toggle_off_outlined,
    RestaurantReservationQrScanContextKind.zone =>
      Icons.table_restaurant_outlined,
    RestaurantReservationQrScanContextKind.table => Icons.event_seat_outlined,
  };
}

IconData _iconForStatus(RestaurantReservationQrScanStatus status) {
  return switch (status) {
    RestaurantReservationQrScanStatus.valid => Icons.verified_outlined,
    RestaurantReservationQrScanStatus.expired =>
      Icons.history_toggle_off_outlined,
    RestaurantReservationQrScanStatus.invalid => Icons.error_outline_rounded,
  };
}
