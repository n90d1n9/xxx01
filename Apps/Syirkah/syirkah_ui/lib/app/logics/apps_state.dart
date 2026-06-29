import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider for the apps state
final appsState = StateNotifierProvider<AppsNotifier, AppsState>((ref) {
  return AppsNotifier();
});

// Notifier to manage the apps state
class AppsNotifier extends StateNotifier<AppsState> {
  AppsNotifier()
      : super(const AppsState(
            success: false,
            showError: false,
            loading: false,
            errorMessage: '',
            hasErrorInForgotPassword: false,
            hasErrorsInLogin: false));
  atHome(value) {
    state = state.copyWith(atHome: value);
  }

  status(AppsState currentState) {
    state = currentState;
  }
}

@immutable
class AppsState {
  const AppsState({
    this.success = false,
    this.showError = false,
    this.loading = false,
    this.errorMessage = '',
    this.hasErrorInForgotPassword = false,
    this.hasErrorsInLogin = false,
    this.atHome = false,
  });

  final bool atHome;
  final bool success;
  final bool loading;
  final bool showError;
  final String errorMessage;
  final bool hasErrorInForgotPassword;
  final bool hasErrorsInLogin;

  AppsState copyWith(
      {bool? success,
      bool? atHome,
      bool? showError,
      bool? loading,
      String? errorMessage,
      bool? hasErrorInForgotPassword,
      String? confirmPasswordMessage,
      bool? hasErrorsInLogin}) {
    return AppsState(
        success: success ?? this.success,
        atHome: atHome ?? this.atHome,
        showError: showError ?? this.showError,
        loading: loading ?? this.loading,
        errorMessage: errorMessage ?? this.errorMessage,
        hasErrorInForgotPassword:
            hasErrorInForgotPassword ?? this.hasErrorInForgotPassword,
        hasErrorsInLogin: hasErrorsInLogin ?? this.hasErrorsInLogin);
  }
}
