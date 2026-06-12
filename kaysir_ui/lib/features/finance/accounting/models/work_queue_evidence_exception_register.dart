import 'accounting_workspace_work_queue.dart';
import 'work_queue_evidence_readiness.dart';

/// Actionable evidence exception for a single accounting work queue.
class AccountingWorkspaceWorkQueueEvidenceException {
  const AccountingWorkspaceWorkQueueEvidenceException({
    required this.queueId,
    required this.title,
    required this.ownerLabel,
    required this.dueLabel,
    required this.severity,
    required this.slaStatus,
    required this.status,
    required this.coverageLabel,
    required this.nextActionLabel,
    required this.pendingReviewCount,
    required this.reworkEvidenceCount,
    required this.remainingItemCount,
  });

  final String queueId;
  final String title;
  final String ownerLabel;
  final String dueLabel;
  final AccountingWorkspaceWorkQueueSeverity severity;
  final AccountingWorkspaceWorkQueueSlaStatus slaStatus;
  final AccountingWorkspaceWorkQueueEvidenceReadinessStatus status;
  final String coverageLabel;
  final String nextActionLabel;
  final int pendingReviewCount;
  final int reworkEvidenceCount;
  final int remainingItemCount;

  String get statusLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
        return 'Missing';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
        return 'Review';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
        return 'Rework';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
        return 'Partial';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
        return 'Ready';
    }
  }

  bool get blocksClearance {
    return status ==
            AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing ||
        status == AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework;
  }

  String get metricLabel {
    final parts = [
      coverageLabel,
      if (pendingReviewCount > 0) '$pendingReviewCount pending',
      if (reworkEvidenceCount > 0) '$reworkEvidenceCount rework',
      if (remainingItemCount > 0) '$remainingItemCount remaining',
    ];

    return parts.join(' · ');
  }

  String get briefLabel {
    return '$title - $statusLabel - $metricLabel - $ownerLabel - '
        '$dueLabel - $nextActionLabel';
  }
}

/// Owner-level handoff summary for evidence exceptions in the active view.
class AccountingWorkspaceWorkQueueEvidenceOwnerHandoff {
  const AccountingWorkspaceWorkQueueEvidenceOwnerHandoff({
    required this.ownerLabel,
    required this.exceptionCount,
    required this.blockerCount,
    required this.reviewCount,
  });

  final String ownerLabel;
  final int exceptionCount;
  final int blockerCount;
  final int reviewCount;

  String get displayLabel {
    final parts = [
      ownerLabel,
      exceptionCount == 1 ? '1 open' : '$exceptionCount open',
      if (blockerCount > 0)
        blockerCount == 1 ? '1 blocker' : '$blockerCount blockers',
      if (reviewCount > 0)
        reviewCount == 1 ? '1 review' : '$reviewCount reviews',
    ];

    return parts.join(' · ');
  }

  String get briefLabel {
    return '$ownerLabel - $exceptionCount open - $blockerCount blocker(s) - '
        '$reviewCount review item(s)';
  }
}

/// Sorted evidence exception register for the active accounting work queue view.
class AccountingWorkspaceWorkQueueEvidenceExceptionRegister {
  AccountingWorkspaceWorkQueueEvidenceExceptionRegister({
    required Iterable<AccountingWorkspaceWorkQueueEvidenceException> items,
  }) : items = List<AccountingWorkspaceWorkQueueEvidenceException>.unmodifiable(
         items,
       ),
       ownerHandoffs = _ownerHandoffsFor(items);

  final List<AccountingWorkspaceWorkQueueEvidenceException> items;
  final List<AccountingWorkspaceWorkQueueEvidenceOwnerHandoff> ownerHandoffs;

  bool get hasExceptions => items.isNotEmpty;

  int get exceptionCount => items.length;

  int get blockerCount {
    return items.where((item) => item.blocksClearance).length;
  }

  int get reviewCount {
    return items
        .where(
          (item) =>
              item.status ==
              AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded,
        )
        .length;
  }

  String get statusLabel {
    if (!hasExceptions) return 'Evidence clear';
    if (blockerCount > 0) return '$blockerCount blocker(s)';

    return '$exceptionCount review item(s)';
  }

  String get exceptionBrief {
    final lines = [
      'Evidence exception register: $statusLabel',
      'Exceptions: $exceptionCount open | $blockerCount blocker(s) | '
          '$reviewCount review item(s)',
      if (ownerHandoffs.isNotEmpty) ...[
        'Owner handoff:',
        for (final handoff in ownerHandoffs) '- ${handoff.briefLabel}',
      ],
      if (items.isEmpty)
        'Review queues: none'
      else ...[
        'Review queues:',
        for (var index = 0; index < items.length; index++)
          '${index + 1}. ${items[index].briefLabel}',
      ],
    ];

    return lines.join('\n');
  }
}

List<AccountingWorkspaceWorkQueueEvidenceOwnerHandoff> _ownerHandoffsFor(
  Iterable<AccountingWorkspaceWorkQueueEvidenceException> items,
) {
  final ownerCounts = <String, _OwnerEvidenceCounts>{};
  for (final item in items) {
    final ownerLabel =
        item.ownerLabel.trim().isEmpty ? 'Unassigned' : item.ownerLabel;
    ownerCounts.putIfAbsent(ownerLabel, _OwnerEvidenceCounts.new).add(item);
  }

  final handoffs = [
    for (final entry in ownerCounts.entries)
      AccountingWorkspaceWorkQueueEvidenceOwnerHandoff(
        ownerLabel: entry.key,
        exceptionCount: entry.value.exceptionCount,
        blockerCount: entry.value.blockerCount,
        reviewCount: entry.value.reviewCount,
      ),
  ]..sort(_compareOwnerHandoffs);

  return List<AccountingWorkspaceWorkQueueEvidenceOwnerHandoff>.unmodifiable(
    handoffs,
  );
}

int _compareOwnerHandoffs(
  AccountingWorkspaceWorkQueueEvidenceOwnerHandoff left,
  AccountingWorkspaceWorkQueueEvidenceOwnerHandoff right,
) {
  final blockerComparison = right.blockerCount.compareTo(left.blockerCount);
  if (blockerComparison != 0) return blockerComparison;

  final countComparison = right.exceptionCount.compareTo(left.exceptionCount);
  if (countComparison != 0) return countComparison;

  return left.ownerLabel.compareTo(right.ownerLabel);
}

class _OwnerEvidenceCounts {
  var exceptionCount = 0;
  var blockerCount = 0;
  var reviewCount = 0;

  void add(AccountingWorkspaceWorkQueueEvidenceException item) {
    exceptionCount += 1;
    if (item.blocksClearance) blockerCount += 1;
    if (item.status ==
        AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded) {
      reviewCount += 1;
    }
  }
}
