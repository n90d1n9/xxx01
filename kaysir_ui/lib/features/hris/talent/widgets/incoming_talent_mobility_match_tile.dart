import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityMatchTile extends StatelessWidget {
  final IncomingTalentMobilityMatch match;
  final VoidCallback onSponsorReview;
  final VoidCallback onAccept;
  final VoidCallback onBlock;
  final VoidCallback onActivate;

  const IncomingTalentMobilityMatchTile({
    super.key,
    required this.match,
    required this.onSponsorReview,
    required this.onAccept,
    required this.onBlock,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(match.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.compare_arrows_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      match.opportunityTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: match.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: match.fitRatio,
            color: color,
            label: '${match.fitScore}% mobility fit',
          ),
          const SizedBox(height: 10),
          Text(
            match.businessRationale,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            match.supportPlan,
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
                label: match.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.verified_user_outlined,
                label: match.sponsorName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(match.startDate),
              ),
              TalentMetaLabel(
                icon: Icons.route_outlined,
                label: match.moveType.label,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      match.status ==
                              IncomingTalentMobilityMatchStatus.sponsorReview
                          ? null
                          : onSponsorReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Review'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      match.status == IncomingTalentMobilityMatchStatus.blocked
                          ? null
                          : onBlock,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Block'),
                ),
                OutlinedButton.icon(
                  onPressed:
                      match.status == IncomingTalentMobilityMatchStatus.accepted
                          ? null
                          : onAccept,
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text('Accept'),
                ),
                FilledButton.icon(
                  onPressed:
                      match.status ==
                              IncomingTalentMobilityMatchStatus.activated
                          ? null
                          : onActivate,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Activate'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(IncomingTalentMobilityMatchStatus status) {
  return switch (status) {
    IncomingTalentMobilityMatchStatus.proposed => const Color(0xFF2563EB),
    IncomingTalentMobilityMatchStatus.sponsorReview => const Color(0xFF7C3AED),
    IncomingTalentMobilityMatchStatus.accepted => const Color(0xFF059669),
    IncomingTalentMobilityMatchStatus.blocked => const Color(0xFFDC2626),
    IncomingTalentMobilityMatchStatus.activated => const Color(0xFF15803D),
  };
}
