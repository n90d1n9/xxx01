import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../models/incoming_talent_training_session_models.dart';
import 'talent_meta_label.dart';

/// Training-session tile with capacity, trainer, and evidence checkpoint.
class IncomingTalentTrainingSessionTile extends StatelessWidget {
  final IncomingTalentTrainingSession session;

  const IncomingTalentTrainingSessionTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentTrainingSessionStatusColor(session.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_formatIcon(session.format), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.programTitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${session.trainerName} at ${session.location}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: session.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: session.fillRatio,
            color: color,
            label:
                '${session.reservedSeats}/${session.capacity} seats reserved, ${session.openSeats} open',
          ),
          const SizedBox(height: 10),
          Text(
            session.outcomeCheckpoint,
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
                label: session.department,
              ),
              TalentMetaLabel(
                icon: Icons.connected_tv_outlined,
                label: session.format.label,
              ),
              TalentMetaLabel(
                icon: Icons.category_outlined,
                label: session.sourceProgramTrack.label,
              ),
              TalentMetaLabel(
                icon: Icons.speed_outlined,
                label: session.sourceProgramIntensity.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(session.sessionDate),
              ),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: DateFormat('MMM d').format(session.followUpDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentTrainingSessionStatusColor(
  IncomingTalentTrainingSessionStatus status,
) {
  return switch (status) {
    IncomingTalentTrainingSessionStatus.draft => const Color(0xFF2563EB),
    IncomingTalentTrainingSessionStatus.scheduled => const Color(0xFF059669),
    IncomingTalentTrainingSessionStatus.live => const Color(0xFF7C3AED),
    IncomingTalentTrainingSessionStatus.completed => const Color(0xFF15803D),
    IncomingTalentTrainingSessionStatus.cancelled => const Color(0xFF64748B),
  };
}

IconData _formatIcon(IncomingTalentTrainingSessionFormat format) {
  return switch (format) {
    IncomingTalentTrainingSessionFormat.onsite => Icons.meeting_room_outlined,
    IncomingTalentTrainingSessionFormat.virtual => Icons.videocam_outlined,
    IncomingTalentTrainingSessionFormat.hybrid => Icons.hub_outlined,
    IncomingTalentTrainingSessionFormat.selfPaced => Icons.menu_book_outlined,
  };
}

@Preview(name: 'Talent training session tile')
Widget incomingTalentTrainingSessionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentTrainingSessionTile(session: _previewSession),
      ),
    ),
  );
}

final _previewSession = IncomingTalentTrainingSession(
  id: 'talent-training-session-preview',
  programId: 'program-preview',
  programTitle: 'Engineering growth accelerator',
  department: 'Engineering',
  trainerName: 'Rani Prasetya',
  format: IncomingTalentTrainingSessionFormat.hybrid,
  status: IncomingTalentTrainingSessionStatus.scheduled,
  location: 'Engineering hybrid cohort room',
  prerequisite: 'Complete manager briefing before the accelerator.',
  outcomeCheckpoint: 'Submit architecture leadership evidence after session.',
  capacity: 16,
  reservedSeats: 11,
  sessionDate: DateTime(2026, 6, 24),
  followUpDate: DateTime(2026, 7, 8),
  sourceProgramTrack: IncomingTalentDevelopmentProgramTrack.leadership,
  sourceProgramIntensity: IncomingTalentDevelopmentProgramIntensity.standard,
  createdAt: DateTime(2026, 6, 9),
);
