// feedback_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

// Define the feedback types
enum FeedbackType { usage, help, complaint, suggestion }

// Model for feedback
class FeedbackModel {
  final String id;
  final FeedbackType type;
  final String subject;
  final String message;
  final DateTime createdAt;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? error;

  FeedbackModel({
    required this.id,
    required this.type,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.error,
  });

  FeedbackModel copyWith({
    String? id,
    FeedbackType? type,
    String? subject,
    String? message,
    DateTime? createdAt,
    bool? isSubmitting,
    bool? isSubmitted,
    String? error,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error ?? this.error,
    );
  }
}

// Feedback repository - handles API calls in a real app
class FeedbackRepository {
  Future<bool> submitFeedback(FeedbackModel feedback) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, you would send data to your backend
    return true;
  }
}

// Provider for the feedback repository
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

// Provider for the feedback state
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackModel>(
  (ref) => FeedbackNotifier(ref),
);

// Notifier to handle feedback state
class FeedbackNotifier extends StateNotifier<FeedbackModel> {
  final Ref ref;

  FeedbackNotifier(this.ref)
    : super(
        FeedbackModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: FeedbackType.usage,
          subject: '',
          message: '',
          createdAt: DateTime.now(),
        ),
      );

  void updateType(FeedbackType type) {
    state = state.copyWith(type: type);
  }

  void updateSubject(String value) {
    state = state.copyWith(subject: value);
  }

  void updateMessage(String value) {
    state = state.copyWith(message: value);
  }

  Future<void> submitFeedback() async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final success = await ref
          .read(feedbackRepositoryProvider)
          .submitFeedback(state);

      if (success) {
        state = state.copyWith(isSubmitting: false, isSubmitted: true);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: 'Failed to submit feedback. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'An error occurred: ${e.toString()}',
      );
    }
  }

  void resetForm() {
    state = FeedbackModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: FeedbackType.usage,
      subject: '',
      message: '',
      createdAt: DateTime.now(),
    );
  }
}

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedback = ref.watch(feedbackProvider);
    final notifier = ref.read(feedbackProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Send Feedback',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: feedback.isSubmitted
          ? buildSuccessView(context, notifier)
          : buildFeedbackForm(context, feedback, notifier),
    );
  }

  Widget buildSuccessView(BuildContext context, FeedbackNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Thank You!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your feedback has been submitted successfully. We appreciate your input!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => notifier.resetForm(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Send Another Feedback'),
          ),
        ],
      ),
    );
  }

  Widget buildFeedbackForm(
    BuildContext context,
    FeedbackModel feedback,
    FeedbackNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feedback type selection
          Text(
            'What kind of feedback do you have?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                buildFeedbackTypeOption(
                  context: context,
                  icon: Icons.analytics_outlined,
                  title: 'App Usage',
                  subtitle: 'Share your experience using the app',
                  isSelected: feedback.type == FeedbackType.usage,
                  onTap: () => notifier.updateType(FeedbackType.usage),
                ),
                buildFeedbackTypeOption(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Help Request',
                  subtitle: 'Need assistance with something?',
                  isSelected: feedback.type == FeedbackType.help,
                  onTap: () => notifier.updateType(FeedbackType.help),
                ),
                buildFeedbackTypeOption(
                  context: context,
                  icon: Icons.error_outline,
                  title: 'Complaint',
                  subtitle: 'Report an issue or problem',
                  isSelected: feedback.type == FeedbackType.complaint,
                  onTap: () => notifier.updateType(FeedbackType.complaint),
                ),
                buildFeedbackTypeOption(
                  context: context,
                  icon: Icons.lightbulb_outline,
                  title: 'Suggestion',
                  subtitle: 'Ideas to improve the app',
                  isSelected: feedback.type == FeedbackType.suggestion,
                  onTap: () => notifier.updateType(FeedbackType.suggestion),
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Subject field
          Text(
            'Subject',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: notifier.updateSubject,
            decoration: InputDecoration(
              hintText: 'Enter a brief summary',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Message field
          Text(
            'Message',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: notifier.updateMessage,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Provide details about your feedback...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          if (feedback.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feedback.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (feedback.subject.isNotEmpty &&
                      feedback.message.isNotEmpty &&
                      !feedback.isSubmitting)
                  ? () => notifier.submitFeedback()
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: feedback.isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeedbackTypeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                else
                  Icon(Icons.circle_outlined, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}

void main(List<String> args) {
  runApp(ProviderScope(child: MaterialApp(home: FeedbackScreen())));
}

// Add this screen to your app's routes
// Example usage:
// void main() {
//   runApp(
//     ProviderScope(
//       child: MaterialApp(
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: FeedbackScreen(),
//       ),
//     ),
//   );
// }
