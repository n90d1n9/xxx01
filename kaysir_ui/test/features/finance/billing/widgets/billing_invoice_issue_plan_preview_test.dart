import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_plan_preview.dart';

void main() {
  testWidgets('BillingInvoiceIssuePlanPreview renders issue plan facts', (
    tester,
  ) async {
    final plan = buildBillingInvoiceIssuePlan(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 0,
        issueDate: DateTime(2026, 6, 10),
        taxMode: BillingInvoiceTaxMode.inclusive,
        lineItems: const [
          BillingInvoiceLineItem(
            id: 'plan-pro',
            description: 'Pro plan',
            quantity: 1,
            unitPrice: 110,
            taxRate: 0.1,
          ),
        ],
      ),
      preferences: const BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        datePattern: 'yyyy-MM-dd',
        paymentTermsDays: 14,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssuePlanPreview(
            issuePlan: plan,
            preferences: const BillingTenantPreferences(
              currencySymbol: 'Rp ',
              decimalDigits: 0,
              datePattern: 'yyyy-MM-dd',
              paymentTermsDays: 14,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Draft total'), findsOneWidget);
    expect(find.text('Rp 110'), findsWidgets);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Rp 10'), findsOneWidget);
    expect(find.text('Due'), findsOneWidget);
    expect(find.text('2026-06-24'), findsOneWidget);
    expect(find.text('Tax mode'), findsOneWidget);
    expect(find.text('Inclusive'), findsOneWidget);
  });

  testWidgets('BillingInvoiceIssuePlanPreview can defer the visible total', (
    tester,
  ) async {
    final plan = buildBillingInvoiceIssuePlan(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 0,
        issueDate: DateTime(2026, 6, 10),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssuePlanPreview(
            issuePlan: plan,
            preferences: const BillingTenantPreferences(),
            showTotalPlaceholder: true,
          ),
        ),
      ),
    );

    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('BillingInvoiceIssuePlanPreview renders payment schedules', (
    tester,
  ) async {
    final plan = buildBillingInvoiceIssuePlan(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 1200,
        issueDate: DateTime(2026, 6, 10),
      ),
      preferences: const BillingTenantPreferences(
        datePattern: 'yyyy-MM-dd',
        paymentTermsDays: 10,
      ),
      paymentScheduleOptions: BillingPaymentScheduleOptions.splitEqual(
        installments: 3,
        intervalDays: 15,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssuePlanPreview(
            issuePlan: plan,
            preferences: const BillingTenantPreferences(
              datePattern: 'yyyy-MM-dd',
              paymentTermsDays: 10,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('3 payments - Split'), findsOneWidget);
    expect(find.text('Final due'), findsOneWidget);
    expect(find.text('2026-07-20'), findsOneWidget);
  });
}
