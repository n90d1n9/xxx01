// lib/widgets/question_widgets/single_choice_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';

class SingleChoiceQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;

  const SingleChoiceQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selectedId = question.answer as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options.map((option) {
            return RadioListTile<String>(
              title: Text(option.text),
              value: option.id,
              groupValue: selectedId,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
    );
  }
}
