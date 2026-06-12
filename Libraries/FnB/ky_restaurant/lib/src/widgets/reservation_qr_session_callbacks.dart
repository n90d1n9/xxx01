import 'package:flutter/foundation.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import '../services/reservation_qr_action_handler.dart';

/// Groups host callbacks used by reservation QR session widgets.
class RestaurantReservationQrSessionCallbacks {
  const RestaurantReservationQrSessionCallbacks({
    this.onCopyLink,
    this.onOpenLink,
    this.onRefreshLink,
    this.onScanActionSelected,
    this.onScanActionHandled,
    this.onContinue,
    this.onRefreshScan,
    this.onDismissScan,
  });

  static const empty = RestaurantReservationQrSessionCallbacks();

  final ValueChanged<Uri>? onCopyLink;
  final ValueChanged<Uri>? onOpenLink;
  final VoidCallback? onRefreshLink;
  final ValueChanged<RestaurantReservationQrScanAction>? onScanActionSelected;
  final ValueChanged<RestaurantReservationQrActionHandlingResult>?
  onScanActionHandled;
  final VoidCallback? onContinue;
  final VoidCallback? onRefreshScan;
  final VoidCallback? onDismissScan;

  RestaurantReservationQrSessionCallbacks mergeWith({
    ValueChanged<Uri>? onCopyLink,
    ValueChanged<Uri>? onOpenLink,
    VoidCallback? onRefreshLink,
    ValueChanged<RestaurantReservationQrScanAction>? onScanActionSelected,
    ValueChanged<RestaurantReservationQrActionHandlingResult>?
    onScanActionHandled,
    VoidCallback? onContinue,
    VoidCallback? onRefreshScan,
    VoidCallback? onDismissScan,
  }) {
    return RestaurantReservationQrSessionCallbacks(
      onCopyLink: onCopyLink ?? this.onCopyLink,
      onOpenLink: onOpenLink ?? this.onOpenLink,
      onRefreshLink: onRefreshLink ?? this.onRefreshLink,
      onScanActionSelected: onScanActionSelected ?? this.onScanActionSelected,
      onScanActionHandled: onScanActionHandled ?? this.onScanActionHandled,
      onContinue: onContinue ?? this.onContinue,
      onRefreshScan: onRefreshScan ?? this.onRefreshScan,
      onDismissScan: onDismissScan ?? this.onDismissScan,
    );
  }
}
