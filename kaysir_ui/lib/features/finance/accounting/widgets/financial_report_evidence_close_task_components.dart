import 'package:flutter/material.dart';

import '../models/financial_report_evidence_close_task.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportEvidenceCloseTasksHeader extends StatelessWidget {
  const FinancialReportEvidenceCloseTasksHeader({
    required this.taskCount,
    required this.resolvedCount,
    required this.blockerCount,
    required this.isDarkMode,
    super.key,
  });

  final int taskCount;
  final int resolvedCount;
  final int blockerCount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final title = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_turned_in_rounded,
              size: 20,
              color:
                  blockerCount > 0
                      ? Colors.red.shade600
                      : Colors.amber.shade800,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Close Evidence Tasks',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
        final counters = Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
          children: [
            FinancialReportEvidenceTaskPill(
              label: '$taskCount task(s)',
              color: Colors.blueGrey,
              isDarkMode: isDarkMode,
            ),
            if (resolvedCount > 0)
              FinancialReportEvidenceTaskPill(
                label: '$resolvedCount resolved',
                color: Colors.teal,
                isDarkMode: isDarkMode,
              ),
            if (blockerCount > 0)
              FinancialReportEvidenceTaskPill(
                label: '$blockerCount blocks close',
                color: Colors.red.shade700,
                isDarkMode: isDarkMode,
              ),
          ],
        );

        return Flex(
          direction: isCompact ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment:
              isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (isCompact) title else Expanded(child: title),
            SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 10 : 0),
            if (isCompact)
              counters
            else
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: counters),
              ),
          ],
        );
      },
    );
  }
}

class FinancialReportEvidenceTaskMetaChip extends StatelessWidget {
  const FinancialReportEvidenceTaskMetaChip({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800;

    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade100,
      borderAlpha: isDarkMode ? 0.16 : 0.14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportEvidenceTaskPill extends StatelessWidget {
  const FinancialReportEvidenceTaskPill({
    required this.label,
    required this.color,
    required this.isDarkMode,
    super.key,
  });

  final String label;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportTintedSurface(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      fillAlpha: isDarkMode ? 0.16 : 0.1,
      borderAlpha: 0.24,
      borderRadius: 999,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class FinancialReportEvidenceTaskLockedLabel extends StatelessWidget {
  const FinancialReportEvidenceTaskLockedLabel({
    required this.label,
    required this.isDarkMode,
    super.key,
  });

  final String label;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline_rounded, size: 14, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

Color financialReportEvidenceTaskPriorityColor(
  FinancialReportEvidenceCloseTaskPriority priority,
  bool isDarkMode,
) {
  switch (priority) {
    case FinancialReportEvidenceCloseTaskPriority.action:
      return isDarkMode ? const Color(0xFFFF8A80) : Colors.red.shade700;
    case FinancialReportEvidenceCloseTaskPriority.monitor:
      return isDarkMode ? const Color(0xFFFFD166) : Colors.amber.shade800;
  }
}
