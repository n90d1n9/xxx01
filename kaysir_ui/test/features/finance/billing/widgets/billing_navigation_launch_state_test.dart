import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_screen_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_state.dart';

void main() {
  test('legacy launch state preserves static tenant availability', () {
    final state = billingNavigationLaunchStateFor(
      BillingNavigationDestinationId.productWorkspace,
      hasTenant: false,
    );

    expect(
      state.destinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(state.surface, BillingNavigationSurface.productWorkspace);
    expect(
      state.presentation,
      BillingBusinessDomainScreenPresentation.embedded,
    );
    expect(state.requiresTenant, isTrue);
    expect(state.isExposed, isTrue);
    expect(state.hasRegisteredScreen, isTrue);
    expect(state.isEnabled, isFalse);
    expect(state.disabledReason, 'Select a tenant first');
    expect(state.screenKey, 'legacy.productWorkspace');
  });

  test('module launch state exposes screen presentation metadata', () {
    final navigationSet = billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    );

    final state = billingNavigationLaunchStateFor(
      BillingNavigationDestinationId.cartCheckout,
      hasTenant: true,
      navigationSet: navigationSet,
    );

    expect(state.isEnabled, isTrue);
    expect(state.surface, BillingNavigationSurface.productWorkspace);
    expect(
      state.presentation,
      BillingBusinessDomainScreenPresentation.workflow,
    );
    expect(state.requiresTenant, isTrue);
    expect(state.isExposed, isTrue);
    expect(state.hasRegisteredScreen, isTrue);
    expect(state.screenKey, 'commerce.cart_checkout');
  });

  test('module launch state reports unavailable module destinations', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );

    final state = billingNavigationLaunchStateFor(
      BillingNavigationDestinationId.cartCheckout,
      hasTenant: true,
      navigationSet: navigationSet,
    );

    expect(state.isEnabled, isFalse);
    expect(state.isExposed, isFalse);
    expect(state.hasRegisteredScreen, isFalse);
    expect(
      state.disabledReason,
      'This destination is not available for this billing domain.',
    );
  });
}
