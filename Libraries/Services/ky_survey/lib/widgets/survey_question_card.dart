import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/question_type_details.dart';
import '../models/survey.dart';
import '../models/survey_section.dart';

class SurveyQuestionCard extends StatelessWidget {
  final Survey survey;
  final Question question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SurveyQuestionCard({
    super.key,
    required this.survey,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final section = survey.sectionForQuestion(question);

    return Card(
      key: ValueKey(question.id),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Type: ${question.type.label}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (section != null) ...[
              const SizedBox(height: 4.0),
              Text(
                'Section: ${section.titleOrFallback}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4.0),
            Text(
              question.required ? 'Required' : 'Optional',
              style: TextStyle(
                color: question.required ? Colors.red[700] : Colors.grey[600],
                fontWeight: question.required
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (question.visibilityRules.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.account_tree_outlined, size: 18),
                    label: Text(
                      '${question.visibilityRules.length} display condition${question.visibilityRules.length == 1 ? '' : 's'}',
                    ),
                  ),
                ],
              ),
            ],
            if (question.options != null && question.options!.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              const Divider(),
              const SizedBox(height: 8.0),
              const Text(
                'Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ...question.options!.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.grey),
                      const SizedBox(width: 8.0),
                      Text(option.text),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
