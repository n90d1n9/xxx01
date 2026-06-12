import 'package:flutter/material.dart';

import '../logic/survey_version_audit.dart';
import '../models/survey.dart';
import 'survey_version_change_summary.dart';
import 'survey_version_timeline.dart';

class SurveyVersionHistoryPanel extends StatelessWidget {
  final Survey survey;
  final int changePreviewLimit;
  final int versionPreviewLimit;

  const SurveyVersionHistoryPanel({
    super.key,
    required this.survey,
    this.changePreviewLimit = 4,
    this.versionPreviewLimit = 4,
  });

  @override
  Widget build(BuildContext context) {
    final audit = SurveyVersionAudit.evaluate(survey);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_edu_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Version History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _VersionStatusChip(audit: audit),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.inventory_2_outlined,
                  label: '${audit.publishedVersionCount} published',
                ),
                _MetricChip(
                  icon: Icons.verified_outlined,
                  label: audit.activeVersion == null
                      ? 'No active version'
                      : 'Active v${audit.activeVersion!.versionNumber}',
                ),
                _MetricChip(
                  icon: Icons.upgrade_outlined,
                  label: 'Next v${audit.nextVersionNumber}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!audit.hasPublishedVersion)
              _NoVersionState(colorScheme: colorScheme)
            else ...[
              SurveyVersionChangeSummary(
                audit: audit,
                previewLimit: changePreviewLimit,
              ),
              const SizedBox(height: 16),
              SurveyVersionTimeline(
                versions: audit.versions.take(versionPreviewLimit).toList(),
                activeVersionId: audit.activeVersion?.id,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VersionStatusChip extends StatelessWidget {
  final SurveyVersionAudit audit;

  const _VersionStatusChip({required this.audit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _status();

    return Chip(
      avatar: Icon(status.icon, size: 18, color: status.color(colorScheme)),
      label: Text(status.label),
    );
  }

  _VersionStatus _status() {
    if (!audit.hasPublishedVersion) {
      return const _VersionStatus(
        label: 'Draft only',
        icon: Icons.edit_note_outlined,
        tone: _VersionTone.neutral,
      );
    }

    if (audit.hasUnpublishedChanges) {
      return const _VersionStatus(
        label: 'Draft changed',
        icon: Icons.pending_actions_outlined,
        tone: _VersionTone.warning,
      );
    }

    return const _VersionStatus(
      label: 'In sync',
      icon: Icons.task_alt_outlined,
      tone: _VersionTone.success,
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _NoVersionState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _NoVersionState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined),
            SizedBox(width: 12),
            Expanded(child: Text('No published versions yet.')),
          ],
        ),
      ),
    );
  }
}

class _VersionStatus {
  final String label;
  final IconData icon;
  final _VersionTone tone;

  const _VersionStatus({
    required this.label,
    required this.icon,
    required this.tone,
  });

  Color color(ColorScheme colorScheme) {
    switch (tone) {
      case _VersionTone.neutral:
        return colorScheme.onSurfaceVariant;
      case _VersionTone.warning:
        return colorScheme.tertiary;
      case _VersionTone.success:
        return colorScheme.primary;
    }
  }
}

enum _VersionTone { neutral, warning, success }
