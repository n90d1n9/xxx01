import 'package:flutter/material.dart';

import '../helper/format_currency.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportComplianceChip extends StatelessWidget {
  const FinancialReportComplianceChip({
    required this.item,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportComplianceItem item;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = financialReportComplianceItemColor(item, isDarkMode);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final status = financialReportComplianceItemStatus(item);

    return Tooltip(
      message: financialReportComplianceTooltip(item),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: FinancialReportTintedSurface(
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          fillAlpha: isDarkMode ? 0.14 : 0.08,
          borderAlpha: 0.32,
          borderRadius: 999,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                financialReportComplianceItemIcon(item),
                color: color,
                size: 17,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color financialReportComplianceItemColor(
  FinancialReportComplianceItem item,
  bool isDarkMode,
) {
  if (item.isMaterialVariance) {
    return isDarkMode ? const Color(0xFFFF8A8A) : Colors.red.shade700;
  }
  if (item.isSatisfied) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
  }
  return Colors.orange.shade700;
}

IconData financialReportComplianceItemIcon(FinancialReportComplianceItem item) {
  if (item.isMaterialVariance) {
    return Icons.warning_amber_rounded;
  }
  if (item.isSatisfied) {
    return Icons.check_circle_rounded;
  }
  return Icons.pending_actions_rounded;
}

String financialReportComplianceItemStatus(FinancialReportComplianceItem item) {
  if (item.isMaterialVariance) {
    return 'Material';
  }
  if (item.isSatisfied) {
    return 'Ready';
  }
  return 'Open';
}

String financialReportComplianceTooltip(FinancialReportComplianceItem item) {
  return [
    '${item.standardReference}: ${item.description}',
    if (_complianceVarianceText(item) case final varianceText?) varianceText,
    if (_complianceMaterialityText(item) case final materialityText?)
      materialityText,
  ].join('\n');
}

String? _complianceVarianceText(FinancialReportComplianceItem item) {
  if (!item.hasVarianceEvidence) {
    return null;
  }

  final values = <String>[];
  final variance = item.variance;
  if (variance != null) {
    values.add('Current variance ${formatCurrency(variance)}');
  }
  final comparativeVariance = item.comparativeVariance;
  if (comparativeVariance != null) {
    values.add('Comparative variance ${formatCurrency(comparativeVariance)}');
  }
  return values.join(' | ');
}

String? _complianceMaterialityText(FinancialReportComplianceItem item) {
  final threshold = item.materialityThreshold;
  if (threshold == null) {
    return null;
  }
  final status =
      item.isMaterialVariance ? 'Material exception' : 'Below materiality';
  final basis = item.materialityBasis;
  if (basis == null || basis.isEmpty) {
    return '$status threshold ${formatCurrency(threshold)}';
  }
  return '$status threshold ${formatCurrency(threshold)} ($basis)';
}
