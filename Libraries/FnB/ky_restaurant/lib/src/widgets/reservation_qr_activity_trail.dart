import 'package:flutter/material.dart';

import '../models/reservation_qr_activity_trail_presentation.dart';
import '../models/reservation_qr_session_activity.dart';
import '../services/reservation_qr_activity_trail_presenter.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_spaced_list.dart';

/// Shows the latest operator-visible events from a reservation QR session.
class RestaurantReservationQrActivityTrail extends StatelessWidget {
  const RestaurantReservationQrActivityTrail({
    super.key,
    required this.activities,
    this.title = 'Recent QR activity',
    this.maxVisible = 4,
    this.presenter = const RestaurantReservationQrActivityTrailPresenter(),
  }) : assert(maxVisible > 0, 'maxVisible must be greater than zero.');

  final List<RestaurantReservationQrSessionActivity> activities;
  final String title;
  final int maxVisible;
  final RestaurantReservationQrActivityTrailPresenter presenter;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final visibleActivities = presenter.buildVisible(
      activities: activities,
      maxVisible: maxVisible,
    );

    return RestaurantSectionSurface(
      backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .18),
      borderColor: colors.outlineVariant.withValues(alpha: .5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            icon: Icons.history_rounded,
            title: title,
            subtitle: 'Latest QR handoff events for this session.',
            trailingLabel: '${visibleActivities.length} shown',
          ),
          const SizedBox(height: 12),
          RestaurantSpacedList<
            RestaurantReservationQrActivityTrailItemPresentation
          >(
            items: visibleActivities,
            spacing: 10,
            itemBuilder: (context, presentation, index) {
              return _ReservationQrActivityTrailItem(
                presentation: presentation,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Renders one compact row in the reservation QR activity trail.
class _ReservationQrActivityTrailItem extends StatelessWidget {
  const _ReservationQrActivityTrailItem({required this.presentation});

  final RestaurantReservationQrActivityTrailItemPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = _styleFor(colors, presentation.tone);
    final detail = presentation.detail;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: presentation.semanticsLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(presentation.kind), size: 18, color: style.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  presentation.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          RestaurantSignalChip(
            label: presentation.timeLabel,
            foregroundColor: style.foreground,
            backgroundColor: style.background,
            borderColor: style.foreground.withValues(alpha: .18),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ],
      ),
    );
  }
}

_ActivityTrailStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrSessionActivityTone tone,
) {
  return switch (tone) {
    RestaurantReservationQrSessionActivityTone.neutral => _ActivityTrailStyle(
      foreground: colors.onSurfaceVariant,
      background: colors.surfaceContainerHighest.withValues(alpha: .45),
    ),
    RestaurantReservationQrSessionActivityTone.success => _ActivityTrailStyle(
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrSessionActivityTone.warning => _ActivityTrailStyle(
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrSessionActivityTone.critical => _ActivityTrailStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
  };
}

IconData _iconFor(RestaurantReservationQrSessionActivityKind kind) {
  return switch (kind) {
    RestaurantReservationQrSessionActivityKind.linkGenerated =>
      Icons.qr_code_2_rounded,
    RestaurantReservationQrSessionActivityKind.linkRefreshed =>
      Icons.refresh_rounded,
    RestaurantReservationQrSessionActivityKind.scanResolved =>
      Icons.qr_code_scanner_rounded,
    RestaurantReservationQrSessionActivityKind.actionSelected =>
      Icons.touch_app_outlined,
    RestaurantReservationQrSessionActivityKind.actionHandled =>
      Icons.check_circle_outline_rounded,
    RestaurantReservationQrSessionActivityKind.scanCleared =>
      Icons.close_rounded,
    RestaurantReservationQrSessionActivityKind.linkCleared =>
      Icons.link_off_rounded,
    RestaurantReservationQrSessionActivityKind.sessionReset =>
      Icons.restart_alt_rounded,
  };
}

/// Holds colors for one reservation QR activity trail row.
class _ActivityTrailStyle {
  const _ActivityTrailStyle({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
