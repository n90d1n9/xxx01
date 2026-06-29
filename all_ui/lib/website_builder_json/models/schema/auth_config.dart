class AuthConfig {
  final String type; // bearer, basic, apiKey, oauth
  final String? token;
  final String? username;
  final String? password;
  final String? apiKey;
  final String? apiKeyLocation; // header, query

  AuthConfig({
    required this.type,
    this.token,
    this.username,
    this.password,
    this.apiKey,
    this.apiKeyLocation,
  });

  factory AuthConfig.fromJson(Map<String, dynamic> json) {
    return AuthConfig(
      type: json['type'] as String,
      token: json['token'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      apiKey: json['apiKey'] as String?,
      apiKeyLocation: json['apiKeyLocation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (token != null) 'token': token,
    if (username != null) 'username': username,
    if (password != null) 'password': password,
    if (apiKey != null) 'apiKey': apiKey,
    if (apiKeyLocation != null) 'apiKeyLocation': apiKeyLocation,
  };
}
