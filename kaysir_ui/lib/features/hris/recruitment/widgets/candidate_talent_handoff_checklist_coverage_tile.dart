import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';

class CandidateTalentHandoffChecklistCoverageTile extends StatelessWidget {
  final CandidateTalentHandoffChecklistCoverage coverage;
  final VoidCallback onGenerate;

  const CandidateTalentHandoffChecklistCoverageTile({
    super.key,
    required this.coverage,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        coverage.isComplete ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coverage.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      coverage.templateLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: coverage.isComplete ? 'Covered' : 'Missing',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: coverage.coverageRatio,
            color: color,
            label: '${(coverage.coverageRatio * 100).round()}% coverage',
          ),
          const SizedBox(height: 10),
          Text(
            coverage.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (coverage.missingCategories.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              coverage.missingCategories
                  .map((category) => category.label)
                  .join(', '),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Generate tasks'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
