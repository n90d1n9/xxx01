import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'talent_meta_label.dart';

/// Tile for one owner workload in governance execution follow-through.
class IncomingTalentGovernanceExecutionOwnerWorkloadTile
    extends StatelessWidget {
  final IncomingTalentGovernanceExecutionOwnerWorkloadItem item;

  const IncomingTalentGovernanceExecutionOwnerWorkloadTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentGovernanceExecutionOwnerLoadColor(item.load);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_loadIcon(item.load), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.actionCount} governance execution ${_plural(item.actionCount, 'action')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.load.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.normalizedAverageProgressRatio,
            color: color,
            label:
                '${(item.normalizedAverageProgressRatio * 100).round()}% owner action progress',
          ),
          const SizedBox(height: 10),
          Text(
            item.nextAction,
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.earliestDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${item.criticalActionCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${item.overdueActionCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label:
                    '${item.signalCount} ${_plural(item.signalCount, 'signal')}',
              ),
              TalentMetaLabel(
                icon: Icons.gavel_outlined,
                label:
                    '${item.decisionCount} ${_plural(item.decisionCount, 'decision')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentGovernanceExecutionOwnerLoadColor(
  IncomingTalentGovernanceExecutionOwnerLoad load,
) {
  return switch (load) {
    IncomingTalentGovernanceExecutionOwnerLoad.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentGovernanceExecutionOwnerLoad.stretched => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceExecutionOwnerLoad.balanced => const Color(
      0xFF2563EB,
    ),
  };
}

IconData _loadIcon(IncomingTalentGovernanceExecutionOwnerLoad load) {
  return switch (load) {
    IncomingTalentGovernanceExecutionOwnerLoad.critical =>
      Icons.priority_high_outlined,
    IncomingTalentGovernanceExecutionOwnerLoad.stretched =>
      Icons.speed_outlined,
    IncomingTalentGovernanceExecutionOwnerLoad.balanced =>
      Icons.account_circle_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution owner workload tile')
Widget incomingTalentGovernanceExecutionOwnerWorkloadTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionOwnerWorkloadTile(
          item: _previewItem,
        ),
      ),
    ),
  );
}

final _previewItem = IncomingTalentGovernanceExecutionOwnerWorkloadItem(
  ownerName: 'People Risk and Assurance',
  load: IncomingTalentGovernanceExecutionOwnerLoad.critical,
  actionCount: 2,
  criticalActionCount: 1,
  highActionCount: 1,
  standardActionCount: 0,
  overdueActionCount: 1,
  signalCount: 9,
  decisionCount: 6,
  readinessTaskCount: 2,
  earliestDueDate: DateTime(2026, 6, 11),
  averageProgressRatio: 0.25,
  nextAction:
      'Rebalance 1 overdue governance execution action from People Risk and Assurance.',
  actionIds: const [
    'talent-governance-execution-action:assurance',
    'talent-governance-execution-action:evidence',
  ],
);
