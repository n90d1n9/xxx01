import '../models/billing_business_domain_profile.dart';
import '../models/billing_invoice_issue_policy.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../models/billing_payment_schedule.dart';

BillingInvoiceIssuePolicy billingInvoiceIssuePolicyForProfile(
  BillingBusinessDomainProfile profile, {
  BillingInvoiceTaxMode? taxMode,
  BillingPaymentScheduleOptions? paymentScheduleOptions,
}) {
  return BillingInvoiceIssuePolicy(
    domain: profile.domain,
    label: profile.label,
    taxMode: taxMode ?? profile.taxMode,
    paymentScheduleOptions:
        paymentScheduleOptions ??
        billingPaymentScheduleOptionsForProfile(profile),
    attributes: profile.attributes,
  );
}

BillingPaymentScheduleOptions? billingPaymentScheduleOptionsForProfile(
  BillingBusinessDomainProfile profile,
) {
  final attributes = profile.attributes;
  final strategy = _strategy(attributes['paymentScheduleStrategy']);

  if (strategy != null) {
    return _optionsForStrategy(strategy, attributes);
  }

  if (profile.supports(BillingBusinessDomainCapability.progressBilling)) {
    return BillingPaymentScheduleOptions.splitEqual(installments: 3);
  }

  if (profile.supports(BillingBusinessDomainCapability.retainers)) {
    return BillingPaymentScheduleOptions.upfrontAndBalance(upfrontRatio: 0.5);
  }

  return null;
}

BillingPaymentScheduleOptions _optionsForStrategy(
  String strategy,
  Map<String, String> attributes,
) {
  return switch (strategy) {
    'single' ||
    'single_due_date' ||
    'singleduedate' => BillingPaymentScheduleOptions.singleDueDate(),
    'split' ||
    'split_equal' ||
    'splitequal' ||
    'installments' => BillingPaymentScheduleOptions.splitEqual(
      installments: _positiveIntAttributeOrFallback(
        attributes,
        'paymentScheduleInstallments',
        fallback: 3,
      ),
      intervalDays: _positiveIntAttribute(
        attributes,
        'paymentScheduleIntervalDays',
      ),
    ),
    'deposit' ||
    'upfront' ||
    'upfront_balance' ||
    'upfrontandbalance' => BillingPaymentScheduleOptions.upfrontAndBalance(
      upfrontRatio: _ratioAttribute(
        attributes,
        'paymentScheduleUpfrontRatio',
        fallback: 0.5,
      ),
    ),
    _ =>
      throw StateError('Unknown billing payment schedule strategy $strategy.'),
  };
}

String? _strategy(String? value) {
  final normalized = value
      ?.trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');

  return normalized == null || normalized.isEmpty ? null : normalized;
}

int _positiveIntAttributeOrFallback(
  Map<String, String> attributes,
  String key, {
  required int fallback,
}) {
  return _positiveIntAttribute(attributes, key) ?? fallback;
}

int? _positiveIntAttribute(Map<String, String> attributes, String key) {
  final rawValue = attributes[key];
  if (rawValue == null || rawValue.trim().isEmpty) return null;

  final value = int.tryParse(rawValue);
  if (value == null || value <= 0) {
    throw StateError('Billing issue policy $key must be a positive integer.');
  }

  return value;
}

double _ratioAttribute(
  Map<String, String> attributes,
  String key, {
  required double fallback,
}) {
  final rawValue = attributes[key];
  if (rawValue == null || rawValue.trim().isEmpty) return fallback;

  final value = double.tryParse(rawValue);
  if (value == null || value <= 0 || value >= 1) {
    throw StateError('Billing issue policy $key must be between 0 and 1.');
  }

  return value;
}
