import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';

void main() {
  test('product release channel matrix providers expose channel targets', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryMatrix = container.read(
      billingBusinessDomainModuleProductReleaseChannelMatrixProvider(true),
    );
    final blockedMatrix = container.read(
      billingBusinessDomainModuleProductReleaseChannelMatrixProvider(false),
    );
    final defaultMatrix = container.read(
      billingDefaultDomainModuleProductReleaseChannelMatrixProvider(true),
    );
    final constructionMatrix = container.read(
      billingTenantDomainModuleProductReleaseChannelMatrixProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryMatrix.channelCount, 5);
    expect(registryMatrix.publishNowCellCount, 2);
    expect(registryMatrix.reviewCellCount, 12);
    expect(blockedMatrix.blockedCellCount, 14);
    expect(defaultMatrix.publishNowCellCount, 2);
    expect(defaultMatrix.blockedCellCount, 12);
    expect(constructionMatrix.reviewCellCount, 5);
    expect(constructionMatrix.blockedCellCount, 9);
  });
}
