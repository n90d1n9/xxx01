import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionPanelDecisionTile extends StatelessWidget {
  final IncomingTalentSuccessionPanelDecision decision;

  const IncomingTalentSuccessionPanelDecisionTile({
    super.key,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final color = _outcomeColor(decision.outcome);

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
                      decision.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      decision.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: decision.outcome.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            decision.decisionSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            decision.conditions,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: decision.department,
              ),
              TalentMetaLabel(
                icon: Icons.groups_2_outlined,
                label: decision.panelLeadName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: decision.followUpOwner,
              ),
              TalentMetaLabel(
                icon: Icons.rocket_launch_outlined,
                label: DateFormat('MMM d').format(decision.activationDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(decision.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(IncomingTalentSuccessionPanelOutcome outcome) {
  return switch (outcome) {
    IncomingTalentSuccessionPanelOutcome.approvePromotion => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionPanelOutcome.approveSuccessionBench => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionPanelOutcome.conditionalApproval => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionPanelOutcome.defer => const Color(0xFFDC2626),
    IncomingTalentSuccessionPanelOutcome.decline => const Color(0xFF7F1D1D),
  };
}
