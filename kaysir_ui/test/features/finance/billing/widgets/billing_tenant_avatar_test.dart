import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_tenant_avatar.dart';

void main() {
  testWidgets('BillingTenantAvatar displays initials when logo is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingTenantAvatar(name: 'Acme Corporation', logoUrl: ''),
        ),
      ),
    );

    expect(find.text('AC'), findsOneWidget);
  });
}
