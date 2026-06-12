import 'package:uuid/uuid.dart';

import '../models/accounting_account.dart';
import '../models/journal_entry.dart';
import '../models/ledger_posting.dart';
import '../models/posting_validation.dart';

typedef AccountingClock = DateTime Function();
typedef AccountingIdGenerator = String Function();

class LedgerPostingException implements Exception {
  final List<String> issues;

  const LedgerPostingException(this.issues);

  @override
  String toString() => 'LedgerPostingException: ${issues.join(', ')}';
}

class LedgerPostingService {
  final AccountingClock now;
  final AccountingIdGenerator nextId;
  final double tolerance;

  LedgerPostingService({
    AccountingClock? now,
    AccountingIdGenerator? nextId,
    this.tolerance = 0.01,
  }) : now = now ?? DateTime.now,
       nextId = nextId ?? const Uuid().v4;

  PostingValidationResult validate(
    JournalDraft draft,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final issues = <String>[];
    final accountById = {
      for (final account in chartOfAccounts) account.id: account,
    };

    if (draft.reference.trim().isEmpty) {
      issues.add('Reference is required');
    }
    if (draft.description.trim().isEmpty) {
      issues.add('Description is required');
    }
    if (draft.lines.length < 2) {
      issues.add('At least two journal lines are required');
    }

    for (final line in draft.lines) {
      final account = accountById[line.accountId];
      if (account == null) {
        issues.add('Account not found: ${line.accountName}');
      } else if (!account.isActive) {
        issues.add('Account is inactive: ${account.name}');
      }

      if (line.amount <= 0) {
        issues.add('Amount must be greater than zero for ${line.accountName}');
      }
    }

    final difference = (draft.debitTotal - draft.creditTotal).abs();
    if (difference > tolerance) {
      issues.add('Debits and credits must balance');
    }

    return PostingValidationResult(
      debitTotal: draft.debitTotal,
      creditTotal: draft.creditTotal,
      issues: issues,
    );
  }

  LedgerPosting post(
    JournalDraft draft,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final validation = validate(draft, chartOfAccounts);
    if (!validation.isValid) {
      throw LedgerPostingException(validation.issues);
    }

    final postingId = nextId();
    return LedgerPosting(
      id: postingId,
      journalId: draft.id,
      entryDate: draft.date,
      postedAt: now(),
      reference: draft.reference.trim(),
      description: draft.description.trim(),
      source: draft.source,
      lines: [
        for (var index = 0; index < draft.lines.length; index++)
          LedgerPostingLine(
            id: '$postingId-${index + 1}',
            accountId: draft.lines[index].accountId,
            accountName: draft.lines[index].accountName,
            side: draft.lines[index].side,
            amount: draft.lines[index].amount,
            memo: draft.lines[index].memo,
          ),
      ],
    );
  }
}
