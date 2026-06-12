import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/billing_release_gate.dart';
import '../widgets/billing_diagnostics_section_profile.dart';
import '../widgets/billing_diagnostics_section_registry.dart';
import '../widgets/billing_release_gate_lane_target.dart';
import '../widgets/standard_billing_diagnostics_section_profiles.dart';
import 'billing_business_domain_pack_provider.dart';
import 'billing_diagnostics_screen_context_provider.dart';
import 'billing_route_contract_provider.dart';

final billingDiagnosticsSectionProfileCatalogProvider =
    Provider<BillingDiagnosticsSectionProfileCatalog>((ref) {
      return ref
          .watch(billingBusinessDomainPackRegistryProvider)
          .diagnosticsProfileCatalog;
    });

final billingDiagnosticsSectionRegistryProvider =
    Provider<BillingDiagnosticsSectionRegistry>((ref) {
      final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);
      final catalog = ref.watch(
        billingDiagnosticsSectionProfileCatalogProvider,
      );

      return billingDiagnosticsSectionRegistryForBusinessDomain(
        screenContext.overview.businessDomain,
        catalog: catalog,
      );
    });

final billingReleaseGateLaneTargetRegistryProvider =
    Provider<BillingReleaseGateLaneTargetRegistry>((ref) {
      final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);
      final packRegistry = ref.watch(billingBusinessDomainPackRegistryProvider);

      return standardBillingReleaseGateLaneTargetRegistry(
        extensions: packRegistry.releaseGateLaneTargetsForBusinessDomain(
          screenContext.overview.businessDomain,
        ),
      );
    });

final billingDiagnosticsReleaseGateReportProvider =
    Provider<BillingReleaseGateReport>((ref) {
      final coreReport = ref.watch(billingReleaseGateReportProvider);
      final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);
      final packRegistry = ref.watch(billingBusinessDomainPackRegistryProvider);

      final extensionLanes = packRegistry.releaseGateLanesForBusinessDomain(
        screenContext.overview.businessDomain,
      );
      if (extensionLanes.isEmpty) return coreReport;

      return BillingReleaseGateReport(
        lanes: [...coreReport.lanes, ...extensionLanes],
      );
    });
