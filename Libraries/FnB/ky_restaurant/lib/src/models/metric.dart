import 'core_aliases.dart';

/// Captures a headline operating metric for the restaurant workspace.
class RestaurantMetric {
  const RestaurantMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.trend,
    required this.status,
  });

  final String id;
  final String label;
  final String value;
  final String detail;
  final String trend;
  final RestaurantServiceStatus status;

  RestaurantMetric copyWith({
    String? label,
    String? value,
    String? detail,
    String? trend,
    RestaurantServiceStatus? status,
  }) {
    return RestaurantMetric(
      id: id,
      label: label ?? this.label,
      value: value ?? this.value,
      detail: detail ?? this.detail,
      trend: trend ?? this.trend,
      status: status ?? this.status,
    );
  }
}
