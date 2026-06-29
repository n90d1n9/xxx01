import 'node.dart';

class RouteSnapshot {
  final String id;
  final String name;
  final DateTime timestamp;
  final WNode route;
  final String? comment;

  RouteSnapshot({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.route,
    this.comment,
  });
}
