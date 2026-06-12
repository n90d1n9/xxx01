import 'package:flutter/material.dart';

import '../logic/survey_response_evidence_summary.dart';
import '../models/survey_evidence_requirement.dart';
import 'evidence_response/evidence_requirement_status_tile.dart';

/// Shows required response evidence progress and actionable capture targets.
class SurveyResponseEvidenceChecklist extends StatelessWidget {
  final SurveyResponseEvidenceSummary summary;
  final bool highlighted;
  final String? focusedRequirementId;
  final ValueChanged<SurveyEvidenceRequirement>? onRequirementSelected;
  final ValueChanged<SurveyEvidenceRequirementStatus>?
  onRequirementStatusSelected;

  const SurveyResponseEvidenceChecklist({
    super.key,
    required this.summary,
    this.highlighted = false,
    this.focusedRequirementId,
    this.onRequirementSelected,
    this.onRequirementStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!summary.hasRequirements) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(colorScheme);
    final focusRequirementId =
        focusedRequirementId ??
        (highlighted
            ? summary.firstIncompleteRequirement?.requirement.id
            : null);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? statusColor.withValues(alpha: 0.06)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted ? statusColor : colorScheme.outlineVariant,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: statusColor.withValues(alpha: 0.14),
                  child: Icon(_statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evidence checklist',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: summary.primaryStatusLabel,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: summary.completionRate.clamp(0, 1).toDouble(),
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.task_alt_outlined,
                  label: summary.progressLabel,
                ),
                _MetricChip(
                  icon: Icons.inventory_2_outlined,
                  label: '${summary.completeCount} complete',
                ),
                if (summary.missingRequiredCount > 0)
                  _MetricChip(
                    icon: Icons.error_outline,
                    label: '${summary.missingRequiredCount} missing',
                    color: colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                for (final status in summary.requirementStatuses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EvidenceRequirementStatusTile(
                      status: status,
                      highlighted: status.requirement.id == focusRequirementId,
                      onTap:
                          onRequirementSelected == null &&
                              onRequirementStatusSelected == null
                          ? null
                          : () => _selectRequirement(status),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final issueMessage = summary.firstIssueMessage;
    if (issueMessage != null) {
      return issueMessage;
    }

    return '${summary.progressLabel} • ${summary.completionPercent}% ready';
  }

  IconData get _statusIcon {
    if (summary.isComplete) {
      return Icons.verified_outlined;
    }

    if (summary.missingRequiredCount > 0) {
      return Icons.add_location_alt_outlined;
    }

    return Icons.error_outline;
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (summary.isComplete) {
      return colorScheme.primary;
    }

    return colorScheme.error;
  }

  void _selectRequirement(SurveyEvidenceRequirementStatus status) {
    onRequirementStatusSelected?.call(status);
    onRequirementSelected?.call(status.requirement);
  }
}

/// Displays one compact evidence metric in the response checklist.
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetricChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onSurfaceVariant;

    return Chip(
      avatar: Icon(icon, size: 18, color: effectiveColor),
      label: Text(label),
      labelStyle: TextStyle(color: effectiveColor, fontWeight: FontWeight.w700),
    );
  }
}

/// Shows the current evidence checklist readiness label.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
