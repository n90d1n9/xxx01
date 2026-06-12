import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_availability_management.dart';
import 'product_workspace_overview_provider.dart';

final productAvailabilityManagementOverviewProvider =
    Provider<ProductAvailabilityManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductAvailabilityManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
