/// Identifies a channel available for contacting a reservation guest.
enum RestaurantReservationCommunicationChannel {
  phone,
  sms,
  whatsapp,
  email;

  String get label => switch (this) {
    RestaurantReservationCommunicationChannel.phone => 'Call',
    RestaurantReservationCommunicationChannel.sms => 'SMS',
    RestaurantReservationCommunicationChannel.whatsapp => 'WhatsApp',
    RestaurantReservationCommunicationChannel.email => 'Email',
  };
}

/// Carries a prepared guest communication action without launching it.
class RestaurantReservationCommunicationDraft {
  const RestaurantReservationCommunicationDraft({
    required this.reservationId,
    required this.guestName,
    required this.channel,
    required this.target,
    required this.uri,
    this.subject,
    this.body,
  });

  final String reservationId;
  final String guestName;
  final RestaurantReservationCommunicationChannel channel;
  final String target;
  final Uri uri;
  final String? subject;
  final String? body;
}
