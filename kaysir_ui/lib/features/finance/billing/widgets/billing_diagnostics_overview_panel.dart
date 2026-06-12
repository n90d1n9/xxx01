import 'package:flutter/material.dart';

import '../states/billing_diagnostics_overview_provider.dart';
import 'billing_diagnostics_pack_summary_card.dart';
import 'billing_diagnostics_release_summary_card.dart';
import 'billing_diagnostics_remediation_summary_card.dart';
import 'billing_diagnostics_scope_pill.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_navigation_coverage_badge.dart';
import 'domain_pack_contract_summary_card.dart';

class BillingDiagnosticsOverviewPanel extends StatelessWidget {
  final BillingDiagnosticsOverview overview;

  const BillingDiagnosticsOverviewPanel({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    return BillingReadinessFrame(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Billing Diagnostics',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BillingDiagnosticsScopePill(label: overview.scopeLabel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overview.readinessSummaryLabel,
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
              BillingNavigationCoverageBadge(summary: overview.coverageSummary),
            ],
          ),
          const SizedBox(height: 16),
          BillingReadinessMetricStrip(metrics: _overviewMetrics(overview)),
          const SizedBox(height: 12),
          _OverviewSummaryGrid(overview: overview),
        ],
      ),
    );
  }
}

class _OverviewSummaryGrid extends StatelessWidget {
  final BillingDiagnosticsOverview overview;

  const _OverviewSummaryGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    final cards = [
      BillingDiagnosticsPackSummaryCard(
        summaryLabel: overview.packReadinessSummaryLabel,
        packCount: overview.packCount,
        blockerCount: overview.packBlockerCount,
        warningCount: overview.packWarningCount,
      ),
      DomainPackContractSummaryCard(
        summaryLabel: overview.packContractSummaryLabel,
        contractCount: overview.packContract.packReports.length,
        openRequirementCount: overview.packContractOpenRequirementCount,
        blockedRequirementCount: overview.packContractBlockedRequirementCount,
        warningRequirementCount: overview.packContractWarningRequirementCount,
      ),
      BillingDiagnosticsRemediationSummaryCard(
        summaryLabel: overview.remediationSummaryLabel,
        actionCount: overview.remediationActionCount,
        blockerActionCount: overview.remediationBlockerActionCount,
        warningActionCount: overview.remediationWarningActionCount,
      ),
      BillingDiagnosticsReleaseSummaryCard(
        summaryLabel: overview.releaseSummaryLabel,
        hasBlockers: overview.hasLaunchBlockers,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final itemWidth =
            isWide ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards) SizedBox(width: itemWidth, child: card),
          ],
        );
      },
    );
  }
}

List<BillingReadinessMetric> _overviewMetrics(
  BillingDiagnosticsOverview overview,
) {
  return [
    BillingReadinessMetric(
      label: 'Modules',
      value: '${overview.moduleCount}',
      icon: Icons.account_tree_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Blockers',
      value: '${overview.blockerCount}',
      icon: Icons.error_outline,
      color: const Color(0xFFDC2626),
    ),
    BillingReadinessMetric(
      label: 'Warnings',
      value: '${overview.warningCount}',
      icon: Icons.info_outline_rounded,
      color: const Color(0xFFD97706),
    ),
    BillingReadinessMetric(
      label: 'Ready launches',
      value: '${overview.readyLaunchTaskCount}/${overview.launchTaskCount}',
      icon: Icons.rocket_launch_outlined,
      color: const Color(0xFF047857),
    ),
  ];
}
