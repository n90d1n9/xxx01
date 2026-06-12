import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/billing_business_domain_pack_remediation_navigation.dart';
import 'billing_navigation_destination.dart';

class BillingBusinessDomainPackRemediationActionList extends StatelessWidget {
  final List<BillingBusinessDomainPackRemediationAction> actions;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingBusinessDomainPackRemediationActionList({
    super.key,
    required this.actions,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              actions
                  .map(
                    (action) => SizedBox(
                      width: itemWidth,
                      child: BillingBusinessDomainPackRemediationActionTile(
                        action: action,
                        onDestinationSelected: onDestinationSelected,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingBusinessDomainPackRemediationActionTile extends StatelessWidget {
  final BillingBusinessDomainPackRemediationAction action;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingBusinessDomainPackRemediationActionTile({
    super.key,
    required this.action,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(action);
    final navigationTarget =
        billingBusinessDomainPackRemediationNavigationTargetFor(action);

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _actionIcon(action),
              color: colors.foreground,
              size: 21,
            ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BillingBusinessDomainPackRemediationSeverityBadge(
                      action: action,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${action.domainLabel} · ${action.sourceLabel}',
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
                    action.facts.take(4).map(_sentenceCaseName).join(', '),
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
                        'billing-pack-remediation-open-${action.id}',
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

class BillingBusinessDomainPackRemediationSeverityBadge
    extends StatelessWidget {
  final BillingBusinessDomainPackRemediationAction action;

  const BillingBusinessDomainPackRemediationSeverityBadge({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(action);

    return Tooltip(
      message: '${action.kindLabel} · ${action.sourceLabel}',
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

class _SeverityColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _SeverityColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

_SeverityColors _severityColors(
  BillingBusinessDomainPackRemediationAction action,
) {
  if (action.isBlocker) {
    return const _SeverityColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    );
  }

  return const _SeverityColors(
    foreground: Color(0xFFB45309),
    background: Color(0xFFFEF3C7),
    border: Color(0xFFFDE68A),
  );
}

IconData _actionIcon(BillingBusinessDomainPackRemediationAction action) {
  return switch (action.kind) {
    BillingBusinessDomainPackRemediationActionKind.validateProfile =>
      Icons.badge_outlined,
    BillingBusinessDomainPackRemediationActionKind.registerScreenRegistry =>
      Icons.dashboard_customize_outlined,
    BillingBusinessDomainPackRemediationActionKind.registerMissingScreens =>
      Icons.view_quilt_outlined,
    BillingBusinessDomainPackRemediationActionKind.defineNavigationPolicy =>
      Icons.account_tree_outlined,
    BillingBusinessDomainPackRemediationActionKind.addLineItemAdapter =>
      Icons.receipt_long_outlined,
    BillingBusinessDomainPackRemediationActionKind.addIssuePolicy =>
      Icons.policy_outlined,
    BillingBusinessDomainPackRemediationActionKind.addPaymentSchedulePolicy =>
      Icons.event_repeat_outlined,
    BillingBusinessDomainPackRemediationActionKind.restoreNavigationCoverage =>
      Icons.route_outlined,
    BillingBusinessDomainPackRemediationActionKind.registerDiagnosticsProfile =>
      Icons.fact_check_outlined,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseWorkspaceProfile =>
      Icons.dashboard_customize_outlined,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseProfileSavedViewProfile =>
      Icons.bookmarks_outlined,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseGateLaneTarget =>
      Icons.flag_outlined,
  };
}

String _sentenceCaseName(String value) {
  final words =
      value
          .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
            return '${match.group(1)} ${match.group(2)}';
          })
          .replaceAll('_', ' ')
          .trim()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .toList();

  if (words.isEmpty) return value;

  final normalizedWords = words.map((word) => word.toLowerCase()).toList();
  final first = normalizedWords.first;
  normalizedWords[0] = first.substring(0, 1).toUpperCase() + first.substring(1);

  return normalizedWords.join(' ');
}
