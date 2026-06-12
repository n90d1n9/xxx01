import '../models/reservation_qr_expiry_status.dart';

/// Builds relative expiry status for active reservation QR handoff links.
class RestaurantReservationQrExpiryStatusPresenter {
  const RestaurantReservationQrExpiryStatusPresenter({
    this.warningThreshold = const Duration(minutes: 5),
  });

  final Duration warningThreshold;

  RestaurantReservationQrExpiryStatus build({
    required DateTime expiresAt,
    DateTime? now,
  }) {
    final referenceTime = now ?? DateTime.now();
    final remaining = expiresAt.difference(referenceTime);
    if (remaining <= Duration.zero) {
      return RestaurantReservationQrExpiryStatus(
        urgency: RestaurantReservationQrExpiryUrgency.expired,
        label: _expiredLabel(remaining),
      );
    }

    final urgency = remaining <= warningThreshold
        ? RestaurantReservationQrExpiryUrgency.expiringSoon
        : RestaurantReservationQrExpiryUrgency.fresh;

    return RestaurantReservationQrExpiryStatus(
      urgency: urgency,
      label: 'Expires in ${_durationLabel(remaining)}',
    );
  }

  String _expiredLabel(Duration remaining) {
    final elapsed = Duration(microseconds: -remaining.inMicroseconds);
    if (elapsed < const Duration(minutes: 1)) return 'Expired just now';
    return 'Expired ${_durationLabel(elapsed)} ago';
  }

  String _durationLabel(Duration duration) {
    final totalMinutes = (duration.inSeconds / 60).ceil();
    if (totalMinutes <= 1) return '1 min';
    if (totalMinutes < 60) return '$totalMinutes min';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final hourLabel = hours == 1 ? '1 hr' : '$hours hr';
    if (minutes == 0) return hourLabel;
    return '$hourLabel $minutes min';
  }
}
