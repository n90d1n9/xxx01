enum SurveyLocationSource { device, manual, imported }

SurveyLocationSource surveyLocationSourceFromJson(Object? value) {
  if (value is SurveyLocationSource) {
    return value;
  }

  if (value is String) {
    for (final source in SurveyLocationSource.values) {
      if (source.name == value) {
        return source;
      }
    }
  }

  return SurveyLocationSource.device;
}

class SurveyLocation {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final DateTime capturedAt;
  final SurveyLocationSource source;
  final bool isMocked;
  final String? provider;

  const SurveyLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
    this.altitudeMeters,
    this.source = SurveyLocationSource.device,
    this.isMocked = false,
    this.provider,
  });

  SurveyLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? altitudeMeters,
    DateTime? capturedAt,
    SurveyLocationSource? source,
    bool? isMocked,
    String? provider,
  }) {
    return SurveyLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      capturedAt: capturedAt ?? this.capturedAt,
      source: source ?? this.source,
      isMocked: isMocked ?? this.isMocked,
      provider: provider ?? this.provider,
    );
  }

  factory SurveyLocation.fromJson(Map<String, dynamic> json) {
    return SurveyLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
      altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      source: surveyLocationSourceFromJson(json['source']),
      isMocked: json['isMocked'] as bool? ?? false,
      provider: json['provider'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'altitudeMeters': altitudeMeters,
      'capturedAt': capturedAt.toIso8601String(),
      'source': source.name,
      'isMocked': isMocked,
      'provider': provider,
    };
  }
}
