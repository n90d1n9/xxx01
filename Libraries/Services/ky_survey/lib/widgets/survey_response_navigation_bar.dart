import 'package:flutter/material.dart';

import '../logic/survey_response_evidence_summary.dart';
import '../logic/survey_response_session_summary.dart';

class SurveyResponseNavigationBar extends StatelessWidget {
  final SurveyResponseSessionSummary summary;
  final SurveyResponseEvidenceSummary? evidenceSummary;
  final int pageCount;
  final int selectedPageIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final String submitLabel;

  const SurveyResponseNavigationBar({
    super.key,
    required this.summary,
    this.evidenceSummary,
    required this.pageCount,
    required this.selectedPageIndex,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    this.submitLabel = 'Submit Response',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canMoveBack = pageCount > 1 && selectedPageIndex > 0;
    final isLastPage = selectedPageIndex >= pageCount - 1;
    final isSubmitted = summary.isSubmitted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResponseSessionStatus(
                summary: summary,
                evidenceSummary: evidenceSummary,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (pageCount > 1) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Back'),
                      onPressed: isSubmitted || !canMoveBack
                          ? null
                          : onPrevious,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      icon: Icon(
                        isSubmitted
                            ? Icons.check_circle_outline
                            : isLastPage
                            ? Icons.send_outlined
                            : Icons.chevron_right,
                      ),
                      label: Text(
                        isSubmitted
                            ? 'Submitted'
                            : isLastPage
                            ? submitLabel
                            : 'Next Section',
                      ),
                      onPressed: isSubmitted
                          ? null
                          : isLastPage
                          ? onSubmit
                          : onNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponseSessionStatus extends StatelessWidget {
  final SurveyResponseSessionSummary summary;
  final SurveyResponseEvidenceSummary? evidenceSummary;

  const _ResponseSessionStatus({
    required this.summary,
    required this.evidenceSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_statusIcon, color: statusColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _primaryStatusLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _detailLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _detailLabel {
    final firstIssue = summary.firstIssueMessage;
    if (firstIssue != null) {
      return '$firstIssue • ${summary.requiredProgressLabel}';
    }

    final evidenceIssue = evidenceSummary?.firstIssueMessage;
    if (_hasEvidenceIssues && evidenceIssue != null) {
      return '$evidenceIssue • ${evidenceSummary!.progressLabel}';
    }

    return '${summary.secondaryStatusLabel} • ${summary.requiredProgressLabel}';
  }

  String get _primaryStatusLabel {
    if (summary.issues.isNotEmpty || summary.isSubmitted) {
      return summary.primaryStatusLabel;
    }

    if (_hasEvidenceIssues) {
      return evidenceSummary!.primaryStatusLabel;
    }

    return summary.primaryStatusLabel;
  }

  bool get _hasEvidenceIssues {
    final evidence = evidenceSummary;
    return evidence != null && evidence.hasRequirements && !evidence.isComplete;
  }

  IconData get _statusIcon {
    if (summary.isSubmitted) {
      return Icons.check_circle_outline;
    }

    if (summary.issues.isNotEmpty || _hasEvidenceIssues) {
      return Icons.error_outline;
    }

    if (summary.canSubmit) {
      return Icons.task_alt_outlined;
    }

    return Icons.edit_note_outlined;
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (summary.isSubmitted || summary.canSubmit) {
      return colorScheme.primary;
    }

    if (summary.issues.isNotEmpty || _hasEvidenceIssues) {
      return colorScheme.error;
    }

    return colorScheme.onSurfaceVariant;
  }
}
