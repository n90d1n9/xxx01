import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../models/incoming_talent_risk_council_sla_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilSlaTile extends StatelessWidget {
  final IncomingTalentRiskCouncilSlaItem item;
  final DateTime asOfDate;

  const IncomingTalentRiskCouncilSlaTile({
    super.key,
    required this.item,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sourceIcon(item.source), color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.source.label} - ${item.title}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.nextAction,
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
                icon: Icons.apartment_outlined,
                label: item.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: item.ownerName,
              ),
              if (item.councilSource !=
                  IncomingTalentRiskCouncilQueueSource.general)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: item.councilSource.label,
                ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: _dueLabel(item.daysUntilDue(asOfDate)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _sourceIcon(IncomingTalentRiskCouncilSlaSource source) {
  return switch (source) {
    IncomingTalentRiskCouncilSlaSource.councilDecision =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilSlaSource.councilFollowUp =>
      Icons.next_plan_outlined,
    IncomingTalentRiskCouncilSlaSource.followUpExecution =>
      Icons.task_alt_outlined,
  };
}

Color _statusColor(IncomingTalentRiskCouncilSlaStatus status) {
  return switch (status) {
    IncomingTalentRiskCouncilSlaStatus.blocked => const Color(0xFFD97706),
    IncomingTalentRiskCouncilSlaStatus.escalated => const Color(0xFFDC2626),
    IncomingTalentRiskCouncilSlaStatus.overdue => const Color(0xFFB91C1C),
    IncomingTalentRiskCouncilSlaStatus.dueSoon => const Color(0xFF2563EB),
    IncomingTalentRiskCouncilSlaStatus.waiting => const Color(0xFF7C3AED),
    IncomingTalentRiskCouncilSlaStatus.onTrack => const Color(0xFF15803D),
  };
}

String _dueLabel(int days) {
  if (days < 0) return '${days.abs()}d overdue';
  if (days == 0) return 'Due today';
  return 'Due in ${days}d';
}
