import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_policies.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_plan.dart';

void main() {
  test('buildBillingInvoiceIssuePlan summarizes amount-only drafts', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 900,
      issueDate: DateTime(2026, 6, 10),
    );

    final plan = buildBillingInvoiceIssuePlan(
      draft,
      preferences: const BillingTenantPreferences(paymentTermsDays: 14),
    );

    expect(plan.canIssue, isTrue);
    expect(plan.isLineItemBased, isFalse);
    expect(plan.dueDate, DateTime(2026, 6, 24));
    expect(plan.paymentTermsDays, 14);
    expect(plan.paymentSchedule.paymentCount, 1);
    expect(plan.paymentSchedule.items.single.dueDate, DateTime(2026, 6, 24));
    expect(plan.subtotal, 900);
    expect(plan.tax, 0);
    expect(plan.total, 900);
  });

  test('buildBillingInvoiceIssuePlan uses draft tax mode for line items', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 6, 10),
      taxMode: BillingInvoiceTaxMode.inclusive,
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'plan-pro',
          description: 'Pro plan',
          quantity: 2,
          unitPrice: 110,
          taxRate: 0.1,
        ),
      ],
    );

    final plan = buildBillingInvoiceIssuePlan(draft);

    expect(plan.canIssue, isTrue);
    expect(plan.isLineItemBased, isTrue);
    expect(plan.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(plan.lineCount, 1);
    expect(plan.quantity, 2);
    expect(plan.subtotal, 220);
    expect(plan.tax, closeTo(20, 0.001));
    expect(plan.total, 220);
  });

  test('buildBillingInvoiceIssuePlan supports tax mode overrides', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 6, 10),
      taxMode: BillingInvoiceTaxMode.inclusive,
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'plan-pro',
          description: 'Pro plan',
          quantity: 1,
          unitPrice: 100,
          taxRate: 0.1,
        ),
      ],
    );

    final plan = buildBillingInvoiceIssuePlan(
      draft,
      taxMode: BillingInvoiceTaxMode.exclusive,
    );

    expect(plan.taxMode, BillingInvoiceTaxMode.exclusive);
    expect(plan.total, 110);
  });

  test('buildBillingInvoiceIssuePlan supports scheduled payment options', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 5000,
      issueDate: DateTime(2026, 6, 10),
    );

    final plan = buildBillingInvoiceIssuePlan(
      draft,
      paymentScheduleOptions: BillingPaymentScheduleOptions.milestones(
        milestones: [
          BillingPaymentScheduleMilestone(
            id: 'mobilization',
            label: 'Mobilization',
            amountRatio: 0.2,
            dueAfterDays: 0,
          ),
          BillingPaymentScheduleMilestone(
            id: 'handover',
            label: 'Handover',
            amountRatio: 0.8,
            dueAfterDays: 45,
          ),
        ],
      ),
    );

    expect(plan.hasScheduledPayments, isTrue);
    expect(
      plan.paymentSchedule.strategy,
      BillingPaymentScheduleStrategy.milestones,
    );
    expect(plan.paymentSchedule.items.map((item) => item.amount), [1000, 4000]);
    expect(plan.paymentSchedule.finalDueDate, DateTime(2026, 7, 25));
    expect(plan.canIssue, isTrue);
  });

  test('buildBillingInvoiceIssuePlan applies reusable issue policies', () {
    final policy = billingInvoiceIssuePolicyForProfile(
      constructionBillingDomainProfile(
        taxMode: BillingInvoiceTaxMode.inclusive,
      ),
    );
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 1200,
      issueDate: DateTime(2026, 6, 10),
    );

    final plan = buildBillingInvoiceIssuePlan(
      draft,
      preferences: const BillingTenantPreferences(paymentTermsDays: 10),
      issuePolicy: policy,
    );

    expect(plan.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(
      plan.paymentSchedule.strategy,
      BillingPaymentScheduleStrategy.splitEqual,
    );
    expect(plan.paymentSchedule.items.map((item) => item.amount), [
      400,
      400,
      400,
    ]);
  });

  test('buildBillingInvoiceIssuePlan exposes draft validation readiness', () {
    final draft = BillingInvoiceDraft(
      tenantId: '',
      amount: 0,
      issueDate: DateTime(2026, 6, 10),
    );

    final plan = buildBillingInvoiceIssuePlan(draft);

    expect(plan.canIssue, isFalse);
    expect(plan.validationErrors, [
      'Choose a tenant before creating an invoice.',
      'Enter an invoice amount greater than zero.',
    ]);
  });

  test('billingInvoiceTaxModeFromTenantPreferences maps tenant settings', () {
    expect(
      billingInvoiceTaxModeFromTenantPreferences(
        const BillingTenantPreferences(taxMode: BillingTaxMode.inclusive),
      ),
      BillingInvoiceTaxMode.inclusive,
    );
    expect(
      billingInvoiceTaxModeFromTenantPreferences(
        const BillingTenantPreferences(taxMode: BillingTaxMode.exempt),
      ),
      BillingInvoiceTaxMode.exempt,
    );
  });
}
