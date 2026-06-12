import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import 'evidence_requirements/evidence_requirement_dialog.dart';
import 'evidence_requirements/evidence_requirement_tile.dart';

class SurveyEvidenceRequirementsPanel extends StatelessWidget {
  final Survey survey;
  final ValueChanged<SurveyEvidenceRequirement> onRequirementAdded;
  final ValueChanged<SurveyEvidenceRequirement> onRequirementChanged;
  final ValueChanged<SurveyEvidenceRequirement> onRequirementRemoved;

  const SurveyEvidenceRequirementsPanel({
    super.key,
    required this.survey,
    required this.onRequirementAdded,
    required this.onRequirementChanged,
    required this.onRequirementRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requirements = survey.evidenceRequirements;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.perm_media_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Evidence Requirements',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: () => _openRequirementDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.rule_folder_outlined,
                  label: '${requirements.length} rules',
                ),
                _MetricChip(
                  icon: Icons.place_outlined,
                  label:
                      '${_countByKind(SurveyEvidenceKind.location)} GPS rules',
                ),
                _MetricChip(
                  icon: Icons.mic_none_outlined,
                  label:
                      '${_countByKind(SurveyEvidenceKind.audio)} audio rules',
                ),
                _MetricChip(
                  icon: Icons.image_outlined,
                  label:
                      '${_countByKind(SurveyEvidenceKind.image)} image rules',
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (requirements.isEmpty)
              _EmptyRequirementsState(colorScheme: colorScheme)
            else
              Column(
                children: [
                  for (final requirement in requirements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: EvidenceRequirementTile(
                        requirement: requirement,
                        questionLabel: _questionLabel(requirement.questionId),
                        onEdit: () =>
                            _openRequirementDialog(context, requirement),
                        onDelete: () => onRequirementRemoved(requirement),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  int _countByKind(SurveyEvidenceKind kind) {
    return survey.evidenceRequirements
        .where((requirement) => requirement.kind == kind)
        .length;
  }

  String? _questionLabel(String? questionId) {
    if (questionId == null) {
      return null;
    }

    for (final question in survey.questions) {
      if (question.id == questionId) {
        final text = question.text.trim();
        return text.isEmpty ? 'Untitled question' : text;
      }
    }

    return 'Missing question';
  }

  void _openRequirementDialog(
    BuildContext context, [
    SurveyEvidenceRequirement? requirement,
  ]) {
    showDialog(
      context: context,
      builder: (context) {
        return EvidenceRequirementDialog(
          requirement: requirement,
          questions: survey.questions,
          onSaved: (updatedRequirement) {
            if (requirement == null) {
              onRequirementAdded(updatedRequirement);
            } else {
              onRequirementChanged(updatedRequirement);
            }
          },
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _EmptyRequirementsState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyRequirementsState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.add_photo_alternate_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add GPS, image, audio, or file requirements for field evidence.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
