import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionTile
    extends StatelessWidget {
  final IncomingTalentSuccessionCoverageCouncilDecision decision;

  const IncomingTalentSuccessionCoverageCouncilDecisionTile({
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
                      decision.scopeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${decision.lane.label} - ${decision.priority.label}',
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: decision.coverageRatio,
            color: color,
            label: '${decision.coverageScore}% coverage',
          ),
          const SizedBox(height: 10),
          Text(
            decision.commitmentSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            decision.minutesNote,
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
                icon: Icons.groups_2_outlined,
                label: decision.decisionMakerName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: decision.executiveSponsorName,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: decision.departmentScope,
              ),
              TalentMetaLabel(
                icon: Icons.event_note_outlined,
                label: DateFormat('MMM d').format(decision.decisionDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(decision.followUpDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _outcomeColor(
  IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
) {
  return switch (outcome) {
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .approveRecoveryPlan =>
      const Color(0xFF2563EB),
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .assignExecutiveSponsor =>
      const Color(0xFF7C3AED),
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure =>
      const Color(0xFF15803D),
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil =>
      const Color(0xFFD97706),
    IncomingTalentSuccessionCoverageCouncilDecisionOutcome
        .escalateToPeopleBoard =>
      const Color(0xFFDC2626),
  };
}
