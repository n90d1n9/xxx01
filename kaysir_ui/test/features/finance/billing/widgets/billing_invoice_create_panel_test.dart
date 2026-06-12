import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_create_panel.dart';

void main() {
  testWidgets('BillingInvoiceCreatePanel creates invoice drafts', (
    tester,
  ) async {
    BillingInvoiceDraft? submittedDraft;
    BillingInvoice? createdInvoice;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: BillingInvoiceCreatePanel(
              tenant: _tenant(),
              initialDate: DateTime(2026, 5, 31),
              onCreate: (draft) async {
                submittedDraft = draft;
                return _invoice(draft);
              },
              onCreated: (invoice) {
                createdInvoice = invoice;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Issue date 2026-05-31'), findsOneWidget);
    expect(find.text('Due'), findsOneWidget);
    expect(find.text('2026-06-14'), findsOneWidget);
    expect(find.text('14 days'), findsOneWidget);
    expect(find.text('Tax mode'), findsOneWidget);
    expect(find.text('Exclusive'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Create Invoice'),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField), '30000');
    await tester.pump();

    expect(find.text('Rp 30,000'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Create Invoice'),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Create Invoice'));
    await tester.pump();

    expect(submittedDraft?.tenantId, 'tenant-a');
    expect(submittedDraft?.amount, 30000);
    expect(submittedDraft?.issueDate, DateTime(2026, 5, 31));
    expect(submittedDraft?.taxMode, BillingInvoiceTaxMode.exclusive);
    expect(createdInvoice?.id, 'inv-created');
  });

  testWidgets('BillingInvoiceCreatePanel shows create failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            child: BillingInvoiceCreatePanel(
              tenant: _tenant(),
              initialDate: DateTime(2026, 5, 31),
              onCreate: (draft) {
                throw StateError('Invoice service unavailable.');
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '30000');
    await tester.pump();
    await tester.tap(find.text('Create Invoice'));
    await tester.pump();

    expect(
      find.text('Bad state: Invoice service unavailable.'),
      findsOneWidget,
    );
  });
}

BillingTenantAccount _tenant() {
  return const BillingTenantAccount(
    id: 'tenant-a',
    name: 'Acme Corp',
    logoUrl: '',
    planName: 'Enterprise',
    currentBalance: 0,
    preferences: BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      datePattern: 'yyyy-MM-dd',
      paymentTermsDays: 14,
    ),
  );
}

BillingInvoice _invoice(BillingInvoiceDraft draft) {
  return BillingInvoice(
    id: 'inv-created',
    tenantId: draft.tenantId,
    amount: draft.amount,
    date: draft.issueDate,
    status: BillingInvoiceStatus.pending,
  );
}
