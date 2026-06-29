import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionTransitionPulseTile extends StatelessWidget {
  final IncomingTalentSuccessionTransitionPulse pulse;

  const IncomingTalentSuccessionTransitionPulseTile({
    super.key,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final color = _healthColor(pulse.health);

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
                      pulse.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${pulse.pulseWindow.label} pulse - ${pulse.targetRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: pulse.health.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: pulse.adoptionRatio,
            color: color,
            label: '${pulse.adoptionScore}/5 adoption',
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: pulse.managerConfidenceRatio,
            color: color,
            label: '${pulse.managerConfidenceScore}/5 manager confidence',
          ),
          const SizedBox(height: 10),
          Text(
            pulse.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pulse.stakeholderSentiment,
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
                label: pulse.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: pulse.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.shield_outlined,
                label: pulse.retentionRisk.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(pulse.pulseDate),
              ),
              TalentMetaLabel(
                icon: Icons.update_outlined,
                label: DateFormat('MMM d').format(pulse.nextPulseDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _healthColor(IncomingTalentSuccessionTransitionPulseHealth health) {
  return switch (health) {
    IncomingTalentSuccessionTransitionPulseHealth.thriving => const Color(
      0xFF15803D,
    ),
    IncomingTalentSuccessionTransitionPulseHealth.stable => const Color(
      0xFF2563EB,
    ),
    IncomingTalentSuccessionTransitionPulseHealth.watch => const Color(
      0xFFD97706,
    ),
    IncomingTalentSuccessionTransitionPulseHealth.intervention => const Color(
      0xFFDC2626,
    ),
  };
}
