import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_launch_playbook.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_package_plan.dart';

void main() {
  test('product package launch playbook providers expose release actions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryPlaybook = container.read(
      billingBusinessDomainModuleProductPackageLaunchPlaybookProvider(true),
    );
    final blockedPlaybook = container.read(
      billingBusinessDomainModuleProductPackageLaunchPlaybookProvider(false),
    );
    final defaultPlaybook = container.read(
      billingDefaultDomainModuleProductPackageLaunchPlaybookProvider(true),
    );
    final constructionPlaybook = container.read(
      billingTenantDomainModuleProductPackageLaunchPlaybookProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryPlaybook.packageNowCount, 2);
    expect(registryPlaybook.hardenCount, 3);
    expect(
      registryPlaybook.requirePrimaryActionForPackage('commerce_checkout').kind,
      BillingProductPackageLaunchActionKind.package,
    );
    expect(blockedPlaybook.blockedCount, 5);
    expect(defaultPlaybook.packageNowCount, 2);
    expect(defaultPlaybook.unavailableCount, 3);
    expect(constructionPlaybook.hardenCount, 2);
    expect(
      constructionPlaybook
          .requirePrimaryActionForPackage('service_operations')
          .lane,
      BillingProductPackageLane.harden,
    );
  });
}
