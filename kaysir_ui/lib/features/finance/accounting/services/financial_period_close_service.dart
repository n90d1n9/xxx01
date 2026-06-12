import 'package:intl/intl.dart';

import '../models/financial_close_checklist.dart';
import '../models/financial_period_close.dart';

class FinancialPeriodCloseService {
  const FinancialPeriodCloseService();

  String periodKey({
    required String periodLabel,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    if (periodStart == null || periodEnd == null) {
      return _slug(periodLabel);
    }
    final formatter = DateFormat('yyyyMMdd');
    return '${formatter.format(periodStart)}-${formatter.format(periodEnd)}';
  }

  FinancialPeriodCloseRecord closePeriod({
    required FinancialCloseChecklist checklist,
    required String periodLabel,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? closedAt,
    String closedBy = 'Current user',
    String? reportPackageHash,
    String? reportPackageHashAlgorithm,
    String? closingEntryPostingId,
    String? closingEntryReference,
    DateTime? closingEntryPostedAt,
  }) {
    if (checklist.hasBlockers) {
      throw StateError(
        'Cannot close ${checklist.periodLabel}; ${checklist.blockedCount} blocker(s) remain.',
      );
    }

    final now = closedAt ?? DateTime.now();
    return FinancialPeriodCloseRecord(
      periodKey: periodKey(
        periodLabel: periodLabel,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
      periodLabel: periodLabel,
      periodStart: periodStart,
      periodEnd: periodEnd,
      status: FinancialPeriodCloseStatus.closed,
      closedAt: now,
      closedBy: closedBy,
      reopenedAt: null,
      reopenedBy: null,
      reopenReason: null,
      checklistReadinessRatio: checklist.readinessRatio,
      blockerCount: checklist.blockedCount,
      reportGeneratedAt: checklist.generatedAt,
      reportPackageHash: reportPackageHash,
      reportPackageHashAlgorithm: reportPackageHashAlgorithm,
      closingEntryPostingId: closingEntryPostingId,
      closingEntryReference: closingEntryReference,
      closingEntryPostedAt: closingEntryPostedAt,
    );
  }

  FinancialPeriodCloseRecord reopenPeriod({
    required FinancialPeriodCloseRecord record,
    required String reason,
    DateTime? reopenedAt,
    String reopenedBy = 'Current user',
  }) {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError('Reopen reason is required');
    }
    if (!record.isClosed) {
      throw StateError('Only closed periods can be reopened');
    }

    return record.copyWith(
      status: FinancialPeriodCloseStatus.reopened,
      reopenedAt: reopenedAt ?? DateTime.now(),
      reopenedBy: reopenedBy,
      reopenReason: normalizedReason,
    );
  }

  String _slug(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'period' : normalized;
  }
}
