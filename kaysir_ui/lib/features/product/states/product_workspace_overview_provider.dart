import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/states/inventory_projection_provider.dart';
import '../../inventory/states/product_provider.dart';
import '../models/product_workspace_overview.dart';
import 'management_pack_provider.dart';
import 'sales_channel_definition_provider.dart';
import 'product_workspace_action_provider.dart';
import 'product_workspace_recommendation_provider.dart';

final productWorkspaceOverviewProvider = Provider<ProductWorkspaceOverview>((
  ref,
) {
  return buildProductWorkspaceOverview(
    products: ref.watch(productsProvider),
    stockRecords: ref.watch(inventoryStockRecordsProvider),
    actionRegistry: ref.watch(productWorkspaceActionRegistryProvider),
    managementPack: ref.watch(productManagementPackProvider),
    channelProfiles: ref.watch(productSalesChannelProfilesProvider),
    channelProfile: ref.watch(productSalesChannelProfileProvider),
    channelProfilePackOverview: ref.watch(
      productSalesChannelProfilePackOverviewProvider,
    ),
    recommendationContributions: ref.watch(
      productWorkspaceRecommendationContributionsProvider,
    ),
  );
});
