import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_program_models.dart';
import '../models/incoming_talent_training_session_models.dart';
import '../states/incoming_talent_training_session_provider.dart';
import 'incoming_talent_training_session_form.dart';
import 'incoming_talent_training_session_tile.dart';

/// Panel for scheduling and monitoring training sessions.
class IncomingTalentTrainingSessionPanel extends ConsumerWidget {
  const IncomingTalentTrainingSessionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(filteredIncomingTalentTrainingSessionsProvider);
    final summary = ref.watch(incomingTalentTrainingSessionSummaryProvider);

    return HrisSectionPanel(
      icon: Icons.event_available_outlined,
      title: 'Training sessions',
      subtitle: summary.nextAction,
      emptyMessage: 'No training session data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Scheduled',
              value: '${summary.scheduledCount}',
            ),
            HrisMetricStripItem(label: 'Live', value: '${summary.liveCount}'),
            HrisMetricStripItem(
              label: 'Seats',
              value: '${summary.reservedSeatCount}/${summary.totalCapacity}',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${summary.attentionCount}',
            ),
          ],
        ),
        HrisProgressBar(
          value: summary.utilizationRatio,
          color: HrisColors.primary,
          label:
              '${(summary.utilizationRatio * 100).round()}% planned seat utilization',
        ),
        const IncomingTalentTrainingSessionForm(),
        if (sessions.isEmpty)
          const HrisListSurface(
            child: Text('No training sessions scheduled yet.'),
          )
        else
          for (final session in sessions)
            IncomingTalentTrainingSessionTile(session: session),
      ],
    );
  }
}

@Preview(name: 'Talent training sessions panel')
Widget incomingTalentTrainingSessionPanelPreview() {
  final sessions = [_previewPanelTrainingSession];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentTrainingSessionsProvider.overrideWithValue(
        sessions,
      ),
      incomingTalentTrainingSessionSummaryProvider.overrideWithValue(
        IncomingTalentTrainingSessionSummary.fromSessions(
          sessions: sessions,
          asOfDate: DateTime(2026, 6, 9),
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentTrainingSessionPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelTrainingSession = IncomingTalentTrainingSession(
  id: 'talent-training-session-preview',
  programId: 'program-preview',
  programTitle: 'Finance recovery academy',
  department: 'Finance',
  trainerName: 'Dimas Wardhana',
  format: IncomingTalentTrainingSessionFormat.onsite,
  status: IncomingTalentTrainingSessionStatus.live,
  location: 'Finance academy room',
  prerequisite: 'Complete manager briefing before the academy.',
  outcomeCheckpoint: 'Submit close-cycle readiness evidence after session.',
  capacity: 12,
  reservedSeats: 10,
  sessionDate: DateTime(2026, 6, 18),
  followUpDate: DateTime(2026, 7, 2),
  sourceProgramTrack: IncomingTalentDevelopmentProgramTrack.recovery,
  sourceProgramIntensity: IncomingTalentDevelopmentProgramIntensity.accelerated,
  createdAt: DateTime(2026, 6, 9),
);
