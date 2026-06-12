import 'package:flutter/material.dart';

import '../models/reservation_qr_expiry_status.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_payload.dart';
import '../models/reservation_qr_presentation.dart';
import '../services/reservation_qr_expiry_status_presenter.dart';
import '../services/reservation_qr_presentation_builder.dart';
import 'reservation_qr_link_expiry_notice.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';

/// Presents a generated reservation QR scan link with compact host actions.
class RestaurantReservationQrLinkCard extends StatelessWidget {
  const RestaurantReservationQrLinkCard({
    super.key,
    required this.payload,
    required this.uri,
    this.title,
    this.onCopyLink,
    this.onOpenLink,
    this.onRefresh,
    this.presentationBuilder =
        const RestaurantReservationQrPresentationBuilder(),
    this.expiryPresenter = const RestaurantReservationQrExpiryStatusPresenter(),
    this.now,
  });

  factory RestaurantReservationQrLinkCard.fromLink({
    Key? key,
    required RestaurantReservationQrLink link,
    String? title,
    ValueChanged<Uri>? onCopyLink,
    ValueChanged<Uri>? onOpenLink,
    VoidCallback? onRefresh,
    RestaurantReservationQrPresentationBuilder presentationBuilder =
        const RestaurantReservationQrPresentationBuilder(),
    RestaurantReservationQrExpiryStatusPresenter expiryPresenter =
        const RestaurantReservationQrExpiryStatusPresenter(),
    DateTime? now,
  }) {
    return RestaurantReservationQrLinkCard(
      key: key,
      payload: link.payload,
      uri: link.uri,
      title: title,
      onCopyLink: onCopyLink,
      onOpenLink: onOpenLink,
      onRefresh: onRefresh,
      presentationBuilder: presentationBuilder,
      expiryPresenter: expiryPresenter,
      now: now,
    );
  }

  final RestaurantReservationQrPayload payload;
  final Uri uri;
  final String? title;
  final ValueChanged<Uri>? onCopyLink;
  final ValueChanged<Uri>? onOpenLink;
  final VoidCallback? onRefresh;
  final RestaurantReservationQrPresentationBuilder presentationBuilder;
  final RestaurantReservationQrExpiryStatusPresenter expiryPresenter;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final link = uri.toString();
    final presentation = presentationBuilder.buildPayload(payload);
    final expiry = expiryPresenter.build(
      expiresAt: payload.expiresAt,
      now: now,
    );
    final style = _styleFor(colors, expiry.urgency);

    return Semantics(
      container: true,
      label:
          '${presentation.title} QR link, ${expiry.label}, '
          '${presentation.expiryLabel}.',
      child: RestaurantSectionSurface(
        borderColor: style.foreground.withValues(alpha: .22),
        backgroundColor: style.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.qr_code_2_outlined,
              iconColor: style.foreground,
              title: title ?? presentation.title,
              subtitle: presentation.subtitle,
              trailing: _ReservationQrLinkActions(
                uri: uri,
                onCopyLink: onCopyLink,
                onOpenLink: onOpenLink,
                onRefresh: onRefresh,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RestaurantSignalChip(
                  label: expiry.label,
                  icon: _iconForExpiry(expiry.urgency),
                  foregroundColor: style.foreground,
                  backgroundColor: style.foreground.withValues(alpha: .09),
                  borderColor: style.foreground.withValues(alpha: .18),
                ),
                for (final item in presentation.metadata)
                  RestaurantSignalChip(
                    label: item.label,
                    icon: _iconForMetadata(item, payload),
                    foregroundColor:
                        item.kind == RestaurantReservationQrMetadataKind.intent
                        ? colors.primary
                        : null,
                    backgroundColor:
                        item.kind == RestaurantReservationQrMetadataKind.intent
                        ? colors.primary.withValues(alpha: .1)
                        : null,
                    borderColor:
                        item.kind == RestaurantReservationQrMetadataKind.intent
                        ? colors.primary.withValues(alpha: .18)
                        : null,
                  ),
              ],
            ),
            if (!expiry.isFresh) ...[
              const SizedBox(height: 12),
              RestaurantReservationQrLinkExpiryNotice(
                status: expiry,
                onRefresh: onRefresh,
              ),
            ],
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: .76),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  link,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Groups icon-only actions for a reservation QR scan link.
class _ReservationQrLinkActions extends StatelessWidget {
  const _ReservationQrLinkActions({
    required this.uri,
    this.onCopyLink,
    this.onOpenLink,
    this.onRefresh,
  });

  final Uri uri;
  final ValueChanged<Uri>? onCopyLink;
  final ValueChanged<Uri>? onOpenLink;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (onCopyLink == null && onOpenLink == null && onRefresh == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 2,
      children: [
        if (onCopyLink != null)
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.copy_rounded),
            visualDensity: VisualDensity.compact,
            onPressed: () => onCopyLink!(uri),
          ),
        if (onOpenLink != null)
          IconButton(
            tooltip: 'Open link',
            icon: const Icon(Icons.open_in_new_rounded),
            visualDensity: VisualDensity.compact,
            onPressed: () => onOpenLink!(uri),
          ),
        if (onRefresh != null)
          IconButton(
            tooltip: 'Refresh link',
            icon: const Icon(Icons.refresh_rounded),
            visualDensity: VisualDensity.compact,
            onPressed: onRefresh,
          ),
      ],
    );
  }
}

_QrLinkCardStyle _styleFor(
  ColorScheme colors,
  RestaurantReservationQrExpiryUrgency urgency,
) {
  return switch (urgency) {
    RestaurantReservationQrExpiryUrgency.fresh => _QrLinkCardStyle(
      foreground: colors.primary,
      background: colors.primaryContainer.withValues(alpha: .18),
    ),
    RestaurantReservationQrExpiryUrgency.expiringSoon => _QrLinkCardStyle(
      foreground: colors.tertiary,
      background: colors.tertiaryContainer.withValues(alpha: .2),
    ),
    RestaurantReservationQrExpiryUrgency.expired => _QrLinkCardStyle(
      foreground: colors.error,
      background: colors.errorContainer.withValues(alpha: .18),
    ),
  };
}

IconData _iconForExpiry(RestaurantReservationQrExpiryUrgency urgency) {
  return switch (urgency) {
    RestaurantReservationQrExpiryUrgency.fresh => Icons.schedule_outlined,
    RestaurantReservationQrExpiryUrgency.expiringSoon => Icons.schedule_rounded,
    RestaurantReservationQrExpiryUrgency.expired => Icons.error_outline_rounded,
  };
}

/// Holds visual treatment for a reservation QR link card state.
class _QrLinkCardStyle {
  const _QrLinkCardStyle({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}

IconData _iconForMetadata(
  RestaurantReservationQrMetadataItem item,
  RestaurantReservationQrPayload payload,
) {
  return switch (item.kind) {
    RestaurantReservationQrMetadataKind.intent => _iconForIntent(
      payload.intent,
    ),
    RestaurantReservationQrMetadataKind.expiry => Icons.schedule_outlined,
    RestaurantReservationQrMetadataKind.zone => Icons.table_restaurant_outlined,
    RestaurantReservationQrMetadataKind.table => Icons.event_seat_outlined,
  };
}

IconData _iconForIntent(RestaurantReservationQrIntent intent) {
  return switch (intent) {
    RestaurantReservationQrIntent.booking => Icons.event_available_outlined,
    RestaurantReservationQrIntent.waitlist => Icons.playlist_add,
    RestaurantReservationQrIntent.checkIn => Icons.login_rounded,
  };
}
