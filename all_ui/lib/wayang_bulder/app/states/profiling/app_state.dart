class AppState {
  final bool hasFinishedGuide;
  final Position position;
  final bool hasOnboarding;

  AppState({
    required this.hasFinishedGuide,
    Position? position,
    required this.hasOnboarding,
  }) : position = position ??
            Position(
              latitude: -6.2088,
              longitude: 106.8456,
              city: 'South Jakarta',
            );

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      hasFinishedGuide: json['hasFinishedGuide'] as bool,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      hasOnboarding: json['hasOnboarding'] as bool,
    );
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(
      hasFinishedGuide: map['hasFinishedGuide'] as bool,
      position: Position.fromMap(map['position'] as Map<String, dynamic>),
      hasOnboarding: map['hasOnboarding'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasFinishedGuide': hasFinishedGuide,
      'position': position.toJson(),
      'hasOnboarding': hasOnboarding,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'hasFinishedGuide': hasFinishedGuide,
      'position': position.toMap(),
      'hasOnboarding': hasOnboarding,
    };
  }

  @override
  String toString() {
    return 'AppState(hasFinishedGuide: $hasFinishedGuide, position: $position, hasOnboarding: $hasOnboarding)';
  }

  AppState copyWith({
    bool? hasFinishedGuide,
    Position? position,
    bool? hasOnboarding,
  }) {
    return AppState(
      hasFinishedGuide: hasFinishedGuide ?? this.hasFinishedGuide,
      position: position ?? this.position,
      hasOnboarding: hasOnboarding ?? this.hasOnboarding,
    );
  }
}

class Position {
  final double latitude;
  final double longitude;
  final String city;

  Position(
      {required this.latitude, required this.longitude, required this.city});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      city: json['city'] as String,
    );
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      city: map['city'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
    };
  }

  @override
  String toString() {
    return 'Position(latitude: $latitude, longitude: $longitude, city: $city)';
  }

  Position copyWith({
    double? latitude,
    double? longitude,
    String? city,
  }) {
    return Position(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
    );
  }
}
