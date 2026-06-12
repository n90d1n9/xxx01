import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_assignments.dart';
import '../models/survey_assignment.dart';

final surveyAssignmentProvider =
    StateNotifierProvider<SurveyAssignmentNotifier, List<SurveyAssignment>>((
      ref,
    ) {
      return SurveyAssignmentNotifier();
    });

class SurveyAssignmentNotifier extends StateNotifier<List<SurveyAssignment>> {
  SurveyAssignmentNotifier() : super(sampleAssignments);

  SurveyAssignment assignSurvey({
    required String surveyId,
    required String assigneeId,
    required String assigneeName,
    required String territory,
    required int targetResponses,
    required DateTime dueAt,
    String? note,
  }) {
    const uuid = Uuid();
    final assignment = SurveyAssignment(
      id: uuid.v4(),
      surveyId: surveyId,
      assigneeId: assigneeId,
      assigneeName: assigneeName,
      territory: territory,
      targetResponses: targetResponses,
      dueAt: dueAt,
      assignedAt: DateTime.now(),
      note: note,
    );

    state = [...state, assignment];
    return assignment;
  }

  void updateAssignmentStatus(
    String assignmentId,
    SurveyAssignmentStatus status,
  ) {
    state = state.map((assignment) {
      if (assignment.id != assignmentId) {
        return assignment;
      }

      return assignment.copyWith(status: status);
    }).toList();
  }

  void recordAssignmentResponse(String assignmentId) {
    state = state.map((assignment) {
      if (assignment.id != assignmentId) {
        return assignment;
      }

      final completedResponses = assignment.completedResponses + 1;
      return assignment.copyWith(
        completedResponses: completedResponses,
        status: completedResponses >= assignment.targetResponses
            ? SurveyAssignmentStatus.needsReview
            : SurveyAssignmentStatus.inProgress,
      );
    }).toList();
  }
}
