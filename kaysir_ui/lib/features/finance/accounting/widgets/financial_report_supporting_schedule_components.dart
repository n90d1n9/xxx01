import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_surface.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_statement_components.dart';
import 'financial_report_supporting_schedule_rows.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportSupportingScheduleCard extends StatelessWidget {
  const FinancialReportSupportingScheduleCard({
    required this.schedule,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportSupportingSchedule schedule;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns =
            schedule.hasComparativeAmounts && constraints.maxWidth >= 720;

        return AppSurface(
          padding: const EdgeInsets.all(14),
          backgroundColor:
              isDarkMode ? const Color(0xFF2C2C44) : const Color(0xFFF8FAFC),
          borderColor: isDarkMode ? Colors.white10 : Colors.grey.shade200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ...schedule.standardReferences.map(
                    (reference) => FinancialReportReferencePill(
                      reference: reference,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(schedule.subtitle, style: TextStyle(color: mutedColor)),
              if (schedule.metrics.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      schedule.metrics
                          .map(
                            (metric) => _ScheduleMetricPill(
                              metric: metric,
                              isDarkMode: isDarkMode,
                            ),
                          )
                          .toList(),
                ),
              ],
              const SizedBox(height: 12),
              FinancialReportScheduleSourceLedger(
                schedule: schedule,
                isDarkMode: isDarkMode,
                useColumns: useColumns,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScheduleMetricPill extends StatelessWidget {
  const _ScheduleMetricPill({required this.metric, required this.isDarkMode});

  final FinancialReportScheduleMetric metric;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;

    return Tooltip(
      message: metric.helperText,
      child: FinancialReportTintedSurface(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        fillAlpha: 0.08,
        borderAlpha: 0.22,
        borderRadius: 999,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(text: '${metric.label}: '),
              TextSpan(
                text: metric.value,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
