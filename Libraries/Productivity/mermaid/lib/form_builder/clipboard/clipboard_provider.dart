import 'package:flutter_riverpod/legacy.dart';

import '../../form_designer/model/field_config.dart';

class ClipboardManager extends StateNotifier<List<FieldConfig>> {
  ClipboardManager() : super([]);

  void copy(List<FieldConfig> fields) {
    state = fields;
  }

  void clear() {
    state = [];
  }

  bool get hasData => state.isNotEmpty;
}

final clipboardProvider =
    StateNotifierProvider<ClipboardManager, List<FieldConfig>>((ref) {
      return ClipboardManager();
    });
