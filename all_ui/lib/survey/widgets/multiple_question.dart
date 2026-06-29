// lib/widgets/question_widgets/multiple_choice_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';

class MultipleChoiceQuestion extends StatelessWidget {
  final Question question;
  final Function(List<String>) onChanged;

  const MultipleChoiceQuestion({
    Key? key,
    required this.question,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final selectedIds = question.answer as List<String>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options.map((option) {
            return CheckboxListTile(
              title: Text(option.text),
              value: selectedIds.contains(option.id),
              onChanged: (value) {
                if (value == true) {
                  onChanged([...selectedIds, option.id]);
                } else {
                  onChanged(
                    selectedIds.where((id) => id != option.id).toList(),
                  );
                }
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
    );
  }
}
