import 'package:flutter/material.dart';

import '../models/reservation_intake_action.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Presents reservation intake paths that hosts can launch during service.
class RestaurantReservationIntakeOptions extends StatelessWidget {
  const RestaurantReservationIntakeOptions({
    super.key,
    this.actions = RestaurantReservationIntakeAction.values,
    this.onActionSelected,
  });

  final List<RestaurantReservationIntakeAction> actions;
  final ValueChanged<RestaurantReservationIntakeAction>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    final qrActionCount = actions.where((action) => action.usesQrCode).length;

    return Semantics(
      container: true,
      label:
          'Reservation intake options. '
          '${actions.map((action) => action.label).join(', ')}.',
      child: RestaurantSectionSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.add_task_outlined,
              title: 'Intake options',
              subtitle: 'Create bookings or scan guest arrivals.',
              trailingLabel: qrActionCount == 0
                  ? null
                  : '$qrActionCount QR flows',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  _ReservationIntakeOptionTile(
                    action: action,
                    onSelected: onActionSelected == null
                        ? null
                        : () => onActionSelected!(action),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders one selectable reservation intake path with source-specific styling.
class _ReservationIntakeOptionTile extends StatelessWidget {
  const _ReservationIntakeOptionTile({required this.action, this.onSelected});

  static const _tileWidth = 168.0;
  static const _tileHeight = 108.0;

  final RestaurantReservationIntakeAction action;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isQr = action.usesQrCode;
    final foregroundColor = isQr ? colors.primary : colors.onSurfaceVariant;
    final backgroundColor = isQr
        ? colors.primaryContainer.withValues(alpha: .34)
        : colors.surface.withValues(alpha: .72);
    final borderColor = isQr
        ? colors.primary.withValues(alpha: .22)
        : colors.outlineVariant.withValues(alpha: .55);

    return SizedBox(
      width: _tileWidth,
      height: _tileHeight,
      child: RestaurantInteractiveSurface(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        tooltip: action.detailLabel,
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForAction(action),
                    color: foregroundColor,
                    size: 18,
                  ),
                  const Spacer(),
                  if (isQr) const _ReservationQrBadge(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                action.detailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marks QR-powered reservation intake paths without requiring a QR package.
class _ReservationQrBadge extends StatelessWidget {
  const _ReservationQrBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.primary.withValues(alpha: .18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Text(
          'QR',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

IconData _iconForAction(RestaurantReservationIntakeAction action) {
  return switch (action) {
    RestaurantReservationIntakeAction.manual => Icons.edit_note_outlined,
    RestaurantReservationIntakeAction.phone => Icons.call_outlined,
    RestaurantReservationIntakeAction.online => Icons.language_outlined,
    RestaurantReservationIntakeAction.qrBooking => Icons.qr_code_2_outlined,
    RestaurantReservationIntakeAction.qrWaitlist => Icons.playlist_add,
    RestaurantReservationIntakeAction.qrCheckIn =>
      Icons.qr_code_scanner_outlined,
  };
}
