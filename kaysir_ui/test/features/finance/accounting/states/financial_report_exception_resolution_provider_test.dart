import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_exception_resolution_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_exception_resolution_provider.dart';

void main() {
  group('Financial report exception resolution provider', () {
    test('stores exception resolutions by selected period', () {
      final repository = InMemoryFinancialReportExceptionResolutionRepository();
      final container = ProviderContainer(
        overrides: [
          financialReportExceptionResolutionRepositoryProvider
              .overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(selectedFinancialPeriodProvider.notifier)
          .state = FinancialStatementPeriod(
        preset: FinancialPeriodPreset.custom,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );

      final januaryKey = container.read(
        currentFinancialReportExceptionResolutionPeriodKeyProvider,
      );
      final januaryResolution = FinancialReportExceptionResolution(
        exceptionId: 'equity-roll-forward-material',
        status: FinancialReportExceptionResolutionStatus.approved,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 11),
        note: 'Approved with supporting schedule.',
        adjustmentReference: 'REV-001',
      );

      container
          .read(financialReportExceptionResolutionProvider.notifier)
          .upsertResolution(
            periodKey: januaryKey,
            resolution: januaryResolution,
          );

      expect(
        container.read(currentFinancialReportExceptionResolutionsProvider),
        [januaryResolution],
      );

      container
          .read(selectedFinancialPeriodProvider.notifier)
          .state = FinancialStatementPeriod(
        preset: FinancialPeriodPreset.custom,
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      expect(
        container.read(currentFinancialReportExceptionResolutionsProvider),
        [],
      );
      expect(repository.loadResolutions()[januaryKey], [januaryResolution]);
    });

    test('replaces existing evidence for the same exception', () {
      final repository = InMemoryFinancialReportExceptionResolutionRepository();
      final notifier = FinancialReportExceptionResolutionNotifier(
        repository: repository,
      );
      addTearDown(notifier.dispose);

      final approved = FinancialReportExceptionResolution(
        exceptionId: 'cash-reconciliation-blocking',
        status: FinancialReportExceptionResolutionStatus.approved,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 10),
        note: 'Initial approval.',
      );
      final adjusted = FinancialReportExceptionResolution(
        exceptionId: 'cash-reconciliation-blocking',
        status: FinancialReportExceptionResolutionStatus.adjusted,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 12),
        note: 'Adjustment posted.',
        adjustmentReference: 'ADJ-009',
      );

      notifier.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: approved,
      );
      notifier.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: adjusted,
      );

      expect(notifier.state['20260101-20260131'], [adjusted]);
      expect(
        repository.loadResolutions()['20260101-20260131']?.single.status,
        FinancialReportExceptionResolutionStatus.adjusted,
      );
    });
  });
}
