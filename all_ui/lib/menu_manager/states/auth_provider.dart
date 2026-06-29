import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final StateNotifierProvider<AuthNotifier, AuthState> authProvider =
      StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
}

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? userRole;

  AuthState({this.isAuthenticated = false, this.userId, this.userRole});

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? userRole,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    userId: userId ?? this.userId,
    userRole: userRole ?? this.userRole,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    state = state.copyWith(
      isAuthenticated: isLoggedIn,
      userId: prefs.getString('userId'),
      userRole: prefs.getString('userRole'),
    );
  }

  Future<bool> login(String username, String password) async {
    // Simulate login logic - you'd replace this with actual authentication
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', username);
    await prefs.setString('userRole', 'admin'); // Default role

    state = state.copyWith(
      isAuthenticated: true,
      userId: username,
      userRole: 'admin',
    );
    print('logged   ${state.isAuthenticated}');
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userRole');

    state = AuthState(); // Reset to initial state
  }
}
