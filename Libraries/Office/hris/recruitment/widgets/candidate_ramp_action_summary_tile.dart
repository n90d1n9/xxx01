import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_ramp_action_models.dart';

class CandidateRampActionSummaryTile extends StatelessWidget {
  final CandidateRampActionSummary summary;

  const CandidateRampActionSummaryTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryPill(label: 'Submitted', value: summary.submittedCount),
              _SummaryPill(label: 'Active', value: summary.activeCount),
              _SummaryPill(label: 'Done', value: summary.completedCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return HrisStatusPill(label: '$label $value', color: HrisColors.primary);
  }
}
