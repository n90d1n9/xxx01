import 'package:flutter/material.dart';

import '../models/reservation_status_timeline.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_status_action.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays compact reservation lifecycle progress for a booking.
class RestaurantReservationStatusTimeline extends StatelessWidget {
  const RestaurantReservationStatusTimeline({
    super.key,
    required this.timeline,
    this.title = 'Status path',
  });

  final RestaurantReservationStatusTimelineData timeline;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: timeline.semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route_outlined,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RestaurantProgressBar(
                  value: timeline.progress,
                  status: timeline.currentStatus.serviceStatus,
                  height: 5,
                  semanticLabel: timeline.semanticLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final step in timeline.steps) _TimelineStepChip(step: step),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStepChip extends StatelessWidget {
  const _TimelineStepChip({required this.step});

  final RestaurantReservationStatusTimelineStep step;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = _styleFor(colors, step);

    return RestaurantSignalChip(
      icon: _iconFor(step),
      label: step.label,
      foregroundColor: style.foreground,
      backgroundColor: style.background,
      borderColor: style.border,
      borderRadius: 8,
      fontWeight:
          step.state == RestaurantReservationStatusTimelineStepState.pending
          ? FontWeight.w700
          : FontWeight.w900,
    );
  }
}

_TimelineStepStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationStatusTimelineStep step,
) {
  return switch (step.state) {
    RestaurantReservationStatusTimelineStepState.current => () {
      final statusStyle = restaurantStatusStyle(
        colors,
        step.status.serviceStatus,
      );
      return _TimelineStepStyle(
        foreground: statusStyle.foreground,
        background: statusStyle.background,
        border: statusStyle.foreground.withValues(alpha: .2),
      );
    }(),
    RestaurantReservationStatusTimelineStepState.completed =>
      _TimelineStepStyle(
        foreground: const Color(0xFF13795B),
        background: const Color(0xFFE7F5EE),
        border: const Color(0xFF13795B).withValues(alpha: .18),
      ),
    RestaurantReservationStatusTimelineStepState.pending => _TimelineStepStyle(
      foreground: colors.onSurfaceVariant,
      background: colors.surfaceContainerHighest.withValues(alpha: .28),
      border: colors.outlineVariant.withValues(alpha: .55),
    ),
  };
}

IconData _iconFor(RestaurantReservationStatusTimelineStep step) {
  if (step.state == RestaurantReservationStatusTimelineStepState.completed) {
    return Icons.check_rounded;
  }

  return switch (step.status) {
    RestaurantReservationStatus.requested => Icons.rule_folder_outlined,
    RestaurantReservationStatus.confirmed => Icons.verified_outlined,
    RestaurantReservationStatus.arrived => Icons.login_rounded,
    RestaurantReservationStatus.seated => Icons.event_seat_outlined,
    RestaurantReservationStatus.completed => Icons.done_all_rounded,
    RestaurantReservationStatus.late => Icons.schedule_outlined,
    RestaurantReservationStatus.cancelled => Icons.event_busy_outlined,
    RestaurantReservationStatus.noShow => Icons.person_off_outlined,
  };
}

class _TimelineStepStyle {
  const _TimelineStepStyle({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
