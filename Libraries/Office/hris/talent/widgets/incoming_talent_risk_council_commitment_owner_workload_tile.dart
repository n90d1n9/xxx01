import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentRiskCouncilCommitmentOwnerWorkloadTile
    extends StatelessWidget {
  final IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem item;

  const IncomingTalentRiskCouncilCommitmentOwnerWorkloadTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentRiskCouncilCommitmentOwnerLoadColor(item.load);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_loadIcon(item.load), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.openCount} open of ${item.totalCount} actions',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.load.label, color: color),
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.earliestDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.report_problem_outlined,
                label: '${item.blockedCount} blocked',
              ),
              TalentMetaLabel(
                icon: Icons.article_outlined,
                label: '${item.waitingEvidenceCount} evidence',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${item.overdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.confirmation_number_outlined,
                label: '${item.sourceCount} signals',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentRiskCouncilCommitmentOwnerLoadColor(
  IncomingTalentRiskCouncilCommitmentOwnerLoad load,
) {
  return switch (load) {
    IncomingTalentRiskCouncilCommitmentOwnerLoad.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced => const Color(
      0xFF2563EB,
    ),
    IncomingTalentRiskCouncilCommitmentOwnerLoad.clear => const Color(
      0xFF15803D,
    ),
  };
}

IconData _loadIcon(IncomingTalentRiskCouncilCommitmentOwnerLoad load) {
  return switch (load) {
    IncomingTalentRiskCouncilCommitmentOwnerLoad.critical =>
      Icons.priority_high_outlined,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched =>
      Icons.speed_outlined,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced =>
      Icons.account_circle_outlined,
    IncomingTalentRiskCouncilCommitmentOwnerLoad.clear =>
      Icons.check_circle_outline,
  };
}
