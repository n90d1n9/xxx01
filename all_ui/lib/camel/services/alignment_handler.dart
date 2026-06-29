import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/node_route_provider.dart';
import '../states/provider.dart';
import '../services/alignment_tools.dart';
import '../states/select_route_provider.dart';

class AlignmentHandler {
  static void handleAlignment(
    AlignmentType type,
    WidgetRef ref,
    BuildContext context,
  ) {
    final routeId = ref.read(selectedRouteIdProvider);
    final selectedNodeIds = ref.read(selectedNodesProvider);

    if (routeId == null ||
        selectedNodeIds.isEmpty ||
        selectedNodeIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 nodes to align')),
      );
      return;
    }

    ref
        .read(routesProvider.notifier)
        .alignSelectedNodes(routeId, selectedNodeIds, type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aligned ${selectedNodeIds.length} nodes')),
    );
  }
}
