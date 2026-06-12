import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_account.dart';
import 'billing_dashboard_provider.dart';
import 'billing_diagnostics_domain_context_provider.dart';
import 'billing_diagnostics_overview_provider.dart';
import 'billing_diagnostics_release_context_provider.dart';

class BillingDiagnosticsScreenContext {
  final BillingTenantAccount? selectedTenant;
  final BillingDiagnosticsOverview overview;
  final BillingDiagnosticsDomainContext domainContext;

  const BillingDiagnosticsScreenContext({
    required this.selectedTenant,
    required this.overview,
    required this.domainContext,
  });

  bool get hasTenant => selectedTenant?.id.isNotEmpty == true;

  String? get tenantName => selectedTenant?.name;

  String get tenantSubtitle {
    final planName = selectedTenant?.planName;
    if (planName != null && planName.isNotEmpty) return '$planName plan';

    return 'Billing module diagnostics';
  }

  BillingDiagnosticsReleaseContext get releaseContext {
    return overview.releaseContext;
  }
}

final billingDiagnosticsScreenContextProvider =
    Provider<BillingDiagnosticsScreenContext>((ref) {
      final currentTenantId = ref.watch(selectedBillingTenantIdProvider);
      final tenantsAsync = ref.watch(billingTenantsProvider);
      final selectedTenant = tenantsAsync.maybeWhen(
        data:
            (tenants) => _selectedTenant(
              tenants: tenants,
              currentTenantId: currentTenantId,
            ),
        orElse: () => null,
      );
      final hasTenant = selectedTenant?.id.isNotEmpty == true;
      final overviewRequest =
          selectedTenant == null
              ? const BillingDiagnosticsOverviewRequest()
              : BillingDiagnosticsOverviewRequest.fromTenant(
                preferences: selectedTenant.preferences,
                tenantId: selectedTenant.id,
              );
      final overview = ref.watch(
        billingDiagnosticsOverviewProvider(overviewRequest),
      );

      return BillingDiagnosticsScreenContext(
        selectedTenant: selectedTenant,
        overview: overview,
        domainContext: ref.watch(
          billingDiagnosticsDomainContextProvider(hasTenant),
        ),
      );
    });

BillingTenantAccount? _selectedTenant({
  required List<BillingTenantAccount> tenants,
  required String currentTenantId,
}) {
  if (tenants.isEmpty) return null;

  return tenants.firstWhere(
    (tenant) => tenant.id == currentTenantId,
    orElse: () => tenants.first,
  );
}
