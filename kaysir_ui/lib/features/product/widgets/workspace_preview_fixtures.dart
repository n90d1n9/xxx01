import '../../inventory/models/inventory_item.dart';
import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/models/inventory_stock_record.dart';
import '../../inventory/models/warehouse.dart';
import '../product_routes.dart';
import '../models/management_pack.dart';
import '../models/product.dart';
import '../models/product_workspace_action_group.dart';
import '../models/product_workspace_action_registry.dart';
import '../models/product_workspace_overview.dart';
import '../models/product_workspace_recommendation.dart';
import '../models/product_workspace_setup_action.dart';
import '../models/product_workspace_setup_overview.dart';
import '../models/product_workspace_setup_target.dart';
import '../models/sales_channel_profile.dart';
import '../models/sales_channel_profile_pack_overview.dart';

/// Compact product workspace summary used by widget previews.
const previewProductWorkspaceSummary = InventoryProductCatalogSummary(
  productCount: 24,
  trackedProductCount: 21,
  inStockProductCount: 18,
  untrackedProductCount: 3,
  attentionProductCount: 4,
  totalQuantity: 486,
  totalInventoryValue: 18640000,
  categoryCount: 7,
);

/// Representative product workspace overview used by widget previews.
final previewProductWorkspaceOverview = _buildPreviewProductWorkspaceOverview();

/// Representative grouped workspace shortcuts used by widget previews.
final previewProductWorkspaceActionGroups = buildProductWorkspaceActionGroups(
  previewProductWorkspaceSummary,
);

/// Representative product workspace recommendations used by widget previews.
const previewProductWorkspaceRecommendations = [
  ProductWorkspaceRecommendation(
    id: 'launch_queue',
    title: 'Clear launch queue',
    subtitle: 'Counter service: Add scan code before morning rush',
    actionLabel: 'Open queue',
    statusLabel: 'Priority',
    priority: ProductWorkspaceRecommendationPriority.critical,
    routePath: '/products?filter=in_stock&q=scan',
  ),
  ProductWorkspaceRecommendation(
    id: 'catalog_setup',
    title: 'Complete catalog setup',
    subtitle: '3 fresh goods still need expiry and batch fields',
    actionLabel: 'Open setup',
    statusLabel: 'Setup',
    sourceLabel: 'Fresh Goods',
    priority: ProductWorkspaceRecommendationPriority.high,
    routePath: '/products?review=freshness',
  ),
  ProductWorkspaceRecommendation(
    id: 'stock_attention',
    title: 'Review stock attention',
    subtitle: '4 tracked products need replenishment decisions',
    actionLabel: 'Open attention',
    statusLabel: 'Attention',
    priority: ProductWorkspaceRecommendationPriority.medium,
    routePath: '/products?filter=attention',
  ),
];

/// Representative setup target used by product workspace setup previews.
const previewProductWorkspaceSetupTarget = ProductWorkspaceSetupTarget(
  id: 'restaurant_menu',
  title: 'Restaurant menu setup',
  subtitle: 'Prepare dine-in menu metadata before publishing the menu channel.',
  actionLabel: 'Review menu setup',
  priority: ProductWorkspaceSetupPriority.medium,
  estimatedMinutes: 16,
  requirements: [
    ProductWorkspaceSetupRequirement(
      id: 'menu_category_data',
      label: 'Menu categories',
      type: ProductWorkspaceSetupRequirementType.data,
    ),
    ProductWorkspaceSetupRequirement(
      id: 'kitchen_routing',
      label: 'Kitchen routing',
      type: ProductWorkspaceSetupRequirementType.workflow,
    ),
    ProductWorkspaceSetupRequirement(
      id: 'delivery_channel',
      label: 'Delivery channel',
      type: ProductWorkspaceSetupRequirementType.channel,
      required: false,
    ),
  ],
);

/// Representative setup prompt used by the focused setup notice preview.
const previewProductWorkspaceSetupPrompt = ProductWorkspaceSetupPrompt(
  target: previewProductWorkspaceSetupTarget,
  action: ProductWorkspaceSetupAction(
    targetId: 'restaurant_menu',
    label: 'Review menu setup',
    routePath: ProductRoutes.catalogPath,
    source: ProductWorkspaceSetupActionSource.fallback,
  ),
);

/// Representative product workspace setup overview used by setup previews.
final previewProductWorkspaceSetupOverview =
    ProductWorkspaceSetupOverview.fromPrompts(const [
      _previewProductWorkspaceSetupInactivePrompt,
      previewProductWorkspaceSetupPrompt,
    ]);

/// Representative setup requirements used by requirement chip previews.
final previewProductWorkspaceSetupRequirements =
    previewProductWorkspaceSetupTarget.requirements;

ProductWorkspaceOverview _buildPreviewProductWorkspaceOverview() {
  final registry = ProductSalesChannelProfileRegistry.fromPacks(
    groceryFreshGoodsProductManagementPack.profilePacks,
  );
  final selectedProfile = registry.fallbackProfile;

  return buildProductWorkspaceOverview(
    products: _previewProducts,
    stockRecords: _previewStockRecords,
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: groceryFreshGoodsProductManagementPack,
    ),
    managementPack: groceryFreshGoodsProductManagementPack,
    channelProfiles: registry.profiles,
    channelProfile: selectedProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: groceryFreshGoodsProductManagementPack.profilePacks,
      registry: registry,
      selectedProfile: selectedProfile,
    ),
  );
}

const _previewProductWorkspaceSetupInactivePrompt = ProductWorkspaceSetupPrompt(
  target: ProductWorkspaceSetupTarget.freshness,
  availability: ProductWorkspaceSetupTargetAvailability.inactive,
  action: ProductWorkspaceSetupAction(
    targetId: productWorkspaceFreshnessSetupTargetId,
    label: 'Switch to Grocery Fresh Goods',
    routePath: ProductRoutes.workspacePath,
    source: ProductWorkspaceSetupActionSource.inactiveTarget,
    activation: ProductWorkspaceSetupActivation(
      targetId: productWorkspaceFreshnessSetupTargetId,
      packId: ProductManagementPackId.groceryFreshGoods,
      packTitle: 'Grocery Fresh Goods',
      packFocusLabel: 'Freshness control unlocks expiry and batch workflows',
    ),
  ),
);

final _previewProducts = [
  Product(
    id: 'preview-produce',
    name: 'Organic Spinach',
    sku: 'FR-001',
    category: 'Fresh Produce',
    description: 'Morning delivery bundle',
    price: 18000,
    barcode: '89910001',
    customAttributes: const {'expiryDate': '2026-06-14', 'batchCode': 'SP-01'},
  ),
  Product(
    id: 'preview-dairy',
    name: 'Cold Brew Bottle',
    sku: 'CB-250',
    category: 'Ready Drink',
    price: 28000,
    barcode: '89910002',
  ),
  Product(
    id: 'preview-bakery',
    name: 'Sourdough Loaf',
    category: 'Bakery',
    description: 'Daily bake',
    price: 42000,
  ),
];

final _previewWarehouse = Warehouse(
  id: 'preview-warehouse',
  name: 'Main Counter',
  location: 'Front store',
);

final _previewStockRecords = [
  InventoryStockRecord(
    item: InventoryItem(
      id: 'preview-stock-1',
      productId: 'preview-produce',
      warehouseId: 'preview-warehouse',
      currentQuantity: 32,
      reorderPoint: 12,
      reorderQuantity: 24,
    ),
    product: _previewProducts[0],
    warehouse: _previewWarehouse,
  ),
  InventoryStockRecord(
    item: InventoryItem(
      id: 'preview-stock-2',
      productId: 'preview-dairy',
      warehouseId: 'preview-warehouse',
      currentQuantity: 6,
      reorderPoint: 10,
      reorderQuantity: 18,
    ),
    product: _previewProducts[1],
    warehouse: _previewWarehouse,
  ),
];
