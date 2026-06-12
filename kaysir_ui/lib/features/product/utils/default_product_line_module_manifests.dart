import '../models/management_module_brief.dart';
import '../models/management_suite_destination.dart';
import '../models/product_line_module_definition.dart';
import '../models/product_line_module_registry.dart';
import '../models/product_workspace_recommendation.dart';
import '../models/product_workspace_setup_target.dart';
import '../models/product_workspace_shortcut.dart';
import '../product_routes.dart';

/// Starter product-line module definitions for reusable end-product builds.
const defaultProductLineModuleDefinitions = [
  coffeeCounterProductLineModuleDefinition,
  restaurantMenuProductLineModuleDefinition,
  retailAssortmentProductLineModuleDefinition,
  kioskSelfServiceProductLineModuleDefinition,
];

/// Default registry used to resolve reusable product-line modules.
final defaultProductLineModuleRegistry = ProductLineModuleRegistry(
  definitions: defaultProductLineModuleDefinitions,
);

/// Generated starter manifests that plug product-line behavior into registry.
final defaultProductLineModuleContributionManifests =
    defaultProductLineModuleRegistry.manifests;

/// Counter-service coffee module for menu, modifier, and station setup.
const coffeeCounterProductLineModuleDefinition = ProductLineModuleDefinition(
  id: 'coffee_counter_operations',
  title: 'Coffee counter operations',
  description:
      'Counter-service menu, modifier, station, and availability hooks.',
  setupTarget: ProductWorkspaceSetupTarget(
    id: 'coffee_menu',
    title: 'Coffee menu setup',
    subtitle: 'Prepare drinks, modifiers, barista station flow, and pickup.',
    actionLabel: 'Review coffee setup',
    recommendationId: 'coffee_counter_operations_setup',
    priority: ProductWorkspaceSetupPriority.high,
    estimatedMinutes: 22,
    requirements: [
      ProductWorkspaceSetupRequirement(
        id: 'drink_menu_data',
        label: 'Drink menu data',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'modifier_options',
        label: 'Modifier options',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'barista_station_handoff',
        label: 'Barista station handoff',
        type: ProductWorkspaceSetupRequirementType.workflow,
      ),
    ],
  ),
  workspaceAction: ProductLineWorkspaceActionSpec(
    groupTitle: 'Coffee counter',
    groupSubtitle: 'Manage drinks, modifiers, pickup windows, and station flow',
    shortcutTitle: 'Menu & modifiers',
    shortcutSubtitle: 'Review drink menu structure before counter launch',
    shortcutStatus: 'Counter setup',
    shortcutId: ProductWorkspaceShortcutId.variantManagement,
    routePath: ProductRoutes.variantManagementPath,
  ),
  recommendation: ProductLineRecommendationSpec(
    title: 'Prepare coffee menu',
    subtitle: 'Check drinks, modifiers, and barista handoff before launch.',
    actionLabel: 'Open setup',
    statusLabel: 'Counter',
    priority: ProductWorkspaceRecommendationPriority.high,
  ),
  briefAction: ProductLineBriefActionSpec(
    title: 'Coffee counter next step',
    description: 'Routes coffee launch work to menu and modifier review.',
    label: 'Review coffee menu',
    detail: 'Drinks, modifiers, and station handoff need launch review.',
    destination: ProductManagementSuiteDestination.variantManagement,
    actionDestination: ProductManagementSuiteDestination.variantManagement,
    routePath: ProductRoutes.variantManagementPath,
    tone: ProductManagementModuleBriefActionTone.info,
  ),
  availabilityTemplates: [
    ProductLineAvailabilityTemplateSpec(
      id: 'counter_service',
      title: 'Coffee counter',
      subtitle: 'POS-first selling for made-to-order beverages.',
      attributes: {
        'available_channels': 'POS, Pickup',
        'sales_status': 'active',
        'stock_policy': 'ingredient_available',
        'fulfillment_modes': 'counter, pickup',
      },
    ),
    ProductLineAvailabilityTemplateSpec(
      id: 'pickup_window',
      title: 'Pickup window',
      subtitle: 'Keep pickup selling behind station capacity and time slots.',
      attributes: {
        'available_channels': 'Online Store, Pickup',
        'sales_status': 'published',
        'stock_policy': 'station_capacity',
        'fulfillment_modes': 'pickup',
      },
    ),
  ],
  readinessRules: [
    ProductLineSetupReadinessRule(
      requirementId: 'drink_menu_data',
      signal: ProductLineSetupReadinessSignal.categories,
      readyReason: 'Drink products have category coverage.',
      missingReason: 'Add drink products with menu categories.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'modifier_options',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: ['modifier_options', 'modifiers', 'options'],
      readyReason: 'Modifier option data is available.',
      missingReason: 'Add modifier options such as size, milk, or add-ons.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'barista_station_handoff',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: ['barista_station', 'prep_station', 'handoff_workflow'],
      readyReason: 'Barista station handoff data is available.',
      missingReason: 'Add barista station or handoff workflow metadata.',
    ),
  ],
);

/// Restaurant menu module for dishes, modifiers, service modes, and timing.
const restaurantMenuProductLineModuleDefinition = ProductLineModuleDefinition(
  id: 'restaurant_menu_operations',
  title: 'Restaurant menu operations',
  description:
      'Dine-in, takeaway, modifier, course, and menu availability hooks.',
  setupTarget: ProductWorkspaceSetupTarget(
    id: 'restaurant_menu',
    title: 'Restaurant menu setup',
    subtitle: 'Prepare dishes, modifiers, prep stations, and service modes.',
    actionLabel: 'Review restaurant menu',
    recommendationId: 'restaurant_menu_operations_setup',
    priority: ProductWorkspaceSetupPriority.high,
    estimatedMinutes: 28,
    requirements: [
      ProductWorkspaceSetupRequirement(
        id: 'dish_catalog_data',
        label: 'Dish catalog data',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'modifier_and_course_rules',
        label: 'Modifier and course rules',
        type: ProductWorkspaceSetupRequirementType.workflow,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'service_mode_channels',
        label: 'Service mode channels',
        type: ProductWorkspaceSetupRequirementType.channel,
      ),
    ],
  ),
  workspaceAction: ProductLineWorkspaceActionSpec(
    groupTitle: 'Restaurant menu',
    groupSubtitle: 'Coordinate dishes, courses, modifiers, and service modes',
    shortcutTitle: 'Dish catalog',
    shortcutSubtitle: 'Review dish and modifier structure before service',
    shortcutStatus: 'Menu setup',
    shortcutId: ProductWorkspaceShortcutId.relationshipManagement,
    routePath: ProductRoutes.relationshipManagementPath,
  ),
  recommendation: ProductLineRecommendationSpec(
    title: 'Prepare restaurant menu',
    subtitle: 'Review dishes, modifiers, and service-mode selling gates.',
    actionLabel: 'Open menu setup',
    statusLabel: 'Menu',
    priority: ProductWorkspaceRecommendationPriority.high,
  ),
  briefAction: ProductLineBriefActionSpec(
    title: 'Restaurant menu next step',
    description: 'Routes restaurant launch work to menu relationship review.',
    label: 'Review menu structure',
    detail: 'Dishes, modifiers, and service modes need launch review.',
    destination: ProductManagementSuiteDestination.relationshipManagement,
    actionDestination: ProductManagementSuiteDestination.relationshipManagement,
    routePath: ProductRoutes.relationshipManagementPath,
    tone: ProductManagementModuleBriefActionTone.info,
  ),
  availabilityTemplates: [
    ProductLineAvailabilityTemplateSpec(
      id: 'dine_in_takeaway',
      title: 'Dine-in and takeaway',
      subtitle: 'Restaurant selling across table service and takeaway.',
      attributes: {
        'available_channels': 'POS, Online Store',
        'sales_status': 'active',
        'stock_policy': 'prep_available',
        'fulfillment_modes': 'dine_in, takeaway',
      },
    ),
    ProductLineAvailabilityTemplateSpec(
      id: 'service_pause',
      title: 'Service pause',
      subtitle: 'Pause menu items during prep overload or station outages.',
      attributes: {
        'availability_status': 'paused',
        'availability_window': 'service_pause',
        'fulfillment_modes': 'dine_in, takeaway',
      },
    ),
  ],
  readinessRules: [
    ProductLineSetupReadinessRule(
      requirementId: 'dish_catalog_data',
      signal: ProductLineSetupReadinessSignal.categories,
      readyReason: 'Dish products have menu category coverage.',
      missingReason: 'Add dish products with menu categories.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'modifier_and_course_rules',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: ['modifier_rules', 'modifiers', 'course_rules', 'course'],
      readyReason: 'Modifier or course rules are available.',
      missingReason: 'Add modifier or course rules for service flow.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'service_mode_channels',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: [
        'service_modes',
        'available_channels',
        'fulfillment_modes',
      ],
      readyReason: 'Service mode channel data is available.',
      missingReason: 'Add dine-in, takeaway, or delivery channel metadata.',
    ),
  ],
);

/// Retail assortment module for category, pricing, and channel coverage.
const retailAssortmentProductLineModuleDefinition = ProductLineModuleDefinition(
  id: 'retail_assortment_operations',
  title: 'Retail assortment operations',
  description:
      'General retail assortment, category, pricing, and channel hooks.',
  setupTarget: ProductWorkspaceSetupTarget(
    id: 'retail_assortment',
    title: 'Retail assortment setup',
    subtitle: 'Prepare category coverage, pricing, and selling channels.',
    actionLabel: 'Review assortment',
    recommendationId: 'retail_assortment_operations_setup',
    priority: ProductWorkspaceSetupPriority.medium,
    estimatedMinutes: 18,
    requirements: [
      ProductWorkspaceSetupRequirement(
        id: 'category_coverage',
        label: 'Category coverage',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'price_coverage',
        label: 'Price coverage',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'channel_listing_rules',
        label: 'Channel listing rules',
        type: ProductWorkspaceSetupRequirementType.channel,
      ),
    ],
  ),
  workspaceAction: ProductLineWorkspaceActionSpec(
    groupTitle: 'Retail assortment',
    groupSubtitle:
        'Balance category coverage, pricing readiness, and channel launch',
    shortcutTitle: 'Assortment plan',
    shortcutSubtitle: 'Review category and channel coverage',
    shortcutStatus: 'Retail setup',
    shortcutId: ProductWorkspaceShortcutId.assortmentPlanning,
    routePath: ProductRoutes.assortmentPlanningPath,
  ),
  recommendation: ProductLineRecommendationSpec(
    title: 'Prepare retail assortment',
    subtitle: 'Check category, price, and channel coverage for launch.',
    actionLabel: 'Open assortment',
    statusLabel: 'Retail',
  ),
  briefAction: ProductLineBriefActionSpec(
    title: 'Retail assortment next step',
    description: 'Routes retail launch work to assortment planning.',
    label: 'Review assortment plan',
    detail: 'Category, price, and channel coverage need launch review.',
    destination: ProductManagementSuiteDestination.assortmentPlanning,
    actionDestination: ProductManagementSuiteDestination.assortmentPlanning,
    routePath: ProductRoutes.assortmentPlanningPath,
  ),
  availabilityTemplates: [
    ProductLineAvailabilityTemplateSpec(
      id: 'omni_retail',
      title: 'Omni retail',
      subtitle: 'POS, online, and marketplace selling from one catalog.',
      attributes: {
        'available_channels': 'POS, Online Store, Marketplace',
        'sales_status': 'published',
        'stock_policy': 'stock_required',
        'fulfillment_modes': 'pickup, delivery, shipping',
      },
    ),
    ProductLineAvailabilityTemplateSpec(
      id: 'store_only',
      title: 'Store only',
      subtitle: 'In-store selling with strict stock and scan readiness.',
      attributes: {
        'available_channels': 'POS',
        'sales_status': 'active',
        'stock_policy': 'in_stock_only',
        'fulfillment_modes': 'pickup',
      },
    ),
  ],
  readinessRules: [
    ProductLineSetupReadinessRule(
      requirementId: 'category_coverage',
      signal: ProductLineSetupReadinessSignal.categories,
      readyReason: 'Retail products have category coverage.',
      missingReason: 'Add category values to retail products.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'price_coverage',
      signal: ProductLineSetupReadinessSignal.pricing,
      readyReason: 'Retail products have sellable prices.',
      missingReason: 'Add sellable prices before retail launch.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'channel_listing_rules',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: [
        'available_channels',
        'enabled_channels',
        'sales_channels',
        'fulfillment_modes',
      ],
      readyReason: 'Retail channel listing rules are available.',
      missingReason: 'Add channel or fulfillment rules for retail selling.',
    ),
  ],
);

/// Kiosk self-service module for kiosk bundles, gates, and channel readiness.
const kioskSelfServiceProductLineModuleDefinition = ProductLineModuleDefinition(
  id: 'kiosk_self_service_operations',
  title: 'Kiosk self-service operations',
  description:
      'Self-service kiosk bundle, scan, availability, and launch hooks.',
  setupTarget: ProductWorkspaceSetupTarget(
    id: 'kiosk_bundle',
    title: 'Kiosk bundle setup',
    subtitle: 'Prepare kiosk-safe catalog, scan rules, and stock gates.',
    actionLabel: 'Review kiosk setup',
    recommendationId: 'kiosk_self_service_operations_setup',
    priority: ProductWorkspaceSetupPriority.high,
    estimatedMinutes: 24,
    requirements: [
      ProductWorkspaceSetupRequirement(
        id: 'kiosk_catalog_copy',
        label: 'Kiosk catalog copy',
        type: ProductWorkspaceSetupRequirementType.data,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'scan_and_payment_flow',
        label: 'Scan and payment flow',
        type: ProductWorkspaceSetupRequirementType.workflow,
      ),
      ProductWorkspaceSetupRequirement(
        id: 'kiosk_channel_gate',
        label: 'Kiosk channel gate',
        type: ProductWorkspaceSetupRequirementType.channel,
      ),
    ],
  ),
  workspaceAction: ProductLineWorkspaceActionSpec(
    groupTitle: 'Kiosk self-service',
    groupSubtitle:
        'Control kiosk-safe catalog coverage, scan flow, and stock gates',
    shortcutTitle: 'Kiosk readiness',
    shortcutSubtitle: 'Review channel gates before self-service launch',
    shortcutStatus: 'Kiosk setup',
    shortcutId: ProductWorkspaceShortcutId.channelReadiness,
    routePath: ProductRoutes.channelReadinessPath,
  ),
  recommendation: ProductLineRecommendationSpec(
    title: 'Prepare kiosk catalog',
    subtitle: 'Check kiosk-safe copy, scan flow, and stock gates.',
    actionLabel: 'Open kiosk setup',
    statusLabel: 'Kiosk',
    priority: ProductWorkspaceRecommendationPriority.high,
  ),
  briefAction: ProductLineBriefActionSpec(
    title: 'Kiosk next step',
    description: 'Routes self-service launch work to channel readiness.',
    label: 'Review kiosk readiness',
    detail: 'Kiosk-safe copy, scan flow, and channel gates need review.',
    destination: ProductManagementSuiteDestination.channelReadiness,
    actionDestination: ProductManagementSuiteDestination.channelReadiness,
    routePath: ProductRoutes.channelReadinessPath,
    tone: ProductManagementModuleBriefActionTone.warning,
  ),
  availabilityTemplates: [
    ProductLineAvailabilityTemplateSpec(
      id: 'self_service_kiosk',
      title: 'Self-service kiosk',
      subtitle: 'Kiosk selling with strict stock and scan gates.',
      attributes: {
        'available_channels': 'Kiosk',
        'sales_status': 'active',
        'stock_policy': 'in_stock_only',
        'fulfillment_modes': 'self_service',
      },
    ),
    ProductLineAvailabilityTemplateSpec(
      id: 'assisted_kiosk',
      title: 'Assisted kiosk',
      subtitle: 'Kiosk discovery with staff-assisted fulfillment.',
      attributes: {
        'available_channels': 'Kiosk, POS',
        'sales_status': 'active',
        'stock_policy': 'staff_confirmed',
        'fulfillment_modes': 'self_service, assisted',
      },
    ),
  ],
  readinessRules: [
    ProductLineSetupReadinessRule(
      requirementId: 'kiosk_catalog_copy',
      signal: ProductLineSetupReadinessSignal.descriptions,
      readyReason: 'Kiosk catalog copy is available.',
      missingReason: 'Add short customer-facing product copy.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'scan_and_payment_flow',
      signal: ProductLineSetupReadinessSignal.scanCodes,
      readyReason: 'Kiosk scan flow has scan-ready products.',
      missingReason: 'Add barcode or shortcut data for kiosk scan flow.',
    ),
    ProductLineSetupReadinessRule(
      requirementId: 'kiosk_channel_gate',
      signal: ProductLineSetupReadinessSignal.customAttributes,
      attributeKeys: [
        'available_channels',
        'enabled_channels',
        'sales_channels',
        'fulfillment_modes',
      ],
      readyReason: 'Kiosk channel gate data is available.',
      missingReason: 'Add kiosk channel or fulfillment metadata.',
    ),
  ],
);
