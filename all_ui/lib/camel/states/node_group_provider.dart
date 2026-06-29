import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/node_card.dart';
import '../models/node_group.dart';
import 'select_route_provider.dart';

final nodeGroupsProvider = StateProvider<List<NodeGroup>>((ref) => []);

// Add these providers to your existing providers
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);
final selectedGroupNodesProvider = StateProvider<Set<String>>((ref) => {});

// Helper provider to get nodes by group
final nodesByGroupProvider = Provider.family<List<NodeCard>, String>((
  ref,
  groupId,
) {
  final route = ref.watch(selectedRouteProvider);
  final groups = ref.watch(nodeGroupsProvider);
  final group = groups.firstWhere(
    (g) => g.id == groupId,
    orElse:
        () =>
            NodeGroup(id: '', name: '', color: Colors.transparent, nodeIds: []),
  );
  return route?.nodes
          .where((node) => group.nodeIds.contains(node.id))
          .toList() ??
      [];
});
