import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import '../services/reservation_qr_selected_action_presenter.dart';
import 'reservation_qr_scan_action_icon_resolver.dart';
import 'restaurant_inline_notice.dart';

/// Highlights the host action selected from a reservation QR scan.
class RestaurantReservationQrSelectedActionNotice extends StatelessWidget {
  const RestaurantReservationQrSelectedActionNotice({
    super.key,
    required this.action,
    this.titlePrefix = 'Selected action',
    this.presenter = const RestaurantReservationQrSelectedActionPresenter(),
    this.iconResolver = const RestaurantReservationQrScanActionIconResolver(),
  });

  final RestaurantReservationQrScanAction action;
  final String titlePrefix;
  final RestaurantReservationQrSelectedActionPresenter presenter;
  final RestaurantReservationQrScanActionIconResolver iconResolver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = colors.primary;
    final presentation = presenter.build(action, titlePrefix: titlePrefix);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: presentation.semanticsLabel,
      child: RestaurantInlineNotice(
        icon: iconResolver.iconFor(
          action,
          variant: RestaurantReservationQrScanActionIconVariant.selectedNotice,
        ),
        title: presentation.title,
        message: presentation.message,
        foregroundColor: foreground,
        backgroundColor: colors.primaryContainer.withValues(alpha: .22),
        borderColor: foreground.withValues(alpha: .18),
        titleStyle: theme.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
        messageStyle: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
