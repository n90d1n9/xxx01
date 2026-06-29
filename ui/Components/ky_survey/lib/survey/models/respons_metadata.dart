import 'geolocation.dart';

class ResponseMetadata {
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceType;
  final String? browser;
  final String? os;
  final String? language;
  final GeoLocation? geoLocation;
  final double? completionPercentage;
  final DateTime? lastInteractionAt;

  ResponseMetadata({
    this.ipAddress,
    this.userAgent,
    this.deviceType,
    this.browser,
    this.os,
    this.language,
    this.geoLocation,
    this.completionPercentage,
    this.lastInteractionAt, 
    required this.startTime,
    this.endTime,
    this.duration,
  });
}
