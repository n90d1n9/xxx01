import 'restaurant_models.dart';

/// Identifies the operating lane represented by a service pulse metric.
enum RestaurantServicePulseMetricKind { floor, reservations, kitchen, menu }

/// Describes one cross-functional service pulse metric for presentation.
class RestaurantServicePulseMetric {
  const RestaurantServicePulseMetric({
    required this.kind,
    required this.label,
    required this.value,
    required this.detail,
    required this.status,
  });

  final RestaurantServicePulseMetricKind kind;
  final String label;
  final String value;
  final String detail;
  final RestaurantServiceStatus status;
}
