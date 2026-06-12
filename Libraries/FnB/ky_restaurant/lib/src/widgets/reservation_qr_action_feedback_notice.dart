import 'package:flutter/material.dart';

import '../services/reservation_qr_action_feedback_presenter.dart';
import '../services/reservation_qr_action_handler.dart';
import 'restaurant_inline_notice.dart';

/// Shows operator-facing feedback after a reservation QR action is routed.
class RestaurantReservationQrActionFeedbackNotice extends StatelessWidget {
  const RestaurantReservationQrActionFeedbackNotice({
    super.key,
    required this.result,
    this.onDismiss,
    this.presenter = const RestaurantReservationQrActionFeedbackPresenter(),
  });

  final RestaurantReservationQrActionHandlingResult result;
  final VoidCallback? onDismiss;
  final RestaurantReservationQrActionFeedbackPresenter presenter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = _styleFor(colors, result.status);
    final presentation = presenter.build(result);

    return RestaurantInlineNotice(
      icon: style.icon,
      title: presentation.title,
      message: presentation.message,
      semanticsLabel: presentation.semanticsLabel,
      foregroundColor: style.foreground,
      backgroundColor: style.background,
      borderColor: style.foreground.withValues(alpha: .2),
      trailing: onDismiss == null
          ? null
          : IconButton(
              tooltip: 'Dismiss QR action feedback',
              icon: const Icon(Icons.close_rounded),
              visualDensity: VisualDensity.compact,
              color: style.foreground,
              onPressed: onDismiss,
            ),
    );
  }
}

_ActionFeedbackStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrActionHandlingStatus status,
) {
  return switch (status) {
    RestaurantReservationQrActionHandlingStatus.pending => _ActionFeedbackStyle(
      icon: Icons.hourglass_top_rounded,
      foreground: colors.secondary,
      background: colors.secondaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrActionHandlingStatus.handled => _ActionFeedbackStyle(
      icon: Icons.check_circle_outline_rounded,
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrActionHandlingStatus.failed => _ActionFeedbackStyle(
      icon: Icons.error_outline_rounded,
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrActionHandlingStatus.unavailable =>
      _ActionFeedbackStyle(
        icon: Icons.tune_outlined,
        foreground: colors.tertiary,
        background: colors.tertiaryContainer.withValues(alpha: .2),
      ),
    RestaurantReservationQrActionHandlingStatus.notAllowed ||
    RestaurantReservationQrActionHandlingStatus.missingReservationId =>
      _ActionFeedbackStyle(
        icon: Icons.error_outline_rounded,
        foreground: colors.error,
        background: colors.errorContainer.withValues(alpha: .18),
      ),
  };
}

/// Holds visual treatment for one QR action handling outcome.
class _ActionFeedbackStyle {
  const _ActionFeedbackStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
}
