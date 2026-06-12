// lib/widgets/question_widgets/multiple_choice_question.dart
import 'package:flutter/material.dart';

import '../logic/survey_choice_answer_selection.dart';
import '../models/question.dart';

/// Renders a multiple-choice survey answer field with normalized selections.
class MultipleChoiceQuestion extends StatelessWidget {
  final Question question;
  final ValueChanged<List<String>> onChanged;

  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selection = SurveyChoiceAnswerSelection.multiple(
      optionIds: options.map((option) => option.id),
      answer: question.answer,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option.text),
          value: selection.isSelected(option.id),
          onChanged: (value) {
            onChanged(selection.toggle(option.id, selected: value == true));
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
