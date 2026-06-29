import 'package:flutter_riverpod/legacy.dart';

import '../model/canvas_state.dart';
import '../model/selected_component_notifier.dart';

final canvasStateProvider =
    StateNotifierProvider<CanvasStateNotifier, CanvasState>((ref) {
      return CanvasStateNotifier();
    });
