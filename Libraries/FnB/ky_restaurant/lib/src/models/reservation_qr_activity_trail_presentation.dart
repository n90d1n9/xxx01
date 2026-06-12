import 'reservation_qr_session_activity.dart';

/// Provides display data for one reservation QR activity trail row.
class RestaurantReservationQrActivityTrailItemPresentation {
  const RestaurantReservationQrActivityTrailItemPresentation({
    required this.kind,
    required this.tone,
    required this.label,
    required this.timeLabel,
    this.detail,
  });

  final RestaurantReservationQrSessionActivityKind kind;
  final RestaurantReservationQrSessionActivityTone tone;
  final String label;
  final String? detail;
  final String timeLabel;

  String get semanticsLabel {
    final detail = this.detail;
    if (detail == null || detail.isEmpty) {
      return '${_sentence(label)} Recorded at $timeLabel.';
    }

    return '${_sentence(label)} ${_sentence(detail)} Recorded at $timeLabel.';
  }
}

String _sentence(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  final last = trimmed[trimmed.length - 1];
  if (last == '.' || last == '!' || last == '?') return trimmed;
  return '$trimmed.';
}
