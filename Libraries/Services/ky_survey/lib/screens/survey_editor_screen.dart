// lib/screens/survey_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/option.dart';
import '../models/question.dart';
import '../models/survey_section.dart';
import '../states/survey_provider.dart';
import '../widgets/question_editor.dart';
import '../widgets/survey_builder_preview_panel.dart';
import '../widgets/survey_evidence_requirements_panel.dart';
import '../widgets/survey_logic_insights_panel.dart';
import '../widgets/survey_question_card.dart';
import '../widgets/survey_section_manager.dart';
import '../widgets/survey_version_history_panel.dart';

class SurveyEditorScreen extends ConsumerWidget {
  final String surveyId;

  const SurveyEditorScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyProvider);
    final survey = surveys.firstWhere((s) => s.id == surveyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Survey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Survey saved successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey title and description editor
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: survey.title),
                      decoration: const InputDecoration(
                        labelText: 'Survey Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        ref
                            .read(surveyProvider.notifier)
                            .updateSurvey(
                              survey.copyWith(
                                title: value,
                                updatedAt: DateTime.now(),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: TextEditingController(
                        text: survey.description,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Survey Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        ref
                            .read(surveyProvider.notifier)
                            .updateSurvey(
                              survey.copyWith(
                                description: value,
                                updatedAt: DateTime.now(),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            SurveySectionManager(
              survey: survey,
              onSectionAdded: (section) {
                ref
                    .read(surveyProvider.notifier)
                    .addSectionToSurvey(surveyId, section);
              },
              onSectionChanged: (section) {
                ref
                    .read(surveyProvider.notifier)
                    .updateSectionInSurvey(surveyId, section);
              },
              onSectionRemoved: (section) {
                ref
                    .read(surveyProvider.notifier)
                    .deleteSectionFromSurvey(surveyId, section.id);
              },
            ),
            const SizedBox(height: 24.0),
            SurveyEvidenceRequirementsPanel(
              survey: survey,
              onRequirementAdded: (requirement) {
                ref
                    .read(surveyProvider.notifier)
                    .addEvidenceRequirementToSurvey(surveyId, requirement);
              },
              onRequirementChanged: (requirement) {
                ref
                    .read(surveyProvider.notifier)
                    .updateEvidenceRequirementInSurvey(surveyId, requirement);
              },
              onRequirementRemoved: (requirement) {
                ref
                    .read(surveyProvider.notifier)
                    .deleteEvidenceRequirementFromSurvey(
                      surveyId,
                      requirement.id,
                    );
              },
            ),
            const SizedBox(height: 24.0),
            SurveyVersionHistoryPanel(survey: survey),
            const SizedBox(height: 24.0),
            SurveyLogicInsightsPanel(survey: survey),
            const SizedBox(height: 24.0),
            SurveyBuilderPreviewPanel(survey: survey),
            const SizedBox(height: 24.0),

            // Questions list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                  onPressed: () {
                    _showAddQuestionDialog(
                      context,
                      ref,
                      survey.questions,
                      survey.orderedSections,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Questions list
            if (survey.questions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No questions added yet. Tap "Add Question" to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: survey.questions.length,
                itemBuilder: (context, index) {
                  final question = survey.questions[index];
                  return SurveyQuestionCard(
                    key: ValueKey(question.id),
                    survey: survey,
                    question: question,
                    onEdit: () {
                      _showEditQuestionDialog(
                        context,
                        ref,
                        survey.questions,
                        survey.orderedSections,
                        question,
                      );
                    },
                    onDelete: () {
                      ref
                          .read(surveyProvider.notifier)
                          .deleteQuestionFromSurvey(surveyId, question.id);
                    },
                  );
                },
                onReorderItem: (oldIndex, newIndex) {
                  final updatedQuestions = List.of(survey.questions);
                  final question = updatedQuestions.removeAt(oldIndex);
                  updatedQuestions.insert(newIndex, question);
                  ref
                      .read(surveyProvider.notifier)
                      .updateSurvey(
                        survey.copyWith(
                          questions: updatedQuestions,
                          updatedAt: DateTime.now(),
                        ),
                      );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(
    BuildContext context,
    WidgetRef ref,
    List<Question> availableQuestions,
    List<SurveySection> sections,
  ) {
    const uuid = Uuid();
    final newQuestion = Question(
      id: uuid.v4(),
      text: '',
      type: QuestionType.singleChoice,
      required: false,
      sectionId: sections.isEmpty ? null : sections.first.id,
      options: [
        Option(id: uuid.v4(), text: 'Option 1'),
        Option(id: uuid.v4(), text: 'Option 2'),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Question'),
        content: SizedBox(
          width: double.maxFinite,
          child: QuestionEditor(
            question: newQuestion,
            availableQuestions: availableQuestions,
            sections: sections,
            onQuestionChanged: (updatedQuestion) {
              ref
                  .read(surveyProvider.notifier)
                  .addQuestionToSurvey(surveyId, updatedQuestion);
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _showEditQuestionDialog(
    BuildContext context,
    WidgetRef ref,
    List<Question> questions,
    List<SurveySection> sections,
    Question question,
  ) {
    final questionIndex = questions.indexWhere(
      (candidate) => candidate.id == question.id,
    );
    final availableQuestions = questionIndex <= 0
        ? const <Question>[]
        : questions.take(questionIndex).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Question'),
        content: SizedBox(
          width: double.maxFinite,
          child: QuestionEditor(
            question: question,
            availableQuestions: availableQuestions,
            sections: sections,
            onQuestionChanged: (updatedQuestion) {
              ref
                  .read(surveyProvider.notifier)
                  .updateQuestionInSurvey(surveyId, updatedQuestion);
              Navigator.of(context).pop();
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
