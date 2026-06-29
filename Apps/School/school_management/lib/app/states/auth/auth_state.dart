import '../../models/auth/user.dart';

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
    String? username,
    String? password,
    bool? rememberMe,
    String? token,
    User? user,
    bool? loggedIn,
    String? loginMessage,
    String? passwordMessage,
    String? confirmPassword,
    String? confirmPasswordMessage,
    bool? hasErrorInForgotPassword,
    bool? hasErrorsInLogin,
    bool? isAuthenticated,
    bool? isFirstTime,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthenticationState(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      token: token ?? this.token,
      user: user ?? this.user,
      loggedIn: loggedIn ?? this.loggedIn,
      loginMessage: loginMessage ?? this.loginMessage,
      passwordMessage: passwordMessage ?? this.passwordMessage,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordMessage:
          confirmPasswordMessage ?? this.confirmPasswordMessage,
      hasErrorInForgotPassword:
          hasErrorInForgotPassword ?? this.hasErrorInForgotPassword,
      hasErrorsInLogin: hasErrorsInLogin ?? this.hasErrorsInLogin,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
