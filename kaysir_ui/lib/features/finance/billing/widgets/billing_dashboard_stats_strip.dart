import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import '../utils/billing_dashboard_metrics.dart';
import 'billing_dashboard_stat_card.dart';

class BillingDashboardStatsStrip extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;

  const BillingDashboardStatsStrip({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(billingDashboardStatsProvider(tenantId));

    return statsAsync.when(
      loading:
          () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => const SizedBox(
            height: 120,
            child: Center(child: Text('Error loading stats')),
          ),
      data: (stats) {
        final metrics = billingDashboardMetrics(
          stats,
          preferences: preferences,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final canFitGrid = constraints.maxWidth >= 720;

            if (canFitGrid) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      metrics
                          .map(
                            (metric) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: BillingDashboardStatCard(
                                  metric: metric,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              );
            }

            return SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: metrics.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return BillingDashboardStatCard(metric: metrics[index]);
                },
              ),
            );
          },
        );
      },
    );
  }
}
