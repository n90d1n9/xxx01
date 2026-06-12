import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/billing_route_extension_manifest.dart';
import '../utils/billing_route_extension_manifest_remediation.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_route_extension_manifest_remediation_list.dart';

/// Displays readiness diagnostics for executable billing route manifests.
class BillingRouteExtensionManifestPanel extends StatelessWidget {
  final BillingRouteExtensionManifestReport report;
  final BillingRouteExtensionManifestRemediationPlan? remediationPlan;
  final int maxVisibleIssues;
  final int maxVisibleActions;

  const BillingRouteExtensionManifestPanel({
    super.key,
    required this.report,
    this.remediationPlan,
    this.maxVisibleIssues = 4,
    this.maxVisibleActions = 3,
  }) : assert(maxVisibleIssues > 0),
       assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    final resolvedRemediationPlan =
        remediationPlan ??
        BillingRouteExtensionManifestRemediationPlan.forReport(report);

    return BillingReadinessPanelScaffold(
      key: const ValueKey('billing-route-extension-manifest-panel'),
      title: 'Route extension manifests',
      summary: report.summaryLabel,
      icon: _statusIcon(report),
      iconColor: _statusColor(report),
      iconBackgroundColor: _statusBackgroundColor(report),
      metrics: [
        BillingReadinessMetric(
          label: 'Manifests',
          value: report.manifestCount.toString(),
          icon: Icons.extension_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Routes',
          value: report.routeCount.toString(),
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF0F766E),
        ),
        BillingReadinessMetric(
          label: 'Builders',
          value: report.pageBuilderCount.toString(),
          icon: Icons.integration_instructions_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Blockers',
          value: report.blockerIssues.length.toString(),
          icon: Icons.report_gmailerrorred_outlined,
          color: const Color(0xFFDC2626),
        ),
        BillingReadinessMetric(
          label: 'Warnings',
          value: report.warningIssues.length.toString(),
          icon: Icons.info_outline_rounded,
          color: const Color(0xFFD97706),
        ),
      ],
      child: _ManifestReadinessBody(
        report: report,
        remediationPlan: resolvedRemediationPlan,
        maxVisibleIssues: maxVisibleIssues,
        maxVisibleActions: maxVisibleActions,
      ),
    );
  }
}

/// Renders either manifest success copy or the current manifest issues.
class _ManifestReadinessBody extends StatelessWidget {
  final BillingRouteExtensionManifestReport report;
  final BillingRouteExtensionManifestRemediationPlan remediationPlan;
  final int maxVisibleIssues;
  final int maxVisibleActions;

  const _ManifestReadinessBody({
    required this.report,
    required this.remediationPlan,
    required this.maxVisibleIssues,
    required this.maxVisibleActions,
  });

  @override
  Widget build(BuildContext context) {
    if (!report.hasIssues) {
      return const _ManifestSuccessState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ManifestIssueList(
          issues: report.issues,
          maxVisibleIssues: maxVisibleIssues,
        ),
        if (!remediationPlan.isEmpty) ...[
          const SizedBox(height: 16),
          BillingRouteExtensionManifestRemediationList(
            actions: remediationPlan.actions,
            maxVisibleActions: maxVisibleActions,
          ),
        ],
      ],
    );
  }
}

/// Compact success state for complete billing route extension manifests.
class _ManifestSuccessState extends StatelessWidget {
  const _ManifestSuccessState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('billing-route-extension-manifest-ready'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'All billing route extension manifests have matching route definitions and page builders.',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lists manifest blockers and warnings with overflow protection.
class _ManifestIssueList extends StatelessWidget {
  final List<BillingRouteExtensionManifestIssue> issues;
  final int maxVisibleIssues;

  const _ManifestIssueList({
    required this.issues,
    required this.maxVisibleIssues,
  });

  @override
  Widget build(BuildContext context) {
    final visibleIssues = issues.take(maxVisibleIssues).toList(growable: false);
    final hiddenCount = issues.length - visibleIssues.length;

    return Column(
      key: const ValueKey('billing-route-extension-manifest-issues'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final indexedIssue in visibleIssues.indexed) ...[
          _ManifestIssueTile(issue: indexedIssue.$2, index: indexedIssue.$1),
          if (indexedIssue.$2 != visibleIssues.last) const SizedBox(height: 10),
        ],
        if (hiddenCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            '+$hiddenCount more ${_plural(hiddenCount, 'issue')} hidden',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

/// Visual row for a single billing route extension manifest issue.
class _ManifestIssueTile extends StatelessWidget {
  final BillingRouteExtensionManifestIssue issue;
  final int index;

  const _ManifestIssueTile({required this.issue, required this.index});

  @override
  Widget build(BuildContext context) {
    final accentColor = _severityColor(issue.severity);

    return Container(
      key: ValueKey(
        'billing-route-extension-manifest-issue-${issue.kind.name}-${issue.manifestId}-$index',
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_severityIcon(issue.severity), color: accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ManifestIssuePill(
                      label: _severityLabel(issue.severity),
                      color: accentColor,
                    ),
                    Text(
                      _issueKindLabel(issue.kind),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      issue.manifestId,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  issue.message,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (issue.details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    issue.details.join(' | '),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small severity marker used inside manifest issue rows.
class _ManifestIssuePill extends StatelessWidget {
  final String label;
  final Color color;

  const _ManifestIssuePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

IconData _statusIcon(BillingRouteExtensionManifestReport report) {
  if (report.blockerIssues.isNotEmpty) return Icons.error_outline_rounded;
  if (report.warningIssues.isNotEmpty) return Icons.info_outline_rounded;

  return Icons.verified_outlined;
}

Color _statusColor(BillingRouteExtensionManifestReport report) {
  if (report.blockerIssues.isNotEmpty) return const Color(0xFFDC2626);
  if (report.warningIssues.isNotEmpty) return const Color(0xFFD97706);

  return const Color(0xFF059669);
}

Color _statusBackgroundColor(BillingRouteExtensionManifestReport report) {
  if (report.blockerIssues.isNotEmpty) return const Color(0xFFFEE2E2);
  if (report.warningIssues.isNotEmpty) return const Color(0xFFFEF3C7);

  return const Color(0xFFD1FAE5);
}

IconData _severityIcon(BillingRouteExtensionManifestIssueSeverity severity) {
  switch (severity) {
    case BillingRouteExtensionManifestIssueSeverity.blocker:
      return Icons.report_gmailerrorred_outlined;
    case BillingRouteExtensionManifestIssueSeverity.warning:
      return Icons.info_outline_rounded;
  }
}

Color _severityColor(BillingRouteExtensionManifestIssueSeverity severity) {
  switch (severity) {
    case BillingRouteExtensionManifestIssueSeverity.blocker:
      return const Color(0xFFDC2626);
    case BillingRouteExtensionManifestIssueSeverity.warning:
      return const Color(0xFFD97706);
  }
}

String _severityLabel(BillingRouteExtensionManifestIssueSeverity severity) {
  switch (severity) {
    case BillingRouteExtensionManifestIssueSeverity.blocker:
      return 'Blocker';
    case BillingRouteExtensionManifestIssueSeverity.warning:
      return 'Warning';
  }
}

String _issueKindLabel(BillingRouteExtensionManifestIssueKind kind) {
  final words =
      kind.name
          .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
          .toLowerCase();

  return words[0].toUpperCase() + words.substring(1);
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

@Preview(name: 'Billing route extension manifest panel')
Widget billingRouteExtensionManifestPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BillingRouteExtensionManifestPanel(
            report: BillingRouteExtensionManifestReport(
              manifests: const [],
              issues: [
                BillingRouteExtensionManifestIssue(
                  kind:
                      BillingRouteExtensionManifestIssueKind.missingPageBuilder,
                  severity: BillingRouteExtensionManifestIssueSeverity.blocker,
                  manifestId: 'billing.entitlements',
                  message:
                      'billingEntitlements is declared without a manifest page builder.',
                  details: const ['routeIdentityKey=billingEntitlements'],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
