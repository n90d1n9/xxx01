import 'billing_invoice_tax_mode.dart';
import 'billing_payment_schedule.dart';

class BillingInvoiceIssuePolicy {
  final String domain;
  final String label;
  final BillingInvoiceTaxMode taxMode;
  final BillingPaymentScheduleOptions? paymentScheduleOptions;
  final Map<String, String> attributes;

  BillingInvoiceIssuePolicy({
    required this.domain,
    required this.label,
    required this.taxMode,
    this.paymentScheduleOptions,
    Map<String, String> attributes = const {},
  }) : attributes = Map.unmodifiable(attributes);

  bool get hasPaymentSchedulePolicy => paymentScheduleOptions != null;

  List<String> get validationErrors {
    final errors = <String>[];

    if (domain.trim().isEmpty) {
      errors.add('Invoice issue policy domain is required.');
    }
    if (label.trim().isEmpty) {
      errors.add('Invoice issue policy label is required.');
    }

    return List.unmodifiable(errors);
  }

  BillingInvoiceIssuePolicy copyWith({
    String? domain,
    String? label,
    BillingInvoiceTaxMode? taxMode,
    Object? paymentScheduleOptions = _unset,
    Map<String, String>? attributes,
  }) {
    return BillingInvoiceIssuePolicy(
      domain: domain ?? this.domain,
      label: label ?? this.label,
      taxMode: taxMode ?? this.taxMode,
      paymentScheduleOptions:
          identical(paymentScheduleOptions, _unset)
              ? this.paymentScheduleOptions
              : paymentScheduleOptions as BillingPaymentScheduleOptions?,
      attributes: attributes ?? this.attributes,
    );
  }
}

const _unset = Object();
