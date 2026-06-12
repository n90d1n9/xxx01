import '../services/restaurant_reservation_communication_composer.dart';
import 'restaurant_models.dart';
import 'restaurant_reservation.dart';
import 'restaurant_reservation_communication.dart';

/// Describes contact-channel availability for one reservation guest.
class RestaurantReservationContactAvailability {
  const RestaurantReservationContactAvailability({
    required this.reservation,
    required this.channels,
  });

  factory RestaurantReservationContactAvailability.fromReservation(
    RestaurantReservation reservation, {
    RestaurantReservationCommunicationComposer composer =
        const RestaurantReservationCommunicationComposer(),
  }) {
    return RestaurantReservationContactAvailability(
      reservation: reservation,
      channels: composer.availableChannelsFor(reservation),
    );
  }

  final RestaurantReservation reservation;
  final List<RestaurantReservationCommunicationChannel> channels;

  bool get hasChannels => channels.isNotEmpty;

  bool get needsGuestContact => reservation.status.isOpen;

  bool get shouldShowUnavailableNotice => needsGuestContact && !hasChannels;

  String get label {
    if (!needsGuestContact) return 'Contact closed';
    if (hasChannels) return 'Contact ready';
    return 'Missing contact';
  }

  String get detail {
    if (!needsGuestContact) return 'Closed reservation.';
    if (hasChannels) return _channelLabels.join(' / ');
    return 'Add phone or email before guest follow-up.';
  }

  RestaurantServiceStatus get serviceStatus {
    if (!needsGuestContact || hasChannels) return RestaurantServiceStatus.calm;
    if (reservation.needsLateRecovery) return RestaurantServiceStatus.critical;
    return RestaurantServiceStatus.busy;
  }

  List<String> get _channelLabels {
    return channels.map((channel) => channel.label).toList(growable: false);
  }
}
