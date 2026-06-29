// lib/widgets/question_widgets/date_question.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/question.dart';

class DateQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;

  const DateQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    String displayDate = '';

    if (question.answer != null && question.answer is String) {
      try {
        final date = DateTime.parse(question.answer as String);
        displayDate = dateFormat.format(date);
      } catch (e) {
        displayDate = '';
      }
    }

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate:
              displayDate.isNotEmpty
                  ? DateTime.parse(displayDate)
                  : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(dateFormat.format(picked));
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          displayDate.isNotEmpty ? displayDate : 'Select a date',
          style: TextStyle(
            color: displayDate.isNotEmpty ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
