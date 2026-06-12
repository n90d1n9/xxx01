import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_type.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/report_generation_request_form.dart';

void main() {
  testWidgets('report generation request form renders an initial request', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      initialRequest: const ReportGenerationRequest(
        period: ReportPeriod.lastYear,
        department: ReportDepartmentScope.finance,
        format: ReportFileFormat.excel,
      ),
    );

    expect(find.text('Last Year'), findsWidgets);
    expect(find.text('Finance'), findsWidgets);
    expect(find.text('Excel'), findsWidgets);
    expect(find.text('Package preset'), findsOneWidget);
    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('turnover-report-finance-last-year.xlsx'), findsOneWidget);
    expect(find.text('2 sections', skipOffstage: false), findsOneWidget);
    expect(find.text('Est. 1.4 MB', skipOffstage: false), findsOneWidget);
    expect(
      find.text('~1m 10s generation', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Internal', skipOffstage: false), findsOneWidget);
    expect(find.text('Executive summary + Trend charts'), findsOneWidget);
  });

  testWidgets('report generation request form updates the export preview', (
    tester,
  ) async {
    final requests = <ReportGenerationRequest>[];

    await _pumpForm(tester, onChanged: requests.add);

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
    expect(find.text('Est. 580 KB', skipOffstage: false), findsOneWidget);
    expect(find.text('~45s generation', skipOffstage: false), findsOneWidget);
    expect(
      requests.last,
      const ReportGenerationRequest(
        period: ReportPeriod.lastQuarter,
        department: ReportDepartmentScope.engineering,
        format: ReportFileFormat.csv,
      ),
    );
  });

  testWidgets('report generation request form manages package contents', (
    tester,
  ) async {
    final requests = <ReportGenerationRequest>[];

    await _pumpForm(tester, onChanged: requests.add);

    await _toggleOption(tester, const Key('report-raw-data-option'));

    expect(requests.last.includeRawData, isTrue);
    expect(
      find.text('Executive summary + Trend charts + Raw data export'),
      findsOneWidget,
    );
    expect(find.text('3 sections', skipOffstage: false), findsOneWidget);
    expect(find.text('Est. 3.2 MB', skipOffstage: false), findsOneWidget);
    expect(find.text('~2m 5s generation', skipOffstage: false), findsOneWidget);
    expect(find.text('Confidential', skipOffstage: false), findsOneWidget);

    await _toggleOption(tester, const Key('report-executive-summary-option'));
    await _toggleOption(tester, const Key('report-trend-charts-option'));
    await _toggleOption(tester, const Key('report-raw-data-option'));

    expect(requests.last.hasSelectedContent, isFalse);
    expect(find.text('Select at least one report section'), findsOneWidget);
    expect(find.text('No package sections selected'), findsOneWidget);
    expect(find.text('0 sections', skipOffstage: false), findsOneWidget);
    expect(find.text('~35s generation', skipOffstage: false), findsOneWidget);
  });

  testWidgets('report generation request form applies package presets', (
    tester,
  ) async {
    final requests = <ReportGenerationRequest>[];

    await _pumpForm(tester, onChanged: requests.add);

    await _selectPackagePreset(tester, 'Audit');

    expect(requests.last.includeExecutiveSummary, isTrue);
    expect(requests.last.includeTrendCharts, isTrue);
    expect(requests.last.includeRawData, isTrue);
    expect(
      find.text('Executive summary + Trend charts + Raw data export'),
      findsOneWidget,
    );
    expect(find.text('3 sections', skipOffstage: false), findsOneWidget);

    await _selectPackagePreset(tester, 'Data');

    expect(requests.last.includeExecutiveSummary, isFalse);
    expect(requests.last.includeTrendCharts, isFalse);
    expect(requests.last.includeRawData, isTrue);
    expect(find.text('Raw data export'), findsWidgets);
    expect(find.text('1 section', skipOffstage: false), findsOneWidget);
    expect(find.text('Est. 2.1 MB', skipOffstage: false), findsOneWidget);
    expect(find.text('Confidential', skipOffstage: false), findsOneWidget);
    expect(
      find.text('~1m 20s generation', skipOffstage: false),
      findsOneWidget,
    );
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  ReportGenerationRequest initialRequest = const ReportGenerationRequest(),
  ValueChanged<ReportGenerationRequest>? onChanged,
}) async {
  var request = initialRequest;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: SizedBox(
                width: 430,
                child: ReportGenerationRequestForm(
                  report: _turnoverReport,
                  request: request,
                  onChanged: (nextRequest) {
                    setState(() => request = nextRequest);
                    onChanged?.call(nextRequest);
                  },
                ),
              ),
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
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _selectPackagePreset(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

const _turnoverReport = ReportType(
  name: 'Turnover Report',
  description: 'Employee turnover rates by department and time period',
  icon: Icons.people_alt_outlined,
);
