import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_brief_models.dart';

class IncomingTalentRiskCouncilBriefInsightTile extends StatelessWidget {
  final IncomingTalentRiskCouncilBriefInsight insight;

  const IncomingTalentRiskCouncilBriefInsightTile({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilBriefInsightToneColor(insight.tone);

    return HrisListSurface(
      child: Row(
        children: [
          Icon(_typeIcon(insight.type), color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          HrisStatusPill(label: insight.tone.label, color: color),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilBriefInsightToneColor(
  IncomingTalentRiskCouncilBriefInsightTone tone,
) {
  return switch (tone) {
    IncomingTalentRiskCouncilBriefInsightTone.positive => const Color(
      0xFF15803D,
    ),
    IncomingTalentRiskCouncilBriefInsightTone.watch => const Color(0xFFD97706),
    IncomingTalentRiskCouncilBriefInsightTone.critical => const Color(
      0xFFDC2626,
    ),
  };
}

IconData _typeIcon(IncomingTalentRiskCouncilBriefInsightType type) {
  return switch (type) {
    IncomingTalentRiskCouncilBriefInsightType.leadershipAttention =>
      Icons.groups_2_outlined,
    IncomingTalentRiskCouncilBriefInsightType.slaRecovery =>
      Icons.timer_off_outlined,
    IncomingTalentRiskCouncilBriefInsightType.decisionQueue =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilBriefInsightType.followUpCreation =>
      Icons.next_plan_outlined,
    IncomingTalentRiskCouncilBriefInsightType.dueSoon =>
      Icons.event_available_outlined,
    IncomingTalentRiskCouncilBriefInsightType.execution =>
      Icons.task_alt_outlined,
    IncomingTalentRiskCouncilBriefInsightType.clear => Icons.verified_outlined,
  };
}
