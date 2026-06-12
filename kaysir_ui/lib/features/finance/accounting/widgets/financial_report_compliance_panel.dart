import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_compliance_chip.dart';
import 'financial_report_compliance_summary_components.dart';
import 'financial_report_panel_components.dart';

export 'financial_report_compliance_chip.dart';
export 'financial_report_compliance_summary_components.dart';

class FinancialReportCompliancePanel extends StatelessWidget {
  const FinancialReportCompliancePanel({
    required this.pack,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final readyCount =
        pack.complianceItems.where((item) => item.isSatisfied).length;
    final totalCount = pack.complianceItems.length;
    final openCount = totalCount - readyCount;
    final exceptionCount =
        pack.complianceItems.where((item) => item.isMaterialVariance).length;
    final readiness = pack.readinessRatio.clamp(0.0, 1.0).toDouble();
    final readinessPercent = (readiness * 100).round();
    final readinessColor = financialReportReadinessColor(readiness, isDarkMode);

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment:
                    isCompact
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                children: [
                  if (isCompact)
                    FinancialReportComplianceHeader(isDarkMode: isDarkMode)
                  else
                    Expanded(
                      child: FinancialReportComplianceHeader(
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  SizedBox(
                    width: isCompact ? 0 : 16,
                    height: isCompact ? 12 : 0,
                  ),
                  FinancialReportComplianceReadinessBadge(
                    percent: readinessPercent,
                    helperText: '$readyCount of $totalCount controls',
                    color: readinessColor,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: readiness,
                  minHeight: 8,
                  backgroundColor:
                      isDarkMode ? Colors.white10 : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(readinessColor),
                ),
              ),
              const SizedBox(height: 12),
              FinancialReportComplianceSummaryStats(
                readyCount: readyCount,
                openCount: openCount,
                exceptionCount: exceptionCount,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 14),
              if (pack.complianceItems.isEmpty)
                FinancialReportComplianceEmptyState(isDarkMode: isDarkMode)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      pack.complianceItems
                          .map(
                            (item) => FinancialReportComplianceChip(
                              item: item,
                              isDarkMode: isDarkMode,
                            ),
                          )
                          .toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}
