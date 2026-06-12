import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_upload_planner.dart';
import '../../logic/survey_evidence_upload_plan_activity.dart';
import '../evidence_upload_task_action_button.dart';
import 'survey_dashboard_shared.dart';

typedef SurveyEvidenceUploadTaskAction =
    void Function(SurveyEvidenceUploadTask task);
typedef SurveyEvidenceUploadPlanAction =
    void Function(SurveyEvidenceUploadPlan plan);

/// Renders upload-plan tasks with guarded actions for dashboard operators.
class SurveyEvidenceUploadPlanPanel extends StatelessWidget {
  final SurveyEvidenceUploadPlan plan;
  final SurveyEvidenceUploadPlanAction? onRunUploadPlan;
  final String runUploadPlanLabel;
  final SurveyEvidenceUploadTaskAction? onQueueUpload;
  final SurveyEvidenceUploadTaskAction? onRetryUpload;
  final SurveyEvidenceUploadTaskAction? onFixEvidence;
  final SurveyEvidenceUploadTaskAction? onMonitorUpload;
  final Set<String> activeUploadKeys;

  const SurveyEvidenceUploadPlanPanel({
    super.key,
    required this.plan,
    this.onRunUploadPlan,
    this.runUploadPlanLabel = 'Upload ready',
    this.onQueueUpload,
    this.onRetryUpload,
    this.onFixEvidence,
    this.onMonitorUpload,
    this.activeUploadKeys = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (!plan.hasWork) {
      return const SurveyEmptyState(
        icon: Icons.cloud_done_outlined,
        title: 'No upload actions',
        subtitle: 'Evidence attachments do not need upload attention.',
      );
    }

    final activity = SurveyEvidenceUploadPlanActivity(
      plan: plan,
      activeUploadKeys: activeUploadKeys,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onRunUploadPlan != null && activity.hasUploadableTasks) ...[
          _UploadPlanActionBar(
            readyCount: activity.readyUploadableCount,
            activeCount: activity.activeUploadableCount,
            label: runUploadPlanLabel,
            onPressed: activity.hasReadyUploadableTasks
                ? () => onRunUploadPlan!(plan)
                : null,
          ),
          const SizedBox(height: 10),
        ],
        for (final task in plan.tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _UploadTaskTile(
              task: task,
              active: activity.isActive(task),
              onQueueUpload: onQueueUpload,
              onRetryUpload: onRetryUpload,
              onFixEvidence: onFixEvidence,
              onMonitorUpload: onMonitorUpload,
            ),
          ),
      ],
    );
  }
}

class _UploadPlanActionBar extends StatelessWidget {
  final int readyCount;
  final int activeCount;
  final String label;
  final VoidCallback? onPressed;

  const _UploadPlanActionBar({
    required this.readyCount,
    required this.activeCount,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusLabel = _statusLabel;
    final actionLabel = readyCount == 0 && activeCount > 0
        ? 'Uploading...'
        : label;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  readyCount == 0 && activeCount > 0
                      ? Icons.sync_outlined
                      : Icons.cloud_upload_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              icon: const Icon(Icons.cloud_sync_outlined, size: 18),
              label: Text(actionLabel),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }

  String get _statusLabel {
    if (readyCount == 0 && activeCount > 0) {
      return '$activeCount uploading';
    }
    if (activeCount > 0) {
      return '$readyCount ready • $activeCount uploading';
    }
    return '$readyCount ready';
  }
}

class _UploadTaskTile extends StatelessWidget {
  final SurveyEvidenceUploadTask task;
  final bool active;
  final SurveyEvidenceUploadTaskAction? onQueueUpload;
  final SurveyEvidenceUploadTaskAction? onRetryUpload;
  final SurveyEvidenceUploadTaskAction? onFixEvidence;
  final SurveyEvidenceUploadTaskAction? onMonitorUpload;

  const _UploadTaskTile({
    required this.task,
    required this.active,
    required this.onQueueUpload,
    required this.onRetryUpload,
    required this.onFixEvidence,
    required this.onMonitorUpload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _actionColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_actionIcon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _TaskActionButton(
              task: task,
              color: color,
              active: active,
              onPressed: _onPressed,
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? get _onPressed {
    switch (task.action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return onFixEvidence == null ? null : () => onFixEvidence!(task);
      case SurveyEvidenceUploadAction.retryUpload:
        return onRetryUpload == null ? null : () => onRetryUpload!(task);
      case SurveyEvidenceUploadAction.queueUpload:
        return onQueueUpload == null ? null : () => onQueueUpload!(task);
      case SurveyEvidenceUploadAction.monitorUpload:
        return onMonitorUpload == null ? null : () => onMonitorUpload!(task);
      case SurveyEvidenceUploadAction.none:
        return null;
    }
  }

  IconData get _actionIcon {
    switch (task.action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return Icons.build_circle_outlined;
      case SurveyEvidenceUploadAction.retryUpload:
        return Icons.refresh_outlined;
      case SurveyEvidenceUploadAction.queueUpload:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceUploadAction.monitorUpload:
        return Icons.sync_outlined;
      case SurveyEvidenceUploadAction.none:
        return Icons.check_circle_outline;
    }
  }

  Color _actionColor(ColorScheme colorScheme) {
    switch (task.action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return colorScheme.error;
      case SurveyEvidenceUploadAction.retryUpload:
      case SurveyEvidenceUploadAction.queueUpload:
      case SurveyEvidenceUploadAction.monitorUpload:
        return colorScheme.tertiary;
      case SurveyEvidenceUploadAction.none:
        return colorScheme.primary;
    }
  }
}

class _TaskActionButton extends StatelessWidget {
  final SurveyEvidenceUploadTask task;
  final Color color;
  final bool active;
  final VoidCallback? onPressed;

  const _TaskActionButton({
    required this.task,
    required this.color,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (active) {
      return SurveyEvidenceUploadTaskActionButton(
        task: task,
        active: true,
        onPressed: null,
        style: SurveyEvidenceUploadTaskActionButtonStyle.outlined,
      );
    }

    if (onPressed == null) {
      return _ActionBadge(label: task.actionLabel, color: color);
    }

    return SurveyEvidenceUploadTaskActionButton(
      task: task,
      onPressed: onPressed,
      style: SurveyEvidenceUploadTaskActionButtonStyle.outlined,
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
