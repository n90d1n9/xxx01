import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';

void main() {
  test('product release edition providers expose sellable variants', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryCatalog = container.read(
      billingBusinessDomainModuleProductReleaseEditionCatalogProvider(true),
    );
    final blockedCatalog = container.read(
      billingBusinessDomainModuleProductReleaseEditionCatalogProvider(false),
    );
    final defaultCatalog = container.read(
      billingDefaultDomainModuleProductReleaseEditionCatalogProvider(true),
    );
    final constructionCatalog = container.read(
      billingTenantDomainModuleProductReleaseEditionCatalogProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryCatalog.editionCount, 5);
    expect(registryCatalog.publishNowCount, 1);
    expect(registryCatalog.reviewCount, 4);
    expect(
      registryCatalog.requirePlanForEdition('commerce_essentials').releaseKeys,
      ['commerce_checkout:commerce', 'omni_channel_billing:commerce'],
    );
    expect(blockedCatalog.blockedCount, 5);
    expect(defaultCatalog.publishNowCount, 1);
    expect(defaultCatalog.blockedCount, 4);
    expect(constructionCatalog.reviewCount, 2);
    expect(constructionCatalog.blockedCount, 3);
  });
}
