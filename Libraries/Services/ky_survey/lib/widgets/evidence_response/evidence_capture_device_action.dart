import 'package:flutter/material.dart';

import '../../logic/survey_evidence_capture_adapter.dart';
import '../../models/survey_evidence_requirement.dart';
import 'evidence_capture_form_helpers.dart';

class EvidenceCaptureDeviceAction extends StatelessWidget {
  final SurveyEvidenceRequirement requirement;
  final SurveyEvidenceCaptureAdapter? adapter;
  final bool isCapturing;
  final VoidCallback onCapture;

  const EvidenceCaptureDeviceAction({
    super.key,
    required this.requirement,
    required this.adapter,
    required this.isCapturing,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final adapter = this.adapter;
    if (adapter == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              evidenceKindIcon(requirement.kind),
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                adapter.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              icon: isCapturing
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sensors_outlined),
              label: Text(isCapturing ? 'Capturing' : 'Capture'),
              onPressed: isCapturing ? null : onCapture,
            ),
          ],
        ),
      ),
    );
  }
}
