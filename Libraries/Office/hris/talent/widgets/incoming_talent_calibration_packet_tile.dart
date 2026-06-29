import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_calibration_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentCalibrationPacketTile extends StatelessWidget {
  final IncomingTalentCalibrationPacket packet;

  const IncomingTalentCalibrationPacketTile({super.key, required this.packet});

  @override
  Widget build(BuildContext context) {
    final color = _recommendationColor(packet.recommendation);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packet.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      packet.evidenceSummary,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: packet.recommendation.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: packet.readinessRatio,
            color: color,
            label:
                '${packet.readinessScore}% readiness, ${packet.confidenceScore}/5 confidence',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: packet.department,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: packet.potential.label,
              ),
              TalentMetaLabel(
                icon: Icons.task_alt_outlined,
                label: '${packet.openInterventionCount} open actions',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(packet.reviewDueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _recommendationColor(IncomingTalentCalibrationRecommendation value) {
  return switch (value) {
    IncomingTalentCalibrationRecommendation.accelerate => const Color(
      0xFF059669,
    ),
    IncomingTalentCalibrationRecommendation.maintainCadence => const Color(
      0xFF2563EB,
    ),
    IncomingTalentCalibrationRecommendation.coach => const Color(0xFFD97706),
    IncomingTalentCalibrationRecommendation.escalate => const Color(0xFFDC2626),
  };
}
