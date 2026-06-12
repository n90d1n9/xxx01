import 'package:flutter/material.dart';

import '../models/reservation_contact_availability.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_communication.dart';
import '../services/restaurant_reservation_communication_composer.dart';
import 'restaurant_inline_notice.dart';
import 'restaurant_status_styles.dart';

/// Displays compact guest contact actions for one reservation.
class RestaurantReservationCommunicationBar extends StatelessWidget {
  const RestaurantReservationCommunicationBar({
    super.key,
    required this.reservation,
    required this.onDraftSelected,
    this.channels,
    this.composer = const RestaurantReservationCommunicationComposer(),
    this.showUnavailableNotice = true,
  });

  final RestaurantReservation reservation;
  final ValueChanged<RestaurantReservationCommunicationDraft> onDraftSelected;
  final List<RestaurantReservationCommunicationChannel>? channels;
  final RestaurantReservationCommunicationComposer composer;
  final bool showUnavailableNotice;

  @override
  Widget build(BuildContext context) {
    final availability =
        RestaurantReservationContactAvailability.fromReservation(
          reservation,
          composer: composer,
        );
    final availableChannels = (channels ?? availability.channels)
        .where((channel) {
          return composer.compose(reservation: reservation, channel: channel) !=
              null;
        })
        .toList(growable: false);
    if (availableChannels.isEmpty) {
      if (!showUnavailableNotice || !availability.shouldShowUnavailableNotice) {
        return const SizedBox.shrink();
      }
      return _ReservationContactUnavailableNotice(availability: availability);
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final channel in availableChannels)
          _ReservationCommunicationButton(
            channel: channel,
            onPressed: () {
              final draft = composer.compose(
                reservation: reservation,
                channel: channel,
              );
              if (draft != null) onDraftSelected(draft);
            },
          ),
      ],
    );
  }
}

/// Shows why reservation communication actions are unavailable.
class _ReservationContactUnavailableNotice extends StatelessWidget {
  const _ReservationContactUnavailableNotice({required this.availability});

  final RestaurantReservationContactAvailability availability;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = restaurantStatusStyle(colors, availability.serviceStatus);

    return RestaurantInlineNotice(
      icon: Icons.contact_phone_outlined,
      title: availability.label,
      message: availability.detail,
      foregroundColor: style.foreground,
      backgroundColor: style.background,
      borderColor: style.foreground.withValues(alpha: .18),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    );
  }
}

/// Renders one compact reservation communication action.
class _ReservationCommunicationButton extends StatelessWidget {
  const _ReservationCommunicationButton({
    required this.channel,
    required this.onPressed,
  });

  final RestaurantReservationCommunicationChannel channel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton.outlined(
      tooltip: channel.label,
      icon: Icon(_iconFor(channel)),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: colors.primaryContainer.withValues(alpha: .12),
        side: BorderSide(color: colors.primary.withValues(alpha: .22)),
      ),
      onPressed: onPressed,
    );
  }
}

IconData _iconFor(RestaurantReservationCommunicationChannel channel) {
  return switch (channel) {
    RestaurantReservationCommunicationChannel.phone => Icons.call_outlined,
    RestaurantReservationCommunicationChannel.sms => Icons.sms_outlined,
    RestaurantReservationCommunicationChannel.whatsapp =>
      Icons.chat_bubble_outline_rounded,
    RestaurantReservationCommunicationChannel.email => Icons.mail_outline,
  };
}
