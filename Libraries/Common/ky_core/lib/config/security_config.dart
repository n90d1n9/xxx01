class SecurityConfig {
  final String apiKey;
  final String apiSecret;
  final String tokenKey;
  final String tokenKeyContent;
  final String refreshTokenKey;
  final String isFirstTimeKey;
  final String finishedGuideKey;

  const SecurityConfig({
    this.apiKey = 'accessToken',
    this.apiSecret = 'auth_token_content',
    this.tokenKey = 'accessToken',
    this.tokenKeyContent = 'auth_token_content',
    this.refreshTokenKey = 'refresh_token',
    this.isFirstTimeKey = 'isFirstTime',
    this.finishedGuideKey = 'finishedGuideKey',
  });

  SecurityConfig copyWith({
    String? apiKey,
    String? apiSecret,
    String? tokenKey,
    String? tokenKeyContent,
    String? refreshTokenKey,
    String? isFirstTimeKey,
    String? finishedGuideKey,
  }) {
    return SecurityConfig(
      apiKey: apiKey ?? this.apiKey,
      apiSecret: apiSecret ?? this.apiSecret,
      tokenKey: tokenKey ?? this.tokenKey,
      tokenKeyContent: tokenKeyContent ?? this.tokenKeyContent,
      refreshTokenKey: refreshTokenKey ?? this.refreshTokenKey,
      isFirstTimeKey: isFirstTimeKey ?? this.isFirstTimeKey,
      finishedGuideKey: finishedGuideKey ?? this.finishedGuideKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'apiSecret': apiSecret,
      'tokenKey': tokenKey,
      'tokenKeyContent': tokenKeyContent,
      'refreshTokenKey': refreshTokenKey,
      'isFirstTimeKey': isFirstTimeKey,
      'finishedGuideKey': finishedGuideKey,
    };
  }

  factory SecurityConfig.fromMap(Map<String, dynamic> map) {
    return SecurityConfig(
      apiKey: map['apiKey'] ?? '',
      apiSecret: map['apiSecret'] ?? '',
      tokenKey: map['tokenKey'] ?? '',
      tokenKeyContent: map['tokenKeyContent'] ?? '',
      refreshTokenKey: map['refreshTokenKey'] ?? '',
      isFirstTimeKey: map['isFirstTimeKey'] ?? '',
      finishedGuideKey: map['finishedGuideKey'] ?? '',
    );
  }
}
