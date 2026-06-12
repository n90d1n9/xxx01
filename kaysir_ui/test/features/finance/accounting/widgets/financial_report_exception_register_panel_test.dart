import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_review_exception.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_exception_register_panel.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('FinancialReportExceptionRegisterPanel', () {
    testWidgets('shows clear state when there are no exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_pack(const [])));

      expect(find.text('Report Exception Register'), findsOneWidget);
      expect(find.text('No unresolved report exceptions'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('shows material exception evidence and close blocker status', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _pack(const [
            FinancialReportComplianceItem(
              id: 'equity-roll-forward',
              title: 'Equity roll-forward reconciles',
              description:
                  'Opening equity plus movements equals ending equity.',
              standardReference: 'PSAK 201',
              isSatisfied: false,
              variance: 125,
              comparativeVariance: -10,
              materialityThreshold: 44,
              materialityBasis: '1% of total assets',
            ),
          ]),
        ),
      );

      expect(find.text('Material'), findsOneWidget);
      expect(find.text('Blocks close'), findsOneWidget);
      expect(find.text('Equity roll-forward reconciles'), findsOneWidget);
      expect(find.textContaining('Current IDR'), findsOneWidget);
      expect(find.textContaining('1% of total assets'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsWidgets);
    });

    testWidgets('shows approved resolution evidence', (tester) async {
      await tester.pumpWidget(
        _host(
          _pack(const [
            FinancialReportComplianceItem(
              id: 'equity-roll-forward',
              title: 'Equity roll-forward reconciles',
              description:
                  'Opening equity plus movements equals ending equity.',
              standardReference: 'PSAK 201',
              isSatisfied: false,
              variance: 125,
              materialityThreshold: 44,
            ),
          ]),
          resolutions: [
            FinancialReportExceptionResolution(
              exceptionId: 'equity-roll-forward-material',
              status: FinancialReportExceptionResolutionStatus.approved,
              reviewer: 'Controller',
              resolvedAt: DateTime(2026, 2, 1, 11),
              note: 'Approved with supporting schedule.',
              adjustmentReference: 'REV-001',
            ),
          ],
        ),
      );

      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Blocks close'), findsNothing);
      expect(find.textContaining('Approved by Controller'), findsOneWidget);
      expect(find.textContaining('REV-001'), findsOneWidget);
      expect(find.text('Feb 1, 2026 11:00'), findsOneWidget);
      expect(find.text('Approved with supporting schedule.'), findsOneWidget);
    });

    testWidgets('emits resolution actions for unresolved exceptions', (
      tester,
    ) async {
      FinancialReportReviewException? selectedException;
      FinancialReportExceptionResolutionStatus? selectedStatus;

      await tester.pumpWidget(
        _host(
          _pack(const [
            FinancialReportComplianceItem(
              id: 'equity-roll-forward',
              title: 'Equity roll-forward reconciles',
              description:
                  'Opening equity plus movements equals ending equity.',
              standardReference: 'PSAK 201',
              isSatisfied: false,
              variance: 125,
              materialityThreshold: 44,
            ),
          ]),
          onResolveException: (exception, status) {
            selectedException = exception;
            selectedStatus = status;
          },
        ),
      );

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Record adjustment'), findsOneWidget);
      expect(find.text('Defer'), findsOneWidget);

      await tester.tap(find.text('Approve'));
      await tester.pump();

      expect(selectedException?.id, 'equity-roll-forward-material');
      expect(selectedStatus, FinancialReportExceptionResolutionStatus.approved);
    });

    testWidgets('emits adjusted resolution action for posting evidence', (
      tester,
    ) async {
      FinancialReportExceptionResolutionStatus? selectedStatus;

      await tester.pumpWidget(
        _host(
          _pack(const [
            FinancialReportComplianceItem(
              id: 'cash-reconciliation',
              title: 'Cash flow reconciles to cash ledger',
              description: 'Ending cash agrees to the cash ledger balance.',
              standardReference: 'PSAK 207',
              isSatisfied: false,
              variance: 75,
            ),
          ]),
          onResolveException: (_, status) {
            selectedStatus = status;
          },
        ),
      );

      await tester.tap(find.text('Record adjustment'));
      await tester.pump();

      expect(selectedStatus, FinancialReportExceptionResolutionStatus.adjusted);
    });

    testWidgets('locks resolution actions when the period is closed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          _pack(const [
            FinancialReportComplianceItem(
              id: 'cash-reconciliation',
              title: 'Cash flow reconciles to cash ledger',
              description: 'Ending cash agrees to the cash ledger balance.',
              standardReference: 'PSAK 207',
              isSatisfied: false,
              variance: 75,
            ),
          ]),
          resolutionActionLockedReason:
              'Period closed - reopen to change exception evidence.',
        ),
      );

      expect(find.text('Approve'), findsNothing);
      expect(find.text('Record adjustment'), findsNothing);
      expect(find.text('Defer'), findsNothing);
      expect(
        find.text('Period closed - reopen to change exception evidence.'),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportTintedSurface), findsWidgets);
    });
  });
}

Widget _host(
  FinancialReportPack pack, {
  List<FinancialReportExceptionResolution> resolutions = const [],
  void Function(
    FinancialReportReviewException exception,
    FinancialReportExceptionResolutionStatus status,
  )?
  onResolveException,
  String? resolutionActionLockedReason,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: FinancialReportExceptionRegisterPanel(
          pack: pack,
          exceptionResolutions: resolutions,
          onResolveException: onResolveException,
          resolutionActionLockedReason: resolutionActionLockedReason,
          isDarkMode: false,
        ),
      ),
    ),
  );
}

FinancialReportPack _pack(List<FinancialReportComplianceItem> complianceItems) {
  return FinancialReportPack(
    entityName: 'Kaysir',
    frameworkName: 'SAK Indonesia (IFRS-converged)',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1),
    statements: const [],
    notes: const [],
    complianceItems: complianceItems,
    metrics: const [],
  );
}
