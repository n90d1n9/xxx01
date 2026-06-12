import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_row_surface_components.dart';
import 'financial_report_schedule_evidence_trail.dart';
import 'financial_report_supporting_schedule_amount_components.dart';

class FinancialReportScheduleColumnHeader extends StatelessWidget {
  const FinancialReportScheduleColumnHeader({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final style = TextStyle(
      color: mutedColor,
      fontSize: 12,
      fontWeight: FontWeight.w800,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        children: [
          Expanded(child: Text('Source line', style: style)),
          SizedBox(
            width: 142,
            child: Text('Current', textAlign: TextAlign.right, style: style),
          ),
          SizedBox(
            width: 142,
            child: Text(
              'Comparative',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          SizedBox(
            width: 112,
            child: Text('Variance', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class FinancialReportScheduleLineRow extends StatelessWidget {
  const FinancialReportScheduleLineRow({
    required this.line,
    required this.isDarkMode,
    required this.useColumns,
    super.key,
  });

  final FinancialReportScheduleLine line;
  final bool isDarkMode;
  final bool useColumns;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return FinancialReportRowSurface(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderColor: isDarkMode ? Colors.white10 : Colors.grey.shade200,
      child:
          useColumns
              ? Row(
                children: [
                  Expanded(child: _lineLabel(textColor)),
                  FinancialReportScheduleAmountCell(
                    amount: line.amount,
                    isDarkMode: isDarkMode,
                  ),
                  FinancialReportScheduleAmountCell(
                    amount: line.comparativeAmount ?? 0,
                    isDarkMode: isDarkMode,
                  ),
                  FinancialReportScheduleAmountCell(
                    amount: line.variance ?? 0,
                    isDarkMode: isDarkMode,
                    width: 112,
                    isVariance: true,
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lineLabel(textColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FinancialReportScheduleAmountPill(
                        label: 'Current',
                        amount: line.amount,
                        isDarkMode: isDarkMode,
                      ),
                      if (line.hasComparativeAmount)
                        FinancialReportScheduleAmountPill(
                          label: 'Comparative',
                          amount: line.comparativeAmount ?? 0,
                          isDarkMode: isDarkMode,
                        ),
                      if (line.hasComparativeAmount)
                        FinancialReportScheduleAmountPill(
                          label: 'Variance',
                          amount: line.variance ?? 0,
                          isDarkMode: isDarkMode,
                          isVariance: true,
                        ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _lineLabel(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          line.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
        if (line.sourceCategory != null || line.noteReference != null) ...[
          const SizedBox(height: 3),
          FinancialReportScheduleEvidenceTrail(
            sourceCategory: line.sourceCategory,
            noteReference: line.noteReference,
            isDarkMode: isDarkMode,
          ),
        ],
      ],
    );
  }
}

class FinancialReportScheduleTotalRow extends StatelessWidget {
  const FinancialReportScheduleTotalRow({
    required this.schedule,
    required this.isDarkMode,
    required this.useColumns,
    super.key,
  });

  final FinancialReportSupportingSchedule schedule;
  final bool isDarkMode;
  final bool useColumns;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    if (useColumns) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                schedule.totalLabel,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
              ),
            ),
            FinancialReportScheduleAmountCell(
              amount: schedule.totalAmount,
              isDarkMode: isDarkMode,
              isTotal: true,
            ),
            FinancialReportScheduleAmountCell(
              amount: schedule.comparativeTotalAmount ?? 0,
              isDarkMode: isDarkMode,
              isTotal: true,
            ),
            FinancialReportScheduleAmountCell(
              amount: schedule.variance ?? 0,
              isDarkMode: isDarkMode,
              width: 112,
              isVariance: true,
              isTotal: true,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          schedule.totalLabel,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FinancialReportScheduleAmountPill(
              label: 'Current',
              amount: schedule.totalAmount,
              isDarkMode: isDarkMode,
            ),
            if (schedule.hasComparativeAmounts)
              FinancialReportScheduleAmountPill(
                label: 'Comparative',
                amount: schedule.comparativeTotalAmount ?? 0,
                isDarkMode: isDarkMode,
              ),
            if (schedule.hasComparativeAmounts)
              FinancialReportScheduleAmountPill(
                label: 'Variance',
                amount: schedule.variance ?? 0,
                isDarkMode: isDarkMode,
                isVariance: true,
              ),
          ],
        ),
      ],
    );
  }
}

class FinancialReportScheduleEmptyState extends StatelessWidget {
  const FinancialReportScheduleEmptyState({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelEmptyState(
      title: 'No source lines are attached to this schedule yet.',
      icon: Icons.playlist_remove_rounded,
      isDarkMode: isDarkMode,
    );
  }
}
