import '../models/billing_tenant.dart';

abstract class BillingProductTenantRepository {
  Future<List<Tenant>> fetchTenants();
}

class DemoBillingProductTenantRepository
    implements BillingProductTenantRepository {
  final Duration latency;

  const DemoBillingProductTenantRepository({
    this.latency = const Duration(milliseconds: 600),
  });

  @override
  Future<List<Tenant>> fetchTenants() async {
    await _wait();
    return const [
      Tenant(id: 't1', name: 'Acme Corp', logoUrl: ''),
      Tenant(id: 't2', name: 'TechStart Inc', logoUrl: ''),
      Tenant(id: 't3', name: 'Bright Solutions', logoUrl: ''),
      Tenant(id: 't4', name: 'Global Services', logoUrl: ''),
      Tenant(id: 't5', name: 'Metro Media', logoUrl: ''),
      Tenant(id: 't6', name: 'Health Partners', logoUrl: ''),
    ];
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
