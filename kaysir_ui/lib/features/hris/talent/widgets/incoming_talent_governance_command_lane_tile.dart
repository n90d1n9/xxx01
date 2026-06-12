import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_command_center_models.dart';
import 'talent_meta_label.dart';

/// Tile for one executive lane in the talent governance command center.
class IncomingTalentGovernanceCommandLaneTile extends StatelessWidget {
  final IncomingTalentGovernanceCommandLane lane;

  const IncomingTalentGovernanceCommandLaneTile({
    super.key,
    required this.lane,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceCommandStatusColor(lane.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_laneIcon(lane.type), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lane.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      lane.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: lane.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: lane.normalizedPressureRatio,
            color: color,
            label:
                '${(lane.normalizedPressureRatio * 100).round()}% governance pressure',
          ),
          const SizedBox(height: 10),
          Text(
            lane.nextAction,
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
                icon: Icons.speed_outlined,
                label: '${lane.metricLabel}: ${lane.metricValue}',
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${lane.signalCount} ${_plural(lane.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${lane.decisionCount} ${_plural(lane.decisionCount, 'decision')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceCommandStatusColor(
  IncomingTalentGovernanceCommandStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceCommandStatus.critical => const Color(0xFFDC2626),
    IncomingTalentGovernanceCommandStatus.watch => const Color(0xFFD97706),
    IncomingTalentGovernanceCommandStatus.stable => const Color(0xFF059669),
  };
}

IconData _laneIcon(IncomingTalentGovernanceCommandLaneType type) {
  return switch (type) {
    IncomingTalentGovernanceCommandLaneType.health =>
      Icons.monitor_heart_outlined,
    IncomingTalentGovernanceCommandLaneType.actionSla => Icons.timer_outlined,
    IncomingTalentGovernanceCommandLaneType.escalation =>
      Icons.report_problem_outlined,
    IncomingTalentGovernanceCommandLaneType.assurance =>
      Icons.verified_user_outlined,
    IncomingTalentGovernanceCommandLaneType.succession =>
      Icons.groups_2_outlined,
    IncomingTalentGovernanceCommandLaneType.training => Icons.school_outlined,
    IncomingTalentGovernanceCommandLaneType.careerPath => Icons.route_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance command lane tile')
Widget incomingTalentGovernanceCommandLaneTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceCommandLaneTile(lane: _previewLane),
      ),
    ),
  );
}

const _previewLane = IncomingTalentGovernanceCommandLane(
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
);
