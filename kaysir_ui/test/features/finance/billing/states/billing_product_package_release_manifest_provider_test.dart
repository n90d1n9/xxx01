import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_manifest.dart';

void main() {
  test('product package release manifest providers expose product outputs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryCatalog = container.read(
      billingBusinessDomainModuleProductPackageReleaseManifestCatalogProvider(
        true,
      ),
    );
    final blockedCatalog = container.read(
      billingBusinessDomainModuleProductPackageReleaseManifestCatalogProvider(
        false,
      ),
    );
    final defaultCatalog = container.read(
      billingDefaultDomainModuleProductPackageReleaseManifestCatalogProvider(
        true,
      ),
    );
    final constructionCatalog = container.read(
      billingTenantDomainModuleProductPackageReleaseManifestCatalogProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryCatalog.releaseReadyCount, 2);
    expect(registryCatalog.hardeningCount, 3);
    expect(
      registryCatalog.requireManifestForPackage('commerce_checkout').releaseKey,
      'commerce_checkout:commerce',
    );
    expect(blockedCatalog.blockedCount, 5);
    expect(defaultCatalog.releaseReadyCount, 2);
    expect(defaultCatalog.fitGapCount, 3);
    expect(constructionCatalog.hardeningCount, 2);
    expect(
      constructionCatalog.requireManifestForPackage('service_operations').state,
      BillingProductPackageReleaseState.needsHardening,
    );
  });
}
