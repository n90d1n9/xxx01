import 'package:flutter/material.dart';

import '../utils/billing_business_domain_module_readiness.dart';
import 'billing_domain_module_readiness_badge.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_issue_list.dart';
import 'billing_domain_module_readiness_metric_strip.dart';

class BillingDomainModuleReadinessPanel extends StatelessWidget {
  final BillingDomainModuleReadinessReport report;
  final int maxVisibleIssues;

  const BillingDomainModuleReadinessPanel({
    super.key,
    required this.report,
    this.maxVisibleIssues = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = BillingDomainModuleReadinessVisuals.fromReport(report);
    final issues = _visibleIssues(report, maxVisibleIssues);

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
                      'Domain readiness',
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
              const SizedBox(width: 10),
              BillingDomainModuleReadinessBadge(report: report),
            ],
          ),
          const SizedBox(height: 14),
          BillingReadinessMetricStrip(metrics: _moduleMetrics(report)),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 14),
            BillingDomainModuleReadinessIssueList(
              issues: issues,
              hiddenIssueCount: report.issues.length - issues.length,
            ),
          ],
        ],
      ),
    );
  }
}

List<BillingReadinessMetric> _moduleMetrics(
  BillingDomainModuleReadinessReport report,
) {
  return [
    BillingReadinessMetric(
      label: 'Blockers',
      value: '${report.blockerIssueCount}',
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
      label: 'Reachable',
      value:
          '${report.navigationCoverage.reachableDestinationIds.length}/'
          '${report.navigationCoverage.destinationIds.length}',
      icon: Icons.route_outlined,
      color: const Color(0xFF2563EB),
    ),
  ];
}

List<BillingDomainModuleReadinessIssue> _visibleIssues(
  BillingDomainModuleReadinessReport report,
  int maxVisibleIssues,
) {
  final orderedIssues = [...report.blockerIssues, ...report.warningIssues];
  return List.unmodifiable(orderedIssues.take(maxVisibleIssues));
}
