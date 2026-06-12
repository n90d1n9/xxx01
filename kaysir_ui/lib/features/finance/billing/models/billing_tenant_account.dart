import 'billing_tenant_preferences.dart';

class BillingTenantAccount {
  final String id;
  final String name;
  final String logoUrl;
  final String planName;
  final double currentBalance;
  final BillingTenantPreferences preferences;

  const BillingTenantAccount({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.planName,
    required this.currentBalance,
    this.preferences = const BillingTenantPreferences(),
  });
}
