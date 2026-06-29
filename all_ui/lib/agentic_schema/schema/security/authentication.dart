enum AuthenticationType {
  none,
  basic,
  bearer,
  apiKey,
  oauth2,
  jwt,
  certificate,
  custom,
}

class Authentication {
  final AuthenticationType type;
  final Map<String, dynamic>? credentials;

  Authentication({required this.type, this.credentials});

  factory Authentication.fromJson(Map<String, dynamic> json) {
    return Authentication(
      type: _parseAuthenticationType(json['type']),
      credentials: json['credentials'] != null
          ? Map<String, dynamic>.from(json['credentials'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (credentials != null) 'credentials': credentials,
    };
  }

  static AuthenticationType _parseAuthenticationType(dynamic value) {
    if (value is AuthenticationType) return value;
    final stringValue = value.toString();
    return AuthenticationType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => AuthenticationType.none,
    );
  }
}
