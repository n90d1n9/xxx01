import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/financial_period_close.dart';
import '../services/financial_period_posting_guard_service.dart';
import 'fin_statement/financial_period_close_provider.dart';

final financialPeriodPostingGuardServiceProvider =
    Provider<FinancialPeriodPostingGuardService>((ref) {
      return const FinancialPeriodPostingGuardService();
    });

final financialPeriodPostingGuardProvider =
    Provider<FinancialPeriodPostingGuard>((ref) {
      return FinancialPeriodPostingGuard(
        service: ref.watch(financialPeriodPostingGuardServiceProvider),
        records: ref.watch(financialPeriodCloseRecordsProvider).values,
      );
    });

class FinancialPeriodPostingGuard {
  final FinancialPeriodPostingGuardService service;
  final Iterable<FinancialPeriodCloseRecord> records;

  const FinancialPeriodPostingGuard({
    required this.service,
    required this.records,
  });

  FinancialPeriodCloseRecord? closedRecordForDate(DateTime entryDate) {
    return service.closedRecordForDate(entryDate: entryDate, records: records);
  }

  void ensureDateIsOpen(DateTime entryDate, {required String actionLabel}) {
    service.ensureDateIsOpen(
      entryDate: entryDate,
      records: records,
      actionLabel: actionLabel,
    );
  }
}
