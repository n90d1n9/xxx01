import 'package:flutter/material.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_qr_scan_action_plan.dart';
import '../services/reservation_qr_presentation_builder.dart';
import 'reservation_qr_session_callbacks.dart';
import 'reservation_qr_session_panel.dart';

/// Binds a reservation QR session controller to the reusable session panel UI.
class RestaurantReservationQrSessionControllerPanel extends StatelessWidget {
  const RestaurantReservationQrSessionControllerPanel({
    super.key,
    required this.controller,
    this.linkTitle = 'Active QR handoff',
    this.scanTitle = 'Latest scan',
    this.callbacks = RestaurantReservationQrSessionCallbacks.empty,
    this.onCopyLink,
    this.onOpenLink,
    this.onRefreshLink,
    this.onScanActionSelected,
    this.onContinue,
    this.onRefreshScan,
    this.onDismissScan,
    this.showActivityTrail = true,
    this.presentationBuilder =
        const RestaurantReservationQrPresentationBuilder(),
    this.summaryNow,
  });

  final RestaurantReservationQrSessionController controller;
  final String linkTitle;
  final String scanTitle;
  final RestaurantReservationQrSessionCallbacks callbacks;
  final ValueChanged<Uri>? onCopyLink;
  final ValueChanged<Uri>? onOpenLink;
  final VoidCallback? onRefreshLink;
  final ValueChanged<RestaurantReservationQrScanAction>? onScanActionSelected;
  final VoidCallback? onContinue;
  final VoidCallback? onRefreshScan;
  final VoidCallback? onDismissScan;
  final bool showActivityTrail;
  final RestaurantReservationQrPresentationBuilder presentationBuilder;
  final DateTime? summaryNow;

  @override
  Widget build(BuildContext context) {
    final effectiveCallbacks = _callbacks;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return RestaurantReservationQrSessionPanel(
          state: controller.state,
          linkTitle: linkTitle,
          scanTitle: scanTitle,
          callbacks: effectiveCallbacks,
          onScanActionSelected: _selectScanAction,
          onDismissScan: _dismissScan,
          showActivityTrail: showActivityTrail,
          presentationBuilder: presentationBuilder,
          summaryNow: summaryNow,
        );
      },
    );
  }

  RestaurantReservationQrSessionCallbacks get _callbacks {
    return callbacks.mergeWith(
      onCopyLink: onCopyLink,
      onOpenLink: onOpenLink,
      onRefreshLink: onRefreshLink,
      onScanActionSelected: onScanActionSelected,
      onContinue: onContinue,
      onRefreshScan: onRefreshScan,
      onDismissScan: onDismissScan,
    );
  }

  void _selectScanAction(RestaurantReservationQrScanAction action) {
    if (controller.selectScanAction(action)) {
      _callbacks.onScanActionSelected?.call(action);
    }
  }

  void _dismissScan() {
    controller.clearScan();
    _callbacks.onDismissScan?.call();
  }
}
