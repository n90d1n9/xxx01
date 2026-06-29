import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_evidence_timeline.dart';

class DashboardActionEvidenceTimelineCard extends StatelessWidget {
  final DashboardActionEvidenceTimeline timeline;

  const DashboardActionEvidenceTimelineCard({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    if (timeline.events.isEmpty) {
      return const SizedBox.shrink();
    }

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_outlined, color: HrisColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Evidence timeline',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${timeline.events.length} checkpoints',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (index, event) in timeline.events.indexed)
            _EvidenceTimelineTile(
              event: event,
              isLast: index == timeline.events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _EvidenceTimelineTile extends StatelessWidget {
  final DashboardActionEvidenceEvent event;
  final bool isLast;

  const _EvidenceTimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(event.state);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Icon(_iconFor(event.state), color: color, size: 17),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: HrisColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 62),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    event.state == DashboardActionEvidenceState.current
                        ? color.withValues(alpha: 0.06)
                        : HrisColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      event.state == DashboardActionEvidenceState.current
                          ? color.withValues(alpha: 0.24)
                          : HrisColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _EvidenceStatePill(state: event.state, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(DashboardActionEvidenceState state) {
    return switch (state) {
      DashboardActionEvidenceState.complete => Colors.green,
      DashboardActionEvidenceState.current => HrisColors.primary,
      DashboardActionEvidenceState.next => Colors.orange,
    };
  }

  IconData _iconFor(DashboardActionEvidenceState state) {
    return switch (state) {
      DashboardActionEvidenceState.complete => Icons.check_rounded,
      DashboardActionEvidenceState.current => Icons.radio_button_checked,
      DashboardActionEvidenceState.next => Icons.schedule_rounded,
    };
  }
}

class _EvidenceStatePill extends StatelessWidget {
  final DashboardActionEvidenceState state;
  final Color color;

  const _EvidenceStatePill({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelFor(state),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _labelFor(DashboardActionEvidenceState state) {
    return switch (state) {
      DashboardActionEvidenceState.complete => 'Complete',
      DashboardActionEvidenceState.current => 'Current',
      DashboardActionEvidenceState.next => 'Next',
    };
  }
}
