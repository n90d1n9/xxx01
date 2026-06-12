import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/channel_requirement.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/presentation_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('standard product profile bundles the default commerce registries', () {
    final profile = ProductProfile.standard;

    expect(profile.id, 'standard');
    expect(profile.presentationProfile.id, 'standard');
    expect(profile.searchKeywords, [
      'omnichannel',
      'multi-channel',
      'retail',
      'storefront',
      'kiosk',
    ]);
    expect(profile.capabilities, [
      ProductCapability.storefrontCheckout,
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ]);
    expect(profile.salesChannels.map((channel) => channel.id), [
      'web_store',
      'marketplace',
      'social_order',
    ]);
    expect(
      profile.channelCoverageRequirements,
      defaultChannelCoverageRequirements,
    );
    expect(
      profile.preferredOrderWorkspaceProfileId,
      ecommerceAllCommerceOrderWorkspaceProfile.id,
    );
    expect(profile.modules, defaultModules);
    expect(profile.actionRules, defaultActionRules);
  });

  test(
    'operations-first product profile swaps only presentation by default',
    () {
      final profile = ProductProfile.operationsFirst;

      expect(profile.id, 'operations_first');
      expect(profile.presentationProfile.id, 'operations_first');
      expect(profile.capabilities.first, ProductCapability.operationsReview);
      expect(profile.salesChannels.map((channel) => channel.id), [
        'marketplace',
        'delivery_app',
        'web_store',
      ]);
      expect(profile.modules, defaultModules);
      expect(profile.actionRules, defaultActionRules);
    },
  );

  test('default product profile registry exposes commerce presets', () {
    expect(defaultProductProfiles.map((profile) => profile.id), [
      'standard',
      'operations_first',
      'remote_payment',
      'subscription_commerce',
      'fulfillment_first',
      'marketplace_operations',
    ]);
  });

  test('remote payment profile focuses checkout and payment flow', () {
    final profile = ProductProfile.remotePayment;
    final destinations = destinationsForModules(
      overview: _overview(),
      modules: profile.modules,
      capabilities: profile.capabilities,
    );

    expect(profile.capabilities, [
      ProductCapability.remotePayment,
      ProductCapability.storefrontCheckout,
    ]);
    expect(profile.salesChannels.map((channel) => channel.id), [
      'social_order',
      'phone_order',
      'web_store',
    ]);
    expect(destinations.map((destination) => destination.id), [
      'remote_payments',
      'checkout',
    ]);
  });

  test(
    'subscription commerce profile combines renewal and remote payment flow',
    () {
      final profile = ProductProfile.subscriptionCommerce;
      final destinations = destinationsForModules(
        overview: _overview(orderCount: 2),
        modules: profile.modules,
        capabilities: profile.capabilities,
      );

      expect(profile.presentationProfile.id, 'operations_first');
      expect(profile.capabilities, [
        ProductCapability.subscriptionBilling,
        ProductCapability.remotePayment,
        ProductCapability.operationsReview,
      ]);
      expect(destinations.map((destination) => destination.id), [
        'remote_payments',
        'checkout',
        'orders',
        'subscription_renewals',
        'promise_policy',
      ]);
    },
  );

  test('fulfillment first profile hides checkout-only workspace modules', () {
    final profile = ProductProfile.fulfillmentFirst;
    final destinations = destinationsForModules(
      overview: _overview(attentionOrders: 2),
      modules: profile.modules,
      capabilities: profile.capabilities,
    );

    expect(profile.presentationProfile.id, 'operations_first');
    expect(
      profile.preferredOrderWorkspaceProfileId,
      ecommerceDeliveryOrderWorkspaceProfile.id,
    );
    expect(destinations.map((destination) => destination.id), [
      'orders',
      'fulfillment_queue',
      'promise_policy',
    ]);
  });

  test(
    'marketplace operations profile adds marketplace coverage requirements',
    () {
      final profile = ProductProfile.marketplaceOperations;

      expect(
        profile.channelCoverageRequirements.map(
          (requirement) => requirement.id,
        ),
        ['payments', 'customers', 'fulfillment_tracking', 'price_lists'],
      );
      expect(
        profile.channelCoverageRequirements.last,
        ecommerceMarketplacePriceListChannelCoverageRequirement,
      );
      expect(
        profile.preferredOrderWorkspaceProfileId,
        ecommerceMarketplaceOrderWorkspaceProfile.id,
      );
    },
  );

  test('product profile copyWith supports product-specific registries', () {
    final module = Module(
      id: 'subscriptions',
      buildDestination:
          (_) => const Destination(
            id: 'subscriptions',
            title: 'Subscriptions',
            subtitle: 'Manage recurring commerce plans.',
            routePath: '/commerce/subscriptions',
            metricLabel: 'Plans',
            metricValue: '3',
            actionLabel: 'Open plans',
            icon: Icons.autorenew_outlined,
            tone: DestinationTone.secondary,
          ),
    );
    final actionRule = ActionRule(
      id: 'subscriptions',
      buildAction:
          (_) => const Action(
            id: 'subscriptions',
            title: 'Review subscriptions',
            description: 'Renewal orders need confirmation.',
            actionLabel: 'Open renewals',
            routePath: '/commerce/subscriptions',
            icon: Icons.autorenew_outlined,
            tone: ActionTone.warning,
            priority: 5,
          ),
    );

    final profile = ProductProfile.standard.copyWith(
      id: 'subscriptions',
      label: 'Subscription commerce',
      searchKeywords: const ['membership', 'recurring'],
      capabilities: const [
        ProductCapability.subscriptionBilling,
        ProductCapability.remotePayment,
      ],
      salesChannels: const [SalesChannels.wholesale],
      channelCoverageRequirements: const [
        ecommerceMarketplacePriceListChannelCoverageRequirement,
      ],
      presentationProfile: PresentationProfile.operationsFirst,
      preferredOrderWorkspaceProfileId:
          ecommerceWholesaleOrderWorkspaceProfile.id,
      modules: [module],
      actionRules: [actionRule],
    );

    expect(profile.id, 'subscriptions');
    expect(profile.presentationProfile.id, 'operations_first');
    expect(profile.searchKeywords, ['membership', 'recurring']);
    expect(profile.capabilities, [
      ProductCapability.subscriptionBilling,
      ProductCapability.remotePayment,
    ]);
    expect(profile.salesChannels.map((channel) => channel.id), ['wholesale']);
    expect(profile.channelCoverageRequirements, [
      ecommerceMarketplacePriceListChannelCoverageRequirement,
    ]);
    expect(
      profile.preferredOrderWorkspaceProfileId,
      ecommerceWholesaleOrderWorkspaceProfile.id,
    );
    expect(profile.modules, [module]);
    expect(profile.actionRules, [actionRule]);
  });

  test(
    'product profile lookup selects by id and falls back to first profile',
    () {
      final profiles = [
        ProductProfile.standard,
        ProductProfile.operationsFirst,
      ];

      expect(
        productProfileFor(profiles: profiles, profileId: 'operations_first').id,
        'operations_first',
      );
      expect(
        productProfileFor(profiles: profiles, profileId: 'unknown').id,
        'standard',
      );
      expect(
        productProfileFor(profiles: const [], profileId: 'unknown').id,
        'standard',
      );
    },
  );

  test('product profile validation accepts default profiles', () {
    final issues = validateProductProfiles(
      profiles: defaultProductProfiles,
      selectedProfileId: ProductProfile.standard.id,
    );

    expect(issues, isEmpty);
  });

  test('product profile validation catches registry issues', () {
    final issues = validateProductProfiles(
      selectedProfileId: 'missing',
      profiles: [
        ProductProfile.standard.copyWith(
          id: '',
          label: '',
          description: '',
          searchKeywords: const ['', 'Retail', 'retail'],
          capabilities: const [],
          salesChannels: const [],
          preferredOrderWorkspaceProfileId: '',
          modules: const [],
          actionRules: const [],
        ),
        ProductProfile.standard.copyWith(id: 'duplicate'),
        ProductProfile.operationsFirst.copyWith(id: 'duplicate'),
        ProductProfile.standard.copyWith(
          id: 'missing_order_workspace',
          preferredOrderWorkspaceProfileId: 'missing',
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ProductProfileIssueType.unknownSelectedProfileId,
        ProductProfileIssueType.blankProfileId,
        ProductProfileIssueType.blankProfileLabel,
        ProductProfileIssueType.blankProfileDescription,
        ProductProfileIssueType.blankProfileSearchKeyword,
        ProductProfileIssueType.duplicateProfileSearchKeyword,
        ProductProfileIssueType.blankPreferredOrderWorkspaceProfileId,
        ProductProfileIssueType.unknownPreferredOrderWorkspaceProfileId,
        ProductProfileIssueType.emptyProfileCapabilities,
        ProductProfileIssueType.emptyProfileSalesChannels,
        ProductProfileIssueType.emptyProfileModules,
        ProductProfileIssueType.emptyProfileActionRules,
        ProductProfileIssueType.duplicateProfileId,
      ]),
    );
  });

  test('product profile validation catches sales channel strategy issues', () {
    const blankChannel = POSCommerceChannel(
      id: '',
      kind: POSCommerceChannelKind.phoneOrder,
      label: '',
      description: 'Sales channel without stable metadata.',
      preferredLayout: POSLayoutPreference.checkout,
      fulfillmentModes: [],
      capabilities: [],
    );
    const legacyChannel = POSCommerceChannel(
      id: 'legacy',
      kind: POSCommerceChannelKind.phoneOrder,
      label: 'Legacy channel',
      description: 'Legacy sales channel without capability mapping.',
      preferredLayout: POSLayoutPreference.checkout,
      fulfillmentModes: [],
      capabilities: [],
    );

    final issues = validateProductProfiles(
      selectedProfileId: 'bad_channels',
      profiles: [
        ProductProfile.standard.copyWith(
          id: 'bad_channels',
          capabilities: const [
            ProductCapability.storefrontCheckout,
            ProductCapability.marketplaceOrders,
            ProductCapability.remotePayment,
            ProductCapability.subscriptionBilling,
            ProductCapability.shipping,
          ],
          salesChannels: const [blankChannel, legacyChannel, legacyChannel],
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        ProductProfileIssueType.blankProfileSalesChannelId,
        ProductProfileIssueType.blankProfileSalesChannelLabel,
        ProductProfileIssueType.duplicateProfileSalesChannelId,
        ProductProfileIssueType.missingStorefrontSalesChannel,
        ProductProfileIssueType.missingMarketplaceSalesChannel,
        ProductProfileIssueType.missingRemotePaymentSalesChannel,
        ProductProfileIssueType.missingSubscriptionSalesChannel,
        ProductProfileIssueType.missingFulfillmentTrackingSalesChannel,
      ]),
    );
    expect(
      issues
          .singleWhere(
            (issue) =>
                issue.type ==
                ProductProfileIssueType.duplicateProfileSalesChannelId,
          )
          .channelId,
      'legacy',
    );
  });

  test(
    'product profile validation catches channel coverage requirement issues',
    () {
      const blankRequirement = ChannelCoverageRequirement(
        id: '',
        type: ChannelCoverageRequirementType.custom,
        label: '',
        capabilityGate: CapabilityGate.always,
        channelCapability: POSCommerceChannelCapability.promotions,
        coveredDetail: '',
        missingDetail: '',
        optionalDetail: '',
      );
      const duplicateRequirement = ChannelCoverageRequirement(
        id: 'duplicate',
        type: ChannelCoverageRequirementType.custom,
        label: 'Duplicate',
        capabilityGate: CapabilityGate.always,
        channelCapability: POSCommerceChannelCapability.promotions,
        coveredDetail: 'Covered',
        missingDetail: 'Missing',
        optionalDetail: 'Optional',
      );
      const badRecommendationRequirement = ChannelCoverageRequirement(
        id: 'bad_recommendation',
        type: ChannelCoverageRequirementType.custom,
        label: 'Bad recommendation',
        capabilityGate: CapabilityGate.always,
        channelCapability: POSCommerceChannelCapability.priceLists,
        coveredDetail: 'Covered',
        missingDetail: 'Missing',
        optionalDetail: 'Optional',
        recommendation: ChannelCoverageRecommendationCopy(
          title: '',
          detail: '',
          actionLabel: '',
          priority: -1,
        ),
      );

      final issues = validateProductProfiles(
        selectedProfileId: 'empty_coverage',
        profiles: [
          ProductProfile.standard.copyWith(
            id: 'empty_coverage',
            channelCoverageRequirements: const [],
          ),
          ProductProfile.standard.copyWith(
            id: 'bad_coverage',
            channelCoverageRequirements: const [
              blankRequirement,
              duplicateRequirement,
              duplicateRequirement,
              badRecommendationRequirement,
            ],
          ),
        ],
      );

      expect(
        issues.map((issue) => issue.type),
        containsAll([
          ProductProfileIssueType.emptyProfileChannelCoverageRequirements,
          ProductProfileIssueType.blankProfileChannelCoverageRequirementId,
          ProductProfileIssueType.blankProfileChannelCoverageRequirementLabel,
          ProductProfileIssueType.blankProfileChannelCoverageRequirementDetail,
          ProductProfileIssueType.duplicateProfileChannelCoverageRequirementId,
          ProductProfileIssueType.blankProfileChannelCoverageRecommendationCopy,
          ProductProfileIssueType
              .invalidProfileChannelCoverageRecommendationPriority,
        ]),
      );
      expect(
        issues
            .singleWhere(
              (issue) =>
                  issue.type ==
                  ProductProfileIssueType
                      .duplicateProfileChannelCoverageRequirementId,
            )
            .requirementId,
        'duplicate',
      );
      expect(
        issues
            .singleWhere(
              (issue) =>
                  issue.type ==
                  ProductProfileIssueType
                      .blankProfileChannelCoverageRecommendationCopy,
            )
            .requirementId,
        'bad_recommendation',
      );
      expect(
        issues
            .singleWhere(
              (issue) =>
                  issue.type ==
                  ProductProfileIssueType
                      .invalidProfileChannelCoverageRecommendationPriority,
            )
            .message,
        'Commerce product profile "bad_coverage" channel coverage requirement "bad_recommendation" recommendation priority must be zero or greater.',
      );
    },
  );

  test('product profile validation catches empty registry', () {
    final issues = validateProductProfiles(
      profiles: const [],
      selectedProfileId: '',
    );

    expect(issues.single.type, ProductProfileIssueType.emptyRegistry);
  });
}

Overview _overview({int orderCount = 0, int attentionOrders = 0}) {
  return Overview(
    orderInsights: OrderInsights(
      orderCount: orderCount,
      revenue: 0,
      averageOrderValue: 0,
      paidOrderCount: 0,
      externalSettlementCount: 0,
      attentionOrderCount: attentionOrders,
      criticalAttentionOrderCount: 0,
      channelBreakdown: const [],
      fulfillmentBreakdown: const [],
    ),
    cartLineCount: 0,
    cartUnitCount: 0,
    cartTotal: 0,
    promisePolicyIssueCount: 0,
  );
}
