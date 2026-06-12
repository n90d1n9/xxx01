import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_variant_management.dart';
import 'product_workspace_overview_provider.dart';

final productVariantManagementOverviewProvider =
    Provider<ProductVariantManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductVariantManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
