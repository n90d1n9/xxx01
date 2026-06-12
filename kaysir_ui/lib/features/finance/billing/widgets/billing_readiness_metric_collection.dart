import 'billing_domain_module_readiness_metric_strip.dart';

class BillingReadinessMetricCollection {
  final List<BillingReadinessMetric> items;

  BillingReadinessMetricCollection({
    Iterable<BillingReadinessMetric> items = const [],
  }) : items = List.unmodifiable(items);

  bool get isEmpty => items.isEmpty;

  int get count => items.length;

  BillingReadinessMetric? metricForLabel(String label) {
    for (final item in items) {
      if (item.label == label) return item;
    }

    return null;
  }
}
