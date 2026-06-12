import 'package:flutter/material.dart';

import '../../analytics/survey_fieldwork_insights.dart';
import '../../analytics/survey_response_sync_readiness.dart';
import '../../models/survey.dart';
import '../../models/survey_assignment.dart';
import 'survey_dashboard_shared.dart';
import 'survey_metric_card.dart';
import 'survey_read_only_pill.dart';
import 'survey_response_sync_readiness_panel.dart';

typedef SurveyAssignmentStatusChanged =
    void Function(SurveyAssignment assignment, SurveyAssignmentStatus status);

/// Renders fieldwork assignments, response readiness, and optional commands.
class SurveyFieldworkBoard extends StatelessWidget {
  final SurveyFieldworkInsights insights;
  final SurveyResponseSyncReadinessInsights responseSyncReadiness;
  final ValueChanged<Survey>? onOpenSurvey;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;
  final SurveyAssignmentStatusChanged? onStatusChanged;

  const SurveyFieldworkBoard({
    super.key,
    required this.insights,
    required this.responseSyncReadiness,
    this.onOpenSurvey,
    this.onOpenResponse,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final assignments = insights.nextAssignments(limit: 8);

    return SurveySectionStack(
      children: [
        SurveyMetricGrid(
          cards: [
            SurveyMetricCard(
              icon: Icons.assignment_ind_outlined,
              label: 'Assignments',
              value: insights.totalAssignments.toString(),
              detail: '${insights.activeAssignments} active',
            ),
            SurveyMetricCard(
              icon: Icons.task_alt_outlined,
              label: 'Completed',
              value: insights.completedAssignments.toString(),
              detail:
                  '${(insights.completionRate * 100).round()}% response target',
            ),
            SurveyMetricCard(
              icon: Icons.warning_amber_outlined,
              label: 'Overdue',
              value: insights.overdueAssignments().toString(),
              detail: 'Needs attention',
            ),
          ],
        ),
        const SurveySectionHeader(title: 'Response Readiness'),
        SurveyResponseSyncReadinessPanel(
          insights: responseSyncReadiness,
          onOpenResponse: onOpenResponse,
        ),
        const SurveySectionHeader(title: 'Assignment Queue'),
        if (assignments.isEmpty)
          const SurveyEmptyState(
            icon: Icons.assignment_late_outlined,
            title: 'No fieldwork assignments',
            subtitle: 'Assigned survey work will appear here.',
          )
        else
          ...assignments.map((assignment) {
            return _AssignmentCard(
              assignment: assignment,
              survey: insights.surveyForAssignment(assignment),
              onOpenSurvey: onOpenSurvey,
              onStatusChanged: onStatusChanged,
            );
          }),
      ],
    );
  }
}

/// Displays a single fieldwork assignment with progress and contextual actions.
class _AssignmentCard extends StatelessWidget {
  final SurveyAssignment assignment;
  final Survey? survey;
  final ValueChanged<Survey>? onOpenSurvey;
  final SurveyAssignmentStatusChanged? onStatusChanged;

  const _AssignmentCard({
    required this.assignment,
    required this.survey,
    required this.onOpenSurvey,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverdue = assignment.isOverdue();
    final actions = _actionWidgets();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOverdue ? colorScheme.error : colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey?.title ?? 'Unknown survey',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assignment.assigneeName} • ${assignment.territory}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AssignmentStatusChip(status: assignment.status),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: assignment.completionRate,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  Text(
                    '${assignment.completedResponses} / ${assignment.targetResponses} responses',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    isOverdue
                        ? 'Overdue'
                        : 'Due ${_formatShortDate(assignment.dueAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isOverdue ? FontWeight.w800 : null,
                    ),
                  ),
                  if (assignment.note != null)
                    Text(
                      assignment.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _actionWidgets() {
    final actions = <Widget>[];
    final survey = this.survey;

    if (survey != null && onOpenSurvey != null) {
      actions.add(
        OutlinedButton.icon(
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Open'),
          onPressed: () => onOpenSurvey!(survey),
        ),
      );
    }

    final onStatusChanged = this.onStatusChanged;
    if (onStatusChanged != null) {
      actions.addAll(
        _nextStatuses(assignment.status).map((status) {
          return FilledButton.tonalIcon(
            icon: Icon(_statusIcon(status), size: 18),
            label: Text(status.label),
            onPressed: () => onStatusChanged(assignment, status),
          );
        }),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        const SurveyReadOnlyPill(tooltip: 'Read-only assignment summary'),
      );
    }

    return actions;
  }

  List<SurveyAssignmentStatus> _nextStatuses(SurveyAssignmentStatus status) {
    switch (status) {
      case SurveyAssignmentStatus.queued:
        return const [SurveyAssignmentStatus.inProgress];
      case SurveyAssignmentStatus.inProgress:
        return const [
          SurveyAssignmentStatus.needsReview,
          SurveyAssignmentStatus.blocked,
        ];
      case SurveyAssignmentStatus.needsReview:
        return const [
          SurveyAssignmentStatus.completed,
          SurveyAssignmentStatus.inProgress,
        ];
      case SurveyAssignmentStatus.blocked:
        return const [SurveyAssignmentStatus.inProgress];
      case SurveyAssignmentStatus.completed:
        return const [];
    }
  }

  IconData _statusIcon(SurveyAssignmentStatus status) {
    switch (status) {
      case SurveyAssignmentStatus.queued:
        return Icons.schedule_outlined;
      case SurveyAssignmentStatus.inProgress:
        return Icons.play_circle_outline;
      case SurveyAssignmentStatus.needsReview:
        return Icons.rate_review_outlined;
      case SurveyAssignmentStatus.completed:
        return Icons.task_alt_outlined;
      case SurveyAssignmentStatus.blocked:
        return Icons.block_outlined;
    }
  }

  String _formatShortDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// Presents the current assignment status with compact dashboard styling.
class _AssignmentStatusChip extends StatelessWidget {
  final SurveyAssignmentStatus status;

  const _AssignmentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case SurveyAssignmentStatus.queued:
        return colorScheme.secondary;
      case SurveyAssignmentStatus.inProgress:
        return colorScheme.primary;
      case SurveyAssignmentStatus.needsReview:
        return colorScheme.tertiary;
      case SurveyAssignmentStatus.completed:
        return colorScheme.primary;
      case SurveyAssignmentStatus.blocked:
        return colorScheme.error;
    }
  }
}
