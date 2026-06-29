class KafkaAuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final BehaviorSubject<bool> _authStatusController = BehaviorSubject.seeded(
    false,
  );

  Stream<bool> get authStatusStream => _authStatusController.stream;

  // OpenID Connect Authentication
  Future<UserPermissions> authenticateWithOpenID() async {
    try {
      // Discover OpenID configuration
      final discoveryResponse = await http.get(Uri.parse(_discoveryUrl));
      final discoveryDocument = json.decode(discoveryResponse.body);

      // Initiate Authorization Request
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              _clientId,
              _redirectUri,
              issuer: _issuer,
              scopes: ['openid', 'profile', 'email', 'roles'],
              discoveryUrl: _discoveryUrl,
            ),
          );

      if (result == null) {
        throw Exception('Authentication failed');
      }

      // Decode and verify ID Token
      final idToken = result.idToken;
      final decodedToken = await _verifyToken(idToken!);

      // Extract user permissions
      return UserPermissions(
        userId: decodedToken.claims['sub'],
        roles: List<String>.from(decodedToken.claims['roles'] ?? []),
        attributes: {
          'email': decodedToken.claims['email'],
          'name': decodedToken.claims['name'],
          'allowed_clusters': decodedToken.claims['allowed_clusters'] ?? [],
          'allowed_topics': decodedToken.claims['allowed_topics'] ?? [],
        },
      );
    } catch (e) {
      throw Exception('OpenID Connect Authentication Failed: $e');
    }
  }

  // Token Verification
  Future<OpenIdToken> _verifyToken(String token) async {
    final issuer = await Issuer.discover(Uri.parse(_issuer));
    final client = Client(issuer, _clientId);

    return client.validateToken(token);
  }

  // Logout
  Future<void> logout() async {
    await _appAuth.endSession(
      EndSessionRequest(
        issuer: _issuer,
        clientId: _clientId,
        postLogoutRedirectUrl: _redirectUri,
      ),
    );
    await _secureStorage.deleteAll();
  }

  Future<bool> authenticateWithSASL({
    required String username,
    required String password,
    required String mechanism, // PLAIN, SCRAM-SHA-256, etc.
  }) async {
    try {
      // Implement SASL authentication
      final saslConfig = SaslConfig(
        mechanism: mechanism,
        username: username,
        password: password,
      );

      // Store credentials securely
      await _secureStorage.write(key: 'kafka_username', value: username);
      await _secureStorage.write(key: 'kafka_sasl_mechanism', value: mechanism);

      // Generate JWT for additional security
      final jwt = _generateJWT(username);
      await _secureStorage.write(key: 'kafka_auth_token', value: jwt);

      _authStatusController.add(true);
      return true;
    } catch (e) {
      _authStatusController.add(false);
      throw KafkaAuthenticationException(
        message: 'Authentication Failed',
        details: e.toString(),
      );
    }
  }

  String _generateJWT(String username) {
    // Simple JWT generation (replace with proper implementation)
    final payload = {
      'sub': username,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
    };
    // In real-world: use a proper JWT library or backend service
    return ''; // Placeholder for JWT generation
  }

  Future<bool> validateJWT() async {
    final token = await _secureStorage.read(key: 'kafka_auth_token');
    if (token == null) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
    _authStatusController.add(false);
  }
}
