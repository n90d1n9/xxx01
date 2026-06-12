// lib/widgets/question_widgets/multiline_text_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';
import 'survey_text_answer_field.dart';

/// Renders a multiline text response question for longer participant input.
class MultilineTextQuestion extends StatelessWidget {
  final Question question;
  final ValueChanged<String> onChanged;

  const MultilineTextQuestion({
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
      minLines: 5,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
    );
  }
}
