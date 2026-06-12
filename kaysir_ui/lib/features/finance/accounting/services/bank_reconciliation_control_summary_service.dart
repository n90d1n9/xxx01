import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_resolution.dart';

class BankReconciliationControlSummaryService {
  final int staleThresholdDays;

  const BankReconciliationControlSummaryService({this.staleThresholdDays = 30});

  BankReconciliationControlSummary summarize({
    required BankReconciliation reconciliation,
    required BankReconciliationResolutionPlan resolutionPlan,
    required DateTime asOfDate,
  }) {
    final oldest = _oldestUnmatchedItem(reconciliation, asOfDate);
    final severity = _severityFor(reconciliation, resolutionPlan);

    return BankReconciliationControlSummary(
      severity: severity,
      nextAction: _nextActionFor(severity, resolutionPlan),
      statementLineCount: reconciliation.statementLines.length,
      matchedCount: reconciliation.matches.length,
      unmatchedStatementCount: reconciliation.unmatchedStatementLines.length,
      unmatchedLedgerCount: reconciliation.unmatchedLedgerLines.length,
      suggestedJournalCount: resolutionPlan.suggestedJournalCount,
      timingDifferenceCount: resolutionPlan.timingDifferenceCount,
      staleThresholdDays: staleThresholdDays,
      timingAging: _timingAging(resolutionPlan, asOfDate),
      oldestUnmatchedAgeDays: oldest?.ageDays,
      oldestUnmatchedDate: oldest?.date,
      oldestUnmatchedReference: oldest?.reference,
    );
  }

  BankReconciliationControlSeverity _severityFor(
    BankReconciliation reconciliation,
    BankReconciliationResolutionPlan resolutionPlan,
  ) {
    if (!reconciliation.hasStatementEvidence) {
      return BankReconciliationControlSeverity.needsEvidence;
    }
    if (reconciliation.isBalanced) {
      return BankReconciliationControlSeverity.ready;
    }
    if (resolutionPlan.suggestedJournalCount > 0) {
      return BankReconciliationControlSeverity.postAdjustments;
    }
    if (resolutionPlan.timingDifferenceCount > 0) {
      return BankReconciliationControlSeverity.timingReview;
    }
    return BankReconciliationControlSeverity.investigate;
  }

  String _nextActionFor(
    BankReconciliationControlSeverity severity,
    BankReconciliationResolutionPlan resolutionPlan,
  ) {
    switch (severity) {
      case BankReconciliationControlSeverity.needsEvidence:
        return 'Import or add bank statement lines for this close period.';
      case BankReconciliationControlSeverity.ready:
        return 'Bank statement evidence is matched and ready for close.';
      case BankReconciliationControlSeverity.postAdjustments:
        final count = resolutionPlan.suggestedJournalCount;
        return 'Post or review $count suggested bank adjustment journal(s).';
      case BankReconciliationControlSeverity.timingReview:
        final count = resolutionPlan.timingDifferenceCount;
        return 'Confirm $count timing difference(s) clear on a later statement.';
      case BankReconciliationControlSeverity.investigate:
        return 'Investigate the remaining bank variance before close.';
    }
  }

  _OldestUnmatchedItem? _oldestUnmatchedItem(
    BankReconciliation reconciliation,
    DateTime asOfDate,
  ) {
    final items = [
      for (final line in reconciliation.unmatchedStatementLines)
        _UnmatchedItem(date: line.date, reference: line.reference ?? line.id),
      for (final line in reconciliation.unmatchedLedgerLines)
        _UnmatchedItem(
          date: line.date,
          reference:
              line.reference.isEmpty ? line.transactionId : line.reference,
        ),
    ];
    if (items.isEmpty) {
      return null;
    }

    items.sort((left, right) => left.date.compareTo(right.date));
    final oldest = items.first;
    final ageDays = asOfDate.difference(oldest.date).inDays;
    return _OldestUnmatchedItem(
      date: oldest.date,
      reference: oldest.reference,
      ageDays: ageDays < 0 ? 0 : ageDays,
    );
  }

  BankReconciliationTimingAgingSummary _timingAging(
    BankReconciliationResolutionPlan resolutionPlan,
    DateTime asOfDate,
  ) {
    var currentCount = 0;
    var watchCount = 0;
    var staleCount = 0;
    var currentAmount = 0.0;
    var watchAmount = 0.0;
    var staleAmount = 0.0;
    final watchThresholdDays =
        staleThresholdDays > 7 ? staleThresholdDays - 7 : 0;

    for (final action in resolutionPlan.actions) {
      if (action.suggestsJournal) {
        continue;
      }
      final rawAgeDays = asOfDate.difference(action.date).inDays;
      final ageDays = rawAgeDays < 0 ? 0 : rawAgeDays;
      final amount = action.amount.abs();
      if (ageDays >= staleThresholdDays) {
        staleCount += 1;
        staleAmount += amount;
      } else if (ageDays >= watchThresholdDays) {
        watchCount += 1;
        watchAmount += amount;
      } else {
        currentCount += 1;
        currentAmount += amount;
      }
    }

    return BankReconciliationTimingAgingSummary(
      currentCount: currentCount,
      watchCount: watchCount,
      staleCount: staleCount,
      currentAmount: currentAmount,
      watchAmount: watchAmount,
      staleAmount: staleAmount,
    );
  }
}

class _UnmatchedItem {
  final DateTime date;
  final String reference;

  const _UnmatchedItem({required this.date, required this.reference});
}

class _OldestUnmatchedItem {
  final DateTime date;
  final String reference;
  final int ageDays;

  const _OldestUnmatchedItem({
    required this.date,
    required this.reference,
    required this.ageDays,
  });
}
