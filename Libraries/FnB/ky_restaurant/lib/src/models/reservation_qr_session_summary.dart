/// Describes the visual urgency of a reservation QR session summary.
enum RestaurantReservationQrSessionSummaryTone {
  neutral,
  active,
  success,
  warning,
  critical,
}

/// Holds one compact session summary statistic for operator scanning.
class RestaurantReservationQrSessionSummaryMetric {
  const RestaurantReservationQrSessionSummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  String get text => '$label: $value';
}

/// Carries host-facing copy for the compact reservation QR session header.
class RestaurantReservationQrSessionSummaryPresentation {
  const RestaurantReservationQrSessionSummaryPresentation({
    required this.title,
    required this.message,
    required this.tone,
    this.metrics = const [],
  });

  final String title;
  final String message;
  final RestaurantReservationQrSessionSummaryTone tone;
  final List<RestaurantReservationQrSessionSummaryMetric> metrics;

  String get semanticsLabel {
    return [
      title,
      message,
      ...metrics.map((metric) => metric.text),
    ].map(_sentence).where((copy) => copy.isNotEmpty).join(' ');
  }
}

String _sentence(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.endsWith('.') || trimmed.endsWith('!') || trimmed.endsWith('?')) {
    return trimmed;
  }
  return '$trimmed.';
}
