// lib/widgets/question_widgets/number_question.dart
import 'package:flutter/material.dart';

import '../models/question.dart';
import 'survey_number_input_formatter.dart';

/// Renders a survey number response field with signed decimal input support.
class NumberQuestion extends StatefulWidget {
  final Question question;
  final Function(String) onChanged;

  const NumberQuestion({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  State<NumberQuestion> createState() => _NumberQuestionState();
}

/// Maintains number field controller state across question answer updates.
class _NumberQuestionState extends State<NumberQuestion> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _answerText);
  }

  @override
  void didUpdateWidget(covariant NumberQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.question.hint ?? 'Enter a number',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: const [SurveyNumberInputFormatter()],
      onChanged: widget.onChanged,
    );
  }

  String get _answerText {
    final answer = widget.question.answer;
    if (answer == null) {
      return '';
    }

    return answer.toString();
  }

  void _syncController() {
    if (_controller.text == _answerText) {
      return;
    }

    _controller.value = _controller.value.copyWith(
      text: _answerText,
      selection: TextSelection.collapsed(offset: _answerText.length),
      composing: TextRange.empty,
    );
  }
}
