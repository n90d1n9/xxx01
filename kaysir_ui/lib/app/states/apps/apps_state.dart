class AppsState {
  final int currentFeaturesId;
  final String currentPath;

  AppsState({this.currentFeaturesId = 0, this.currentPath = '/'});

  AppsState copyWith({int? currentFeaturesId, String? currentPath}) {
    return AppsState(
      currentFeaturesId: currentFeaturesId ?? currentFeaturesId!,
      currentPath: currentPath ?? currentPath!,
    );
  }
}
