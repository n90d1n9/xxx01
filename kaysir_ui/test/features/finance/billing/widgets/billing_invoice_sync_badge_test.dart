import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_sync_state.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_sync_badge.dart';

void main() {
  testWidgets('BillingInvoiceSyncBadge shows local-only sync state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceSyncBadge(
            state: BillingInvoiceSyncState.localOnly,
          ),
        ),
      ),
    );

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
  });

  testWidgets('BillingInvoiceSyncBadge hides confirmed state by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceSyncBadge(
            state: BillingInvoiceSyncState.confirmed,
          ),
        ),
      ),
    );

    expect(find.text('Synced'), findsNothing);
  });

  testWidgets('BillingInvoiceSyncBadge can show confirmed state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceSyncBadge(
            state: BillingInvoiceSyncState.confirmed,
            showConfirmed: true,
          ),
        ),
      ),
    );

    expect(find.text('Synced'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
  });
}
