import 'pos_commerce_channel_registry.dart';

enum POSCommerceChannelBehaviorArea {
  orderCapture,
  checkout,
  fulfillment,
  inventory,
  pricing,
  customer,
  operations,
  synchronization,
}

class POSCommerceChannelBehaviorModule {
  final String id;
  final String label;
  final String description;
  final POSCommerceChannelBehaviorArea area;
  final List<String> traits;

  const POSCommerceChannelBehaviorModule({
    required this.id,
    required this.label,
    required this.description,
    required this.area,
    this.traits = const [],
  });

  bool hasTrait(String trait) {
    final normalizedTrait = trait.trim();
    return traits.any((value) => value.trim() == normalizedTrait);
  }
}

abstract final class POSCommerceChannelBehaviorModules {
  static const counterCheckout = POSCommerceChannelBehaviorModule(
    id: 'counter_checkout',
    label: 'Counter checkout',
    description: 'Cashier-led ordering with direct tender collection.',
    area: POSCommerceChannelBehaviorArea.checkout,
    traits: ['cashier-led', 'direct-payment'],
  );

  static const selfServiceFlow = POSCommerceChannelBehaviorModule(
    id: 'self_service_flow',
    label: 'Self-service flow',
    description: 'Guided ordering for unattended customer-facing screens.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['guided', 'touch-first'],
  );

  static const staffAssistedSelling = POSCommerceChannelBehaviorModule(
    id: 'staff_assisted_selling',
    label: 'Staff-assisted selling',
    description: 'Staff captures orders while staying close to the customer.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['assisted', 'mobile-ready'],
  );

  static const ownedOnlineOrder = POSCommerceChannelBehaviorModule(
    id: 'owned_online_order',
    label: 'Owned online order',
    description: 'Owned storefront orders with customer-managed checkout.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['owned-online', 'customer-account'],
  );

  static const marketplacePolicy = POSCommerceChannelBehaviorModule(
    id: 'marketplace_policy',
    label: 'Marketplace policy',
    description: 'Third-party policy, fee, and reconciliation handling.',
    area: POSCommerceChannelBehaviorArea.operations,
    traits: ['third-party', 'policy-bound'],
  );

  static const conversationOrder = POSCommerceChannelBehaviorModule(
    id: 'conversation_order',
    label: 'Conversation order',
    description: 'Assisted order capture from chat or social channels.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['conversation-led', 'manual-confirmation'],
  );

  static const deliveryAggregator = POSCommerceChannelBehaviorModule(
    id: 'delivery_aggregator',
    label: 'Delivery aggregator',
    description: 'Aggregator order intake with external courier handoff.',
    area: POSCommerceChannelBehaviorArea.operations,
    traits: ['aggregator', 'courier'],
  );

  static const accountPricing = POSCommerceChannelBehaviorModule(
    id: 'account_pricing',
    label: 'Account pricing',
    description: 'Customer account, negotiated price list, or channel pricing.',
    area: POSCommerceChannelBehaviorArea.pricing,
    traits: ['price-list', 'account-aware'],
  );

  static const routeSelling = POSCommerceChannelBehaviorModule(
    id: 'route_selling',
    label: 'Route selling',
    description: 'Field sales order capture with route-aware fulfillment.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['route-based', 'field-ready'],
  );

  static const phoneAssistedOrder = POSCommerceChannelBehaviorModule(
    id: 'phone_assisted_order',
    label: 'Phone-assisted order',
    description: 'Staff-assisted remote order capture with callbacks.',
    area: POSCommerceChannelBehaviorArea.orderCapture,
    traits: ['assisted-remote', 'callback-ready'],
  );

  static const tableServiceLifecycle = POSCommerceChannelBehaviorModule(
    id: 'table_service_lifecycle',
    label: 'Table service lifecycle',
    description: 'Dine-in table state, service staging, and closeout.',
    area: POSCommerceChannelBehaviorArea.operations,
    traits: ['table-aware', 'service-staging'],
  );

  static const immediateFulfillment = POSCommerceChannelBehaviorModule(
    id: 'immediate_fulfillment',
    label: 'Immediate fulfillment',
    description: 'Order is handed over immediately at checkout.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['handoff-now'],
  );

  static const pickupQueue = POSCommerceChannelBehaviorModule(
    id: 'pickup_queue',
    label: 'Pickup queue',
    description: 'Order is prepared for customer pickup.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['pickup'],
  );

  static const deliveryFulfillment = POSCommerceChannelBehaviorModule(
    id: 'delivery_fulfillment',
    label: 'Delivery fulfillment',
    description: 'Order requires a delivery destination and handoff.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['delivery', 'destination-required'],
  );

  static const shipmentFulfillment = POSCommerceChannelBehaviorModule(
    id: 'shipment_fulfillment',
    label: 'Shipment fulfillment',
    description: 'Order is packed and shipped to a customer destination.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['shipment', 'destination-required'],
  );

  static const tableFulfillment = POSCommerceChannelBehaviorModule(
    id: 'table_fulfillment',
    label: 'Table fulfillment',
    description: 'Order is fulfilled to a table or seat location.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['table-service'],
  );

  static const scheduledFulfillment = POSCommerceChannelBehaviorModule(
    id: 'scheduled_fulfillment',
    label: 'Scheduled fulfillment',
    description: 'Order requires a pickup, delivery, or service schedule.',
    area: POSCommerceChannelBehaviorArea.fulfillment,
    traits: ['scheduled'],
  );

  static const inventoryReservation = POSCommerceChannelBehaviorModule(
    id: 'inventory_reservation',
    label: 'Inventory reservation',
    description: 'Channel reserves stock while order work is still pending.',
    area: POSCommerceChannelBehaviorArea.inventory,
    traits: ['stock-hold'],
  );

  static const offlineCapture = POSCommerceChannelBehaviorModule(
    id: 'offline_capture',
    label: 'Offline capture',
    description: 'Order capture can continue while connectivity is unreliable.',
    area: POSCommerceChannelBehaviorArea.synchronization,
    traits: ['offline-ready'],
  );
}

class POSCommerceChannelBehaviorProfile {
  final String channelId;
  final List<POSCommerceChannelBehaviorModule> modules;
  final List<String> traits;

  POSCommerceChannelBehaviorProfile({
    required this.channelId,
    required Iterable<POSCommerceChannelBehaviorModule> modules,
    this.traits = const [],
  }) : modules = List.unmodifiable(modules);

  List<String> get moduleIds {
    return List.unmodifiable(modules.map((module) => module.id));
  }

  List<String> get searchTerms {
    final terms = <String>[
      channelId,
      ...traits,
      for (final module in modules) ...[
        module.id,
        module.label,
        module.description,
        module.area.name,
        ...module.traits,
      ],
    ];

    return List.unmodifiable(
      terms.map((term) => term.trim()).where((term) => term.isNotEmpty),
    );
  }

  bool supportsModule(POSCommerceChannelBehaviorModule module) {
    return supportsModuleId(module.id);
  }

  bool supportsModuleId(String moduleId) {
    final normalizedModuleId = moduleId.trim();
    return modules.any((module) => module.id.trim() == normalizedModuleId);
  }

  bool hasTrait(String trait) {
    final normalizedTrait = trait.trim();
    return traits.any((value) => value.trim() == normalizedTrait) ||
        modules.any((module) => module.hasTrait(normalizedTrait));
  }
}

enum POSCommerceChannelBehaviorRegistryIssueType {
  emptyRegistry,
  blankChannelId,
  duplicateChannelId,
  missingChannelBehavior,
  emptyModules,
  blankModuleId,
  blankModuleLabel,
  duplicateModuleId,
  blankTrait,
}

class POSCommerceChannelBehaviorRegistryIssue {
  final POSCommerceChannelBehaviorRegistryIssueType type;
  final String channelId;
  final String message;

  const POSCommerceChannelBehaviorRegistryIssue({
    required this.type,
    required this.channelId,
    required this.message,
  });

  @override
  String toString() => message;
}

class POSCommerceChannelBehaviorRegistry {
  final List<POSCommerceChannelBehaviorProfile> profiles;

  POSCommerceChannelBehaviorRegistry({
    required Iterable<POSCommerceChannelBehaviorProfile> profiles,
  }) : profiles = List.unmodifiable(profiles);

  List<String> get channelIds {
    return List.unmodifiable(profiles.map((profile) => profile.channelId));
  }

  POSCommerceChannelBehaviorProfile profileForChannel(String channelId) {
    final profile = findByChannelId(channelId);
    if (profile != null) return profile;

    throw StateError(
      'No POS commerce channel behavior registered for "${channelId.trim()}".',
    );
  }

  POSCommerceChannelBehaviorProfile? findByChannelId(String channelId) {
    final normalizedChannelId = channelId.trim();
    for (final profile in profiles) {
      if (profile.channelId.trim() == normalizedChannelId) return profile;
    }

    return null;
  }

  List<POSCommerceChannelBehaviorProfile> profilesForModule(
    POSCommerceChannelBehaviorModule module,
  ) {
    return profilesForModuleId(module.id);
  }

  List<POSCommerceChannelBehaviorProfile> profilesForModuleId(String moduleId) {
    final normalizedModuleId = moduleId.trim();
    return List.unmodifiable(
      profiles.where((profile) => profile.supportsModuleId(normalizedModuleId)),
    );
  }

  List<POSCommerceChannelBehaviorModule> modulesForChannel(String channelId) {
    return profileForChannel(channelId).modules;
  }

  List<String> channelIdsForModule(POSCommerceChannelBehaviorModule module) {
    return channelIdsForModuleId(module.id);
  }

  List<String> channelIdsForModuleId(String moduleId) {
    return List.unmodifiable(
      profilesForModuleId(moduleId).map((profile) => profile.channelId),
    );
  }

  List<POSCommerceChannelBehaviorRegistryIssue> validate({
    POSCommerceChannelRegistry? commerceChannelRegistry,
  }) {
    final issues = <POSCommerceChannelBehaviorRegistryIssue>[];
    if (profiles.isEmpty) {
      issues.add(
        const POSCommerceChannelBehaviorRegistryIssue(
          type: POSCommerceChannelBehaviorRegistryIssueType.emptyRegistry,
          channelId: '',
          message: 'No POS commerce channel behavior profiles are registered.',
        ),
      );
    }

    final idCounts = <String, int>{};
    for (final profile in profiles) {
      final channelId = profile.channelId.trim();
      if (channelId.isNotEmpty) {
        idCounts[channelId] = (idCounts[channelId] ?? 0) + 1;
      }
    }

    for (final profile in profiles) {
      final channelId = profile.channelId.trim();
      if (channelId.isEmpty) {
        issues.add(
          POSCommerceChannelBehaviorRegistryIssue(
            type: POSCommerceChannelBehaviorRegistryIssueType.blankChannelId,
            channelId: profile.channelId,
            message:
                'POS commerce channel behavior channel id cannot be blank.',
          ),
        );
      }

      if (profile.modules.isEmpty) {
        issues.add(
          POSCommerceChannelBehaviorRegistryIssue(
            type: POSCommerceChannelBehaviorRegistryIssueType.emptyModules,
            channelId: profile.channelId,
            message:
                'POS commerce channel behavior "$channelId" must register at least one module.',
          ),
        );
      }

      final moduleIds = <String>{};
      final duplicateModuleIds = <String>{};
      for (final module in profile.modules) {
        final moduleId = module.id.trim();
        if (moduleId.isEmpty) {
          issues.add(
            POSCommerceChannelBehaviorRegistryIssue(
              type: POSCommerceChannelBehaviorRegistryIssueType.blankModuleId,
              channelId: profile.channelId,
              message:
                  'POS commerce channel behavior "$channelId" has a module with a blank id.',
            ),
          );
        } else if (!moduleIds.add(moduleId) &&
            duplicateModuleIds.add(moduleId)) {
          issues.add(
            POSCommerceChannelBehaviorRegistryIssue(
              type:
                  POSCommerceChannelBehaviorRegistryIssueType.duplicateModuleId,
              channelId: profile.channelId,
              message:
                  'POS commerce channel behavior "$channelId" has duplicate module id "$moduleId".',
            ),
          );
        }

        if (module.label.trim().isEmpty) {
          issues.add(
            POSCommerceChannelBehaviorRegistryIssue(
              type:
                  POSCommerceChannelBehaviorRegistryIssueType.blankModuleLabel,
              channelId: profile.channelId,
              message:
                  'POS commerce channel behavior "$channelId" has module "$moduleId" with a blank label.',
            ),
          );
        }

        if (module.traits.any((trait) => trait.trim().isEmpty)) {
          issues.add(
            POSCommerceChannelBehaviorRegistryIssue(
              type: POSCommerceChannelBehaviorRegistryIssueType.blankTrait,
              channelId: profile.channelId,
              message:
                  'POS commerce channel behavior "$channelId" has a module with a blank trait.',
            ),
          );
        }
      }

      if (profile.traits.any((trait) => trait.trim().isEmpty)) {
        issues.add(
          POSCommerceChannelBehaviorRegistryIssue(
            type: POSCommerceChannelBehaviorRegistryIssueType.blankTrait,
            channelId: profile.channelId,
            message:
                'POS commerce channel behavior "$channelId" has a blank trait.',
          ),
        );
      }
    }

    for (final entry in idCounts.entries) {
      if (entry.value <= 1) continue;
      issues.add(
        POSCommerceChannelBehaviorRegistryIssue(
          type: POSCommerceChannelBehaviorRegistryIssueType.duplicateChannelId,
          channelId: entry.key,
          message:
              'Duplicate POS commerce channel behavior profile for "${entry.key}" found.',
        ),
      );
    }

    final channelRegistry = commerceChannelRegistry;
    if (channelRegistry != null) {
      for (final channelId in channelRegistry.channelIds) {
        if (findByChannelId(channelId) != null) continue;

        issues.add(
          POSCommerceChannelBehaviorRegistryIssue(
            type:
                POSCommerceChannelBehaviorRegistryIssueType
                    .missingChannelBehavior,
            channelId: channelId,
            message:
                'POS commerce channel "$channelId" is missing a behavior profile.',
          ),
        );
      }
    }

    return List.unmodifiable(issues);
  }

  bool isValid({POSCommerceChannelRegistry? commerceChannelRegistry}) {
    return validate(commerceChannelRegistry: commerceChannelRegistry).isEmpty;
  }

  void throwIfInvalid({POSCommerceChannelRegistry? commerceChannelRegistry}) {
    final issues = validate(commerceChannelRegistry: commerceChannelRegistry);
    if (issues.isEmpty) return;

    throw StateError(
      'Invalid POS commerce channel behavior registry: '
      '${issues.map((issue) => issue.message).join('; ')}',
    );
  }
}
