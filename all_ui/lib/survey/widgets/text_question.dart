// lib/widgets/question_widgets/text_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';

class TextQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;

  const TextQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: question.answer as String? ?? ''),
      decoration: InputDecoration(
        hintText: question.hint,
        border: const OutlineInputBorder(),
      ),
      maxLength: question.maxLength,
      onChanged: onChanged,
    );
  }
}
