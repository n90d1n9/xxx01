import 'package:flutter/material.dart';

import '../../../widgets/ui/app_icon_badge.dart';
import '../../../widgets/ui/app_trend_indicator.dart';
import '../../../widgets/ui/app_value_cluster.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentageChange;
  final Color color;
  final IconData? icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.percentageChange,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconBadge(
                  icon: icon ?? Icons.insights_outlined,
                  size: 40,
                  iconSize: 22,
                  backgroundColor: color.withValues(alpha: 0.18),
                  foregroundColor: color,
                ),
                const Spacer(),
                AppTrendIndicator(
                  value: percentageChange,
                  compactValue: false,
                  maxWidth: 150,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppValueCluster(
              label: title,
              value: value,
              labelGap: 4,
              valueStyle: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
