import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/question_visibility_rule.dart';
import 'question_logic_rule_editor.dart';

class QuestionLogicSection extends StatelessWidget {
  final List<Question> availableQuestions;
  final List<QuestionVisibilityRule> rules;
  final ValueChanged<List<QuestionVisibilityRule>> onRulesChanged;

  const QuestionLogicSection({
    super.key,
    required this.availableQuestions,
    required this.rules,
    required this.onRulesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = rules.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Display Logic',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show only when conditions match'),
              value: isEnabled,
              onChanged: availableQuestions.isEmpty && !isEnabled
                  ? null
                  : _setEnabled,
            ),
            if (availableQuestions.isEmpty)
              Text(
                'Add this after another question to enable conditions.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else if (isEnabled) ...[
              const SizedBox(height: 12),
              ...rules.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuestionLogicRuleEditor(
                    index: entry.key,
                    availableQuestions: availableQuestions,
                    rule: entry.value,
                    onRuleChanged: (rule) => _replaceRule(entry.key, rule),
                    onRuleRemoved: () => _removeRule(entry.key),
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add condition'),
                  onPressed: _addRule,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _setEnabled(bool enabled) {
    onRulesChanged(enabled ? [_defaultRule()] : const []);
  }

  void _addRule() {
    onRulesChanged([...rules, _defaultRule()]);
  }

  void _replaceRule(int index, QuestionVisibilityRule rule) {
    final updatedRules = [...rules];
    updatedRules[index] = rule;
    onRulesChanged(updatedRules);
  }

  void _removeRule(int index) {
    final updatedRules = [...rules]..removeAt(index);
    onRulesChanged(updatedRules);
  }

  QuestionVisibilityRule _defaultRule() {
    return QuestionVisibilityRule(
      sourceQuestionId: availableQuestions.first.id,
    );
  }
}
