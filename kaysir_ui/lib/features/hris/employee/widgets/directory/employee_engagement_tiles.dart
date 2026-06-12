import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_engagement_models.dart';
import 'employee_engagement_styles.dart';

class EmployeeEngagementSummaryStrip extends StatelessWidget {
  final EmployeeEngagementPlan plan;

  const EmployeeEngagementSummaryStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Status', value: plan.status.label),
        HrisMetricStripItem(
          label: 'Pulse avg',
          value: plan.averagePulseScore.toStringAsFixed(1),
        ),
        HrisMetricStripItem(label: 'Signals', value: '${plan.openSignalCount}'),
        HrisMetricStripItem(
          label: 'Recognition',
          value: '${plan.recognitionCount}',
        ),
      ],
    );
  }
}

class EmployeeEngagementPulseTile extends StatelessWidget {
  final EmployeeEngagementPulse pulse;

  const EmployeeEngagementPulseTile({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final color = employeeEngagementSentimentColor(pulse.sentiment);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMM d').format(pulse.date),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: pulse.sentiment.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          HrisProgressBar(
            value: pulse.scoreRatio,
            color: color,
            label: 'Pulse score ${pulse.score}/5',
          ),
          const SizedBox(height: 8),
          Text(
            pulse.summary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Next: ${pulse.nextStep}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeRetentionSignalTile extends StatelessWidget {
  final EmployeeRetentionSignal signal;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onResolve;

  const EmployeeRetentionSignalTile({
    super.key,
    required this.signal,
    required this.asOfDate,
    required this.onStart,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = signal.isOverdue(asOfDate);
    final color =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeRetentionSignalStatusColor(signal.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: overdue ? 'Overdue' : signal.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.flag_outlined, label: signal.type.label),
              _MetaChip(icon: Icons.person_outline, label: signal.owner),
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: 'Severity ${signal.severity}/5',
                color: signal.severity >= 4 ? const Color(0xFFB91C1C) : null,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: DateFormat('MMM d').format(signal.dueDate),
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed:
                    signal.status == EmployeeRetentionSignalStatus.resolved ||
                            signal.status ==
                                EmployeeRetentionSignalStatus.inProgress
                        ? null
                        : onStart,
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('Start'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed:
                    signal.status == EmployeeRetentionSignalStatus.resolved
                        ? null
                        : onResolve,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Resolve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeRecognitionNoteTile extends StatelessWidget {
  final EmployeeRecognitionNote note;

  const EmployeeRecognitionNoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF7C3AED);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeRecognitionImpactIcon(note.impact),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${note.from} - ${note.impact.label} - ${DateFormat('MMM d').format(note.date)}',
                  overflow: TextOverflow.ellipsis,
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
