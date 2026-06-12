import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionNominationTile extends StatelessWidget {
  final IncomingTalentSuccessionNomination nomination;

  const IncomingTalentSuccessionNominationTile({
    super.key,
    required this.nomination,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(nomination.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_reg_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomination.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      nomination.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: nomination.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nomination.businessCase,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nomination.successPlan,
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
                label: nomination.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: nomination.sponsorName,
              ),
              TalentMetaLabel(
                icon: Icons.workspace_premium_outlined,
                label: nomination.nominationType.label,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: nomination.readiness.label,
              ),
              TalentMetaLabel(
                icon: Icons.groups_2_outlined,
                label: DateFormat('MMM d').format(nomination.panelDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentSuccessionNominationStatus status) {
  return switch (status) {
    IncomingTalentSuccessionNominationStatus.panelReview => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionNominationStatus.approved => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionNominationStatus.deferred => const Color(
      0xFFDC2626,
    ),
    IncomingTalentSuccessionNominationStatus.sponsorFollowUp => const Color(
      0xFFD97706,
    ),
  };
}
