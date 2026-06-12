import '../models/survey.dart';
import '../models/survey_section.dart';

class SurveyStructureInsights {
  final List<Survey> surveys;

  const SurveyStructureInsights(this.surveys);

  int get totalSections =>
      surveys.fold(0, (total, survey) => total + survey.sections.length);

  int get sectionedSurveyCount =>
      surveys.where((survey) => survey.sections.isNotEmpty).length;

  int get unsectionedQuestionCount => surveys.fold(
    0,
    (total, survey) => total + survey.unsectionedQuestions.length,
  );

  List<SurveySectionSummary> summariesForSurvey(Survey survey) {
    final summaries = survey.orderedSections.map((section) {
      final questions = survey.questionsForSection(section.id);
      return SurveySectionSummary(
        section: section,
        questionCount: questions.length,
        requiredQuestionCount: questions
            .where((question) => question.required)
            .length,
      );
    }).toList();

    if (survey.unsectionedQuestions.isNotEmpty) {
      summaries.add(
        SurveySectionSummary(
          section: const SurveySection(
            id: 'unsectioned',
            title: 'Unsectioned',
            order: 999999,
          ),
          questionCount: survey.unsectionedQuestions.length,
          requiredQuestionCount: survey.unsectionedQuestions
              .where((question) => question.required)
              .length,
        ),
      );
    }

    return summaries;
  }
}

class SurveySectionSummary {
  final SurveySection section;
  final int questionCount;
  final int requiredQuestionCount;

  const SurveySectionSummary({
    required this.section,
    required this.questionCount,
    required this.requiredQuestionCount,
  });
}
