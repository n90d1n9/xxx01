// BoQ Provider
import 'package:flutter_riverpod/legacy.dart';

import '../models/boq_item.dart';

final boqProvider = StateNotifierProvider<BoQNotifier, List<BoQItem>>(
  (ref) => BoQNotifier(),
);

class BoQNotifier extends StateNotifier<List<BoQItem>> {
  BoQNotifier() : super([]);

  void addItem(BoQItem item) {
    state = [...state, item];
  }

  void updateItem(BoQItem item) {
    state = [
      for (final i in state)
        if (i.id == item.id) item else i,
    ];
  }

  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  List<BoQItem> getByProject(String projectId) {
    return state.where((i) => i.projectId == projectId).toList();
  }
}
