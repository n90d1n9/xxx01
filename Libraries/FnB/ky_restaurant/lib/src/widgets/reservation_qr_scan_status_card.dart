import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_guidance.dart';
import '../models/reservation_qr_scan_result.dart';
import '../services/reservation_qr_presentation_builder.dart';
import '../services/reservation_qr_scan_action_planner.dart';
import 'reservation_qr_scan_action_bar.dart';
import 'reservation_qr_scan_context_strip.dart';
import 'reservation_qr_scan_guidance_notice.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Presents the outcome of a scanned reservation QR link with recovery actions.
class RestaurantReservationQrScanStatusCard extends StatelessWidget {
  const RestaurantReservationQrScanStatusCard({
    super.key,
    required this.result,
    this.title,
    this.actionPlan,
    this.onActionSelected,
    this.onContinue,
    this.onRefresh,
    this.onDismiss,
    this.presentationBuilder =
        const RestaurantReservationQrPresentationBuilder(),
  });

  final RestaurantReservationQrScanResult result;
  final String? title;
  final RestaurantReservationQrScanActionPlan? actionPlan;
  final ValueChanged<RestaurantReservationQrScanAction>? onActionSelected;
  final VoidCallback? onContinue;
  final VoidCallback? onRefresh;
  final VoidCallback? onDismiss;
  final RestaurantReservationQrPresentationBuilder presentationBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = _styleFor(colors, result.status);
    final presentation = presentationBuilder.buildScan(result);
    final plan =
        actionPlan ??
        const RestaurantReservationQrScanActionPlanner().planFor(result);
    final guidance = RestaurantReservationQrScanGuidance.fromScan(
      result: result,
      actionPlan: plan,
    );
    final actionBar = RestaurantReservationQrScanActionBar(
      plan: plan,
      onActionSelected: onActionSelected,
      onContinue: onContinue,
      onRefresh: onRefresh,
      onDismiss: onDismiss,
    );

    return Semantics(
      container: true,
      label: '${presentation.statusLabel}. ${presentation.detailLabel}',
      child: RestaurantSectionSurface(
        borderColor: style.foreground.withValues(alpha: .2),
        backgroundColor: style.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: _iconForStatus(result.status),
              iconColor: style.foreground,
              title: title ?? presentation.statusLabel,
              subtitle: presentation.detailLabel,
              titleStyle: theme.textTheme.labelLarge?.copyWith(
                color: style.foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (actionBar.hasSelectableActions) ...[
              const SizedBox(height: 12),
              actionBar,
            ],
            const SizedBox(height: 12),
            RestaurantReservationQrScanGuidanceNotice(guidance: guidance),
            const SizedBox(height: 12),
            RestaurantReservationQrScanContextStrip(
              result: result,
              statusForegroundColor: style.foreground,
              statusBackgroundColor: style.foreground.withValues(alpha: .1),
              statusBorderColor: style.foreground.withValues(alpha: .18),
            ),
          ],
        ),
      ),
    );
  }
}

_ScanStatusStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrScanStatus status,
) {
  return switch (status) {
    RestaurantReservationQrScanStatus.valid => _ScanStatusStyle(
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrScanStatus.expired => _ScanStatusStyle(
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .22),
    ),
    RestaurantReservationQrScanStatus.invalid => _ScanStatusStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
  };
}

IconData _iconForStatus(RestaurantReservationQrScanStatus status) {
  return switch (status) {
    RestaurantReservationQrScanStatus.valid => Icons.verified_outlined,
    RestaurantReservationQrScanStatus.expired =>
      Icons.history_toggle_off_outlined,
    RestaurantReservationQrScanStatus.invalid => Icons.error_outline_rounded,
  };
}

/// Holds the foreground and background colors for one QR scan state.
class _ScanStatusStyle {
  const _ScanStatusStyle({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}
