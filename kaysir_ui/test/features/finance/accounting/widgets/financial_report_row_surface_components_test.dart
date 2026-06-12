import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_row_surface_components.dart';

void main() {
  testWidgets('financial report row surface applies reusable row chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportRowSurface(
            isDarkMode: false,
            backgroundColor: Color(0xFFF1F5F9),
            child: Text('Revenue row'),
          ),
        ),
      ),
    );

    expect(find.text('Revenue row'), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(FinancialReportRowSurface),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, const Color(0xFFF1F5F9));
    expect(decoration.border?.bottom.color, Colors.grey.shade100);
  });
}
