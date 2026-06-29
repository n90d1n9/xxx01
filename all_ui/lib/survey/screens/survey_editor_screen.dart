// lib/screens/survey_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/option.dart';
import '../models/question.dart';
import '../states/survey_provider.dart';
import '../widgets/question_editor.dart';

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
                    _showAddQuestionDialog(context, ref);
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
                  return Card(
                    key: ValueKey(question.id),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  question.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditQuestionDialog(
                                        context,
                                        ref,
                                        question,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(surveyProvider.notifier)
                                          .deleteQuestionFromSurvey(
                                            surveyId,
                                            question.id,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Type: ${_getQuestionTypeLabel(question.type)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            question.required ? 'Required' : 'Optional',
                            style: TextStyle(
                              color:
                                  question.required
                                      ? Colors.red[700]
                                      : Colors.grey[600],
                              fontWeight:
                                  question.required
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (question.options != null &&
                              question.options!.isNotEmpty) ...[
                            const SizedBox(height: 8.0),
                            const Divider(),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Options:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            ...question.options!.map((option) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(option.text),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
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

  void _showAddQuestionDialog(BuildContext context, WidgetRef ref) {
    const uuid = Uuid();
    final newQuestion = Question(
      id: uuid.v4(),
      text: '',
      type: QuestionType.singleChoice,
      required: false,
      options: [
        Option(id: uuid.v4(), text: 'Option 1'),
        Option(id: uuid.v4(), text: 'Option 2'),
      ],
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Question'),
            content: SizedBox(
              width: double.maxFinite,
              child: QuestionEditor(
                question: newQuestion,
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
    Question question,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Question'),
            content: SizedBox(
              width: double.maxFinite,
              child: QuestionEditor(
                question: question,
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

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.singleLineText:
        return 'Short Answer';
      case QuestionType.multiLineText:
        return 'Long Answer';
      case QuestionType.number:
        return 'Number';
      case QuestionType.date:
        return 'Date';
      case QuestionType.rating:
        return 'Rating';
    }
  }
}
