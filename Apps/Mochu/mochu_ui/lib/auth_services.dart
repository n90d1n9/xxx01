// Previous imports remain the same, but add:
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/spreadsheets',
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Sign in error: $error');
      return null;
    }
  }

  Future<String?> getAccessToken(GoogleSignInAccount account) async {
    try {
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
