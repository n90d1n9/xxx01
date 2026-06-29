import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

// Mock authentication service
class AuthService {
  Future<User?> login(String email, String password) async {
    // Mock implementation
    print(email);
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: 'user123',
      name: 'Ahmed Ali',
      email: email,
      userType: email.contains('investor') ? 'investor' : 'partner',
      profileImage: 'https://example.com/profile.jpg',
      bio: 'Experienced business developer with Islamic finance expertise',
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Stream<User?> authStateChanges() {
    return Stream.value(null);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

final currentUserProvider = StateProvider<User?>((ref) => null);

// For login functionality
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return LoginController(authService, ref);
    });

class LoginController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Ref _ref;

  LoginController(this._authService, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, password);
      _ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      _ref.read(currentUserProvider.notifier).state = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
