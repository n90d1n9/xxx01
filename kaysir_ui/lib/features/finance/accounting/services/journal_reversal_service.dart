import 'package:uuid/uuid.dart';

import '../accounting_core/models/journal_entry.dart';
import '../models/journal_approval.dart';

typedef JournalReversalClock = DateTime Function();
typedef JournalReversalIdGenerator = String Function();

/// Exception raised when a posted journal cannot produce a reversal request.
class JournalReversalException implements Exception {
  const JournalReversalException(this.issues);

  final List<String> issues;

  @override
  String toString() => 'JournalReversalException: ${issues.join(', ')}';
}

/// Builds reversing approval requests from already-posted journals.
class JournalReversalService {
  JournalReversalService({
    JournalReversalClock? now,
    JournalReversalIdGenerator? nextId,
  }) : now = now ?? DateTime.now,
       nextId = nextId ?? const Uuid().v4;

  final JournalReversalClock now;
  final JournalReversalIdGenerator nextId;

  JournalApprovalRequest createReversalRequest({
    required JournalApprovalRequest original,
    required DateTime reversalDate,
    String? preparerName,
    String? reviewerName,
  }) {
    final effectiveReversalDate = _dateOnly(reversalDate);
    final issues = _validate(original, effectiveReversalDate);
    if (issues.isNotEmpty) {
      throw JournalReversalException(issues);
    }

    final requestId = nextId();
    final submittedAt = now();
    final effectivePreparer =
        _trimmed(preparerName) ?? original.preparerName.trim();
    final effectiveReviewer =
        _trimmed(reviewerName) ?? original.reviewerName.trim();

    return JournalApprovalRequest(
      id: 'approval-reversal-$requestId',
      draft: JournalDraft(
        id: 'je-reversal-$requestId',
        date: effectiveReversalDate,
        reference: '${original.draft.reference}-REV',
        description:
            'Reverse ${original.draft.reference}: ${original.draft.description}',
        source: original.draft.source,
        lines: [
          for (final line in original.draft.lines)
            JournalLineDraft(
              accountId: line.accountId,
              accountName: line.accountName,
              side: _oppositeSide(line.side),
              amount: line.amount,
              memo: _reversalMemo(original, line),
            ),
        ],
      ),
      preparerName: effectivePreparer,
      reviewerName: effectiveReviewer,
      status: JournalApprovalStatus.pendingReview,
      submittedAt: submittedAt,
      dueAt: submittedAt.add(const Duration(days: 1)),
      evidenceReference: original.evidenceReference,
      reversalDate: effectiveReversalDate,
      auditTrail: [
        JournalApprovalAuditEvent(
          id: 'approval-reversal-$requestId-audit-1',
          action: JournalApprovalAuditAction.submitted,
          actorName: effectivePreparer,
          occurredAt: submittedAt,
          note: 'Submitted as reversal for ${original.draft.reference}.',
        ),
      ],
    );
  }

  List<String> _validate(
    JournalApprovalRequest original,
    DateTime reversalDate,
  ) {
    final issues = <String>[];
    if (original.status != JournalApprovalStatus.posted) {
      issues.add('Only posted journals can be reversed.');
    }
    if (original.reversalRequested) {
      issues.add('A reversal request already exists for this journal.');
    }
    if (reversalDate.isBefore(_dateOnly(original.draft.date))) {
      issues.add('Reversal date cannot be before the original journal date.');
    }
    if (original.draft.lines.length < 2) {
      issues.add('Original journal must have at least two lines.');
    }

    return issues;
  }
}

JournalSide _oppositeSide(JournalSide side) {
  return switch (side) {
    JournalSide.debit => JournalSide.credit,
    JournalSide.credit => JournalSide.debit,
  };
}

String _reversalMemo(JournalApprovalRequest original, JournalLineDraft line) {
  final memo = line.memo?.trim();
  if (memo == null || memo.isEmpty) {
    return 'Reversal of ${original.draft.reference}';
  }

  return 'Reversal of ${original.draft.reference}: $memo';
}

String? _trimmed(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  return trimmed;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
