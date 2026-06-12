import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import 'talent_meta_label.dart';

/// Recommendation tile for rebalancing council commitment ownership.
class IncomingTalentRiskCouncilCommitmentOwnerRebalanceTile
    extends StatelessWidget {
  final IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation
  recommendation;

  const IncomingTalentRiskCouncilCommitmentOwnerRebalanceTile({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(recommendation.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_priorityIcon(recommendation.priority), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.sourceOwnerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      recommendation.targetOwnerName == null
                          ? 'Needs relief capacity'
                          : 'Relief: ${recommendation.targetOwnerName}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: recommendation.priority.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: recommendation.pressureRatio,
            color: color,
            label: '${(recommendation.pressureRatio * 100).round()}% pressure',
          ),
          const SizedBox(height: 10),
          Text(
            recommendation.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.swap_horiz_outlined,
                label: '${recommendation.suggestedActionCount} move',
              ),
              TalentMetaLabel(
                icon: Icons.pending_actions_outlined,
                label: '${recommendation.sourceOpenCount} open',
              ),
              TalentMetaLabel(
                icon: Icons.report_problem_outlined,
                label: '${recommendation.sourceBlockedCount} blocked',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${recommendation.sourceOverdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.article_outlined,
                label: recommendation.reason,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(
  IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority priority,
) {
  return switch (priority) {
    IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.critical =>
      const Color(0xFFDC2626),
    IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.support =>
      const Color(0xFFD97706),
  };
}

IconData _priorityIcon(
  IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority priority,
) {
  return switch (priority) {
    IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.critical =>
      Icons.priority_high_outlined,
    IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.support =>
      Icons.balance_outlined,
  };
}

@Preview(name: 'Talent risk council owner rebalance tile')
Widget incomingTalentRiskCouncilCommitmentOwnerRebalanceTilePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilCommitmentOwnerRebalanceTile(
          recommendation: _previewRecommendation,
        ),
      ),
    ),
  );
}

const _previewRecommendation =
    IncomingTalentRiskCouncilCommitmentOwnerRebalanceRecommendation(
      sourceOwnerName: 'Ari Talent Partner',
      targetOwnerName: 'Citra HRBP',
      priority:
          IncomingTalentRiskCouncilCommitmentOwnerRebalancePriority.critical,
      suggestedActionCount: 2,
      sourceOpenCount: 4,
      sourceBlockedCount: 1,
      sourceOverdueCount: 1,
      sourceWaitingEvidenceCount: 1,
      reliefCapacity: 1,
      reason: '1 blocked commitment action',
      nextAction:
          'Move 2 urgent actions from Ari Talent Partner to Citra HRBP.',
    );
