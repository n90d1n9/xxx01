import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../utils/billing_product_package_launch_playbook.dart';
import '../utils/billing_product_package_plan.dart';
import '../utils/billing_product_package_release_bundle.dart';
import '../utils/billing_product_package_release_manifest.dart';
import '../utils/billing_product_release_channel.dart';
import '../utils/billing_product_release_edition.dart';
import '../widgets/billing_navigation_destination.dart';
import '../widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import '../widgets/billing_product_release_channel_launch_queue.dart';
import '../widgets/billing_product_release_channel_launch_runbook.dart';
import 'billing_business_domain_blueprint_provider.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_product_release_channel_provider.dart';

class BillingDiagnosticsReleaseContextRequest {
  final BillingTenantPreferences preferences;
  final String tenantId;
  final BillingNavigationSurface currentSurface;

  const BillingDiagnosticsReleaseContextRequest({
    this.preferences = const BillingTenantPreferences(),
    this.tenantId = '',
    this.currentSurface = BillingNavigationSurface.dashboard,
  });

  factory BillingDiagnosticsReleaseContextRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
    BillingNavigationSurface currentSurface =
        BillingNavigationSurface.dashboard,
  }) {
    return BillingDiagnosticsReleaseContextRequest(
      preferences: preferences,
      tenantId: tenantId,
      currentSurface: currentSurface,
    );
  }

  bool get hasTenant => tenantId.isNotEmpty;

  String get businessDomain => preferences.businessDomain;

  BillingBusinessDomainBlueprintRequest get blueprintRequest {
    return BillingBusinessDomainBlueprintRequest(
      preferences: preferences,
      hasTenant: hasTenant,
    );
  }

  BillingDefaultNavigationDispatchSnapshotRequest get defaultDispatchRequest {
    return BillingDefaultNavigationDispatchSnapshotRequest(
      hasTenant: hasTenant,
      currentSurface: currentSurface,
    );
  }

  BillingNavigationDispatchSnapshotRequest get tenantDispatchRequest {
    return BillingNavigationDispatchSnapshotRequest(
      preferences: preferences,
      hasTenant: hasTenant,
      currentSurface: currentSurface,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingDiagnosticsReleaseContextRequest &&
            other.preferences == preferences &&
            other.tenantId == tenantId &&
            other.currentSurface == currentSurface;
  }

  @override
  int get hashCode {
    return Object.hash(preferences, tenantId, currentSurface);
  }
}

class BillingDiagnosticsReleaseContext {
  final bool isTenantScoped;
  final String businessDomain;
  final BillingProductPackagePortfolio packagePortfolio;
  final BillingProductPackageLaunchPlaybook packagePlaybook;
  final BillingProductPackageReleaseManifestCatalog releaseManifestCatalog;
  final BillingProductPackageReleaseBundleCatalog releaseBundleCatalog;
  final BillingProductReleaseEditionCatalog releaseEditionCatalog;
  final BillingProductReleaseChannelMatrix releaseChannelMatrix;
  final BillingProductReleaseChannelLaunchPlan releaseChannelLaunchPlan;
  final BillingProductReleaseChannelLaunchDispatchPlan
  releaseChannelLaunchDispatchPlan;
  final BillingProductReleaseChannelLaunchRunbook releaseChannelLaunchRunbook;
  final BillingProductReleaseChannelLaunchQueue releaseChannelLaunchQueue;

  const BillingDiagnosticsReleaseContext({
    required this.isTenantScoped,
    required this.businessDomain,
    required this.packagePortfolio,
    required this.packagePlaybook,
    required this.releaseManifestCatalog,
    required this.releaseBundleCatalog,
    required this.releaseEditionCatalog,
    required this.releaseChannelMatrix,
    required this.releaseChannelLaunchPlan,
    required this.releaseChannelLaunchDispatchPlan,
    required this.releaseChannelLaunchRunbook,
    required this.releaseChannelLaunchQueue,
  });

  bool get isDefaultScoped => !isTenantScoped;

  String get scopeLabel {
    if (isTenantScoped) return 'Tenant $businessDomain release context';

    return 'Default release context';
  }

  String get summaryLabel {
    return releaseChannelLaunchQueue.summaryLabel;
  }
}

final billingDiagnosticsReleaseContextProvider = Provider.family<
  BillingDiagnosticsReleaseContext,
  BillingDiagnosticsReleaseContextRequest
>((ref, request) {
  if (request.hasTenant) {
    return _tenantReleaseContext(ref, request);
  }

  return _defaultReleaseContext(ref, request);
});

BillingDiagnosticsReleaseContext _defaultReleaseContext(
  Ref ref,
  BillingDiagnosticsReleaseContextRequest request,
) {
  final dispatchRequest = request.defaultDispatchRequest;

  return BillingDiagnosticsReleaseContext(
    isTenantScoped: false,
    businessDomain: request.businessDomain,
    packagePortfolio: ref.watch(
      billingDefaultDomainModuleProductPackagePortfolioProvider(
        request.hasTenant,
      ),
    ),
    packagePlaybook: ref.watch(
      billingDefaultDomainModuleProductPackageLaunchPlaybookProvider(
        request.hasTenant,
      ),
    ),
    releaseManifestCatalog: ref.watch(
      billingDefaultDomainModuleProductPackageReleaseManifestCatalogProvider(
        request.hasTenant,
      ),
    ),
    releaseBundleCatalog: ref.watch(
      billingDefaultDomainModuleProductPackageReleaseBundleCatalogProvider(
        request.hasTenant,
      ),
    ),
    releaseEditionCatalog: ref.watch(
      billingDefaultDomainModuleProductReleaseEditionCatalogProvider(
        request.hasTenant,
      ),
    ),
    releaseChannelMatrix: ref.watch(
      billingDefaultDomainModuleProductReleaseChannelMatrixProvider(
        request.hasTenant,
      ),
    ),
    releaseChannelLaunchPlan: ref.watch(
      billingDefaultDomainModuleProductReleaseChannelLaunchPlanProvider(
        request.hasTenant,
      ),
    ),
    releaseChannelLaunchDispatchPlan: ref.watch(
      billingDefaultDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
        dispatchRequest,
      ),
    ),
    releaseChannelLaunchRunbook: ref.watch(
      billingDefaultDomainModuleProductReleaseChannelLaunchRunbookProvider(
        dispatchRequest,
      ),
    ),
    releaseChannelLaunchQueue: ref.watch(
      billingDefaultDomainModuleProductReleaseChannelLaunchQueueProvider(
        dispatchRequest,
      ),
    ),
  );
}

BillingDiagnosticsReleaseContext _tenantReleaseContext(
  Ref ref,
  BillingDiagnosticsReleaseContextRequest request,
) {
  final blueprintRequest = request.blueprintRequest;
  final dispatchRequest = request.tenantDispatchRequest;

  return BillingDiagnosticsReleaseContext(
    isTenantScoped: true,
    businessDomain: request.businessDomain,
    packagePortfolio: ref.watch(
      billingTenantDomainModuleProductPackagePortfolioProvider(
        blueprintRequest,
      ),
    ),
    packagePlaybook: ref.watch(
      billingTenantDomainModuleProductPackageLaunchPlaybookProvider(
        blueprintRequest,
      ),
    ),
    releaseManifestCatalog: ref.watch(
      billingTenantDomainModuleProductPackageReleaseManifestCatalogProvider(
        blueprintRequest,
      ),
    ),
    releaseBundleCatalog: ref.watch(
      billingTenantDomainModuleProductPackageReleaseBundleCatalogProvider(
        blueprintRequest,
      ),
    ),
    releaseEditionCatalog: ref.watch(
      billingTenantDomainModuleProductReleaseEditionCatalogProvider(
        blueprintRequest,
      ),
    ),
    releaseChannelMatrix: ref.watch(
      billingTenantDomainModuleProductReleaseChannelMatrixProvider(
        blueprintRequest,
      ),
    ),
    releaseChannelLaunchPlan: ref.watch(
      billingTenantDomainModuleProductReleaseChannelLaunchPlanProvider(
        blueprintRequest,
      ),
    ),
    releaseChannelLaunchDispatchPlan: ref.watch(
      billingTenantDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
        dispatchRequest,
      ),
    ),
    releaseChannelLaunchRunbook: ref.watch(
      billingTenantDomainModuleProductReleaseChannelLaunchRunbookProvider(
        dispatchRequest,
      ),
    ),
    releaseChannelLaunchQueue: ref.watch(
      billingTenantDomainModuleProductReleaseChannelLaunchQueueProvider(
        dispatchRequest,
      ),
    ),
  );
}
