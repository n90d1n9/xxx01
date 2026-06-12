import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_product_release_channel.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_presentation.dart';

void main() {
  test('release dispatch presentation describes route entries', () {
    final entry = _dispatchEntry(
      navigationPlan: _routePlan(BillingNavigationDestinationId.cartCheckout),
      routeTarget: BillingProductReleaseChannelLaunchRouteTarget(
        destinationId: BillingNavigationDestinationId.cartCheckout,
        callToActionLabel: 'Open checkout',
        operatorStepLabel: 'Open checkout workflow',
      ),
    );

    final presentation =
        BillingProductReleaseChannelLaunchDispatchPresentation.fromEntry(entry);

    expect(presentation.title, 'Cart & checkout - Route');
    expect(presentation.detail, 'Open checkout workflow');
    expect(presentation.icon, Icons.open_in_new_outlined);
    expect(presentation.backgroundColor, const Color(0xFFECFDF5));
    expect(presentation.foregroundColor, const Color(0xFF059669));
    expect(presentation.isActionable, isTrue);
  });

  test('release dispatch presentation describes blocked entries', () {
    final entry = _dispatchEntry(
      launchAction: _launchAction(
        lane: BillingProductReleaseChannelLaunchLane.blocked,
        detail: 'Resolve release blocker.',
      ),
      navigationPlan: _routePlan(BillingNavigationDestinationId.cartCheckout),
      routeTarget: BillingProductReleaseChannelLaunchRouteTarget(
        destinationId: BillingNavigationDestinationId.cartCheckout,
        callToActionLabel: 'Open checkout',
        operatorStepLabel: 'Open checkout workflow',
      ),
    );

    final presentation =
        BillingProductReleaseChannelLaunchDispatchPresentation.fromEntry(entry);

    expect(presentation.title, 'Cart & checkout - Blocked');
    expect(presentation.detail, 'Resolve release blocker.');
    expect(presentation.icon, Icons.lock_outline_rounded);
    expect(presentation.backgroundColor, const Color(0xFFFEF2F2));
    expect(presentation.foregroundColor, const Color(0xFFDC2626));
    expect(presentation.isActionable, isFalse);
  });
}

BillingProductReleaseChannelLaunchDispatchEntry _dispatchEntry({
  BillingProductReleaseChannelLaunchAction? launchAction,
  required BillingProductReleaseChannelLaunchRouteTarget routeTarget,
  BillingNavigationDispatchPlan? navigationPlan,
}) {
  return BillingProductReleaseChannelLaunchDispatchEntry(
    launchAction: launchAction ?? _launchAction(),
    routeTarget: routeTarget,
    navigationPlan: navigationPlan,
  );
}

BillingProductReleaseChannelLaunchAction _launchAction({
  BillingProductReleaseChannelLaunchLane lane =
      BillingProductReleaseChannelLaunchLane.publishNow,
  String detail = 'Ready to launch.',
}) {
  return BillingProductReleaseChannelLaunchAction(
    id: 'test.pos.commerce',
    channelKey: 'pos_counter',
    channelLabel: 'POS Counter',
    editionKey: 'commerce_essentials',
    editionLabel: 'Commerce Essentials',
    label: 'Launch POS Counter',
    detail: detail,
    lane: lane,
    priority: 1,
  );
}

BillingNavigationDispatchPlan _routePlan(
  BillingNavigationDestinationId destinationId,
) {
  final planner = BillingNavigationLaunchPlanner(
    hasTenant: true,
    navigationSet: billingDomainNavigationSetForModule(
      commerceBillingDomainModule(),
    ),
  );

  return resolveBillingNavigationDispatchPlan(
    launchState: planner.stateFor(destinationId),
    currentSurface: BillingNavigationSurface.dashboard,
  );
}
