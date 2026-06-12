import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_scope_pill.dart';

void main() {
  testWidgets('BillingDiagnosticsScopePill constrains long labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingDiagnosticsScopePill(
            label: 'Tenant construction diagnostics with a very long name',
            maxWidth: 120,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.textContaining('Tenant construction diagnostics'),
        matching: find.byType(Container),
      ),
    );
    final text = tester.widget<Text>(
      find.textContaining('Tenant construction diagnostics'),
    );

    expect(container.constraints, const BoxConstraints(maxWidth: 120));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
