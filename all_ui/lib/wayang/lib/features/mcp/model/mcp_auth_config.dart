import 'mcp.dart';

class MCPAuthConfig {
  final MCPAuthType type;
  final String? apiKey;
  final String? username;
  final String? password;
  final String? token;
  final Duration tokenExpiry;
  final Map<String, String> headers;
  final String? oauthEndpoint;

  MCPAuthConfig({
    required this.type,
    this.apiKey,
    this.username,
    this.password,
    this.token,
    this.tokenExpiry = const Duration(hours: 24),
    this.headers = const {},
    this.oauthEndpoint,
  });
}

enum MCPAuthType { none, apiKey, basic, bearer, oauth2, mTLS }

/* 
class MCPAuthConfig {
  final MCPAuthType type;
  final String? apiKey;
  final String? username;
  final String? password;
  final String? token;
  final Duration tokenExpiry;
  final Map<String, String> headers;
  final String? oauthEndpoint;

  MCPAuthConfig({
    required this.type,
    this.apiKey,
    this.username,
    this.password,
    this.token,
    this.tokenExpiry = const Duration(hours: 24),
    this.headers = const {},
    this.oauthEndpoint,
  });
} */
