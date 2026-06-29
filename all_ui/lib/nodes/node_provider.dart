import 'dart:ui' show Offset;

import 'package:flutter_riverpod/legacy.dart';

final nodeStateProvider = StateNotifierProvider<NodeStateNotifier, NodeState>((
  ref,
) {
  return NodeStateNotifier();
});

class NodeState {
  final bool isDragging;
  final Offset position;
  final List<String> selectedFeatures;

  NodeState({
    this.isDragging = false,
    this.position = Offset.zero,
    this.selectedFeatures = const [],
  });

  NodeState copyWith({
    bool? isDragging,
    Offset? position,
    List<String>? selectedFeatures,
  }) {
    return NodeState(
      isDragging: isDragging ?? this.isDragging,
      position: position ?? this.position,
      selectedFeatures: selectedFeatures ?? this.selectedFeatures,
    );
  }
}

class NodeStateNotifier extends StateNotifier<NodeState> {
  NodeStateNotifier() : super(NodeState());

  void setDragging(bool dragging) {
    state = state.copyWith(isDragging: dragging);
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }

  void toggleFeature(String feature) {
    final features = List<String>.from(state.selectedFeatures);
    if (features.contains(feature)) {
      features.remove(feature);
    } else {
      features.add(feature);
    }
    state = state.copyWith(selectedFeatures: features);
  }
}
