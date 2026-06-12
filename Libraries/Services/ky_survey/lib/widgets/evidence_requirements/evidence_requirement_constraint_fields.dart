import 'package:flutter/material.dart';

import '../../models/survey_evidence.dart';

class EvidenceRequirementConstraintFields extends StatelessWidget {
  final SurveyEvidenceKind kind;
  final TextEditingController maxSizeController;
  final TextEditingController minDurationController;
  final TextEditingController maxAccuracyController;

  const EvidenceRequirementConstraintFields({
    super.key,
    required this.kind,
    required this.maxSizeController,
    required this.minDurationController,
    required this.maxAccuracyController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (kind != SurveyEvidenceKind.location) ...[
          const SizedBox(height: 12),
          TextField(
            controller: maxSizeController,
            decoration: const InputDecoration(
              labelText: 'Max file size (MB)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        if (kind == SurveyEvidenceKind.audio) ...[
          const SizedBox(height: 12),
          TextField(
            controller: minDurationController,
            decoration: const InputDecoration(
              labelText: 'Minimum duration (seconds)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        if (kind == SurveyEvidenceKind.location) ...[
          const SizedBox(height: 12),
          TextField(
            controller: maxAccuracyController,
            decoration: const InputDecoration(
              labelText: 'Max accuracy (meters)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ],
    );
  }
}
