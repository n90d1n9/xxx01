import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_pricing_management.dart';
import 'product_workspace_overview_provider.dart';

final productPricingManagementOverviewProvider =
    Provider<ProductPricingManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductPricingManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
