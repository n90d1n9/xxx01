import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_policy.dart';
import '../models/billing_invoice_issue_plan.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../models/billing_payment_schedule.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_invoice_line_item_summary.dart' hide BillingInvoiceTaxMode;
import 'billing_invoice_terms.dart';
import 'billing_payment_schedule.dart';

BillingInvoiceIssuePlan buildBillingInvoiceIssuePlan(
  BillingInvoiceDraft draft, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  BillingInvoiceIssuePolicy? issuePolicy,
  BillingInvoiceTaxMode? taxMode,
  BillingPaymentScheduleOptions? paymentScheduleOptions,
}) {
  final resolvedTaxMode = taxMode ?? issuePolicy?.taxMode ?? draft.taxMode;
  final resolvedScheduleOptions =
      paymentScheduleOptions ?? issuePolicy?.paymentScheduleOptions;
  final dueDate = billingInvoiceDraftDueDate(draft, preferences: preferences);

  if (draft.lineItems.isEmpty) {
    final total = draft.amount;

    return BillingInvoiceIssuePlan(
      draft: draft,
      dueDate: dueDate,
      paymentTermsDays: preferences.paymentTermsDays,
      paymentSchedule: buildBillingPaymentSchedule(
        total: total,
        issueDate: draft.issueDate,
        preferences: preferences,
        options: resolvedScheduleOptions,
      ),
      taxMode: resolvedTaxMode,
      lineCount: 0,
      quantity: 0,
      subtotal: draft.amount,
      discount: 0,
      tax: 0,
      total: total,
    );
  }

  final summary = summarizeBillingInvoiceDraftLineItems(
    draft,
    taxMode: resolvedTaxMode,
  );

  return BillingInvoiceIssuePlan(
    draft: draft,
    dueDate: dueDate,
    paymentTermsDays: preferences.paymentTermsDays,
    paymentSchedule: buildBillingPaymentSchedule(
      total: summary.total,
      issueDate: draft.issueDate,
      preferences: preferences,
      options: resolvedScheduleOptions,
    ),
    taxMode: resolvedTaxMode,
    lineCount: summary.lineCount,
    quantity: summary.quantity,
    subtotal: summary.subtotal,
    discount: summary.discount,
    tax: summary.tax,
    total: summary.total,
  );
}

BillingInvoiceTaxMode billingInvoiceTaxModeFromTenantPreferences(
  BillingTenantPreferences preferences,
) {
  return switch (preferences.taxMode) {
    BillingTaxMode.exclusive => BillingInvoiceTaxMode.exclusive,
    BillingTaxMode.inclusive => BillingInvoiceTaxMode.inclusive,
    BillingTaxMode.exempt => BillingInvoiceTaxMode.exempt,
  };
}
