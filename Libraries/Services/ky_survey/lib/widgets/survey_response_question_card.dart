import 'package:flutter/material.dart';

import '../models/question.dart';
import '../validation/survey_response_validator.dart';
import 'survey_response_question_field.dart';
import 'survey_response_question_frame.dart';

/// Adapts a survey question into a framed, validation-aware response field.
class SurveyResponseQuestionCard extends StatelessWidget {
  final int questionNumber;
  final Question question;
  final ValueChanged<dynamic> onAnswerChanged;
  final List<SurveyResponseValidationIssue> issues;
  final String? helperText;
  final bool enabled;
  final bool highlighted;

  const SurveyResponseQuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
    required this.onAnswerChanged,
    this.issues = const [],
    this.helperText,
    this.enabled = true,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SurveyResponseQuestionFrame(
      questionNumber: questionNumber,
      title: question.text,
      isRequired: question.required,
      helperText: helperText,
      enabled: enabled,
      highlighted: highlighted,
      issueMessages: issues.map((issue) => issue.message).toList(),
      child: SurveyResponseQuestionField(
        question: question,
        onAnswerChanged: onAnswerChanged,
      ),
    );
  }
}
