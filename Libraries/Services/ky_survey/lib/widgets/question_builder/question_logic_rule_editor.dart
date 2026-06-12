import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/question_visibility_rule.dart';
import 'question_logic_value_field.dart';

class QuestionLogicRuleEditor extends StatelessWidget {
  final int index;
  final List<Question> availableQuestions;
  final QuestionVisibilityRule rule;
  final ValueChanged<QuestionVisibilityRule> onRuleChanged;
  final VoidCallback onRuleRemoved;

  const QuestionLogicRuleEditor({
    super.key,
    required this.index,
    required this.availableQuestions,
    required this.rule,
    required this.onRuleChanged,
    required this.onRuleRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceQuestion = _sourceQuestion;
    final operators = _operatorsFor(sourceQuestion);
    final operator = operators.contains(rule.operator)
        ? rule.operator
        : QuestionVisibilityOperator.answered;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: sourceQuestion.id,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Source question ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    items: availableQuestions.map((question) {
                      return DropdownMenuItem(
                        value: question.id,
                        child: Text(
                          _questionLabel(question),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (questionId) {
                      if (questionId == null) {
                        return;
                      }

                      onRuleChanged(
                        QuestionVisibilityRule(sourceQuestionId: questionId),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Remove condition',
                  icon: const Icon(Icons.close),
                  onPressed: onRuleRemoved,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<QuestionVisibilityOperator>(
              initialValue: operator,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Operator',
                border: OutlineInputBorder(),
              ),
              items: operators.map((operator) {
                return DropdownMenuItem(
                  value: operator,
                  child: Text(operator.label),
                );
              }).toList(),
              onChanged: (operator) {
                if (operator == null) {
                  return;
                }

                onRuleChanged(
                  QuestionVisibilityRule(
                    sourceQuestionId: rule.sourceQuestionId,
                    operator: operator,
                    value: operator.needsValue ? rule.value : null,
                  ),
                );
              },
            ),
            if (operator.needsValue) ...[
              const SizedBox(height: 12),
              QuestionLogicValueField(
                sourceQuestion: sourceQuestion,
                rule: rule,
                operator: operator,
                onChanged: (value) {
                  onRuleChanged(
                    QuestionVisibilityRule(
                      sourceQuestionId: rule.sourceQuestionId,
                      operator: operator,
                      value: value,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Question get _sourceQuestion {
    return availableQuestions.firstWhere(
      (question) => question.id == rule.sourceQuestionId,
      orElse: () => availableQuestions.first,
    );
  }

  List<QuestionVisibilityOperator> _operatorsFor(Question sourceQuestion) {
    final baseOperators = [
      QuestionVisibilityOperator.answered,
      QuestionVisibilityOperator.unanswered,
      QuestionVisibilityOperator.equals,
      QuestionVisibilityOperator.notEquals,
    ];

    if (sourceQuestion.type == QuestionType.number ||
        sourceQuestion.type == QuestionType.rating) {
      return [
        ...baseOperators,
        QuestionVisibilityOperator.greaterThan,
        QuestionVisibilityOperator.greaterThanOrEqual,
        QuestionVisibilityOperator.lessThan,
        QuestionVisibilityOperator.lessThanOrEqual,
      ];
    }

    if (sourceQuestion.type == QuestionType.date) {
      return baseOperators;
    }

    return [
      ...baseOperators,
      QuestionVisibilityOperator.contains,
      QuestionVisibilityOperator.notContains,
    ];
  }

  String _questionLabel(Question question) {
    final label = question.text.trim();
    return label.isEmpty ? 'Untitled question' : label;
  }
}
