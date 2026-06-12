import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_tenant_preferences.dart';
import '../utils/billing_business_domain_blueprint.dart';
import '../utils/billing_business_domain_blueprint_fit_matrix.dart';
import '../utils/billing_business_domain_blueprint_launch_plan.dart';
import '../utils/billing_product_package.dart';
import '../utils/billing_product_package_launch_playbook.dart';
import '../utils/billing_product_package_plan.dart';
import '../utils/billing_product_package_release_bundle.dart';
import '../utils/billing_product_package_release_manifest.dart';
import '../utils/billing_product_release_channel.dart';
import '../utils/billing_product_release_edition.dart';
import 'billing_business_domain_profile_provider.dart';

class BillingBusinessDomainBlueprintRequest {
  final BillingTenantPreferences preferences;
  final bool hasTenant;

  const BillingBusinessDomainBlueprintRequest({
    required this.preferences,
    required this.hasTenant,
  });

  factory BillingBusinessDomainBlueprintRequest.fromTenant({
    required BillingTenantPreferences preferences,
    required String tenantId,
  }) {
    return BillingBusinessDomainBlueprintRequest(
      preferences: preferences,
      hasTenant: tenantId.isNotEmpty,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingBusinessDomainBlueprintRequest &&
            other.preferences == preferences &&
            other.hasTenant == hasTenant;
  }

  @override
  int get hashCode => Object.hash(preferences, hasTenant);
}

final billingBusinessDomainModuleBlueprintRegistryProvider =
    Provider.family<BillingBusinessDomainBlueprintRegistry, bool>((
      ref,
      hasTenant,
    ) {
      return BillingBusinessDomainBlueprintRegistry.forRegistry(
        ref.watch(billingBusinessDomainModuleRegistryProvider),
        hasTenant: hasTenant,
      );
    });

final billingBusinessDomainModuleBlueprintFitMatrixProvider = Provider.family<
  BillingBusinessDomainBlueprintFitMatrix,
  bool
>((ref, hasTenant) {
  return BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    ref.watch(billingBusinessDomainModuleBlueprintRegistryProvider(hasTenant)),
  );
});

final billingBusinessDomainModuleBlueprintLaunchPortfolioProvider =
    Provider.family<BillingBusinessDomainBlueprintLaunchPortfolio, bool>((
      ref,
      hasTenant,
    ) {
      return BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
        ref.watch(
          billingBusinessDomainModuleBlueprintFitMatrixProvider(hasTenant),
        ),
      );
    });

final billingProductPackageRegistryProvider =
    Provider<BillingProductPackageRegistry>((ref) {
      return standardBillingProductPackageRegistry();
    });

final billingProductReleaseEditionRegistryProvider =
    Provider<BillingProductReleaseEditionRegistry>((ref) {
      return standardBillingProductReleaseEditionRegistry();
    });

final billingProductReleaseChannelRegistryProvider =
    Provider<BillingProductReleaseChannelRegistry>((ref) {
      return standardBillingProductReleaseChannelRegistry();
    });

final billingBusinessDomainModuleProductPackagePortfolioProvider =
    Provider.family<BillingProductPackagePortfolio, bool>((ref, hasTenant) {
      final fitMatrix = ref.watch(
        billingBusinessDomainModuleBlueprintFitMatrixProvider(hasTenant),
      );

      return BillingProductPackagePortfolio.forLaunchPortfolio(
        registry: ref.watch(billingProductPackageRegistryProvider),
        launchPortfolio: ref.watch(
          billingBusinessDomainModuleBlueprintLaunchPortfolioProvider(
            hasTenant,
          ),
        ),
        columns: fitMatrix.columns,
      );
    });

final billingBusinessDomainModuleProductPackageLaunchPlaybookProvider =
    Provider.family<BillingProductPackageLaunchPlaybook, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageLaunchPlaybook.forPortfolio(
        ref.watch(
          billingBusinessDomainModuleProductPackagePortfolioProvider(hasTenant),
        ),
      );
    });

final billingBusinessDomainModuleProductPackageReleaseManifestCatalogProvider =
    Provider.family<BillingProductPackageReleaseManifestCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: ref.watch(
          billingBusinessDomainModuleProductPackagePortfolioProvider(hasTenant),
        ),
        playbook: ref.watch(
          billingBusinessDomainModuleProductPackageLaunchPlaybookProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingBusinessDomainModuleProductPackageReleaseBundleCatalogProvider =
    Provider.family<BillingProductPackageReleaseBundleCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
        ref.watch(
          billingBusinessDomainModuleProductPackageReleaseManifestCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingBusinessDomainModuleProductReleaseEditionCatalogProvider =
    Provider.family<BillingProductReleaseEditionCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductReleaseEditionCatalog.forManifestCatalog(
        registry: ref.watch(billingProductReleaseEditionRegistryProvider),
        manifestCatalog: ref.watch(
          billingBusinessDomainModuleProductPackageReleaseManifestCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingBusinessDomainModuleProductReleaseChannelMatrixProvider =
    Provider.family<BillingProductReleaseChannelMatrix, bool>((ref, hasTenant) {
      return BillingProductReleaseChannelMatrix.forEditionCatalog(
        registry: ref.watch(billingProductReleaseChannelRegistryProvider),
        editionCatalog: ref.watch(
          billingBusinessDomainModuleProductReleaseEditionCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingDefaultDomainModuleBlueprintProvider =
    Provider.family<BillingBusinessDomainBlueprint, bool>((ref, hasTenant) {
      return BillingBusinessDomainBlueprint.forModule(
        ref.watch(billingDefaultBusinessDomainModuleProvider),
        hasTenant: hasTenant,
      );
    });

final billingDefaultDomainModuleBlueprintFitMatrixProvider =
    Provider.family<BillingBusinessDomainBlueprintFitMatrix, bool>((
      ref,
      hasTenant,
    ) {
      return _fitMatrixForBlueprint(
        ref.watch(billingDefaultDomainModuleBlueprintProvider(hasTenant)),
      );
    });

final billingDefaultDomainModuleBlueprintLaunchPortfolioProvider =
    Provider.family<BillingBusinessDomainBlueprintLaunchPortfolio, bool>((
      ref,
      hasTenant,
    ) {
      return BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
        ref.watch(
          billingDefaultDomainModuleBlueprintFitMatrixProvider(hasTenant),
        ),
      );
    });

final billingDefaultDomainModuleProductPackagePortfolioProvider =
    Provider.family<BillingProductPackagePortfolio, bool>((ref, hasTenant) {
      final fitMatrix = ref.watch(
        billingDefaultDomainModuleBlueprintFitMatrixProvider(hasTenant),
      );

      return BillingProductPackagePortfolio.forLaunchPortfolio(
        registry: ref.watch(billingProductPackageRegistryProvider),
        launchPortfolio: ref.watch(
          billingDefaultDomainModuleBlueprintLaunchPortfolioProvider(hasTenant),
        ),
        columns: fitMatrix.columns,
      );
    });

final billingDefaultDomainModuleProductPackageLaunchPlaybookProvider =
    Provider.family<BillingProductPackageLaunchPlaybook, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageLaunchPlaybook.forPortfolio(
        ref.watch(
          billingDefaultDomainModuleProductPackagePortfolioProvider(hasTenant),
        ),
      );
    });

final billingDefaultDomainModuleProductPackageReleaseManifestCatalogProvider =
    Provider.family<BillingProductPackageReleaseManifestCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: ref.watch(
          billingDefaultDomainModuleProductPackagePortfolioProvider(hasTenant),
        ),
        playbook: ref.watch(
          billingDefaultDomainModuleProductPackageLaunchPlaybookProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingDefaultDomainModuleProductPackageReleaseBundleCatalogProvider =
    Provider.family<BillingProductPackageReleaseBundleCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
        ref.watch(
          billingDefaultDomainModuleProductPackageReleaseManifestCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseEditionCatalogProvider =
    Provider.family<BillingProductReleaseEditionCatalog, bool>((
      ref,
      hasTenant,
    ) {
      return BillingProductReleaseEditionCatalog.forManifestCatalog(
        registry: ref.watch(billingProductReleaseEditionRegistryProvider),
        manifestCatalog: ref.watch(
          billingDefaultDomainModuleProductPackageReleaseManifestCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingDefaultDomainModuleProductReleaseChannelMatrixProvider =
    Provider.family<BillingProductReleaseChannelMatrix, bool>((ref, hasTenant) {
      return BillingProductReleaseChannelMatrix.forEditionCatalog(
        registry: ref.watch(billingProductReleaseChannelRegistryProvider),
        editionCatalog: ref.watch(
          billingDefaultDomainModuleProductReleaseEditionCatalogProvider(
            hasTenant,
          ),
        ),
      );
    });

final billingTenantDomainModuleBlueprintProvider = Provider.family<
  BillingBusinessDomainBlueprint,
  BillingBusinessDomainBlueprintRequest
>((ref, request) {
  return BillingBusinessDomainBlueprint.forModule(
    ref.watch(billingTenantDomainModuleProvider(request.preferences)),
    hasTenant: request.hasTenant,
  );
});

final billingTenantDomainModuleBlueprintFitMatrixProvider = Provider.family<
  BillingBusinessDomainBlueprintFitMatrix,
  BillingBusinessDomainBlueprintRequest
>((ref, request) {
  return _fitMatrixForBlueprint(
    ref.watch(billingTenantDomainModuleBlueprintProvider(request)),
  );
});

final billingTenantDomainModuleBlueprintLaunchPortfolioProvider =
    Provider.family<
      BillingBusinessDomainBlueprintLaunchPortfolio,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
        ref.watch(billingTenantDomainModuleBlueprintFitMatrixProvider(request)),
      );
    });

final billingTenantDomainModuleProductPackagePortfolioProvider =
    Provider.family<
      BillingProductPackagePortfolio,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      final fitMatrix = ref.watch(
        billingTenantDomainModuleBlueprintFitMatrixProvider(request),
      );

      return BillingProductPackagePortfolio.forLaunchPortfolio(
        registry: ref.watch(billingProductPackageRegistryProvider),
        launchPortfolio: ref.watch(
          billingTenantDomainModuleBlueprintLaunchPortfolioProvider(request),
        ),
        columns: fitMatrix.columns,
      );
    });

final billingTenantDomainModuleProductPackageLaunchPlaybookProvider =
    Provider.family<
      BillingProductPackageLaunchPlaybook,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductPackageLaunchPlaybook.forPortfolio(
        ref.watch(
          billingTenantDomainModuleProductPackagePortfolioProvider(request),
        ),
      );
    });

final billingTenantDomainModuleProductPackageReleaseManifestCatalogProvider =
    Provider.family<
      BillingProductPackageReleaseManifestCatalog,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductPackageReleaseManifestCatalog.forPortfolio(
        portfolio: ref.watch(
          billingTenantDomainModuleProductPackagePortfolioProvider(request),
        ),
        playbook: ref.watch(
          billingTenantDomainModuleProductPackageLaunchPlaybookProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductPackageReleaseBundleCatalogProvider =
    Provider.family<
      BillingProductPackageReleaseBundleCatalog,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
        ref.watch(
          billingTenantDomainModuleProductPackageReleaseManifestCatalogProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseEditionCatalogProvider =
    Provider.family<
      BillingProductReleaseEditionCatalog,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductReleaseEditionCatalog.forManifestCatalog(
        registry: ref.watch(billingProductReleaseEditionRegistryProvider),
        manifestCatalog: ref.watch(
          billingTenantDomainModuleProductPackageReleaseManifestCatalogProvider(
            request,
          ),
        ),
      );
    });

final billingTenantDomainModuleProductReleaseChannelMatrixProvider =
    Provider.family<
      BillingProductReleaseChannelMatrix,
      BillingBusinessDomainBlueprintRequest
    >((ref, request) {
      return BillingProductReleaseChannelMatrix.forEditionCatalog(
        registry: ref.watch(billingProductReleaseChannelRegistryProvider),
        editionCatalog: ref.watch(
          billingTenantDomainModuleProductReleaseEditionCatalogProvider(
            request,
          ),
        ),
      );
    });

BillingBusinessDomainBlueprintFitMatrix _fitMatrixForBlueprint(
  BillingBusinessDomainBlueprint blueprint,
) {
  return BillingBusinessDomainBlueprintFitMatrix.forRegistry(
    BillingBusinessDomainBlueprintRegistry(blueprints: [blueprint]),
  );
}
