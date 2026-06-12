import '../../models/auth/user.dart';

const Object _unset = Object();

class AuthenticationState {
  final String? username;
  final String? password;
  final bool rememberMe;
  final String? token;
  final User? user;
  final bool loggedIn;
  final String? loginMessage;
  final String? passwordMessage;
  final String? confirmPassword;
  final String? confirmPasswordMessage;
  final bool hasErrorInForgotPassword;
  final bool hasErrorsInLogin;
  final bool isAuthenticated;
  final bool isFirstTime;
  final bool isLoading;
  final String? errorMessage;

  const AuthenticationState({
    this.username,
    this.password,
    this.rememberMe = false,
    this.token,
    this.user,
    this.loggedIn = false,
    this.loginMessage,
    this.passwordMessage,
    this.confirmPassword,
    this.confirmPasswordMessage,
    this.hasErrorInForgotPassword = false,
    this.hasErrorsInLogin = false,
    this.isAuthenticated = false,
    this.isFirstTime = true,
    this.isLoading = true,
    this.errorMessage,
  });

  factory AuthenticationState.initial() => const AuthenticationState();

  AuthenticationState copyWith({
    Object? username = _unset,
    Object? password = _unset,
    bool? rememberMe,
    Object? token = _unset,
    Object? user = _unset,
    bool? loggedIn,
    Object? loginMessage = _unset,
    Object? passwordMessage = _unset,
    Object? confirmPassword = _unset,
    Object? confirmPasswordMessage = _unset,
    bool? hasErrorInForgotPassword,
    bool? hasErrorsInLogin,
    bool? isAuthenticated,
    bool? isFirstTime,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return AuthenticationState(
      username: _copyNullable<String>(username, this.username),
      password: _copyNullable<String>(password, this.password),
      rememberMe: rememberMe ?? this.rememberMe,
      token: _copyNullable<String>(token, this.token),
      user: _copyNullable<User>(user, this.user),
      loggedIn: loggedIn ?? this.loggedIn,
      loginMessage: _copyNullable<String>(loginMessage, this.loginMessage),
      passwordMessage: _copyNullable<String>(
        passwordMessage,
        this.passwordMessage,
      ),
      confirmPassword: _copyNullable<String>(
        confirmPassword,
        this.confirmPassword,
      ),
      confirmPasswordMessage: _copyNullable<String>(
        confirmPasswordMessage,
        this.confirmPasswordMessage,
      ),
      hasErrorInForgotPassword:
          hasErrorInForgotPassword ?? this.hasErrorInForgotPassword,
      hasErrorsInLogin: hasErrorsInLogin ?? this.hasErrorsInLogin,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: _copyNullable<String>(errorMessage, this.errorMessage),
    );
  }
}

T? _copyNullable<T>(Object? value, T? currentValue) {
  if (identical(value, _unset)) return currentValue;
  return value as T?;
}
