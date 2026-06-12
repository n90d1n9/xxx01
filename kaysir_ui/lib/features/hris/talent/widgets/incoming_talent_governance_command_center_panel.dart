import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_command_center_models.dart';
import '../states/incoming_talent_governance_command_center_provider.dart';
import 'incoming_talent_governance_command_lane_tile.dart';
import 'talent_meta_label.dart';

/// Executive command center for talent governance decisions.
class IncomingTalentGovernanceCommandCenterPanel extends ConsumerWidget {
  const IncomingTalentGovernanceCommandCenterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandCenter = ref.watch(
      incomingTalentGovernanceCommandCenterProvider,
    );
    final color = incomingTalentGovernanceCommandStatusColor(
      commandCenter.status,
    );

    return HrisSectionPanel(
      icon: Icons.dashboard_customize_outlined,
      title: 'Talent governance command center',
      subtitle: commandCenter.nextAction,
      emptyMessage: 'No talent governance lanes',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Score',
              value: '${commandCenter.governanceScore}%',
            ),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${commandCenter.criticalLaneCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: '${commandCenter.watchLaneCount}',
            ),
            HrisMetricStripItem(
              label: 'Decisions',
              value: '${commandCenter.decisionCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrisStatusPill(
                    label: commandCenter.status.label,
                    color: color,
                  ),
                  const Spacer(),
                  Text(
                    '${commandCenter.laneCount} lanes',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HrisColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: commandCenter.governanceRatio,
                color: color,
                label: '${commandCenter.governanceScore}% governance readiness',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${commandCenter.totalSignalCount} active governance signals',
                  ),
                  TalentMetaLabel(
                    icon: Icons.check_circle_outline,
                    label:
                        '${commandCenter.stableLaneCount} stable ${_plural(commandCenter.stableLaneCount, 'lane')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${commandCenter.decisionCount} pending governance ${_plural(commandCenter.decisionCount, 'decision')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final lane in commandCenter.lanes.take(6))
          IncomingTalentGovernanceCommandLaneTile(lane: lane),
      ],
    );
  }
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance command center panel')
Widget incomingTalentGovernanceCommandCenterPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceCommandCenterProvider.overrideWithValue(
        _previewCenter,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceCommandCenterPanel(),
        ),
      ),
    ),
  );
}

const _previewLanes = [
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-assurance',
    type: IncomingTalentGovernanceCommandLaneType.assurance,
    status: IncomingTalentGovernanceCommandStatus.critical,
    title: 'Assurance',
    detail: '4 evidence gaps, 3 remediation actions, 2 execution tracks.',
    metricLabel: 'Gaps',
    metricValue: '4',
    nextAction: 'Unblock 1 assurance remediation execution track.',
    pressureRatio: 0.74,
    signalCount: 5,
    decisionCount: 3,
  ),
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-action-sla',
    type: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: IncomingTalentGovernanceCommandStatus.watch,
    title: 'Action SLA',
    detail: '0 overdue, 1 today, 2 at risk across 5 sources.',
    metricLabel: 'SLAs',
    metricValue: '8',
    nextAction: 'Close 1 talent operating SLA item due today.',
    pressureRatio: 0.42,
    signalCount: 3,
    decisionCount: 3,
  ),
];

const _previewCenter = IncomingTalentGovernanceCommandCenter(
  status: IncomingTalentGovernanceCommandStatus.critical,
  governanceScore: 64,
  laneCount: 7,
  criticalLaneCount: 1,
  watchLaneCount: 3,
  stableLaneCount: 3,
  totalSignalCount: 12,
  decisionCount: 8,
  nextAction:
      'Run governance review for 1 critical talent lane: Unblock 1 assurance remediation execution track.',
  lanes: _previewLanes,
);
