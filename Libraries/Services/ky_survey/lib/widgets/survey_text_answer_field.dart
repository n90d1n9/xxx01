import 'package:flutter/material.dart';

/// Renders a survey text answer field while keeping host-provided answers synced.
class SurveyTextAnswerField extends StatefulWidget {
  final dynamic answer;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int? maxLength;
  final int minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const SurveyTextAnswerField({
    super.key,
    required this.answer,
    required this.onChanged,
    this.hintText,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  State<SurveyTextAnswerField> createState() => _SurveyTextAnswerFieldState();
}

/// Maintains a text controller without leaking response-state concerns upward.
class _SurveyTextAnswerFieldState extends State<SurveyTextAnswerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _answerText);
  }

  @override
  void didUpdateWidget(covariant SurveyTextAnswerField oldWidget) {
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
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
    );
  }

  String get _answerText {
    final answer = widget.answer;
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
