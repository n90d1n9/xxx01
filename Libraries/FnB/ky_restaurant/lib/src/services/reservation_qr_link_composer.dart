import 'dart:convert';
import 'dart:math';

import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_link.dart';
import 'reservation_qr_link_builder.dart';
import 'reservation_qr_payload_builder.dart';

/// Supplies the current time when composing reservation QR links.
typedef RestaurantReservationQrClock = DateTime Function();

/// Supplies an opaque token for reservation QR payloads.
typedef RestaurantReservationQrTokenFactory = String Function();

/// Creates URL-safe random tokens for reservation QR payloads.
class RestaurantReservationQrTokenGenerator {
  const RestaurantReservationQrTokenGenerator();

  String generate({int byteLength = 18}) {
    if (byteLength < 1) {
      throw RangeError.range(byteLength, 1, null, 'byteLength');
    }

    final random = Random.secure();
    final bytes = List<int>.generate(
      byteLength,
      (_) => random.nextInt(256),
      growable: false,
    );
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

/// Composes tokenized reservation QR payloads and scan links from intake actions.
class RestaurantReservationQrLinkComposer {
  RestaurantReservationQrLinkComposer({
    RestaurantReservationQrPayloadBuilder? payloadBuilder,
    RestaurantReservationQrLinkBuilder? linkBuilder,
    RestaurantReservationQrClock? clock,
    RestaurantReservationQrTokenFactory? tokenFactory,
    this.defaultLifetime = const Duration(minutes: 15),
  }) : payloadBuilder =
           payloadBuilder ?? const RestaurantReservationQrPayloadBuilder(),
       linkBuilder = linkBuilder ?? const RestaurantReservationQrLinkBuilder(),
       clock = clock ?? DateTime.now,
       tokenFactory =
           tokenFactory ??
           const RestaurantReservationQrTokenGenerator().generate;

  final RestaurantReservationQrPayloadBuilder payloadBuilder;
  final RestaurantReservationQrLinkBuilder linkBuilder;
  final RestaurantReservationQrClock clock;
  final RestaurantReservationQrTokenFactory tokenFactory;
  final Duration defaultLifetime;

  RestaurantReservationQrLink composeForAction({
    required RestaurantReservationIntakeAction action,
    required Uri baseUri,
    Duration? lifetime,
    String? reservationId,
    String? zoneLabel,
    String? tableLabel,
    Map<String, String> queryParameters = const {},
  }) {
    final effectiveLifetime = lifetime ?? defaultLifetime;
    if (effectiveLifetime <= Duration.zero) {
      throw ArgumentError.value(
        effectiveLifetime,
        'lifetime',
        'Reservation QR link lifetime must be positive.',
      );
    }

    final createdAt = clock();
    final payload = payloadBuilder.buildForAction(
      action: action,
      token: tokenFactory(),
      expiresAt: createdAt.add(effectiveLifetime),
      reservationId: reservationId,
      zoneLabel: zoneLabel,
      tableLabel: tableLabel,
    );
    final uri = linkBuilder.buildUri(
      baseUri: baseUri,
      payload: payload,
      queryParameters: queryParameters,
    );

    return RestaurantReservationQrLink(
      action: action,
      payload: payload,
      uri: uri,
      createdAt: createdAt,
    );
  }
}
