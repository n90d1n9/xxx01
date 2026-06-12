import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_release_bundle.dart';

void main() {
  test('product package release bundle providers expose staged rollouts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryCatalog = container.read(
      billingBusinessDomainModuleProductPackageReleaseBundleCatalogProvider(
        true,
      ),
    );
    final blockedCatalog = container.read(
      billingBusinessDomainModuleProductPackageReleaseBundleCatalogProvider(
        false,
      ),
    );
    final defaultCatalog = container.read(
      billingDefaultDomainModuleProductPackageReleaseBundleCatalogProvider(
        true,
      ),
    );
    final constructionCatalog = container.read(
      billingTenantDomainModuleProductPackageReleaseBundleCatalogProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryCatalog.bundleCount, 2);
    expect(registryCatalog.publishNowManifestCount, 2);
    expect(registryCatalog.reviewManifestCount, 3);
    expect(
      registryCatalog
          .requireBundleForState(
            BillingProductPackageReleaseBundleState.publishNow,
          )
          .releaseKeys,
      ['commerce_checkout:commerce', 'omni_channel_billing:commerce'],
    );
    expect(blockedCatalog.blockedManifestCount, 5);
    expect(defaultCatalog.publishNowManifestCount, 2);
    expect(defaultCatalog.blockedManifestCount, 3);
    expect(constructionCatalog.reviewManifestCount, 2);
    expect(constructionCatalog.blockedManifestCount, 3);
  });
}
