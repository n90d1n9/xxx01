// State class to hold notification data
import 'notification_message.dart';

class NotificationState {
  final List<NotificationMessage> messages;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
