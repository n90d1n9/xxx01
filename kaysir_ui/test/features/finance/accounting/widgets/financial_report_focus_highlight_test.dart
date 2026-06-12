import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_focus_highlight.dart';

void main() {
  testWidgets('renders a visible treatment when active', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportFocusHighlight(
            active: true,
            child: Text('Target section'),
          ),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, isNot(Colors.transparent));
    expect(decoration.boxShadow, isNotEmpty);
    expect(find.text('Target section'), findsOneWidget);
  });

  testWidgets('stays visually neutral when inactive', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportFocusHighlight(
            active: false,
            child: Text('Target section'),
          ),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.color, Colors.transparent);
    expect(decoration.boxShadow, isEmpty);
    expect(find.text('Target section'), findsOneWidget);
  });
}
