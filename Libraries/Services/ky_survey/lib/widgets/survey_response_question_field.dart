import 'package:flutter/material.dart';

import '../models/question.dart';
import 'date_question.dart';
import 'multiline_question.dart';
import 'multiple_question.dart';
import 'number_question.dart';
import 'rating_question.dart';
import 'single_choice.dart';
import 'text_question.dart';

class SurveyResponseQuestionField extends StatelessWidget {
  final Question question;
  final ValueChanged<dynamic> onAnswerChanged;

  const SurveyResponseQuestionField({
    super.key,
    required this.question,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return SingleChoiceQuestion(
          question: question,
          onChanged: onAnswerChanged,
        );
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          question: question,
          onChanged: onAnswerChanged,
        );
      case QuestionType.singleLineText:
        return TextQuestion(question: question, onChanged: onAnswerChanged);
      case QuestionType.multiLineText:
        return MultilineTextQuestion(
          question: question,
          onChanged: onAnswerChanged,
        );
      case QuestionType.number:
        return NumberQuestion(question: question, onChanged: onAnswerChanged);
      case QuestionType.date:
        return DateQuestion(question: question, onChanged: onAnswerChanged);
      case QuestionType.rating:
        return RatingQuestion(question: question, onChanged: onAnswerChanged);
    }
  }
}
