import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/payroal/models/payroll_management_models.dart';
import 'package:kaysir/features/hris/payroal/widgets/payroll_period_selector.dart';

void main() {
  testWidgets('payroll period selector emits selected period id', (
    tester,
  ) async {
    var selectedId = '202606';
    final periods = [
      PayrollRunPeriod(
        id: '202606',
        label: 'June 2026 Payroll',
        asOfDate: DateTime(2026, 6, 2),
        payDate: DateTime(2026, 6, 25),
        statusLabel: 'Current close',
        isCurrent: true,
      ),
      PayrollRunPeriod(
        id: '202607',
        label: 'July 2026 Payroll',
        asOfDate: DateTime(2026, 7, 2),
        payDate: DateTime(2026, 7, 25),
        statusLabel: 'Planning',
        isCurrent: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PayrollPeriodSelector(
            periods: periods,
            selectedPeriod: periods.first,
            onPeriodChanged: (periodId) => selectedId = periodId,
          ),
        ),
      ),
    );

    expect(find.text('June 2026 Payroll'), findsOneWidget);
    expect(find.text('Current close'), findsOneWidget);
    expect(find.text('Pay Jun 25, 2026'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('July 2026 Payroll').last);
    await tester.pumpAndSettle();

    expect(selectedId, '202607');
  });
}
