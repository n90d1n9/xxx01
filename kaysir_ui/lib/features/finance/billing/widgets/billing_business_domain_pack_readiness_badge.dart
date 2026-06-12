import 'package:flutter/material.dart';

import '../utils/billing_business_domain_pack_readiness.dart';

class BillingBusinessDomainPackReadinessBadge extends StatelessWidget {
  final BillingBusinessDomainPackReadinessReport report;

  const BillingBusinessDomainPackReadinessBadge({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = BillingBusinessDomainPackReadinessVisuals.fromReport(
      report,
    );

    return Tooltip(
      message: report.summaryLabel,
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

class BillingBusinessDomainPackReadinessVisuals {
  final String headline;
  final String badgeLabel;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const BillingBusinessDomainPackReadinessVisuals({
    required this.headline,
    required this.badgeLabel,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory BillingBusinessDomainPackReadinessVisuals.fromReport(
    BillingBusinessDomainPackReadinessReport report,
  ) {
    if (!report.isReady) {
      return const BillingBusinessDomainPackReadinessVisuals(
        headline: 'Needs attention',
        badgeLabel: 'Blocked',
        icon: Icons.warning_amber_outlined,
        color: Color(0xFFB91C1C),
        backgroundColor: Color(0xFFFEE2E2),
        borderColor: Color(0xFFFECACA),
      );
    }

    if (report.hasWarnings) {
      return const BillingBusinessDomainPackReadinessVisuals(
        headline: 'Ready with warnings',
        badgeLabel: 'Warnings',
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFB45309),
        backgroundColor: Color(0xFFFEF3C7),
        borderColor: Color(0xFFFDE68A),
      );
    }

    return const BillingBusinessDomainPackReadinessVisuals(
      headline: 'Release-ready',
      badgeLabel: 'Ready',
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
      backgroundColor: Color(0xFFD1FAE5),
      borderColor: Color(0xFFA7F3D0),
    );
  }
}
