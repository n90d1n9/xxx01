import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_category_management.dart';
import 'product_workspace_overview_provider.dart';

final productCategoryManagementOverviewProvider =
    Provider<ProductCategoryManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductCategoryManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
