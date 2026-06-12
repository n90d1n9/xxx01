import 'package:flutter/material.dart';

import '../models/reservation_qr_expiry_status.dart';
import 'restaurant_inline_notice.dart';

/// Shows recovery guidance when a reservation QR handoff is near expiry.
class RestaurantReservationQrLinkExpiryNotice extends StatelessWidget {
  const RestaurantReservationQrLinkExpiryNotice({
    super.key,
    required this.status,
    this.onRefresh,
  });

  final RestaurantReservationQrExpiryStatus status;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (status.isFresh) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = _styleFor(colors, status.urgency);

    return RestaurantInlineNotice(
      icon: _iconFor(status.urgency),
      title: _titleFor(status.urgency),
      message: _messageFor(status),
      semanticsLabel: '${_titleFor(status.urgency)}. ${_messageFor(status)}',
      trailing: onRefresh == null
          ? null
          : _ReservationQrExpiryRefreshAction(
              foregroundColor: style.foreground,
              onRefresh: onRefresh!,
            ),
      foregroundColor: style.foreground,
      backgroundColor: style.background,
      borderColor: style.foreground.withValues(alpha: .18),
      titleStyle: theme.textTheme.labelLarge?.copyWith(
        color: style.foreground,
        fontWeight: FontWeight.w900,
      ),
      messageStyle: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Renders the compact refresh action shown in QR expiry notices.
class _ReservationQrExpiryRefreshAction extends StatelessWidget {
  const _ReservationQrExpiryRefreshAction({
    required this.foregroundColor,
    required this.onRefresh,
  });

  final Color foregroundColor;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Refresh QR link',
      child: TextButton.icon(
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Refresh'),
        onPressed: onRefresh,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _titleFor(RestaurantReservationQrExpiryUrgency urgency) {
  return switch (urgency) {
    RestaurantReservationQrExpiryUrgency.fresh => 'QR link ready',
    RestaurantReservationQrExpiryUrgency.expiringSoon =>
      'QR link expiring soon',
    RestaurantReservationQrExpiryUrgency.expired => 'QR link expired',
  };
}

String _messageFor(RestaurantReservationQrExpiryStatus status) {
  return switch (status.urgency) {
    RestaurantReservationQrExpiryUrgency.fresh =>
      '${status.label}. Ready for guest scan.',
    RestaurantReservationQrExpiryUrgency.expiringSoon =>
      '${status.label}. Refresh if the guest has not scanned yet.',
    RestaurantReservationQrExpiryUrgency.expired =>
      '${status.label}. Generate a fresh QR link before the guest scans.',
  };
}

IconData _iconFor(RestaurantReservationQrExpiryUrgency urgency) {
  return switch (urgency) {
    RestaurantReservationQrExpiryUrgency.fresh => Icons.qr_code_2_rounded,
    RestaurantReservationQrExpiryUrgency.expiringSoon => Icons.schedule_rounded,
    RestaurantReservationQrExpiryUrgency.expired => Icons.error_outline_rounded,
  };
}

_ExpiryNoticeStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrExpiryUrgency urgency,
) {
  return switch (urgency) {
    RestaurantReservationQrExpiryUrgency.fresh => _ExpiryNoticeStyle(
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrExpiryUrgency.expiringSoon => _ExpiryNoticeStyle(
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrExpiryUrgency.expired => _ExpiryNoticeStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
  };
}

/// Holds visual treatment for a reservation QR expiry notice.
class _ExpiryNoticeStyle {
  const _ExpiryNoticeStyle({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
