import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/billing_route_contract.dart';
import '../utils/billing_route_contract_remediation.dart';
import '../utils/billing_route_definition_registry.dart';
import '../utils/billing_route_execution_contract.dart';
import 'billing_domain_module_readiness_frame.dart';
import 'billing_domain_module_readiness_metric_strip.dart';
import 'billing_navigation_destination.dart';
import 'billing_route_contract_remediation_list.dart';

/// Displays billing route and sidebar contract health in diagnostics.
class BillingRouteContractPanel extends StatelessWidget {
  final BillingRouteContractReport report;
  final BillingRouteContractRemediationPlan? remediationPlan;
  final BillingRouteExecutionReport? executionReport;
  final int maxVisibleIssues;
  final int maxVisibleActions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingRouteContractPanel({
    super.key,
    required this.report,
    this.remediationPlan,
    this.executionReport,
    this.maxVisibleIssues = 4,
    this.maxVisibleActions = 3,
    this.onDestinationSelected,
  }) : assert(maxVisibleIssues > 0),
       assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    final resolvedRemediationPlan =
        remediationPlan ??
        BillingRouteContractRemediationPlan.forReport(report);
    final resolvedExecutionReport =
        executionReport ??
        BillingRouteExecutionReport.forRegistry(
          routeDefinitionRegistry: BillingRouteDefinitionRegistry(
            baseDefinitions: report.routeDefinitions,
          ),
        );

    return BillingReadinessPanelScaffold(
      key: const ValueKey('billing-route-contract-panel'),
      title: 'Route contract',
      summary: report.summaryLabel,
      icon: _statusIcon(report),
      iconColor: _statusColor(report),
      iconBackgroundColor: _statusBackgroundColor(report),
      metrics: [
        BillingReadinessMetric(
          label: 'Routes',
          value: report.routeDefinitions.length.toString(),
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF2563EB),
        ),
        BillingReadinessMetric(
          label: 'Sidebar',
          value: report.actualSidebarPaths.length.toString(),
          icon: Icons.menu_open_rounded,
          color: const Color(0xFF0F766E),
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
        BillingReadinessMetric(
          label: 'Builders',
          value: resolvedExecutionReport.explicitBuilderCount.toString(),
          icon: Icons.integration_instructions_outlined,
          color: const Color(0xFF7C3AED),
        ),
        BillingReadinessMetric(
          label: 'Fallbacks',
          value: resolvedExecutionReport.fallbackBuilderCount.toString(),
          icon: Icons.route_outlined,
          color: const Color(0xFFEA580C),
        ),
      ],
      child: _RouteContractReadinessBody(
        report: report,
        remediationPlan: resolvedRemediationPlan,
        executionReport: resolvedExecutionReport,
        maxVisibleIssues: maxVisibleIssues,
        maxVisibleActions: maxVisibleActions,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}

/// Renders route metadata and execution readiness in one diagnostics panel.
class _RouteContractReadinessBody extends StatelessWidget {
  final BillingRouteContractReport report;
  final BillingRouteContractRemediationPlan remediationPlan;
  final BillingRouteExecutionReport executionReport;
  final int maxVisibleIssues;
  final int maxVisibleActions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _RouteContractReadinessBody({
    required this.report,
    required this.remediationPlan,
    required this.executionReport,
    required this.maxVisibleIssues,
    required this.maxVisibleActions,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (report.isComplete && executionReport.isReady) {
      return const _RouteContractSuccessState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (executionReport.hasIssues) ...[
          _RouteExecutionIssueList(report: executionReport),
          if (!report.isComplete) const SizedBox(height: 16),
        ],
        if (!report.isComplete)
          _RouteContractIssueAndActionList(
            report: report,
            remediationPlan: remediationPlan,
            maxVisibleIssues: maxVisibleIssues,
            maxVisibleActions: maxVisibleActions,
            onDestinationSelected: onDestinationSelected,
          ),
      ],
    );
  }
}

/// Combines route contract drift details with the suggested fixes.
class _RouteContractIssueAndActionList extends StatelessWidget {
  final BillingRouteContractReport report;
  final BillingRouteContractRemediationPlan remediationPlan;
  final int maxVisibleIssues;
  final int maxVisibleActions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const _RouteContractIssueAndActionList({
    required this.report,
    required this.remediationPlan,
    required this.maxVisibleIssues,
    required this.maxVisibleActions,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RouteContractIssueList(
          issues: report.issues,
          maxVisibleIssues: maxVisibleIssues,
        ),
        if (!remediationPlan.isEmpty) ...[
          const SizedBox(height: 16),
          BillingRouteContractRemediationList(
            actions: remediationPlan.actions,
            maxVisibleActions: maxVisibleActions,
            onDestinationSelected: onDestinationSelected,
          ),
        ],
      ],
    );
  }
}

/// Lists route definitions that still use the unavailable fallback page.
class _RouteExecutionIssueList extends StatelessWidget {
  final BillingRouteExecutionReport report;

  const _RouteExecutionIssueList({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('billing-route-execution-readiness'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_outlined, color: Color(0xFFEA580C), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Route execution readiness',
                  style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.summaryLabel,
            style: const TextStyle(
              color: Color(0xFF9A3412),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final issue in report.issues) ...[
            _RouteExecutionIssueTile(issue: issue),
            if (issue != report.issues.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Compact issue row for a route missing an explicit page builder.
class _RouteExecutionIssueTile extends StatelessWidget {
  final BillingRouteExecutionIssue issue;

  const _RouteExecutionIssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('billing-route-execution-issue-${issue.routeName}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue.message,
            style: const TextStyle(
              color: Color(0xFF7C2D12),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            issue.details.join(' | '),
            style: const TextStyle(
              color: Color(0xFF9A3412),
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact success state for a complete billing route contract.
class _RouteContractSuccessState extends StatelessWidget {
  const _RouteContractSuccessState();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'All billing routes are reachable from the sidebar with metadata aligned to the route registry.',
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

/// Renders route contract issues with severity, kind, and drift details.
class _RouteContractIssueList extends StatelessWidget {
  final List<BillingRouteContractIssue> issues;
  final int maxVisibleIssues;

  const _RouteContractIssueList({
    required this.issues,
    required this.maxVisibleIssues,
  });

  @override
  Widget build(BuildContext context) {
    final visibleIssues = issues.take(maxVisibleIssues).toList(growable: false);
    final hiddenCount = issues.length - visibleIssues.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final issue in visibleIssues) ...[
          _RouteContractIssueTile(issue: issue),
          if (issue != visibleIssues.last) const SizedBox(height: 10),
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

/// Visual row for a single billing route contract issue.
class _RouteContractIssueTile extends StatelessWidget {
  final BillingRouteContractIssue issue;

  const _RouteContractIssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    final accentColor = _severityColor(issue.severity);

    return Container(
      key: ValueKey(
        'billing-route-contract-issue-${issue.kind.name}-${issue.routeName}',
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
                    _RouteContractIssuePill(
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
                      issue.routeName,
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

/// Small severity marker used inside route contract issue rows.
class _RouteContractIssuePill extends StatelessWidget {
  final String label;
  final Color color;

  const _RouteContractIssuePill({required this.label, required this.color});

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

IconData _statusIcon(BillingRouteContractReport report) {
  if (report.blockerIssues.isNotEmpty) return Icons.error_outline_rounded;
  if (report.warningIssues.isNotEmpty) return Icons.info_outline_rounded;

  return Icons.verified_outlined;
}

Color _statusColor(BillingRouteContractReport report) {
  if (report.blockerIssues.isNotEmpty) return const Color(0xFFDC2626);
  if (report.warningIssues.isNotEmpty) return const Color(0xFFD97706);

  return const Color(0xFF059669);
}

Color _statusBackgroundColor(BillingRouteContractReport report) {
  if (report.blockerIssues.isNotEmpty) return const Color(0xFFFEE2E2);
  if (report.warningIssues.isNotEmpty) return const Color(0xFFFEF3C7);

  return const Color(0xFFD1FAE5);
}

IconData _severityIcon(BillingRouteContractIssueSeverity severity) {
  switch (severity) {
    case BillingRouteContractIssueSeverity.blocker:
      return Icons.report_gmailerrorred_outlined;
    case BillingRouteContractIssueSeverity.warning:
      return Icons.info_outline_rounded;
  }
}

Color _severityColor(BillingRouteContractIssueSeverity severity) {
  switch (severity) {
    case BillingRouteContractIssueSeverity.blocker:
      return const Color(0xFFDC2626);
    case BillingRouteContractIssueSeverity.warning:
      return const Color(0xFFD97706);
  }
}

String _severityLabel(BillingRouteContractIssueSeverity severity) {
  switch (severity) {
    case BillingRouteContractIssueSeverity.blocker:
      return 'Blocker';
    case BillingRouteContractIssueSeverity.warning:
      return 'Warning';
  }
}

String _issueKindLabel(BillingRouteContractIssueKind kind) {
  final words =
      kind.name
          .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ')
          .toLowerCase();

  return words[0].toUpperCase() + words.substring(1);
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

@Preview(name: 'Billing route contract panel')
Widget billingRouteContractPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BillingRouteContractPanel(
            report: BillingRouteContractReport.forRouteRegistry(),
          ),
        ),
      ),
    ),
  );
}
