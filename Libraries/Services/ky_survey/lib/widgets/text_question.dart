// lib/widgets/question_widgets/text_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';
import 'survey_text_answer_field.dart';

/// Renders a single-line text response question.
class TextQuestion extends StatelessWidget {
  final Question question;
  final ValueChanged<String> onChanged;

  const TextQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyTextAnswerField(
      answer: question.answer,
      hintText: question.hint,
      maxLength: question.maxLength,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
    );
  }
}
