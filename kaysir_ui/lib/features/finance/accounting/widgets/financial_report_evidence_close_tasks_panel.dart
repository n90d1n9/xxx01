import 'package:flutter/material.dart';

import '../models/financial_report_evidence_close_task.dart';
import 'financial_report_evidence_close_task_components.dart';
import 'financial_report_evidence_close_task_row.dart';
import 'financial_report_evidence_task_audit_trail.dart';
import 'financial_report_panel_components.dart';

export 'financial_report_evidence_close_task_components.dart';
export 'financial_report_evidence_close_task_row.dart';
export 'financial_report_evidence_task_audit_trail.dart';

class FinancialReportEvidenceCloseTasksPanel extends StatelessWidget {
  const FinancialReportEvidenceCloseTasksPanel({
    super.key,
    required this.items,
    this.auditEvents = const [],
    this.onResolveTask,
    this.resolutionActionLockedReason,
    required this.isDarkMode,
  });

  final List<FinancialReportEvidenceCloseTaskReviewItem> items;
  final List<FinancialReportEvidenceTaskAuditEvent> auditEvents;
  final void Function(
    FinancialReportEvidenceCloseTask task,
    FinancialReportEvidenceCloseTaskResolutionStatus status,
  )?
  onResolveTask;
  final String? resolutionActionLockedReason;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final blockerCount = items.where((item) => item.blocksClose).length;
    final resolvedCount = items.where((item) => item.isResolved).length;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      muted: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportEvidenceCloseTasksHeader(
            taskCount: items.length,
            resolvedCount: resolvedCount,
            blockerCount: blockerCount,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 12),
          ...items.indexed.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.$1 == items.length - 1 ? 0 : 8,
              ),
              child: FinancialReportEvidenceCloseTaskRow(
                item: entry.$2,
                onResolveTask: onResolveTask,
                resolutionActionLockedReason: resolutionActionLockedReason,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
          if (auditEvents.isNotEmpty) ...[
            const SizedBox(height: 12),
            FinancialReportEvidenceTaskAuditTrail(
              events: auditEvents,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }
}
