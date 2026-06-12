import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/question_type_details.dart';
import '../../models/question_visibility_rule.dart';

class QuestionLogicValueField extends StatelessWidget {
  final Question sourceQuestion;
  final QuestionVisibilityRule rule;
  final QuestionVisibilityOperator operator;
  final ValueChanged<dynamic> onChanged;

  const QuestionLogicValueField({
    super.key,
    required this.sourceQuestion,
    required this.rule,
    required this.operator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (sourceQuestion.type.usesOptions) {
      final options = sourceQuestion.options ?? const [];
      final selectedValue =
          options.any((option) => option.id == rule.value?.toString())
          ? rule.value?.toString()
          : null;

      return DropdownButtonFormField<String>(
        initialValue: selectedValue,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Value',
          border: OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option.id,
            child: Text(option.text, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
      );
    }

    return TextFormField(
      key: ValueKey('${rule.sourceQuestionId}-${operator.name}'),
      initialValue: rule.value?.toString() ?? '',
      keyboardType: operator.usesNumericValue
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Value',
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
