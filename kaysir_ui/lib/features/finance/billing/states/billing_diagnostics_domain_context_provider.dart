import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/billing_business_domain_blueprint.dart';
import '../utils/billing_business_domain_blueprint_fit_matrix.dart';
import '../utils/billing_business_domain_blueprint_launch_plan.dart';
import '../utils/billing_business_domain_module_readiness.dart';
import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/domain_pack_contract.dart';
import 'billing_business_domain_pack_provider.dart';
import 'billing_business_domain_blueprint_provider.dart';
import 'billing_business_domain_profile_provider.dart';

/// Aggregates the domain-pack diagnostics data needed by the billing screen.
class BillingDiagnosticsDomainContext {
  final bool hasTenant;
  final BillingDomainModuleRegistryReadinessReport registryReadiness;
  final BillingBusinessDomainPackRegistryReadinessReport packReadiness;
  final DomainPackContractRegistryReport packContractReport;
  final BillingBusinessDomainBlueprintRegistry blueprintRegistry;
  final BillingBusinessDomainBlueprintFitMatrix fitMatrix;
  final BillingBusinessDomainBlueprintLaunchPortfolio launchPortfolio;

  const BillingDiagnosticsDomainContext({
    required this.hasTenant,
    required this.registryReadiness,
    required this.packReadiness,
    required this.packContractReport,
    required this.blueprintRegistry,
    required this.fitMatrix,
    required this.launchPortfolio,
  });

  int get moduleCount => registryReadiness.moduleReports.length;

  int get packCount => packReadiness.packReports.length;

  int get blueprintCount => blueprintRegistry.blueprints.length;

  int get fitRowCount => fitMatrix.rows.length;

  int get launchPlanCount => launchPortfolio.domainCount;

  bool get isLaunchReady => registryReadiness.isReady;

  bool get isPackReady => packReadiness.isReady;

  bool get isPackContractReleaseReady => packContractReport.isReleaseReady;

  int get packContractOpenRequirementCount {
    return packContractReport.openRequirementCount;
  }

  int get packContractBlockedRequirementCount {
    return packContractReport.blockedRequirementCount;
  }

  int get packContractWarningRequirementCount {
    return packContractReport.warningRequirementCount;
  }

  BillingBusinessDomainPackRegistryRemediationPlan get packRemediationPlan {
    return BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      packReadiness,
    );
  }
}

final billingDiagnosticsDomainContextProvider =
    Provider.family<BillingDiagnosticsDomainContext, bool>((ref, hasTenant) {
      return BillingDiagnosticsDomainContext(
        hasTenant: hasTenant,
        registryReadiness: ref.watch(
          billingBusinessDomainModuleRegistryReadinessProvider(hasTenant),
        ),
        packReadiness: ref.watch(
          billingBusinessDomainPackRegistryReadinessProvider(hasTenant),
        ),
        packContractReport: ref.watch(
          billingBusinessDomainPackContractRegistryProvider(hasTenant),
        ),
        blueprintRegistry: ref.watch(
          billingBusinessDomainModuleBlueprintRegistryProvider(hasTenant),
        ),
        fitMatrix: ref.watch(
          billingBusinessDomainModuleBlueprintFitMatrixProvider(hasTenant),
        ),
        launchPortfolio: ref.watch(
          billingBusinessDomainModuleBlueprintLaunchPortfolioProvider(
            hasTenant,
          ),
        ),
      );
    });
