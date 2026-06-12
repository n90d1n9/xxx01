import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_formatters.dart';

void main() {
  test('formatBillingCurrency formats the default billing currency', () {
    expect(formatBillingCurrency(1250), r'$1,250.00');
    expect(formatBillingCurrency(1250.5), r'$1,250.50');
  });

  test('formatBillingCurrency supports alternate symbols and precision', () {
    expect(formatBillingCurrency(1250, symbol: 'Rp '), 'Rp 1,250.00');
    expect(formatBillingCurrency(1250, decimalDigits: 0), r'$1,250');
  });

  test('formatBillingCurrency supports tenant preferences', () {
    const preferences = BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
    );

    expect(formatBillingCurrency(1250.5, preferences: preferences), 'Rp 1,251');
  });

  test('formatBillingDate uses billing display date by default', () {
    expect(formatBillingDate(DateTime(2026, 6, 10)), 'Jun 10, 2026');
  });

  test('formatBillingDate supports alternate patterns', () {
    expect(
      formatBillingDate(DateTime(2026, 6, 10), pattern: 'yyyy-MM-dd'),
      '2026-06-10',
    );
  });

  test('formatBillingDate supports tenant preferences', () {
    const preferences = BillingTenantPreferences(datePattern: 'yyyy-MM-dd');

    expect(
      formatBillingDate(DateTime(2026, 6, 10), preferences: preferences),
      '2026-06-10',
    );
  });
}
