// Version History
import 'package:flutter_riverpod/legacy.dart';

import '../models/node.dart';
import '../models/route_snapshot.dart';

class SnapshotNotifier extends StateNotifier<List<RouteSnapshot>> {
  SnapshotNotifier() : super([]);

  void createSnapshot(WNode route, String? comment) {
    final snapshot = RouteSnapshot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Snapshot ${state.length + 1}',
      timestamp: DateTime.now(),
      route: route,
      comment: comment,
    );
    state = [...state, snapshot];
  }

  void deleteSnapshot(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final snapshotsProvider =
    StateNotifierProvider<SnapshotNotifier, List<RouteSnapshot>>((ref) {
      return SnapshotNotifier();
    });
