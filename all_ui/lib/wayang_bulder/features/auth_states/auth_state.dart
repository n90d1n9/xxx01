import 'user.dart';

class AuthenticationState {
  final String? username;
  final String? password;
  final String? email;
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
  final String? role;

  const AuthenticationState({
    this.username,
    this.password,
    this.email,
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
    this.role,
  });

  factory AuthenticationState.initial() => const AuthenticationState();

  AuthenticationState copyWith({
    String? username,
    String? password,
    String? email,
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
    String? role,
  }) {
    return AuthenticationState(
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
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
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return '''
username: $username, email: $email, isAuthenticated: $isAuthenticated, isFirsTime: $isFirstTime, rememberMe: $rememberMe, role: $role
''';
  }
}

/* 
@immutable
class AuthenticationState {
  const AuthenticationState(
      {this.username,
      this.password,
      this.rememberMe = false,
      this.user,
      this.hasErrorInForgotPassword = false,
      this.hasErrorsInLogin = false,
      this.token ,
      this.loggedIn = false,
      this.loginMessage,
      this.passwordMessage,
      this.confirmPassword ,
      this.confirmPasswordMessage,
      this.status = const StateStatus()});

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
  final StateStatus status;

  AuthenticationState copyWith(
      {String? username,
      String? password,
      bool? rememberMe,
      String? token,
      User? user,
      bool? loggedIn,
      String? loginMessage,
      String? passwordMessage,
      String? confirmPassword,
      String? confirmPasswordMessage,
      StateStatus? status}) {
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
        status: status ?? this.status);
  }

  @override
  String toString() {
    return 'username: $username';
  }
}
 */
