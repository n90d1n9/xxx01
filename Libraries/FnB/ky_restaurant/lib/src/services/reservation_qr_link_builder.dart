import 'dart:convert';

import '../models/reservation_qr_payload.dart';
import '../restaurant_routes.dart';
import 'reservation_qr_codec.dart';

/// Creates and resolves reservation QR scan links from encoded payloads.
class RestaurantReservationQrLinkBuilder {
  const RestaurantReservationQrLinkBuilder({
    this.codec = const RestaurantReservationQrCodec(),
    this.path = RestaurantRoutes.reservationQrPath,
    this.payloadParameter = defaultPayloadParameter,
  });

  static const defaultPayloadParameter = 'payload';

  final RestaurantReservationQrCodec codec;
  final String path;
  final String payloadParameter;

  Uri buildUri({
    required Uri baseUri,
    required RestaurantReservationQrPayload payload,
    Map<String, String> queryParameters = const {},
  }) {
    return baseUri.replace(
      path: _joinUriPaths(baseUri.path, path),
      queryParameters: {
        ...baseUri.queryParameters,
        ...queryParameters,
        payloadParameter: _encodeLinkPayload(codec.encode(payload)),
      },
    );
  }

  RestaurantReservationQrPayload decodeUri(Uri uri, {DateTime? now}) {
    final value = uri.queryParameters[payloadParameter];
    if (value == null || value.trim().isEmpty) {
      throw const FormatException('Reservation QR link payload is required.');
    }

    return codec.decode(_decodeLinkPayload(value), now: now);
  }
}

String _joinUriPaths(String basePath, String childPath) {
  final segments = [
    ...basePath.split('/').where((segment) => segment.isNotEmpty),
    ...childPath.split('/').where((segment) => segment.isNotEmpty),
  ];
  return segments.isEmpty ? '/' : '/${segments.join('/')}';
}

String _encodeLinkPayload(String payload) {
  return base64Url.encode(utf8.encode(payload)).replaceAll('=', '');
}

String _decodeLinkPayload(String value) {
  try {
    return utf8.decode(base64Url.decode(base64Url.normalize(value.trim())));
  } on FormatException {
    throw const FormatException('Reservation QR link payload is invalid.');
  }
}
