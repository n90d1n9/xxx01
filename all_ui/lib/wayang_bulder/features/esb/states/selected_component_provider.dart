import 'package:flutter_riverpod/legacy.dart';

import '../model/selected_component_notifier.dart';

final selectedComponentProvider =
    StateNotifierProvider<SelectedComponentNotifier, Set<String>>((ref) {
      return SelectedComponentNotifier();
    });
