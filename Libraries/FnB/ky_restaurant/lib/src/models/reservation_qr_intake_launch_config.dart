/// Carries routing and context used when launching a reservation QR intake flow.
class RestaurantReservationQrIntakeLaunchConfig {
  const RestaurantReservationQrIntakeLaunchConfig({
    required this.baseUri,
    this.lifetime,
    this.reservationId,
    this.zoneLabel,
    this.tableLabel,
    this.queryParameters = const {},
  });

  final Uri baseUri;
  final Duration? lifetime;
  final String? reservationId;
  final String? zoneLabel;
  final String? tableLabel;
  final Map<String, String> queryParameters;

  RestaurantReservationQrIntakeLaunchConfig copyWith({
    Uri? baseUri,
    Duration? lifetime,
    String? reservationId,
    String? zoneLabel,
    String? tableLabel,
    Map<String, String>? queryParameters,
  }) {
    return RestaurantReservationQrIntakeLaunchConfig(
      baseUri: baseUri ?? this.baseUri,
      lifetime: lifetime ?? this.lifetime,
      reservationId: reservationId ?? this.reservationId,
      zoneLabel: zoneLabel ?? this.zoneLabel,
      tableLabel: tableLabel ?? this.tableLabel,
      queryParameters: queryParameters ?? this.queryParameters,
    );
  }
}
