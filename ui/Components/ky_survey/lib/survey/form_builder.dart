import 'package:flutter/material.dart';

import '../question/models/question.dart';
import '../question/question_builder.dart';

class SurveyCreateScreen extends StatefulWidget {
  const SurveyCreateScreen({super.key});

  @override
  State<SurveyCreateScreen> createState() => _SurveyCreateScreenState();
}

class _SurveyCreateScreenState extends State<SurveyCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<Question> _questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Survey')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Survey Title',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            QuestionBuilder(
              onQuestionAdded: (question) {
                setState(() {
                  _questions.add(question);
                });
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  child: ListTile(
                    title: Text(question.text),
                    subtitle: Text(question.type.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _questions.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSurvey,
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _saveSurvey() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save survey logic
    }
  }
}
