import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report tinted surface components', () {
    testWidgets('applies reusable tint, border, padding, and height', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportTintedSurface(
              color: Colors.teal,
              minHeight: 96,
              width: double.infinity,
              padding: EdgeInsets.all(14),
              fillAlpha: 0.11,
              borderAlpha: 0.29,
              backgroundColor: Colors.white,
              child: Text('Surface content'),
            ),
          ),
        ),
      );

      expect(find.text('Surface content'), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FinancialReportTintedSurface),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      final border = decoration.border! as Border;

      expect(container.constraints?.minHeight, 96);
      expect(container.constraints?.minWidth, double.infinity);
      expect(container.padding, const EdgeInsets.all(14));
      expect(decoration.color, Colors.white);
      expect(border.top.color, Colors.teal.withValues(alpha: 0.29));
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });
}
