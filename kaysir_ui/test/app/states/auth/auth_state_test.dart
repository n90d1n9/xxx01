import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/models/auth/user.dart';
import 'package:kaysir/app/states/auth/auth_state.dart';

void main() {
  test('copyWith preserves and updates lifecycle flags', () {
    final state = AuthenticationState.initial().copyWith(
      isAuthenticated: true,
      isFirstTime: false,
      isLoading: false,
      loggedIn: true,
    );

    expect(state.isAuthenticated, isTrue);
    expect(state.isFirstTime, isFalse);
    expect(state.isLoading, isFalse);
    expect(state.loggedIn, isTrue);
  });

  test('copyWith can clear nullable auth fields', () {
    const user = User(id: 1, username: 'cashier');
    const state = AuthenticationState(
      username: 'cashier',
      password: 'secret',
      token: 'token',
      user: user,
      loginMessage: 'Invalid credentials',
      passwordMessage: 'empty',
      confirmPassword: 'secret',
      confirmPasswordMessage: 'match',
      errorMessage: 'network',
    );

    final cleared = state.copyWith(
      username: null,
      password: null,
      token: null,
      user: null,
      loginMessage: null,
      passwordMessage: null,
      confirmPassword: null,
      confirmPasswordMessage: null,
      errorMessage: null,
    );

    expect(cleared.username, isNull);
    expect(cleared.password, isNull);
    expect(cleared.token, isNull);
    expect(cleared.user, isNull);
    expect(cleared.loginMessage, isNull);
    expect(cleared.passwordMessage, isNull);
    expect(cleared.confirmPassword, isNull);
    expect(cleared.confirmPasswordMessage, isNull);
    expect(cleared.errorMessage, isNull);
  });
}
