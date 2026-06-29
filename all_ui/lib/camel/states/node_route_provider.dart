// Routes State with History Support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/camel/models/node_connection.dart';

import '../models/node_card.dart';
import '../models/node.dart';
import '../models/history_entry.dart';
import '../models/node_group.dart';
import '../services/alignment_tools.dart';
import 'node_group_provider.dart';
import 'provider.dart';
import 'route_history_provider.dart';
import 'select_route_provider.dart';

final routesProvider = StateNotifierProvider<RoutesNotifier, List<WNode>>((
  ref,
) {
  return RoutesNotifier(ref);
});

class RoutesNotifier extends StateNotifier<List<WNode>> {
  RoutesNotifier(this.ref) : super([]);
  final Ref ref;

  void _saveHistory() {
    final selectedRouteId = ref.read(selectedRouteIdProvider);
    ref
        .read(routeHistoryProvider.notifier)
        .push(
          HistoryEntry(
            routes: List.from(state),
            selectedRouteId: selectedRouteId,
          ),
        );
  }

  void restoreFromHistory(HistoryEntry entry) {
    state = List.from(entry.routes);
    if (entry.selectedRouteId != null) {
      ref.read(selectedRouteIdProvider.notifier).state = entry.selectedRouteId;
    }
  }

  void addRoute(WNode route) {
    state = [...state, route];
    _saveHistory();
  }

  void updateRoute(String id, WNode route) {
    state = [
      for (final r in state)
        if (r.id == id) route else r,
    ];
    _saveHistory();
  }

  void deleteRoute(String id) {
    state = state.where((r) => r.id != id).toList();
    _saveHistory();
  }

  void addNodeToRoute(String routeId, NodeCard node) {
    state = [
      for (final r in state)
        if (r.id == routeId) r.copyWith(nodes: [...r.nodes, node]) else r,
    ];
    _saveHistory();
  }

  void updateNodeInRoute(String routeId, String nodeId, NodeCard node) {
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                if (n.id == nodeId) node else n,
            ],
          )
        else
          r,
    ];
    _saveHistory();
  }

  void deleteNodeFromRoute(String routeId, String nodeId) {
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(nodes: r.nodes.where((n) => n.id != nodeId).toList())
        else
          r,
    ];
    _saveHistory();
  }

  void deleteNodesFromRoute(String routeId, Set<String> nodeIds) {
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: r.nodes.where((n) => !nodeIds.contains(n.id)).toList(),
          )
        else
          r,
    ];
    _saveHistory();
  }

  void connectNodes(String routeId, String fromNodeId, String toNodeId) {
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                if (n.id == fromNodeId)
                  n.copyWith(
                    connections: [
                      ...n.connections,
                      NodeConnection(targetNodeId: toNodeId),
                    ],
                  )
                else
                  n,
            ],
          )
        else
          r,
    ];
    _saveHistory();
  }

  void moveNodes(String routeId, Set<String> nodeIds, Offset delta) {
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                if (nodeIds.contains(n.id))
                  n.copyWith(position: n.position + delta)
                else
                  n,
            ],
          )
        else
          r,
    ];
  }

  void autoLayout(String routeId) {
    final route = state.firstWhere((r) => r.id == routeId);
    if (route.nodes.isEmpty) return;

    // Simple hierarchical layout
    final Map<String, int> levels = {};
    final Map<String, List<String>> childrenMap = {};

    // Build adjacency map - fix here: use targetNodeId from connections
    for (final node in route.nodes) {
      for (final connection in node.connections) {
        if (connection.targetNodeId != null) {
          childrenMap
              .putIfAbsent(node.id, () => [])
              .add(connection.targetNodeId!);
        }
      }
    }

    // Find root nodes (nodes with no incoming connections)
    final Set<String> allTargets = {};
    for (final children in childrenMap.values) {
      allTargets.addAll(children);
    }

    final roots = route.nodes.where((n) => !allTargets.contains(n.id)).toList();

    // Fixed assignLevels function
    void assignLevels(String nodeId, int level) {
      // Only update if we found a deeper level or haven't seen this node
      if (!levels.containsKey(nodeId) || levels[nodeId]! < level) {
        levels[nodeId] = level;
        final children = childrenMap[nodeId] ?? [];
        for (final childId in children) {
          assignLevels(childId, level + 1);
        }
      }
    }

    // Assign levels starting from roots
    for (final root in roots) {
      assignLevels(root.id, 0);
    }

    // Handle nodes that weren't reached by BFS (isolated nodes or cycles)
    for (final node in route.nodes) {
      if (!levels.containsKey(node.id)) {
        levels[node.id] = 0; // Assign to level 0 as fallback
      }
    }

    // Position nodes
    final Map<int, List<NodeCard>> nodesByLevel = {};
    for (final node in route.nodes) {
      final level = levels[node.id] ?? 0;
      nodesByLevel.putIfAbsent(level, () => []).add(node);
    }

    // Sort nodes within each level for consistent layout
    nodesByLevel.forEach((level, nodes) {
      // Sort by existing Y position for stability, or by ID as fallback
      nodes.sort((a, b) {
        final yCompare = a.position.dy.compareTo(b.position.dy);
        return yCompare != 0 ? yCompare : a.id.compareTo(b.id);
      });
    });

    const double levelSpacing = 250.0;
    const double nodeSpacing = 150.0;
    const double startX = 100.0;
    const double startY = 100.0;

    final List<NodeCard> positionedNodes = [];

    // Layout nodes level by level
    final sortedLevels = nodesByLevel.keys.toList()..sort();
    for (final level in sortedLevels) {
      final nodes = nodesByLevel[level]!;
      final levelHeight = (nodes.length - 1) * nodeSpacing;
      final startLevelY =
          startY - levelHeight / 2; // Center the level vertically

      for (int i = 0; i < nodes.length; i++) {
        final x = startX + level * levelSpacing;
        final y = startLevelY + i * nodeSpacing;
        positionedNodes.add(nodes[i].copyWith(position: Offset(x, y)));
      }
    }

    state = [
      for (final r in state)
        if (r.id == routeId) r.copyWith(nodes: positionedNodes) else r,
    ];
    _saveHistory();
  }

  // Add this method to your RoutesNotifier class
  void ungroup(String groupId) {
    final groups = ref.read(nodeGroupsProvider);
    final group = groups.firstWhere((g) => g.id == groupId);

    // Remove groupId from all nodes in the group
    state = [
      for (final r in state)
        r.copyWith(
          nodes: [
            for (final n in r.nodes)
              if (group.nodeIds.contains(n.id))
                n.copyWith(groupId: null)
              else
                n,
          ],
        ),
    ];

    // Remove the group
    ref
        .read(nodeGroupsProvider.notifier)
        .update((groups) => groups.where((g) => g.id != groupId).toList());

    // Clear selection if the ungrouped group was selected
    if (ref.read(selectedGroupIdProvider) == groupId) {
      ref.read(selectedGroupIdProvider.notifier).state = null;
    }

    _saveHistory();
  }

  void alignSelectedNodes(
    String routeId,
    Set<String> nodeIds,
    AlignmentType type,
  ) {
    final route = state.firstWhere((r) => r.id == routeId);
    final selectedNodes =
        route.nodes.where((n) => nodeIds.contains(n.id)).toList();

    if (selectedNodes.length < 2) return;

    AlignmentTools.alignNodes(selectedNodes, type);

    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                selectedNodes.firstWhere(
                  (sn) => sn.id == n.id,
                  orElse: () => n,
                ),
            ],
          )
        else
          r,
    ];
    _saveHistory();
  }

  //----
  void createGroup(
    String routeId,
    Set<String> nodeIds,
    String name,
    Color color,
  ) {
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';

    // Update node groups
    ref
        .read(nodeGroupsProvider.notifier)
        .update(
          (groups) => [
            ...groups,
            NodeGroup(
              id: groupId,
              name: name,
              color: color,
              nodeIds: nodeIds.toList(),
            ),
          ],
        );

    // Update nodes with groupId
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                if (nodeIds.contains(n.id)) n.copyWith(groupId: groupId) else n,
            ],
          )
        else
          r,
    ];
    _saveHistory();
  }

  void updateGroup(String groupId, NodeGroup updatedGroup) {
    ref
        .read(nodeGroupsProvider.notifier)
        .update(
          (groups) => [
            for (final group in groups)
              if (group.id == groupId) updatedGroup else group,
          ],
        );
    _saveHistory();
  }

  void deleteGroup(String groupId) {
    // Remove groupId from nodes
    state = [
      for (final r in state)
        r.copyWith(
          nodes: [
            for (final n in r.nodes)
              if (n.groupId == groupId) n.copyWith(groupId: null) else n,
          ],
        ),
    ];

    // Remove the group
    ref
        .read(nodeGroupsProvider.notifier)
        .update((groups) => groups.where((g) => g.id != groupId).toList());
    _saveHistory();
  }

  void addNodesToGroup(String groupId, Set<String> nodeIds) {
    final groups = ref.read(nodeGroupsProvider);
    final group = groups.firstWhere((g) => g.id == groupId);

    final updatedGroup = group.copyWith(
      nodeIds: [...group.nodeIds, ...nodeIds],
    );

    // Update nodes with groupId
    state = [
      for (final r in state)
        r.copyWith(
          nodes: [
            for (final n in r.nodes)
              if (nodeIds.contains(n.id)) n.copyWith(groupId: groupId) else n,
          ],
        ),
    ];

    updateGroup(groupId, updatedGroup);
  }

  void removeNodesFromGroup(String groupId, Set<String> nodeIds) {
    final groups = ref.read(nodeGroupsProvider);
    final group = groups.firstWhere((g) => g.id == groupId);

    final updatedGroup = group.copyWith(
      nodeIds: group.nodeIds.where((id) => !nodeIds.contains(id)).toList(),
    );

    // Remove groupId from nodes
    state = [
      for (final r in state)
        r.copyWith(
          nodes: [
            for (final n in r.nodes)
              if (nodeIds.contains(n.id)) n.copyWith(groupId: null) else n,
          ],
        ),
    ];

    updateGroup(groupId, updatedGroup);
  }

  void moveGroup(String routeId, String groupId, Offset delta) {
    final groups = ref.read(nodeGroupsProvider);
    final group = groups.firstWhere((g) => g.id == groupId);

    // Move all nodes in the group
    state = [
      for (final r in state)
        if (r.id == routeId)
          r.copyWith(
            nodes: [
              for (final n in r.nodes)
                if (group.nodeIds.contains(n.id))
                  n.copyWith(position: n.position + delta)
                else
                  n,
            ],
          )
        else
          r,
    ];
    _saveHistory();
  }

  void selectGroup(String groupId) {
    final groups = ref.read(nodeGroupsProvider);
    final group = groups.firstWhere((g) => g.id == groupId);

    // Set selected group
    ref.read(selectedGroupIdProvider.notifier).state = groupId;

    // Select all nodes in the group
    ref.read(selectedNodesProvider.notifier).state = group.nodeIds.toSet();
  }

  void deselectGroup() {
    ref.read(selectedGroupIdProvider.notifier).state = null;
    ref.read(selectedGroupNodesProvider.notifier).state = {};
  }
}
