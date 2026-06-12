import 'package:flutter/material.dart';

import '../../logic/survey_response_evidence_summary.dart';
import '../../models/survey_evidence.dart';

/// Renders one evidence requirement with status, progress, and tap affordance.
class EvidenceRequirementStatusTile extends StatelessWidget {
  final SurveyEvidenceRequirementStatus status;
  final bool highlighted;
  final VoidCallback? onTap;

  const EvidenceRequirementStatusTile({
    super.key,
    required this.status,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(colorScheme);
    final borderColor = highlighted ? statusColor : colorScheme.outlineVariant;

    return Material(
      color: highlighted
          ? statusColor.withValues(alpha: 0.06)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: highlighted ? 1.4 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.14),
                child: Icon(
                  _kindIcon(status.requirement.kind),
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.requirement.labelOrFallback,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.firstIssueMessage ?? status.scopeLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: status.hasIssues
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (highlighted)
                          _StatusPill(
                            icon: Icons.arrow_forward_outlined,
                            label: 'Next action',
                            color: statusColor,
                          ),
                        _StatusPill(
                          icon: _statusIcon,
                          label: status.statusLabel,
                          color: statusColor,
                        ),
                        _StatusPill(
                          icon: Icons.collections_bookmark_outlined,
                          label: status.captureProgressLabel,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _statusIcon {
    if (status.isComplete) {
      return Icons.task_alt_outlined;
    }

    if (status.isMissingRequiredEvidence) {
      return Icons.add_photo_alternate_outlined;
    }

    return Icons.error_outline;
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (status.isComplete) {
      return colorScheme.primary;
    }

    if (status.hasIssues) {
      return colorScheme.error;
    }

    return colorScheme.onSurfaceVariant;
  }

  IconData _kindIcon(SurveyEvidenceKind kind) {
    switch (kind) {
      case SurveyEvidenceKind.location:
        return Icons.place_outlined;
      case SurveyEvidenceKind.image:
        return Icons.image_outlined;
      case SurveyEvidenceKind.audio:
        return Icons.mic_none_outlined;
      case SurveyEvidenceKind.file:
        return Icons.attach_file_outlined;
    }
  }
}

/// Shows a short evidence status attribute inside a rounded pill.
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color == colorScheme.onSurfaceVariant
                    ? colorScheme.onSurfaceVariant
                    : color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
