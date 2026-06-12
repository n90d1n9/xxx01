import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_blueprint_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_profile_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_release_channel_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('product release channel launch plan providers expose actions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registryPlan = container.read(
      billingBusinessDomainModuleProductReleaseChannelLaunchPlanProvider(true),
    );
    final blockedPlan = container.read(
      billingBusinessDomainModuleProductReleaseChannelLaunchPlanProvider(false),
    );
    final defaultPlan = container.read(
      billingDefaultDomainModuleProductReleaseChannelLaunchPlanProvider(true),
    );
    final constructionPlan = container.read(
      billingTenantDomainModuleProductReleaseChannelLaunchPlanProvider(
        const BillingBusinessDomainBlueprintRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
        ),
      ),
    );

    expect(registryPlan.actionCount, 14);
    expect(registryPlan.publishNowCount, 2);
    expect(registryPlan.reviewCount, 12);
    expect(blockedPlan.blockedCount, 14);
    expect(defaultPlan.publishNowCount, 2);
    expect(defaultPlan.blockedCount, 12);
    expect(constructionPlan.reviewCount, 5);
    expect(constructionPlan.blockedCount, 9);
  });

  test('product release channel launch dispatch providers expose routes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final defaultDispatchPlan = container.read(
      billingDefaultDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
        const BillingDefaultNavigationDispatchSnapshotRequest(
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );
    final constructionDispatchPlan = container.read(
      billingTenantDomainModuleProductReleaseChannelLaunchDispatchPlanProvider(
        const BillingNavigationDispatchSnapshotRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );

    expect(defaultDispatchPlan.entryCount, 14);
    expect(defaultDispatchPlan.actionableCount, 2);
    expect(defaultDispatchPlan.unavailableCount, 12);
    expect(
      defaultDispatchPlan
          .requireEntryForTarget(
            channelId: 'pos_counter',
            editionId: 'commerce_essentials',
          )
          .destinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(constructionDispatchPlan.entryCount, 14);
    expect(constructionDispatchPlan.actionableCount, 5);
    expect(constructionDispatchPlan.unavailableCount, 9);
  });

  test('product release channel launch runbook providers expose steps', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final defaultRunbook = container.read(
      billingDefaultDomainModuleProductReleaseChannelLaunchRunbookProvider(
        const BillingDefaultNavigationDispatchSnapshotRequest(
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );
    final constructionRunbook = container.read(
      billingTenantDomainModuleProductReleaseChannelLaunchRunbookProvider(
        const BillingNavigationDispatchSnapshotRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );

    expect(defaultRunbook.stepCount, 14);
    expect(defaultRunbook.actionableStepCount, 2);
    expect(defaultRunbook.needsWorkStepCount, 12);
    expect(
      defaultRunbook
          .requireGroupForDestination(
            BillingNavigationDestinationId.cartCheckout,
          )
          .steps
          .single
          .callToActionLabel,
      'Open checkout',
    );
    expect(constructionRunbook.stepCount, 14);
    expect(constructionRunbook.actionableStepCount, 5);
    expect(constructionRunbook.needsWorkStepCount, 9);
  });

  test('product release channel launch queue providers expose lanes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final defaultQueue = container.read(
      billingDefaultDomainModuleProductReleaseChannelLaunchQueueProvider(
        const BillingDefaultNavigationDispatchSnapshotRequest(
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );
    final constructionQueue = container.read(
      billingTenantDomainModuleProductReleaseChannelLaunchQueueProvider(
        const BillingNavigationDispatchSnapshotRequest(
          preferences: BillingTenantPreferences(businessDomain: 'construction'),
          hasTenant: true,
          currentSurface: BillingNavigationSurface.dashboard,
        ),
      ),
    );

    expect(defaultQueue.itemCount, 14);
    expect(defaultQueue.readyNowCount, 2);
    expect(defaultQueue.needsRoutingCount, 0);
    expect(defaultQueue.blockedCount, 12);
    expect(defaultQueue.nextReadyItem, isNotNull);
    expect(constructionQueue.itemCount, 14);
    expect(constructionQueue.readyNowCount, 5);
    expect(constructionQueue.blockedCount, 9);
  });
}
