import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/engagement_models.dart';
import 'engagement_meta_label.dart';
import 'engagement_status_styles.dart';

class PulseTopicPanel extends StatelessWidget {
  final List<PulseTopic> pulses;

  const PulseTopicPanel({super.key, required this.pulses});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Pulse Topics',
      icon: Icons.insights_outlined,
      subtitle: '${pulses.length} topics',
      emptyMessage: 'No pulse topics match filters',
      children: pulses.map((pulse) => _PulseTile(pulse: pulse)).toList(),
    );
  }
}

class _PulseTile extends StatelessWidget {
  final PulseTopic pulse;

  const _PulseTile({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final color = engagementPriorityColor(pulse.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pulse.topic,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
          const SizedBox(height: 8),
          HrisProgressBar(
            value: pulse.score / 100,
            color: color,
            label: pulse.insight,
          ),
          const SizedBox(height: 8),
          EngagementMetaLabel(
            icon:
                pulse.trend >= 0
                    ? Icons.trending_up_outlined
                    : Icons.trending_down_outlined,
            label: '${pulse.trend >= 0 ? '+' : ''}${pulse.trend} points',
          ),
        ],
      ),
    );
  }
}
