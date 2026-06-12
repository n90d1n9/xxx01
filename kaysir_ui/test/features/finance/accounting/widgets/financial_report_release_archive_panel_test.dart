import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('renders archive register and opens archive dialog', (
    tester,
  ) async {
    var archivePressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseArchivePanel(
            summary: _readySummary,
            onArchive: () => archivePressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Release Archive Register'), findsOneWidget);
    expect(find.text('Ready to archive'), findsOneWidget);
    expect(find.text('2/2 evidence ready'), findsOneWidget);
    expect(find.text('10 year retention'), findsOneWidget);

    await tester.tap(find.text('Archive pack'));
    await tester.pump();

    expect(archivePressed, isTrue);
  });

  testWidgets('renders archived release register facts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseArchivePanel(summary: _archivedSummary),
        ),
      ),
    );

    expect(find.text('Archived'), findsWidgets);
    expect(find.text('Clear archive'), findsOneWidget);
    expect(find.text('FR-ARCH-2026010120260131-ABCDEF123456'), findsWidgets);
    expect(find.text('Finance archive owner'), findsOneWidget);
    expect(find.text('Encrypted archive vault'), findsOneWidget);
    expect(find.textContaining('retain until Jan 31, 2036'), findsOneWidget);
    expect(find.textContaining('SHA-256 ABCDEF123456'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is FinancialReportResponsiveWrapGrid,
      ),
      findsOneWidget,
    );
    expect(find.byType(FinancialReportTintedSurface), findsAtLeastNWidgets(6));
  });

  testWidgets('returns archive dialog input', (tester) async {
    FinancialReportReleaseArchiveInput? input;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => FilledButton(
                onPressed: () async {
                  input = await showDialog<FinancialReportReleaseArchiveInput>(
                    context: context,
                    builder:
                        (context) =>
                            const FinancialReportReleaseArchiveDialog(),
                  );
                },
                child: const Text('Open'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Controller');
    await tester.enterText(find.byType(TextField).at(1), 'Finance owner');
    await tester.enterText(find.byType(TextField).at(2), 'Archive vault');
    await tester.enterText(find.byType(TextField).at(3), 'Archived note');
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(input?.archivedBy, 'Controller');
    expect(input?.custodian, 'Finance owner');
    expect(input?.storageLocation, 'Archive vault');
    expect(input?.note, 'Archived note');
  });
}

const _readySummary = FinancialReportReleaseArchiveSummary(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  status: FinancialReportReleaseArchiveStatus.ready,
  record: null,
  evidenceReady: true,
  evidenceItemCount: 2,
  readyEvidenceCount: 2,
  nextAction:
      'Release evidence is ready. Create the archive register before closing the release file.',
);

final _archivedRecord = FinancialReportReleaseArchiveRecord(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
  archivedAt: _archivedAt,
  archivedBy: 'Controller',
  custodian: 'Finance archive owner',
  storageLocation: 'Encrypted archive vault',
  retentionPolicy: 'Indonesia statutory/tax archive policy',
  retainUntil: _retainUntil,
  packageFingerprint: 'abcdef1234567890',
  packageFingerprintAlgorithm: 'SHA-256',
  evidenceItemCount: 2,
  note: 'Release file archived.',
);

final _archivedSummary = FinancialReportReleaseArchiveSummary(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  status: FinancialReportReleaseArchiveStatus.archived,
  record: _archivedRecord,
  evidenceReady: true,
  evidenceItemCount: 2,
  readyEvidenceCount: 2,
  nextAction:
      'Archive record sealed under FR-ARCH-2026010120260131-ABCDEF123456; retain through 2036-01-31.',
);

final _archivedAt = DateTime(2026, 2, 1, 14);
final _retainUntil = DateTime(2036, 1, 31);
