// lib/widgets/question_widgets/single_choice_question.dart
import 'package:flutter/material.dart';

import '../logic/survey_choice_answer_selection.dart';
import '../models/question.dart';

/// Renders a single-choice survey answer field with normalized selection state.
class SingleChoiceQuestion extends StatelessWidget {
  final Question question;
  final ValueChanged<String> onChanged;

  const SingleChoiceQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selection = SurveyChoiceAnswerSelection.single(
      optionIds: options.map((option) => option.id),
      answer: question.answer,
    );

    return RadioGroup<String>(
      groupValue: selection.selectedId,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          return RadioListTile<String>(
            title: Text(option.text),
            value: option.id,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}
