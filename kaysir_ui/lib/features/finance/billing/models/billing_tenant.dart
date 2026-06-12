import 'billing_tenant_preferences.dart';

class Tenant {
  final String id;
  final String name;
  final String logoUrl;
  final BillingTenantPreferences preferences;

  const Tenant({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.preferences = const BillingTenantPreferences(),
  });
}
