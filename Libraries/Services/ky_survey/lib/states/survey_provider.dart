import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../data/sample.dart';
import '../models/question.dart';
import '../models/survey.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_section.dart';
import '../models/survey_status.dart';
import '../logic/survey_publication_planner.dart';

final surveyProvider = StateNotifierProvider<SurveyNotifier, List<Survey>>((
  ref,
) {
  return SurveyNotifier();
});

final currentSurveyProvider = StateProvider<Survey?>((ref) => null);

class SurveyNotifier extends StateNotifier<List<Survey>> {
  SurveyNotifier() : super(sampleSurveys);

  void addSurvey(Survey survey) {
    state = [...state, survey];
  }

  void updateSurvey(Survey updatedSurvey) {
    state = state
        .map((survey) => survey.id == updatedSurvey.id ? updatedSurvey : survey)
        .toList();
  }

  void deleteSurvey(String id) {
    state = state.where((survey) => survey.id != id).toList();
  }

  Survey createEmptySurvey() {
    const uuid = Uuid();
    return Survey(
      id: uuid.v4(),
      title: 'New Survey',
      description: 'Survey description',
      questions: [],
      createdAt: DateTime.now(),
      targetResponses: 100,
    );
  }

  void updateSurveyStatus(String surveyId, SurveyStatus status) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = SurveyPublicationPlanner.applyStatusChange(
      survey: survey,
      targetStatus: status,
      changedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void updateSurveyAssignments(String surveyId, List<String> assigneeNames) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = survey.copyWith(
      assigneeNames: assigneeNames,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void recordSurveyResponse(String surveyId) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = survey.copyWith(
      responseCount: survey.responseCount + 1,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void addQuestionToSurvey(String surveyId, Question question) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedQuestions = [...survey.questions, question];
    final updatedSurvey = survey.copyWith(
      questions: updatedQuestions,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void addSectionToSurvey(String surveyId, SurveySection section) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = survey.copyWith(
      sections: [...survey.sections, section],
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void addEvidenceRequirementToSurvey(
    String surveyId,
    SurveyEvidenceRequirement requirement,
  ) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = survey.copyWith(
      evidenceRequirements: [...survey.evidenceRequirements, requirement],
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void updateEvidenceRequirementInSurvey(
    String surveyId,
    SurveyEvidenceRequirement updatedRequirement,
  ) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedRequirements = survey.evidenceRequirements
        .map(
          (requirement) => requirement.id == updatedRequirement.id
              ? updatedRequirement
              : requirement,
        )
        .toList();
    final updatedSurvey = survey.copyWith(
      evidenceRequirements: updatedRequirements,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void deleteEvidenceRequirementFromSurvey(
    String surveyId,
    String requirementId,
  ) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSurvey = survey.copyWith(
      evidenceRequirements: survey.evidenceRequirements
          .where((requirement) => requirement.id != requirementId)
          .toList(),
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void updateSectionInSurvey(String surveyId, SurveySection updatedSection) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSections = survey.sections
        .map(
          (section) =>
              section.id == updatedSection.id ? updatedSection : section,
        )
        .toList();
    final updatedSurvey = survey.copyWith(
      sections: updatedSections,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void deleteSectionFromSurvey(String surveyId, String sectionId) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedSections = survey.sections
        .where((section) => section.id != sectionId)
        .toList();
    final updatedQuestions = survey.questions.map((question) {
      if (question.sectionId != sectionId) {
        return question;
      }

      return question.copyWith(clearSectionId: true);
    }).toList();
    final updatedSurvey = survey.copyWith(
      sections: updatedSections,
      questions: updatedQuestions,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void updateQuestionInSurvey(String surveyId, Question updatedQuestion) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedQuestions = survey.questions
        .map((q) => q.id == updatedQuestion.id ? updatedQuestion : q)
        .toList();
    final updatedSurvey = survey.copyWith(
      questions: updatedQuestions,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void deleteQuestionFromSurvey(String surveyId, String questionId) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedQuestions = survey.questions
        .where((q) => q.id != questionId)
        .toList();
    final updatedSurvey = survey.copyWith(
      questions: updatedQuestions,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }

  void updateQuestionAnswer(
    String surveyId,
    String questionId,
    dynamic answer,
  ) {
    final survey = state.firstWhere((s) => s.id == surveyId);
    final updatedQuestions = survey.questions.map((q) {
      if (q.id == questionId) {
        return q.copyWith(answer: answer);
      }
      return q;
    }).toList();

    final updatedSurvey = survey.copyWith(
      questions: updatedQuestions,
      updatedAt: DateTime.now(),
    );
    updateSurvey(updatedSurvey);
  }
}
