import '../models/billing_business_domain_profile.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_line_item.dart';
import '../models/billing_invoice_line_item_adapter.dart';
import 'billing_invoice_line_item_summary.dart';

BillingInvoiceDraft composeBillingInvoiceDraft({
  required String tenantId,
  required DateTime issueDate,
  Iterable<BillingInvoiceLineItem> lineItems = const [],
  double amount = 0,
  BillingBusinessDomainProfile? profile,
  BillingInvoiceTaxMode? taxMode,
}) {
  final resolvedLineItems = List<BillingInvoiceLineItem>.unmodifiable(
    lineItems,
  );
  final resolvedTaxMode =
      taxMode ?? profile?.taxMode ?? BillingInvoiceTaxMode.exclusive;
  final resolvedAmount =
      resolvedLineItems.isEmpty
          ? amount
          : summarizeBillingInvoiceLineItems(
            resolvedLineItems,
            taxMode: resolvedTaxMode,
          ).total;

  return BillingInvoiceDraft(
    tenantId: tenantId,
    amount: resolvedAmount,
    issueDate: issueDate,
    lineItems: resolvedLineItems,
    taxMode: resolvedTaxMode,
  );
}

BillingInvoiceDraft composeBillingInvoiceDraftFromValues({
  required String tenantId,
  required DateTime issueDate,
  required Iterable<Object> values,
  required BillingInvoiceLineItemAdapterRegistry adapterRegistry,
  double amount = 0,
  BillingBusinessDomainProfile? profile,
  String? domain,
  String? sourceType,
  BillingInvoiceTaxMode? taxMode,
}) {
  final resolvedDomain = domain ?? profile?.domain;
  final resolvedSourceType = sourceType ?? profile?.defaultSourceType;
  final lineItems = adapterRegistry.adaptAll(
    values,
    domain: resolvedDomain,
    type: resolvedSourceType,
  );

  return composeBillingInvoiceDraft(
    tenantId: tenantId,
    issueDate: issueDate,
    lineItems: lineItems,
    amount: amount,
    profile: profile,
    taxMode: taxMode,
  );
}
