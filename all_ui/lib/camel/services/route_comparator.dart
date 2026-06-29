import '../models/node.dart';
import '../models/route_comparison.dart';

class RouteComparator {
  static RouteComparison compare(WNode route1, WNode route2) {
    final nodes1Ids = route1.nodes.map((n) => n.id).toSet();
    final nodes2Ids = route2.nodes.map((n) => n.id).toSet();

    final added = nodes2Ids.difference(nodes1Ids).toList();
    final removed = nodes1Ids.difference(nodes2Ids).toList();
    final modified = <String>[];

    for (final node1 in route1.nodes) {
      final node2 = route2.nodes.where((n) => n.id == node1.id).firstOrNull;
      if (node2 != null &&
          (node1.config.toString() != node2.config.toString() ||
              node1.position != node2.position)) {
        modified.add(node1.id);
      }
    }

    return RouteComparison(
      addedNodes: added,
      removedNodes: removed,
      modifiedNodes: modified,
      addedConnections: [],
      removedConnections: [],
    );
  }
}
