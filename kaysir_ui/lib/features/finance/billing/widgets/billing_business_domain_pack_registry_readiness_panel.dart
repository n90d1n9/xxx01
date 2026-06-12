import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_readiness.dart';
import 'billing_business_domain_pack_readiness_tile.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_empty_state.dart';

class BillingBusinessDomainPackRegistryReadinessPanel extends StatelessWidget {
  final BillingBusinessDomainPackRegistryReadinessReport report;
  final int maxVisiblePacks;

  const BillingBusinessDomainPackRegistryReadinessPanel({
    super.key,
    required this.report,
    this.maxVisiblePacks = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _PackRegistryReadinessVisuals.fromReport(report);
    final packReports = report.packReports.take(maxVisiblePacks).toList();

    return BillingReadinessFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BillingReadinessStatusIcon(
                icon: visuals.icon,
                color: visuals.color,
                backgroundColor: visuals.backgroundColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business domain packs',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visuals.headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.summaryLabel,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BillingReadinessMetricStrip(metrics: _packRegistryMetrics(report)),
          if (packReports.isEmpty) ...[
            const SizedBox(height: 14),
            const _PackRegistryEmptyState(),
          ] else ...[
            const SizedBox(height: 14),
            Column(
              children:
                  packReports
                      .map(
                        (packReport) => BillingBusinessDomainPackReadinessTile(
                          report: packReport,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (report.packReports.length > packReports.length) ...[
            const SizedBox(height: 10),
            Text(
              '${report.packReports.length - packReports.length} more '
              'packs hidden',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PackRegistryEmptyState extends StatelessWidget {
  const _PackRegistryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const BillingEmptyState(
      message: 'No reusable billing business domain packs are registered yet.',
      padding: EdgeInsets.all(14),
    );
  }
}

class _PackRegistryReadinessVisuals {
  final String headline;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _PackRegistryReadinessVisuals({
    required this.headline,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory _PackRegistryReadinessVisuals.fromReport(
    BillingBusinessDomainPackRegistryReadinessReport report,
  ) {
    if (!report.isReady) {
      return const _PackRegistryReadinessVisuals(
        headline: 'Pack blockers',
        icon: Icons.warning_amber_outlined,
        color: Color(0xFFB91C1C),
        backgroundColor: Color(0xFFFEE2E2),
      );
    }

    if (report.hasWarnings) {
      return const _PackRegistryReadinessVisuals(
        headline: 'Ready with pack warnings',
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFB45309),
        backgroundColor: Color(0xFFFEF3C7),
      );
    }

    return const _PackRegistryReadinessVisuals(
      headline: 'All packs ready',
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
      backgroundColor: Color(0xFFD1FAE5),
    );
  }
}

List<BillingReadinessMetric> _packRegistryMetrics(
  BillingBusinessDomainPackRegistryReadinessReport report,
) {
  return [
    BillingReadinessMetric(
      label: 'Packs',
      value: '${report.packReports.length}',
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Blocked',
      value: '${report.blockedPackReports.length}',
      icon: Icons.error_outline,
      color: const Color(0xFFDC2626),
    ),
    BillingReadinessMetric(
      label: 'Warnings',
      value: '${report.warningIssueCount}',
      icon: Icons.info_outline_rounded,
      color: const Color(0xFFD97706),
    ),
    BillingReadinessMetric(
      label: 'Diagnostics',
      value: '${_diagnosticsProfileCount(report)}',
      icon: Icons.fact_check_outlined,
      color: const Color(0xFF7C3AED),
    ),
    BillingReadinessMetric(
      label: 'Release',
      value: '${_releaseWorkspaceProfileCount(report)}',
      icon: Icons.dashboard_customize_outlined,
      color: const Color(0xFF0F766E),
    ),
    BillingReadinessMetric(
      label: 'Profile views',
      value: '${_releaseProfileSavedViewProfileCount(report)}',
      icon: Icons.bookmarks_outlined,
      color: const Color(0xFF2563EB),
    ),
  ];
}

int _diagnosticsProfileCount(
  BillingBusinessDomainPackRegistryReadinessReport report,
) {
  return report.packReports
      .where((packReport) => packReport.pack.diagnosticsProfile != null)
      .length;
}

int _releaseWorkspaceProfileCount(
  BillingBusinessDomainPackRegistryReadinessReport report,
) {
  return report.packReports
      .where((packReport) => packReport.pack.releaseWorkspaceProfile != null)
      .length;
}

int _releaseProfileSavedViewProfileCount(
  BillingBusinessDomainPackRegistryReadinessReport report,
) {
  return report.packReports
      .where(
        (packReport) => packReport.pack.releaseProfileSavedViewProfile != null,
      )
      .length;
}
