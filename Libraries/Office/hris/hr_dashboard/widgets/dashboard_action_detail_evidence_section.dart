import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail.dart';
import '../models/dashboard_action_evidence_timeline.dart';
import 'dashboard_action_evidence_timeline_card.dart';

class DashboardActionDetailEvidenceSection extends StatelessWidget {
  final DashboardActionDetail detail;
  final DashboardActionEvidenceTimeline timeline;

  const DashboardActionDetailEvidenceSection({
    super.key,
    required this.detail,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardActionEvidenceTimelineCard(timeline: timeline),
        const SizedBox(height: 12),
        _SignalList(signals: detail.signals),
        const SizedBox(height: 12),
        _NextStepCard(detail: detail),
      ],
    );
  }
}

class _SignalList extends StatelessWidget {
  final List<DashboardActionDetailSignal> signals;

  const _SignalList({required this.signals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          signals
              .map(
                (signal) => Padding(
                  padding: EdgeInsets.only(
                    bottom: signal == signals.last ? 0 : 8,
                  ),
                  child: _SignalTile(signal: signal),
                ),
              )
              .toList(),
    );
  }
}

class _SignalTile extends StatelessWidget {
  final DashboardActionDetailSignal signal;

  const _SignalTile({required this.signal});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  signal.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            signal.value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final DashboardActionDetail detail;

  const _NextStepCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_outlined, color: HrisColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended next step',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail.nextStep,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
