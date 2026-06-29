// lib/screens/survey_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../states/survey_provider.dart';
import 'survey_editor_screen.dart';
import 'survey_view_screen.dart';

class SurveyListScreen extends ConsumerWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyProvider);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Surveys'), centerTitle: true),
      body:
          surveys.isEmpty
              ? const Center(
                child: Text('No surveys available. Create one to get started!'),
              )
              : ListView.builder(
                itemCount: surveys.length,
                itemBuilder: (context, index) {
                  final survey = surveys[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        survey.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text(survey.description),
                          const SizedBox(height: 8.0),
                          Text(
                            'Questions: ${survey.questions.length}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Created: ${dateFormat.format(survey.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.0,
                            ),
                          ),
                          if (survey.updatedAt != null) ...[
                            const SizedBox(height: 4.0),
                            Text(
                              'Updated: ${dateFormat.format(survey.updatedAt!)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            tooltip: 'View Survey',
                            onPressed: () {
                              ref.read(currentSurveyProvider.notifier).state =
                                  survey;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SurveyViewerScreen(
                                        surveyId: survey.id,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit Survey',
                            onPressed: () {
                              ref.read(currentSurveyProvider.notifier).state =
                                  survey;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SurveyEditorScreen(
                                        surveyId: survey.id,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Survey',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Survey'),
                                      content: const Text(
                                        'Are you sure you want to delete this survey?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(surveyProvider.notifier)
                                                .deleteSurvey(survey.id);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final newSurvey =
              ref.read(surveyProvider.notifier).createEmptySurvey();
          ref.read(surveyProvider.notifier).addSurvey(newSurvey);
          ref.read(currentSurveyProvider.notifier).state = newSurvey;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyEditorScreen(surveyId: newSurvey.id),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Survey'),
      ),
    );
  }
}
