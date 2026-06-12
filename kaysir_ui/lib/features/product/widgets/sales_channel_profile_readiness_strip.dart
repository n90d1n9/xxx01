import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';

/// Summary strip for active sales-channel profile readiness.
class ProductSalesChannelProfileReadinessStrip extends StatelessWidget {
  const ProductSalesChannelProfileReadinessStrip({
    super.key,
    required this.summary,
  });

  final ProductSalesChannelProfileReadinessSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(summary.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppStatusPill(
                  label: summary.statusLabel,
                  color: color,
                  icon: _levelIcon(summary.level),
                  maxWidth: 112,
                ),
                AppStatusPill(
                  label: summary.channelLabel,
                  color: color,
                  icon: Icons.hub_rounded,
                  maxWidth: 170,
                ),
                AppStatusPill(
                  label: summary.coverageLabel,
                  color: Colors.blue.shade700,
                  icon: Icons.inventory_2_rounded,
                  maxWidth: 190,
                ),
                AppStatusPill(
                  label: summary.blockerLabel,
                  color:
                      summary.blockedProductSlotCount == 0
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                  icon: Icons.rule_rounded,
                  maxWidth: 210,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              summary.nextActionLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Sales channel profile readiness')
Widget productSalesChannelProfileReadinessStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelProfileReadinessStrip(
          summary: summarizeProductSalesChannelProfileReadiness(
            buildProductSalesChannelReadiness(const []),
          ),
        ),
      ),
    ),
  );
}

IconData _levelIcon(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Icons.priority_high_rounded;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Icons.trending_up_rounded;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Icons.check_rounded;
  }
}

Color _levelColor(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Colors.red.shade700;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Colors.orange.shade700;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Colors.green.shade700;
  }
}
