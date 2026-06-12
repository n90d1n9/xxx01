import 'package:flutter/material.dart';

import '../utils/billing_business_domain_module_readiness.dart';
import 'billing_domain_module_readiness_badge.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';

class BillingDomainModuleRegistryReadinessPanel extends StatelessWidget {
  final BillingDomainModuleRegistryReadinessReport report;
  final int maxVisibleModules;

  const BillingDomainModuleRegistryReadinessPanel({
    super.key,
    required this.report,
    this.maxVisibleModules = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _RegistryReadinessVisuals.fromReport(report);
    final moduleReports = report.moduleReports.take(maxVisibleModules).toList();

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
                      'Billing modules',
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
          BillingReadinessMetricStrip(metrics: _registryMetrics(report)),
          if (moduleReports.isNotEmpty) ...[
            const SizedBox(height: 14),
            Column(
              children:
                  moduleReports
                      .map(
                        (moduleReport) =>
                            _ModuleReadinessRow(report: moduleReport),
                      )
                      .toList(),
            ),
          ],
          if (report.moduleReports.length > moduleReports.length) ...[
            const SizedBox(height: 10),
            Text(
              '${report.moduleReports.length - moduleReports.length} more '
              'modules hidden',
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

class _ModuleReadinessRow extends StatelessWidget {
  final BillingDomainModuleReadinessReport report;

  const _ModuleReadinessRow({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.domainLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  report.summaryLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BillingDomainModuleReadinessBadge(report: report),
        ],
      ),
    );
  }
}

class _RegistryReadinessVisuals {
  final String headline;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _RegistryReadinessVisuals({
    required this.headline,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  factory _RegistryReadinessVisuals.fromReport(
    BillingDomainModuleRegistryReadinessReport report,
  ) {
    if (!report.isReady) {
      return const _RegistryReadinessVisuals(
        headline: 'Module blockers',
        icon: Icons.warning_amber_outlined,
        color: Color(0xFFB91C1C),
        backgroundColor: Color(0xFFFEE2E2),
      );
    }

    if (report.hasWarnings) {
      return const _RegistryReadinessVisuals(
        headline: 'Ready with warnings',
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFB45309),
        backgroundColor: Color(0xFFFEF3C7),
      );
    }

    return const _RegistryReadinessVisuals(
      headline: 'All modules ready',
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
      backgroundColor: Color(0xFFD1FAE5),
    );
  }
}

List<BillingReadinessMetric> _registryMetrics(
  BillingDomainModuleRegistryReadinessReport report,
) {
  return [
    BillingReadinessMetric(
      label: 'Modules',
      value: '${report.moduleReports.length}',
      icon: Icons.account_tree_outlined,
      color: const Color(0xFF2563EB),
    ),
    BillingReadinessMetric(
      label: 'Blocked',
      value: '${report.blockedModuleReports.length}',
      icon: Icons.error_outline,
      color: const Color(0xFFDC2626),
    ),
    BillingReadinessMetric(
      label: 'Warnings',
      value: '${report.warningIssueCount}',
      icon: Icons.info_outline_rounded,
      color: const Color(0xFFD97706),
    ),
  ];
}
