import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_communication.dart';

/// Builds contact-channel drafts for reservation guest communication.
class RestaurantReservationCommunicationComposer {
  const RestaurantReservationCommunicationComposer();

  List<RestaurantReservationCommunicationChannel> availableChannelsFor(
    RestaurantReservation reservation,
  ) {
    return [
      if (_normalizedPhone(reservation.phoneNumber) != null) ...[
        RestaurantReservationCommunicationChannel.phone,
        RestaurantReservationCommunicationChannel.sms,
        RestaurantReservationCommunicationChannel.whatsapp,
      ],
      if (_normalizedEmail(reservation.emailAddress) != null)
        RestaurantReservationCommunicationChannel.email,
    ];
  }

  RestaurantReservationCommunicationDraft? compose({
    required RestaurantReservation reservation,
    required RestaurantReservationCommunicationChannel channel,
  }) {
    final body = _bodyFor(reservation);

    return switch (channel) {
      RestaurantReservationCommunicationChannel.phone => _phoneDraft(
        reservation,
      ),
      RestaurantReservationCommunicationChannel.sms => _smsDraft(
        reservation,
        body,
      ),
      RestaurantReservationCommunicationChannel.whatsapp => _whatsAppDraft(
        reservation,
        body,
      ),
      RestaurantReservationCommunicationChannel.email => _emailDraft(
        reservation,
        body,
      ),
    };
  }

  RestaurantReservationCommunicationDraft? _phoneDraft(
    RestaurantReservation reservation,
  ) {
    final phone = _normalizedPhone(reservation.phoneNumber);
    if (phone == null) return null;

    return RestaurantReservationCommunicationDraft(
      reservationId: reservation.id,
      guestName: reservation.guestName,
      channel: RestaurantReservationCommunicationChannel.phone,
      target: phone,
      uri: Uri(scheme: 'tel', path: phone),
    );
  }

  RestaurantReservationCommunicationDraft? _smsDraft(
    RestaurantReservation reservation,
    String body,
  ) {
    final phone = _normalizedPhone(reservation.phoneNumber);
    if (phone == null) return null;

    return RestaurantReservationCommunicationDraft(
      reservationId: reservation.id,
      guestName: reservation.guestName,
      channel: RestaurantReservationCommunicationChannel.sms,
      target: phone,
      body: body,
      uri: Uri(scheme: 'sms', path: phone, queryParameters: {'body': body}),
    );
  }

  RestaurantReservationCommunicationDraft? _whatsAppDraft(
    RestaurantReservation reservation,
    String body,
  ) {
    final phone = _normalizedPhone(reservation.phoneNumber);
    if (phone == null) return null;
    final digits = phone.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return null;

    return RestaurantReservationCommunicationDraft(
      reservationId: reservation.id,
      guestName: reservation.guestName,
      channel: RestaurantReservationCommunicationChannel.whatsapp,
      target: phone,
      body: body,
      uri: Uri.https('wa.me', '/$digits', {'text': body}),
    );
  }

  RestaurantReservationCommunicationDraft? _emailDraft(
    RestaurantReservation reservation,
    String body,
  ) {
    final email = _normalizedEmail(reservation.emailAddress);
    if (email == null) return null;
    final subject = 'Reservation ${reservation.timeLabel}';

    return RestaurantReservationCommunicationDraft(
      reservationId: reservation.id,
      guestName: reservation.guestName,
      channel: RestaurantReservationCommunicationChannel.email,
      target: email,
      subject: subject,
      body: body,
      uri: Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': subject, 'body': body},
      ),
    );
  }

  String _bodyFor(RestaurantReservation reservation) {
    return 'Hi ${reservation.guestName}, confirming your '
        '${reservation.timeLabel} reservation for ${reservation.partyLabel} '
        'at ${reservation.seatingLabel}.';
  }
}

String? _normalizedPhone(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final normalized = trimmed.replaceAll(RegExp('[^0-9+]'), '');
  if (normalized.isEmpty) return null;
  return normalized;
}

String? _normalizedEmail(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || !trimmed.contains('@')) {
    return null;
  }
  return trimmed;
}
