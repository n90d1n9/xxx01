import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_notes_panel.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('FinancialReportNotesPanel', () {
    testWidgets('renders disclosure notes with reusable reference pills', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportNotesPanel(
                pack: _packWithNotes(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('2 disclosures'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Basis of preparation'), findsOneWidget);
      expect(find.text('PSAK 1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Revenue recognition'), findsOneWidget);
      expect(find.text('PSAK 72'), findsOneWidget);
      expect(
        find.textContaining('prepared under SAK Indonesia'),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(5));
    });

    testWidgets('renders an empty notes state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportNotesPanel(
              pack: _emptyPack(),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('0 disclosures'), findsOneWidget);
      expect(
        find.text('No disclosure notes are attached to this report pack.'),
        findsOneWidget,
      );
    });
  });
}

FinancialReportPack _packWithNotes() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [
      FinancialReportDisclosureNote(
        number: '1',
        title: 'Basis of preparation',
        body: 'The financial statements are prepared under SAK Indonesia.',
        standardReferences: ['PSAK 1'],
      ),
      FinancialReportDisclosureNote(
        number: '2',
        title: 'Revenue recognition',
        body: 'Revenue is recognized when control transfers to customers.',
        standardReferences: ['PSAK 72'],
      ),
    ],
    complianceItems: const [],
    metrics: const [],
  );
}

FinancialReportPack _emptyPack() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}
