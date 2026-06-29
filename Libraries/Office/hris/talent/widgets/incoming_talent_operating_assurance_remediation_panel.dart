import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import '../states/incoming_talent_operating_inbox_provider.dart';
import 'incoming_talent_operating_assurance_remediation_tile.dart';

/// Owner-assigned remediation plan for talent assurance exposure.
class IncomingTalentOperatingAssuranceRemediationPanel extends ConsumerWidget {
  const IncomingTalentOperatingAssuranceRemediationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.watch(
      incomingTalentOperatingAssuranceRemediationActionsProvider,
    );
    final summary = ref.watch(
      incomingTalentOperatingAssuranceRemediationSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Talent assurance remediation',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent assurance remediation',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Actions',
              value: '${summary.actionCount}',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${summary.criticalActionCount}',
            ),
            HrisMetricStripItem(
              label: 'Owners',
              value: '${summary.ownerCount}',
            ),
            HrisMetricStripItem(
              label: 'Linked',
              value: '${summary.linkedEscalationCount}',
            ),
          ],
        ),
        if (actions.isEmpty)
          const HrisListSurface(
            child: Text('No active assurance remediation actions.'),
          )
        else
          for (final action in actions.take(5))
            IncomingTalentOperatingAssuranceRemediationTile(action: action),
      ],
    );
  }
}

@Preview(name: 'Talent assurance remediation panel')
Widget incomingTalentOperatingAssuranceRemediationPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentOperatingAssuranceRemediationActionsProvider
          .overrideWithValue(_previewActions),
      incomingTalentOperatingAssuranceRemediationSummaryProvider
          .overrideWithValue(
            IncomingTalentOperatingAssuranceRemediationSummary.fromActions(
              _previewActions,
            ),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentOperatingAssuranceRemediationPanel(),
        ),
      ),
    ),
  );
}

final _previewActions = [
  IncomingTalentOperatingAssuranceRemediationAction(
    id: 'assurance-remediation-people-operations-talent-partner-risk-council',
    type:
        IncomingTalentOperatingAssuranceRemediationType.recoverOverdueEvidence,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.critical,
    assuranceLevel: IncomingTalentOperatingAssuranceLevel.exposed,
    ownerName: 'People Operations Talent Partner',
    workstreamLabel: 'Risk council',
    title: 'People Operations Talent Partner - Risk council evidence',
    detail: '2 assurance gaps in risk council',
    nextAction:
        'Ask People Operations Talent Partner to recover 1 overdue risk council evidence gap.',
    gapCount: 2,
    criticalGapCount: 1,
    highGapCount: 1,
    overdueGapCount: 1,
    dueTodayGapCount: 0,
    linkedEscalationCount: 3,
    nextDueDate: DateTime(2026, 6, 10),
    pressureRatio: 0.78,
    evidenceRequests: const [
      'Attach decision notes, owner commitment, and follow-up acceptance.',
    ],
    gapIds: const ['evidence-risk-overdue', 'evidence-risk-today'],
  ),
  IncomingTalentOperatingAssuranceRemediationAction(
    id: 'assurance-remediation-learning-partner-development',
    type: IncomingTalentOperatingAssuranceRemediationType.closeDueToday,
    priority: IncomingTalentOperatingAssuranceRemediationPriority.high,
    assuranceLevel: IncomingTalentOperatingAssuranceLevel.guarded,
    ownerName: 'Learning Partner',
    workstreamLabel: 'Development',
    title: 'Learning Partner - Development evidence',
    detail: '1 assurance gap in development',
    nextAction:
        'Ask Learning Partner to close 1 development evidence gap due today.',
    gapCount: 1,
    criticalGapCount: 0,
    highGapCount: 1,
    overdueGapCount: 0,
    dueTodayGapCount: 1,
    linkedEscalationCount: 0,
    nextDueDate: DateTime(2026, 6, 11),
    pressureRatio: 0.46,
    evidenceRequests: const [
      'Attach attendance, completion proof, and learner feedback.',
    ],
    gapIds: const ['evidence-training-today'],
  ),
];
