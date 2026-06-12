import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_assortment_plan.dart';
import 'management_pack_provider.dart';
import 'product_workspace_overview_provider.dart';

final productAssortmentPlanProvider = Provider<ProductAssortmentPlan>((ref) {
  final overview = ref.watch(productWorkspaceOverviewProvider);

  return buildProductAssortmentPlan(
    records: overview.records,
    managementPack: ref.watch(productManagementPackProvider),
    channelProfile: overview.channelProfile,
  );
});
