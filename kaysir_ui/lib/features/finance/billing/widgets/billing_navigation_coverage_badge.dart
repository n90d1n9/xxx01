import 'package:flutter/material.dart';

import 'billing_navigation_coverage_issue.dart';
import 'billing_navigation_coverage_summary.dart';

class BillingNavigationCoverageBadge extends StatelessWidget {
  final BillingNavigationCoverageSummary summary;

  const BillingNavigationCoverageBadge({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final visuals = _NavigationCoverageVisuals.fromSummary(summary);

    return Tooltip(
      message: visuals.tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: visuals.backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: visuals.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visuals.icon, color: visuals.color, size: 14),
            const SizedBox(width: 4),
            Text(
              visuals.badgeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: visuals.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCoverageVisuals {
  final String badgeLabel;
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _NavigationCoverageVisuals({
    required this.badgeLabel,
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _NavigationCoverageVisuals.fromSummary(
    BillingNavigationCoverageSummary summary,
  ) {
    final tooltip = summary.summaryLabel;
    if (summary.isComplete) {
      return _NavigationCoverageVisuals(
        badgeLabel: 'Ready',
        tooltip: tooltip,
        icon: Icons.verified_outlined,
        color: const Color(0xFF047857),
        backgroundColor: const Color(0xFFD1FAE5),
        borderColor: const Color(0xFFA7F3D0),
      );
    }

    switch (summary.primaryKind) {
      case BillingNavigationCoverageIssueKind.unavailable:
        return _NavigationCoverageVisuals(
          badgeLabel: 'Blocked',
          tooltip: tooltip,
          icon: Icons.lock_outline,
          color: const Color(0xFFB91C1C),
          backgroundColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFECACA),
        );
      case BillingNavigationCoverageIssueKind.missingPlan:
        return _NavigationCoverageVisuals(
          badgeLabel: 'Incomplete',
          tooltip: tooltip,
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFFB45309),
          backgroundColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFDE68A),
        );
      case BillingNavigationCoverageIssueKind.unreachable:
      case null:
        return _NavigationCoverageVisuals(
          badgeLabel: 'Review',
          tooltip: tooltip,
          icon: Icons.route_outlined,
          color: const Color(0xFF1D4ED8),
          backgroundColor: const Color(0xFFDBEAFE),
          borderColor: const Color(0xFFBFDBFE),
        );
    }
  }
}
