import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/billing_route_extension_manifest.dart';
import '../utils/billing_route_extension_manifest_remediation.dart';

/// Displays actionable remediation steps for route extension manifest issues.
class BillingRouteExtensionManifestRemediationList extends StatelessWidget {
  final List<BillingRouteExtensionManifestRemediationAction> actions;
  final int maxVisibleActions;

  const BillingRouteExtensionManifestRemediationList({
    super.key,
    required this.actions,
    this.maxVisibleActions = 3,
  }) : assert(maxVisibleActions > 0);

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.take(maxVisibleActions).toList();
    final hiddenCount = actions.length - visibleActions.length;

    return Column(
      key: const ValueKey('billing-route-extension-manifest-remediation-list'),
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
                    child: BillingRouteExtensionManifestRemediationTile(
                      action: action,
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

/// Compact card for a single route extension manifest remediation action.
class BillingRouteExtensionManifestRemediationTile extends StatelessWidget {
  final BillingRouteExtensionManifestRemediationAction action;

  const BillingRouteExtensionManifestRemediationTile({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(action);

    return Container(
      key: ValueKey(
        'billing-route-extension-manifest-remediation-${action.id}',
      ),
      constraints: const BoxConstraints(minHeight: 124),
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
                    _ManifestSeverityBadge(action: action),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${action.manifestId} | ${action.kindLabel}',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Severity badge for a route extension manifest remediation action.
class _ManifestSeverityBadge extends StatelessWidget {
  final BillingRouteExtensionManifestRemediationAction action;

  const _ManifestSeverityBadge({required this.action});

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

/// Color tokens used by manifest remediation severity badges.
class _ManifestSeverityColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _ManifestSeverityColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

_ManifestSeverityColors _severityColors(
  BillingRouteExtensionManifestRemediationAction action,
) {
  if (action.isBlocker) {
    return const _ManifestSeverityColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    );
  }

  return const _ManifestSeverityColors(
    foreground: Color(0xFFB45309),
    background: Color(0xFFFEF3C7),
    border: Color(0xFFFDE68A),
  );
}

IconData _actionIcon(BillingRouteExtensionManifestRemediationActionKind kind) {
  return switch (kind) {
    BillingRouteExtensionManifestRemediationActionKind.attachPageBuilder =>
      Icons.web_asset_outlined,
    BillingRouteExtensionManifestRemediationActionKind.deduplicateManifestId =>
      Icons.badge_outlined,
    BillingRouteExtensionManifestRemediationActionKind.deduplicatePageBuilder =>
      Icons.integration_instructions_outlined,
    BillingRouteExtensionManifestRemediationActionKind.resolveOrphanBuilder =>
      Icons.rule_folder_outlined,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

@Preview(name: 'Billing route extension manifest remediation list')
Widget billingRouteExtensionManifestRemediationListPreview() {
  final report = BillingRouteExtensionManifestReport(
    manifests: const [],
    issues: [
      BillingRouteExtensionManifestIssue(
        kind: BillingRouteExtensionManifestIssueKind.missingPageBuilder,
        severity: BillingRouteExtensionManifestIssueSeverity.blocker,
        manifestId: 'billing.entitlements',
        message:
            'billingEntitlements is declared without a manifest page builder.',
        details: const ['routeIdentityKey=billingEntitlements'],
      ),
      BillingRouteExtensionManifestIssue(
        kind: BillingRouteExtensionManifestIssueKind.orphanPageBuilder,
        severity: BillingRouteExtensionManifestIssueSeverity.warning,
        manifestId: 'billing.subscription',
        message: 'billingSubscription has no route definition.',
        details: const ['routeIdentityKey=billingSubscription'],
      ),
    ],
  );
  final plan = BillingRouteExtensionManifestRemediationPlan.forReport(report);

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BillingRouteExtensionManifestRemediationList(
            actions: plan.actions,
          ),
        ),
      ),
    ),
  );
}
