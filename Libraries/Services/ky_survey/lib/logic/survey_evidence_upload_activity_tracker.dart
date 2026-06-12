import '../analytics/survey_evidence_upload_planner.dart';

/// Tracks in-flight evidence upload tasks by response and evidence identity.
class SurveyEvidenceUploadActivityTracker {
  final Set<String> _activeKeys;

  SurveyEvidenceUploadActivityTracker({Set<String>? activeKeys})
    : _activeKeys = {...?activeKeys};

  Set<String> get activeKeys => Set.unmodifiable(_activeKeys);

  bool isActive(SurveyEvidenceUploadTask task) {
    return _activeKeys.contains(keyFor(task));
  }

  List<SurveyEvidenceUploadTask> inactiveTasks(
    Iterable<SurveyEvidenceUploadTask> tasks,
  ) {
    return tasks.where((task) => !isActive(task)).toList(growable: false);
  }

  Set<String> keysFor(Iterable<SurveyEvidenceUploadTask> tasks) {
    return tasks.map(keyFor).toSet();
  }

  void track(SurveyEvidenceUploadTask task) {
    _activeKeys.add(keyFor(task));
  }

  void trackKeys(Iterable<String> keys) {
    _activeKeys.addAll(keys);
  }

  void release(SurveyEvidenceUploadTask task) {
    _activeKeys.remove(keyFor(task));
  }

  void releaseKey(String key) {
    _activeKeys.remove(key);
  }

  void releaseKeys(Iterable<String> keys) {
    _activeKeys.removeAll(keys);
  }

  static String keyFor(SurveyEvidenceUploadTask task) {
    return '${task.responseId}:${task.evidenceId}';
  }
}
