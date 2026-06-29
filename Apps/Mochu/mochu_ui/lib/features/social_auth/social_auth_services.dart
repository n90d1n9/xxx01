import 'package:google_sign_in/google_sign_in.dart';

import '../../core/network/rest/network_services.dart';
import '../auth/models/auth_token.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn;

  SocialAuthService(this._googleSignIn);

  Future<AuthTokens> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in cancelled';

      final googleAuth = await googleUser.authentication;
      final response = await NetworkService.post(
        '/auth/social/google',
        data: {'id_token': googleAuth.idToken},
      );

      return AuthTokens(
        accessToken: response.data['access_token'],
        refreshToken: response.data['refresh_token'],
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    } catch (e) {
      throw 'Google sign in failed';
    }
  }
}
