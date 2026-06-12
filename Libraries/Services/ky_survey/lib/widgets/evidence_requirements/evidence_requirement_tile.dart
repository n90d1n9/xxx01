import 'package:flutter/material.dart';

import '../../models/survey_evidence.dart';
import '../../models/survey_evidence_requirement.dart';

class EvidenceRequirementTile extends StatelessWidget {
  final SurveyEvidenceRequirement requirement;
  final String? questionLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EvidenceRequirementTile({
    super.key,
    required this.requirement,
    required this.questionLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                _kindIcon(requirement.kind),
                size: 19,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requirement.labelOrFallback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _InfoChip(label: _scopeLabel),
                      _InfoChip(label: 'Min ${requirement.minCount}'),
                      if (requirement.requireUploaded)
                        const _InfoChip(label: 'Upload required'),
                      if (requirement.maxAttachmentSizeBytes != null)
                        _InfoChip(label: _maxSizeLabel),
                      if (requirement.minAudioDurationMilliseconds != null)
                        _InfoChip(label: _minDurationLabel),
                      if (requirement.maxLocationAccuracyMeters != null)
                        _InfoChip(label: _accuracyLabel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Edit requirement',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Remove requirement',
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    final instructions = requirement.instructions.trim();
    if (instructions.isNotEmpty) {
      return instructions;
    }

    if (requirement.scope == SurveyEvidenceScope.question) {
      return questionLabel == null
          ? 'Question-level evidence'
          : 'Question: $questionLabel';
    }

    return 'Response-level evidence';
  }

  String get _scopeLabel {
    if (requirement.scope == SurveyEvidenceScope.question) {
      return 'Question';
    }

    return 'Response';
  }

  String get _maxSizeLabel {
    final bytes = requirement.maxAttachmentSizeBytes ?? 0;
    final megabytes = bytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(megabytes >= 10 ? 0 : 1)} MB max';
  }

  String get _minDurationLabel {
    final seconds = (requirement.minAudioDurationMilliseconds ?? 0) / 1000;
    return '${seconds.round()}s min';
  }

  String get _accuracyLabel {
    final meters = requirement.maxLocationAccuracyMeters ?? 0;
    return '${meters.toStringAsFixed(meters >= 10 ? 0 : 1)}m accuracy';
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

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
