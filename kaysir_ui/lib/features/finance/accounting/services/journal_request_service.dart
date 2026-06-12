import 'package:uuid/uuid.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../models/journal_approval.dart';
import '../models/journal_request_form.dart';

typedef JournalRequestClock = DateTime Function();
typedef JournalRequestIdGenerator = String Function();

/// Exception thrown when a journal request cannot be converted to approval work.
class JournalRequestException implements Exception {
  const JournalRequestException(this.issues);

  final List<String> issues;

  @override
  String toString() => 'JournalRequestException: ${issues.join(', ')}';
}

/// Validates journal form input and creates approval requests for review.
class JournalRequestService {
  JournalRequestService({
    JournalRequestClock? now,
    JournalRequestIdGenerator? nextId,
    this.tolerance = 0.01,
    this.evidenceThreshold = 25000000,
  }) : now = now ?? DateTime.now,
       nextId = nextId ?? const Uuid().v4;

  final JournalRequestClock now;
  final JournalRequestIdGenerator nextId;
  final double tolerance;
  final double evidenceThreshold;

  JournalRequestValidationResult validate(
    JournalRequestInput input,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final issues = <JournalRequestValidationIssue>[];
    final accountById = {
      for (final account in chartOfAccounts) account.id: account,
    };

    if (input.reference.trim().isEmpty) {
      issues.add(const JournalRequestValidationIssue('Reference is required.'));
    }
    if (input.description.trim().isEmpty) {
      issues.add(
        const JournalRequestValidationIssue('Description is required.'),
      );
    }
    if (input.preparerName.trim().isEmpty) {
      issues.add(const JournalRequestValidationIssue('Preparer is required.'));
    }
    if (input.reviewerName.trim().isEmpty) {
      issues.add(const JournalRequestValidationIssue('Reviewer is required.'));
    }
    if (input.preparerName.trim().toLowerCase() ==
            input.reviewerName.trim().toLowerCase() &&
        input.preparerName.trim().isNotEmpty) {
      issues.add(
        const JournalRequestValidationIssue(
          'Reviewer must be different from preparer.',
        ),
      );
    }
    if (input.lines.length < 2) {
      issues.add(
        const JournalRequestValidationIssue(
          'At least two journal lines are required.',
        ),
      );
    }

    for (var index = 0; index < input.lines.length; index++) {
      final line = input.lines[index];
      final account = accountById[line.accountId];
      final lineNumber = index + 1;
      if (!line.hasAccount || account == null) {
        issues.add(
          JournalRequestValidationIssue(
            'Line $lineNumber account is required.',
          ),
        );
      } else if (!account.isActive) {
        issues.add(
          JournalRequestValidationIssue(
            'Account is inactive: ${account.name}.',
          ),
        );
      } else if (!account.allowPosting) {
        issues.add(
          JournalRequestValidationIssue(
            'Account does not allow direct posting: ${account.name}.',
          ),
        );
      }

      if (line.amount <= 0) {
        issues.add(
          JournalRequestValidationIssue(
            'Line $lineNumber amount must be greater than zero.',
          ),
        );
      }
    }

    if (input.difference.abs() > tolerance) {
      issues.add(
        const JournalRequestValidationIssue('Debits and credits must balance.'),
      );
    }

    final evidenceRequired =
        input.source == JournalSource.periodClose ||
        input.debitTotal >= evidenceThreshold;
    if (evidenceRequired && (input.evidenceReference ?? '').trim().isEmpty) {
      issues.add(
        const JournalRequestValidationIssue(
          'Evidence reference is required for this journal.',
        ),
      );
    }

    return JournalRequestValidationResult(issues: List.unmodifiable(issues));
  }

  JournalApprovalRequest createApprovalRequest(
    JournalRequestInput input,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final validation = validate(input, chartOfAccounts);
    if (!validation.isValid) {
      throw JournalRequestException(
        validation.issues.map((issue) => issue.message).toList(),
      );
    }

    final accountById = {
      for (final account in chartOfAccounts) account.id: account,
    };
    final requestId = nextId();
    final submittedAt = now();
    final preparerName = input.preparerName.trim();

    return JournalApprovalRequest(
      id: 'approval-$requestId',
      draft: JournalDraft(
        id: 'je-$requestId',
        date: DateTime(submittedAt.year, submittedAt.month, submittedAt.day),
        reference: input.reference.trim(),
        description: input.description.trim(),
        source: input.source,
        lines: [
          for (final line in input.lines)
            JournalLineDraft(
              accountId: line.accountId!.trim(),
              accountName: accountById[line.accountId]!.name,
              side: line.side,
              amount: line.amount,
              memo: _trimmed(line.memo),
            ),
        ],
      ),
      preparerName: preparerName,
      reviewerName: input.reviewerName.trim(),
      status: JournalApprovalStatus.pendingReview,
      submittedAt: submittedAt,
      dueAt: submittedAt.add(const Duration(days: 1)),
      evidenceReference: _trimmed(input.evidenceReference),
      auditTrail: [
        JournalApprovalAuditEvent(
          id: 'approval-$requestId-audit-1',
          action: JournalApprovalAuditAction.submitted,
          actorName: preparerName,
          occurredAt: submittedAt,
          note: 'Submitted for reviewer approval.',
        ),
      ],
    );
  }
}

String? _trimmed(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  return trimmed;
}
