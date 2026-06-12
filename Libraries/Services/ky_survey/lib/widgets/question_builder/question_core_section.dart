import 'package:flutter/material.dart';

import '../../models/question.dart';
import '../../models/question_type_details.dart';

class QuestionCoreSection extends StatelessWidget {
  final TextEditingController questionTextController;
  final QuestionType selectedType;
  final bool isRequired;
  final ValueChanged<QuestionType> onTypeChanged;
  final ValueChanged<bool> onRequiredChanged;

  const QuestionCoreSection({
    super.key,
    required this.questionTextController,
    required this.selectedType,
    required this.isRequired,
    required this.onTypeChanged,
    required this.onRequiredChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: questionTextController,
          decoration: const InputDecoration(
            labelText: 'Question Text',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<QuestionType>(
          initialValue: selectedType,
          decoration: const InputDecoration(
            labelText: 'Question Type',
            border: OutlineInputBorder(),
          ),
          items: QuestionType.values.map((type) {
            return DropdownMenuItem<QuestionType>(
              value: type,
              child: _QuestionTypeOption(type: type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: SwitchListTile(
            title: Text(
              'Required',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text('Participant must answer this question.'),
            value: isRequired,
            onChanged: onRequiredChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }
}

class _QuestionTypeOption extends StatelessWidget {
  final QuestionType type;

  const _QuestionTypeOption({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(type.label),
        Text(
          type.builderDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
