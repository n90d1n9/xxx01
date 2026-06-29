// lib/widgets/question_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/option.dart';
import '../models/question.dart';

class QuestionEditor extends StatefulWidget {
  final Question question;
  final Function(Question) onQuestionChanged;
  final VoidCallback onCancel;

  const QuestionEditor({
    Key? key,
    required this.question,
    required this.onQuestionChanged,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController _questionTextController;
  late TextEditingController _hintController;
  late TextEditingController _maxLengthController;
  late TextEditingController _minRatingController;
  late TextEditingController _maxRatingController;
  late QuestionType _selectedType;
  late bool _isRequired;
  late List<Option> _options;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(text: widget.question.text);
    _hintController = TextEditingController(text: widget.question.hint ?? '');
    _maxLengthController = TextEditingController(
      text: widget.question.maxLength?.toString() ?? '',
    );
    _minRatingController = TextEditingController(
      text: widget.question.minRating?.toString() ?? '1',
    );
    _maxRatingController = TextEditingController(
      text: widget.question.maxRating?.toString() ?? '5',
    );
    _selectedType = widget.question.type;
    _isRequired = widget.question.required;
    _options = widget.question.options?.map((o) => o).toList() ?? [];

    if (_options.isEmpty &&
        (_selectedType == QuestionType.singleChoice ||
            _selectedType == QuestionType.multipleChoice)) {
      const uuid = Uuid();
      _options = [
        Option(id: uuid.v4(), text: 'Option 1'),
        Option(id: uuid.v4(), text: 'Option 2'),
      ];
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _hintController.dispose();
    _maxLengthController.dispose();
    _minRatingController.dispose();
    _maxRatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _questionTextController,
            decoration: const InputDecoration(
              labelText: 'Question Text',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16.0),
          DropdownButtonFormField<QuestionType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Question Type',
              border: OutlineInputBorder(),
            ),
            items:
                QuestionType.values.map((type) {
                  return DropdownMenuItem<QuestionType>(
                    value: type,
                    child: Text(_getQuestionTypeLabel(type)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                // Reset options if switching to or from choice type
                if (value == QuestionType.singleChoice ||
                    value == QuestionType.multipleChoice) {
                  if (_options.isEmpty) {
                    const uuid = Uuid();
                    _options = [
                      Option(id: uuid.v4(), text: 'Option 1'),
                      Option(id: uuid.v4(), text: 'Option 2'),
                    ];
                  }
                }
              });
            },
          ),
          const SizedBox(height: 16.0),
          SwitchListTile(
            title: const Text('Required'),
            value: _isRequired,
            onChanged: (value) {
              setState(() {
                _isRequired = value;
              });
            },
          ),
          const SizedBox(height: 8.0),

          // Conditional fields based on question type
          if (_selectedType == QuestionType.singleLineText ||
              _selectedType == QuestionType.multiLineText) ...[
            const SizedBox(height: 8.0),
            TextField(
              controller: _hintController,
              decoration: const InputDecoration(
                labelText: 'Hint Text (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _maxLengthController,
              decoration: const InputDecoration(
                labelText: 'Maximum Length (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],

          if (_selectedType == QuestionType.rating) ...[
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minRatingController,
                    decoration: const InputDecoration(
                      labelText: 'Min Rating',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _maxRatingController,
                    decoration: const InputDecoration(
                      labelText: 'Max Rating',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],

          if (_selectedType == QuestionType.singleChoice ||
              _selectedType == QuestionType.multipleChoice) ...[
            const SizedBox(height: 16.0),
            const Text(
              'Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            ..._buildOptionsList(),
            const SizedBox(height: 8.0),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
              onPressed: _addOption,
            ),
          ],

          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptionsList() {
    return _options.map((option) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                //initialValue: option.text,
                decoration: const InputDecoration(
                  labelText: 'Option',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final index = _options.indexOf(option);
                  setState(() {
                    _options[index] = option.copyWith(text: value);
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _options.remove(option);
                });
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addOption() {
    setState(() {
      const uuid = Uuid();
      _options.add(
        Option(id: uuid.v4(), text: 'Option ${_options.length + 1}'),
      );
    });
  }

  void _saveQuestion() {
    // Validate the question has text
    if (_questionTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For choice questions, ensure there are at least 2 options
    if ((_selectedType == QuestionType.singleChoice ||
            _selectedType == QuestionType.multipleChoice) &&
        _options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least 2 options for choice questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For rating questions, validate min and max
    if (_selectedType == QuestionType.rating) {
      final minRating = int.tryParse(_minRatingController.text) ?? 1;
      final maxRating = int.tryParse(_maxRatingController.text) ?? 5;

      if (minRating >= maxRating) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Max rating must be greater than min rating'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Create updated question
    final updatedQuestion = Question(
      id: widget.question.id,
      text: _questionTextController.text.trim(),
      type: _selectedType,
      required: _isRequired,
      options:
          (_selectedType == QuestionType.singleChoice ||
                  _selectedType == QuestionType.multipleChoice)
              ? _options
              : null,
      hint: _hintController.text.isNotEmpty ? _hintController.text : null,
      maxLength:
          _maxLengthController.text.isNotEmpty
              ? int.tryParse(_maxLengthController.text)
              : null,
      minRating:
          _selectedType == QuestionType.rating
              ? int.tryParse(_minRatingController.text) ?? 1
              : null,
      maxRating:
          _selectedType == QuestionType.rating
              ? int.tryParse(_maxRatingController.text) ?? 5
              : null,
    );

    widget.onQuestionChanged(updatedQuestion);
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
      default:
        return 'Unknown';
    }
  }
}
