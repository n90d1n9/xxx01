import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint.dart';

class BillingBlueprintStatusStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final Color border;

  const BillingBlueprintStatusStyle({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.border,
  });

  factory BillingBlueprintStatusStyle.forBlueprint(
    BillingBusinessDomainBlueprint blueprint,
  ) {
    if (!blueprint.isLaunchReady) {
      return const BillingBlueprintStatusStyle(
        label: 'Needs config',
        icon: Icons.report_outlined,
        color: Color(0xFFDC2626),
        background: Color(0xFFFEE2E2),
        border: Color(0xFFFECACA),
      );
    }
    if (blueprint.hasWarnings) {
      return const BillingBlueprintStatusStyle(
        label: 'Warnings',
        icon: Icons.warning_amber_outlined,
        color: Color(0xFFD97706),
        background: Color(0xFFFEF3C7),
        border: Color(0xFFFDE68A),
      );
    }

    return const BillingBlueprintStatusStyle(
      label: 'Ready',
      icon: Icons.check_circle_outline,
      color: Color(0xFF059669),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    );
  }
}

class BillingBlueprintContractStateStyle {
  final IconData icon;
  final Color color;
  final Color background;

  const BillingBlueprintContractStateStyle({
    required this.icon,
    required this.color,
    required this.background,
  });

  factory BillingBlueprintContractStateStyle.forContract(
    BillingBusinessDomainBlueprintContract contract,
  ) {
    if (contract.isBlocker) {
      return const BillingBlueprintContractStateStyle(
        icon: Icons.report_outlined,
        color: Color(0xFFDC2626),
        background: Color(0xFFFEE2E2),
      );
    }
    if (contract.isWarning) {
      return const BillingBlueprintContractStateStyle(
        icon: Icons.warning_amber_outlined,
        color: Color(0xFFD97706),
        background: Color(0xFFFEF3C7),
      );
    }

    return const BillingBlueprintContractStateStyle(
      icon: Icons.check_circle_outline,
      color: Color(0xFF059669),
      background: Color(0xFFD1FAE5),
    );
  }
}

String billingBlueprintDestinationCountLabel(int count) {
  return count == 1 ? '1 route' : '$count routes';
}

String billingBlueprintQuickActionCountLabel(int count) {
  return count == 1 ? '1 action' : '$count actions';
}

String billingBlueprintDestinationLabel(String value) {
  final words = value
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .split(RegExp(r'[_\s-]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return 'Dashboard';

  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
