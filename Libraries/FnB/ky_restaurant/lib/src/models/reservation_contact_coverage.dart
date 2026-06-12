import '../services/restaurant_reservation_communication_composer.dart';
import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_communication.dart';

/// Summarizes whether open reservation guests can be contacted.
class RestaurantReservationContactCoverageSummary {
  const RestaurantReservationContactCoverageSummary({
    required this.openReservations,
    required this.contactableReservations,
    required this.missingContactReservations,
    required this.channelReservations,
  });

  factory RestaurantReservationContactCoverageSummary.fromReservations(
    Iterable<RestaurantReservation> reservations, {
    RestaurantReservationCommunicationComposer composer =
        const RestaurantReservationCommunicationComposer(),
  }) {
    final openReservations =
        reservations
            .where((reservation) => reservation.status.isOpen)
            .toList(growable: false)
          ..sort(
            (a, b) =>
                a.arrivalMinutesFromNow.compareTo(b.arrivalMinutesFromNow),
          );
    final contactableReservations = <RestaurantReservation>[];
    final missingContactReservations = <RestaurantReservation>[];
    final channelReservations = {
      for (final channel in RestaurantReservationCommunicationChannel.values)
        channel: <RestaurantReservation>[],
    };

    for (final reservation in openReservations) {
      final channels = composer.availableChannelsFor(reservation);
      if (channels.isEmpty) {
        missingContactReservations.add(reservation);
        continue;
      }

      contactableReservations.add(reservation);
      for (final channel in channels) {
        channelReservations[channel]!.add(reservation);
      }
    }

    return RestaurantReservationContactCoverageSummary(
      openReservations: openReservations,
      contactableReservations: contactableReservations,
      missingContactReservations: missingContactReservations,
      channelReservations: channelReservations,
    );
  }

  final List<RestaurantReservation> openReservations;
  final List<RestaurantReservation> contactableReservations;
  final List<RestaurantReservation> missingContactReservations;
  final Map<
    RestaurantReservationCommunicationChannel,
    List<RestaurantReservation>
  >
  channelReservations;

  int get openCount => openReservations.length;

  int get contactableCount => contactableReservations.length;

  int get missingContactCount => missingContactReservations.length;

  bool get hasOpenReservations => openReservations.isNotEmpty;

  bool get hasMissingContacts => missingContactReservations.isNotEmpty;

  String get reachableLabel {
    return '$contactableCount ${contactableCount == 1 ? 'reachable guest' : 'reachable guests'}';
  }

  String get missingContactLabel {
    if (!hasMissingContacts) return 'All contactable';
    return '$missingContactCount missing ${missingContactCount == 1 ? 'contact' : 'contacts'}';
  }

  RestaurantServiceStatus get serviceStatus {
    if (missingContactReservations.any(
      (reservation) => reservation.needsLateRecovery,
    )) {
      return RestaurantServiceStatus.critical;
    }
    if (hasMissingContacts) return RestaurantServiceStatus.busy;
    return RestaurantServiceStatus.calm;
  }

  int channelCount(RestaurantReservationCommunicationChannel channel) {
    return channelReservations[channel]?.length ?? 0;
  }

  String channelLabel(RestaurantReservationCommunicationChannel channel) {
    final count = channelCount(channel);
    return switch (channel) {
      RestaurantReservationCommunicationChannel.phone => '$count phone/SMS',
      RestaurantReservationCommunicationChannel.sms => '$count SMS',
      RestaurantReservationCommunicationChannel.whatsapp => '$count WhatsApp',
      RestaurantReservationCommunicationChannel.email => '$count email',
    };
  }
}
