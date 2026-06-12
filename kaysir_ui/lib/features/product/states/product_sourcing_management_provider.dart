import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_sourcing_management.dart';
import 'product_workspace_overview_provider.dart';

final productSourcingManagementOverviewProvider =
    Provider<ProductSourcingManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductSourcingManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
