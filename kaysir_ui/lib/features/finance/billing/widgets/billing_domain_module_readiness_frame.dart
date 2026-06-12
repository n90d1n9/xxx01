import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_metric_strip.dart';

class BillingReadinessFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const BillingReadinessFrame({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class BillingReadinessPanelScaffold extends StatelessWidget {
  final String title;
  final String summary;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final List<BillingReadinessMetric> metrics;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const BillingReadinessPanelScaffold({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.metrics,
    required this.child,
    this.trailing,
    this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BillingReadinessFrame(
      margin: margin,
      padding: padding,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BillingReadinessPanelHeader(
            title: title,
            summary: summary,
            icon: icon,
            iconColor: iconColor,
            iconBackgroundColor: iconBackgroundColor,
            trailing: trailing,
          ),
          const SizedBox(height: 16),
          BillingReadinessMetricStrip(metrics: metrics),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class BillingReadinessStatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const BillingReadinessStatusIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 38,
    this.iconSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class BillingReadinessPanelHeader extends StatelessWidget {
  final String title;
  final String summary;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Widget? trailing;

  const BillingReadinessPanelHeader({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BillingReadinessStatusIcon(
          icon: icon,
          color: iconColor,
          backgroundColor: iconBackgroundColor,
          size: 42,
          iconSize: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}
