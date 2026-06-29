import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionBenchCheckInTile extends StatelessWidget {
  final IncomingTalentSuccessionBenchCheckIn checkIn;

  const IncomingTalentSuccessionBenchCheckInTile({
    super.key,
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    final color = _healthColor(checkIn.health);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkIn.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${checkIn.readyNowCount}/${checkIn.successorSlateCount} ready now - ${checkIn.department}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: checkIn.health.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: checkIn.readinessRatio,
            color: color,
            label: '${checkIn.readinessScore}/5 bench readiness',
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: checkIn.readyNowRatio,
            color: color,
            label:
                '${(checkIn.readyNowRatio * 100).round()}% ready-now coverage',
          ),
          const SizedBox(height: 10),
          Text(
            checkIn.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            checkIn.blockerSummary,
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
                icon: Icons.person_outline,
                label: checkIn.candidateName,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: checkIn.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: checkIn.priority.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(checkIn.checkInDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(checkIn.nextCheckInDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _healthColor(IncomingTalentSuccessionBenchCheckInHealth health) {
  return switch (health) {
    IncomingTalentSuccessionBenchCheckInHealth.onTrack => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionBenchCheckInHealth.watch => const Color(0xFFD97706),
    IncomingTalentSuccessionBenchCheckInHealth.atRisk => const Color(
      0xFFDC2626,
    ),
    IncomingTalentSuccessionBenchCheckInHealth.blocked => const Color(
      0xFF991B1B,
    ),
  };
}
