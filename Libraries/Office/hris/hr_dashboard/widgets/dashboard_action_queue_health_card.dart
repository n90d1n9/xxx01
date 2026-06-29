import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_queue_health.dart';
import '../models/dashboard_action_urgency.dart';

class DashboardActionQueueHealthCard extends StatelessWidget {
  final DashboardActionQueueHealth health;
  final ValueChanged<DashboardActionUrgencyTier>? onFocusUrgency;

  const DashboardActionQueueHealthCard({
    super.key,
    required this.health,
    this.onFocusUrgency,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(health.tone);
    final canFocus = health.focusUrgency != null && onFocusUrgency != null;

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final content = _HealthContent(health: health, color: color);
          final action =
              canFocus
                  ? OutlinedButton.icon(
                    onPressed: () => onFocusUrgency!(health.focusUrgency!),
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: Text(health.actionLabel!),
                  )
                  : null;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_iconFor(health.tone), color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    isNarrow || action == null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            content,
                            if (action != null) ...[
                              const SizedBox(height: 12),
                              action,
                            ],
                          ],
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: content),
                            const SizedBox(width: 12),
                            action,
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _colorFor(DashboardActionQueueHealthTone tone) {
    return switch (tone) {
      DashboardActionQueueHealthTone.atRisk => Colors.red,
      DashboardActionQueueHealthTone.active => HrisColors.primary,
      DashboardActionQueueHealthTone.planned => Colors.orange,
      DashboardActionQueueHealthTone.clear => Colors.green,
    };
  }

  IconData _iconFor(DashboardActionQueueHealthTone tone) {
    return switch (tone) {
      DashboardActionQueueHealthTone.atRisk =>
        Icons.notification_important_outlined,
      DashboardActionQueueHealthTone.active => Icons.route_rounded,
      DashboardActionQueueHealthTone.planned => Icons.event_note_outlined,
      DashboardActionQueueHealthTone.clear => Icons.verified_outlined,
    };
  }
}

class _HealthContent extends StatelessWidget {
  final DashboardActionQueueHealth health;
  final Color color;

  const _HealthContent({required this.health, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Queue health',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            HrisStatusPill(label: health.label, color: color),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          health.headline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          health.detail,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}
