import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionActivationCheckInTile extends StatelessWidget {
  final IncomingTalentSuccessionActivationCheckIn checkIn;

  const IncomingTalentSuccessionActivationCheckInTile({
    super.key,
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    final color = _trendColor(checkIn.trend);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, color: HrisColors.primary),
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
                      checkIn.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: checkIn.trend.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: checkIn.confidenceRatio,
            color: color,
            label: '${checkIn.confidenceScore}/5 transition confidence',
          ),
          const SizedBox(height: 10),
          Text(
            checkIn.nextStep,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (checkIn.blockerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              checkIn.blockerNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: checkIn.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: checkIn.reviewerName,
              ),
              TalentMetaLabel(
                icon: Icons.rocket_launch_outlined,
                label: checkIn.activationStatus.label,
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

Color _trendColor(IncomingTalentSuccessionActivationCheckInTrend trend) {
  return switch (trend) {
    IncomingTalentSuccessionActivationCheckInTrend.accelerating => const Color(
      0xFF059669,
    ),
    IncomingTalentSuccessionActivationCheckInTrend.onTrack => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionActivationCheckInTrend.watch => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionActivationCheckInTrend.blocked => const Color(
      0xFFDC2626,
    ),
  };
}
