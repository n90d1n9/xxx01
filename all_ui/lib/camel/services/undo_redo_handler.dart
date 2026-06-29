import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/node_route_provider.dart';
import '../states/route_history_provider.dart';

class UndoRedoHandler {
  static void handleUndo(WidgetRef ref) {
    final entry = ref.read(routeHistoryProvider.notifier).undo();
    if (entry != null) {
      ref.read(routesProvider.notifier).restoreFromHistory(entry);
    }
  }

  static void handleRedo(WidgetRef ref) {
    final entry = ref.read(routeHistoryProvider.notifier).redo();
    if (entry != null) {
      ref.read(routesProvider.notifier).restoreFromHistory(entry);
    }
  }
}
