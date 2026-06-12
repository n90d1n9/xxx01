import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_guidance.dart';
import 'restaurant_inline_notice.dart';

/// Renders a host-facing next step for a resolved reservation QR scan.
class RestaurantReservationQrScanGuidanceNotice extends StatelessWidget {
  const RestaurantReservationQrScanGuidanceNotice({
    super.key,
    required this.guidance,
  });

  final RestaurantReservationQrScanGuidance guidance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = _styleFor(colors, guidance.tone);

    return RestaurantInlineNotice(
      icon: style.icon,
      title: guidance.title,
      message: guidance.message,
      foregroundColor: style.foreground,
      backgroundColor: style.background,
      borderColor: style.foreground.withValues(alpha: .18),
    );
  }
}

_ScanGuidanceStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrScanGuidanceTone tone,
) {
  return switch (tone) {
    RestaurantReservationQrScanGuidanceTone.success => _ScanGuidanceStyle(
      icon: Icons.check_circle_outline_rounded,
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .16),
    ),
    RestaurantReservationQrScanGuidanceTone.warning => _ScanGuidanceStyle(
      icon: Icons.refresh_rounded,
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrScanGuidanceTone.critical => _ScanGuidanceStyle(
      icon: Icons.error_outline_rounded,
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .16),
    ),
  };
}

/// Holds presentation treatment for one QR scan guidance tone.
class _ScanGuidanceStyle {
  const _ScanGuidanceStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}
