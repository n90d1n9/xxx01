import 'package:flutter/material.dart';

import '../models/reservation_contact_coverage.dart';
import '../models/restaurant_reservation_communication.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays contact-channel coverage for open reservation guests.
class RestaurantReservationContactCoverageStrip extends StatelessWidget {
  const RestaurantReservationContactCoverageStrip({
    super.key,
    required this.summary,
    this.title = 'Guest contact',
  });

  final RestaurantReservationContactCoverageSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusStyle = restaurantStatusStyle(colors, summary.serviceStatus);

    return Semantics(
      container: true,
      label: _semanticLabel(title, summary),
      child: RestaurantSectionSurface(
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.contact_phone_outlined,
              title: title,
              trailingLabel: summary.hasOpenReservations
                  ? summary.reachableLabel
                  : 'No open guests',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!summary.hasOpenReservations)
                  RestaurantSignalChip(
                    icon: Icons.task_alt_rounded,
                    label: 'No open reservations',
                    backgroundColor: colors.surface.withValues(alpha: .72),
                  )
                else ...[
                  RestaurantSignalChip(
                    icon: Icons.verified_user_outlined,
                    label: summary.reachableLabel,
                    foregroundColor: colors.primary,
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: .2,
                    ),
                    borderColor: colors.primary.withValues(alpha: .18),
                  ),
                  RestaurantSignalChip(
                    icon: summary.hasMissingContacts
                        ? Icons.report_gmailerrorred_outlined
                        : Icons.check_circle_outline_rounded,
                    label: summary.missingContactLabel,
                    foregroundColor: statusStyle.foreground,
                    backgroundColor: statusStyle.background,
                    borderColor: statusStyle.foreground.withValues(alpha: .18),
                  ),
                  for (final channel in _displayChannels)
                    if (summary.channelCount(channel) > 0)
                      RestaurantSignalChip(
                        icon: _iconForChannel(channel),
                        label: summary.channelLabel(channel),
                        backgroundColor: colors.surface.withValues(alpha: .72),
                      ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _displayChannels = [
  RestaurantReservationCommunicationChannel.phone,
  RestaurantReservationCommunicationChannel.whatsapp,
  RestaurantReservationCommunicationChannel.email,
];

IconData _iconForChannel(RestaurantReservationCommunicationChannel channel) {
  return switch (channel) {
    RestaurantReservationCommunicationChannel.phone => Icons.phone_outlined,
    RestaurantReservationCommunicationChannel.sms => Icons.sms_outlined,
    RestaurantReservationCommunicationChannel.whatsapp =>
      Icons.chat_bubble_outline_rounded,
    RestaurantReservationCommunicationChannel.email => Icons.mail_outline,
  };
}

String _semanticLabel(
  String title,
  RestaurantReservationContactCoverageSummary summary,
) {
  if (!summary.hasOpenReservations) {
    return '$title. No open guests.';
  }

  final channelLabels = _displayChannels
      .where((channel) => summary.channelCount(channel) > 0)
      .map(summary.channelLabel)
      .join(', ');
  return '$title. ${summary.reachableLabel}. '
      '${summary.missingContactLabel}. $channelLabels.';
}
