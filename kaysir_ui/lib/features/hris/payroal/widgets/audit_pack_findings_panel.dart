import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows actionable audit pack findings and remediation progress.
class AuditPackFindingsPanel extends StatelessWidget {
  final AuditPackFindingsSummary summary;
  final ValueChanged<String> onRemediateFinding;
  final ValueChanged<String> onCloseFinding;
  final ValueChanged<String> onReopenFinding;

  const AuditPackFindingsPanel({
    super.key,
    required this.summary,
    required this.onRemediateFinding,
    required this.onCloseFinding,
    required this.onReopenFinding,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        summary.hasOpenFindings
            ? const Color(0xFFB91C1C)
            : const Color(0xFF15803D);

    return HrisSectionPanel(
      icon: Icons.assignment_late_outlined,
      title: 'Audit pack findings',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.closureRate,
                color: color,
                label:
                    '${(summary.closureRate * 100).round()}% findings closed',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(
                    label: summary.hasOpenFindings ? 'Open' : 'Closed',
                    color: color,
                  ),
                  _MetricChip(
                    icon: Icons.report_problem_outlined,
                    label: '${summary.openCount} open',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.remediatedCount} remediated',
                  ),
                  _MetricChip(
                    icon: Icons.verified_outlined,
                    label: '${summary.closedCount} closed',
                  ),
                  _MetricChip(
                    icon: Icons.priority_high_outlined,
                    label: '${summary.criticalCount} critical',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.hasOpenFindings
                        ? Icons.assignment_late_outlined
                        : Icons.verified_outlined,
                    color: color,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (summary.findings.isEmpty)
          const HrisEmptyState(message: 'No audit pack findings')
        else
          HrisListSurface(
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < summary.findings.length;
                  index++
                ) ...[
                  _FindingRow(
                    finding: summary.findings[index],
                    onRemediateFinding: onRemediateFinding,
                    onCloseFinding: onCloseFinding,
                    onReopenFinding: onReopenFinding,
                  ),
                  if (index < summary.findings.length - 1)
                    const Divider(height: 22, color: HrisColors.border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _FindingRow extends StatelessWidget {
  final AuditPackFinding finding;
  final ValueChanged<String> onRemediateFinding;
  final ValueChanged<String> onCloseFinding;
  final ValueChanged<String> onReopenFinding;

  const _FindingRow({
    required this.finding,
    required this.onRemediateFinding,
    required this.onCloseFinding,
    required this.onReopenFinding,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(finding.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_severityIcon(finding.severity), color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      finding.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: finding.status.label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                finding.owner,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.priority_high_outlined,
                    label: finding.severity.label,
                  ),
                  _MetricChip(
                    icon: Icons.event_outlined,
                    label: DateFormat('MMM d').format(finding.dueDate),
                  ),
                  if (finding.resolutionNote.isNotEmpty)
                    _MetricChip(
                      icon: Icons.task_alt_outlined,
                      label: finding.resolutionNote,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                finding.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: finding.isOpen ? color : HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (finding.isOpen)
                    FilledButton.tonalIcon(
                      onPressed: () => onRemediateFinding(finding.id),
                      icon: const Icon(Icons.playlist_add_check_outlined),
                      label: const Text('Remediate'),
                    ),
                  if (finding.canClose)
                    FilledButton.tonalIcon(
                      onPressed: () => onCloseFinding(finding.id),
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Close'),
                    ),
                  if (finding.isClosed)
                    OutlinedButton.icon(
                      onPressed: () => onReopenFinding(finding.id),
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(AuditPackFindingStatus status) {
  return switch (status) {
    AuditPackFindingStatus.open => const Color(0xFFB91C1C),
    AuditPackFindingStatus.remediated => const Color(0xFF2563EB),
    AuditPackFindingStatus.closed => const Color(0xFF15803D),
  };
}

IconData _severityIcon(AuditPackFindingSeverity severity) {
  return switch (severity) {
    AuditPackFindingSeverity.critical => Icons.priority_high_outlined,
    AuditPackFindingSeverity.high => Icons.warning_amber_outlined,
    AuditPackFindingSeverity.medium => Icons.info_outlined,
  };
}
