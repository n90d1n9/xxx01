class MenuState {
  final double zoomLevel;
  final bool canUndo;
  final bool canRedo;

  MenuState({
    this.zoomLevel = 1.0,
    this.canUndo = false,
    this.canRedo = false,
  });

  MenuState copyWith({
    double? zoomLevel,
    bool? canUndo,
    bool? canRedo,
  }) {
    return MenuState(
      zoomLevel: zoomLevel ?? this.zoomLevel,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
