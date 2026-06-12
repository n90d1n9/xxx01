import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import '../../analytics/survey_evidence_upload_planner.dart';
import '../../logic/survey_evidence_upload_activity_tracker.dart';
import '../evidence_upload_task_action_button.dart';

/// Handles an upload review action for one evidence upload task.
typedef SurveyEvidenceUploadReviewTaskAction =
    void Function(SurveyEvidenceUploadTask task);

/// Presents response evidence uploads that need operator review.
class SurveyEvidenceUploadReviewSheet extends StatelessWidget {
  final List<SurveyEvidenceSyncItem> items;
  final String? focusedQuestionId;
  final ValueChanged<SurveyEvidenceSyncItem>? onItemSelected;
  final SurveyEvidenceUploadReviewTaskAction? onQueueUpload;
  final SurveyEvidenceUploadReviewTaskAction? onRetryUpload;
  final SurveyEvidenceUploadReviewTaskAction? onFixEvidence;
  final SurveyEvidenceUploadReviewTaskAction? onMonitorUpload;
  final Set<String> activeUploadKeys;

  const SurveyEvidenceUploadReviewSheet({
    super.key,
    required this.items,
    this.focusedQuestionId,
    this.onItemSelected,
    this.onQueueUpload,
    this.onRetryUpload,
    this.onFixEvidence,
    this.onMonitorUpload,
    this.activeUploadKeys = const {},
  });

  static Future<void> show({
    required BuildContext context,
    required List<SurveyEvidenceSyncItem> items,
    String? focusedQuestionId,
    ValueChanged<SurveyEvidenceSyncItem>? onItemSelected,
    SurveyEvidenceUploadReviewTaskAction? onQueueUpload,
    SurveyEvidenceUploadReviewTaskAction? onRetryUpload,
    SurveyEvidenceUploadReviewTaskAction? onFixEvidence,
    SurveyEvidenceUploadReviewTaskAction? onMonitorUpload,
    Set<String> activeUploadKeys = const {},
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SurveyEvidenceUploadReviewSheet(
        items: items,
        focusedQuestionId: focusedQuestionId,
        onItemSelected: onItemSelected,
        onQueueUpload: onQueueUpload,
        onRetryUpload: onRetryUpload,
        onFixEvidence: onFixEvidence,
        onMonitorUpload: onMonitorUpload,
        activeUploadKeys: activeUploadKeys,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orderedItems = _orderedItems;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.cloud_sync_outlined,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evidence upload review',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _summaryLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (orderedItems.isEmpty)
                const _UploadReviewEmptyState()
              else
                Column(
                  children: [
                    for (final item in orderedItems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UploadReviewTile(
                          item: item,
                          highlighted: _matchesFocus(item),
                          onQueueUpload: onQueueUpload,
                          onRetryUpload: onRetryUpload,
                          onFixEvidence: onFixEvidence,
                          onMonitorUpload: onMonitorUpload,
                          activeUploadKeys: activeUploadKeys,
                          onSelected: onItemSelected == null
                              ? null
                              : () => onItemSelected!(item),
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

  List<SurveyEvidenceSyncItem> get _orderedItems {
    final queue = items.toList();
    queue.sort((left, right) {
      final priority = left.priority.compareTo(right.priority);
      if (priority != 0) {
        return priority;
      }

      return right.evidence.capturedAt.compareTo(left.evidence.capturedAt);
    });
    return queue;
  }

  bool _matchesFocus(SurveyEvidenceSyncItem item) {
    final questionId = focusedQuestionId;
    if (questionId == null) {
      return false;
    }

    return item.evidence.questionId == questionId ||
        item.requirement?.questionId == questionId;
  }

  String get _summaryLabel {
    if (items.isEmpty) {
      return 'No upload issue is attached to this response.';
    }

    final failed = items
        .where((item) => item.state == SurveyEvidenceSyncState.failed)
        .length;
    if (failed > 0) {
      return _plural(
        failed,
        'failed upload needs review',
        'failed uploads need review',
      );
    }

    final blocked = items
        .where((item) => item.state == SurveyEvidenceSyncState.blocked)
        .length;
    if (blocked > 0) {
      return _plural(blocked, 'upload is blocked', 'uploads are blocked');
    }

    final pending = items.where((item) => item.isPendingUpload).length;
    if (pending > 0) {
      return _plural(
        pending,
        'upload is waiting to sync',
        'uploads are waiting to sync',
      );
    }

    return _plural(
      items.length,
      'upload item is ready',
      'upload items are ready',
    );
  }

  static String _plural(int count, String singular, String plural) {
    return '$count ${count == 1 ? singular : plural}';
  }
}

/// Shows an empty state when an upload review intent has no sync item.
class _UploadReviewEmptyState extends StatelessWidget {
  const _UploadReviewEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.cloud_done_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No upload action is currently required for this response.',
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
}

/// Renders one evidence upload item with status, file, and next action copy.
class _UploadReviewTile extends StatelessWidget {
  final SurveyEvidenceSyncItem item;
  final bool highlighted;
  final SurveyEvidenceUploadReviewTaskAction? onQueueUpload;
  final SurveyEvidenceUploadReviewTaskAction? onRetryUpload;
  final SurveyEvidenceUploadReviewTaskAction? onFixEvidence;
  final SurveyEvidenceUploadReviewTaskAction? onMonitorUpload;
  final Set<String> activeUploadKeys;
  final VoidCallback? onSelected;

  const _UploadReviewTile({
    required this.item,
    required this.highlighted,
    required this.onQueueUpload,
    required this.onRetryUpload,
    required this.onFixEvidence,
    required this.onMonitorUpload,
    required this.activeUploadKeys,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _stateColor(colorScheme);
    final task = SurveyEvidenceUploadTask.fromSyncItem(item);
    final onTaskAction = _taskAction(task);
    final uploadActive = activeUploadKeys.contains(
      SurveyEvidenceUploadActivityTracker.keyFor(task),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted ? color : colorScheme.outlineVariant,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_stateIcon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _detailText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _UploadStateBadge(label: item.stateLabel, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _UploadReviewChip(
                  icon: Icons.insert_drive_file_outlined,
                  label: item.attachment.fileName,
                ),
                _UploadReviewChip(
                  icon: Icons.schedule_outlined,
                  label: _capturedAtLabel(context),
                ),
                if (item.requiresUpload)
                  const _UploadReviewChip(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Upload required',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _nextActionLabel(uploadActive: uploadActive),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (uploadActive || onTaskAction != null || onSelected != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (uploadActive || onTaskAction != null)
                    SurveyEvidenceUploadTaskActionButton(
                      task: task,
                      active: uploadActive,
                      onPressed: onTaskAction == null
                          ? null
                          : () => onTaskAction(task),
                    ),
                  if (onSelected != null)
                    TextButton.icon(
                      icon: const Icon(
                        Icons.center_focus_strong_outlined,
                        size: 18,
                      ),
                      label: Text(_selectionLabel),
                      onPressed: onSelected,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _detailText {
    final uploadError = item.attachment.uploadError;
    if (uploadError != null && uploadError.trim().isNotEmpty) {
      return uploadError.trim();
    }

    return item.detail;
  }

  String _nextActionLabel({required bool uploadActive}) {
    if (uploadActive) {
      return 'Upload is in progress. Actions are paused until this attempt finishes.';
    }

    switch (item.state) {
      case SurveyEvidenceSyncState.blocked:
        return 'Fix the evidence details before this item can upload.';
      case SurveyEvidenceSyncState.failed:
        return 'Retry from the evidence upload queue or capture a replacement.';
      case SurveyEvidenceSyncState.readyToUpload:
        return 'Ready to be queued for upload.';
      case SurveyEvidenceSyncState.queued:
        return 'Waiting in the upload queue.';
      case SurveyEvidenceSyncState.uploading:
        return 'Upload is already in progress.';
      case SurveyEvidenceSyncState.localOnly:
        return 'This evidence is allowed to remain local.';
      case SurveyEvidenceSyncState.uploaded:
        return 'Upload is complete.';
    }
  }

  String get _selectionLabel {
    final hasQuestion =
        item.evidence.questionId != null ||
        item.requirement?.questionId != null;
    return hasQuestion ? 'Focus question' : 'Review evidence';
  }

  SurveyEvidenceUploadReviewTaskAction? _taskAction(
    SurveyEvidenceUploadTask task,
  ) {
    switch (task.action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return onFixEvidence;
      case SurveyEvidenceUploadAction.retryUpload:
        return onRetryUpload;
      case SurveyEvidenceUploadAction.queueUpload:
        return onQueueUpload;
      case SurveyEvidenceUploadAction.monitorUpload:
        return onMonitorUpload;
      case SurveyEvidenceUploadAction.none:
        return null;
    }
  }

  String _capturedAtLabel(BuildContext context) {
    final capturedAt = item.evidence.capturedAt.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(capturedAt);
    final time = TimeOfDay.fromDateTime(capturedAt).format(context);
    return '$date $time';
  }

  IconData get _stateIcon {
    switch (item.state) {
      case SurveyEvidenceSyncState.blocked:
        return Icons.block_outlined;
      case SurveyEvidenceSyncState.failed:
        return Icons.cloud_off_outlined;
      case SurveyEvidenceSyncState.readyToUpload:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceSyncState.queued:
        return Icons.pending_actions_outlined;
      case SurveyEvidenceSyncState.uploading:
        return Icons.sync_outlined;
      case SurveyEvidenceSyncState.localOnly:
        return Icons.folder_outlined;
      case SurveyEvidenceSyncState.uploaded:
        return Icons.cloud_done_outlined;
    }
  }

  Color _stateColor(ColorScheme colorScheme) {
    switch (item.state) {
      case SurveyEvidenceSyncState.blocked:
      case SurveyEvidenceSyncState.failed:
        return colorScheme.error;
      case SurveyEvidenceSyncState.readyToUpload:
      case SurveyEvidenceSyncState.queued:
      case SurveyEvidenceSyncState.uploading:
        return colorScheme.tertiary;
      case SurveyEvidenceSyncState.localOnly:
        return colorScheme.onSurfaceVariant;
      case SurveyEvidenceSyncState.uploaded:
        return colorScheme.primary;
    }
  }
}

/// Displays a compact upload state label.
class _UploadStateBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _UploadStateBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

/// Displays one short upload metadata hint.
class _UploadReviewChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _UploadReviewChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 17, color: colorScheme.onSurfaceVariant),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
