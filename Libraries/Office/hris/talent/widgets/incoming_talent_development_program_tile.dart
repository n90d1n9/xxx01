import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentDevelopmentProgramTile extends StatelessWidget {
  final IncomingTalentDevelopmentProgram program;
  final int enrolledCount;

  const IncomingTalentDevelopmentProgramTile({
    super.key,
    required this.program,
    required this.enrolledCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = _programStatusColor(program.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      program.skillFocus,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: program.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: program.fillRatio(enrolledCount),
            color: color,
            label:
                '$enrolledCount/${program.capacity} seats filled, '
                '${program.availableSeats(enrolledCount)} open',
          ),
          const SizedBox(height: 10),
          Text(
            program.expectedOutcome,
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
                label: program.department,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: program.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.category_outlined,
                label: program.track.label,
              ),
              TalentMetaLabel(
                icon: Icons.speed_outlined,
                label: program.intensity.label,
              ),
              TalentMetaLabel(
                icon: Icons.timelapse_outlined,
                label: '${program.durationDays} days',
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(program.startDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _programStatusColor(IncomingTalentDevelopmentProgramStatus status) {
  return switch (status) {
    IncomingTalentDevelopmentProgramStatus.draft => const Color(0xFF2563EB),
    IncomingTalentDevelopmentProgramStatus.active => const Color(0xFF059669),
    IncomingTalentDevelopmentProgramStatus.paused => const Color(0xFFD97706),
    IncomingTalentDevelopmentProgramStatus.archived => const Color(0xFF64748B),
  };
}
