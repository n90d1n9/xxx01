import 'package:flutter/widgets.dart';

import '../models/reservation_qr_scan_workflow.dart';

/// Describes how a reservation QR scan entry should render and report scans.
@immutable
class RestaurantReservationQrScanEntryBinding {
  const RestaurantReservationQrScanEntryBinding({
    this.entry,
    this.visible = true,
    this.includeDismiss = true,
    this.onResolved,
    this.onCleared,
  });

  /// Hides the scan entry while keeping QR intake and session panels available.
  static const hidden = RestaurantReservationQrScanEntryBinding(visible: false);

  final Widget? entry;
  final bool visible;
  final bool includeDismiss;
  final ValueChanged<RestaurantReservationQrScanWorkflow>? onResolved;
  final VoidCallback? onCleared;
}
