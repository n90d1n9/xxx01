import 'package:flutter/material.dart';

import 'app_icon_badge.dart';
import 'app_surface.dart';
import 'app_trend_indicator.dart';
import 'app_value_cluster.dart';

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.change,
    this.helper,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? change;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconBadge(
                icon: icon,
                backgroundColor: accentColor.withValues(alpha: 0.14),
                foregroundColor: accentColor,
              ),
              if (change != null) ...[
                const Spacer(),
                AppTrendIndicator(value: change!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AppValueCluster(
            label: title,
            value: value,
            detail: helper,
            valueStyle: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
