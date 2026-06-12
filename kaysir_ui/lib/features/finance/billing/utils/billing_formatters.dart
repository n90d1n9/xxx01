import 'package:intl/intl.dart';

import '../models/billing_tenant_preferences.dart';

String formatBillingCurrency(
  num amount, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  String? symbol,
  int? decimalDigits,
  String? locale,
}) {
  return NumberFormat.currency(
    locale: locale ?? preferences.locale,
    symbol: symbol ?? preferences.currencySymbol,
    decimalDigits: decimalDigits ?? preferences.decimalDigits,
  ).format(amount);
}

String formatBillingDate(
  DateTime date, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  String? pattern,
  String? locale,
}) {
  return DateFormat(
    pattern ?? preferences.datePattern,
    locale ?? preferences.locale,
  ).format(date);
}
