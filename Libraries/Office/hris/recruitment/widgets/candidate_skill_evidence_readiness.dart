import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_skill_evidence_models.dart';

class CandidateSkillEvidenceReadiness extends StatelessWidget {
  final CandidateSkillEvidenceDraft draft;

  const CandidateSkillEvidenceReadiness({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                errors.isEmpty ? Icons.verified_outlined : Icons.rule_outlined,
                color:
                    errors.isEmpty
                        ? const Color(0xFF15803D)
                        : HrisColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errors.isEmpty
                      ? 'Evidence is ready to save.'
                      : 'Complete the scorecard evidence.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  error,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
