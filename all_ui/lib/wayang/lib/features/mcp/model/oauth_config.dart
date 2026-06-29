import 'oauth_grant.dart';

class MCPOAuth2Config {
  final String clientId;
  final String clientSecret;
  final List<String> allowedScopes;
  final String? tokenEndpoint;
  final String? authorizationEndpoint;
  final Duration tokenExpiry;
  final bool requireConsent;
  final List<MCPOAuth2Grant> grantTypes;

  MCPOAuth2Config({
    required this.clientId,
    required this.clientSecret,
    required this.allowedScopes,
    this.tokenEndpoint,
    this.authorizationEndpoint,
    this.tokenExpiry = const Duration(hours: 1),
    this.requireConsent = true,
    this.grantTypes = const [MCPOAuth2Grant.authorizationCode],
  });
}
