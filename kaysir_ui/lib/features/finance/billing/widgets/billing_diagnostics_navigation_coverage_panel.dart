import 'package:flutter/material.dart';

import '../states/billing_diagnostics_overview_provider.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_navigation_coverage_badge.dart';

class BillingDiagnosticsNavigationCoveragePanel extends StatelessWidget {
  final BillingDiagnosticsOverview overview;

  const BillingDiagnosticsNavigationCoveragePanel({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final summary = overview.coverageSummary;

    return BillingReadinessFrame(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.route_outlined, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Navigation coverage',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.summaryLabel,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BillingNavigationCoverageBadge(summary: summary),
        ],
      ),
    );
  }
}
