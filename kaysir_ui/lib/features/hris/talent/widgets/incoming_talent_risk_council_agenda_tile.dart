import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_agenda_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilAgendaTile extends StatelessWidget {
  final IncomingTalentRiskCouncilAgendaItem item;

  const IncomingTalentRiskCouncilAgendaTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilAgendaPriorityColor(item.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sectionIcon(item.section), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.section.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.priority.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.objective,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.targetOutcome,
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
                icon: Icons.badge_outlined,
                label: item.facilitatorName,
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${item.timeboxMinutes} min',
              ),
              TalentMetaLabel(
                icon: Icons.confirmation_number_outlined,
                label: '${item.sourceCount} signals',
              ),
              TalentMetaLabel(
                icon: Icons.checklist_outlined,
                label: '${item.readinessTaskIds.length} prep tasks',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilAgendaPriorityColor(
  IncomingTalentRiskCouncilAgendaPriority priority,
) {
  return switch (priority) {
    IncomingTalentRiskCouncilAgendaPriority.critical => const Color(0xFFDC2626),
    IncomingTalentRiskCouncilAgendaPriority.high => const Color(0xFFD97706),
    IncomingTalentRiskCouncilAgendaPriority.normal => const Color(0xFF2563EB),
    IncomingTalentRiskCouncilAgendaPriority.clear => const Color(0xFF15803D),
  };
}

IconData _sectionIcon(IncomingTalentRiskCouncilAgendaSection section) {
  return switch (section) {
    IncomingTalentRiskCouncilAgendaSection.clear =>
      Icons.event_available_outlined,
    IncomingTalentRiskCouncilAgendaSection.leadershipEscalation =>
      Icons.priority_high_outlined,
    IncomingTalentRiskCouncilAgendaSection.slaRecovery =>
      Icons.restore_outlined,
    IncomingTalentRiskCouncilAgendaSection.decisionDocket =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilAgendaSection.followUpPlanning =>
      Icons.next_plan_outlined,
    IncomingTalentRiskCouncilAgendaSection.ownerConfirmation =>
      Icons.assignment_ind_outlined,
    IncomingTalentRiskCouncilAgendaSection.executionReview =>
      Icons.task_alt_outlined,
    IncomingTalentRiskCouncilAgendaSection.commitmentClose =>
      Icons.lock_clock_outlined,
  };
}
