import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive_retention.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('renders archive retention status and checkpoints', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseArchiveRetentionPanel(summary: _summary),
        ),
      ),
    );

    expect(find.text('Archive Retention Monitor'), findsOneWidget);
    expect(find.text('Review due'), findsWidgets);
    expect(find.text('As of Jan 10, 2027'), findsOneWidget);
    expect(find.text('Retain until Jan 31, 2036'), findsOneWidget);
    expect(find.text('90d review window'), findsOneWidget);
    expect(find.text('Last Jan 10, 2027'), findsOneWidget);
    expect(find.text('Mark reviewed'), findsOneWidget);
    expect(find.text('Disposal review'), findsOneWidget);
    expect(find.text('Custodian'), findsOneWidget);
    expect(find.text('Finance archive owner'), findsOneWidget);
    expect(find.text('Next review'), findsOneWidget);
    expect(find.text('Feb 1, 2027'), findsOneWidget);
    expect(find.text('22 day(s) remaining'), findsOneWidget);
    expect(
      find.byType(FinancialReportReleaseArchiveRetentionPanel),
      findsOneWidget,
    );
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<
          FinancialReportReleaseArchiveRetentionCheckpoint
        >,
      ),
      findsOneWidget,
    );
    expect(find.byType(FinancialReportTintedSurface), findsAtLeastNWidgets(3));
  });

  testWidgets('opens retention action dialog and returns note', (tester) async {
    FinancialReportReleaseArchiveRetentionActionInput? input;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => FilledButton(
                onPressed: () async {
                  input = await showDialog<
                    FinancialReportReleaseArchiveRetentionActionInput
                  >(
                    context: context,
                    builder:
                        (context) =>
                            const FinancialReportReleaseArchiveRetentionActionDialog(
                              title: 'Mark retention reviewed',
                              actionLabel: 'Mark reviewed',
                            ),
                  );
                },
                child: const Text('Open'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Custody reviewed.');
    await tester.tap(find.text('Mark reviewed'));
    await tester.pumpAndSettle();

    expect(input?.note, 'Custody reviewed.');
  });
}

final _summary = FinancialReportReleaseArchiveRetentionSummary(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  status: FinancialReportReleaseArchiveRetentionStatus.reviewDue,
  record: _record,
  asOf: DateTime(2027, 1, 10),
  retainUntil: DateTime(2036, 1, 31),
  nextReviewDate: DateTime(2027, 2, 1),
  lastReviewAt: _lastReviewAt,
  lastReviewActor: 'Controller',
  daysRemaining: 3308,
  daysUntilReview: 22,
  reviewWindowDays: 90,
  nextAction:
      'FR-ARCH-2026010120260131-ABCDEF123456 is due for custody review in 22 day(s).',
  checkpoints: const [
    FinancialReportReleaseArchiveRetentionCheckpoint(
      title: 'Custodian',
      value: 'Finance archive owner',
      detail: 'Encrypted archive vault',
      status: FinancialReportReleaseArchiveRetentionStatus.active,
    ),
    FinancialReportReleaseArchiveRetentionCheckpoint(
      title: 'Next review',
      value: 'Feb 1, 2027',
      detail: '22 day(s) remaining',
      status: FinancialReportReleaseArchiveRetentionStatus.reviewDue,
    ),
    FinancialReportReleaseArchiveRetentionCheckpoint(
      title: 'Retention deadline',
      value: 'Jan 31, 2036',
      detail: '3308 day(s) remaining',
      status: FinancialReportReleaseArchiveRetentionStatus.active,
    ),
  ],
);

final _record = FinancialReportReleaseArchiveRecord(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
  archivedAt: DateTime(2026, 2, 1, 14),
  archivedBy: 'Controller',
  custodian: 'Finance archive owner',
  storageLocation: 'Encrypted archive vault',
  retentionPolicy: 'Indonesia statutory/tax archive policy',
  retainUntil: DateTime(2036, 1, 31),
  packageFingerprint: 'abcdef1234567890',
  packageFingerprintAlgorithm: 'SHA-256',
  evidenceItemCount: 2,
  note: 'Release file archived.',
);

final _lastReviewAt = DateTime(2027, 1, 10);
