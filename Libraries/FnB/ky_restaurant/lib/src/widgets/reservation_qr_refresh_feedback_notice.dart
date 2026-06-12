import 'package:flutter/material.dart';

import '../models/reservation_qr_link.dart';
import '../services/reservation_qr_refresh_feedback_presenter.dart';
import 'restaurant_inline_notice.dart';

/// Shows immediate confirmation after a reservation QR handoff is refreshed.
class RestaurantReservationQrRefreshFeedbackNotice extends StatelessWidget {
  const RestaurantReservationQrRefreshFeedbackNotice({
    super.key,
    required this.link,
    this.onDismiss,
    this.presenter = const RestaurantReservationQrRefreshFeedbackPresenter(),
  });

  final RestaurantReservationQrLink link;
  final VoidCallback? onDismiss;
  final RestaurantReservationQrRefreshFeedbackPresenter presenter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = colors.primary;
    final presentation = presenter.build(link);

    return RestaurantInlineNotice(
      icon: Icons.refresh_rounded,
      title: presentation.title,
      message: presentation.message,
      semanticsLabel: presentation.semanticsLabel,
      foregroundColor: foreground,
      backgroundColor: colors.primaryContainer.withValues(alpha: .18),
      borderColor: foreground.withValues(alpha: .2),
      titleStyle: theme.textTheme.labelLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w900,
      ),
      messageStyle: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      trailing: onDismiss == null
          ? null
          : IconButton(
              tooltip: 'Dismiss QR refresh feedback',
              icon: const Icon(Icons.close_rounded),
              visualDensity: VisualDensity.compact,
              color: foreground,
              onPressed: onDismiss,
            ),
    );
  }
}
