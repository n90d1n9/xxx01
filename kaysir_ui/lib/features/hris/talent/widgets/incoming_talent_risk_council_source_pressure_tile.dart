import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../models/incoming_talent_risk_council_source_pressure.dart';
import 'talent_meta_label.dart';

/// Visual triage row for one risk council source pressure bucket.
class IncomingTalentRiskCouncilSourcePressureTile extends StatelessWidget {
  final IncomingTalentRiskCouncilSourcePressure pressure;

  const IncomingTalentRiskCouncilSourcePressureTile({
    super.key,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(pressure.level);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sourceIcon(pressure.source), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pressure.source.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${pressure.totalCount} active SLA items',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: pressure.level.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: pressure.pressureRatio,
            color: color,
            label: '${(pressure.pressureRatio * 100).round()}% pressure',
          ),
          const SizedBox(height: 10),
          Text(
            pressure.nextAction,
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
                icon: Icons.people_outline,
                label: '${pressure.candidateCount} people',
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${pressure.urgentCount} urgent',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: '${pressure.dueSoonCount} due soon',
              ),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: '${pressure.waitingDecisionCount} decisions',
              ),
              TalentMetaLabel(
                icon: Icons.task_alt_outlined,
                label: '${pressure.activeFollowUpCount} follow-ups',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _levelColor(IncomingTalentRiskCouncilSourcePressureLevel level) {
  return switch (level) {
    IncomingTalentRiskCouncilSourcePressureLevel.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilSourcePressureLevel.watch => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilSourcePressureLevel.steady => const Color(
      0xFF15803D,
    ),
  };
}

IconData _sourceIcon(IncomingTalentRiskCouncilQueueSource source) {
  return switch (source) {
    IncomingTalentRiskCouncilQueueSource.general => Icons.groups_2_outlined,
    IncomingTalentRiskCouncilQueueSource.developmentIntervention =>
      Icons.build_circle_outlined,
    IncomingTalentRiskCouncilQueueSource.developmentResolutionReview =>
      Icons.rule_folder_outlined,
    IncomingTalentRiskCouncilQueueSource.promotionResolutionReview =>
      Icons.workspace_premium_outlined,
    IncomingTalentRiskCouncilQueueSource.developmentFollowUp =>
      Icons.add_task_outlined,
    IncomingTalentRiskCouncilQueueSource.developmentOutcome =>
      Icons.health_and_safety_outlined,
    IncomingTalentRiskCouncilQueueSource.careerSupportAction =>
      Icons.support_agent_outlined,
    IncomingTalentRiskCouncilQueueSource.careerSupportOutcome =>
      Icons.insights_outlined,
    IncomingTalentRiskCouncilQueueSource.programMilestone =>
      Icons.flag_outlined,
    IncomingTalentRiskCouncilQueueSource.programCompletion =>
      Icons.verified_outlined,
  };
}

@Preview(name: 'Talent risk council source pressure tile')
Widget incomingTalentRiskCouncilSourcePressureTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilSourcePressureTile(
          pressure: _previewPressure,
        ),
      ),
    ),
  );
}

const _previewPressure = IncomingTalentRiskCouncilSourcePressure(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  level: IncomingTalentRiskCouncilSourcePressureLevel.critical,
  totalCount: 3,
  candidateCount: 2,
  blockedCount: 0,
  escalatedCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  waitingDecisionCount: 1,
  waitingFollowUpCount: 1,
  activeFollowUpCount: 1,
  nextAction: 'Track 1 escalated promotion resolution review SLA item.',
);
