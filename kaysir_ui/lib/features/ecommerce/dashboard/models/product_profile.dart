import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../channel/models/sales_channel.dart';
import '../../order/models/order_workspace_profile.dart';
import 'action.dart';
import 'capability.dart';
import 'channel_requirement.dart';
import 'module.dart';
import 'presentation_profile.dart';

export 'capability.dart';

enum ProductProfileIssueType {
  emptyRegistry,
  blankSelectedProfileId,
  unknownSelectedProfileId,
  blankProfileId,
  duplicateProfileId,
  blankProfileLabel,
  blankProfileDescription,
  blankProfileSearchKeyword,
  duplicateProfileSearchKeyword,
  emptyProfileCapabilities,
  emptyProfileSalesChannels,
  blankProfileSalesChannelId,
  duplicateProfileSalesChannelId,
  blankProfileSalesChannelLabel,
  emptyProfileChannelCoverageRequirements,
  blankProfileChannelCoverageRequirementId,
  duplicateProfileChannelCoverageRequirementId,
  blankProfileChannelCoverageRequirementLabel,
  blankProfileChannelCoverageRequirementDetail,
  blankProfileChannelCoverageRecommendationCopy,
  invalidProfileChannelCoverageRecommendationPriority,
  blankPreferredOrderWorkspaceProfileId,
  unknownPreferredOrderWorkspaceProfileId,
  missingStorefrontSalesChannel,
  missingMarketplaceSalesChannel,
  missingRemotePaymentSalesChannel,
  missingSubscriptionSalesChannel,
  missingFulfillmentTrackingSalesChannel,
  emptyProfileModules,
  emptyProfileActionRules,
}

class ProductProfileIssue {
  final ProductProfileIssueType type;
  final String message;
  final String? profileId;
  final String? channelId;
  final String? requirementId;

  const ProductProfileIssue({
    required this.type,
    required this.message,
    this.profileId,
    this.channelId,
    this.requirementId,
  });
}

class ProductProfile {
  final String id;
  final String label;
  final String description;
  final List<String> searchKeywords;
  final List<ProductCapability> capabilities;
  final List<POSCommerceChannel> salesChannels;
  final List<ChannelCoverageRequirement> channelCoverageRequirements;
  final PresentationProfile presentationProfile;
  final String preferredOrderWorkspaceProfileId;
  final List<Module> modules;
  final List<ActionRule> actionRules;

  const ProductProfile({
    required this.id,
    required this.label,
    required this.description,
    this.searchKeywords = const [],
    required this.capabilities,
    required this.salesChannels,
    this.channelCoverageRequirements = defaultChannelCoverageRequirements,
    required this.presentationProfile,
    String? preferredOrderWorkspaceProfileId,
    required this.modules,
    required this.actionRules,
  }) : preferredOrderWorkspaceProfileId =
           preferredOrderWorkspaceProfileId ??
           ecommerceAllCommerceOrderWorkspaceProfileId;

  static final standard = ProductProfile(
    id: 'standard',
    label: 'Standard commerce',
    description: 'Balanced checkout, orders, and fulfillment operations.',
    searchKeywords: const [
      'omnichannel',
      'multi-channel',
      'retail',
      'storefront',
      'kiosk',
    ],
    capabilities: const [
      ProductCapability.storefrontCheckout,
      ProductCapability.marketplaceOrders,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ],
    salesChannels: const [
      SalesChannels.webStore,
      SalesChannels.marketplace,
      SalesChannels.socialOrder,
    ],
    presentationProfile: PresentationProfile.standard,
    modules: defaultModules,
    actionRules: defaultActionRules,
  );

  static final operationsFirst = standard.copyWith(
    id: 'operations_first',
    label: 'Operations first commerce',
    description: 'Prioritizes order attention and daily operational work.',
    searchKeywords: const [
      'back office',
      'ops',
      'order review',
      'daily operations',
    ],
    capabilities: const [
      ProductCapability.operationsReview,
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.marketplaceOrders,
    ],
    salesChannels: const [
      SalesChannels.marketplace,
      SalesChannels.deliveryApp,
      SalesChannels.webStore,
    ],
    presentationProfile: PresentationProfile.operationsFirst,
  );

  static final remotePayment = standard.copyWith(
    id: 'remote_payment',
    label: 'Remote payment commerce',
    description: 'Payment-link checkout for chat, social, and assisted orders.',
    searchKeywords: const [
      'assisted selling',
      'chat commerce',
      'payment link',
      'social selling',
    ],
    capabilities: const [
      ProductCapability.remotePayment,
      ProductCapability.storefrontCheckout,
    ],
    salesChannels: const [
      SalesChannels.socialOrder,
      SalesChannels.phoneOrder,
      SalesChannels.webStore,
    ],
    modules: const [ecommerceRemotePaymentWorkspaceModule, ...defaultModules],
    actionRules: [ecommerceRemotePaymentActionRule, ...defaultActionRules],
  );

  static final subscriptionCommerce = standard.copyWith(
    id: 'subscription_commerce',
    label: 'Subscription commerce',
    description: 'Recurring orders, renewal review, and remote payment flow.',
    searchKeywords: const [
      'membership',
      'recurring billing',
      'renewals',
      'plans',
    ],
    capabilities: const [
      ProductCapability.subscriptionBilling,
      ProductCapability.remotePayment,
      ProductCapability.operationsReview,
    ],
    salesChannels: const [
      SalesChannels.webStore,
      SalesChannels.phoneOrder,
      SalesChannels.socialOrder,
    ],
    presentationProfile: PresentationProfile.operationsFirst,
    modules: const [
      ecommerceRemotePaymentWorkspaceModule,
      ecommerceSubscriptionRenewalsWorkspaceModule,
      ...defaultModules,
    ],
    actionRules: [
      ecommerceRemotePaymentActionRule,
      ecommerceSubscriptionRenewalActionRule,
      ...defaultActionRules,
    ],
  );

  static final fulfillmentFirst = standard.copyWith(
    id: 'fulfillment_first',
    label: 'Fulfillment first commerce',
    description:
        'Pickup, delivery, and shipping operations without checkout noise.',
    searchKeywords: const [
      'delivery operations',
      'dispatch',
      'warehouse',
      'pickup',
    ],
    capabilities: const [
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ],
    salesChannels: const [
      SalesChannels.marketplace,
      SalesChannels.deliveryApp,
      SalesChannels.wholesale,
    ],
    presentationProfile: PresentationProfile.operationsFirst,
    modules: const [
      ecommerceFulfillmentQueueWorkspaceModule,
      ...defaultModules,
    ],
    preferredOrderWorkspaceProfileId: ecommerceDeliveryOrderWorkspaceProfileId,
    actionRules: [ecommerceFulfillmentQueueActionRule, ...defaultActionRules],
  );

  static final marketplaceOperations = standard.copyWith(
    id: 'marketplace_operations',
    label: 'Marketplace operations',
    description:
        'Marketplace order workload, settlement, and fulfillment review.',
    searchKeywords: const [
      'marketplace seller',
      'price list',
      'settlement',
      'seller center',
    ],
    capabilities: const [
      ProductCapability.marketplaceOrders,
      ProductCapability.remotePayment,
      ProductCapability.shipping,
      ProductCapability.operationsReview,
    ],
    salesChannels: const [
      SalesChannels.marketplace,
      SalesChannels.deliveryApp,
      SalesChannels.socialOrder,
    ],
    presentationProfile: PresentationProfile.operationsFirst,
    modules: const [
      ecommerceRemotePaymentWorkspaceModule,
      ecommerceMarketplaceQueueWorkspaceModule,
      ecommerceFulfillmentQueueWorkspaceModule,
      ...defaultModules,
    ],
    preferredOrderWorkspaceProfileId:
        ecommerceMarketplaceOrderWorkspaceProfileId,
    channelCoverageRequirements: const [
      ...defaultChannelCoverageRequirements,
      ecommerceMarketplacePriceListChannelCoverageRequirement,
    ],
    actionRules: [
      ecommerceRemotePaymentActionRule,
      ecommerceMarketplaceQueueActionRule,
      ecommerceFulfillmentQueueActionRule,
      ...defaultActionRules,
    ],
  );

  ProductProfile copyWith({
    String? id,
    String? label,
    String? description,
    List<String>? searchKeywords,
    List<ProductCapability>? capabilities,
    List<POSCommerceChannel>? salesChannels,
    List<ChannelCoverageRequirement>? channelCoverageRequirements,
    PresentationProfile? presentationProfile,
    String? preferredOrderWorkspaceProfileId,
    List<Module>? modules,
    List<ActionRule>? actionRules,
  }) {
    return ProductProfile(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      capabilities: capabilities ?? this.capabilities,
      salesChannels: salesChannels ?? this.salesChannels,
      channelCoverageRequirements:
          channelCoverageRequirements ?? this.channelCoverageRequirements,
      presentationProfile: presentationProfile ?? this.presentationProfile,
      preferredOrderWorkspaceProfileId:
          preferredOrderWorkspaceProfileId ??
          this.preferredOrderWorkspaceProfileId,
      modules: modules ?? this.modules,
      actionRules: actionRules ?? this.actionRules,
    );
  }
}

final List<ProductProfile> defaultProductProfiles =
    List.unmodifiable(<ProductProfile>[
      ProductProfile.standard,
      ProductProfile.operationsFirst,
      ProductProfile.remotePayment,
      ProductProfile.subscriptionCommerce,
      ProductProfile.fulfillmentFirst,
      ProductProfile.marketplaceOperations,
    ]);

ProductProfile productProfileFor({
  required Iterable<ProductProfile> profiles,
  required String profileId,
}) {
  final profileList = profiles.toList(growable: false);
  if (profileList.isEmpty) return ProductProfile.standard;

  final normalizedProfileId = profileId.trim();
  for (final profile in profileList) {
    if (profile.id == normalizedProfileId) return profile;
  }

  return profileList.first;
}

List<ProductProfileIssue> validateProductProfiles({
  required Iterable<ProductProfile> profiles,
  required String selectedProfileId,
}) {
  final profileList = profiles.toList(growable: false);
  final issues = <ProductProfileIssue>[];
  final seenProfileIds = <String>{};
  final normalizedSelectedProfileId = selectedProfileId.trim();

  if (profileList.isEmpty) {
    issues.add(
      const ProductProfileIssue(
        type: ProductProfileIssueType.emptyRegistry,
        message: 'Add at least one commerce product profile.',
      ),
    );
    return List.unmodifiable(issues);
  }

  if (normalizedSelectedProfileId.isEmpty) {
    issues.add(
      const ProductProfileIssue(
        type: ProductProfileIssueType.blankSelectedProfileId,
        message: 'Select a commerce product profile id.',
      ),
    );
  } else if (!profileList.any(
    (profile) => profile.id.trim() == normalizedSelectedProfileId,
  )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.unknownSelectedProfileId,
        profileId: normalizedSelectedProfileId,
        message:
            'Selected commerce product profile "$normalizedSelectedProfileId" is not registered.',
      ),
    );
  }

  for (final profile in profileList) {
    final profileId = profile.id.trim();
    final issueProfileId = profileId.isEmpty ? null : profileId;

    if (profileId.isEmpty) {
      issues.add(
        const ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileId,
          message: 'Commerce product profiles need a stable profile id.',
        ),
      );
    } else if (!seenProfileIds.add(profileId)) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.duplicateProfileId,
          profileId: profileId,
          message: 'Duplicate commerce product profile id "$profileId".',
        ),
      );
    }

    if (profile.label.trim().isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileLabel,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need a visible label.'
                  : 'Commerce product profile "$profileId" needs a visible label.',
        ),
      );
    }

    if (profile.description.trim().isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileDescription,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need helper text.'
                  : 'Commerce product profile "$profileId" needs helper text.',
        ),
      );
    }

    _validateProfileSearchKeywords(
      issues: issues,
      profile: profile,
      profileId: profileId,
      issueProfileId: issueProfileId,
    );

    if (profile.capabilities.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.emptyProfileCapabilities,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need at least one capability.'
                  : 'Commerce product profile "$profileId" needs at least one capability.',
        ),
      );
    }

    if (profile.salesChannels.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.emptyProfileSalesChannels,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need at least one sales channel.'
                  : 'Commerce product profile "$profileId" needs at least one sales channel.',
        ),
      );
    }
    _validateProfileSalesChannels(
      issues: issues,
      profile: profile,
      profileId: profileId,
      issueProfileId: issueProfileId,
    );
    _validateProfileChannelCoverageRequirements(
      issues: issues,
      profile: profile,
      profileId: profileId,
      issueProfileId: issueProfileId,
    );
    _validatePreferredOrderWorkspaceProfile(
      issues: issues,
      profile: profile,
      profileId: profileId,
      issueProfileId: issueProfileId,
    );

    if (profile.modules.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.emptyProfileModules,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need at least one workspace module.'
                  : 'Commerce product profile "$profileId" needs at least one workspace module.',
        ),
      );
    }

    if (profile.actionRules.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.emptyProfileActionRules,
          profileId: issueProfileId,
          message:
              profileId.isEmpty
                  ? 'Commerce product profiles need at least one action rule.'
                  : 'Commerce product profile "$profileId" needs at least one action rule.',
        ),
      );
    }
  }

  return List.unmodifiable(issues);
}

void _validateProfileSearchKeywords({
  required List<ProductProfileIssue> issues,
  required ProductProfile profile,
  required String profileId,
  required String? issueProfileId,
}) {
  final seenKeywords = <String>{};

  for (final keyword in profile.searchKeywords) {
    final normalizedKeyword = keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileSearchKeyword,
          profileId: issueProfileId,
          message: _profileIssueMessage(
            profileId,
            'Commerce product profile search keywords cannot be blank.',
            'Commerce product profile "$profileId" has a blank search keyword.',
          ),
        ),
      );
      continue;
    }

    if (!seenKeywords.add(normalizedKeyword)) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.duplicateProfileSearchKeyword,
          profileId: issueProfileId,
          message:
              'Commerce product profile "$profileId" includes duplicate search keyword "$normalizedKeyword".',
        ),
      );
    }
  }
}

void _validateProfileSalesChannels({
  required List<ProductProfileIssue> issues,
  required ProductProfile profile,
  required String profileId,
  required String? issueProfileId,
}) {
  final channels = profile.salesChannels;
  if (channels.isEmpty) return;

  final seenChannelIds = <String>{};
  for (final channel in channels) {
    final channelId = channel.id.trim();
    if (channelId.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileSalesChannelId,
          profileId: issueProfileId,
          message: _profileIssueMessage(
            profileId,
            'Commerce product profiles need stable sales channel ids.',
            'Commerce product profile "$profileId" has a sales channel without an id.',
          ),
        ),
      );
    } else if (!seenChannelIds.add(channelId)) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.duplicateProfileSalesChannelId,
          profileId: issueProfileId,
          channelId: channelId,
          message:
              'Commerce product profile "$profileId" includes duplicate sales channel "$channelId".',
        ),
      );
    }

    if (channel.label.trim().isEmpty) {
      issues.add(
        ProductProfileIssue(
          type: ProductProfileIssueType.blankProfileSalesChannelLabel,
          profileId: issueProfileId,
          channelId: channelId.isEmpty ? null : channelId,
          message:
              channelId.isEmpty
                  ? _profileIssueMessage(
                    profileId,
                    'Commerce product profile sales channels need visible labels.',
                    'Commerce product profile "$profileId" has a sales channel without a visible label.',
                  )
                  : 'Commerce product profile "$profileId" sales channel "$channelId" needs a visible label.',
        ),
      );
    }
  }

  final capabilities = profile.capabilities.toSet();

  if (capabilities.contains(ProductCapability.storefrontCheckout) &&
      !channels.any(
        (channel) => channel.kind == POSCommerceChannelKind.webStore,
      )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.missingStorefrontSalesChannel,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Storefront checkout profiles need a web store sales channel.',
          'Commerce product profile "$profileId" needs a web store sales channel for storefront checkout.',
        ),
      ),
    );
  }

  if (capabilities.contains(ProductCapability.marketplaceOrders) &&
      !channels.any(
        (channel) => channel.kind == POSCommerceChannelKind.marketplace,
      )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.missingMarketplaceSalesChannel,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Marketplace profiles need a marketplace sales channel.',
          'Commerce product profile "$profileId" needs a marketplace sales channel.',
        ),
      ),
    );
  }

  if (capabilities.contains(ProductCapability.remotePayment) &&
      !channels.any(
        (channel) =>
            channel.supportsCapability(POSCommerceChannelCapability.payments),
      )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.missingRemotePaymentSalesChannel,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Remote payment profiles need a payment-capable sales channel.',
          'Commerce product profile "$profileId" needs a payment-capable sales channel.',
        ),
      ),
    );
  }

  if (capabilities.contains(ProductCapability.subscriptionBilling) &&
      !channels.any(
        (channel) =>
            channel.supportsCapability(POSCommerceChannelCapability.payments) &&
            channel.supportsCapability(
              POSCommerceChannelCapability.customerIdentity,
            ),
      )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.missingSubscriptionSalesChannel,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Subscription profiles need a customer-aware payment channel.',
          'Commerce product profile "$profileId" needs a customer-aware payment channel for subscriptions.',
        ),
      ),
    );
  }

  if (_needsFulfillmentTracking(capabilities) &&
      !channels.any(
        (channel) => channel.supportsCapability(
          POSCommerceChannelCapability.fulfillmentTracking,
        ),
      )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.missingFulfillmentTrackingSalesChannel,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Fulfillment profiles need a fulfillment-tracking sales channel.',
          'Commerce product profile "$profileId" needs a fulfillment-tracking sales channel.',
        ),
      ),
    );
  }
}

void _validateProfileChannelCoverageRequirements({
  required List<ProductProfileIssue> issues,
  required ProductProfile profile,
  required String profileId,
  required String? issueProfileId,
}) {
  final requirements = profile.channelCoverageRequirements;

  if (requirements.isEmpty) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.emptyProfileChannelCoverageRequirements,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Commerce product profiles need at least one channel coverage requirement.',
          'Commerce product profile "$profileId" needs at least one channel coverage requirement.',
        ),
      ),
    );
    return;
  }

  final seenRequirementIds = <String>{};
  for (final requirement in requirements) {
    final requirementId = requirement.id.trim();
    final issueRequirementId = requirementId.isEmpty ? null : requirementId;

    if (requirementId.isEmpty) {
      issues.add(
        ProductProfileIssue(
          type:
              ProductProfileIssueType.blankProfileChannelCoverageRequirementId,
          profileId: issueProfileId,
          message: _profileIssueMessage(
            profileId,
            'Commerce product profile coverage requirements need stable ids.',
            'Commerce product profile "$profileId" has a channel coverage requirement without an id.',
          ),
        ),
      );
    } else if (!seenRequirementIds.add(requirementId)) {
      issues.add(
        ProductProfileIssue(
          type:
              ProductProfileIssueType
                  .duplicateProfileChannelCoverageRequirementId,
          profileId: issueProfileId,
          requirementId: requirementId,
          message:
              'Commerce product profile "$profileId" includes duplicate channel coverage requirement "$requirementId".',
        ),
      );
    }

    if (requirement.label.trim().isEmpty) {
      issues.add(
        ProductProfileIssue(
          type:
              ProductProfileIssueType
                  .blankProfileChannelCoverageRequirementLabel,
          profileId: issueProfileId,
          requirementId: issueRequirementId,
          message:
              requirementId.isEmpty
                  ? _profileIssueMessage(
                    profileId,
                    'Commerce product profile coverage requirements need visible labels.',
                    'Commerce product profile "$profileId" has a channel coverage requirement without a visible label.',
                  )
                  : 'Commerce product profile "$profileId" channel coverage requirement "$requirementId" needs a visible label.',
        ),
      );
    }

    if (requirement.coveredDetail.trim().isEmpty ||
        requirement.missingDetail.trim().isEmpty ||
        requirement.optionalDetail.trim().isEmpty) {
      issues.add(
        ProductProfileIssue(
          type:
              ProductProfileIssueType
                  .blankProfileChannelCoverageRequirementDetail,
          profileId: issueProfileId,
          requirementId: issueRequirementId,
          message:
              requirementId.isEmpty
                  ? _profileIssueMessage(
                    profileId,
                    'Commerce product profile coverage requirements need ready, missing, and optional detail copy.',
                    'Commerce product profile "$profileId" has a channel coverage requirement without complete detail copy.',
                  )
                  : 'Commerce product profile "$profileId" channel coverage requirement "$requirementId" needs ready, missing, and optional detail copy.',
        ),
      );
    }

    _validateProfileChannelCoverageRecommendation(
      issues: issues,
      recommendation: requirement.recommendation,
      profileId: profileId,
      issueProfileId: issueProfileId,
      requirementId: requirementId,
      issueRequirementId: issueRequirementId,
    );
  }
}

void _validatePreferredOrderWorkspaceProfile({
  required List<ProductProfileIssue> issues,
  required ProductProfile profile,
  required String profileId,
  required String? issueProfileId,
}) {
  final preferredProfileId = profile.preferredOrderWorkspaceProfileId.trim();

  if (preferredProfileId.isEmpty) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.blankPreferredOrderWorkspaceProfileId,
        profileId: issueProfileId,
        message: _profileIssueMessage(
          profileId,
          'Commerce product profiles need a preferred order workspace profile.',
          'Commerce product profile "$profileId" needs a preferred order workspace profile.',
        ),
      ),
    );
    return;
  }

  if (!ecommerceDefaultOrderWorkspaceProfiles.any(
    (profile) => profile.id == preferredProfileId,
  )) {
    issues.add(
      ProductProfileIssue(
        type: ProductProfileIssueType.unknownPreferredOrderWorkspaceProfileId,
        profileId: issueProfileId,
        message:
            'Commerce product profile "$profileId" references unknown order workspace profile "$preferredProfileId".',
      ),
    );
  }
}

void _validateProfileChannelCoverageRecommendation({
  required List<ProductProfileIssue> issues,
  required ChannelCoverageRecommendationCopy? recommendation,
  required String profileId,
  required String? issueProfileId,
  required String requirementId,
  required String? issueRequirementId,
}) {
  if (recommendation == null) return;

  if (recommendation.title.trim().isEmpty ||
      recommendation.detail.trim().isEmpty ||
      recommendation.actionLabel.trim().isEmpty) {
    issues.add(
      ProductProfileIssue(
        type:
            ProductProfileIssueType
                .blankProfileChannelCoverageRecommendationCopy,
        profileId: issueProfileId,
        requirementId: issueRequirementId,
        message:
            requirementId.isEmpty
                ? _profileIssueMessage(
                  profileId,
                  'Commerce product profile coverage recommendations need title, detail, and action copy.',
                  'Commerce product profile "$profileId" has a channel coverage recommendation without complete copy.',
                )
                : 'Commerce product profile "$profileId" channel coverage requirement "$requirementId" recommendation needs title, detail, and action copy.',
      ),
    );
  }

  if (recommendation.priority < 0) {
    issues.add(
      ProductProfileIssue(
        type:
            ProductProfileIssueType
                .invalidProfileChannelCoverageRecommendationPriority,
        profileId: issueProfileId,
        requirementId: issueRequirementId,
        message:
            requirementId.isEmpty
                ? _profileIssueMessage(
                  profileId,
                  'Commerce product profile coverage recommendation priorities must be zero or greater.',
                  'Commerce product profile "$profileId" has a channel coverage recommendation with an invalid priority.',
                )
                : 'Commerce product profile "$profileId" channel coverage requirement "$requirementId" recommendation priority must be zero or greater.',
      ),
    );
  }
}

bool _needsFulfillmentTracking(Set<ProductCapability> capabilities) {
  return capabilities.contains(ProductCapability.shipping) ||
      capabilities.contains(ProductCapability.pickupDelivery);
}

String _profileIssueMessage(String profileId, String fallback, String message) {
  return profileId.isEmpty ? fallback : message;
}
