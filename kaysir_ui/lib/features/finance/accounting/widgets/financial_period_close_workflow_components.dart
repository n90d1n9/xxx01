import 'package:flutter/material.dart';

import '../models/financial_period_close_workflow.dart';
import 'financial_close_status_pill.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialPeriodCloseWorkflowHeader extends StatelessWidget {
  final FinancialPeriodCloseWorkflowSnapshot snapshot;
  final VoidCallback? onPostClosingEntry;
  final VoidCallback? onClosePeriod;
  final VoidCallback? onReopenPeriod;
  final bool isDarkMode;

  const FinancialPeriodCloseWorkflowHeader({
    required this.snapshot,
    required this.onPostClosingEntry,
    required this.onClosePeriod,
    required this.onReopenPeriod,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final accent = _statusColor(snapshot, isDarkMode);
    final workflowPercent = (snapshot.workflowProgress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252538) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 720;
              final titleBlock = _WorkflowTitleBlock(
                snapshot: snapshot,
                accent: accent,
                isDarkMode: isDarkMode,
              );
              final actions = _WorkflowActionButtons(
                snapshot: snapshot,
                onPostClosingEntry: onPostClosingEntry,
                onClosePeriod: onClosePeriod,
                onReopenPeriod: onReopenPeriod,
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 14), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 18),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: snapshot.workflowProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  color: accent,
                  backgroundColor:
                      isDarkMode ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$workflowPercent%',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialCloseStatusPill(
                label:
                    '${snapshot.completedStepCount}/${snapshot.totalStepCount} steps',
                color: accent,
                isDarkMode: isDarkMode,
              ),
              FinancialCloseStatusPill(
                label: '${(snapshot.readinessRatio * 100).round()}% checklist',
                color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
                isDarkMode: isDarkMode,
              ),
              FinancialCloseStatusPill(
                label: '${snapshot.blockerCount} blocker(s)',
                color:
                    snapshot.blockerCount == 0
                        ? accent
                        : Colors.orange.shade700,
                isDarkMode: isDarkMode,
              ),
              FinancialCloseStatusPill(
                label: '${snapshot.auditEventCount} audit event(s)',
                color: mutedColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialPeriodCloseStepTracker extends StatelessWidget {
  final FinancialPeriodCloseWorkflowSnapshot snapshot;
  final bool isDarkMode;

  const FinancialPeriodCloseStepTracker({
    required this.snapshot,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FinancialReportResponsiveWrapGrid<FinancialPeriodCloseWorkflowStep>(
      items: snapshot.steps,
      breakpoints: const [
        FinancialReportResponsiveGridBreakpoint(minWidth: 520, columns: 2),
        FinancialReportResponsiveGridBreakpoint(minWidth: 760, columns: 3),
        FinancialReportResponsiveGridBreakpoint(minWidth: 1080, columns: 5),
      ],
      itemBuilder:
          (context, step) =>
              FinancialPeriodCloseStepCard(step: step, isDarkMode: isDarkMode),
    );
  }
}

class FinancialPeriodCloseStepCard extends StatelessWidget {
  final FinancialPeriodCloseWorkflowStep step;
  final bool isDarkMode;

  const FinancialPeriodCloseStepCard({
    required this.step,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stepColor(step.status, isDarkMode);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 166,
      padding: const EdgeInsets.all(14),
      borderAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.26)),
                ),
                child: Icon(_stepIcon(step.status), color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mutedColor, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialCloseStatusPill(
                label: step.status.label,
                color: color,
                isDarkMode: isDarkMode,
              ),
              FinancialCloseStatusPill(
                label: step.reference,
                color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialPeriodCloseAttentionPanel extends StatelessWidget {
  final List<String> items;
  final bool isDarkMode;

  const FinancialPeriodCloseAttentionPanel({
    required this.items,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final accent = isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Close Attention',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 7, color: accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(color: mutedColor, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowTitleBlock extends StatelessWidget {
  final FinancialPeriodCloseWorkflowSnapshot snapshot;
  final Color accent;
  final bool isDarkMode;

  const _WorkflowTitleBlock({
    required this.snapshot,
    required this.accent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: Icon(Icons.lock_clock_rounded, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period Close Command Center',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${snapshot.periodLabel} | ${snapshot.statusLabel}',
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkflowActionButtons extends StatelessWidget {
  final FinancialPeriodCloseWorkflowSnapshot snapshot;
  final VoidCallback? onPostClosingEntry;
  final VoidCallback? onClosePeriod;
  final VoidCallback? onReopenPeriod;

  const _WorkflowActionButtons({
    required this.snapshot,
    required this.onPostClosingEntry,
    required this.onClosePeriod,
    required this.onReopenPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: snapshot.canPostClosingEntry ? onPostClosingEntry : null,
          icon: const Icon(Icons.publish_rounded, size: 18),
          label: const Text('Post Closing'),
        ),
        ElevatedButton.icon(
          onPressed: snapshot.canClosePeriod ? onClosePeriod : null,
          icon: const Icon(Icons.lock_rounded, size: 18),
          label: const Text('Close Period'),
        ),
        OutlinedButton.icon(
          onPressed: snapshot.canReopenPeriod ? onReopenPeriod : null,
          icon: const Icon(Icons.lock_open_rounded, size: 18),
          label: const Text('Reopen'),
        ),
      ],
    );
  }
}

Color _statusColor(
  FinancialPeriodCloseWorkflowSnapshot snapshot,
  bool isDarkMode,
) {
  if (snapshot.isClosed) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
  }
  if (snapshot.blockerCount > 0 || !snapshot.hasBoundedPeriod) {
    return Colors.orange.shade700;
  }
  if (snapshot.canClosePeriod) {
    return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
  }
  return isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;
}

Color _stepColor(
  FinancialPeriodCloseWorkflowStepStatus status,
  bool isDarkMode,
) {
  switch (status) {
    case FinancialPeriodCloseWorkflowStepStatus.complete:
      return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
    case FinancialPeriodCloseWorkflowStepStatus.active:
      return isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey.shade700;
    case FinancialPeriodCloseWorkflowStepStatus.blocked:
      return Colors.orange.shade700;
    case FinancialPeriodCloseWorkflowStepStatus.queued:
      return isDarkMode ? Colors.grey.shade500 : Colors.blueGrey;
  }
}

IconData _stepIcon(FinancialPeriodCloseWorkflowStepStatus status) {
  switch (status) {
    case FinancialPeriodCloseWorkflowStepStatus.complete:
      return Icons.check_rounded;
    case FinancialPeriodCloseWorkflowStepStatus.active:
      return Icons.play_arrow_rounded;
    case FinancialPeriodCloseWorkflowStepStatus.blocked:
      return Icons.warning_rounded;
    case FinancialPeriodCloseWorkflowStepStatus.queued:
      return Icons.hourglass_top_rounded;
  }
}
