import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_activity.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_activity_timeline.dart';

void main() {
  testWidgets('BillingInvoiceActivityTimeline renders entries and dates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceActivityTimeline(
            entries: _entries(),
            preferences: const BillingTenantPreferences(
              datePattern: 'yyyy-MM-dd',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Invoice issued'), findsOneWidget);
    expect(find.text('Payment due soon'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
    expect(find.text('2026-05-31'), findsOneWidget);
  });

  testWidgets('BillingInvoiceActivityTimeline stays compact on narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: BillingInvoiceActivityTimeline(entries: _entries()),
          ),
        ),
      ),
    );

    expect(find.text('Payment due soon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

List<BillingInvoiceActivityEntry> _entries() {
  return [
    BillingInvoiceActivityEntry(
      type: BillingInvoiceActivityType.issued,
      state: BillingInvoiceActivityState.completed,
      title: 'Invoice issued',
      description: 'Created for Rp 2,000.',
      date: DateTime(2026, 5, 20),
    ),
    BillingInvoiceActivityEntry(
      type: BillingInvoiceActivityType.paymentDue,
      state: BillingInvoiceActivityState.current,
      title: 'Payment due soon',
      description: 'Payment is due in 3 days.',
      date: DateTime(2026, 5, 31),
    ),
  ];
}
