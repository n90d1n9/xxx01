import '../models/billing_invoice.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_tenant_preferences.dart';

DateTime billingInvoiceDueDate(
  BillingInvoice invoice, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) {
  return billingIssueDueDate(invoice.date, preferences: preferences);
}

DateTime billingInvoiceDraftDueDate(
  BillingInvoiceDraft draft, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) {
  return billingIssueDueDate(draft.issueDate, preferences: preferences);
}

DateTime billingIssueDueDate(
  DateTime issueDate, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
}) {
  return issueDate.add(Duration(days: preferences.paymentTermsDays));
}
