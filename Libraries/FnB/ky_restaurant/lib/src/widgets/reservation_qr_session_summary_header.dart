import 'package:flutter/material.dart';

import '../models/reservation_qr_session_summary.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';

/// Shows a compact summary of the current reservation QR handoff state.
class RestaurantReservationQrSessionSummaryHeader extends StatelessWidget {
  const RestaurantReservationQrSessionSummaryHeader({
    super.key,
    required this.summary,
  });

  final RestaurantReservationQrSessionSummaryPresentation summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = _styleFor(colors, summary.tone);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: summary.semanticsLabel,
      child: RestaurantSectionSurface(
        backgroundColor: style.background,
        borderColor: style.foreground.withValues(alpha: .18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: _iconFor(summary.tone),
              iconColor: style.foreground,
              title: summary.title,
              subtitle: summary.message,
              titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: style.foreground,
                fontWeight: FontWeight.w900,
              ),
              subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (summary.metrics.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final metric in summary.metrics)
                    RestaurantSignalChip(
                      label: metric.text,
                      foregroundColor: style.foreground,
                      backgroundColor: colors.surface.withValues(alpha: .62),
                      borderColor: style.foreground.withValues(alpha: .16),
                      fontWeight: FontWeight.w800,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

_SessionSummaryStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrSessionSummaryTone tone,
) {
  return switch (tone) {
    RestaurantReservationQrSessionSummaryTone.neutral => _SessionSummaryStyle(
      foreground: colors.onSurfaceVariant,
      background: colors.surfaceContainerHighest.withValues(alpha: .22),
    ),
    RestaurantReservationQrSessionSummaryTone.active => _SessionSummaryStyle(
      foreground: colors.secondary,
      background: colors.secondaryContainer.withValues(alpha: .16),
    ),
    RestaurantReservationQrSessionSummaryTone.success => _SessionSummaryStyle(
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrSessionSummaryTone.warning => _SessionSummaryStyle(
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrSessionSummaryTone.critical => _SessionSummaryStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
  };
}

IconData _iconFor(RestaurantReservationQrSessionSummaryTone tone) {
  return switch (tone) {
    RestaurantReservationQrSessionSummaryTone.neutral =>
      Icons.qr_code_scanner_outlined,
    RestaurantReservationQrSessionSummaryTone.active => Icons.qr_code_2_rounded,
    RestaurantReservationQrSessionSummaryTone.success =>
      Icons.check_circle_outline_rounded,
    RestaurantReservationQrSessionSummaryTone.warning => Icons.schedule_rounded,
    RestaurantReservationQrSessionSummaryTone.critical =>
      Icons.error_outline_rounded,
  };
}

/// Holds visual treatment for one reservation QR session summary.
class _SessionSummaryStyle {
  const _SessionSummaryStyle({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
