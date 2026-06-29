import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_brief_models.dart';
import '../states/incoming_talent_risk_council_brief_provider.dart';
import 'incoming_talent_risk_council_brief_insight_tile.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilBriefPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilBriefPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brief = ref.watch(incomingTalentRiskCouncilBriefProvider);
    final color = incomingTalentRiskCouncilBriefStatusColor(brief.status);

    return HrisSectionPanel(
      icon: Icons.summarize_outlined,
      title: 'Talent risk council brief',
      subtitle: brief.nextAction,
      emptyMessage: 'No talent risk council brief',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Pending',
              value: '${brief.pendingDecisionCount}',
            ),
            HrisMetricStripItem(
              label: 'Decisions',
              value: '${brief.decisionCount}',
            ),
            HrisMetricStripItem(
              label: 'Follow-ups',
              value: '${brief.openFollowUpCount}',
            ),
            HrisMetricStripItem(
              label: 'SLA',
              value:
                  '${brief.blockedSlaCount + brief.escalatedSlaCount + brief.overdueSlaCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrisStatusPill(label: brief.status.label, color: color),
                  const Spacer(),
                  Text(
                    '${(brief.readinessRatio * 100).round()}% ready',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HrisColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: brief.readinessRatio,
                color: color,
                label:
                    '${(brief.readinessRatio * 100).round()}% council readiness',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label: '${brief.criticalDecisionCount} critical decisions',
                  ),
                  TalentMetaLabel(
                    icon: Icons.next_plan_outlined,
                    label: '${brief.waitingFollowUpCount} follow-ups to create',
                  ),
                  TalentMetaLabel(
                    icon: Icons.event_available_outlined,
                    label: '${brief.dueSoonSlaCount} SLA due soon',
                  ),
                  TalentMetaLabel(
                    icon: Icons.task_alt_outlined,
                    label:
                        '${brief.completedFollowUpCount} follow-ups completed',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final insight in brief.insights.take(4))
          IncomingTalentRiskCouncilBriefInsightTile(insight: insight),
      ],
    );
  }
}

Color incomingTalentRiskCouncilBriefStatusColor(
  IncomingTalentRiskCouncilBriefStatus status,
) {
  return switch (status) {
    IncomingTalentRiskCouncilBriefStatus.clear => const Color(0xFF15803D),
    IncomingTalentRiskCouncilBriefStatus.watch => const Color(0xFFD97706),
    IncomingTalentRiskCouncilBriefStatus.critical => const Color(0xFFDC2626),
  };
}
