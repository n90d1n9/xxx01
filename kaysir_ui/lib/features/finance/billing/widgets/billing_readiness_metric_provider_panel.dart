import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_frame.dart';
import 'billing_readiness_metric_provider.dart';

class BillingReadinessMetricProviderPanel<T extends Object>
    extends StatelessWidget {
  final T source;
  final BillingReadinessMetricProvider<T> metricProvider;
  final String title;
  final String summary;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const BillingReadinessMetricProviderPanel({
    super.key,
    required this.source,
    required this.metricProvider,
    required this.title,
    required this.summary,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.child,
    this.trailing,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = metricProvider.resolve(source);

    return BillingReadinessPanelScaffold(
      title: title,
      summary: summary,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      metrics: metrics.items,
      trailing: trailing,
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}
