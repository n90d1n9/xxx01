import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../data/sample.dart';
import '../models/question.dart';
import '../models/survey.dart';

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
    );
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
