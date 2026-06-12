import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_period_close.dart';
import '../../models/financial_period_close_audit.dart';
import '../../repositories/financial_period_close_repository_provider.dart';
import '../../services/financial_period_close_audit_service.dart';
import 'financial_period_close_provider.dart';
import 'financial_provider.dart';

final financialPeriodCloseAuditServiceProvider =
    Provider<FinancialPeriodCloseAuditService>((ref) {
      return FinancialPeriodCloseAuditService();
    });

final financialPeriodCloseAuditProvider = StateNotifierProvider<
  FinancialPeriodCloseAuditNotifier,
  List<FinancialPeriodCloseAuditEvent>
>((ref) {
  return FinancialPeriodCloseAuditNotifier(
    repository: ref.watch(financialPeriodCloseRepositoryProvider),
    service: ref.watch(financialPeriodCloseAuditServiceProvider),
  );
});

final currentFinancialPeriodCloseAuditProvider =
    Provider<List<FinancialPeriodCloseAuditEvent>>((ref) {
      final period = ref.watch(selectedFinancialPeriodProvider);
      final closeService = ref.watch(financialPeriodCloseServiceProvider);
      final auditService = ref.watch(financialPeriodCloseAuditServiceProvider);
      final events = ref.watch(financialPeriodCloseAuditProvider);
      final key = closeService.periodKey(
        periodLabel: period.label,
        periodStart: period.startDate,
        periodEnd: period.endDate,
      );

      return auditService.newestFirst(
        events.where((event) => event.periodKey == key),
      );
    });

class FinancialPeriodCloseAuditNotifier
    extends StateNotifier<List<FinancialPeriodCloseAuditEvent>> {
  final FinancialPeriodCloseRepository repository;
  final FinancialPeriodCloseAuditService service;
  var _isDisposed = false;

  FinancialPeriodCloseAuditNotifier({
    required this.repository,
    required this.service,
  }) : super(repository.loadAuditEvents()) {
    unawaited(_hydrateFromRepository());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = this.repository;
    if (repository is! HydratableFinancialPeriodCloseRepository) {
      return;
    }

    await repository.hydrate();
    if (!_isDisposed) {
      state = repository.loadAuditEvents();
    }
  }

  FinancialPeriodCloseAuditEvent recordClosed(
    FinancialPeriodCloseRecord record,
  ) {
    final event = service.closed(record);
    repository.appendAuditEvent(event);
    state = repository.loadAuditEvents();
    return event;
  }

  FinancialPeriodCloseAuditEvent recordReopened(
    FinancialPeriodCloseRecord record,
  ) {
    final event = service.reopened(record);
    repository.appendAuditEvent(event);
    state = repository.loadAuditEvents();
    return event;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
