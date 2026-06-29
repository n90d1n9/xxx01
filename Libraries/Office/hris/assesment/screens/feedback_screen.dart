import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/feedback_provider.dart';
import '../widgets/feedback_employee_selection.dart';
import '../widgets/feedback_form_panel.dart';
import '../widgets/feedback_success_view.dart';
import '../widgets/feedback_summary_grid.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackProvider);
    final summary = ref.watch(feedbackSummaryProvider);
    final notifier = ref.read(feedbackProvider.notifier);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('360 Feedback'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback history opened')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          state.isSubmitted
              ? const FeedbackSuccessView()
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FeedbackSummaryGrid(summary: summary),
                      const SizedBox(height: 16),
                      if (state.selectedEmployee == null)
                        FeedbackEmployeeSelection(
                          employees: state.employees,
                          onSelected: notifier.selectEmployee,
                        )
                      else
                        FeedbackFormPanel(
                          state: state,
                          onRatingUpdate: notifier.updateRating,
                          onCommentsChanged: notifier.updateComments,
                          onSubmit: notifier.submitFeedback,
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
