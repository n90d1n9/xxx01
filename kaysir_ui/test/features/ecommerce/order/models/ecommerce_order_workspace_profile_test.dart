import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise_policy.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';

void main() {
  test('default order workspace profiles expose stable product variants', () {
    expect(
      ecommerceDefaultOrderWorkspaceProfiles.map((profile) => profile.id),
      ['all_commerce', 'marketplace_ops', 'delivery_ops', 'wholesale_ops'],
    );
    expect(
      validateOrderWorkspaceProfiles(ecommerceDefaultOrderWorkspaceProfiles),
      isEmpty,
    );
    expect(ecommerceAllCommerceOrderWorkspaceProfile.title, 'Orders');
  });

  test('marketplace profile constrains channels and workspace presets', () {
    expect(
      ecommerceMarketplaceOrderWorkspaceProfile.title,
      'Marketplace Orders',
    );
    expect(ecommerceMarketplaceOrderWorkspaceProfile.salesChannelIds, [
      'marketplace',
    ]);
    expect(
      ecommerceMarketplaceOrderWorkspaceProfile.initialFilter.channelId,
      'marketplace',
    );
    expect(
      ecommerceMarketplaceOrderWorkspaceProfile.initialSortMode,
      OrderSortMode.attention,
    );
    expect(
      ecommerceMarketplaceOrderWorkspaceProfile.workspaceViews.map(
        (view) => view.id,
      ),
      [
        'marketplace_all',
        'marketplace_priority',
        'marketplace_settlement',
        'marketplace_handoff',
      ],
    );
  });

  test('profile lookup falls back to all commerce profile', () {
    expect(
      ecommerceOrderWorkspaceProfileFor(
        profiles: ecommerceDefaultOrderWorkspaceProfiles,
        profileId: 'delivery_ops',
      ),
      ecommerceDeliveryOrderWorkspaceProfile,
    );
    expect(
      ecommerceOrderWorkspaceProfileFor(
        profiles: ecommerceDefaultOrderWorkspaceProfiles,
        profileId: 'unknown',
      ),
      ecommerceAllCommerceOrderWorkspaceProfile,
    );
  });

  test('profile helpers resolve initial and explicit workspace views', () {
    expect(
      ecommerceInitialOrderWorkspaceViewForProfile(
        ecommerceMarketplaceOrderWorkspaceProfile,
      )?.id,
      'marketplace_all',
    );
    expect(
      ecommerceOrderWorkspaceViewById(
        views: ecommerceMarketplaceOrderWorkspaceProfile.workspaceViews,
        viewId: 'marketplace_priority',
      )?.label,
      'Policy priority',
    );
    expect(
      ecommerceOrderWorkspaceViewById(
        views: ecommerceMarketplaceOrderWorkspaceProfile.workspaceViews,
        viewId: 'missing',
      ),
      isNull,
    );
  });

  test('profile validation catches unsafe registry shapes', () {
    const invalidPolicy = OrderFulfillmentPromisePolicy(
      warningWindow: Duration.zero,
    );
    const invalidProfile = OrderWorkspaceProfile(
      id: 'bad',
      title: '',
      description: '',
      salesChannels: [SalesChannels.deliveryApp, SalesChannels.deliveryApp],
      initialFilter: OrderFilter(query: 'manual'),
      workspaceViews: [
        ecommerceAllOrdersWorkspaceView,
        ecommerceAllOrdersWorkspaceView,
      ],
      fulfillmentPromisePolicy: invalidPolicy,
    );

    expect(
      invalidProfile.validate().map((issue) => issue.type),
      containsAll([
        OrderWorkspaceProfileIssueType.blankTitle,
        OrderWorkspaceProfileIssueType.blankDescription,
        OrderWorkspaceProfileIssueType.duplicateSalesChannel,
        OrderWorkspaceProfileIssueType.duplicateWorkspaceView,
        OrderWorkspaceProfileIssueType.initialWorkspaceNotRegistered,
        OrderWorkspaceProfileIssueType.invalidPromisePolicy,
      ]),
    );

    final registryIssues = validateOrderWorkspaceProfiles([
      ecommerceAllCommerceOrderWorkspaceProfile,
      ecommerceAllCommerceOrderWorkspaceProfile,
    ]);

    expect(
      registryIssues.map((issue) => issue.type),
      contains(OrderWorkspaceProfileIssueType.duplicateProfileId),
    );
  });
}
