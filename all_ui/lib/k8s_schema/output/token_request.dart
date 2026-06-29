class TokenRequest {
  final String audience;
  final int? expirationSeconds;
  TokenRequest({required this.audience, this.expirationSeconds});
  factory TokenRequest.fromJson(Map<String, dynamic> json) {
    return TokenRequest(
      audience: json['audience'],
      expirationSeconds: json['expirationSeconds'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'audience': audience,
      if (expirationSeconds != null) 'expirationSeconds': expirationSeconds,
    };
  }
}
