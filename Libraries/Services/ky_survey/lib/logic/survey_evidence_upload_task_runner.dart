import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_activity_tracker.dart';
import 'survey_evidence_upload_service.dart';

typedef SurveyEvidenceUploadActivityChanged = void Function();

/// Coordinates upload service execution with in-flight activity tracking.
class SurveyEvidenceUploadTaskRunner {
  final SurveyEvidenceUploadService service;
  final SurveyEvidenceUploadActivityTracker activityTracker;
  final SurveyEvidenceUploadObserver? observer;
  final SurveyEvidenceUploadActivityChanged? onActivityChanged;

  const SurveyEvidenceUploadTaskRunner({
    required this.service,
    required this.activityTracker,
    this.observer,
    this.onActivityChanged,
  });

  Future<SurveyEvidenceUploadTaskRunResult> uploadTask(
    SurveyEvidenceUploadTask task,
  ) async {
    final uploadKey = SurveyEvidenceUploadActivityTracker.keyFor(task);
    if (activityTracker.isActive(task)) {
      return SurveyEvidenceUploadTaskRunResult.alreadyActive(task: task);
    }

    activityTracker.track(task);
    onActivityChanged?.call();
    try {
      final execution = await service.uploadTask(task, observer: observer);
      return SurveyEvidenceUploadTaskRunResult.completed(
        task: task,
        execution: execution,
      );
    } finally {
      activityTracker.releaseKey(uploadKey);
      onActivityChanged?.call();
    }
  }

  Future<SurveyEvidenceUploadPlanRunResult> uploadPlan(
    SurveyEvidenceUploadPlan plan,
  ) async {
    final uploadableTasks = activityTracker.inactiveTasks(plan.uploadableTasks);
    if (uploadableTasks.isEmpty) {
      return const SurveyEvidenceUploadPlanRunResult.noUploadableTasks();
    }

    final uploadKeys = activityTracker.keysFor(uploadableTasks);
    activityTracker.trackKeys(uploadKeys);
    onActivityChanged?.call();
    try {
      final execution = await service.uploadPlan(
        SurveyEvidenceUploadPlan(tasks: uploadableTasks),
        observer: observer,
      );
      return SurveyEvidenceUploadPlanRunResult.completed(
        tasks: uploadableTasks,
        execution: execution,
      );
    } finally {
      activityTracker.releaseKeys(uploadKeys);
      onActivityChanged?.call();
    }
  }
}

enum SurveyEvidenceUploadTaskRunStatus { alreadyActive, completed }

/// Describes the result of one guarded evidence upload task execution.
class SurveyEvidenceUploadTaskRunResult {
  final SurveyEvidenceUploadTaskRunStatus status;
  final SurveyEvidenceUploadTask task;
  final SurveyEvidenceUploadExecution? execution;

  const SurveyEvidenceUploadTaskRunResult.alreadyActive({required this.task})
    : status = SurveyEvidenceUploadTaskRunStatus.alreadyActive,
      execution = null;

  const SurveyEvidenceUploadTaskRunResult.completed({
    required this.task,
    required SurveyEvidenceUploadExecution this.execution,
  }) : status = SurveyEvidenceUploadTaskRunStatus.completed;

  bool get alreadyActive =>
      status == SurveyEvidenceUploadTaskRunStatus.alreadyActive;

  bool get completed => status == SurveyEvidenceUploadTaskRunStatus.completed;
}

enum SurveyEvidenceUploadPlanRunStatus { noUploadableTasks, completed }

/// Describes the result of a guarded evidence upload batch execution.
class SurveyEvidenceUploadPlanRunResult {
  final SurveyEvidenceUploadPlanRunStatus status;
  final List<SurveyEvidenceUploadTask> tasks;
  final SurveyEvidenceUploadBatchExecution? execution;

  const SurveyEvidenceUploadPlanRunResult.noUploadableTasks()
    : status = SurveyEvidenceUploadPlanRunStatus.noUploadableTasks,
      tasks = const [],
      execution = null;

  const SurveyEvidenceUploadPlanRunResult.completed({
    required this.tasks,
    required SurveyEvidenceUploadBatchExecution this.execution,
  }) : status = SurveyEvidenceUploadPlanRunStatus.completed;

  bool get hasUploadableTasks =>
      status == SurveyEvidenceUploadPlanRunStatus.completed;

  bool get noUploadableTasks =>
      status == SurveyEvidenceUploadPlanRunStatus.noUploadableTasks;
}
