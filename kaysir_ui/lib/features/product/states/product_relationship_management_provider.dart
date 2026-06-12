import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_relationship_management.dart';
import 'product_workspace_overview_provider.dart';

final productRelationshipManagementOverviewProvider =
    Provider<ProductRelationshipManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);

      return buildProductRelationshipManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
      );
    });
