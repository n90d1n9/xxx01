enum BillingTaxMode { exclusive, inclusive, exempt }

class BillingTenantPreferences {
  final String currencySymbol;
  final int? decimalDigits;
  final String datePattern;
  final String? locale;
  final int paymentTermsDays;
  final BillingTaxMode taxMode;
  final String businessDomain;

  const BillingTenantPreferences({
    this.currencySymbol = r'$',
    this.decimalDigits,
    this.datePattern = 'MMM d, yyyy',
    this.locale,
    this.paymentTermsDays = 30,
    this.taxMode = BillingTaxMode.exclusive,
    this.businessDomain = 'commerce',
  });

  BillingTenantPreferences copyWith({
    String? currencySymbol,
    int? decimalDigits,
    bool clearDecimalDigits = false,
    String? datePattern,
    String? locale,
    bool clearLocale = false,
    int? paymentTermsDays,
    BillingTaxMode? taxMode,
    String? businessDomain,
  }) {
    return BillingTenantPreferences(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      decimalDigits:
          clearDecimalDigits ? null : decimalDigits ?? this.decimalDigits,
      datePattern: datePattern ?? this.datePattern,
      locale: clearLocale ? null : locale ?? this.locale,
      paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
      taxMode: taxMode ?? this.taxMode,
      businessDomain: businessDomain ?? this.businessDomain,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingTenantPreferences &&
            other.currencySymbol == currencySymbol &&
            other.decimalDigits == decimalDigits &&
            other.datePattern == datePattern &&
            other.locale == locale &&
            other.paymentTermsDays == paymentTermsDays &&
            other.taxMode == taxMode &&
            other.businessDomain == businessDomain;
  }

  @override
  int get hashCode {
    return Object.hash(
      currencySymbol,
      decimalDigits,
      datePattern,
      locale,
      paymentTermsDays,
      taxMode,
      businessDomain,
    );
  }
}
