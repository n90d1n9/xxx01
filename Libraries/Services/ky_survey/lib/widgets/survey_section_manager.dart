import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/survey.dart';
import '../models/survey_section.dart';

class SurveySectionManager extends StatelessWidget {
  final Survey survey;
  final ValueChanged<SurveySection> onSectionAdded;
  final ValueChanged<SurveySection> onSectionChanged;
  final ValueChanged<SurveySection> onSectionRemoved;

  const SurveySectionManager({
    super.key,
    required this.survey,
    required this.onSectionAdded,
    required this.onSectionChanged,
    required this.onSectionRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = survey.orderedSections;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.view_agenda_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sections',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: () => _showSectionDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sections.isEmpty)
              Text(
                'Use sections to group longer surveys into focused pages.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final section in sections)
                    _SectionChip(
                      section: section,
                      questionCount: survey
                          .questionsForSection(section.id)
                          .length,
                      onEdit: () => _showSectionDialog(context, section),
                      onDelete: () => onSectionRemoved(section),
                    ),
                ],
              ),
            if (survey.unsectionedQuestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${survey.unsectionedQuestions.length} unsectioned question${survey.unsectionedQuestions.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSectionDialog(BuildContext context, [SurveySection? section]) {
    final titleController = TextEditingController(text: section?.title ?? '');
    final descriptionController = TextEditingController(
      text: section?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(section == null ? 'Add Section' : 'Edit Section'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Section title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section title is required')),
                  );
                  return;
                }

                if (section == null) {
                  const uuid = Uuid();
                  onSectionAdded(
                    SurveySection(
                      id: uuid.v4(),
                      title: title,
                      description: descriptionController.text.trim(),
                      order: survey.sections.length,
                    ),
                  );
                } else {
                  onSectionChanged(
                    section.copyWith(
                      title: title,
                      description: descriptionController.text.trim(),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _SectionChip extends StatelessWidget {
  final SurveySection section;
  final int questionCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectionChip({
    required this.section,
    required this.questionCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: const Icon(Icons.segment_outlined, size: 18),
      label: Text('$questionCount • ${section.titleOrFallback}'),
      onPressed: onEdit,
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }
}
