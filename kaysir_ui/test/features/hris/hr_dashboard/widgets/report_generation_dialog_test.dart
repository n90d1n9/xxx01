import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/report_generation_dialog.dart';

void main() {
  const report = ReportType(
    name: 'Turnover Report',
    description: 'Employee turnover rates by department and time period',
    icon: Icons.people_alt_outlined,
  );

  testWidgets('report generation dialog returns the default request', (
    tester,
  ) async {
    ReportGenerationRequest? generated;

    await _pumpDialogHarness(
      tester,
      report: report,
      onGenerate: (request) => generated = request,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Generate Turnover Report'), findsOneWidget);
    expect(
      find.text('turnover-report-all-departments-last-30-days.pdf'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    expect(generated, const ReportGenerationRequest());
    expect(find.text('Generate Turnover Report'), findsNothing);
  });

  testWidgets('report generation dialog returns selected parameters', (
    tester,
  ) async {
    ReportGenerationRequest? generated;

    await _pumpDialogHarness(
      tester,
      report: report,
      onGenerate: (request) => generated = request,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await _chooseDropdownValue(
      tester,
      fieldKey: const Key('report-period-field'),
      label: 'Last Quarter',
    );
    await _chooseDropdownValue(
      tester,
      fieldKey: const Key('report-department-field'),
      label: 'Engineering',
    );
    await _chooseDropdownValue(
      tester,
      fieldKey: const Key('report-format-field'),
      label: 'CSV',
    );

    expect(
      find.text('turnover-report-engineering-last-quarter.csv'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
    await tester.pumpAndSettle();

    expect(
      generated,
      const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
      ),
    );
  });

  testWidgets('report generation dialog blocks empty report contents', (
    tester,
  ) async {
    ReportGenerationRequest? generated;

    await _pumpDialogHarness(
      tester,
      report: report,
      onGenerate: (request) => generated = request,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await _toggleOption(tester, const Key('report-executive-summary-option'));
    await _toggleOption(tester, const Key('report-trend-charts-option'));

    final generateButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Generate'),
    );

    expect(generateButton.onPressed, isNull);
    expect(find.text('Select at least one report section'), findsOneWidget);
    expect(generated, isNull);
  });
}

Future<void> _pumpDialogHarness(
  WidgetTester tester, {
  required ReportType report,
  required ValueChanged<ReportGenerationRequest> onGenerate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder:
                      (context) => ReportGenerationDialog(
                        report: report,
                        onGenerate: onGenerate,
                      ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> _chooseDropdownValue(
  WidgetTester tester, {
  required Key fieldKey,
  required String label,
}) async {
  await tester.tap(find.byKey(fieldKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _toggleOption(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}
