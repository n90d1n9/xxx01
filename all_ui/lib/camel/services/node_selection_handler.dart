import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/clipboard_provider.dart';
import '../states/node_route_provider.dart';
import '../states/provider.dart';
import '../states/select_route_provider.dart';

class NodeSelectionHandler {
  static void selectAllNodes(WidgetRef ref) {
    final route = ref.read(selectedRouteProvider);
    if (route == null) return;

    ref.read(selectedNodesProvider.notifier).state =
        route.nodes.map((n) => n.id).toSet();
  }

  static void copySelectedNodes(WidgetRef ref, BuildContext context) {
    final route = ref.read(selectedRouteProvider);
    final selectedNodeIds = ref.read(selectedNodesProvider);

    if (route == null || selectedNodeIds.isEmpty) return;

    final nodesToCopy =
        route.nodes.where((n) => selectedNodeIds.contains(n.id)).toList();

    ref.read(clipboardProvider.notifier).state = ClipboardState(
      nodes: nodesToCopy,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${nodesToCopy.length} node(s)')),
    );
  }

  static void pasteNodes(WidgetRef ref, BuildContext context) {
    final clipboard = ref.read(clipboardProvider);
    if (clipboard == null || clipboard.nodes.isEmpty) return;

    final routeId = ref.read(selectedRouteIdProvider);
    if (routeId == null) return;

    final offset = const Offset(50, 50);
    final newNodeIds = <String>[];

    for (final node in clipboard.nodes) {
      final newId =
          DateTime.now().millisecondsSinceEpoch.toString() +
          math.Random().nextInt(10000).toString();
      final newNode = node.copyWith(
        id: newId,
        position: node.position + offset,
        connections: [], // Clear connections for pasted nodes
      );
      ref.read(routesProvider.notifier).addNodeToRoute(routeId, newNode);
      newNodeIds.add(newId);
    }

    // Select the pasted nodes
    ref.read(selectedNodesProvider.notifier).state = newNodeIds.toSet();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasted ${clipboard.nodes.length} node(s)')),
    );
  }

  static void deleteSelectedNodes(WidgetRef ref, BuildContext context) {
    final routeId = ref.read(selectedRouteIdProvider);
    final selectedNodeIds = ref.read(selectedNodesProvider);

    if (routeId == null || selectedNodeIds.isEmpty) return;

    ref
        .read(routesProvider.notifier)
        .deleteNodesFromRoute(routeId, selectedNodeIds);
    ref.read(selectedNodesProvider.notifier).state = {};
    ref.read(selectedNodeIdProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${selectedNodeIds.length} node(s)')),
    );
  }
}
