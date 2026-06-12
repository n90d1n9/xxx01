import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';

void main() {
  group('financial report audit trail components', () {
    testWidgets('limits visible audit events and reports older count', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportAuditTrailPanel<int>(
              title: 'Shared Audit Trail',
              events: List<int>.generate(6, (index) => index + 1),
              isDarkMode: false,
              itemBuilder: (context, event) => Text('Event $event'),
            ),
          ),
        ),
      );

      expect(find.text('Shared Audit Trail'), findsOneWidget);
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 5'), findsOneWidget);
      expect(find.text('Event 6'), findsNothing);
      expect(find.text('+1 older event(s)'), findsOneWidget);
    });
  });
}
