import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_assurance_execution_tile.dart';

/// Execution tracker for owner-led assurance remediation work.
class IncomingTalentOperatingAssuranceExecutionPanel extends ConsumerWidget {
  const IncomingTalentOperatingAssuranceExecutionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(
      incomingTalentOperatingAssuranceExecutionTracksProvider,
    );
    final summary = ref.watch(
      incomingTalentOperatingAssuranceExecutionSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.track_changes_outlined,
      title: 'Talent remediation execution',
      subtitle: summary.nextAction,
      emptyMessage: 'No assurance execution tracks',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Tracks',
              value: '${summary.trackCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Recovery',
              value: '${summary.recoveryCount}',
            ),
            HrisMetricStripItem(
              label: 'Due today',
              value: '${summary.dueTodayCount}',
            ),
          ],
        ),
        if (tracks.isEmpty)
          const HrisListSurface(
            child: Text('No active remediation execution to track.'),
          )
        else
          for (final track in tracks.take(5))
            IncomingTalentOperatingAssuranceExecutionTile(track: track),
      ],
    );
  }
}

@Preview(name: 'Talent assurance execution panel')
Widget incomingTalentOperatingAssuranceExecutionPanelPreview() {
  final previewTracks = _previewTracks();

  return ProviderScope(
    overrides: [
      incomingTalentOperatingAssuranceExecutionTracksProvider.overrideWithValue(
        previewTracks,
      ),
      incomingTalentOperatingAssuranceExecutionSummaryProvider
          .overrideWithValue(
            IncomingTalentOperatingAssuranceExecutionSummary.fromTracks(
              previewTracks,
            ),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingAssuranceExecutionPanel(),
        ),
      ),
    ),
  );
}

List<IncomingTalentOperatingAssuranceExecutionTrack> _previewTracks() {
  return [
    IncomingTalentOperatingAssuranceExecutionTrack(
      id: 'assurance-execution-assurance-remediation-people-operations-risk',
      remediationActionId: 'assurance-remediation-people-operations-risk',
      status: IncomingTalentOperatingAssuranceExecutionStatus.blocked,
      dueHealth: IncomingTalentOperatingAssuranceExecutionDueHealth.overdue,
      priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
      ownerName: 'People Operations Talent Partner',
      workstreamLabel: 'Risk council',
      title: 'People Operations Talent Partner execution - Risk council',
      detail: '2 open gaps with 3 completion proofs required',
      blocker: '3 linked escalations must be cleared before assurance closure.',
      nextStep:
          'Unblock linked risk council escalations with People Operations Talent Partner.',
      dueDate: DateTime(2026, 6, 10),
      executionRatio: 0.26,
      openGapCount: 2,
      overdueGapCount: 1,
      dueTodayGapCount: 0,
      linkedEscalationCount: 3,
      completionEvidence: [
        'Attach decision notes, owner commitment, and follow-up acceptance.',
        'Owner confirmation for 2 gaps.',
        'HRIS closure note for risk council assurance.',
      ],
      gapIds: ['evidence-risk-overdue', 'evidence-risk-linked'],
    ),
    IncomingTalentOperatingAssuranceExecutionTrack(
      id: 'assurance-execution-assurance-remediation-learning-development',
      remediationActionId: 'assurance-remediation-learning-development',
      status: IncomingTalentOperatingAssuranceExecutionStatus.dueToday,
      dueHealth: IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday,
      priority: IncomingTalentOperatingAssuranceRemediationPriority.high,
      ownerName: 'Learning Partner',
      workstreamLabel: 'Development',
      title: 'Learning Partner execution - Development',
      detail: '1 open gap with 3 completion proofs required',
      blocker: '1 due-today gap needs same-day proof.',
      nextStep: 'Close due-today development evidence before the HRIS cut-off.',
      dueDate: DateTime(2026, 6, 11),
      executionRatio: 0.62,
      openGapCount: 1,
      overdueGapCount: 0,
      dueTodayGapCount: 1,
      linkedEscalationCount: 0,
      completionEvidence: [
        'Attach attendance, completion proof, and learner feedback.',
        'Owner confirmation for 1 gap.',
        'HRIS closure note for development assurance.',
      ],
      gapIds: ['evidence-training-today'],
    ),
  ];
}
