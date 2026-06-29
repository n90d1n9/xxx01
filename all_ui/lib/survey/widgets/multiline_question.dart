// lib/widgets/question_widgets/multiline_text_question.dart
import 'package:flutter/material.dart';
import '../models/question.dart';

class MultilineTextQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;

  const MultilineTextQuestion({
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
      maxLines: 5,
      onChanged: onChanged,
    );
  }
}
