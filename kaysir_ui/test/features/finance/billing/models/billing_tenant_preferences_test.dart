import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';

void main() {
  test('BillingTenantPreferences compares by value', () {
    const first = BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      datePattern: 'dd MMM yyyy',
      locale: 'id_ID',
      paymentTermsDays: 14,
      taxMode: BillingTaxMode.inclusive,
      businessDomain: 'commerce',
    );
    const second = BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
      datePattern: 'dd MMM yyyy',
      locale: 'id_ID',
      paymentTermsDays: 14,
      taxMode: BillingTaxMode.inclusive,
      businessDomain: 'commerce',
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test(
    'BillingTenantPreferences copyWith updates and clears optional fields',
    () {
      const preferences = BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        locale: 'id_ID',
        businessDomain: 'commerce',
      );

      final updated = preferences.copyWith(
        clearDecimalDigits: true,
        clearLocale: true,
        paymentTermsDays: 45,
        businessDomain: 'construction',
      );

      expect(updated.currencySymbol, 'Rp ');
      expect(updated.decimalDigits, isNull);
      expect(updated.locale, isNull);
      expect(updated.paymentTermsDays, 45);
      expect(updated.businessDomain, 'construction');
    },
  );
}
