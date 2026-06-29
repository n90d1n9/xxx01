import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final formViewModelProvider =
    StateNotifierProvider<FormViewModel, FormState>((ref) {
  return FormViewModel();
});

class FormState {
  final String name;
  final String email;
  final FormStatus? status;

  FormState({
    this.name = '',
    this.email = '',
    this.status,
  });

  FormState copyWith({
    String? name,
    String? email,
    FormStatus? status,
  }) {
    return FormState(
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }
}

class FormStatus {
  final bool isCleared;
  final bool isMoved;
  final bool isPending;
  final bool isCancel;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  FormStatus({
    this.isCleared = false,
    this.isMoved = false,
    this.isPending = false,
    this.isCancel = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  FormStatus copyWith({
    bool? isCleared,
    bool? isMoved,
    bool? isPending,
    bool? isCancel,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return FormStatus(
      isCleared: isCleared ?? this.isCleared,
      isMoved: isMoved ?? this.isMoved,
      isPending: isPending ?? this.isPending,
      isCancel: isCancel ?? this.isCancel,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage,
    );
  }
}

class FormViewModel extends StateNotifier<FormState> {
  FormViewModel() : super(FormState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  Future<void> submitForm() async {
    state =
        state.copyWith(status: FormStatus(isLoading: true, errorMessage: null));

    try {
      final response = await Dio().post(
        'https://example.com/api/submit',
        data: {
          'name': state.name,
          'email': state.email,
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        state = state.copyWith(
            status: FormStatus(isLoading: false, errorMessage: null));
      } else {
        // Handle failure
        state = state.copyWith(
            status: FormStatus(
                isLoading: false, errorMessage: 'Submission failed'));
      }
    } catch (e) {
      state = state.copyWith(
          status: FormStatus(
              isLoading: false, errorMessage: 'An error occurred: $e'));
    }
  }
}

// Define your API endpoint
const String apiEndpoint = 'https://your-api-endpoint.com/api/submit-form';

// Define your form data model
class FormData {
  final String name;
  final String email;
  final String message;

  FormData({
    required this.name,
    required this.email,
    required this.message,
  });
}

// Create a provider for the form data
final formDataProvider = StateProvider<FormData?>((ref) => null);

// Create a provider for the Dio instance
final dioProvider = Provider<Dio>((ref) => Dio());

// Create a provider for the form submission status
final formSubmissionStatusProvider =
    StateProvider<FormSubmissionStatus>((ref) => FormSubmissionStatus.initial);

// Define enum for form submission status
enum FormSubmissionStatus {
  initial,
  loading,
  success,
  error,
}
