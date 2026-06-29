// lib/widgets/question_widgets/number_question.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';

class NumberQuestion extends StatelessWidget {
  final Question question;
  final Function(String) onChanged;

  const NumberQuestion({
    Key? key,
    required this.question,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: question.answer as String? ?? ''),
      decoration: InputDecoration(
        hintText: question.hint ?? 'Enter a number',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
      ],
      onChanged: onChanged,
    );
  }
}
