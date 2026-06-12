import 'package:flutter/material.dart';

import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_pack.dart';
import '../services/financial_report_evidence_close_task_service.dart';
import '../services/financial_report_schedule_evidence_health_service.dart';
import 'financial_report_evidence_close_tasks_panel.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_schedule_evidence_health_components.dart';
import 'financial_report_supporting_schedule_components.dart';
import 'financial_report_supporting_schedule_panel_components.dart';

class FinancialReportSupportingSchedulesPanel extends StatelessWidget {
  const FinancialReportSupportingSchedulesPanel({
    super.key,
    required this.pack,
    this.evidenceTaskResolutions = const [],
    this.evidenceTaskAuditEvents = const [],
    this.onResolveEvidenceTask,
    this.evidenceTaskResolutionLockedReason,
    required this.isDarkMode,
  });

  final FinancialReportPack pack;
  final List<FinancialReportEvidenceCloseTaskResolution>
  evidenceTaskResolutions;
  final List<FinancialReportEvidenceTaskAuditEvent> evidenceTaskAuditEvents;
  final void Function(
    FinancialReportEvidenceCloseTask task,
    FinancialReportEvidenceCloseTaskResolutionStatus status,
  )?
  onResolveEvidenceTask;
  final String? evidenceTaskResolutionLockedReason;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    if (pack.supportingSchedules.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeCount =
        pack.supportingSchedules
            .where((schedule) => schedule.hasActivity)
            .length;
    final sourceLineCount = pack.supportingSchedules.fold<int>(
      0,
      (total, schedule) => total + schedule.lines.length,
    );
    const evidenceHealthService =
        FinancialReportScheduleEvidenceHealthService();
    final evidenceHealth = evidenceHealthService.summarize(
      pack.supportingSchedules,
    );
    final evidenceHealthItems = evidenceHealthService.summarizeBySchedule(
      pack.supportingSchedules,
    );
    final evidenceCloseTaskItems =
        const FinancialReportEvidenceCloseTaskService().buildReviewItems(
          schedules: pack.supportingSchedules,
          resolutions: evidenceTaskResolutions,
          generatedAt: pack.generatedAt,
        );

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportSupportingSchedulesHeader(
            scheduleCount: pack.supportingSchedules.length,
            activeCount: activeCount,
            sourceLineCount: sourceLineCount,
            isDarkMode: isDarkMode,
            evidenceHealth: evidenceHealth,
          ),
          if (!evidenceHealth.isReady) ...[
            const SizedBox(height: 12),
            FinancialReportScheduleEvidenceHealthBanner(
              summary: evidenceHealth,
              items: evidenceHealthItems
                  .where((item) => !item.summary.isReady)
                  .toList(growable: false),
              isDarkMode: isDarkMode,
            ),
          ],
          if (evidenceCloseTaskItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            FinancialReportEvidenceCloseTasksPanel(
              items: evidenceCloseTaskItems,
              auditEvents: evidenceTaskAuditEvents,
              onResolveTask: onResolveEvidenceTask,
              resolutionActionLockedReason: evidenceTaskResolutionLockedReason,
              isDarkMode: isDarkMode,
            ),
          ],
          const SizedBox(height: 14),
          ...pack.supportingSchedules.indexed.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom:
                    entry.$1 == pack.supportingSchedules.length - 1 ? 0 : 12,
              ),
              child: FinancialReportSupportingScheduleCard(
                schedule: entry.$2,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
