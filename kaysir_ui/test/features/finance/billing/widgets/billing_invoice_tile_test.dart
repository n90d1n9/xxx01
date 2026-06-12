import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_sync_state.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_empty_state.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_tile.dart';

void main() {
  testWidgets('BillingInvoiceTile displays invoice details and handles taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceTile(
            invoice: _invoice(),
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Invoice #inv-pending'), findsOneWidget);
    expect(find.text('Jun 10, 2026'), findsOneWidget);
    expect(find.text(r'$2,000.00'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.byType(BillingInvoiceTile));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('BillingInvoiceTile adapts to compact widths without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: BillingInvoiceTile(invoice: _invoice()),
          ),
        ),
      ),
    );

    expect(find.text('Invoice #inv-pending'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BillingInvoiceTile formats with tenant preferences', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceTile(
            invoice: _invoice(),
            preferences: const BillingTenantPreferences(
              currencySymbol: 'Rp ',
              decimalDigits: 0,
              datePattern: 'yyyy-MM-dd',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rp 2,000'), findsOneWidget);
    expect(find.text('2026-06-10'), findsOneWidget);
  });

  testWidgets('BillingInvoiceTile shows local-only sync state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceTile(
            invoice: _invoice(),
            syncState: BillingInvoiceSyncState.localOnly,
          ),
        ),
      ),
    );

    expect(find.text('Syncing'), findsOneWidget);
  });

  testWidgets('BillingInvoiceEmptyState uses a reusable message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceEmptyState(message: 'No invoices ready'),
        ),
      ),
    );

    expect(find.text('No invoices ready'), findsOneWidget);
  });
}

BillingInvoice _invoice() {
  return BillingInvoice(
    id: 'inv-pending',
    tenantId: 'tenant-test',
    amount: 2000,
    date: DateTime(2026, 6, 10),
    status: BillingInvoiceStatus.pending,
  );
}
