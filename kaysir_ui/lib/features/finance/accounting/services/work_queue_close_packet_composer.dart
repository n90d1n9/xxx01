import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/work_queue_close_packet_evidence_summary.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_summary.dart';

/// Builds an audit-ready close packet from the current work queue resolution view.
class AccountingWorkspaceWorkQueueClosePacketComposer {
  const AccountingWorkspaceWorkQueueClosePacketComposer();

  String compose({
    required AccountingWorkspaceWorkQueueResolutionSummary summary,
    required AccountingWorkspaceWorkQueueResolutionFilter filter,
    required AccountingWorkspaceRolePreset rolePreset,
    required AccountingMenuSearchScope scope,
    required String query,
    required DateTime generatedAt,
    AccountingWorkspaceWorkQueueResolutionNextAction? nextAction,
    Iterable<AccountingWorkspaceWorkQueueResolutionBriefItem> briefItems =
        const [],
    Iterable<AccountingWorkspaceWorkQueueEvidenceReadiness> evidenceReadiness =
        const [],
    Map<String, String> evidenceQueueTitlesById = const {},
    int evidenceAttentionLimit = 5,
  }) {
    final normalizedQuery = query.trim();
    final rankedItems = briefItems.toList();
    final evidenceItems = evidenceReadiness.toList();
    final evidenceSummary =
        AccountingWorkspaceWorkQueueClosePacketEvidenceSummary.fromReadiness(
          evidenceItems,
        );
    final evidenceAttentionItems = _evidenceAttentionItems(
      evidenceItems,
      limit: evidenceAttentionLimit,
    );
    final effectiveNextAction = nextAction ?? summary.nextAction;

    return [
      'Accounting close packet',
      'Generated: ${_formatTimestamp(generatedAt)}',
      'Role: ${rolePreset.label}',
      'Scope: ${scope.label}',
      if (normalizedQuery.isNotEmpty) 'Search: $normalizedQuery',
      'Resolution view: ${filter.label}',
      '',
      'Status: ${summary.statusLabel}',
      'Clearance score: ${summary.clearanceScoreLabel}',
      'Queue coverage: ${summary.clearedQueueCount} cleared | '
          '${summary.readyToClearQueueCount} ready | '
          '${summary.blockedQueueCount} blocked | '
          '${summary.waitingQueueCount} waiting',
      'Open queues: ${summary.openQueueCount}',
      'Control note: Clearance is gated by accepted evidence, reviewer sign-off, '
          'and open checklist blockers.',
      '',
      'Evidence posture',
      if (!evidenceSummary.hasQueues)
        'No evidence readiness captured for this packet.'
      else ...[
        'Status: ${evidenceSummary.statusLabel}',
        'Accepted support: ${evidenceSummary.coverageLabel}',
        'Queues: ${evidenceSummary.queueBreakdownLabel}',
        'Evidence links: ${evidenceSummary.linkReviewLabel}',
        if (evidenceAttentionItems.isEmpty)
          'Evidence attention: none'
        else ...[
          'Evidence attention:',
          for (final readiness in evidenceAttentionItems)
            '- ${_evidenceQueueTitle(readiness, evidenceQueueTitlesById)} - '
                '${readiness.statusLabel} - ${readiness.coverageLabel} - '
                '${readiness.nextActionLabel}',
        ],
      ],
      '',
      'Next action',
      if (effectiveNextAction == null)
        'No active ${filter.label.toLowerCase()} review action.'
      else ...[
        effectiveNextAction.title,
        'Status: ${effectiveNextAction.statusLabel}',
        'Action: ${effectiveNextAction.actionLabel}',
        'Owner: ${effectiveNextAction.ownerLabel}',
        'Due: ${effectiveNextAction.dueLabel}',
      ],
      '',
      'Priority queues',
      if (rankedItems.isEmpty)
        'No queues in this packet.'
      else
        for (final item in rankedItems) item.briefLabel,
      '',
      'Review brief',
      filter.resolutionBriefFor(
        summary: summary,
        nextAction: effectiveNextAction,
        briefItems: rankedItems,
      ),
    ].join('\n');
  }
}

List<AccountingWorkspaceWorkQueueEvidenceReadiness> _evidenceAttentionItems(
  Iterable<AccountingWorkspaceWorkQueueEvidenceReadiness> items, {
  required int limit,
}) {
  if (limit <= 0) return const [];

  final attentionItems = [
    for (final item in items)
      if (item.status !=
          AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready)
        item,
  ]..sort(_compareEvidenceReadiness);

  return List<AccountingWorkspaceWorkQueueEvidenceReadiness>.unmodifiable(
    attentionItems.take(limit),
  );
}

int _compareEvidenceReadiness(
  AccountingWorkspaceWorkQueueEvidenceReadiness a,
  AccountingWorkspaceWorkQueueEvidenceReadiness b,
) {
  final statusComparison = _evidenceStatusPriority(
    a.status,
  ).compareTo(_evidenceStatusPriority(b.status));
  if (statusComparison != 0) return statusComparison;

  final remainingComparison = b.remainingItemCount.compareTo(
    a.remainingItemCount,
  );
  if (remainingComparison != 0) return remainingComparison;

  final reviewComparison = (b.pendingReviewCount + b.reworkEvidenceCount)
      .compareTo(a.pendingReviewCount + a.reworkEvidenceCount);
  if (reviewComparison != 0) return reviewComparison;

  return a.queueId.compareTo(b.queueId);
}

int _evidenceStatusPriority(
  AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
) {
  switch (status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return 0;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
      return 1;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
      return 2;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return 3;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return 4;
  }
}

String _evidenceQueueTitle(
  AccountingWorkspaceWorkQueueEvidenceReadiness readiness,
  Map<String, String> titlesById,
) {
  final title = titlesById[readiness.queueId]?.trim();
  if (title != null && title.isNotEmpty) return title;

  return readiness.queueId;
}

String _formatTimestamp(DateTime value) {
  final local = value.toLocal();
  return '${_twoDigits(local.year ~/ 100)}${_twoDigits(local.year % 100)}-'
      '${_twoDigits(local.month)}-${_twoDigits(local.day)} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
