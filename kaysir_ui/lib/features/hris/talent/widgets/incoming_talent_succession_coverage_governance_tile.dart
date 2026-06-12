import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageGovernanceTile extends StatelessWidget {
  final IncomingTalentSuccessionCoverageGovernanceRecord record;

  const IncomingTalentSuccessionCoverageGovernanceTile({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(record.riskLevel);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.policy_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.scopeLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${record.stage.label} - ${record.reviewDecision.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: record.riskLevel.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: record.coverageRatio,
            color: color,
            label: '${record.coverageScore}% governed coverage',
          ),
          const SizedBox(height: 10),
          Text(
            record.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            record.evidenceSummary,
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
                label: record.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: record.departmentScope,
              ),
              TalentMetaLabel(
                icon: Icons.timeline_outlined,
                label: record.stage.label,
              ),
              TalentMetaLabel(
                icon: Icons.monitor_heart_outlined,
                label: record.coverageHealth.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(record.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _riskColor(IncomingTalentSuccessionCoverageGovernanceRiskLevel risk) {
  return switch (risk) {
    IncomingTalentSuccessionCoverageGovernanceRiskLevel.low => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionCoverageGovernanceRiskLevel.medium => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionCoverageGovernanceRiskLevel.high => const Color(
      0xFFEA580C,
    ),
    IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical => const Color(
      0xFFDC2626,
    ),
  };
}
