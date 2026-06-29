import 'package:flutter/material.dart';

import 'models/question.dart';
import 'models/question_options.dart';

class QuestionBuilder extends StatefulWidget {
  final Function(Question) onQuestionAdded;

  const QuestionBuilder({
    super.key,
    required this.onQuestionAdded,
  });

  @override
  State<QuestionBuilder> createState() => _QuestionBuilderState();
}

class _QuestionBuilderState extends State<QuestionBuilder> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  QuestionType _selectedType = QuestionType.multipleChoice;
  List<QuestionOptions> _options = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Question Type',
                ),
                items: QuestionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              if (_selectedType == QuestionType.multipleChoice) ...[
                const SizedBox(height: 16),
                const Text('Options:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _options.length) {
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            _options.add(QuestionOptions());
                          });
                        },
                        child: const Text('Add Option'),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            //initialValue: _options[index].toString(),
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                            ),
                            onChanged: (value) {
                              //_options[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _options.removeAt(index);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Add Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuestion() {
    if (_formKey.currentState?.validate() ?? false) {
      final question = Question(
        id: DateTime.now().toString(),
        text: _questionController.text,
        type: _selectedType,
        options: _selectedType == QuestionType.multipleChoice ? _options[0] : QuestionOptions(),
        isRequired: false,
        orderIndex: 0,
      );
      widget.onQuestionAdded(question);
      _questionController.clear();
      setState(() {
        _options = [];
      });
    }
  }
}
