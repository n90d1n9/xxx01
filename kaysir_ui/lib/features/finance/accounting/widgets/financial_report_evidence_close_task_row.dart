import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_evidence_close_task.dart';
import 'financial_report_evidence_close_task_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportEvidenceCloseTaskRow extends StatelessWidget {
  const FinancialReportEvidenceCloseTaskRow({
    required this.item,
    this.onResolveTask,
    this.resolutionActionLockedReason,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportEvidenceCloseTaskReviewItem item;
  final void Function(
    FinancialReportEvidenceCloseTask task,
    FinancialReportEvidenceCloseTaskResolutionStatus status,
  )?
  onResolveTask;
  final String? resolutionActionLockedReason;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    final color = financialReportEvidenceTaskPriorityColor(
      task.priority,
      isDarkMode,
    );
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final dueLabel = DateFormat('MMM d, yyyy').format(task.dueDate);
    final resolution = item.resolution;

    return FinancialReportTintedSurface(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      backgroundColor: isDarkMode ? Colors.white10 : Colors.white,
      borderAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FinancialReportEvidenceTaskPill(
                label: task.priority.label,
                color: color,
                isDarkMode: isDarkMode,
              ),
              FinancialReportEvidenceTaskPill(
                label: dueLabel,
                color: Colors.blueGrey,
                isDarkMode: isDarkMode,
              ),
              if (task.blocksClose)
                FinancialReportEvidenceTaskPill(
                  label: item.blocksClose ? 'Blocks close' : 'Block cleared',
                  color: item.blocksClose ? Colors.red.shade700 : Colors.teal,
                  isDarkMode: isDarkMode,
                ),
              if (resolution != null)
                FinancialReportEvidenceTaskPill(
                  label: resolution.status.label,
                  color:
                      resolution.clearsCloseBlocker
                          ? Colors.teal
                          : Colors.blueGrey,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.actionLabel,
            style: TextStyle(color: mutedColor, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportEvidenceTaskMetaChip(
                icon: Icons.person_rounded,
                label: task.owner,
                isDarkMode: isDarkMode,
              ),
              FinancialReportEvidenceTaskMetaChip(
                icon: Icons.verified_user_rounded,
                label: task.reviewer,
                isDarkMode: isDarkMode,
              ),
              FinancialReportEvidenceTaskMetaChip(
                icon: Icons.rule_folder_rounded,
                label: task.reference,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.evidenceLabel,
            style: TextStyle(color: mutedColor, fontSize: 11, height: 1.35),
          ),
          if (resolution != null) ...[
            const SizedBox(height: 8),
            Text(
              financialReportEvidenceTaskResolutionLabel(resolution),
              style: TextStyle(color: mutedColor, fontSize: 11, height: 1.35),
            ),
          ],
          if (resolutionActionLockedReason == null &&
              onResolveTask != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed:
                    () => onResolveTask!(
                      task,
                      resolution?.status ??
                          FinancialReportEvidenceCloseTaskResolutionStatus
                              .completed,
                    ),
                icon: const Icon(Icons.task_alt_rounded, size: 16),
                label: Text(
                  resolution == null ? 'Save Evidence' : 'Update Evidence',
                ),
              ),
            ),
          ] else if (resolutionActionLockedReason != null) ...[
            const SizedBox(height: 10),
            FinancialReportEvidenceTaskLockedLabel(
              label: resolutionActionLockedReason!,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }
}

String financialReportEvidenceTaskResolutionLabel(
  FinancialReportEvidenceCloseTaskResolution resolution,
) {
  final reference = resolution.evidenceReference;
  final referenceLabel =
      reference == null || reference.trim().isEmpty ? '' : ' / $reference';
  return '${resolution.reviewer}$referenceLabel: ${resolution.note}';
}
