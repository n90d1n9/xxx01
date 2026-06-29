import '../model/workflow_version.dart';

class VersionControlState {
  final List<WorkflowVersion> versions;
  final WorkflowVersion? currentVersion;
  final bool hasUnsavedChanges;
  final Map<String, dynamic> diff;

  VersionControlState({
    this.versions = const [],
    this.currentVersion,
    this.hasUnsavedChanges = false,
    this.diff = const {},
  });

  VersionControlState copyWith({
    List<WorkflowVersion>? versions,
    WorkflowVersion? currentVersion,
    bool? hasUnsavedChanges,
    Map<String, dynamic>? diff,
  }) {
    return VersionControlState(
      versions: versions ?? this.versions,
      currentVersion: currentVersion ?? this.currentVersion,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      diff: diff ?? this.diff,
    );
  }
}
