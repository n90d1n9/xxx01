import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/billing_route_contract.dart';
import '../utils/billing_route_contract_remediation.dart';
import '../utils/billing_route_contract_remediation_navigation.dart';
import 'billing_navigation_destination.dart';

/// Displays actionable remediation steps for billing route contract issues.
class BillingRouteContractRemediationList extends StatelessWidget {
  final List<BillingRouteContractRemediationAction> actions;
  final int maxVisibleActions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingRouteContractRemediationList({
    super.key,
    required this.actions,
    this.maxVisibleActions = 3,
    this.onDestinationSelected,
  }) : assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.take(maxVisibleActions).toList();
    final hiddenCount = actions.length - visibleActions.length;

    return Column(
      key: const ValueKey('billing-route-contract-remediation-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Suggested fixes',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final itemWidth =
                isWide ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final action in visibleActions)
                  SizedBox(
                    width: itemWidth,
                    child: BillingRouteContractRemediationTile(
                      action: action,
                      onDestinationSelected: onDestinationSelected,
                    ),
                  ),
              ],
            );
          },
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            '+$hiddenCount more ${_plural(hiddenCount, 'fix')} hidden',
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

/// Compact card for a single route contract remediation action.
class BillingRouteContractRemediationTile extends StatelessWidget {
  final BillingRouteContractRemediationAction action;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingRouteContractRemediationTile({
    super.key,
    required this.action,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(action);
    final navigationTarget = billingRouteContractRemediationNavigationTargetFor(
      action,
    );

    return Container(
      key: ValueKey('billing-route-contract-remediation-${action.id}'),
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_actionIcon(action.kind), color: colors.foreground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        action.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RouteContractSeverityBadge(action: action),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${action.routeName} | ${action.kindLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (action.facts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    action.facts.take(3).join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (onDestinationSelected != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: ValueKey(
                        'billing-route-contract-remediation-open-${action.id}',
                      ),
                      onPressed:
                          () => onDestinationSelected?.call(
                            navigationTarget.destinationId,
                          ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(navigationTarget.callToActionLabel),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.foreground,
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

/// Severity badge for a route contract remediation action.
class _RouteContractSeverityBadge extends StatelessWidget {
  final BillingRouteContractRemediationAction action;

  const _RouteContractSeverityBadge({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(action);

    return Tooltip(
      message: action.kindLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            action.severityLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// Color tokens used by route contract remediation severity badges.
class _RouteContractSeverityColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _RouteContractSeverityColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

_RouteContractSeverityColors _severityColors(
  BillingRouteContractRemediationAction action,
) {
  if (action.isBlocker) {
    return const _RouteContractSeverityColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    );
  }

  return const _RouteContractSeverityColors(
    foreground: Color(0xFFB45309),
    background: Color(0xFFFEF3C7),
    border: Color(0xFFFDE68A),
  );
}

IconData _actionIcon(BillingRouteContractRemediationActionKind kind) {
  return switch (kind) {
    BillingRouteContractRemediationActionKind.cleanupRegistry =>
      Icons.cleaning_services_outlined,
    BillingRouteContractRemediationActionKind.alignRouteIdentity =>
      Icons.badge_outlined,
    BillingRouteContractRemediationActionKind.alignRoutePath =>
      Icons.alt_route_outlined,
    BillingRouteContractRemediationActionKind.alignRouteMetadata =>
      Icons.tune_outlined,
    BillingRouteContractRemediationActionKind.restoreSidebarCoverage =>
      Icons.menu_open_rounded,
    BillingRouteContractRemediationActionKind.attachPageBuilder =>
      Icons.web_asset_outlined,
    BillingRouteContractRemediationActionKind.registerFeatureRoute =>
      Icons.add_road_outlined,
    BillingRouteContractRemediationActionKind.removeUnexpectedRoute =>
      Icons.route_outlined,
    BillingRouteContractRemediationActionKind.restoreRouteOrder =>
      Icons.swap_vert_rounded,
    BillingRouteContractRemediationActionKind.enrichSearchMetadata =>
      Icons.manage_search_outlined,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

@Preview(name: 'Billing route contract remediation list')
Widget billingRouteContractRemediationListPreview() {
  final registryReport = BillingRouteContractReport.forRouteRegistry();
  final report = BillingRouteContractReport(
    rootRoute: registryReport.rootRoute,
    routeDefinitions: registryReport.routeDefinitions,
    issues: [
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.duplicateRouteName,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: 'billingManagement',
        message: 'Billing route registry has duplicate route name.',
        details: const ['billingManagement'],
      ),
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteOrderMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: 'billingManagement',
        message: 'Billing sidebar route order differs from the registry.',
      ),
    ],
  );
  final plan = BillingRouteContractRemediationPlan.forReport(report);

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BillingRouteContractRemediationList(actions: plan.actions),
        ),
      ),
    ),
  );
}
