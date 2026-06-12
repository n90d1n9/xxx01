import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentMobilityCadenceTile extends StatelessWidget {
  final IncomingTalentMobilityCadenceCheckIn checkIn;

  const IncomingTalentMobilityCadenceTile({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(checkIn.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_repeat_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkIn.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${checkIn.outcomeDecision.label} - ${checkIn.opportunityTitle}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: checkIn.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: checkIn.confidenceRatio,
            color: color,
            label: '${checkIn.hostConfidenceScore}/5 host confidence',
          ),
          const SizedBox(height: 10),
          Text(
            checkIn.supportPlan,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            checkIn.pulseSummary,
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
                label: checkIn.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: checkIn.hostDepartment,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: checkIn.residualRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: _deltaLabel(checkIn.confidenceDelta),
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(checkIn.nextReviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _deltaLabel(int value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix$value confidence';
}

Color _statusColor(IncomingTalentMobilityCadenceStatus status) {
  return switch (status) {
    IncomingTalentMobilityCadenceStatus.onTrack => const Color(0xFF15803D),
    IncomingTalentMobilityCadenceStatus.watch => const Color(0xFFD97706),
    IncomingTalentMobilityCadenceStatus.intervene => const Color(0xFFDC2626),
    IncomingTalentMobilityCadenceStatus.closed => const Color(0xFF475569),
  };
}
