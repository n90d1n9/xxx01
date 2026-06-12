/// Describes what a reservation QR code should do when scanned.
enum RestaurantReservationQrIntent {
  booking,
  waitlist,
  checkIn;

  String get label => switch (this) {
    RestaurantReservationQrIntent.booking => 'Create booking',
    RestaurantReservationQrIntent.waitlist => 'Join waitlist',
    RestaurantReservationQrIntent.checkIn => 'Check in',
  };
}

/// Carries the non-PII reservation QR token and routing context.
class RestaurantReservationQrPayload {
  const RestaurantReservationQrPayload({
    required this.token,
    required this.intent,
    required this.expiresAt,
    this.reservationId,
    this.zoneLabel,
    this.tableLabel,
  });

  static const int currentVersion = 1;

  factory RestaurantReservationQrPayload.fromJson(Map<String, Object?> json) {
    final token = json['token'];
    final intentName = json['intent'];
    final expiresAtValue = json['expiresAt'];

    if (token is! String || token.trim().isEmpty) {
      throw const FormatException('Reservation QR token is required.');
    }
    if (intentName is! String) {
      throw const FormatException('Reservation QR intent is required.');
    }
    if (expiresAtValue is! String) {
      throw const FormatException('Reservation QR expiry is required.');
    }

    final intent = RestaurantReservationQrIntent.values.firstWhere(
      (value) => value.name == intentName,
      orElse: () {
        throw FormatException('Unsupported reservation QR intent: $intentName');
      },
    );
    final expiresAt = DateTime.tryParse(expiresAtValue);
    if (expiresAt == null) {
      throw const FormatException('Reservation QR expiry is invalid.');
    }

    return RestaurantReservationQrPayload(
      token: token.trim(),
      intent: intent,
      expiresAt: expiresAt,
      reservationId: _nullableString(json['reservationId']),
      zoneLabel: _nullableString(json['zoneLabel']),
      tableLabel: _nullableString(json['tableLabel']),
    );
  }

  final String token;
  final RestaurantReservationQrIntent intent;
  final DateTime expiresAt;
  final String? reservationId;
  final String? zoneLabel;
  final String? tableLabel;

  bool isExpiredAt(DateTime now) => !expiresAt.isAfter(now);

  Map<String, Object?> toJson() {
    return {
      'version': currentVersion,
      'token': token,
      'intent': intent.name,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      if (reservationId != null) 'reservationId': reservationId,
      if (zoneLabel != null) 'zoneLabel': zoneLabel,
      if (tableLabel != null) 'tableLabel': tableLabel,
    };
  }
}

String? _nullableString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
