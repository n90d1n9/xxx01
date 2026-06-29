// lib/screens/survey_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../states/survey_provider.dart';
import '../widgets/date_question.dart';
import '../widgets/multiline_question.dart';
import '../widgets/multiple_question.dart';
import '../widgets/number_question.dart';
import '../widgets/rating_question.dart';
import '../widgets/single_choice.dart';
import '../widgets/text_question.dart';

class SurveyViewerScreen extends ConsumerWidget {
  final String surveyId;

  const SurveyViewerScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyProvider);
    final survey = surveys.firstWhere((s) => s.id == surveyId);

    return Scaffold(
      appBar: AppBar(title: Text(survey.title)),
      body: Column(
        children: [
          // Survey header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.deepPurple.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  survey.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(survey.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8.0),
                Text(
                  '${survey.questions.length} Questions',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Questions
          Expanded(
            child:
                survey.questions.isEmpty
                    ? const Center(child: Text('No questions in this survey.'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: survey.questions.length,
                      itemBuilder: (context, index) {
                        final question = survey.questions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.deepPurple,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            question.text,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (question.required) ...[
                                            const SizedBox(height: 4.0),
                                            const Text(
                                              'Required',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 16.0),
                                          _buildQuestionWidget(
                                            question,
                                            survey.id,
                                            ref,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // Submit button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Validate required questions
                final unansweredQuestions =
                    survey.questions.where((q) {
                      if (!q.required) return false;

                      if (q.answer == null) return true;

                      if (q.type == QuestionType.singleChoice ||
                          q.type == QuestionType.multipleChoice) {
                        if (q.type == QuestionType.singleChoice &&
                            q.answer is String &&
                            q.answer.isNotEmpty) {
                          return false;
                        }
                        if (q.type == QuestionType.multipleChoice &&
                            q.answer is List &&
                            (q.answer as List).isNotEmpty) {
                          return false;
                        }
                        return true;
                      }

                      if (q.answer is String && q.answer.isEmpty) return true;

                      return false;
                    }).toList();

                if (unansweredQuestions.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please answer all required questions (${unansweredQuestions.length} remaining)',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Survey submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
    Question question,
    String surveyId,
    WidgetRef ref,
  ) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return SingleChoiceQuestion(
          question: question,
          onChanged: (selectedId) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, selectedId);
          },
        );
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          question: question,
          onChanged: (selectedIds) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, selectedIds);
          },
        );
      case QuestionType.singleLineText:
        return TextQuestion(
          question: question,
          onChanged: (value) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, value);
          },
        );
      case QuestionType.multiLineText:
        return MultilineTextQuestion(
          question: question,
          onChanged: (value) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, value);
          },
        );
      case QuestionType.number:
        return NumberQuestion(
          question: question,
          onChanged: (value) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, value);
          },
        );
      case QuestionType.date:
        return DateQuestion(
          question: question,
          onChanged: (value) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, value);
          },
        );
      case QuestionType.rating:
        return RatingQuestion(
          question: question,
          onChanged: (value) {
            ref
                .read(surveyProvider.notifier)
                .updateQuestionAnswer(surveyId, question.id, value);
          },
        );
    }
  }
}
