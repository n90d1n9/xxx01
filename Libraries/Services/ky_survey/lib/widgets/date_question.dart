// lib/widgets/question_widgets/date_question.dart
import 'package:flutter/material.dart';

import '../logic/survey_date_answer_formatter.dart';
import '../models/question.dart';

typedef SurveyDatePickerLauncher =
    Future<DateTime?> Function({
      required BuildContext context,
      required DateTime initialDate,
      required DateTime firstDate,
      required DateTime lastDate,
    });

/// Opens the platform Material date picker for survey date responses.
Future<DateTime?> showSurveyMaterialDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

/// Renders a date response field backed by a reusable date answer formatter.
class DateQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? fallbackDate;
  final SurveyDatePickerLauncher? datePicker;
  final SurveyDateAnswerFormatter formatter;

  const DateQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.fallbackDate,
    this.datePicker,
    this.formatter = const SurveyDateAnswerFormatter(),
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = formatter.formatAnswer(question.answer);
    final hasDate = displayDate.isNotEmpty;
    final firstSelectableDate = firstDate ?? DateTime(1900);
    final lastSelectableDate = lastDate ?? DateTime(2100);
    final placeholder = question.hint ?? 'Select a date';
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      value: hasDate ? displayDate : 'No date selected',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final picker = datePicker ?? showSurveyMaterialDatePicker;
          final picked = await picker(
            context: context,
            initialDate: formatter.resolveInitialDate(
              answer: question.answer,
              fallbackDate: fallbackDate ?? DateTime.now(),
              firstDate: firstSelectableDate,
              lastDate: lastSelectableDate,
            ),
            firstDate: firstSelectableDate,
            lastDate: lastSelectableDate,
          );

          if (picked != null) {
            onChanged(formatter.formatDate(picked));
          }
        },
        child: InputDecorator(
          isEmpty: !hasDate,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.event_rounded),
          ),
          child: Text(
            hasDate ? displayDate : placeholder,
            style: textTheme.bodyLarge?.copyWith(
              color: hasDate
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
