import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../utils/billing_business_domain_module_readiness.dart';
import '../utils/billing_business_domain_pack_readiness.dart';
import '../utils/billing_business_domain_pack_remediation.dart';
import '../utils/domain_pack_contract.dart';
import '../widgets/billing_navigation_coverage_summary.dart';
import '../widgets/billing_navigation_destination.dart';
import '../widgets/billing_navigation_dispatch_snapshot.dart';
import '../widgets/billing_navigation_launch_snapshot.dart';
import 'billing_business_domain_pack_provider.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_diagnostics_release_context_provider.dart';

class BillingDiagnosticsOverviewRequest {
  final BillingTenantPreferences preferences;
  final String tenantId;
  final BillingNavigationSurface currentSurface;

  const BillingDiagnosticsOverviewRequest({
    this.preferences = const BillingTenantPreferences(),
    this.tenantId = '',
    this.currentSurface = BillingNavigationSurface.dashboard,
  });

  factory BillingDiagnosticsOverviewRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    BillingNavigationSurface currentSurface =
        BillingNavigationSurface.dashboard,
  }) {
    return BillingDiagnosticsOverviewRequest(
      preferences: preferences,
      tenantId: tenantId,
      currentSurface: currentSurface,
    );
  }

  bool get hasTenant => tenantId.isNotEmpty;

  String get businessDomain => preferences.businessDomain;

  BillingNavigationLaunchPlannerRequest get launchPlannerRequest {
    return BillingNavigationLaunchPlannerRequest(
      preferences: preferences,
      hasTenant: hasTenant,
    );
  }

  BillingDiagnosticsReleaseContextRequest get releaseContextRequest {
    if (!hasTenant) {
      return BillingDiagnosticsReleaseContextRequest(
        preferences: preferences,
        currentSurface: currentSurface,
      );
    }

    return BillingDiagnosticsReleaseContextRequest.fromTenant(
      preferences: preferences,
      tenantId: tenantId,
      currentSurface: currentSurface,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingDiagnosticsOverviewRequest &&
            other.preferences == preferences &&
            other.tenantId == tenantId &&
            other.currentSurface == currentSurface;
  }

  @override
  int get hashCode {
    return Object.hash(preferences, tenantId, currentSurface);
  }
}

class BillingDiagnosticsOverview {
  final BillingDiagnosticsOverviewRequest request;
  final BillingNavigationLaunchSnapshot destinationLaunchSnapshot;
  final BillingNavigationDispatchSnapshot destinationDispatchSnapshot;
  final BillingNavigationCoverageSummary coverageSummary;
  final BillingDomainModuleRegistryReadinessReport registryReadiness;
  final BillingBusinessDomainPackRegistryReadinessReport packReadiness;
  final DomainPackContractRegistryReport packContract;
  final BillingDiagnosticsReleaseContext releaseContext;

  const BillingDiagnosticsOverview({
    required this.request,
    required this.destinationLaunchSnapshot,
    required this.destinationDispatchSnapshot,
    required this.coverageSummary,
    required this.registryReadiness,
    required this.packReadiness,
    required this.packContract,
    required this.releaseContext,
  });

  bool get hasTenant => request.hasTenant;

  bool get isTenantScoped => request.hasTenant;

  bool get isDefaultScoped => !isTenantScoped;

  String get businessDomain => request.businessDomain;

  String get scopeLabel {
    if (isTenantScoped) return 'Tenant $businessDomain diagnostics';

    return 'Default diagnostics';
  }

  String get readinessSummaryLabel => registryReadiness.summaryLabel;

  String get navigationSummaryLabel => coverageSummary.summaryLabel;

  String get releaseSummaryLabel => releaseContext.summaryLabel;

  int get moduleCount => registryReadiness.moduleReports.length;

  int get packCount => packReadiness.packReports.length;

  int get blockerCount => registryReadiness.blockerIssueCount;

  int get warningCount => registryReadiness.warningIssueCount;

  int get packBlockerCount => packReadiness.blockerIssueCount;

  int get packWarningCount => packReadiness.warningIssueCount;

  String get packReadinessSummaryLabel => packReadiness.summaryLabel;

  String get packContractSummaryLabel => packContract.summaryLabel;

  int get packContractOpenRequirementCount {
    return packContract.openRequirementCount;
  }

  int get packContractBlockedRequirementCount {
    return packContract.blockedRequirementCount;
  }

  int get packContractWarningRequirementCount {
    return packContract.warningRequirementCount;
  }

  bool get isPackContractFullySpecified => packContract.isFullySpecified;

  BillingBusinessDomainPackRegistryRemediationPlan get packRemediationPlan {
    return BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      packReadiness,
    );
  }

  String get remediationSummaryLabel => packRemediationPlan.summaryLabel;

  int get remediationActionCount => packRemediationPlan.actionCount;

  int get remediationBlockerActionCount {
    return packRemediationPlan.blockerActionCount;
  }

  int get remediationWarningActionCount {
    return packRemediationPlan.warningActionCount;
  }

  int get navigationGapCount => coverageSummary.issueCount;

  int get launchTaskCount => releaseContext.releaseChannelLaunchQueue.itemCount;

  int get readyLaunchTaskCount {
    return releaseContext.releaseChannelLaunchQueue.readyNowCount;
  }

  int get blockedLaunchTaskCount {
    return releaseContext.releaseChannelLaunchQueue.blockedCount;
  }

  bool get hasNavigationGaps => coverageSummary.hasIssues;

  bool get hasLaunchBlockers => blockedLaunchTaskCount > 0;
}

final billingDiagnosticsOverviewProvider = Provider.family<
  BillingDiagnosticsOverview,
  BillingDiagnosticsOverviewRequest
>((ref, request) {
  final releaseContextRequest = request.releaseContextRequest;
  final destinationLaunchSnapshot =
      request.hasTenant
          ? ref.watch(
            billingTenantDomainModuleDestinationLaunchSnapshotProvider(
              request.launchPlannerRequest,
            ),
          )
          : ref.watch(
            billingDefaultDomainModuleDestinationLaunchSnapshotProvider(false),
          );
  final destinationDispatchSnapshot =
      request.hasTenant
          ? ref.watch(
            billingTenantDomainModuleDestinationDispatchSnapshotProvider(
              releaseContextRequest.tenantDispatchRequest,
            ),
          )
          : ref.watch(
            billingDefaultDomainModuleDestinationDispatchSnapshotProvider(
              releaseContextRequest.defaultDispatchRequest,
            ),
          );
  final coverageSummary =
      request.hasTenant
          ? ref
              .watch(
                billingTenantDomainModuleNavigationCoverageProvider(
                  request.launchPlannerRequest,
                ),
              )
              .summary
          : ref
              .watch(
                billingDefaultDomainModuleNavigationCoverageProvider(false),
              )
              .summary;

  return BillingDiagnosticsOverview(
    request: request,
    destinationLaunchSnapshot: destinationLaunchSnapshot,
    destinationDispatchSnapshot: destinationDispatchSnapshot,
    coverageSummary: coverageSummary,
    registryReadiness: ref.watch(
      billingBusinessDomainModuleRegistryReadinessProvider(request.hasTenant),
    ),
    packReadiness: ref.watch(
      billingBusinessDomainPackRegistryReadinessProvider(request.hasTenant),
    ),
    packContract: ref.watch(
      billingBusinessDomainPackContractRegistryProvider(request.hasTenant),
    ),
    releaseContext: ref.watch(
      billingDiagnosticsReleaseContextProvider(releaseContextRequest),
    ),
  );
});
