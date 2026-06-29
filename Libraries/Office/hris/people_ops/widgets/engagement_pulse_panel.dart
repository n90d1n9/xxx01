import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/people_ops_models.dart';
import 'people_ops_meta_label.dart';
import 'people_ops_status_styles.dart';

class EngagementPulsePanel extends StatelessWidget {
  final List<EngagementPulse> pulses;

  const EngagementPulsePanel({super.key, required this.pulses});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Engagement Pulse',
      icon: Icons.insights_outlined,
      subtitle: '${pulses.length} departments',
      emptyMessage: 'No engagement items match filters',
      children: pulses.map((pulse) => _EngagementTile(pulse: pulse)).toList(),
    );
  }
}

class _EngagementTile extends StatelessWidget {
  final EngagementPulse pulse;

  const _EngagementTile({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final color = peopleOpsPriorityColor(pulse.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pulse.department,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${pulse.score}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: pulse.score / 100,
            color: color,
            label: '${pulse.responseRate}% response rate',
          ),
          const SizedBox(height: 8),
          Text(
            pulse.insight,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          PeopleOpsMetaLabel(
            icon: Icons.how_to_vote_outlined,
            label: '${pulse.responseRate}% response rate',
          ),
        ],
      ),
    );
  }
}
