import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../channel/models/sales_channel.dart';
import 'order_attention.dart';
import 'order_filter.dart';
import 'order_fulfillment_promise_policy.dart';
import 'order_payment_scope.dart';
import 'order_sort.dart';
import 'order_workspace_view.dart';

const ecommerceAllCommerceOrderWorkspaceProfileId = 'all_commerce';
const ecommerceMarketplaceOrderWorkspaceProfileId = 'marketplace_ops';
const ecommerceDeliveryOrderWorkspaceProfileId = 'delivery_ops';
const ecommerceWholesaleOrderWorkspaceProfileId = 'wholesale_ops';

enum OrderWorkspaceProfileIssueType {
  blankProfileId,
  duplicateProfileId,
  blankTitle,
  blankDescription,
  emptySalesChannels,
  duplicateSalesChannel,
  emptyWorkspaceViews,
  duplicateWorkspaceView,
  initialWorkspaceNotRegistered,
  invalidPromisePolicy,
}

class OrderWorkspaceProfileIssue {
  final OrderWorkspaceProfileIssueType type;
  final String message;
  final String? profileId;

  const OrderWorkspaceProfileIssue({
    required this.type,
    required this.message,
    this.profileId,
  });

  @override
  String toString() => message;
}

class OrderWorkspaceProfile {
  final String id;
  final String title;
  final String description;
  final List<POSCommerceChannel> salesChannels;
  final OrderFilter initialFilter;
  final OrderSortMode initialSortMode;
  final List<OrderWorkspaceView> workspaceViews;
  final OrderFulfillmentPromisePolicy? fulfillmentPromisePolicy;
  final int recommendationLimit;

  const OrderWorkspaceProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.salesChannels,
    this.initialFilter = const OrderFilter(),
    this.initialSortMode = OrderSortMode.newest,
    this.workspaceViews = ecommerceDefaultOrderWorkspaceViews,
    this.fulfillmentPromisePolicy,
    this.recommendationLimit = 3,
  }) : assert(recommendationLimit >= 0);

  List<String> get salesChannelIds =>
      salesChannels.map((channel) => channel.id).toList(growable: false);

  List<OrderWorkspaceProfileIssue> validate() {
    final issues = <OrderWorkspaceProfileIssue>[];
    final normalizedProfileId = id.trim();
    final profileLabel = normalizedProfileId.isEmpty ? 'unknown' : id;

    if (normalizedProfileId.isEmpty) {
      issues.add(
        const OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.blankProfileId,
          message: ' order workspace profile id cannot be blank.',
        ),
      );
    }
    if (title.trim().isEmpty) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.blankTitle,
          profileId: normalizedProfileId,
          message:
              ' order workspace profile "$profileLabel" title cannot be blank.',
        ),
      );
    }
    if (description.trim().isEmpty) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.blankDescription,
          profileId: normalizedProfileId,
          message:
              ' order workspace profile "$profileLabel" description cannot be blank.',
        ),
      );
    }

    if (salesChannels.isEmpty) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.emptySalesChannels,
          profileId: normalizedProfileId,
          message:
              ' order workspace profile "$profileLabel" must include at least one sales channel.',
        ),
      );
    } else {
      final channelIds = <String>{};
      for (final channel in salesChannels) {
        final channelId = channel.id.trim();
        if (!channelIds.add(channelId)) {
          issues.add(
            OrderWorkspaceProfileIssue(
              type: OrderWorkspaceProfileIssueType.duplicateSalesChannel,
              profileId: normalizedProfileId,
              message:
                  ' order workspace profile "$profileLabel" repeats sales channel "$channelId".',
            ),
          );
        }
      }
    }

    if (workspaceViews.isEmpty) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.emptyWorkspaceViews,
          profileId: normalizedProfileId,
          message:
              ' order workspace profile "$profileLabel" must include at least one workspace view.',
        ),
      );
    } else {
      final workspaceViewIds = <String>{};
      for (final view in workspaceViews) {
        final viewId = view.id.trim();
        if (!workspaceViewIds.add(viewId)) {
          issues.add(
            OrderWorkspaceProfileIssue(
              type: OrderWorkspaceProfileIssueType.duplicateWorkspaceView,
              profileId: normalizedProfileId,
              message:
                  ' order workspace profile "$profileLabel" repeats workspace view "$viewId".',
            ),
          );
        }
      }
      if (ecommerceInitialOrderWorkspaceViewForProfile(this) == null) {
        issues.add(
          OrderWorkspaceProfileIssue(
            type: OrderWorkspaceProfileIssueType.initialWorkspaceNotRegistered,
            profileId: normalizedProfileId,
            message:
                ' order workspace profile "$profileLabel" initial filter and sort must match a registered workspace view.',
          ),
        );
      }
    }

    final promiseIssues = fulfillmentPromisePolicy?.validate() ?? const [];
    if (promiseIssues.isNotEmpty) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.invalidPromisePolicy,
          profileId: normalizedProfileId,
          message:
              ' order workspace profile "$profileLabel" has an invalid promise policy: ${promiseIssues.map((issue) => issue.message).join(' ')}',
        ),
      );
    }

    return List.unmodifiable(issues);
  }

  bool get isValid => validate().isEmpty;
}

const ecommerceMarketplaceOrderWorkspaceViews = <OrderWorkspaceView>[
  OrderWorkspaceView(
    id: 'marketplace_all',
    label: 'Marketplace all',
    description: 'Show every marketplace order with policy work visible.',
    filter: OrderFilter(channelId: 'marketplace'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'marketplace_priority',
    label: 'Policy priority',
    description: 'Show marketplace orders blocked by missing data or routing.',
    filter: OrderFilter(
      channelId: 'marketplace',
      attentionScope: OrderAttentionScope.highPriority,
    ),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'marketplace_settlement',
    label: 'Settlement',
    description:
        'Show marketplace orders ready for marketplace settlement matching.',
    filter: OrderFilter(
      channelId: 'marketplace',
      paymentScope: OrderPaymentScope.externalSettlement,
    ),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'marketplace_handoff',
    label: 'Ship handoff',
    description: 'Show marketplace orders ready for carrier handoff.',
    filter: OrderFilter(channelId: 'marketplace', status: 'ready'),
    sortMode: OrderSortMode.attention,
  ),
];

const ecommerceDeliveryOrderWorkspaceViews = <OrderWorkspaceView>[
  OrderWorkspaceView(
    id: 'delivery_all',
    label: 'Delivery all',
    description: 'Show every delivery-app order by operational attention.',
    filter: OrderFilter(channelId: 'delivery_app'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'delivery_priority',
    label: 'Courier blockers',
    description: 'Show delivery orders blocked before courier prep.',
    filter: OrderFilter(
      channelId: 'delivery_app',
      attentionScope: OrderAttentionScope.highPriority,
    ),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'delivery_ready',
    label: 'Courier ready',
    description: 'Show delivery orders waiting for courier handoff.',
    filter: OrderFilter(channelId: 'delivery_app', status: 'ready'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'delivery_today',
    label: 'Today delivery',
    description: 'Show today delivery-app queue with attention surfaced first.',
    filter: OrderFilter(
      channelId: 'delivery_app',
      timeScope: OrderTimeScope.today,
    ),
    sortMode: OrderSortMode.attention,
  ),
];

const ecommerceWholesaleOrderWorkspaceViews = <OrderWorkspaceView>[
  OrderWorkspaceView(
    id: 'wholesale_all',
    label: 'Wholesale all',
    description: 'Show every wholesale order with account work surfaced.',
    filter: OrderFilter(channelId: 'wholesale'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'wholesale_priority',
    label: 'Account blockers',
    description: 'Show wholesale orders blocked by account or routing details.',
    filter: OrderFilter(
      channelId: 'wholesale',
      attentionScope: OrderAttentionScope.highPriority,
    ),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'wholesale_staging',
    label: 'Staging',
    description: 'Show wholesale orders waiting for staged fulfillment.',
    filter: OrderFilter(channelId: 'wholesale', status: 'processing'),
    sortMode: OrderSortMode.attention,
  ),
  OrderWorkspaceView(
    id: 'wholesale_handoff',
    label: 'B2B handoff',
    description: 'Show wholesale orders ready for customer or carrier handoff.',
    filter: OrderFilter(channelId: 'wholesale', status: 'ready'),
    sortMode: OrderSortMode.attention,
  ),
];

const ecommerceAllCommerceOrderWorkspaceProfile = OrderWorkspaceProfile(
  id: ecommerceAllCommerceOrderWorkspaceProfileId,
  title: 'Orders',
  description:
      'All ecommerce order channels with shared settlement, fulfillment, and SLA controls.',
  salesChannels: SalesChannels.all,
  workspaceViews: ecommerceDefaultOrderWorkspaceViews,
  fulfillmentPromisePolicy: OrderFulfillmentPromisePolicy(),
);

const ecommerceMarketplaceOrderWorkspaceProfile = OrderWorkspaceProfile(
  id: ecommerceMarketplaceOrderWorkspaceProfileId,
  title: 'Marketplace Orders',
  description:
      'Marketplace operations for policy-bound fulfillment, handoff, and settlement matching.',
  salesChannels: [SalesChannels.marketplace],
  initialFilter: OrderFilter(channelId: 'marketplace'),
  initialSortMode: OrderSortMode.attention,
  workspaceViews: ecommerceMarketplaceOrderWorkspaceViews,
  fulfillmentPromisePolicy: OrderFulfillmentPromisePolicy(),
);

const ecommerceDeliveryOrderWorkspaceProfile = OrderWorkspaceProfile(
  id: ecommerceDeliveryOrderWorkspaceProfileId,
  title: 'Delivery Orders',
  description:
      'Delivery-app operations for prep-time, courier handoff, and external settlement.',
  salesChannels: [SalesChannels.deliveryApp],
  initialFilter: OrderFilter(channelId: 'delivery_app'),
  initialSortMode: OrderSortMode.attention,
  workspaceViews: ecommerceDeliveryOrderWorkspaceViews,
  fulfillmentPromisePolicy: OrderFulfillmentPromisePolicy(
    defaultTarget: ecommerceCourierPrepPromiseTarget,
  ),
);

const ecommerceWholesaleOrderWorkspaceProfile = OrderWorkspaceProfile(
  id: ecommerceWholesaleOrderWorkspaceProfileId,
  title: 'Wholesale Orders',
  description:
      'Wholesale order operations for account staging, B2B fulfillment, and handoff control.',
  salesChannels: [SalesChannels.wholesale],
  initialFilter: OrderFilter(channelId: 'wholesale'),
  initialSortMode: OrderSortMode.attention,
  workspaceViews: ecommerceWholesaleOrderWorkspaceViews,
  fulfillmentPromisePolicy: OrderFulfillmentPromisePolicy(
    defaultTarget: ecommerceAccountStagingPromiseTarget,
  ),
);

const ecommerceDefaultOrderWorkspaceProfiles = <OrderWorkspaceProfile>[
  ecommerceAllCommerceOrderWorkspaceProfile,
  ecommerceMarketplaceOrderWorkspaceProfile,
  ecommerceDeliveryOrderWorkspaceProfile,
  ecommerceWholesaleOrderWorkspaceProfile,
];

OrderWorkspaceView? ecommerceInitialOrderWorkspaceViewForProfile(
  OrderWorkspaceProfile profile,
) {
  return ecommerceActiveOrderWorkspaceView(
    views: profile.workspaceViews,
    filter: profile.initialFilter,
    sortMode: profile.initialSortMode,
  );
}

OrderWorkspaceProfile ecommerceOrderWorkspaceProfileFor({
  required List<OrderWorkspaceProfile> profiles,
  required String profileId,
}) {
  final normalizedProfileId = profileId.trim();
  for (final profile in profiles) {
    if (profile.id == normalizedProfileId) return profile;
  }

  return ecommerceAllCommerceOrderWorkspaceProfile;
}

List<OrderWorkspaceProfileIssue> validateOrderWorkspaceProfiles(
  List<OrderWorkspaceProfile> profiles,
) {
  final issues = <OrderWorkspaceProfileIssue>[];
  final seenProfileIds = <String>{};
  final reportedProfileIds = <String>{};

  for (final profile in profiles) {
    issues.addAll(profile.validate());

    final normalizedProfileId = profile.id.trim();
    if (normalizedProfileId.isEmpty) continue;

    if (!seenProfileIds.add(normalizedProfileId) &&
        reportedProfileIds.add(normalizedProfileId)) {
      issues.add(
        OrderWorkspaceProfileIssue(
          type: OrderWorkspaceProfileIssueType.duplicateProfileId,
          profileId: normalizedProfileId,
          message:
              'Duplicate ecommerce order workspace profile id "$normalizedProfileId" found.',
        ),
      );
    }
  }

  return List.unmodifiable(issues);
}
