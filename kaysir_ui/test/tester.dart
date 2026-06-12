import 'package:kaysir/services/network/openid_service.dart';

/* 

curl "http://localhost:8180/realms/quarkus-app/protocol/openid-connect/token" \
  -d "client_id=quarkus-app-client" \
  -d "client_secret=quarkus-app-secret" \
  -d "username=myuser" \
  -d "password=myuser" \
  -d "grant_type=password"
 */
void main() async {
  final openidService = OpenidService(
    baseUrl: 'http://localhost:8180',
    realm: 'quarkus-app',
    clientId: 'quarkus-app-client',
    clientSecret: 'quarkus-app-secret',
  );

  try {
    // Login
    final tokens = await openidService.login('myuser', 'myuser');
    print('Access token: ${tokens['access_token']}');
    print('Refresh token: ${tokens['refresh_token']}');
    final accessToken = tokens['access_token'];
    final refreshToken = tokens['refresh_token'];

    // Get user info
    final userInfo = await openidService.getUserInfo(accessToken);
    print('User info: $userInfo');

    // Refresh token when needed
    final newTokens = await openidService.refreshToken(refreshToken);

    // Logout
    await openidService.logout(refreshToken);
  } catch (e) {
    print('Authentication error: $e');
  }
}
