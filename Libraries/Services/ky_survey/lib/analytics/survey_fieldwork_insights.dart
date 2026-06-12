import '../models/survey.dart';
import '../models/survey_assignment.dart';

class SurveyFieldworkInsights {
  final List<Survey> surveys;
  final List<SurveyAssignment> assignments;

  const SurveyFieldworkInsights({
    required this.surveys,
    required this.assignments,
  });

  int get totalAssignments => assignments.length;

  int get activeAssignments =>
      assignments.where((assignment) => assignment.status.isActive).length;

  int overdueAssignments({DateTime? now}) {
    return assignments
        .where((assignment) => assignment.isOverdue(now: now))
        .length;
  }

  int get completedAssignments =>
      assignments.where((assignment) => assignment.status.isDone).length;

  int get targetResponses => assignments.fold(
    0,
    (total, assignment) => total + assignment.targetResponses,
  );

  int get completedResponses => assignments.fold(
    0,
    (total, assignment) => total + assignment.completedResponses,
  );

  double get completionRate {
    if (targetResponses == 0) {
      return 0;
    }

    return (completedResponses / targetResponses).clamp(0, 1).toDouble();
  }

  List<SurveyAssignment> assignmentsForSurvey(String surveyId) {
    return assignments
        .where((assignment) => assignment.surveyId == surveyId)
        .toList();
  }

  List<SurveyAssignment> assignmentsForAssignee(String assigneeId) {
    return assignments
        .where((assignment) => assignment.assigneeId == assigneeId)
        .toList();
  }

  List<SurveyAssignment> nextAssignments({int limit = 5}) {
    final sorted = [...assignments]
      ..sort((left, right) {
        final statusCompare = _statusRank(
          left.status,
        ).compareTo(_statusRank(right.status));
        if (statusCompare != 0) {
          return statusCompare;
        }

        return left.dueAt.compareTo(right.dueAt);
      });

    return sorted.take(limit).toList();
  }

  SurveyFieldworkSummary summaryForSurvey(Survey survey, {DateTime? now}) {
    final surveyAssignments = assignmentsForSurvey(survey.id);
    final target = surveyAssignments.fold<int>(
      0,
      (total, assignment) => total + assignment.targetResponses,
    );
    final completed = surveyAssignments.fold<int>(
      0,
      (total, assignment) => total + assignment.completedResponses,
    );

    return SurveyFieldworkSummary(
      survey: survey,
      assignmentCount: surveyAssignments.length,
      activeAssignments: surveyAssignments
          .where((assignment) => assignment.status.isActive)
          .length,
      overdueAssignments: surveyAssignments
          .where((assignment) => assignment.isOverdue(now: now))
          .length,
      targetResponses: target,
      completedResponses: completed,
    );
  }

  Survey? surveyForAssignment(SurveyAssignment assignment) {
    for (final survey in surveys) {
      if (survey.id == assignment.surveyId) {
        return survey;
      }
    }

    return null;
  }

  int _statusRank(SurveyAssignmentStatus status) {
    switch (status) {
      case SurveyAssignmentStatus.blocked:
        return 0;
      case SurveyAssignmentStatus.inProgress:
        return 1;
      case SurveyAssignmentStatus.needsReview:
        return 2;
      case SurveyAssignmentStatus.queued:
        return 3;
      case SurveyAssignmentStatus.completed:
        return 4;
    }
  }
}

class SurveyFieldworkSummary {
  final Survey survey;
  final int assignmentCount;
  final int activeAssignments;
  final int overdueAssignments;
  final int targetResponses;
  final int completedResponses;

  const SurveyFieldworkSummary({
    required this.survey,
    required this.assignmentCount,
    required this.activeAssignments,
    required this.overdueAssignments,
    required this.targetResponses,
    required this.completedResponses,
  });

  double get completionRate {
    if (targetResponses == 0) {
      return 0;
    }

    return (completedResponses / targetResponses).clamp(0, 1).toDouble();
  }
}
