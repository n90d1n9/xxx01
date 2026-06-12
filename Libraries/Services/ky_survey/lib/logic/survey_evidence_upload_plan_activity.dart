import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_activity_tracker.dart';

/// Summarizes uploadable plan tasks by ready and in-flight activity state.
class SurveyEvidenceUploadPlanActivity {
  final SurveyEvidenceUploadPlan plan;
  final Set<String> activeUploadKeys;

  const SurveyEvidenceUploadPlanActivity({
    required this.plan,
    this.activeUploadKeys = const {},
  });

  List<SurveyEvidenceUploadTask> get uploadableTasks => plan.uploadableTasks;

  List<SurveyEvidenceUploadTask> get activeUploadableTasks {
    return uploadableTasks.where(isActive).toList(growable: false);
  }

  List<SurveyEvidenceUploadTask> get readyUploadableTasks {
    return uploadableTasks
        .where((task) => !isActive(task))
        .toList(growable: false);
  }

  int get activeUploadableCount => activeUploadableTasks.length;

  int get readyUploadableCount => readyUploadableTasks.length;

  bool get hasUploadableTasks => uploadableTasks.isNotEmpty;

  bool get hasReadyUploadableTasks => readyUploadableTasks.isNotEmpty;

  bool get allUploadableTasksActive {
    return hasUploadableTasks && !hasReadyUploadableTasks;
  }

  bool isActive(SurveyEvidenceUploadTask task) {
    return activeUploadKeys.contains(
      SurveyEvidenceUploadActivityTracker.keyFor(task),
    );
  }
}
