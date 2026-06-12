import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_command.dart';
import '../models/billing_invoice_issue_policy.dart';
import '../models/billing_invoice_line_item.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../models/billing_payment_schedule.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_invoice_issue_plan.dart';

BillingInvoiceIssueCommand buildBillingInvoiceIssueCommand(
  BillingInvoiceDraft draft, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  BillingInvoiceIssuePolicy? issuePolicy,
  BillingInvoiceTaxMode? taxMode,
  BillingPaymentScheduleOptions? paymentScheduleOptions,
  DateTime? requestedAt,
  String channel = 'manual',
  String? idempotencyKey,
  Map<String, String> attributes = const {},
}) {
  final resolvedRequestedAt = requestedAt ?? DateTime.now();
  final draftFingerprint = billingInvoiceDraftFingerprint(draft);
  final issuePlan = buildBillingInvoiceIssuePlan(
    draft,
    preferences: preferences,
    issuePolicy: issuePolicy,
    taxMode: taxMode,
    paymentScheduleOptions: paymentScheduleOptions,
  );

  return BillingInvoiceIssueCommand(
    idempotencyKey:
        idempotencyKey ??
        billingInvoiceIssueCommandKey(
          draft,
          channel: channel,
          draftFingerprint: draftFingerprint,
        ),
    draftFingerprint: draftFingerprint,
    draft: draft,
    issuePlan: issuePlan,
    requestedAt: resolvedRequestedAt,
    channel: channel,
    attributes: attributes,
  );
}

String billingInvoiceIssueCommandKey(
  BillingInvoiceDraft draft, {
  String channel = 'manual',
  String? draftFingerprint,
  DateTime? requestedAt,
}) {
  final resolvedTenantId =
      draft.tenantId.trim().isEmpty ? 'unknown' : draft.tenantId.trim();
  final resolvedChannel = channel.trim().isEmpty ? 'unknown' : channel.trim();
  final resolvedFingerprint =
      draftFingerprint ?? billingInvoiceDraftFingerprint(draft);

  return 'issue-${resolvedChannel.toLowerCase()}-$resolvedTenantId-${_stableFingerprintHash(resolvedFingerprint)}';
}

String billingInvoiceDraftFingerprint(BillingInvoiceDraft draft) {
  final buffer =
      StringBuffer('billing-invoice-draft:v1')
        ..write('|tenantId=${draft.tenantId.trim()}')
        ..write('|amount=${_number(draft.amount)}')
        ..write('|issueDate=${draft.issueDate.toIso8601String()}')
        ..write('|taxMode=${draft.taxMode.name}')
        ..write('|lineCount=${draft.lineItems.length}');

  for (final lineItem in draft.lineItems) {
    buffer.write('|line=${_lineItemFingerprint(lineItem)}');
  }

  return buffer.toString();
}

String _lineItemFingerprint(BillingInvoiceLineItem lineItem) {
  final source = lineItem.source;

  return [
    'id=${lineItem.id.trim()}',
    'description=${lineItem.description.trim()}',
    'quantity=${_number(lineItem.quantity)}',
    'unitPrice=${_number(lineItem.unitPrice)}',
    'unitLabel=${lineItem.unitLabel.trim()}',
    'discountAmount=${_number(lineItem.discountAmount)}',
    'taxable=${lineItem.taxable}',
    'taxRate=${_number(lineItem.taxRate)}',
    'servicePeriodStart=${_date(lineItem.servicePeriodStart)}',
    'servicePeriodEnd=${_date(lineItem.servicePeriodEnd)}',
    if (source == null)
      'source=null'
    else ...[
      'sourceDomain=${source.domain.trim()}',
      'sourceType=${source.type.trim()}',
      'sourceId=${source.id.trim()}',
      'sourceAttributes=${_attributes(source.attributes)}',
    ],
  ].join(',');
}

String _attributes(Map<String, String> attributes) {
  final keys = attributes.keys.toList()..sort();
  return keys.map((key) => '$key=${attributes[key]}').join(',');
}

String _date(DateTime? value) {
  return value?.toIso8601String() ?? '';
}

String _number(num value) {
  return value.toStringAsFixed(6);
}

String _stableFingerprintHash(String value) {
  var hash = 0x811c9dc5;

  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }

  return hash.toRadixString(16).padLeft(8, '0');
}
