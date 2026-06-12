// lib/widgets/question_editor.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/option.dart';
import '../models/question.dart';
import '../models/question_type_details.dart';
import '../models/question_visibility_rule.dart';
import '../models/survey_section.dart';
import '../validation/question_validator.dart';
import 'question_builder/choice_options_editor.dart';
import 'question_builder/question_core_section.dart';
import 'question_builder/question_editor_actions.dart';
import 'question_builder/question_logic_section.dart';
import 'question_builder/question_section_picker.dart';
import 'question_builder/rating_question_settings.dart';
import 'question_builder/text_question_settings.dart';

class QuestionEditor extends StatefulWidget {
  final Question question;
  final List<Question> availableQuestions;
  final List<SurveySection> sections;
  final ValueChanged<Question> onQuestionChanged;
  final VoidCallback onCancel;

  const QuestionEditor({
    super.key,
    required this.question,
    this.availableQuestions = const [],
    this.sections = const [],
    required this.onQuestionChanged,
    required this.onCancel,
  });

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late final TextEditingController _questionTextController;
  late final TextEditingController _hintController;
  late final TextEditingController _maxLengthController;
  late final TextEditingController _minRatingController;
  late final TextEditingController _maxRatingController;

  late QuestionType _selectedType;
  late bool _isRequired;
  late List<Option> _options;
  late String? _sectionId;
  late List<QuestionVisibilityRule> _visibilityRules;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController();
    _hintController = TextEditingController();
    _maxLengthController = TextEditingController();
    _minRatingController = TextEditingController();
    _maxRatingController = TextEditingController();
    _syncFromQuestion(widget.question);
  }

  @override
  void didUpdateWidget(covariant QuestionEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _syncFromQuestion(widget.question);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCoreSection(
            questionTextController: _questionTextController,
            selectedType: _selectedType,
            isRequired: _isRequired,
            onTypeChanged: _changeQuestionType,
            onRequiredChanged: (value) {
              setState(() => _isRequired = value);
            },
          ),
          if (widget.sections.isNotEmpty) ...[
            const SizedBox(height: 20),
            QuestionSectionPicker(
              sections: widget.sections,
              selectedSectionId: _sectionId,
              onChanged: (sectionId) {
                setState(() => _sectionId = sectionId);
              },
            ),
          ],
          if (_selectedType.usesTextSettings) ...[
            const SizedBox(height: 20),
            TextQuestionSettings(
              hintController: _hintController,
              maxLengthController: _maxLengthController,
            ),
          ],
          if (_selectedType.usesRatingSettings) ...[
            const SizedBox(height: 20),
            RatingQuestionSettings(
              minRatingController: _minRatingController,
              maxRatingController: _maxRatingController,
            ),
          ],
          if (_selectedType.usesOptions) ...[
            const SizedBox(height: 20),
            ChoiceOptionsEditor(
              options: _options,
              onOptionChanged: _updateOption,
              onOptionRemoved: _removeOption,
              onOptionAdded: _addOption,
            ),
          ],
          const SizedBox(height: 20),
          QuestionLogicSection(
            availableQuestions: widget.availableQuestions,
            rules: _visibilityRules,
            onRulesChanged: (rules) {
              setState(() => _visibilityRules = rules);
            },
          ),
          const SizedBox(height: 24),
          QuestionEditorActions(
            onCancel: widget.onCancel,
            onSave: _saveQuestion,
          ),
        ],
      ),
    );
  }

  void _syncFromQuestion(Question question) {
    _questionTextController.text = question.text;
    _hintController.text = question.hint ?? '';
    _maxLengthController.text = question.maxLength?.toString() ?? '';
    _minRatingController.text = question.minRating?.toString() ?? '1';
    _maxRatingController.text = question.maxRating?.toString() ?? '5';
    _selectedType = question.type;
    _isRequired = question.required;
    _options = [...?question.options];
    _sectionId = question.sectionId;
    _visibilityRules = [...question.visibilityRules];
    _ensureChoiceOptions();
  }

  void _changeQuestionType(QuestionType type) {
    setState(() {
      _selectedType = type;
      _ensureChoiceOptions();
    });
  }

  void _ensureChoiceOptions() {
    if (!_selectedType.usesOptions || _options.isNotEmpty) {
      return;
    }

    const uuid = Uuid();
    _options = [
      Option(id: uuid.v4(), text: 'Option 1'),
      Option(id: uuid.v4(), text: 'Option 2'),
    ];
  }

  void _updateOption(Option updatedOption) {
    setState(() {
      _options = _options
          .map(
            (option) => option.id == updatedOption.id ? updatedOption : option,
          )
          .toList();
    });
  }

  void _removeOption(Option option) {
    setState(() {
      _options = _options
          .where((candidate) => candidate.id != option.id)
          .toList();
    });
  }

  void _addOption() {
    setState(() {
      const uuid = Uuid();
      _options = [
        ..._options,
        Option(id: uuid.v4(), text: 'Option ${_options.length + 1}'),
      ];
    });
  }

  void _saveQuestion() {
    final validation = QuestionValidator.validateDraft(
      text: _questionTextController.text,
      type: _selectedType,
      options: _options,
      maxLengthText: _maxLengthController.text,
      minRatingText: _minRatingController.text,
      maxRatingText: _maxRatingController.text,
    );

    if (!validation.isValid) {
      _showError(validation.firstError!);
      return;
    }

    final updatedQuestion = Question(
      id: widget.question.id,
      text: _questionTextController.text.trim(),
      type: _selectedType,
      required: _isRequired,
      options: _selectedType.usesOptions ? _sanitizedOptions() : null,
      answer: _selectedType == widget.question.type
          ? widget.question.answer
          : null,
      hint:
          _selectedType.usesTextSettings &&
              _hintController.text.trim().isNotEmpty
          ? _hintController.text.trim()
          : null,
      maxLength:
          _selectedType.usesTextSettings &&
              _maxLengthController.text.trim().isNotEmpty
          ? int.tryParse(_maxLengthController.text)
          : null,
      minRating: _selectedType.usesRatingSettings
          ? int.tryParse(_minRatingController.text) ?? 1
          : null,
      maxRating: _selectedType.usesRatingSettings
          ? int.tryParse(_maxRatingController.text) ?? 5
          : null,
      sectionId: _sectionId,
      visibilityRules: _visibilityRules,
    );

    widget.onQuestionChanged(updatedQuestion);
  }

  List<Option> _sanitizedOptions() {
    return _options
        .where((option) => option.text.trim().isNotEmpty)
        .map((option) => option.copyWith(text: option.text.trim()))
        .toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
