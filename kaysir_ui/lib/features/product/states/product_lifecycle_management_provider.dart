import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_lifecycle_management.dart';
import 'management_pack_provider.dart';
import 'product_workspace_overview_provider.dart';

final productLifecycleManagementOverviewProvider =
    Provider<ProductLifecycleManagementOverview>((ref) {
      final overview = ref.watch(productWorkspaceOverviewProvider);
      final managementPack = ref.watch(productManagementPackProvider);

      return buildProductLifecycleManagementOverview(
        records: overview.records,
        channelProfile: overview.channelProfile,
        managementPack: managementPack,
      );
    });
