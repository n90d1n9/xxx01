// History State for Undo/Redo
import 'node.dart';

class HistoryEntry {
  final List<WNode> routes;
  final String? selectedRouteId;
  final DateTime timestamp;

  HistoryEntry({
    required this.routes,
    this.selectedRouteId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
