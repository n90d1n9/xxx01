import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_supporting_schedule_source_components.dart';

export 'financial_report_supporting_schedule_amount_components.dart';
export 'financial_report_supporting_schedule_source_components.dart';

class FinancialReportScheduleSourceLedger extends StatelessWidget {
  const FinancialReportScheduleSourceLedger({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (schedule.lines.isEmpty)
          FinancialReportScheduleEmptyState(isDarkMode: isDarkMode)
        else ...[
          if (useColumns)
            FinancialReportScheduleColumnHeader(isDarkMode: isDarkMode),
          ...schedule.lines.map(
            (line) => FinancialReportScheduleLineRow(
              line: line,
              isDarkMode: isDarkMode,
              useColumns: useColumns,
            ),
          ),
        ],
        const Divider(height: 18),
        FinancialReportScheduleTotalRow(
          schedule: schedule,
          isDarkMode: isDarkMode,
          useColumns: useColumns,
        ),
      ],
    );
  }
}
