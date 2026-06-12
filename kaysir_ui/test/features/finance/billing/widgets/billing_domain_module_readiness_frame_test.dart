import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_module_readiness_frame.dart';

void main() {
  testWidgets('BillingReadinessFrame applies custom frame spacing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingReadinessFrame(
            margin: EdgeInsets.all(9),
            padding: EdgeInsets.all(11),
            backgroundColor: Color(0xFFF8FAFC),
            child: Text('Frame content'),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('Frame content'),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(container.margin, const EdgeInsets.all(9));
    expect(container.padding, const EdgeInsets.all(11));
    expect(decoration.color, const Color(0xFFF8FAFC));
  });
}
