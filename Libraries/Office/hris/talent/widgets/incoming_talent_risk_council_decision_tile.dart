import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'talent_meta_label.dart';

/// List tile that records a council decision with owner, source, and follow-up.
class IncomingTalentRiskCouncilDecisionTile extends StatelessWidget {
  final IncomingTalentRiskCouncilDecision decision;

  const IncomingTalentRiskCouncilDecisionTile({
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
                      '${decision.role} - ${decision.department}',
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
            value: decision.urgencyRatio,
            color: color,
            label:
                '${decision.signalCount} ${decision.category.label.toLowerCase()} signals',
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
                label: decision.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: decision.sourceSeverity.label,
              ),
              if (decision.source !=
                  IncomingTalentRiskCouncilQueueSource.general)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: decision.source.label,
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

Color _outcomeColor(IncomingTalentRiskCouncilDecisionOutcome outcome) {
  return switch (outcome) {
    IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan => const Color(
      0xFF2563EB,
    ),
    IncomingTalentRiskCouncilDecisionOutcome.assignOwner => const Color(
      0xFF7C3AED,
    ),
    IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilDecisionOutcome.closeRisk => const Color(
      0xFF15803D,
    ),
  };
}

@Preview(name: 'Talent risk council decision tile')
Widget incomingTalentRiskCouncilDecisionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilDecisionTile(
          decision: _previewDecision,
        ),
      ),
    ),
  );
}

final _previewDecision = IncomingTalentRiskCouncilDecision(
  id: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  decisionMakerName: 'Talent Council',
  ownerName: 'People Operations Promotion Stabilization Partner',
  decisionDate: DateTime(2026, 6, 11),
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  commitmentSummary:
      'Council will monitor promotion stabilization risk at the next talent risk council.',
  minutesNote:
      'Residual role-risk evidence needs manager checkpoint and closure disposition.',
  followUpDate: DateTime(2026, 7, 11),
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);
