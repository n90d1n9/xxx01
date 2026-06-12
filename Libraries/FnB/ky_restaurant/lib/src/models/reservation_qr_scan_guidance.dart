import 'reservation_qr_scan_action_plan.dart';
import 'reservation_qr_scan_result.dart';

/// Identifies the operator-facing urgency for one QR scan guidance note.
enum RestaurantReservationQrScanGuidanceTone { success, warning, critical }

/// Describes the next host step after a reservation QR scan is resolved.
class RestaurantReservationQrScanGuidance {
  const RestaurantReservationQrScanGuidance({
    required this.title,
    required this.message,
    required this.tone,
  });

  factory RestaurantReservationQrScanGuidance.fromScan({
    required RestaurantReservationQrScanResult result,
    required RestaurantReservationQrScanActionPlan actionPlan,
  }) {
    if (result.isExpired) {
      return RestaurantReservationQrScanGuidance(
        title: 'Generate a fresh QR',
        message: _expiredMessage(result),
        tone: RestaurantReservationQrScanGuidanceTone.warning,
      );
    }

    if (result.isInvalid) {
      return RestaurantReservationQrScanGuidance(
        title: 'Use another intake path',
        message:
            result.detail ??
            'Ask the guest to refresh the QR link or continue manually.',
        tone: RestaurantReservationQrScanGuidanceTone.critical,
      );
    }

    final action = actionPlan.primaryAction;
    final intentLabel = result.payload?.intent.label.toLowerCase();
    final actionLabel = action?.label ?? 'Continue';

    return RestaurantReservationQrScanGuidance(
      title: 'Ready to continue',
      message: intentLabel == null
          ? '$actionLabel keeps the reservation flow moving.'
          : '$actionLabel keeps the $intentLabel flow moving.',
      tone: RestaurantReservationQrScanGuidanceTone.success,
    );
  }

  final String title;
  final String message;
  final RestaurantReservationQrScanGuidanceTone tone;

  bool get needsAttention {
    return tone != RestaurantReservationQrScanGuidanceTone.success;
  }
}

String _expiredMessage(RestaurantReservationQrScanResult result) {
  final expiresAt = result.payload?.expiresAt;
  if (expiresAt == null) {
    return 'Refresh the link before continuing with this guest.';
  }

  final hour = expiresAt.hour.toString().padLeft(2, '0');
  final minute = expiresAt.minute.toString().padLeft(2, '0');
  final suffix = expiresAt.isUtc ? ' UTC' : '';
  return 'This link expired at $hour:$minute$suffix. Refresh it before continuing.';
}
