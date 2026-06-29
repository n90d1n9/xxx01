// Route Comparison
class RouteComparison {
  final List<String> addedNodes;
  final List<String> removedNodes;
  final List<String> modifiedNodes;
  final List<String> addedConnections;
  final List<String> removedConnections;

  RouteComparison({
    required this.addedNodes,
    required this.removedNodes,
    required this.modifiedNodes,
    required this.addedConnections,
    required this.removedConnections,
  });
}
