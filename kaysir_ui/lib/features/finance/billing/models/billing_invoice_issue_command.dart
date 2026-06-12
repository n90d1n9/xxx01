import 'billing_invoice_draft.dart';
import 'billing_invoice_issue_plan.dart';
import 'billing_invoice_line_item.dart';

class BillingInvoiceIssueCommand {
  final String idempotencyKey;
  final String draftFingerprint;
  final BillingInvoiceDraft draft;
  final BillingInvoiceIssuePlan issuePlan;
  final DateTime requestedAt;
  final String channel;
  final Map<String, String> attributes;

  BillingInvoiceIssueCommand({
    required this.idempotencyKey,
    required this.draftFingerprint,
    required this.draft,
    required this.issuePlan,
    required this.requestedAt,
    this.channel = 'manual',
    Map<String, String> attributes = const {},
  }) : attributes = Map.unmodifiable(attributes);

  String get tenantId => draft.tenantId;

  double get total => issuePlan.total;

  bool get canIssue => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];

    if (idempotencyKey.trim().isEmpty) {
      errors.add('Invoice issue idempotency key is required.');
    }
    if (draftFingerprint.trim().isEmpty) {
      errors.add('Invoice issue draft fingerprint is required.');
    }
    if (channel.trim().isEmpty) {
      errors.add('Invoice issue channel is required.');
    }
    errors.addAll(issuePlan.validationErrors);

    return List.unmodifiable(errors);
  }

  BillingInvoiceIssueCommand copyWith({
    String? idempotencyKey,
    String? draftFingerprint,
    BillingInvoiceDraft? draft,
    BillingInvoiceIssuePlan? issuePlan,
    DateTime? requestedAt,
    String? channel,
    Map<String, String>? attributes,
  }) {
    return BillingInvoiceIssueCommand(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      draftFingerprint: draftFingerprint ?? this.draftFingerprint,
      draft: draft ?? this.draft,
      issuePlan: issuePlan ?? this.issuePlan,
      requestedAt: requestedAt ?? this.requestedAt,
      channel: channel ?? this.channel,
      attributes: attributes ?? this.attributes,
    );
  }

  void ensureCanIssue() {
    final errors = validationErrors;
    if (errors.isNotEmpty) {
      throw StateError(errors.first);
    }
  }

  Map<String, Object?> toPayload() {
    return Map.unmodifiable({
      'idempotencyKey': idempotencyKey,
      'draftFingerprint': draftFingerprint,
      'tenantId': tenantId,
      'channel': channel,
      'requestedAt': requestedAt.toIso8601String(),
      'issueDate': draft.issueDate.toIso8601String(),
      'dueDate': issuePlan.dueDate.toIso8601String(),
      'paymentTermsDays': issuePlan.paymentTermsDays,
      'paymentSchedule': issuePlan.paymentSchedule.toPayload(),
      'taxMode': issuePlan.taxMode.name,
      'lineCount': issuePlan.lineCount,
      'quantity': issuePlan.quantity,
      'subtotal': issuePlan.subtotal,
      'discount': issuePlan.discount,
      'tax': issuePlan.tax,
      'total': issuePlan.total,
      'attributes': Map<String, String>.unmodifiable(attributes),
      'lineItems': List<Map<String, Object?>>.unmodifiable(
        draft.lineItems.map(_lineItemPayload),
      ),
    });
  }
}

Map<String, Object?> _lineItemPayload(BillingInvoiceLineItem lineItem) {
  return Map.unmodifiable({
    'id': lineItem.id,
    'description': lineItem.description,
    'quantity': lineItem.quantity,
    'unitPrice': lineItem.unitPrice,
    'unitLabel': lineItem.unitLabel,
    'discountAmount': lineItem.discountAmount,
    'subtotal': lineItem.subtotal,
    'discount': lineItem.discount,
    'netSubtotal': lineItem.netSubtotal,
    'taxable': lineItem.taxable,
    'taxRate': lineItem.taxRate,
    'servicePeriodStart': lineItem.servicePeriodStart?.toIso8601String(),
    'servicePeriodEnd': lineItem.servicePeriodEnd?.toIso8601String(),
    'source':
        lineItem.source == null
            ? null
            : Map<String, Object?>.unmodifiable({
              'domain': lineItem.source!.domain,
              'type': lineItem.source!.type,
              'id': lineItem.source!.id,
              'attributes': Map<String, String>.unmodifiable(
                lineItem.source!.attributes,
              ),
            }),
  });
}
