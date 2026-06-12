import 'package:flutter/material.dart';

import '../logic/survey_version_audit.dart';

class SurveyVersionChangeSummary extends StatelessWidget {
  final SurveyVersionAudit audit;
  final int previewLimit;

  const SurveyVersionChangeSummary({
    super.key,
    required this.audit,
    required this.previewLimit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!audit.hasUnpublishedChanges) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Current draft matches v${audit.activeVersion!.versionNumber}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visibleChanges = audit.changes.take(previewLimit).toList();
    final hiddenCount = audit.changes.length - visibleChanges.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${audit.changes.length} unpublished changes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final change in visibleChanges)
              _VersionChangeRow(change: change),
            if (hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+$hiddenCount more changes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VersionChangeRow extends StatelessWidget {
  final SurveyVersionChange change;

  const _VersionChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_changeIcon(change.type), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: change.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: ' - ${change.detail}'),
                ],
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _changeIcon(SurveyVersionChangeType type) {
    switch (type) {
      case SurveyVersionChangeType.titleChanged:
      case SurveyVersionChangeType.descriptionChanged:
        return Icons.drive_file_rename_outline;
      case SurveyVersionChangeType.sectionAdded:
      case SurveyVersionChangeType.sectionRemoved:
      case SurveyVersionChangeType.sectionChanged:
        return Icons.segment_outlined;
      case SurveyVersionChangeType.questionAdded:
      case SurveyVersionChangeType.questionRemoved:
      case SurveyVersionChangeType.questionChanged:
        return Icons.help_outline;
      case SurveyVersionChangeType.questionOrderChanged:
        return Icons.swap_vert_outlined;
      case SurveyVersionChangeType.evidenceRequirementAdded:
      case SurveyVersionChangeType.evidenceRequirementRemoved:
      case SurveyVersionChangeType.evidenceRequirementChanged:
        return Icons.perm_media_outlined;
    }
  }
}
