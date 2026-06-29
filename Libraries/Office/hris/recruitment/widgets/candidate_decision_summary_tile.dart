import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import '../models/candidate_decision_review_summary.dart';

class CandidateDecisionSummaryTile extends StatelessWidget {
  final CandidateDecisionSummary summary;
  final CandidateDecisionReviewSummary reviewSummary;

  const CandidateDecisionSummaryTile({
    super.key,
    required this.summary,
    required this.reviewSummary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.fact_check_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decision action',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reviewSummary.nextAction,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DecisionStat(label: 'Packets', value: '${summary.totalPackets}'),
              _DecisionStat(label: 'Approve', value: '${summary.approveCount}'),
              _DecisionStat(
                label: 'Conditional',
                value: '${summary.conditionalCount}',
              ),
              _DecisionStat(label: 'Hold', value: '${summary.holdCount}'),
              _DecisionStat(
                label: 'Due soon',
                value: '${summary.dueSoonCount}',
              ),
              _DecisionStat(
                label: 'Reviews',
                value: '${reviewSummary.totalCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecisionStat extends StatelessWidget {
  final String label;
  final String value;

  const _DecisionStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
