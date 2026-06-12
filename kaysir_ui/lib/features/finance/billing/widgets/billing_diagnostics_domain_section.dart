import 'package:flutter/material.dart';

import '../states/billing_diagnostics_domain_context_provider.dart';
import 'billing_business_domain_blueprint_fit_matrix_panel.dart';
import 'billing_business_domain_blueprint_launch_plan_panel.dart';
import 'billing_business_domain_blueprint_panel.dart';
import 'billing_business_domain_pack_remediation_panel.dart';
import 'billing_business_domain_pack_registry_readiness_panel.dart';
import 'billing_domain_module_catalog_panel.dart';
import 'billing_domain_module_registry_readiness_panel.dart';
import 'billing_navigation_destination.dart';
import 'domain_pack_contract_coverage_panel.dart';

/// Renders domain diagnostics for billing modules, packs, and extensions.
class BillingDiagnosticsDomainSection extends StatelessWidget {
  final BillingDiagnosticsDomainContext context;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingDiagnosticsDomainSection({
    super.key,
    required this.context,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BillingDomainModuleRegistryReadinessPanel(
          report: context.registryReadiness,
          maxVisibleModules: context.moduleCount,
        ),
        BillingBusinessDomainPackRegistryReadinessPanel(
          report: context.packReadiness,
          maxVisiblePacks: context.packCount,
        ),
        DomainPackContractCoveragePanel(
          report: context.packContractReport,
          remediationPlan: context.packRemediationPlan,
          onDestinationSelected: onDestinationSelected,
          maxVisibleContracts: context.packCount,
        ),
        BillingBusinessDomainPackRemediationPanel(
          plan: context.packRemediationPlan,
          onDestinationSelected: onDestinationSelected,
        ),
        BillingDomainModuleCatalogPanel(report: context.registryReadiness),
        BillingBusinessDomainBlueprintPanel(
          registry: context.blueprintRegistry,
        ),
        BillingBusinessDomainBlueprintFitMatrixPanel(matrix: context.fitMatrix),
        BillingBusinessDomainBlueprintLaunchPlanPanel(
          portfolio: context.launchPortfolio,
        ),
      ],
    );
  }
}
